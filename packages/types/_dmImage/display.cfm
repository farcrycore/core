<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmImage/display.cfm,v 1.8 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
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
<cfif stObj.thumbnailimage neq "">
	<cfoutput>#application.adminBundle[application.config.general.locale].thumbnailLabel# <br /><div style="margin-left:20px;margin-top:20px;"><img src="#application.url.webroot##stObj.thumbnailimage#" alt="#stObj.alt#" border="0"></div></cfoutput>
</cfif>
<cfif stObj.standardimage neq "">
	<cfoutput>Standard Image <br /><div style="margin-left:20px;margin-top:20px;"><img src="#application.url.webroot##stObj.StandardImage#" alt="#stObj.alt#" border="0"></div></cfoutput>
</cfif>
<cfif stObj.sourceimage neq "">
	<cfoutput>#application.adminBundle[application.config.general.locale].imageLabel# <br /><div style="margin-left:20px;margin-top:20px;"><img src="#application.url.webroot##stObj.sourceimage#" alt="#stObj.alt#" border="0"></div></cfoutput>
</cfif>

<cfif stObj.sourceimage eq "" and stObj.thumbnailimage eq "" and stObj.standardimage eq "">
	<cfoutput><div style="margin-left:20px;margin-top:20px;">File does not exist.</div></cfoutput>
</cfif> 
<cfsetting enablecfoutputonly="No">