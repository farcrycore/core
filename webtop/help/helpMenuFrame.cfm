<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/help/helpMenuFrame.cfm,v 1.4 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Displays menu items for help section in Farcry. $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/misc/" prefix="misc">

<!--- check permissions --->
<cfscript>
	iHelpTab = application.security.checkPermission(permission="MainNavHelpTab");
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
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="documentation.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("documentation")#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="mailingLists.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("mailingLists")#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="support.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("commercialSupport")#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="reportBug.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("reportBug")#</a></div>
			</cfif>
		</cfcase>
	</cfswitch>
</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">
