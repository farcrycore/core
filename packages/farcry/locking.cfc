<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/locking.cfc,v 1.6 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: locking cfc $


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
		<cfargument name="locked" type="boolean" default="1" />
		
		<cfset var stLock = structNew() />
		
		<cfset createobject("component", application.stCoapi[arguments.typename].typePath).setLock(argumentCollection="#arguments#") />
		
		<cfset stLock.bSuccess=true />
		
		<cfreturn stLock />
		
	</cffunction>
	
	<cffunction name="unlock" access="public" returntype="struct" hint="Unlocks specified object">
		<cfargument name="objectId" type="uuid" required="false">
		<cfargument name="typeName" type="string" required="true">
		<cfargument name="locked" type="boolean" default="0" />
		
		<cfset var stLock = structNew() />
		
		<cfset createobject("component", application.stCoapi[arguments.typename].typePath).setLock(argumentCollection="#arguments#") />
		
		<cfset stLock.bSuccess=true />
		
		<cfreturn stLock />
				
	</cffunction>
	
	<cffunction name="checkForLock" access="public" returntype="struct" hint="Checks if specified object is locked by another user on the system">
		<cfargument name="objectId" type="uuid" required="true">
		
		<cfset var stLock = structNew()>
		<cfset var stObj = "">
		
		<cfinclude template="_locking/checkForLock.cfm">
		
		<cfreturn stLock>
	</cffunction>
	
	<cffunction name="getLockedObjects" access="public" returntype="query" hint="Returns a query of all object currenty locked by user">
		<cfargument name="userLogin" type="string" required="true">
		<cfargument name="types" type="string" required="false" default="#structKeyList(application.types)#">
		
		<cfset var qLockedObjects = queryNew("objectId,objectTitle,createdBy,objectLastUpdated,objectType,objectParent")>
		<cfset var i = "">
		<cfset var qLockedObjects2 = "">
		<cfset var qGetObjects = "">
		<cfset var qGetParent = "">		
		
		<cfinclude template="_locking/getLockedObjects.cfm">
		
		<cfreturn qLockedObjects2>
	</cffunction>
	
	<cffunction name="scheduledUnlock" access="public" returntype="query" hint="Unlocks objects that have been locked for a specified period">
		<cfargument name="days" type="numeric" required="true" default="5" hint="allowable number of days since locked object last updated">
		<cfargument name="types" type="string" required="false" default="dmHTML,dmNews,dmCSS,dmImage,dmFile,dmNavigation,dmInclude">
		
		<cfset var qLockedObjects = queryNew("objectId,objectTitle,lastupdatedby,objectLastUpdated,objectType,objectParent")>
		<cfset var qLockedObjects1 = "">
		<cfset var i = "">
		<cfset var unlockRet = "">		
		
		<cfinclude template="_locking/scheduledUnlock.cfm">
		
		<cfreturn qLockedObjects>
	</cffunction>
	
</cfcomponent>