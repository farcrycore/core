<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/ui/dynamic/Attic/dynamicMenuFrame.cfm,v 1.6 2003/07/24 07:39:02 brendan Exp $
$Author: brendan $
$Date: 2003/07/24 07:39:02 $
$Name: b131 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: Displays menu for dynamic tab $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@dameon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/farcry_core/tags/misc/" prefix="misc">

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>dynamicMenuFrame</title>
	<misc:cachecontrol>
	<LINK href="../css/overviewFrame.css" rel="stylesheet" type="text/css">
</head>

<body>
<cfparam name="url.type" default="general">
<div id="frameMenu">

	<cfswitch expression="#url.type#">
		<cfcase value="general">
			<div class="frameMenuTitle">Dynamic Content</div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/GenericAdmin.cfm?type=News&typename=dmNews" class="frameMenuItem" target="editFrame">News</a></div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/GenericAdmin.cfm?type=News&typename=dmFacts" class="frameMenuItem" target="editFrame">Facts</a></div>				
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/GenericAdmin.cfm?type=News&typename=dmLink" class="frameMenuItem" target="editFrame">Links</a></div>				
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/GenericAdmin.cfm?type=News&typename=dmEvent" class="frameMenuItem" target="editFrame">Events</a></div>				
		</cfcase>
		
		<cfcase value="xml">
			<div class="frameMenuTitle">XML Export</div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="xmlFeedList.cfm" class="frameMenuItem" target="editFrame">Manage Feeds</a></div>		
		</cfcase>
		
		<cfcase value="categorisation">
			<div class="frameMenuTitle">Categorisation</div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../navajo/keywords/hierarchyedit.cfm" class="frameMenuItem" target="editFrame">Manage Keywords</a></div>		
		</cfcase>
	</cfswitch>
</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">