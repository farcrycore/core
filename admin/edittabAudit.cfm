<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/edittabAudit.cfm,v 1.8 2003/09/11 01:26:52 brendan Exp $
$Author: brendan $
$Date: 2003/09/11 01:26:52 $
$Name: b201 $
$Revision: 1.8 $

|| DESCRIPTION || 
$DESCRIPTION: Displays an audit log for object$
$TODO:  $ 

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in:$ 
$out:$
--->

<!--- check permissions --->
<cfscript>
	iAuditTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectAuditTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iAuditTab eq 1>
	<cfscript>
		oAudit = createObject("component", "#application.packagepath#.farcry.audit");
		qLog = oAudit.getAuditLog(objectid=url.objectid);
	</cfscript>
	
	<div class="FormTitle">Audit Trace</div>
	
	
	<cfif qLog.recordcount gt 0>
		<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
		<tr class="dataheader">
			<td align="center"><strong>Date</strong></td>
			<td align="center"><strong>Change Type</strong></td>
			<td align="center"><strong>Location</strong></td>
			<td align="center"><strong>Notes</strong></td>
			<td align="center"><strong>User</strong></td>
		</tr>
		<cfoutput query="qLog">
			<cfif isdefined("url.user")>
				<cfif url.user eq username>
					<tr class="#IIF(qLog.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
						<td>#dateformat(datetimestamp, "dd-mmm-yyyy")# #timeformat(datetimestamp)#</td>
						<td>#audittype#</td>
						<td>#location#</td>
						<td <cfif note eq "">align="center"</cfif>><cfif note neq "">#note#<cfelse><em>n/a</em></cfif></td>
						<td><a href="edittabAudit.cfm?objectid=#objectid#&user=#username#">#username#</a></td>
					</tr>
				</cfif>	
			<cfelse>
				<tr class="#IIF(qLog.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
					<td>#dateformat(datetimestamp, "dd-mmm-yyyy")# #timeformat(datetimestamp)#</td>
					<td>#audittype#</td>
					<td>#location#</td>
					<td <cfif note eq "">align="center"</cfif>><cfif note neq "">#note#<cfelse><em>n/a</em></cfif></td>
					<td><a href="edittabAudit.cfm?objectid=#objectid#&user=#username#">#username#</a></td>
				</tr>
			</cfif>
		</cfoutput>
		<cfif isdefined("url.user")>
			<tr>
				<td colspan="5" align="right"><span class="frameMenuBullet">&raquo;</span> <a href="edittabAudit.cfm?objectid=<cfoutput>#url.objectid#</cfoutput>">Show all users</a></td>
			</tr>
		</cfif>
		</table>
	<cfelse>
		<table cellpadding="5" cellspacing="0" border="0" style="margin-left:30px;">
		<tr>
			<td colspan="5">No trace recorded.</td>
		</tr>
		</table>
	</cfif>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>