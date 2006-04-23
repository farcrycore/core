<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmImage/display.cfm,v 1.4.2.1 2004/02/27 04:09:24 brendan Exp $
$Author: brendan $
$Date: 2004/02/27 04:09:24 $
$Name: milestone_2-1-2 $
$Revision: 1.4.2.1 $

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
<!--- display all images --->
<cfif stObj.imageFile neq "">
	<cfoutput>Image: <br /><div style="margin-left:20px;margin-top:20px;"><img src="#application.url.webroot#/images/#stObj.imageFile#" alt="#stObj.alt#" border="0"></div></cfoutput>
</cfif>
<cfif stObj.thumbnail neq "">
	<cfoutput>Thumbnail: <br /><div style="margin-left:20px;margin-top:20px;"><img src="#application.url.webroot#/images/#stObj.thumbnail#" alt="#stObj.alt#" border="0"></div></cfoutput>
</cfif>
<cfif stObj.optimisedImage neq "">
	<cfoutput>Highres: <br /><div style="margin-left:20px;margin-top:20px;"><img src="#application.url.webroot#/images/#stObj.optimisedImage#" alt="#stObj.alt#" border="0"></div></cfoutput>
</cfif>
<cfif stObj.imageFile eq "" and stObj.thumbnail eq "" and stObj.optimisedImage eq "">
	<cfoutput><div style="margin-left:20px;margin-top:20px;">File does not exist.</div></cfoutput>
</cfif> 
<cfsetting enablecfoutputonly="No">