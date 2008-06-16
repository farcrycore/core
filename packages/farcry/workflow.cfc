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
$Header: /cvs/farcry/core/packages/farcry/workflow.cfc,v 1.8 2005/10/24 06:10:13 guy Exp $
$Author: guy $
$Date: 2005/10/24 06:10:13 $
$Name: milestone_3-0-1 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: workflow cfc $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayName="Workflow" hint="Workflow methods">
	<cffunction name="getObjectsPendingApproval" access="public" returntype="struct" hint="Returns all objects pending approval by user">
		<cfargument name="stForm" type="Struct" required="yes">
		<cfset var stReturn = StructNew()>
		<cfset var stLocal = StructNew()>
		<cfset stReturn.bSuccess = 1>
		<cfset stReturn.message = "">

		<cfinclude template="_workflow/getObjectsPendingApproval.cfm">
		
		<cfreturn stReturn>
	</cffunction>
	
	<cffunction name="getNewsPendingApproval" access="public" returntype="struct" hint="Returns all news pending approval by user">
				
		<cfinclude template="_workflow/getNewsPendingApproval.cfm">
		
		<cfreturn stPendingNews>
	</cffunction>
	
	<cffunction name="getObjectApprovers" access="public" returntype="struct" hint="Returns all users that can approve pending objects">
		<cfargument name="objectID" type="UUID" required="yes">
		
		<cfinclude template="_workflow/getObjectApprovers.cfm">
		
		<cfreturn stApprovers>
	</cffunction>
	
	<cffunction name="getNewsApprovers" access="public" returntype="struct" hint="Returns all users that can approve pending news objects">
		<cfargument name="objectID" type="UUID" required="yes">
		
		<cfinclude template="_workflow/getNewsApprovers.cfm">
		
		<cfreturn stApprovers>
	</cffunction>
	
	<cffunction name="getUserDraftObjects" access="public" returntype="query" hint="Returns all draft objects for logged in user">
		<cfargument name="userLogin" type="string" required="true">
		<cfargument name="objectTypes" type="string" required="false" default="dmHTML,dmNews">
		
		<cfinclude template="_workflow/getUserDraftObjects.cfm">
		
		<cfreturn qDraftObjects2>
	</cffunction>
	
	<cffunction name="getStatusBreakdown" access="public" returntype="struct" hint="Returns a breakdown of objects by status">
				
		<cfinclude template="_workflow/getStatusBreakdown.cfm">
		
		<cfreturn stStatus>
	</cffunction>

	<cffunction name="getLockedObjects" access="public" returntype="struct" hint="Returns a breakdown of objects by status">
		<cfargument name="lockedby" type="string" required="yes">
		<cfset var stReturn = StructNew()>
		<cfset var stLocal = StructNew()>
		<cfset stReturn.bSuccess = 1>
		<cfset stReturn.message = "">
		
		<cfinclude template="_workflow/getLockedObjects.cfm">
		
		<cfreturn stReturn>
	</cffunction>
</cfcomponent>