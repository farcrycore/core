<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/reportingMenuFrame.cfm,v 1.14 2005/08/09 03:54:40 geoff Exp $
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

<cfimport taglib="/farcry/farcry_core/tags/misc/" prefix="misc">

<!--- check permissions --->
<cfscript>
	iStatsTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingStatsTab");
	iAuditTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingAuditTab");
	iDeveloper = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="Developer");
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
				<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].general#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsOverview.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].overviewReport#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsMostPopular.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].viewSummary#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsReferer.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].refererSummary#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsLocale.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].localeSummary#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsOS.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].OSsummary#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsBrowsers.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].browserSummary#</a></div>		
				
				<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].sessions#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsVisitors.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].sessionSummary#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsVisitorPaths.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].sessionPath#s</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsWhosOn.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].whoOnNow#</a></div>
				
				<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].keyWordSearch#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsGoogle.cfm" class="frameMenuItem" target="editFrame">Google</a></div>
				
				<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].inSiteSearches#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsSearches.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].recentSearches#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsSearchesNoResults.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].noResultSearches#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsSearchesMostPopular.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].mostPopularSearches#</a></div>
				
				<cfif iDeveloper eq 1>
					<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].maintenance#</div>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsClear.cfm" class="frameMenuItem" target="editFrame" onClick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmDeleteAllRecs#');">#application.adminBundle[session.dmProfile.locale].clearStatsLog#</a></div>
				</cfif>
			</cfif>
		</cfcase>
		
		<cfcase value="audit">
			<!--- permission check --->
			<cfif iAuditTab eq 1>
				<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].loginActivity#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="auditLogins.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].allLogins#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="auditFailedLogins.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].failedLogins#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="auditUserActivity.cfm?graph=day" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].dailyUserLoginActivity#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="auditUserActivity.cfm?graph=week" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].weeklyUserLoginActivity#</a></div>
				
				<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].userActivitiy#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="auditUser.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].userActivitiy#</a></div>
			</cfif>
		</cfcase>
	</cfswitch>
	
</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">
