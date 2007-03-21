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
		</cflock>
		
		<cfreturn bResult />
	</cffunction>
	
	<cffunction name="GetFromObjectBroker" access="public" output="false" returntype="struct">
		<cfargument name="ObjectID" required="yes" type="UUID">
		<cfargument name="typename" required="true" type="string">
		
		<cfset var stobj = structNew()>
		
		<cfif structKeyExists(application, "bObjectBroker") and application.bObjectBroker>
			<!--- If the type is stored in the objectBroker and the Object is currently in the ObjectBroker --->
			<cfif structkeyexists(application.objectbroker, arguments.typename) 
					AND structkeyexists(application.objectbroker[arguments.typename], arguments.objectid)
					AND structkeyexists(application.objectbroker[arguments.typename][arguments.objectid], "stobj" )>
				
				<cfset stobj = duplicate(application.objectbroker[arguments.typename][arguments.objectid].stobj)>
				<cftrace type="information" category="coapi" var="stobj.typename" text="getData() used objectpool cache.">
				
			</cfif>
		</cfif>
		
		<cfreturn stobj>
	</cffunction>
		
	<cffunction name="getWebskin" access="public" output="false" returntype="string" hint="Searches the object broker in an attempt to locate the requested webskin template">
		<cfargument name="ObjectID" required="yes" type="UUID">
		<cfargument name="typename" required="true" type="string">
		<cfargument name="template" required="true" type="string">
		
		<cfset var webskinHTML = "" />
		<cfset var i = "" />
		
		<cfif application.bObjectBroker>
			<cfif request.mode.design eq 1>
				<!--- DO NOT USE CACHE IF IN DESIGN MODE --->
			<cfelse>
				
				<cfif listContainsNoCase(application.stcoapi[arguments.typename].lObjectBrokerWebskins, arguments.template)>
					<cfif structKeyExists(application.objectbroker, arguments.typename)
						AND 	structKeyExists(application.objectbroker[arguments.typename], arguments.objectid)
						AND 	structKeyExists(application.objectbroker[arguments.typename][arguments.objectid], "stWebskins")
						AND 	structKeyExists(application.objectbroker[arguments.typename][arguments.objectid].stWebskins, arguments.template)
						AND 	structKeyExists(application.objectbroker[arguments.typename][arguments.objectid].stWebskins[arguments.template], "datetimecreated")
						AND 	structKeyExists(application.objectbroker[arguments.typename][arguments.objectid].stWebskins[arguments.template], "webskinHTML")
						>
						<cfif DateDiff('n', application.objectbroker[arguments.typename][arguments.objectid].stWebskins[arguments.template].datetimecreated, now()) LT application.stcoapi[arguments.typename].stObjectBrokerWebskins[arguments.template].timeout >
							<cfset webskinHTML = application.objectbroker[arguments.typename][arguments.objectid].stWebskins[arguments.template].webskinHTML />
							
							<!--- Place any request.inHead variables back into the request scope from which it came. --->
							<cfparam name="request.inHead" default="#structNew()#" />
							<cfloop list="#structKeyList(application.objectbroker[arguments.typename][arguments.objectid].stWebskins[arguments.template].inHead)#" index="i">
								<cfset request.inHead[i] = application.objectbroker[arguments.typename][arguments.objectid].stWebskins[arguments.template].inHead[i] />
							</cfloop>
						</cfif>					
					</cfif>		
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn webskinHTML />
	</cffunction>
			
	<cffunction name="addWebskin" access="public" output="false" returntype="boolean" hint="Searches the object broker in an attempt to locate the requested webskin template">
		<cfargument name="ObjectID" required="yes" type="UUID">
		<cfargument name="typename" required="true" type="string">
		<cfargument name="template" required="true" type="string">
		<cfargument name="HTML" required="true" type="string">
		
		<cfset var webskinHTML = "" />
		<cfset var bSuccess = "true" />
		
		<cfif application.bObjectBroker>
			<cfif request.mode.design eq 1>
				<!--- DO NOT ADD TO CACHE IF IN DESIGN MODE --->
			<cfelse>
				<cfif listContainsNoCase(application.stcoapi[arguments.typename].lObjectBrokerWebskins, arguments.template) and len(arguments.HTML)>
					<cfif structKeyExists(application.objectbroker[arguments.typename], arguments.objectid)>
						<cflock name="objectBroker" type="exclusive" timeout="2" throwontimeout="true">
							<cfif not structKeyExists(application.objectbroker[arguments.typename][arguments.objectid], "stWebskins")>
								<cfset application.objectbroker[arguments.typename][arguments.objectid].stWebskins = structNew() />
							</cfif>
																		
							<cfset application.objectbroker[arguments.typename][arguments.objectid].stWebskins[arguments.template] = structNew() />
							<cfset application.objectbroker[arguments.typename][arguments.objectid].stWebskins[arguments.template].datetimecreated = now() />
							<cfset application.objectbroker[arguments.typename][arguments.objectid].stWebskins[arguments.template].webskinHTML = trim(arguments.HTML) />
		
							
							<!--- Add the current State of the request.inHead scope into the broker --->
							<cfparam name="request.inHead" default="#structNew()#">
						
							<cfset application.objectbroker[arguments.typename][arguments.objectid].stWebskins[arguments.template].inHead = duplicate(request.inHead) />
						</cflock>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn bSuccess />
		
	</cffunction>
	
	<cffunction name="removeWebskin" access="public" output="false" returntype="boolean" hint="Searches the object broker in an attempt to locate the requested webskin template">
		<cfargument name="ObjectID" required="yes" type="UUID">
		<cfargument name="typename" required="true" type="string">
		<cfargument name="template" required="true" type="string">
		
		<cfset var bSuccess = "true" />
		
		
		<cfif application.bObjectBroker>
		
			<cfif structKeyExists(application.objectbroker[arguments.typename], arguments.objectid)>
				<cfif structKeyExists(application.objectbroker[arguments.typename][arguments.objectid], "stWebskins")>
					<cflock name="objectBroker" type="exclusive" timeout="2" throwontimeout="true">
						<cfset structDelete(application.objectbroker[arguments.typename][arguments.objectid].stWebskins, arguments.template) />
					</cflock>
				</cfif>
			</cfif>
		
		</cfif>
	
		
		<cfreturn bSuccess />
		
	</cffunction>
	
	
	
	<cffunction name="AddToObjectBroker" access="public" output="true" returntype="boolean">
		<cfargument name="stObj" required="yes" type="struct">
		<cfargument name="typename" required="true" type="string">
		
		<cfif structKeyExists(application, "bObjectBroker") and application.bObjectBroker>
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
		
		<cfif application.bObjectBroker>
			<cfif arraylen(application.objectbroker[arguments.typename].aObjects) GT application.objectbroker[arguments.typename].maxObjects>
				
				<cfset numberToRemove =  Round(application.objectbroker[arguments.typename].maxObjects / 10) />
				<cfif numberToRemove GT 0>
					<cfloop from="1" to="#numberToRemove#" index="i">		
						<cfset lRemoveObjectIDs = listAppend(lRemoveObjectIDs, application.objectbroker[arguments.typename].aObjects[i]) />			
					<!--- 	<!--- Get the objectid in the first (oldest) position  --->
						<cfset ObjectToDelete = application.objectbroker[arguments.typename].aObjects[1]>
						
						<!--- Delete the structure that has the key of this objectid --->
						<cfset StructDelete(application.objectbroker[arguments.typename],ObjectToDelete)>
						
						<!--- Now delete the first (oldest) position of the array  --->
						<cfset arrayDeleteAt(application.objectbroker[arguments.typename].aObjects,1)>  --->
					</cfloop>
					
					<cfset removeFromObjectBroker(lObjectIDs=lRemoveObjectIDs, typename=arguments.typename) />
				</cfif>
				
				
				<cftrace type="information" category="coapi" text="ObjectBroker Removed #numberToRemove# objects from FIFO #arguments.typename# stack.">
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="RemoveFromObjectBroker" access="public" output="true" returntype="void">
		<cfargument name="lObjectIDs" required="true" type="string">
		<cfargument name="typename" required="true" type="string" default="">
		
		<cfset var aObjectIds = arrayNew(1) />
		<cfset var oWebskinAncestor = createObject("component", application.stcoapi.dmWebskinAncestor.packagePath) />						
		<cfset var qWebskinAncestors = queryNew("blah") />

		<cfif application.bObjectBroker>
			<cfif structkeyexists(application.objectbroker, arguments.typename)>
				<cfloop list="#arguments.lObjectIDs#" index="i">				
					<cfif structkeyexists(application.objectbroker[arguments.typename], i)>
						
						
						<!--- Find any ancestor webskins and delete them as well --->
						<cfset qWebskinAncestors = oWebskinAncestor.getAncestorWebskins(webskinObjectID=i) />
						
						<cfif qWebskinAncestors.recordCount>
							<cfloop query="qWebskinAncestors">
								<cfset bSuccess = removeWebskin(objectid=qWebskinAncestors.ancestorID,typename=qWebskinAncestors.ancestorTypename,template=qWebskinAncestors.ancestorTemplate) />
								<cfset stResult = oWebskinAncestor.delete(objectid=qWebskinAncestors.objectid) />
							</cfloop>
						</cfif>
						<cflock name="objectBroker" type="exclusive" timeout="2" throwontimeout="true">
							<cfset StructDelete(application.objectbroker[arguments.typename], i)>
						</cflock>
					</cfif>
				</cfloop>
				
				<cfset aObjectIds = ListToArray(arguments.lObjectIDs)>
				
				<cflock name="objectBroker" type="exclusive" timeout="2" throwontimeout="true">
					<cfset application.objectBroker[arguments.typename].aObjects.removeAll(aObjectIds) >
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