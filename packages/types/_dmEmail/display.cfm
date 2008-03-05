<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmEmail/display.cfm,v 1.2 2004/07/16 01:42:49 brendan Exp $
$Author: brendan $
$Date: 2004/07/16 01:42:49 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Email preview $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
--->
<cfsetting enablecfoutputonly="yes">

<cfoutput>
<strong>#application.rb.getResource("toLabel")#</strong><p></p>
<strong>#application.rb.getResource("fromLabel")#</strong> #stObj.fromEmail#<p></p>
<strong>#application.rb.getResource("subjLabel")#</strong> #stObj.title#<p></p>

#stObj.body#
</cfoutput>

<cfsetting enablecfoutputonly="no">
