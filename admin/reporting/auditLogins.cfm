<cfsetting enablecfoutputonly="true" />
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/reporting/auditLogins.cfm,v 1.7 2005/08/16 02:41:08 pottery Exp $
$Author: pottery $
$Date: 2005/08/16 02:41:08 $
$Name: milestone_3-0-1 $
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

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:restricted permission="ReportingAuditTab">
  <cfif isdefined("url.view")>
	  <cfoutput>	<h3>#application.adminBundle[session.dmProfile.locale].allLogins#</h3></cfoutput>
  <cfelse>
  	<cfoutput>	<h3>#application.adminBundle[session.dmProfile.locale].recentLogins#</h3></cfoutput>
  </cfif>
	
	<cfscript>
		if (not isdefined("url.view")) {
			maxrows=10;
		} else {
			maxrows=100;
		}
		qLogins = application.factory.oAudit.getAuditLog(maxrows=maxrows, audittype="dmSec.login");
	</cfscript>	
	
	<cfoutput>
	<table class="table-3" cellspacing="0">
	<tr>
		<th>#application.adminBundle[session.dmProfile.locale].date#</th>
		<th>#application.adminBundle[session.dmProfile.locale].location#</th>
		<th>#application.adminBundle[session.dmProfile.locale].note#</th>
		<th>#application.adminBundle[session.dmProfile.locale].user#</th>
	</tr></cfoutput>
	<cfloop query="qLogins"><cfoutput>
		<tr class="#IIF(currentrow MOD 2, de(""), de("alt"))#">
			<td>
			#application.thisCalendar.i18nDateFormat(Datetimestamp,session.dmProfile.locale,application.shortF)# 
			#application.thisCalendar.i18nTimeFormat(Datetimestamp,session.dmProfile.locale,application.shortF)#
			</td>
			<td>#Location#</td>
			<td>#Note#</td>
			<td><cfif username neq "">#Username#<cfelse><i>#application.adminBundle[session.dmProfile.locale].unknown#</i></cfif></td>
		</tr></cfoutput>
  </cfloop>
  <cfoutput>
	</table>
	<hr />
	<ul></cfoutput>

	<li>

	<cfif not isdefined("url.view")><cfoutput>
		<li><a href="auditLogins.cfm?view=all">#application.adminBundle[session.dmProfile.locale].viewAllLogins#</a></li></cfoutput>
	<cfelse><cfoutput>
		<li><a href="auditLogins.cfm">#application.adminBundle[session.dmProfile.locale].viewRecentLogins#</a></li></cfoutput>
	</cfif>

  <cfoutput>	
	</ul></cfoutput>
</sec:restricted>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="false" />