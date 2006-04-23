<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_locking/lock.cfm,v 1.14 2004/03/24 22:37:27 brendan Exp $
$Author: brendan $
$Date: 2004/03/24 22:37:27 $
$Name: milestone_2-2-1 $
$Revision: 1.14 $

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