<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_locking/checkForLock.cfm,v 1.5 2003/10/22 07:35:24 paul Exp $
$Author: paul $
$Date: 2003/10/22 07:35:24 $
$Name: b201 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: checks if object is locked $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/fourq/tags" prefix="q4">

<cfset stLock = structNew()>

<!--- get object details --->
<q4:contentobjectget objectID="#arguments.objectid#" r_stobject="stObj">

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

<cfsetting enablecfoutputonly="no">