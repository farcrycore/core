<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmNews/plpEdit/complete.cfm,v 1.3 2004/07/16 05:39:02 brendan Exp $
$Author: brendan $
$Date: 2004/07/16 05:39:02 $
$Name: milestone_2-3-2 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: dmNews PLP -- Complete Step $
$TODO: Is this need at all? 20030503 GB$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $

|| ATTRIBUTES ||
$in: <separate entry for each variable>$
$out: <separate entry for each variable>$
--->
<!--- 
ok this is the PLP complete step.  This is here to do any last minute 
cleanup of the output scope before setting the PLP as completed. 
--->
<cfprocessingDirective pageencoding="utf-8">

<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>

<cfset bComplete = true>


