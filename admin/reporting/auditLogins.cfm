<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/auditLogins.cfm,v 1.3 2003/09/03 01:50:31 brendan Exp $
$Author: brendan $
$Date: 2003/09/03 01:50:31 $
$Name: b201 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: Audit for logins $
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

	<span class="formtitle"><cfif isdefined("url.view")>All<cfelse>Recent</cfif> Logins</span><p></p>
	
	<cfscript>
		if (not isdefined("url.view")) {
			maxrows=10;
		} else {
			maxrows=100;
		}
		qLogins = application.factory.oAudit.getAuditLog(maxrows=maxrows, audittype="dmSec.login");
	</cfscript>	
	
	<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
	<tr class="dataheader">
		<td>Date</td>
		<td>Location</td>
		<td>Note</td>
		<td>User</td>
	</tr>
	<cfoutput query="qLogins">
		<tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
			<td>#dateformat(Datetimestamp,"dd-mmm-yy")# #timeformat(Datetimestamp)#</td>
			<td>#Location#</td>
			<td>#Note#</td>
			<td><cfif username neq "">#Username#<cfelse><i>unknown</i></cfif></td>
		</tr>	
	</cfoutput>
	</table>
	<p></p>
	<span class="frameMenuBullet" style="margin-left:30px;">&raquo;</span> 

	<cfif not isdefined("url.view")>
		<a href="auditLogins.cfm?view=all">View all Logins</a>
	<cfelse>
		<a href="auditLogins.cfm">View recent Logins</a>
	</cfif>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>