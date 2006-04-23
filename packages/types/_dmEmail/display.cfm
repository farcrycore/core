<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEmail/display.cfm,v 1.1 2003/08/05 05:54:45 brendan Exp $
$Author: brendan $
$Date: 2003/08/05 05:54:45 $
$Name: b201 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: Email preview $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
--->
<cfsetting enablecfoutputonly="yes">

<cfoutput>
<strong>To:</strong><p></p>
<strong>From:</strong> #stObj.fromEmail#<p></p>
<strong>Subject:</strong> #stObj.title#<p></p>

#stObj.body#
</cfoutput>

<cfsetting enablecfoutputonly="no">
