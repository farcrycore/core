<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/auditUser.cfm,v 1.3 2003/09/03 01:50:31 brendan Exp $
$Author: brendan $
$Date: 2003/09/03 01:50:31 $
$Name: b201 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: Audit for user activity $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<!--- check permissions --->
<cfscript>
	iAuditTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingAuditTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iAuditTab eq 1>
	<span class="formtitle"><cfif isdefined("url.view")>All<cfelse>Recent</cfif> User Activity</span><p></p>
	
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
	
	<table cellpadding="5" cellspacing="0" border="0" style="margin-left:30px;">
	<tr>
		<td colspan="6">
			<form action="#application.url.farcry#/admin/reporting/auditUser.cfm" method="post">
				User:
				<select name="userName">
					<option value="all">All users
					<cfloop query="qUsers">
						<cfoutput><option value="#username#" <cfif form.username eq username>selected</cfif>>#username#</cfoutput>
					</cfloop>
				</select>
				
				Activity:
				<select name="auditType">
					<option value="all">All types
					<cfloop query="qActivitites">
						<cfoutput><option value="#auditType#" <cfif form.auditType eq auditType>selected</cfif>>#auditType#</cfoutput>
					</cfloop>
				</select>
				
				Rows Returned
				<select name="maxRows">
					<option value="all" <cfif form.maxRows eq "all">selected</cfif>>All Rows
					<cfloop from="10" to="200" step=10 index="rows">
						<cfoutput><option value="#rows#" <cfif rows eq form.maxRows>selected</cfif>>#rows#</cfoutput>
					</cfloop>				
				</select>
				
				<input type="submit" value="Submit">
			</form>
		</td>
	</tr>
	</table>
	
	<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
	<tr class="dataheader">
		<td>Date</td>	
		<td>Activity</td>
		<td>Object</td>
		<td>Note</td>
		<td>User</td>
		<td>Location</td>
	</tr>
	<cfoutput query="qActivity">
		<tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
			<td>#dateformat(Datetimestamp,"dd-mmm-yy")# #timeformat(Datetimestamp)#</td>
			<td>#auditType#</td>
			<td><cfif len(trim(objectid))><a href="#application.url.conjurer#?objectid=#objectid#" target="_blank">#objectid#</a><cfelse>n/a</cfif></td>
			<td>#Note#</td>
			<td><cfif username neq "">#Username#<cfelse><i>unknown</i></cfif></td>		
			<td>#Location#</td>
		</tr>	
	</cfoutput>
	</table>
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>