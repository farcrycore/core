<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEmail/plpEdit/complete.cfm,v 1.1 2003/08/05 05:54:45 brendan Exp $
$Author: brendan $
$Date: 2003/08/05 05:54:45 $
$Name: b201 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: dmCourses -- Complete PLP Step $
$TODO: $

|| DEVELOPER ||
$Developer: Andrew Robertson (andrewr@daemon.com.au) $
--->

<!--- 
ok this is the PLP complete step.  This is here to do any last minute 
cleanup of the output scope before setting the PLP as completed. 
--->

<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>


<cfset bComplete = true>


