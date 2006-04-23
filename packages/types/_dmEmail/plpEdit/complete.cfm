<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEmail/plpEdit/complete.cfm,v 1.2 2004/07/16 01:42:49 brendan Exp $
$Author: brendan $
$Date: 2004/07/16 01:42:49 $
$Name: milestone_2-3-2 $
$Revision: 1.2 $

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
<cfprocessingDirective pageencoding="utf-8">

<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>


<cfset bComplete = true>


