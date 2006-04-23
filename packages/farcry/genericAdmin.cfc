<cfcomponent displayname="Generic Admin" hint="Functions used to display the Generic Admin section of Farcry">

<cffunction name="deleteObjects" access="remote" returntype="string" hint="Deletes object(s) from type table">
    <cfargument name="typename" type="string" required="true" hint="Object type of objects being displayed">
	<cfargument name="lObjectIDs" type="string" required="true" hint="Objects to be deleted">
    
	<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">	
	<nj:deleteObjects lObjectIDs="#arguments.lObjectIDs#" typename="#arguments.typename#" rMsg="msg">
	
	<cfreturn msg>
</cffunction>

<cffunction name="permissionCheck" access="remote" returntype="string" hint="Checks if user has a permission to perform select action">
    <cfargument name="permission" type="string" required="true" hint="name of permission">
	    
		<cfscript>
			permissionReturn = request.dmSec.oAuthorisation.checkPermission(permissionName="#arguments.permission#",reference="PolicyGroup");
		</cfscript>
	
	<cfreturn permissionReturn>
</cffunction>

<cffunction name="changeStatus" access="remote" returntype="struct" hint="Changes status of selected object(s)">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
    	
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_genericAdmin/changeStatus.cfm">
	
	<cfreturn stStatus>
</cffunction>

<cffunction name="getObjects" access="remote" returntype="query" hint="Returns a query of objects to be displayed">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
	<cfargument name="typename" type="string" required="true" default="dmNews" hint="Object type of objects to be displayed">
	<cfargument name="status" type="string" default="all" required="true" hint="Status of objects to be displayed">
	<cfargument name="order" type="string" default="datetimecreated" required="true" hint="Field to order by">
	<cfargument name="orderDirection" type="string" default="desc" required="true" hint="Order by ascending or descending">
	<cfargument name="lCategories" type="string" required="false" hint="Categories to restrict search by">
    	
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_genericAdmin/getObjects.cfm">
	
	<cfreturn qGetObjects>
</cffunction>

</cfcomponent>
