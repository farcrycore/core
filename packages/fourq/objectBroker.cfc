<cfcomponent name="objectBroker" displayname="objectBroker" access="public" hint="Stores and manages cache of objects to enable faster access">

	<cffunction name="init" access="public" output="false" returntype="struct">
				
		<cfif not structKeyExists(application, "objectBroker")>
			<cflock name="objectBroker" type="exclusive" timeout="2" throwontimeout="true">	
				<cfset application.objectbroker =  structNew() />
			</cflock>
		</cfif>	
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="configureType" access="public" output="false" returntype="boolean">
		<cfargument name="typename" required="yes" type="string">
		<cfargument name="MaxObjects" required="no" type="numeric" default="100">
		<cfargument name="MaxWebskins" required="no" type="numeric" default="10">
		
		<cfset var bResult = "true" />
		
		<cflock name="objectBroker" type="exclusive" timeout="2" throwontimeout="true">			
			<cfset application.objectbroker[arguments.typename]=structnew() />
			<cfset application.objectbroker[arguments.typename].aobjects=arraynew(1) />
			<cfset application.objectbroker[arguments.typename].maxobjects=arguments.MaxObjects />
			<cfset application.objectbroker[arguments.typename].stTypeWebskins = structnew() />			
		</cflock>
		
		<cfreturn bResult />
	</cffunction>
	
	<cffunction name="GetFromObjectBroker" access="public" output="false" returntype="struct">
		<cfargument name="ObjectID" required="yes" type="UUID">
		<cfargument name="typename" required="true" type="string">
		
		<cfset var stobj = structNew()>
		
		<cfif application.bObjectBroker>
			<!--- If the type is stored in the objectBroker and the Object is currently in the ObjectBroker --->
			<cfif structkeyexists(application.objectbroker, arguments.typename) 
					AND structkeyexists(application.objectbroker[arguments.typename], arguments.objectid)
					AND structkeyexists(application.objectbroker[arguments.typename][arguments.objectid], "stobj" )>
				
				<cfset stobj = duplicate(application.objectbroker[arguments.typename][arguments.objectid].stobj)>
				<!--- <cftrace type="information" category="coapi" var="stobj.typename" text="getData() used objectpool cache."> --->
				
			</cfif>
		</cfif>
		
		<cfreturn stobj>
	</cffunction>
		
	<cffunction name="getWebskin" access="public" output="false" returntype="string" hint="Searches the object broker in an attempt to locate the requested webskin template">
		<cfargument name="ObjectID" required="false" type="UUID">
		<cfargument name="typename" required="true" type="string">
		<cfargument name="template" required="true" type="string">
		<cfargument name="hashKey" required="true" type="string">
		
		<cfset var webskinHTML = "" />
		<cfset var i = "" />
		<cfset var j = "" />
		<cfset var k = "" />
		<cfset var bFlushCache = 0 />
		<cfset var stCacheWebskin = structNew() />
		<cfset var webskinTypename = arguments.typename /><!--- Default to the typename passed in --->
		<cfset var stCoapi = structNew() />
		
		<cfif arguments.typename EQ "farCoapi">
			<!--- This means its a type webskin and we need to look for the timeout value on the related type. --->			
			<cfset stCoapi = createObject("component", application.stcoapi["farCoapi"].packagePath).getData(objectid="#arguments.objectid#") />
			<cfset webskinTypename = stCoapi.name />
		</cfif>

		
		
		<cfif application.bObjectBroker>
		
			<cfif request.mode.flushcache EQ 1 AND structKeyExists(arguments, "objectid")>
				<cfset bFlushCache = removeWebskin(objectid=arguments.objectid, typename=arguments.typename, template=template) />
			</cfif>
		
			<cfif request.mode.design eq 1 OR request.mode.lvalidstatus NEQ "approved" OR (structKeyExists(url, "updateapp") AND url.updateapp EQ 1)>
				<!--- DO NOT USE CACHE IF IN DESIGN MODE or SHOWING MORE THAN APPROVED OBJECTS or UPDATING APP --->
			<cfelse>
				<cfif listFindNoCase(application.stcoapi[webskinTypename].lObjectBrokerWebskins, arguments.template)>
					<cfif structkeyexists(arguments,"objectid")>
						<cfif structKeyExists(application.objectbroker, arguments.typename)
							AND 	structKeyExists(application.objectbroker[arguments.typename], arguments.objectid)
							AND 	structKeyExists(application.objectbroker[arguments.typename][arguments.objectid], "stWebskins")
							AND 	structKeyExists(application.objectbroker[arguments.typename][arguments.objectid].stWebskins, arguments.template)>
												
							<cfif len(arguments.hashKey) AND structKeyExists(application.objectbroker[arguments.typename][arguments.objectid].stWebskins[arguments.template], hash("#arguments.hashKey#"))>							
								<cfset stCacheWebskin = application.objectbroker[arguments.typename][arguments.objectid].stWebskins[arguments.template]["#hash('#arguments.hashKey#')#"] />
							<cfelseif structKeyExists(application.objectbroker[arguments.typename][arguments.objectid].stWebskins[arguments.template], hash("#arguments.hashKey##cgi.http_host##cgi.script_name##cgi.query_string#"))>
								<cfset stCacheWebskin = application.objectbroker[arguments.typename][arguments.objectid].stWebskins[arguments.template]["#hash('#arguments.hashKey##cgi.http_host##cgi.script_name##cgi.query_string#')#"] />
							<cfelseif structKeyExists(application.objectbroker[arguments.typename][arguments.objectid].stWebskins[arguments.template], "standard") >
								<cfset stCacheWebskin = application.objectbroker[arguments.typename][arguments.objectid].stWebskins[arguments.template].standard />
							</cfif>
						</cfif>
					</cfif>
					
					<cfif not structisempty(stCacheWebskin)>
						<cfif structKeyExists(stCacheWebskin, "datetimecreated")
							AND structKeyExists(stCacheWebskin, "webskinHTML") >

							<cfif DateDiff('n', stCacheWebskin.datetimecreated, now()) LT stCacheWebskin.timeout >
								<cfset webskinHTML = stCacheWebskin.webskinHTML />
								
								<!--- Place any request.inHead variables back into the request scope from which it came. --->
								<cfparam name="request.inHead" default="#structNew()#" />
								<cfparam name="request.inhead.stCustom" default="#structNew()#" />
								<cfparam name="request.inhead.aCustomIDs" default="#arrayNew(1)#" />
								<cfparam name="request.inhead.stOnReady" default="#structNew()#" />
								<cfparam name="request.inhead.aOnReadyIDs" default="#arrayNew(1)#" />
								
								<cfloop list="#structKeyList(stCacheWebskin.inHead)#" index="i">
									<cfswitch expression="#i#">
										<cfcase value="stCustom">
											<cfloop list="#structKeyList(stCacheWebskin.inHead.stCustom)#" index="j">
												<cfif not structKeyExists(request.inHead.stCustom, j)>
													<cfset request.inHead.stCustom[j] = stCacheWebskin.inHead.stCustom[j] />
												</cfif>
												
												<cfset application.coapi.objectbroker.addhtmlHeadToWebskins(id="#j#", text="#stCacheWebskin.inHead.stCustom[j]#") />
	
											</cfloop>
										</cfcase>
										<cfcase value="aCustomIDs">
											<cfloop from="1" to="#arrayLen(stCacheWebskin.inHead.aCustomIDs)#" index="k">
												<cfif NOT listFindNoCase(arrayToList(request.inHead.aCustomIDs), stCacheWebskin.inHead.aCustomIDs[k])>
													<cfset arrayAppend(request.inHead.aCustomIDs,stCacheWebskin.inHead.aCustomIDs[k]) />
												</cfif>
											</cfloop>
										</cfcase>
										<cfcase value="stOnReady">
											<cfloop list="#structKeyList(stCacheWebskin.inHead.stOnReady)#" index="j">
												<cfif not structKeyExists(request.inHead.stOnReady, j)>
													<cfset request.inHead.stOnReady[j] = stCacheWebskin.inHead.stOnReady[j] />
												</cfif>
												
												<cfset application.coapi.objectbroker.addhtmlHeadToWebskins(id="#j#", onReady="#stCacheWebskin.inHead.stOnReady[j]#") />
	
											</cfloop>
										</cfcase>
										<cfcase value="aOnReadyIDs">
											<cfloop from="1" to="#arrayLen(stCacheWebskin.inHead.aOnReadyIDs)#" index="k">
												<cfif NOT listFindNoCase(arrayToList(request.inHead.aOnReadyIDs), stCacheWebskin.inHead.aOnReadyIDs[k])>
													<cfset arrayAppend(request.inHead.aOnReadyIDs,stCacheWebskin.inHead.aOnReadyIDs[k]) />
												</cfif>
											</cfloop>
										</cfcase>
										<cfdefaultcase>
											<cfset application.coapi.objectbroker.addhtmlHeadToWebskins(library=i) />
											<cfset request.inHead[i] = stCacheWebskin.inHead[i] />
										</cfdefaultcase>
									</cfswitch>
						
								</cfloop>

							</cfif>	
							
						</cfif>	
					</cfif>
				</cfif>
			</cfif>
			
		</cfif>
		<cfreturn webskinHTML />
	</cffunction>
			
	<cffunction name="addhtmlHeadToWebskins" access="public" output="true" returntype="void" hint="Adds the result of a skin:htmlHead to all relevent webskin caches">
		<cfargument name="id" type="string" required="false" default="#createUUID()#" />
		<cfargument name="text" type="string" required="false" default="" />
		<cfargument name="library" type="string" required="false" default="" />
		<cfargument name="libraryState" type="boolean" required="false" default="true" />
		<cfargument name="onReady" type="string" required="false" default="" />
		
		<cfset var iWebskin = "">
		<cfset var iLibrary = "">

		<cfif len(arguments.id) or listlen(arguments.library)>
			<cfif structKeyExists(request, "aAncestorWebskins") AND arrayLen(request.aAncestorWebskins)>
				<cfloop from="1" to="#arrayLen(request.aAncestorWebskins)#" index="iWebskin">
					<cfif listlen(arguments.library)>
						<cfloop list="#arguments.library#" index="iLibrary">
							<cfset request.aAncestorWebskins[iWebskin].inHead[iLibrary] = arguments.libraryState />
						</cfloop>
					<cfelseif len(arguments.onReady)>
						<!--- If we are currently inside of a webskin we need to add this id to the current webskin --->					
						<cfif NOT structKeyExists(request.aAncestorWebskins[iWebskin].inhead.stOnReady, arguments.id)>
							<cfset request.aAncestorWebskins[iWebskin].inHead.stOnReady[arguments.id] = arguments.onReady />
							<cfset arrayAppend(request.aAncestorWebskins[iWebskin].inHead.aOnReadyIDs, arguments.id) />
						</cfif>
					<cfelse>
						<!--- If we are currently inside of a webskin we need to add this id to the current webskin --->					
						<cfif NOT structKeyExists(request.aAncestorWebskins[iWebskin].inhead.stCustom, arguments.id)>
							<cfset request.aAncestorWebskins[iWebskin].inHead.stCustom[arguments.id] = arguments.text />
							<cfset arrayAppend(request.aAncestorWebskins[iWebskin].inHead.aCustomIDs, arguments.id) />
						</cfif>
					</cfif>
				</cfloop>
			</cfif>	
		</cfif>
		
	</cffunction>		
	
	
	<cffunction name="addWebskin" access="public" output="true" returntype="boolean" hint="Adds webskin to object broker if all conditions are met">
		<cfargument name="ObjectID" required="false" type="UUID">
		<cfargument name="typename" required="true" type="string">
		<cfargument name="template" required="true" type="string">
		<cfargument name="HTML" required="true" type="string">
		<cfargument name="stCurrentView" required="true" type="struct">
		
		<cfset var webskinHTML = "" />
		<cfset var bAdded = "false" />
		<cfset var stCacheWebskin = structNew() />
		<cfset var hashString = "" />
		<cfset var webskinTypename = arguments.typename /><!--- Default to the typename passed in --->
		<cfset var stCoapi = structNew() />
		
		<cfif arguments.typename EQ "farCoapi">
			<!--- This means its a type webskin and we need to look for the timeout value on the related type. --->			
			<cfset stCoapi = createObject("component", application.stcoapi["farCoapi"].packagePath).getData(objectid="#arguments.objectid#") />
			<cfset webskinTypename = stCoapi.name />
		</cfif>
		
		<cfif application.bObjectBroker>
			<cfif request.mode.design eq 1 OR request.mode.lvalidstatus NEQ "approved" OR (structKeyExists(url, "updateapp") AND url.updateapp EQ 1)>
				<!--- DO NOT ADD TO CACHE IF IN DESIGN MODE or SHOWING MORE THAN APPROVED OBJECTS or UPDATING APP --->
			<cfelseif len(arguments.HTML)>
				<cfif listFindNoCase(application.stcoapi[webskinTypename].lObjectBrokerWebskins, arguments.template)>
					<cfif application.stcoapi[webskinTypename].stObjectBrokerWebskins[arguments.template].timeout NEQ 0>
						<cfif structKeyExists(application.objectbroker[arguments.typename], arguments.objectid)>
							<cflock name="objectBroker" type="exclusive" timeout="2" throwontimeout="true">
								<cfif not structKeyExists(application.objectbroker[arguments.typename][arguments.objectid], "stWebskins")>
									<cfset application.objectbroker[arguments.typename][arguments.objectid].stWebskins = structNew() />
								</cfif>			
								
								<!--- Add the current State of the request.inHead scope into the broker --->
								<cfparam name="request.inHead" default="#structNew()#">
								
								<cfset stCacheWebskin.datetimecreated = now() />
								<cfset stCacheWebskin.webskinHTML = trim(arguments.HTML) />	
								<cfset stCacheWebskin.inHead = duplicate(arguments.stCurrentView.inHead) />
								<cfset stCacheWebskin.timeout = arguments.stCurrentView.timeout />
	
								<cfif len(arguments.stCurrentView.hashKey)>
									<cfset hashString = arguments.stCurrentView.hashKey />
								</cfif>
								<cfif arguments.stCurrentView.hashURL>
									<cfset hashString = "#hashString##cgi.http_host##cgi.script_name##cgi.query_string#" />
								</cfif>
								
								<cfif len(hashString)>
									<cfset application.objectbroker[arguments.typename][arguments.objectid].stWebskins[arguments.template][hash("#hashString#")] = stCacheWebskin />
								<cfelse>
									<cfset application.objectbroker[arguments.typename][arguments.objectid].stWebskins[arguments.template]["standard"] = stCacheWebskin />
								</cfif>
																
								<cfset bAdded = true />
							</cflock>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn bAdded />
		
	</cffunction>
	
	<cffunction name="removeWebskin" access="public" output="false" returntype="boolean" hint="Searches the object broker in an attempt to locate the requested webskin template">
		<cfargument name="ObjectID" required="false" type="UUID">
		<cfargument name="typename" required="true" type="string">
		<cfargument name="template" required="true" type="string">
		
		<cfset var bSuccess = "true" />
		
		
		<cfif application.bObjectBroker>
		
			<cfif structKeyExists(application.objectbroker, arguments.typename)>
				<cfif structKeyExists(application.objectbroker[arguments.typename], arguments.objectid)>
					<cfif structKeyExists(application.objectbroker[arguments.typename][arguments.objectid], "stWebskins")>
						<cflock name="objectBroker" type="exclusive" timeout="2" throwontimeout="true">
							<cfset structDelete(application.objectbroker[arguments.typename][arguments.objectid].stWebskins, arguments.template) />
						</cflock>
					</cfif>
				<cfelse>
					<cfif structKeyExists(application.objectbroker[arguments.typename], "stTypeWebskins")>
						<cflock name="objectBroker" type="exclusive" timeout="2" throwontimeout="true">
							<cfset structDelete(application.objectbroker[arguments.typename].stTypeWebskins, arguments.template) />
						</cflock>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
	
		
		<cfreturn bSuccess />
		
	</cffunction>
	
	
	
	<cffunction name="AddToObjectBroker" access="public" output="true" returntype="boolean">
		<cfargument name="stObj" required="yes" type="struct">
		<cfargument name="typename" required="true" type="string">
		
		<cfif application.bObjectBroker>
			<!--- if the type is to be stored in the objectBroker --->
			<cfif structkeyexists(arguments.stObj, "objectid") AND structkeyexists(application.objectbroker, arguments.typename)>
				<cflock name="objectBroker" type="exclusive" timeout="2" throwontimeout="true">
					<!--- Create a key in the types object broker using the object id --->
					<cfset application.objectbroker[arguments.typename][arguments.stObj.objectid] = structNew() />
					
					<!--- Add the stobj into the new key. --->
					<cfset application.objectbroker[arguments.typename][arguments.stObj.objectid].stobj = duplicate(arguments.stObj) />
					
					<!--- Prepare for any webskins that may be placed in the object broker --->
					<cfset application.objectbroker[arguments.typename][arguments.stObj.objectid].stWebskins = structNew() />
					
					<!--- Add the objectid to the end of the FIFO array so we know its the latest to be added --->
					<cfset arrayappend(application.objectbroker[arguments.typename].aObjects,arguments.stObj.ObjectID)>
				</cflock>
				
				<!--- Cleanup the object broker just in case we have reached our limit of objects as defined by the metadata. --->
				<cfset cleanupObjectBroker(typename=arguments.typename)>
				<cfreturn true>
			<cfelse>
				<cfreturn false>
			</cfif>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	
		
	
	<cffunction name="CleanupObjectBroker" access="public" output="false" returntype="void" hint="Removes 10% of the items in the object broker if it is full.">
		<cfargument name="typename" required="yes" type="string">
		
		<cfset var numberToRemove = 0 />
		<cfset var lRemoveObjectIDs = "" />
		<cfset var i = "" />
		<cfset var objectToDelete = "" />
		
		<cfif application.bObjectBroker>
			<cfif arraylen(application.objectbroker[arguments.typename].aObjects) GT application.objectbroker[arguments.typename].maxObjects>
				
				<cfset numberToRemove =  Round(application.objectbroker[arguments.typename].maxObjects / 10) />
				<cfif numberToRemove GT 0>
					<cfloop from="1" to="#numberToRemove#" index="i">		
						<cfset lRemoveObjectIDs = listAppend(lRemoveObjectIDs, application.objectbroker[arguments.typename].aObjects[i]) />			
					</cfloop>
					
					<cfset removeFromObjectBroker(lObjectIDs=lRemoveObjectIDs, typename=arguments.typename) />
				</cfif>
				
				
				<!--- <cftrace type="information" category="coapi" text="ObjectBroker Removed #numberToRemove# objects from FIFO #arguments.typename# stack."> --->
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="RemoveFromObjectBroker" access="public" output="true" returntype="void">
		<cfargument name="lObjectIDs" required="true" type="string">
		<cfargument name="typename" required="true" type="string" default="">
		
		<cfset var aObjectIds = arrayNew(1) />
		<cfset var oWebskinAncestor = createObject("component", application.stcoapi.dmWebskinAncestor.packagePath) />						
		<cfset var qWebskinAncestors = queryNew("blah") />
		<cfset var i = "" />
		<cfset var bSuccess = "" />
		<cfset var stResult = structNew() />
		<cfset var pos = "" />
		<cfset var arrayList = "" />
		<cfset var deleted = "" />
		<cfset var oCaster = "" />

		<cfif application.bObjectBroker>
			<cfif structkeyexists(application.objectbroker, arguments.typename)>
				<cfloop list="#arguments.lObjectIDs#" index="i">				
					<cfif structkeyexists(application.objectbroker[arguments.typename], i)>
						
						
						<!--- Find any ancestor webskins and delete them as well --->
						<cfset qWebskinAncestors = oWebskinAncestor.getAncestorWebskins(webskinObjectID=i) />
						
						<cfif qWebskinAncestors.recordCount>
							<cfloop query="qWebskinAncestors">
								<cfset bSuccess = removeWebskin(objectid=qWebskinAncestors.ancestorID,typename=qWebskinAncestors.ancestorTypename,template=qWebskinAncestors.ancestorTemplate) />
								<!--- <cfset stResult = oWebskinAncestor.delete(objectid=qWebskinAncestors.objectid) /> --->
							</cfloop>
						</cfif>
						<cflock name="objectBroker" type="exclusive" timeout="2" throwontimeout="true">
							<cfset StructDelete(application.objectbroker[arguments.typename], i)>
						</cflock>
					</cfif>
				</cfloop>
				
				<cfset aObjectIds = ListToArray(arguments.lObjectIDs)>
				
				<cflock name="objectBroker" type="exclusive" timeout="2" throwontimeout="true">
					<cfswitch expression="#server.coldfusion.productname#">
						<cfcase value="Railo">
							<cfset oCaster = createObject('java','railo.runtime.op.Caster') />
							<cfset application.objectBroker[arguments.typename].aObjects.removeAll(oCaster.toList(aObjectIds)) />
						</cfcase>
						<cfdefaultcase>
							<cfset application.objectBroker[arguments.typename].aObjects.removeAll(aObjectIds) >
						</cfdefaultcase>
					</cfswitch>					
				</cflock>
				
				<!--- 
				<cfset pos = application.objectBroker[arguments.typename].aObjects.contains(arguments.objectid) />
				<cfset arraylist = arraytoList(application.objectBroker[arguments.typename].aObjects)>
				<cfset pos = listContainsNoCase(arraylist,arguments.objectid)>
		
				<cfif pos GT 0>
					<cfset deleted = arrayDeleteAt(application.objectBroker[arguments.typename].aObjects,pos)>
				</cfif> --->
				
			</cfif>
		</cfif>
	</cffunction>

</cfcomponent>