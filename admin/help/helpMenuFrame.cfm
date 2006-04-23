<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/help/helpMenuFrame.cfm,v 1.2 2003/10/28 00:59:07 brendan Exp $
$Author: brendan $
$Date: 2003/10/28 00:59:07 $
$Name: b201 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Displays menu items for help section in Farcry. $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfimport taglib="/farcry/farcry_core/tags/misc/" prefix="misc">

<!--- check permissions --->
<cfscript>
	iHelpTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="MainNavHelpTab");
</cfscript>

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>helpMenuFrame</title>
	<misc:cacheControl>
	<LINK href="../css/overviewFrame.css" rel="stylesheet" type="text/css">
</head>

<body>

<cfparam name="url.type" default="general">

<!--- display menu --->
<div id="frameMenu">
	<cfswitch expression="#url.type#">
		<cfcase value="general">	
			<!--- permission check --->
			<cfif iHelpTab eq 1>
				<div class="frameMenuTitle">General</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="documentation.cfm" class="frameMenuItem" target="editFrame">Documentation</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="mailingLists.cfm" class="frameMenuItem" target="editFrame">Mailing Lists</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="support.cfm" class="frameMenuItem" target="editFrame">Commercial Support</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="reportBug.cfm" class="frameMenuItem" target="editFrame">Report A Bug</a></div>
			</cfif>
		</cfcase>
	</cfswitch>
</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">
