<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/auditLogins.cfm,v 1.7 2005/08/16 02:41:08 pottery Exp $
$Author: pottery $
$Date: 2005/08/16 02:41:08 $
$Name: milestone_3-0-0 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: Audit for logins $


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

	<h3>
	<cfif isdefined("url.view")>
		<cfoutput>#application.adminBundle[session.dmProfile.locale].allLogins#</cfoutput>
	<cfelse>
		<cfoutput>#application.adminBundle[session.dmProfile.locale].recentLogins#</cfoutput>
	</cfif>
	</h3>
	
	<cfscript>
		if (not isdefined("url.view")) {
			maxrows=10;
		} else {
			maxrows=100;
		}
		qLogins = application.factory.oAudit.getAuditLog(maxrows=maxrows, audittype="dmSec.login");
	</cfscript>	
	
	<table class="table-3" cellspacing="0">
	<cfoutput>
	<tr>
		<th>#application.adminBundle[session.dmProfile.locale].date#</th>
		<th>#application.adminBundle[session.dmProfile.locale].location#</th>
		<th>#application.adminBundle[session.dmProfile.locale].note#</th>
		<th>#application.adminBundle[session.dmProfile.locale].user#</th>
	</tr>
	</cfoutput>
	<cfoutput query="qLogins">
		<tr class="#IIF(currentrow MOD 2, de(""), de("alt"))#">
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

	<hr />
	
	<ul>
	<li>

	<cfif not isdefined("url.view")>
		<a href="auditLogins.cfm?view=all"><cfoutput>#application.adminBundle[session.dmProfile.locale].viewAllLogins#</cfoutput></a>
	<cfelse>
		<a href="auditLogins.cfm"><cfoutput>#application.adminBundle[session.dmProfile.locale].viewRecentLogins#</cfoutput></a>
	</cfif>
	
	</li>
	</ul>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>