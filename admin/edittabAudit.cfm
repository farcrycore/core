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
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<!--- set up page header --->
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:restricted permission="ObjectAuditTab">
	<cfset oAudit = createObject("component", "#application.packagepath#.farcry.audit") />
	<cfset qLog = oAudit.getAuditLog(objectid=url.objectid) />
	
	<cfoutput>	<h3>#application.adminBundle[session.dmProfile.locale].auditTrace#</h3></cfoutput>
	
	<cfif qLog.recordcount gt 0>
		<cfoutput>
		<table cellspacing="0">
		<tr>
			<th>#application.adminBundle[session.dmProfile.locale].date#</th>
			<th>#application.adminBundle[session.dmProfile.locale].changeType#</th>
			<th>#application.adminBundle[session.dmProfile.locale].location#</th>
			<th>#application.adminBundle[session.dmProfile.locale].notes#</th>
			<th>#application.adminBundle[session.dmProfile.locale].user#</th>
		</tr>
		</cfoutput>
		<cfloop query="qLog">
			<!--- TODO: Why do we have this redundant CFIF which outputs the same info regardless? JSC --->
			<cfif structKeyExists(url, "user")>
				<cfif url.user eq username>
					<cfoutput>
					<tr>
						<td>
						#application.thisCalendar.i18nDateFormat(datetimestamp,session.dmProfile.locale,application.longF)# 
						#application.thisCalendar.i18nTimeFormat(datetimestamp,session.dmProfile.locale,application.shortF)#
						</td>
						<td>#audittype#</td>
						<td>#location#</td>
						<td>
							<cfif note neq "">
								#note#
							<cfelse>
								<em>#application.adminBundle[session.dmProfile.locale].notAvailable#</em>
							</cfif>
						</td>
						<td><a href="edittabAudit.cfm?objectid=#objectid#&amp;user=#username#">#username#</a></td>
					</tr></cfoutput>
				</cfif>	
			<cfelse>
				<cfoutput>
				<tr>
					<td>
					#application.thisCalendar.i18nDateFormat(datetimestamp,session.dmProfile.locale,application.longF)# 
					#application.thisCalendar.i18nTimeFormat(datetimestamp,session.dmProfile.locale,application.shortF)#
					</td>
					<td>#audittype#</td>
					<td>#location#</td>
					<td>
						<cfif note neq "">
							#note#
						<cfelse>
							<em>#application.adminBundle[session.dmProfile.locale].notAvailable#</em>
						</cfif>
					</td>
					<td><a href="edittabAudit.cfm?objectid=#objectid#&user=#username#">#username#</a></td>
				</tr></cfoutput>
			</cfif>
		</cfloop>

		<cfif structKeyExists(url, "user")>
			<cfoutput>
			<tr>
				<td colspan="5" align="right"><span class="frameMenuBullet">&raquo;</span> <a href="edittabAudit.cfm?objectid=#url.objectid#">#application.adminBundle[session.dmProfile.locale].showAllUsers#</a></td>
			</tr></cfoutput>
		</cfif>

		<cfoutput>
		</table></cfoutput>
	
	<cfelse>
		<cfoutput>
		<table cellpadding="5" cellspacing="0" border="0" style="margin-left:30px;">
			<tr>
				<td colspan="5">#application.adminBundle[session.dmProfile.locale].noTraceRecorded#</td>
			</tr>
		</table></cfoutput>
	</cfif>
</sec:restricted>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="false" />