<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/edittabAudit.cfm,v 1.10 2005/09/23 04:23:25 guy Exp $
$Author: guy $
$Date: 2005/09/23 04:23:25 $
$Name: milestone_3-0-0 $
$Revision: 1.10 $

|| DESCRIPTION || 
$DESCRIPTION: Displays an audit log for object$
$TODO:  $ 

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in:$ 
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfset iAuditTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectAuditTab")>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iAuditTab eq 1>
	<cfset oAudit = createObject("component", "#application.packagepath#.farcry.audit")>
	<cfset qLog = oAudit.getAuditLog(objectid=url.objectid)>
	
	<div class="FormTitle"><cfoutput>#application.adminBundle[session.dmProfile.locale].auditTrace#</cfoutput></div>	
	
	<cfif qLog.recordcount gt 0>
		<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
		<cfoutput>
		<tr class="dataheader">
			<td align="center"><strong>#application.adminBundle[session.dmProfile.locale].date#</strong></td>
			<td align="center"><strong>#application.adminBundle[session.dmProfile.locale].changeType#</strong></td>
			<td align="center"><strong>#application.adminBundle[session.dmProfile.locale].location#</strong></td>
			<td align="center"><strong>#application.adminBundle[session.dmProfile.locale].notes#</strong></td>
			<td align="center"><strong>#application.adminBundle[session.dmProfile.locale].user#</strong></td>
		</tr>
		</cfoutput>
		<cfoutput query="qLog">
			<cfif isdefined("url.user")>
				<cfif url.user eq username>
					<tr class="#IIF(qLog.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
						<td>
						#application.thisCalendar.i18nDateFormat(datetimestamp,session.dmProfile.locale,application.longF)# 
						#application.thisCalendar.i18nTimeFormat(datetimestamp,session.dmProfile.locale,application.shortF)#
						</td>
						<td>#audittype#</td>
						<td>#location#</td>
						<td <cfif note eq "">align="center"</cfif>><cfif note neq "">#note#<cfelse><em>n/a</em></cfif></td>
						<td><a href="edittabAudit.cfm?objectid=#objectid#&user=#username#">#username#</a></td>
					</tr>
				</cfif>	
			<cfelse>
				<tr class="#IIF(qLog.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
					<td>
					#application.thisCalendar.i18nDateFormat(datetimestamp,session.dmProfile.locale,application.longF)# 
					#application.thisCalendar.i18nTimeFormat(datetimestamp,session.dmProfile.locale,application.shortF)#
					</td>
					<td>#audittype#</td>
					<td>#location#</td>
					<td <cfif note eq "">align="center"</cfif>>
						<cfif note neq "">
							#note#
						<cfelse>
							<em>#application.adminBundle[session.dmProfile.locale].notAvailable#</em>
						</cfif>
					</td>
					<td><a href="edittabAudit.cfm?objectid=#objectid#&user=#username#">#username#</a></td>
				</tr>
			</cfif>
		</cfoutput>
		<cfif isdefined("url.user")>
			<tr>
				<cfoutput>
				<td colspan="5" align="right"><span class="frameMenuBullet">&raquo;</span> <a href="edittabAudit.cfm?objectid=#url.objectid#">#application.adminBundle[session.dmProfile.locale].showAllUsers#</a></td>
				</cfoutput>
			</tr>
		</cfif>
		</table>
	<cfelse>
		<table cellpadding="5" cellspacing="0" border="0" style="margin-left:30px;">
		<tr>
			<td colspan="5"><cfoutput>#application.adminBundle[session.dmProfile.locale].noTraceRecorded#</cfoutput></td>
		</tr>
		</table>
	</cfif>
	<a href="<cfoutput>#application.url.farcry#/edittaboverview.cfm?objectid=#url.objectId#</cfoutput>">[BACK]</a>
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>