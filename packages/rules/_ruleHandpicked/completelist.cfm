<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/rules/_ruleHandpicked/completelist.cfm,v 1.3 2004/07/30 08:34:40 phastings Exp $
$Author: phastings $
$Date: 2004/07/30 08:34:40 $
$Name: milestone_2-3-2 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: ruleHandpicked PLP - complete step (completelist.cfm) $
$TODO: Might be worth working out if this step is needed at all here ;) Clean up whitespace issues, revise formatting 20030503 GB$

|| DEVELOPER ||
$Developer: Paul Harrison (paul@daemon.com.au) $
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<!--- 
ok this is the PLP complete step.  This is here to do any last minute 
cleanup of the output scope before setting the PLP as completed. 
--->
<cfprocessingDirective pageencoding="utf-8">

<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>

<cfset bListComplete = true>


