<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmImage/display.cfm,v 1.4 2003/09/10 23:46:11 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 23:46:11 $
$Name: b201 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: display handler$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfif stObj.imageFile neq "">
	<cfoutput><div style="margin-left:20px;margin-top:20px;"><img src="#application.url.webroot#/images/#stObj.imageFile#" alt="#stObj.alt#" border="0"></div></cfoutput>
<cfelse>
	<cfoutput><div style="margin-left:20px;margin-top:20px;">File does not exist.</div></cfoutput>
</cfif>
	
<cfsetting enablecfoutputonly="No">