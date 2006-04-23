<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/rules/_ruleHandpicked/complete.cfm,v 1.2 2003/05/03 04:00:57 geoff Exp $
$Author: geoff $
$Date: 2003/05/03 04:00:57 $
$Name: b131 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: ruleHandpicked PLP - complete step (complete.cfm) $
$TODO: Might be worth working out if this step is needed at all here ;) Clean up whitespace issues, revise formatting 20030503 GB$

|| DEVELOPER ||
$Developer: Paul Harrison (paul@daemon.com.au) $
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<!--- 
ok this is the PLP complete step.  This is here to do any last minute 
cleanup of the output scope before setting the PLP as completed. 
--->
<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>

<cfset bComplete = true>


