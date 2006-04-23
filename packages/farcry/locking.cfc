<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/locking.cfc,v 1.4 2004/01/06 01:08:52 brendan Exp $
$Author: brendan $
$Date: 2004/01/06 01:08:52 $
$Name: milestone_2-1-2 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: locking cfc $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayName="Object Locking" hint="Functions for locking and unlocking objects to avoid users editing at same time">
	<cffunction name="lock" access="public" returntype="struct" hint="Locks object to current user">
		<cfargument name="objectId" type="uuid" required="true">
		<cfargument name="typeName" type="string" required="true">
		
		<cfinclude template="_locking/lock.cfm">
		
		<cfreturn stLock>
	</cffunction>
	
	<cffunction name="unlock" access="public" returntype="struct" hint="Unlocks specified object">
		<cfargument name="objectId" type="uuid" required="false">
		<cfargument name="typeName" type="string" required="true">
		<cfargument name="stObj" type="struct" required="false">
		
		<cfinclude template="_locking/unlock.cfm">
		
		<cfreturn stLock>
	</cffunction>
	
	<cffunction name="checkForLock" access="public" returntype="struct" hint="Checks if specified object is locked by another user on the system">
		<cfargument name="objectId" type="uuid" required="true">
		
		<cfinclude template="_locking/checkForLock.cfm">
		
		<cfreturn stLock>
	</cffunction>
	
	<cffunction name="getLockedObjects" access="public" returntype="query" hint="Returns a query of all object currenty locked by user">
		<cfargument name="userLogin" type="string" required="true">
		<cfargument name="types" type="string" required="false" default="#structKeyList(application.types)#">
		
		<cfinclude template="_locking/getLockedObjects.cfm">
		
		<cfreturn qLockedObjects2>
	</cffunction>
	
	<cffunction name="scheduledUnlock" access="public" returntype="query" hint="Unlocks objects that have been locked for a specified period">
		<cfargument name="days" type="numeric" required="true" default="5" hint="allowable number of days since locked object last updated">
		<cfargument name="types" type="string" required="false" default="dmHTML,dmNews,dmCSS,dmImage,dmFile,dmNavigation,dmInclude">
		
		<cfinclude template="_locking/scheduledUnlock.cfm">
		
		<cfreturn qLockedObjects>
	</cffunction>
	
</cfcomponent>