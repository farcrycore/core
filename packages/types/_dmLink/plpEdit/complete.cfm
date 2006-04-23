<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmLink/plpEdit/complete.cfm,v 1.1 2003/05/28 05:18:16 brendan Exp $
$Author: brendan $
$Date: 2003/05/28 05:18:16 $
$Name: b201 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: dmFacts Type PLP for edit handler - Categorisation Step $
$TODO: Is this needed at all?? clean-up whitespace handling, and formatting 20030503 GB$

|| DEVELOPER ||
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


