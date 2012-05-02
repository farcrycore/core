<cfcomponent displayname="Events" hint="Event controller" output="false">
	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfreturn this />
	</cffunction>
	
	
	<!--- EVENT API METHODS --->
		
	<cffunction name="announce" access="public" output="false" returntype="void" hint="Broadcast an event">
		<cfargument name="component" type="string" required="true" hint="Component to announce to" />
		<cfargument name="eventName" type="string" required="true" hint="Event to announce" />
		<cfargument name="stParams" type="struct" default="#structNew()#" hint="Event parameters" />
		
		<cfset var aListeners = getListeners(arguments.component,request.mode.debug) />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#arraylen(aListeners)#" index="i">
			<cfif structkeyexists(aListeners[i],arguments.eventName)>
				<cfinvoke component="#aListeners[i]#" method="#arguments.eventName#" argumentCollection="#arguments.stParams#"></cfinvoke>
			</cfif>
		</cfloop>
	</cffunction>
	
	
	<!--- LISTENER CACHE METHODS --->
	
	<cffunction name="getListenerCache" access="public" output="false" returntype="struct">
		<cfparam name="request.fc.events.listenercache" default="#structNew()#" />
		<cfreturn request.fc.events.listenercache />
	</cffunction>

	<cffunction name="clearListenerCache" access="public" output="false" returntype="void">
		<cfset request.fc.events.listenercache = structNew() />
	</cffunction>
		
	<cffunction name="getListeners" access="public" output="false" returntype="array">
		<cfargument name="component" type="string" required="true" />
		<cfargument name="cache" type="boolean" required="false" default="true" />
		
		<cfset var stCache = getListenerCache() />
		<cfset var componentPath = "" />
		<cfset var aListeners = arrayNew(1) />
		
		<cfif arguments.cache and structkeyexists(stCache,arguments.component)>
			<cfreturn stCache[arguments.component] />
		</cfif>
		
		<cfset lPaths = application.fc.utils.getPath(package="events",component=arguments.component,scope="ALL")>
		<cfloop index="componentPath" list="#lPaths#">
			<cfset arrayappend(aListeners,createobject("component",componentPath)) />
		</cfloop>
		
		<cfif arguments.cache>
			<cfset stCache[arguments.component] = aListeners />
		</cfif>
		
		<cfreturn aListeners />
	</cffunction>

</cfcomponent>