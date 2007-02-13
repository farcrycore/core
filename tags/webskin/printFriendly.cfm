<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/webskin/printFriendly.cfm,v 1.2 2003/09/25 23:28:09 brendan Exp $
$Author: brendan $
$Date: 2003/09/25 23:28:09 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
$DESCRIPTION: Creates a link to a printfriendly version of the page$

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
--->

<cfsetting enablecfoutputonly="yes">
<cfparam name="attributes.linktext" default="Printer Friendly Version">

<cfoutput><a href="#application.url.webroot#/printFriendly.cfm?objectid=#url.objectid#" target="_blank">#attributes.linkText#</a></cfoutput>

<cfsetting enablecfoutputonly="no">
