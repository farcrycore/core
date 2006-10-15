<cfsetting enablecfoutputonly="true" />
<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: $
$Author: $
$Date: $
$Name: $
$Revision: $

|| DESCRIPTION || 
$DESCRIPTION: Displays an audit log for object$

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">

<!--- check permissions --->
<cfset iAuditTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectAuditTab")>

<!--- set up page header --->
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iAuditTab eq 1>
	<cfset oAudit = createObject("component", "#application.packagepath#.farcry.audit")>
	<cfset qLog = oAudit.getAuditLog(objectid=url.objectid)>
	
	<cfoutput>
	<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].auditTrace#</div>
	</cfoutput>
	
	<cfif qLog.recordcount gt 0>
		<cfoutput>
		<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
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
			<cfoutput>
			<tr>
				<td colspan="5" align="right"><span class="frameMenuBullet">&raquo;</span> <a href="edittabAudit.cfm?objectid=#url.objectid#">#application.adminBundle[session.dmProfile.locale].showAllUsers#</a></td>
			</tr>
			</cfoutput>
		</cfif>

		<cfoutput></table></cfoutput>
	
	<cfelse>
		<cfoutput>
		<table cellpadding="5" cellspacing="0" border="0" style="margin-left:30px;">
		<tr>
			<td colspan="5">#application.adminBundle[session.dmProfile.locale].noTraceRecorded#</td>
		</tr>
		</table>
		</cfoutput>
	</cfif>
	<cfoutput><a href="<cfoutput>#application.url.farcry#/edittabOverview.cfm?objectid=#url.objectId#</cfoutput>">[BACK]</a></cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="false" />