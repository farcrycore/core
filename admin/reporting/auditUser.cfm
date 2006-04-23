<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/auditUser.cfm,v 1.5 2004/10/21 06:46:50 paul Exp $
$Author: paul $
$Date: 2004/10/21 06:46:50 $
$Name: milestone_2-3-2 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: Audit for user activity $
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
		<cfoutput>#application.adminBundle[session.dmProfile.locale].allUserActivity#</cfoutput>
	<cfelse>
		<cfoutput>#application.adminBundle[session.dmProfile.locale].recentUserActivity#</cfoutput>
	</cfif>
	</span>
	<p></p>
	
	<cfparam name="form.username" default="all">
	<cfparam name="form.auditType" default="all">
	<cfparam name="form.maxRows" default="10">
	
	<cfscript>
		// hack for max rows, unlikely they'll want more than this
		if (form.maxrows eq "all") {
			form.maxrows = 999999;
		}	
		
		qActivity = application.factory.oAudit.getAuditLog(maxrows=form.maxRows,username=form.username,auditType=form.auditType);
		qUsers = application.factory.oAudit.getAuditUsers(maxrows=maxrows);
		qActivitites = application.factory.oAudit.getAuditActivities(maxrows=maxrows);
	</cfscript>	
	<cfoutput>
	<table cellpadding="5" cellspacing="0" border="0" style="margin-left:30px;">
	<tr>
		<td colspan="6">
			<form action="#application.url.farcry#/reporting/auditUser.cfm" method="post">
				#application.adminBundle[session.dmProfile.locale].userLabel#
				<select name="userName">
					<option value="all">#application.adminBundle[session.dmProfile.locale].allUsers#
					<cfloop query="qUsers">
						<option value="#username#" <cfif form.username eq username>selected</cfif>>#username#
					</cfloop>
				</select>
				
				#application.adminBundle[session.dmProfile.locale].activityLabel#
				<select name="auditType">
					<option value="all">#application.adminBundle[session.dmProfile.locale].allTypes#
					<cfloop query="qActivitites">
						<option value="#auditType#" <cfif form.auditType eq auditType>selected</cfif>>#auditType#
					</cfloop>
				</select>
				
				#application.adminBundle[session.dmProfile.locale].rowsReturned#
				<select name="maxRows">
					<option value="all" <cfif form.maxRows eq "all">selected</cfif>>#application.adminBundle[session.dmProfile.locale].allRows#
					<cfloop from="10" to="200" step=10 index="rows">
						<option value="#rows#" <cfif rows eq form.maxRows>selected</cfif>>#rows#
					</cfloop>				
				</select>
				
				<input type="submit" value="#application.adminBundle[session.dmProfile.locale].submit#">
			</form>
		</td>
	</tr>
	</table>
	</cfoutput>
	<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
	<cfoutput>
	<tr class="dataheader">
		<td>#application.adminBundle[session.dmProfile.locale].date#</td>	
		<td>#application.adminBundle[session.dmProfile.locale].activity#</td>
		<td>#application.adminBundle[session.dmProfile.locale].objectLC#</td>
		<td>#application.adminBundle[session.dmProfile.locale].note#</td>
		<td>#application.adminBundle[session.dmProfile.locale].user#</td>
		<td>#application.adminBundle[session.dmProfile.locale].location#</td>
	</tr>
	</cfoutput>
	<cfoutput query="qActivity">
		<tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
			<td>
			#application.thisCalendar.i18nDateFormat(Datetimestamp,session.dmProfile.locale,application.fullF)# 
			#application.thisCalendar.i18nTimeFormat(Datetimestamp,session.dmProfile.locale,application.shortF)#
			</td>
			<td>#auditType#</td>
			<td><cfif len(trim(objectid))><a href="#application.url.conjurer#?objectid=#objectid#" target="_blank">#objectid#</a><cfelse>#application.adminBundle[session.dmProfile.locale].notAvailable#</cfif></td>
			<td>#Note#</td>
			<td><cfif username neq "">#Username#<cfelse><i>#application.adminBundle[session.dmProfile.locale].unknown#</i></cfif></td>		
			<td>#Location#</td>
		</tr>	
	</cfoutput>
	</table>
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>