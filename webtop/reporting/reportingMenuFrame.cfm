<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/reporting/reportingMenuFrame.cfm,v 1.14 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.14 $

|| DESCRIPTION || 
$Description: Displays menu items for reporting section in Farcry. $


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
	iStatsTab = application.security.checkPermission(permission="ReportingStatsTab");
	iAuditTab = application.security.checkPermission(permission="ReportingAuditTab");
	iDeveloper = application.security.checkPermission(permission="Developer");
</cfscript>

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
	<title>reportingMenuFrame</title>
	<misc:cacheControl>
	<LINK href="../css/overviewFrame.css" rel="stylesheet" type="text/css">
	<meta content="text/html; charset=UTF-8" http-equiv="content-type">
</head>

<body>

<cfparam name="url.type" default="stats">

<!--- display menu --->
<div id="frameMenu">
	<cfswitch expression="#url.type#">
		<cfcase value="stats">	
			<!--- permission check --->
			<cfif iStatsTab eq 1>
				<div class="frameMenuTitle">#apapplication.rb.getResource("general")#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsOverview.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("overviewReport")#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsMostPopular.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("viewSummary")#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsReferer.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("refererSummary")#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsLocale.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("localeSummary")#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsOS.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("OSsummary")#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsBrowsers.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("browserSummary")#</a></div>		
				
				<div class="frameMenuTitle">#apapplication.rb.getResource("sessions")#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsVisitors.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("sessionSummary")#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsVisitorPaths.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("sessionPath")#s</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsWhosOn.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("whoOnNow")#</a></div>
				
				<div class="frameMenuTitle">#apapplication.rb.getResource("keyWordSearch")#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsGoogle.cfm" class="frameMenuItem" target="editFrame">Google</a></div>
				
				<div class="frameMenuTitle">#apapplication.rb.getResource("inSiteSearches")#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsSearches.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("recentSearches")#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsSearchesNoResults.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("noResultSearches")#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsSearchesMostPopular.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("mostPopularSearches")#</a></div>
				
				<cfif iDeveloper eq 1>
					<div class="frameMenuTitle">#apapplication.rb.getResource("maintenance")#</div>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsClear.cfm" class="frameMenuItem" target="editFrame" onClick="return confirm('#apapplication.rb.getResource("confirmDeleteAllRecs")#');">#apapplication.rb.getResource("clearStatsLog")#</a></div>
				</cfif>
			</cfif>
		</cfcase>
		
		<cfcase value="audit">
			<!--- permission check --->
			<cfif iAuditTab eq 1>
				<div class="frameMenuTitle">#apapplication.rb.getResource("loginActivity")#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="auditLogins.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("allLogins")#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="auditFailedLogins.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("failedLogins")#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="auditUserActivity.cfm?graph=day" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("dailyUserLoginActivity")#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="auditUserActivity.cfm?graph=week" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("weeklyUserLoginActivity")#</a></div>
				
				<div class="frameMenuTitle">#apapplication.rb.getResource("userActivitiy")#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="auditUser.cfm" class="frameMenuItem" target="editFrame">#apapplication.rb.getResource("userActivitiy")#</a></div>
			</cfif>
		</cfcase>
	</cfswitch>
	
</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">
