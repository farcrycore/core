<cfcomponent>
	<cffunction name="cacheClean" access="public" hint="Removes cache(s) that have timed out in a cache block">
		<cfargument name="cacheBlockName" type="string" required="true">
		<cfargument name="bShowResults" type="boolean" required="false" default="false">
		
		<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
		<cfinclude template="_cache/cacheClean.cfm">
	</cffunction>
	
	<cffunction name="cacheFlush" access="public" hint="Removes cache(s)">
		<cfargument name="cacheBlockName" type="string" required="false">
		<cfargument name="bShowResults" type="boolean" required="false" default="false">
		<cfargument name="lcachenames" type="string" required="false">
						
		<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
		<cfinclude template="_cache/cacheFlush.cfm">
	</cffunction>
	
	<cffunction name="cacheRead" access="public" returntype="string" hint="Reads a cache">
		<cfargument name="cacheBlockName" type="string" required="true">
		<cfargument name="cacheName" type="string" required="true">
		<cfargument name="dtCachetimeout" type="date" required="true">
		
				
		<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
		<cfinclude template="_cache/cacheRead.cfm">
		<cfreturn read>
	</cffunction>
	
	<cffunction name="cacheWrite" access="public" hint="Writes a cache">
		<cfargument name="cacheBlockName" type="string" required="true">
		<cfargument name="cacheName" type="string" required="true">
		<cfargument name="stcacheblock" type="struct" required="true">
				
		<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
		<cfinclude template="_cache/cacheWrite.cfm">
	</cffunction>
</cfcomponent>