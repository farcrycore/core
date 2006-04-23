<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/help/helpMenuFrame.cfm,v 1.3 2004/07/15 01:11:37 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:11:37 $
$Name: milestone_2-3-2 $
$Revision: 1.3 $

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

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/farcry_core/tags/misc/" prefix="misc">

<!--- check permissions --->
<cfscript>
	iHelpTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="MainNavHelpTab");
</cfscript>

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
	<title>helpMenuFrame</title>
	<misc:cacheControl>
	<LINK href="../css/overviewFrame.css" rel="stylesheet" type="text/css">
	<meta content="text/html; charset=UTF-8" http-equiv="content-type">
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
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="documentation.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].documentation#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="mailingLists.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].mailingLists#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="support.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].commercialSupport#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="reportBug.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].reportBug#</a></div>
			</cfif>
		</cfcase>
	</cfswitch>
</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">
