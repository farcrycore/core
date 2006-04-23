<cfcomponent>
	<cffunction name="getObjectsPendingApproval" access="public" returntype="struct" hint="Returns all objects pending approval by user">
		<cfargument name="userLogin" type="string" required="yes">
		
		<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
		<cfinclude template="_workflow/getObjectsPendingApproval.cfm">
		
		<cfreturn stPendingObjects>
	</cffunction>
	
	<cffunction name="getNewsPendingApproval" access="public" returntype="struct" hint="Returns all news pending approval by user">
				
		<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
		<cfinclude template="_workflow/getNewsPendingApproval.cfm">
		
		<cfreturn stPendingNews>
	</cffunction>
	
	<cffunction name="getObjectApprovers" access="public" returntype="struct" hint="Returns all users that can approve pending objects">
		<cfargument name="objectID" type="UUID" required="yes">
		
		<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
		<cfinclude template="_workflow/getObjectApprovers.cfm">
		
		<cfreturn stApprovers>
	</cffunction>
	
	<cffunction name="getNewsApprovers" access="public" returntype="struct" hint="Returns all users that can approve pending news objects">
		<cfargument name="objectID" type="UUID" required="yes">
		
		<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
		<cfinclude template="_workflow/getNewsApprovers.cfm">
		
		<cfreturn stApprovers>
	</cffunction>
	
	<cffunction name="getUserDraftObjects" access="public" returntype="query" hint="Returns all draft objects for logged in user">
		<cfargument name="userLogin" type="string" required="true">
		<cfargument name="objectTypes" type="string" required="false" default="dmHTML,dmNews">
		
		<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
		<cfinclude template="_workflow/getUserDraftObjects.cfm">
		
		<cfreturn qDraftObjects2>
	</cffunction>
	
	<cffunction name="getStatusBreakdown" access="public" returntype="struct" hint="Returns a breakdown of objects by status">
				
		<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
		<cfinclude template="_workflow/getStatusBreakdown.cfm">
		
		<cfreturn stStatus>
	</cffunction>
</cfcomponent>