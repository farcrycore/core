<cfcomponent>
	<cffunction name="getAgeBreakdown" access="public" returntype="struct" hint="Returns a count of objects broken down into date segments">
		<cfargument name="breakdown" type="string" required="false" default="25,50,75,100">
				
		<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
		<cfinclude template="_reporting/getAgeBreakdown.cfm">
		
		<cfreturn stAge>
	</cffunction>

	<cffunction name="getRecentObjects" access="public" returntype="query" hint="Returns a recent list of Objects added to the system">
		<cfargument name="numberOfObjects" type="string" required="false" default="5">
		<cfargument name="objectType" type="string" required="true">
				
		<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
		<cfinclude template="_reporting/getRecentObjects.cfm">
		
		<cfreturn qGetObjects>
	</cffunction>
</cfcomponent>