<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_locking/lock.cfm,v 1.11 2003/10/22 07:19:03 paul Exp $
$Author: paul $
$Date: 2003/10/22 07:19:03 $
$Name: b201 $
$Revision: 1.11 $

|| DESCRIPTION || 
$Description: locks an object $
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
<cfset stLock.bSuccess=true>

<!--- get object details --->
<q4:contentobjectget objectID="#arguments.objectid#" r_stobject="stObj">

<!--- update locking fields --->

<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">

<!--- <cftry> --->
	<!--- save object details --->
	<cfscript>
	stProperties = structNew();
	stProperties.objectid = stObj.objectid;
	stProperties.locked = 1;
	stProperties.lockedBy = "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#";

	// update the OBJECT	
	oType = createobject("component","#getPackagePath(arguments.typename)#");
	oType.setData(stProperties=stProperties);	
	</cfscript>	
	
	<!--- <cfcatch>
		<cfset stLock.bSuccess=false>
		<cfset stLock.message=cfcatch>
	</cfcatch>
</cftry> --->

<cfsetting enablecfoutputonly="no">