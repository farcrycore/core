<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEmail/display.cfm,v 1.2 2004/07/16 01:42:49 brendan Exp $
$Author: brendan $
$Date: 2004/07/16 01:42:49 $
$Name: milestone_2-3-2 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Email preview $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
--->
<cfsetting enablecfoutputonly="yes">

<cfoutput>
<strong>#application.adminBundle[session.dmProfile.locale].toLabel#</strong><p></p>
<strong>#application.adminBundle[session.dmProfile.locale].fromLabel#</strong> #stObj.fromEmail#<p></p>
<strong>#application.adminBundle[session.dmProfile.locale].subjLabel#</strong> #stObj.title#<p></p>

#stObj.body#
</cfoutput>

<cfsetting enablecfoutputonly="no">
