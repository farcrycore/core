<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_locking/checkForLock.cfm,v 1.8 2005/08/09 03:54:40 geoff Exp $
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

<cfimport taglib="/farcry/fourq/tags" prefix="q4">

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