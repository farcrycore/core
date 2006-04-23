<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/reportingMenuFrame.cfm,v 1.12 2004/01/07 23:30:17 brendan Exp $
$Author: brendan $
$Date: 2004/01/07 23:30:17 $
$Name: milestone_2-2-1 $
$Revision: 1.12 $

|| DESCRIPTION || 
$Description: Displays menu items for reporting section in Farcry. $
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
	iStatsTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingStatsTab");
	iAuditTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingAuditTab");
	iDeveloper = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="Developer");
</cfscript>

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>reportingMenuFrame</title>
	<misc:cacheControl>
	<LINK href="../css/overviewFrame.css" rel="stylesheet" type="text/css">
</head>

<body>

<cfparam name="url.type" default="stats">

<!--- display menu --->
<div id="frameMenu">
	<cfswitch expression="#url.type#">
		<cfcase value="stats">	
			<!--- permission check --->
			<cfif iStatsTab eq 1>
				<div class="frameMenuTitle">General</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsOverview.cfm" class="frameMenuItem" target="editFrame">Overview Report</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsMostPopular.cfm" class="frameMenuItem" target="editFrame">View Summary</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsReferer.cfm" class="frameMenuItem" target="editFrame">Referer Summary</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsLocale.cfm" class="frameMenuItem" target="editFrame">Locale Summary</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsOS.cfm" class="frameMenuItem" target="editFrame">Operating System Summary</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsBrowsers.cfm" class="frameMenuItem" target="editFrame">Browser Summary</a></div>		
				
				<div class="frameMenuTitle">Sessions</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsVisitors.cfm" class="frameMenuItem" target="editFrame">Session Summary</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsVisitorPaths.cfm" class="frameMenuItem" target="editFrame">Session Paths</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsWhosOn.cfm" class="frameMenuItem" target="editFrame">Who's On Now</a></div>
				
				<div class="frameMenuTitle">Search Engine Key Words</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsGoogle.cfm" class="frameMenuItem" target="editFrame">Google</a></div>
				
				<div class="frameMenuTitle">In-Site Searches</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsSearches.cfm" class="frameMenuItem" target="editFrame">Recent Searches</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsSearchesNoResults.cfm" class="frameMenuItem" target="editFrame">Searches Returning No Results</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsSearchesMostPopular.cfm" class="frameMenuItem" target="editFrame">Most Popular Searches</a></div>
				
				<cfif iDeveloper eq 1>
					<div class="frameMenuTitle">Maintenance</div>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsClear.cfm" class="frameMenuItem" target="editFrame" onClick="return confirm('Are you sure you wish to delete all Stats records?');">Clear Stats Log</a></div>
				</cfif>
			</cfif>
		</cfcase>
		
		<cfcase value="audit">
			<!--- permission check --->
			<cfif iAuditTab eq 1>
				<div class="frameMenuTitle">Login Activity</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="auditLogins.cfm" class="frameMenuItem" target="editFrame">All Logins</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="auditFailedLogins.cfm" class="frameMenuItem" target="editFrame">Failed Logins</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="auditUserActivity.cfm?graph=day" class="frameMenuItem" target="editFrame">Daily User Login Activity</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="auditUserActivity.cfm?graph=week" class="frameMenuItem" target="editFrame">Weekly User Login Activity</a></div>
				
				<div class="frameMenuTitle">User Activitiy</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="auditUser.cfm" class="frameMenuItem" target="editFrame">User Activity</a></div>
			</cfif>
		</cfcase>
	</cfswitch>
	

</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">
