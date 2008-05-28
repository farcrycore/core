<cfsetting enablecfoutputonly="true" />
<cfprocessingDirective pageencoding="utf-8">
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
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

<sec:CheckPermission error="true" permission="ObjectAuditTab">
	<cfset oAudit = createObject("component", "#application.packagepath#.farcry.audit") />
	<cfset qLog = oAudit.getAuditLog(objectid=url.objectid) />
	
	<cfoutput>	<h3>#application.rb.getResource("auditTrace")#</h3></cfoutput>
	
	<cfif qLog.recordcount gt 0>
		<cfoutput>
		<table cellspacing="0">
		<tr>
			<th>#application.rb.getResource("date")#</th>
			<th>#application.rb.getResource("changeType")#</th>
			<th>#application.rb.getResource("location")#</th>
			<th>#application.rb.getResource("notes")#</th>
			<th>#application.rb.getResource("user")#</th>
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
							<cfif notes neq "">
								#notes#
							<cfelse>
								<em>#application.rb.getResource("notAvailable")#</em>
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
						<cfif notes neq "">
							#notes#
						<cfelse>
							<em>#application.rb.getResource("notAvailable")#</em>
						</cfif>
					</td>
					<td><a href="edittabAudit.cfm?objectid=#objectid#&user=#username#">#username#</a></td>
				</tr></cfoutput>
			</cfif>
		</cfloop>

		<cfif structKeyExists(url, "user")>
			<cfoutput>
			<tr>
				<td colspan="5" align="right"><span class="frameMenuBullet">&raquo;</span> <a href="edittabAudit.cfm?objectid=#url.objectid#">#application.rb.getResource("showAllUsers")#</a></td>
			</tr></cfoutput>
		</cfif>

		<cfoutput>
		</table></cfoutput>
	
	<cfelse>
		<cfoutput>
		<table cellpadding="5" cellspacing="0" border="0" style="margin-left:30px;">
			<tr>
				<td colspan="5">#application.rb.getResource("noTraceRecorded")#</td>
			</tr>
		</table></cfoutput>
	</cfif>
</sec:CheckPermission>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="false" />