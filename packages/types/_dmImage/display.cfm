<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmImage/display.cfm,v 1.5 2004/03/02 01:00:02 brendan Exp $
$Author: brendan $
$Date: 2004/03/02 01:00:02 $
$Name: milestone_2-2-1 $
$Revision: 1.5 $

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