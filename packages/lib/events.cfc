<cfcomponent displayname="Events" hint="Event controller" output="false">
	
	<cffunction name="init" access="public" output="false" returntype="any">
		
		<cfset this.oUtils = createobject("component","farcry.core.packages.farcry.utils") />
		
		<cfset initializeListenerCache() />
		
		<cfreturn this />
	</cffunction>
	
	
	<!--- EVENT API METHODS --->
		
	<cffunction name="announce" access="public" output="false" returntype="void" hint="Broadcast an event">
		<cfargument name="component" type="string" required="true" hint="Component to announce to" />
		<cfargument name="eventName" type="string" required="true" hint="Event to announce" />
		<cfargument name="stParams" type="struct" default="#structNew()#" hint="Event parameters" />
		
		<cfset var aListeners = getListeners(arguments.component) />
		<cfset var i = 0 />
		
		<cfloop collection="#arguments#" item="i">
			<cfif not listfindnocase("component,eventname,stparams",i)>
				<cfset arguments.stParams[i] = arguments[i] />
			</cfif>
		</cfloop>
		
		<cfloop from="1" to="#arraylen(aListeners)#" index="i">
			<cfif structkeyexists(aListeners[i],arguments.eventName)>
				<cfinvoke component="#aListeners[i]#" method="#arguments.eventName#" argumentCollection="#arguments.stParams#"></cfinvoke>
			</cfif>
		</cfloop>
	</cffunction>
	
	
	<!--- LISTENER CACHE METHODS --->
	
	<cffunction name="getListenerCache" access="public" output="false" returntype="struct">
		
		<cfparam name="this.listenercache" default="#structNew()#" />
		<cfreturn this.listenercache />
	</cffunction>

	<cffunction name="clearListenerCache" access="public" output="false" returntype="void">
		
		<cfset this.listenercache = structNew() />
	</cffunction>
	
	<cffunction name="initializeListenerCache" access="public" output="false" returntype="struct">
		
		<cfset var components = this.oUtils.getComponents(package="events") />
		<cfset var lPaths = "" />
		<cfset var thiscomponent = "" />
		<cfset var thispath = "" />
		<cfset var o = "" />
		<cfset var stMeta = structnew() />
		<cfset var componentname = "" />
		<cfset var stCache = getListenerCache() />
		
		<cfloop list="#components#" index="thiscomponent">
			<cfset lPaths = this.oUtils.getPath(package="events",component=thiscomponent,scope="ALL") />
			
			<cfloop list="#lpaths#" index="thispath">
				<cfset o = createobject("component",thispath) />
				<cfset stMeta = getMetadata(o) />
				
				<cfset componentname = thiscomponent />
				<cfif structkeyexists(stMeta,"component")>
					<cfset componentname = stMeta.component />
				</cfif>
				
				<cfparam name="stCache.#componentname#" default="#arraynew(1)#" />
				
				<cfset arrayappend(stCache[componentname],o) />
			</cfloop>
		</cfloop>
		
		<cfreturn stCache />
	</cffunction>
	
	<cffunction name="getListeners" access="public" output="false" returntype="array">
		<cfargument name="component" type="string" required="true" />
		<cfargument name="cache" type="boolean" required="false" default="true" />
		
		<cfset var stCache = getListenerCache() />
		<cfset var componentPath = "" />
		<cfset var aListeners = arrayNew(1) />
		<cfset var components = "" />
		<cfset var thiscomponent = "" />
		<cfset var o = "" />
		<cfset var stMeta = structnew() />
		<cfset var lPaths	= '' />
		
		<cfif arguments.cache and structkeyexists(stCache,arguments.component)>
			<cfreturn stCache[arguments.component] />
		</cfif>
		
		<cfset components = this.oUtils.getComponents(package="events") />
		<cfloop list="#component#" index="thiscomponent">
			<cfset lPaths = application.fc.utils.getPath(package="events",component=thiscomponent,scope="ALL")>
			<cfloop index="componentPath" list="#lPaths#">
				<cfset o = createobject("component",componentPath) />
				<cfset stMeta = getMetadata(o) />
				
				<cfif thiscomponent eq arguments.component or (structkeyexists(stMeta,"component") and stMeta.component eq arguments.component)>
					<cfset arrayappend(aListeners,createobject("component",componentPath)) />
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfif arguments.cache>
			<cfset stCache[arguments.component] = aListeners />
		</cfif>
		
		<cfreturn aListeners />
	</cffunction>

</cfcomponent>