<cfcomponent name="objectBroker" displayname="objectBroker" access="public" hint="Stores and manages cache of objects to enable faster access">

	<cffunction name="init" access="public" output="false" returntype="struct">
		<cfargument name="bFlush" default="false" type="boolean" hint="Allows the application to force a total flush of the objectbroker." />
		
		<cfif arguments.bFlush OR NOT structKeyExists(application, "objectBroker") OR NOT structKeyExists(application, "objectrecycler") OR NOT structKeyExists(this,"c")>
			<!--- This Java object gathers objects that were put in the broker but marked for garbage collection --->
			<cfset application.objectrecycler =  createObject("java", "java.lang.ref.ReferenceQueue") />
			
			<!--- Set up cache replacement queue --->
			<cfset cacheInitialise(1000,1000) />
		</cfif>	
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="GetFromObjectBroker" access="public" output="false" returntype="struct">
		<cfargument name="ObjectID" required="yes" type="UUID">
		<cfargument name="typename" required="true" type="string">
		
		<cfif isCacheable(typename=arguments.typename)>
			<cfreturn cachePull("#rereplace(application.applicationname,'[^\w\d]','','ALL')#_#arguments.typename#_#arguments.objectid#") />
		<cfelse>
			<cfreturn structnew() />
		</cfif>
	</cffunction>
	
	<cffunction name="getWebskin" access="public" output="true" returntype="struct" hint="Searches the object broker in an attempt to locate the requested webskin template. Returns a struct containing the webskinCacheID and the html.">
		<cfargument name="ObjectID" required="false" type="UUID">
		<cfargument name="typename" required="true" type="string">
		<cfargument name="template" required="true" type="string">
		<cfargument name="hashKey" required="true" type="string">
		
		<cfset var stResult = structNew() />
		<cfset var i = "" />
		<cfset var j = "" />
		<cfset var k = "" />
		<cfset var bFlushCache = 0 />
		<cfset var stCacheWebskin = structNew() />
		<cfset var webskinTypename = arguments.typename /><!--- Default to the typename passed in --->
		<cfset var stCoapi = structNew() />
		
		
		<cfset stResult.bInCache = false />
		<cfset stResult.webskinCacheID = "" />
		<cfset stResult.webskinHTML = "" />

		<cfif arguments.typename EQ "farCoapi">
			<!--- This means its a type webskin and we need to look for the timeout value on the related type. --->			
			<cfset stCoapi = application.fc.factory['farCoapi'].getData(objectid="#arguments.objectid#") />
			<cfset webskinTypename = stCoapi.name />
		</cfif>

		<cfif isCacheable(typename=webskinTypename,template=arguments.template)>
				
			<cfset stResult.webskinCacheID = generateWebskinCacheID(
					typename="#webskinTypename#", 
					template="#arguments.template#",
					hashKey="#arguments.hashKey#"
			) />

			<cfset stCacheWebskin = cachePull("#rereplace(application.applicationname,'[^\w\d]','','ALL')#_#webskinTypename#_#arguments.objectid#_#arguments.template#_#hash(stResult.webskinCacheID)#") />
			
			<cfif not structisempty(stCacheWebskin) AND 
				structKeyExists(stCacheWebskin, "datetimecreated") AND
				structKeyExists(stCacheWebskin, "webskinHTML") AND
				DateDiff('n', stCacheWebskin.datetimecreated, now()) LT stCacheWebskin.cacheTimeout >
				
				<cfset stResult.bInCache = true />
				<cfset stResult.webskinHTML = stCacheWebskin.webskinHTML />
				
				<!--- Update request browser timeout --->
				<cfif structkeyexists(stCacheWebskin,"browserCacheTimeout") and stCacheWebskin.browserCacheTimeout neq -1 and (not structkeyexists(request.fc,"browserCacheTimeout") or stCacheWebskin.browserCacheTimeout lt request.fc.browserCacheTimeout)>
					<cfset request.fc.browserCacheTimeout = stCacheWebskin.browserCacheTimeout />
				</cfif>
				
				<!--- Update request proxy timeout --->
				<cfif structkeyexists(stCacheWebskin,"proxyCacheTimeout") and stCacheWebskin.proxyCacheTimeout neq -1 and (not structkeyexists(request.fc,"proxyCacheTimeout") or stCacheWebskin.proxyCacheTimeout lt request.fc.proxyCacheTimeout)>
					<cfset request.fc.proxyCacheTimeout = stCacheWebskin.proxyCacheTimeout />
				</cfif>
				
				<!--- Place any request.inHead variables back into the request scope from which it came. --->
				<cfparam name="request.inHead" default="#structNew()#" />
				<cfparam name="request.inhead.stCustom" default="#structNew()#" />
				<cfparam name="request.inhead.aCustomIDs" default="#arrayNew(1)#" />
				<cfparam name="request.inhead.stOnReady" default="#structNew()#" />
				<cfparam name="request.inhead.aOnReadyIDs" default="#arrayNew(1)#" />
				
				<!--- CSS --->
				<cfparam name="request.inhead.stCSSLibraries" default="#structNew()#" />
				<cfparam name="request.inhead.aCSSLibraries" default="#arrayNew(1)#" />
				
				<!--- JS --->
				<cfparam name="request.inhead.stJSLibraries" default="#structNew()#" />
				<cfparam name="request.inhead.aJSLibraries" default="#arrayNew(1)#" />
				
				<cfloop list="#structKeyList(stCacheWebskin.inHead)#" index="i">
					<cfswitch expression="#i#">
						<cfcase value="stCustom">
							<cfloop list="#structKeyList(stCacheWebskin.inHead.stCustom)#" index="j">
								<cfif not structKeyExists(request.inHead.stCustom, j)>
									<cfset request.inHead.stCustom[j] = stCacheWebskin.inHead.stCustom[j] />
								</cfif>
								
								<cfset addhtmlHeadToWebskins(id="#j#", text="#stCacheWebskin.inHead.stCustom[j]#") />

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
								
								<cfset addhtmlHeadToWebskins(id="#j#", onReady="#stCacheWebskin.inHead.stOnReady[j]#") />

							</cfloop>
						</cfcase>
						<cfcase value="aOnReadyIDs">
							<cfloop from="1" to="#arrayLen(stCacheWebskin.inHead.aOnReadyIDs)#" index="k">
								<cfif NOT listFindNoCase(arrayToList(request.inHead.aOnReadyIDs), stCacheWebskin.inHead.aOnReadyIDs[k])>
									<cfset arrayAppend(request.inHead.aOnReadyIDs,stCacheWebskin.inHead.aOnReadyIDs[k]) />
								</cfif>
							</cfloop>
						</cfcase>
						
						<!--- CSS LIBRARIES --->
						
						<cfcase value="stCSSLibraries">
							<cfloop list="#structKeyList(stCacheWebskin.inHead.stCSSLibraries)#" index="j">
								<cfif not structKeyExists(request.inHead.stCSSLibraries, j)>
									<cfset request.inHead.stCSSLibraries[j] = stCacheWebskin.inHead.stCSSLibraries[j] />
								</cfif>			
							</cfloop>
						</cfcase>
						<cfcase value="aCSSLibraries">
							<cfloop from="1" to="#arrayLen(stCacheWebskin.inHead.aCSSLibraries)#" index="k">
								<cfif NOT listFindNoCase(arrayToList(request.inHead.aCSSLibraries), stCacheWebskin.inHead.aCSSLibraries[k])>
									<cfset arrayAppend(request.inHead.aCSSLibraries,stCacheWebskin.inHead.aCSSLibraries[k]) />
								</cfif>														
								<cfset addCSSHeadToWebskins(stCacheWebskin.inHead.stCSSLibraries[stCacheWebskin.inHead.aCSSLibraries[k]]) />
							</cfloop>
						</cfcase>
						

						<!--- JS LIBRARIES --->
						
						<cfcase value="stJSLibraries">
							<cfloop list="#structKeyList(stCacheWebskin.inHead.stJSLibraries)#" index="j">
								<cfif not structKeyExists(request.inHead.stJSLibraries, j)>
									<cfset request.inHead.stJSLibraries[j] = stCacheWebskin.inHead.stJSLibraries[j] />
								</cfif>																	
							</cfloop>
						</cfcase>
						<cfcase value="aJSLibraries">
							<cfloop from="1" to="#arrayLen(stCacheWebskin.inHead.aJSLibraries)#" index="k">
								<cfif NOT listFindNoCase(arrayToList(request.inHead.aJSLibraries), stCacheWebskin.inHead.aJSLibraries[k])>
									<cfset arrayAppend(request.inHead.aJSLibraries,stCacheWebskin.inHead.aJSLibraries[k]) />
								</cfif>														
								<cfset addJSHeadToWebskins(stCacheWebskin.inHead.stJSLibraries[stCacheWebskin.inHead.aJSLibraries[k]]) />
							</cfloop>
						</cfcase>
																	
						<cfdefaultcase>
							<cfset addhtmlHeadToWebskins(library=i) />
							<cfset request.inHead[i] = stCacheWebskin.inHead[i] />
						</cfdefaultcase>
					</cfswitch>
		
				</cfloop>

			</cfif>
			
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
		
	<cffunction name="generateWebskinCacheID" access="public" output="false" returntype="string" hint="Generates a webskin Cache ID that can be hashed to store a specific version of a webskin cache.">
		<cfargument name="typename" required="true" />
		<cfargument name="template" required="true" />
		<cfargument name="hashKey" required="false" default="" />
		<cfargument name="bCacheByURL" required="false" default="#application.coapi.coapiadmin.getWebskincacheByURL(typename=arguments.typename, template=arguments.template)#" />
		<cfargument name="bCacheByForm" required="false" default="#application.coapi.coapiadmin.getWebskincacheByForm(typename=arguments.typename, template=arguments.template)#" />
		<cfargument name="bCacheByRoles" required="false" default="#application.coapi.coapiadmin.getWebskincacheByRoles(typename=arguments.typename, template=arguments.template)#" />
		<cfargument name="lcacheByVars" required="false" default="#application.coapi.coapiadmin.getWebskincacheByVars(typename=arguments.typename, template=arguments.template)#" />

		<cfset var WebskinCacheID = "" />
		<cfset var iFormField = "" />
		<cfset var iViewState = "" />
	
		
		<!--- Always prefixed with the hash key. This can be overridden in the webskin call. It will include any cfparam attributes. --->
		<cfif len(arguments.hashKey)>
			<cfset WebskinCacheID = listAppend(WebskinCacheID, "#arguments.hashKey#") />
		</cfif>
		
		<cfif arguments.bCacheByURL>
			<cfset WebskinCacheID = listAppend(WebskinCacheID,"script_name:#cgi.script_name#,query_string:#cgi.query_string#") />
		</cfif>
		
		<cfif arguments.bCacheByForm AND isDefined("form")>
			<cfif structIsEmpty(form)>
				<cfset WebskinCacheID = listAppend(WebskinCacheID, "form:empty") />
			<cfelse>
				<cfloop list="#listSort(structKeyList(form),'text')#" index="iFormField">
					<cfif isSimpleValue(form[iFormField])>
						<cfset WebskinCacheID = listAppend(WebskinCacheID, "form[#iFormField#]:#form[iFormField]#") />
					<cfelse>
						<cfset WebskinCacheID = listAppend(WebskinCacheID, "form[#iFormField#]:{complex}") />
					</cfif>
				</cfloop>
			</cfif>					
		</cfif>
		
		<cfif arguments.bCacheByRoles>
			<cfif application.security.isLoggedIn()>
				<cfset WebskinCacheID = listAppend(WebskinCacheID,"roles:#listSort(session.security.roles,'text')#") />
			<cfelse>
				<cfset WebskinCacheID = listAppend(WebskinCacheID, "roles:anonymous") />
			</cfif>									
		</cfif>

		<cfif listLen(arguments.lcacheByVars)>
			<cfloop list="#listSort(arguments.lcacheByVars, 'text')#" index="iViewState">
				
				<cftry>
					<cfif isDefined(trim(listfirst(iViewState,":")))>
						<cfset WebskinCacheID = listAppend(WebskinCacheID, "#listfirst(iViewState,':')#:#evaluate(trim(listfirst(iViewState,':')))#") />
					<cfelse>
						<!--- If the var is defined with a default (e.g. @@cacheByVars: url.page:1), the default is incorporated into the hash --->
						<!--- If the var does not define a default (e.g. @@cacheByVars: url.error), that valueless string indicates the null --->
						<cfset WebskinCacheID = listAppend(WebskinCacheID, "#iViewState#") />
					</cfif>		
				
					<cfcatch type="any">
						<cftry>
							<cfset WebskinCacheID = listAppend(WebskinCacheID, "#listfirst(iViewState,':')#:#evaluate(trim(listfirst(iViewState,':')))#") />
							
							<cfcatch type="any">
								<cfset WebskinCacheID = listAppend(WebskinCacheID, "#listfirst(iViewState,':')#:invalidVarName") />
							</cfcatch>
						</cftry>						
					</cfcatch>
				</cftry>		
			</cfloop>								
		</cfif>

		<cfreturn WebskinCacheID />
	</cffunction>	
			
	<cffunction name="addhtmlHeadToWebskins" access="public" output="true" returntype="void" hint="Adds the result of a skin:htmlHead to all relevent webskin caches">
		<cfargument name="id" type="string" required="false" default="#application.fc.utils.createJavaUUID()#" />
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
			
	<cffunction name="addCSSHeadToWebskins" access="public" output="true" returntype="void" hint="Adds the result of a skin:loadCSS to all relevent webskin caches">
		<cfargument name="stCSS" type="struct" required="true" />
		
		<cfset var iWebskin = "">

		<cfif structKeyExists(request, "aAncestorWebskins") AND arrayLen(request.aAncestorWebskins)>
			<cfloop from="1" to="#arrayLen(request.aAncestorWebskins)#" index="iWebskin">
				<!--- If we are currently inside of a webskin we need to add this id to the current webskin --->					
				<cfif NOT structKeyExists(request.aAncestorWebskins[iWebskin].inhead.stCSSLibraries, arguments.stCSS.id)>
					
					<!--- Add the id to the array to make sure we keep track of the order in which these libraries need to appear. --->
					<cfset arrayAppend(request.aAncestorWebskins[iWebskin].inHead.aCSSLibraries, arguments.stCSS.id) />
					
					<!--- Add the css information to the struct so we will be able to load it all correctly into the header at the end of the request. --->
					<cfset request.aAncestorWebskins[iWebskin].inHead.stCSSLibraries[stCSS.id] = arguments.stCSS />
					
				</cfif>
			</cfloop>
		</cfif>	
	</cffunction>
	<cffunction name="addJSHeadToWebskins" access="public" output="true" returntype="void" hint="Adds the result of a skin:loadJS to all relevent webskin caches">
		<cfargument name="stJS" type="struct" required="true" />
		
		<cfset var iWebskin = "">

		<cfif structKeyExists(request, "aAncestorWebskins") AND arrayLen(request.aAncestorWebskins)>
			<cfloop from="1" to="#arrayLen(request.aAncestorWebskins)#" index="iWebskin">
				<!--- If we are currently inside of a webskin we need to add this id to the current webskin --->					
				<cfif NOT structKeyExists(request.aAncestorWebskins[iWebskin].inhead.stJSLibraries, arguments.stJS.id)>
					
					<!--- Add the id to the array to make sure we keep track of the order in which these libraries need to appear. --->
					<cfset arrayAppend(request.aAncestorWebskins[iWebskin].inHead.aJSLibraries, arguments.stJS.id) />
					
					<!--- Add the JS information to the struct so we will be able to load it all correctly into the header at the end of the request. --->
					<cfset request.aAncestorWebskins[iWebskin].inHead.stJSLibraries[stJS.id] = arguments.stJS />
					
				</cfif>
			</cfloop>
		</cfif>	
	</cffunction>
	
	<cffunction name="isCacheable" access="private" output="false" returntype="boolean" hint="Utility function for addWebskin - returns true if the conditions for caching are met">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="template" type="string" required="false" />
		
		<cfparam name="request.mode.flushcache" default="0">
		<cfparam name="request.mode.showdraft" default="0">
		<cfparam name="request.mode.lvalidstatus" default="0">
		
		<cfset var baseCheck = application.bObjectBroker and
				  not (
				  	structKeyExists(request,"mode") AND 
				  	(
				  		request.mode.flushcache EQ 1 OR 
				  		request.mode.showdraft EQ 1 OR 
				  		request.mode.lvalidstatus NEQ "approved"
				  	) 
				  ) and
				  not (structKeyExists(url, "updateapp") AND url.updateapp EQ 1) and
				  (
				  	isdefined("application.stCOAPI.#arguments.typename#.bObjectBroker") and 
				  	application.stcoapi[arguments.typename].bObjectBroker
				  ) />
		
		<cfif structkeyexists(arguments,"template")>
			<cfset baseCheck = baseCheck and
					  not (
					  	isDefined("form") AND 
					  	not structIsEmpty(form) and 
					  	application.coapi.coapiadmin.getWebskinCacheFlushOnFormPost(typename=arguments.typename,template=arguments.template)
					  ) and
					  not (
					  	structKeyExists(request,"mode") AND 
					  	(
					  		request.mode.tracewebskins eq 1 OR 
					  		request.mode.design eq 1
					  	) 
					  ) and
					  structKeyExists(application.stcoapi[arguments.typename].stWebskins, arguments.template) and
					  application.stcoapi[arguments.typename].stWebskins[arguments.template].cacheStatus EQ 1 />
		</cfif>
		
		<cfreturn baseCheck />
	</cffunction>
	
	<cffunction name="addWebskin" access="public" output="true" returntype="boolean" hint="Adds webskin to object broker if all conditions are met">
		<cfargument name="ObjectID" required="false" type="UUID">
		<cfargument name="typename" required="true" type="string">
		<cfargument name="template" required="true" type="string">
		<cfargument name="webskinCacheID" required="true" type="string">
		<cfargument name="HTML" required="true" type="string">
		<cfargument name="stCurrentView" required="true" type="struct">
		
		<cfset var stCacheWebskin = structNew() />
		<cfset var webskinTypename = arguments.typename /><!--- Default to the typename passed in --->
		<cfset var stCoapi = structNew() />
		
		<cfif arguments.typename EQ "farCoapi">
			<!--- This means its a type webskin and we need to look for the timeout value on the related type. --->		
			<cfset stCoapi = application.fc.factory['farCoapi'].getData(objectid="#arguments.objectid#") />
			<cfset webskinTypename = stCoapi.name />
		</cfif>
		
		<cfif isCacheable(typename=webskinTypename,template=arguments.template)>
			
			<!--- Add the current State of the request.inHead scope into the broker --->
			<cfparam name="request.inHead" default="#structNew()#">
			
			<cfset stCacheWebskin.datetimecreated = now() />
			<cfset stCacheWebskin.webskinHTML = trim(arguments.HTML) />	
			<cfset stCacheWebskin.inHead = duplicate(arguments.stCurrentView.inHead) />
			<cfset stCacheWebskin.cacheStatus = arguments.stCurrentView.cacheStatus />
			<cfset stCacheWebskin.cacheTimeout = arguments.stCurrentView.cacheTimeout />
			<cfif structkeyexists(arguments.stCurrentView,"browserCacheTimeout")>
				<cfset stCacheWebskin.browserCacheTimeout = arguments.stCurrentView.browserCacheTimeout />
			</cfif>
			<cfif structkeyexists(arguments.stCurrentView,"proxyCacheTimeout")>
				<cfset stCacheWebskin.proxyCacheTimeout = arguments.stCurrentView.proxyCacheTimeout />
			</cfif>

			<cfset stCacheWebskin.webskinCacheID = generateWebskinCacheID(
													typename="#webskinTypename#", 
													template="#arguments.template#",
													hashKey="#arguments.stCurrentView.hashKey#"
										) />
			<cfset cacheAdd("#rereplace(application.applicationname,'[^\w\d]','','ALL')#_#webskinTypename#_#arguments.objectid#_#arguments.template#_#hash(stCacheWebskin.webskinCacheID)#",stCacheWebskin,stCacheWebskin.cacheTimeout*60) />
			
			<cfreturn true />
				
		</cfif>
		
		<cfreturn false />
	</cffunction>
	
	<cffunction name="removeWebskin" access="public" output="false" returntype="boolean" hint="Searches the object broker in an attempt to locate the requested webskin template">
		<cfargument name="ObjectID" required="false" type="UUID">
		<cfargument name="typename" required="true" type="string">
		<cfargument name="template" required="true" type="string">
		
		<cfif application.bObjectBroker>
			<cfset cacheFlush(regex="#rereplace(application.applicationname,'[^\w\d]','','ALL')#_#arguments.typename#_#arguments.objectid#_#arguments.template#_.*") />
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="AddToObjectBroker" access="public" output="true" returntype="boolean">
		<cfargument name="stObj" required="yes" type="struct">
		<cfargument name="typename" required="true" type="string">
		
		<cfif isCacheable(arguments.typename) and structkeyexists(arguments.stObj, "objectid")>
			<cfset cacheAdd("#rereplace(application.applicationname,'[^\w\d]','','ALL')#_#arguments.typename#_#arguments.stObj.objectid#",arguments.stObj) />
			<cfreturn true />
		</cfif>
		
		<cfreturn false />
	</cffunction>
	
	<cffunction name="RemoveFromObjectBroker" access="public" output="true" returntype="void">
		<cfargument name="lObjectIDs" required="true" type="string">
		<cfargument name="typename" required="true" type="string">
		<cfargument name="eventName" required="false" type="string" default="flush" hint="Name of event that triggered the removal {flush,reap,evict}">
		
		<cfset var oWebskinAncestor = application.fapi.getContentType("dmWebskinAncestor") />						
		<cfset var qWebskinAncestors = queryNew("blah") />
		<cfset var i = "" />
		<cfset var regexString = "" />

		<cfif application.bObjectBroker and len(arguments.typename) and application.stcoapi[arguments.typename].bObjectBroker>
			
			<cfset regexString = listchangedelims(arguments.lObjectIDs,'|') />
			
			<!--- Remove any ancestor webskins that include a fragment of this object --->
			<cfloop list="#arguments.lObjectIDs#" index="i">
				<cfset qWebskinAncestors = oWebskinAncestor.getAncestorWebskins(webskinObjectID=i, webskinTypename=arguments.typename) />
						
				<cfif qWebskinAncestors.recordCount>
					<cfloop query="qWebskinAncestors">
						<cfset regexString = listappend(regexString,"#qWebskinAncestors.ancestorRefTypename#_#qWebskinAncestors.ancestorID#_#qWebskinAncestors.ancestorTemplate#","|") />
					</cfloop>
				</cfif>
			</cfloop>
			
			<cfset cacheFlush(regex="(#regexString#)") />
			
		</cfif>
	</cffunction>
	
	<cffunction name="flushTypeWatchWebskins" access="public" output="false" returntype="boolean" hint="Finds all webskins watching this type for any CRUD functions and flushes them from the cache">
	 	<cfargument name="objectID" required="false" hint="The typename that the CRUD function was performed on." />
	 	<cfargument name="typename" required="false" hint="" />
	 	<cfargument name="stObject" required="false" hint="Alternative to objectID+typename">
		
		<cfset var stTypeWatchWebskins = "" />
		<cfset var iType = "" />
		<cfset var iWebskin = "" />
		<cfset var oCoapi = application.fapi.getContentType("farCoapi") />
		<cfset var coapiObjectID = "" />
		<cfset var qCachedAncestors = "" />
		<cfset var bSuccess = "" />
		<cfset var qWebskinAncestors = "" />
		
		<cfif structkeyexists(arguments,"stObject")>
			<cfset arguments.typename = arguments.stObject.typename />
			<cfset arguments.objectid = arguments.stObject.objectid />
		<cfelse>
			<cfset arguments.stObject = application.fapi.getContentObject(objectid=arguments.objectid,typename=arguments.typename)>
		</cfif>
		
		<cfset stTypeWatchWebskins = application.stCoapi[arguments.typename].stTypeWatchWebskins />
		
		<cfif not structKeyExists(stObject, "status") OR stObject.status EQ "approved" and not structIsEmpty(stTypeWatchWebskins)>
			<cfloop collection="#stTypeWatchWebskins#" item="iType">
				
				<cfset coapiObjectID = oCoapi.getCoapiObjectID(iType) />
				
				<cfif not structKeyExists(application.fc.webskinAncestors, iType)>
					<cfset application.fc.webskinAncestors[iType] = queryNew( 'webskinObjectID,webskinTypename,webskinRefTypename,webskinTemplate,ancestorID,ancestorTypename,ancestorTemplate,ancestorRefTypename', 'VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar' ) />
				</cfif>
				<cfset qWebskinAncestors = application.fc.webskinAncestors[iType] />
				
				<cfloop from="1" to="#arrayLen(stTypeWatchWebskins[iType])#" index="iWebskin">
					
					<cfquery dbtype="query" name="qCachedAncestors">
						SELECT * 
						FROM qWebskinAncestors
						WHERE (
								webskinTypename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#iType#" />
								OR webskinObjectID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#coapiObjectID#" />
						)
						AND webskinTemplate = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stTypeWatchWebskins[iType][iWebskin]#" />
					</cfquery>
					
					<cfloop query="qCachedAncestors">
						<cfset bSuccess = removeWebskin(	objectID=qCachedAncestors.ancestorID,
															typename=qCachedAncestors.ancestorTypename,
															template=qCachedAncestors.ancestorTemplate ) />
						
						<cfset bSuccess = removeWebskin(	objectID=qCachedAncestors.webskinObjectID,
															typename=qCachedAncestors.webskinRefTypename,
															template=qCachedAncestors.webskinTemplate ) />
						
					</cfloop>
					
				</cfloop>
				
			</cfloop>
		</cfif>
		
		<cfreturn true />
	 </cffunction>
	
	<!--- Memory information functions --->
	<cffunction name="getMemoryUsage2" access="public" output="false" returntype="struct" hint="Returns memory information for the specified pool">
		<cfargument name="pool" type="string" required="true" />
		<cfargument name="bHeap" type="boolean" required="true" />
		
		<cfset var i = 0 />
		<cfset var oUsage = "" />
		<cfset var stUsage = structnew() />
		<cfset var heap = "Heap memory" />
		<cfset var poolhash = "#arguments.pool# #heap#">
		
		<cfif not structkeyexists(request,"aMemPools")>
			<cfset request.aMemPools = this.managementFactory.getMemoryPoolMXBeans() />
		</cfif>
		
		<cfif not arguments.bHeap>
			<cfset heap = "Non-heap memory" />
			<cfset poolhash = "#arguments.pool# #heap#">
		</cfif>
		
		<cfparam name="request.stMemPools" default="#structnew()#" />
		<cfif not structkeyexists(request.stMemPools,poolhash)>
			<cfloop from="1" to="#arraylen(request.aMemPools)#" index="i">
				<cfif findnocase(arguments.pool,request.aMemPools[i].getName()) and request.aMemPools[i].getType().toString() eq heap>
					<cfset stUsage.name = request.aMemPools[i].getName() />
					
					<cfset oUsage = request.aMemPools[i].getUsage() />
					<cfset stUsage.initial = oUsage.getInit() />
					<cfset stUsage.used = oUsage.getUsed() />
					<cfset stUsage.committed = oUsage.getCommitted() />
					<cfset stUsage.maximum = oUsage.getMax() />
					<cfset stUsage.usedPercentage = stUsage.used / stUsage.maximum />
					
					<cfset oUsage = request.aMemPools[i].getPeakUsage() />
					<cfset stUsage.peakinitial = oUsage.getInit() />
					<cfset stUsage.peakused = oUsage.getUsed() />
					<cfset stUsage.peakcommitted = oUsage.getCommitted() />
					<cfset stUsage.peakmaximum = oUsage.getMax() />
					<cfset stUsage.peakusedPercentage = stUsage.peakused / stUsage.peakmaximum />
					
					<cfbreak />
				</cfif>
			</cfloop>
			
			<cfset request.stMemPools[poolhash] = stUsage />
		</cfif>
		
		<cfreturn request.stMemPools[poolhash] />
	</cffunction>
	
	<!--- Cache replacement functions --->
	<cffunction name="cacheInitialise" access="public" output="false" returntype="void">
		<cfargument name="min" type="numeric" required="false" default="5000" />
		<cfargument name="max" type="numeric" required="false" default="5000" />
		
		<cfset var stCacheProperties = structnew() />
		
		<cftry>
			<cfset stCacheProperties.overflowToDisk = false />
			<cfset stCacheProperties.memoryEvictionPolicy = "LFU" />
			<cfset stCacheProperties.objectType = "object" />
			<cfset stCacheProperties.maxElementsInMemory = arguments.min />
			<cfset cacheSetProperties(stCacheProperties) />
		
			<cfcatch>
				<!--- Railo doesn't let you do this :(, but set up a default "object" cache in the railo admin --->
			</cfcatch>
		</cftry>
		
		<cfif arraylen(cacheGetAllIds())>
			<cfset cacheRemove(arraytolist(cacheGetAllIds())) />
		</cfif>
		
		<cfset this.min = arguments.min />
		<cfset this.max = arguments.max />
	</cffunction>
	
	<cffunction name="cachePull" access="public" output="false" returntype="struct" hint="Returns an object from cache if it is there, an empty struct if not. Note that garbage collected data counts as a miss.">
		<cfargument name="key" type="string" required="true" />
		
		<cfset var stCacheEntry = "" />
		
		<cftry>
			<cfset stCacheEntry = cacheGet(arguments.key) />
			<cfcatch>
				<cfset stCacheEntry = structnew() />
			</cfcatch>
		</cftry>
		
		<cfif not isdefined("stCacheEntry")>
			<cfset stCacheEntry = structnew() />
		</cfif>
		
		<cfreturn duplicate(stCacheEntry) />
	</cffunction>
	
	<cffunction name="cacheAdd" access="public" output="false" returntype="void" hint="Puts the specified key in the cache. Note that if the key IS in cache or the data is deliberately empty, the cache is updated but cache queuing is not effected.">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="data" type="struct" required="true" />
		<cfargument name="timeout" type="numeric" required="false" hint="Number of seconds until this item should timeout" />
		
		<cfif structkeyexists(arguments,"timeout")>
			<cfset cachePut(arguments.key,duplicate(arguments.data),createtimespan(0,0,0,arguments.timeout)) />
		<cfelse>
			<cfset cachePut(arguments.key,duplicate(arguments.data)) />
		</cfif>	
	</cffunction>
	
	<cffunction name="cacheFlush" access="public" output="false" returntype="void" hint="Removes items from the cache that match the specified regex. Does NOT change the cache management stats.">
		<cfargument name="regex" type="string" required="false" default="" />
		<cfargument name="key" type="string" required="false" default="" />
		
		<cfset var i = 0 />
		<cfset var allkeys = arraynew(1) />
		<cfset var flushkeys = "" />
		
		<cfif len(arguments.key)>
			<cfset cacheRemove(arguments.key) />
		<cfelseif len(arguments.regex)>
			<cfset allkeys = cacheGetAllIds() />
			<cfloop from="1" to="#arraylen(allkeys)#" index="i">
				<cfif refindnocase(arguments.regex,allkeys[i])>
					<cfset flushkeys = listappend(flushkeys,allkeys[i]) />
				</cfif>
			</cfloop>
			<cfif len(flushkeys)>
				<cfset cacheRemove(flushkeys) />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="configureType">
	
	</cffunction>
	
</cfcomponent>