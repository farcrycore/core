<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEvent/plpEdit/complete.cfm,v 1.1 2003/06/13 01:04:34 brendan Exp $
$Author: brendan $
$Date: 2003/06/13 01:04:34 $
$Name: b131 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: dmEvent PLP -- Complete Step $
$TODO: Is this need at all? 20030503 GB$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out: $
--->
<!--- 
ok this is the PLP complete step.  This is here to do any last minute 
cleanup of the output scope before setting the PLP as completed. 
--->
<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>

<cfset bComplete = true>


