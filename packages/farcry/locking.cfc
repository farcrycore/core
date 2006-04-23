<cfcomponent>
	<cffunction name="lock" access="public" returntype="struct" hint="Locks object to current user">
		<cfargument name="objectId" type="uuid" required="true">
		<cfargument name="typeName" type="string" required="true">
		
		<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
		<cfinclude template="_locking/lock.cfm">
		
		<cfreturn stLock>
	</cffunction>
	
	<cffunction name="unlock" access="public" returntype="struct" hint="Unlocks specified object">
		<cfargument name="objectId" type="uuid" required="false">
		<cfargument name="typeName" type="string" required="true">
		<cfargument name="stObj" type="struct" required="false">
		
		<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
		<cfinclude template="_locking/unlock.cfm">
		
		<cfreturn stLock>
	</cffunction>
	
	<cffunction name="checkForLock" access="public" returntype="struct" hint="Checks if specified object is locked by another user on the system">
		<cfargument name="objectId" type="uuid" required="true">
		
		<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
		<cfinclude template="_locking/checkForLock.cfm">
		
		<cfreturn stLock>
	</cffunction>
	
	<cffunction name="getLockedObjects" access="public" returntype="query" hint="Returns a query of all object currenty locked by user">
		<cfargument name="userLogin" type="string" required="true">
		<cfargument name="types" type="string" required="false" default="dmHTML,dmNews,dmCSS,dmImage,dmFile,dmNavigation,dmInclude">
		
		<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
		<cfinclude template="_locking/getLockedObjects.cfm">
		
		<cfreturn qLockedObjects2>
	</cffunction>
	
	<cffunction name="scheduledUnlock" access="public" returntype="query" hint="Unlocks objects that have been locked for a specified period">
		<cfargument name="days" type="numeric" required="true" default="5" hint="allowable number of days since locked object last updated">
		<cfargument name="types" type="string" required="false" default="dmHTML,dmNews,dmCSS,dmImage,dmFile,dmNavigation,dmInclude">
		
		<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
		<cfinclude template="_locking/scheduledUnlock.cfm">
		
		<cfreturn qLockedObjects>
	</cffunction>
	
</cfcomponent>