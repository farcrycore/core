<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/dynamic/dynamicMenuFrame.cfm,v 1.17 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.17 $

|| DESCRIPTION || 
$Description: Displays menu for dynamic tab $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@dameon.com.au)$
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/misc/" prefix="misc">
<!--- check permissions --->
<cfscript>
	iContentTab = application.security.checkPermission(permission="MainNavContentTab");
	iExportTab = application.security.checkPermission(permission="ContentExportTab");
	iCategorisationTab = application.security.checkPermission(permission="ContentCategorisationTab");
	
	lDynamicTypes = 'news,event,fact,link';
	aDynamicTypes = listToArray(lDynamicTypes);
	lPermissions = 'Edit,Create,Delete,RequestApproval,Approve';
	aPermissions = listToArray(lPermissions);
	for (x=1;x LTE arrayLen(aDynamicTypes);x=x+1)
	{	
		'i#aDynamicTypes[x]#' = 0;
		for(y=1;y LTE arrayLen(aPermissions);y=y+1)
		{
			'i#aDynamicTypes[x]#' = application.security.checkPermission(permission="#aDynamicTypes[x]##aPermissions[y]#");
			if(evaluate('i'& aDynamicTypes[x]) EQ 1)
				break;
		}
	}
	
</cfscript>

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
	<title>ContentMenuFrame</title>
	<misc:cacheControl>
	<LINK href="../css/overviewFrame.css" rel="stylesheet" type="text/css">
	<meta content="text/html; charset=UTF-8" http-equiv="content-type">
</head>

<body>
<cfparam name="url.type" default="general">
<div id="frameMenu">

	<cfswitch expression="#url.type#">
		<cfcase value="general">
			<!--- permission check --->
			<cfif iContentTab eq 1>
				<div class="frameMenuTitle">#apapplication.rb.getResource("dynamicContent")#</div>
				<cfif iNews eq 1>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/GenericAdmin.cfm?typename=dmNews" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("news")#</a></div>
				</cfif>
				<cfif iFact eq 1>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/GenericAdmin.cfm?typename=dmFacts" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("facts")#</a></div>				
				</cfif>
				<cfif iLink eq 1>					
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/GenericAdmin.cfm?typename=dmLink" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("links")#</a></div>				
				</cfif>
				<cfif iEvent eq 1>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/GenericAdmin.cfm?typename=dmEvent" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("events")#</a></div>				
				</cfif>
			</cfif>
		</cfcase>
		
		<cfcase value="export">
			<!--- permission check --->
			<cfif iExportTab eq 1>		
				<div class="frameMenuTitle">#apapplication.rb.getResource("export")#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="xmlFeedList.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("RSSFeeds")#</a></div>		
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="export.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("export")#</a></div>		
			</cfif>
		</cfcase>
		
		<cfcase value="categorisation">
			<!--- permission check --->
			<cfif iCategorisationTab eq 1>
				<div class="frameMenuTitle">#apapplication.rb.getResource("categorization")#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../navajo/keywords/hierarchyedit.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("manageKeywords")#</a></div>		
			</cfif>
		</cfcase>
	</cfswitch>
</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">