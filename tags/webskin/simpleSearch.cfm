<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/webskin/simpleSearch.cfm,v 1.2 2003/09/25 23:28:08 brendan Exp $
$Author: brendan $
$Date: 2003/09/25 23:28:08 $
$Name: b201 $
$Revision: 1.2 $

|| DESCRIPTION || 
$DESCRIPTION: Simple search form$

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
--->

<cfsetting enablecfoutputonly="Yes">
<cfoutput>
<form action="#application.url.conjurer#?objectid=#application.navid.search#" method="post">
<input type="text" name="criteria" value="">
<input type="submit" name="action" value="Search">
</form>
</cfoutput>
<cfsetting enablecfoutputonly="No">
