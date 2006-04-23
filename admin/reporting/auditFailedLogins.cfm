<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/auditFailedLogins.cfm,v 1.4 2004/07/15 01:51:48 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:51:48 $
$Name: milestone_2-3-2 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Audit for failed logins $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iAuditTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingAuditTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iAuditTab eq 1>
	<span class="formtitle">
	<cfif isdefined("url.view")>
		<cfoutput>#application.adminBundle[session.dmProfile.locale].allFailedLogins#</cfoutput>
	<cfelse>
		<cfoutput>#application.adminBundle[session.dmProfile.locale].recentFailedLogins#</cfoutput>
	</cfif> 
	</span>
	<p></p>
	
	<cfscript>
		if (not isdefined("url.view")) {
			maxrows=10;
		} else {
			maxrows=100;
		}
		qFailed = application.factory.oAudit.getAuditLog(maxrows=maxrows, audittype="dmSec.loginfailed");
	</cfscript>	
	
	<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
	<cfoutput>
	<tr class="dataheader">
		<td>#application.adminBundle[session.dmProfile.locale].date#</td>
		<td>#application.adminBundle[session.dmProfile.locale].location#</td>
		<td>#application.adminBundle[session.dmProfile.locale].note#</td>
		<td>#application.adminBundle[session.dmProfile.locale].user#</td>
	</tr>
	</cfoutput>
	<cfoutput query="qFailed">
		<tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
			<td>
			#application.thisCalendar.i18nDateFormat(Datetimestamp,session.dmProfile.locale,application.shortF)# 
			#application.thisCalendar.i18nTimeFormat(Datetimestamp,session.dmProfile.locale,application.shortF)#
			</td>
			<td>#Location#</td>
			<td>#Note#</td>
			<td><cfif username neq "">#Username#<cfelse><i>#application.adminBundle[session.dmProfile.locale].unknown#</i></cfif></td>
		</tr>	
	</cfoutput>
	</table>
	<p></p>
	<span class="frameMenuBullet" style="margin-left:30px;">&raquo;</span> 
	
	<cfif not isdefined("url.view")>
		<a href="auditFailedLogins.cfm?view=all"><cfoutput>#application.adminBundle[session.dmProfile.locale].viewAllFailedLogins#</cfoutput></a>
	<cfelse>
		<a href="auditFailedLogins.cfm"><cfoutput>#application.adminBundle[session.dmProfile.locale].viewRecentFailedLogins#</cfoutput></a>
	</cfif>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>