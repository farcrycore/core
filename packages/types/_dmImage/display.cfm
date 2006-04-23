<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmImage/display.cfm,v 1.8 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-0 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: display handler$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">
<!--- display all images --->
<cfif stObj.imageFile neq "">
	<cfoutput>#application.adminBundle[application.config.general.locale].imageLabel# <br /><div style="margin-left:20px;margin-top:20px;"><img src="#application.url.webroot#/images/#stObj.imageFile#" alt="#stObj.alt#" border="0"></div></cfoutput>
</cfif>
<cfif stObj.thumbnail neq "">
	<cfoutput>#application.adminBundle[application.config.general.locale].thumbnailLabel# <br /><div style="margin-left:20px;margin-top:20px;"><img src="#application.url.webroot#/images/#stObj.thumbnail#" alt="#stObj.alt#" border="0"></div></cfoutput>
</cfif>
<cfif stObj.optimisedImage neq "">
	<cfoutput>#application.adminBundle[application.config.general.locale].highResLabel# <br /><div style="margin-left:20px;margin-top:20px;"><img src="#application.url.webroot#/images/#stObj.optimisedImage#" alt="#stObj.alt#" border="0"></div></cfoutput>
</cfif>
<cfif stObj.imageFile eq "" and stObj.thumbnail eq "" and stObj.optimisedImage eq "">
	<cfoutput><div style="margin-left:20px;margin-top:20px;">File does not exist.</div></cfoutput>
</cfif> 
<cfsetting enablecfoutputonly="No">