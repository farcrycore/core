<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_locking/lock.cfm,v 1.15 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.15 $

|| DESCRIPTION || 
$Description: locks an object $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/fourq/tags" prefix="q4">

<cfset stLock.bSuccess=true>

<!--- get object details --->
<q4:contentobjectget objectID="#arguments.objectid#" r_stobject="stObj">

<cftry>
	<!--- save object details --->
	<cfscript>
	stProperties.objectid = stObj.objectid;
	stProperties.locked = 1;
	stProperties.lockedBy = "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#";

	// update the OBJECT	
	oType.setData(stProperties=stProperties);	
	</cfscript>	
	
	<cfcatch>
		<cfset stLock.bSuccess=false>
		<cfset stLock.message=cfcatch>
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="no">