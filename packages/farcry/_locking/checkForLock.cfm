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
$Header: /cvs/farcry/core/packages/farcry/_locking/checkForLock.cfm,v 1.8 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: checks if object is locked $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">

<!--- get object details --->
<q4:contentobjectget objectID="#arguments.objectid#" r_stobject="stObj">
<cfif StructIsEmpty(stObj)>
	<!--- object locked --->
	<cfset stLock.bSuccess = false>
	<cfset stLock.lockedBy = "">
	<cfset stLock.message = "Object is not currently in refobjects">
<cfelse>
	<!--- just in case stobj.locked ends up being an empty string --->
	<cfif not len(stObj.locked)>
		<cfset stObj.locked = 0>
	</cfif>
	
	<!--- check for lock --->
	<cfif stObj.locked eq 1>
		<!--- object locked --->
		<cfset stLock.bSuccess = false>
		<cfset stLock.lockedBy = stObj.lockedBy>
		<cfset stLock.message = "Object is currently locked by user: #stObj.lockedBy#">
	<cfelse> 
		<!--- object not locked --->
		<cfset stLock.bSuccess = true>
		<cfset stLock.meesage = "Object is not locked and is available for edit">
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="no">