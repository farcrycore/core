<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/statsVisitorPaths.cfm,v 1.5 2004/08/17 04:51:30 brendan Exp $
$Author: brendan $
$Date: 2004/08/17 04:51:30 $
$Name: milestone_2-3-2 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: Displays stats for visitors objects$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iStatsTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingStatsTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iStatsTab eq 1>
	<cfparam name="form.remoteIP" default="all">
	<cfif form.remoteIP eq "">
		<cfset form.remoteIP = "all">
	</cfif>
	<cfparam name="form.dateRange" default="all">
	<cfparam name="form.maxRows" default="20">
	
	<!--- get stats --->
	<cfscript>
		qVisitors = application.factory.oStats.getVisitors(dateRange=#form.dateRange#,maxRows=#form.maxRows#,remoteIP='#form.remoteIP#');
	</cfscript>
	
	<cfoutput>
	<div class="formtitle">#application.adminBundle[session.dmProfile.locale].recentVisitors#</div>
	
	<cfif qVisitors.recordcount>
		<table cellpadding="5" cellspacing="0" border="0"  style="margin-left:30px;">
		<form action="" method="post">
		<tr>
			<td width="450">
			<!--- drop down for date --->
			#application.adminBundle[session.dmProfile.locale].Date#
			<select name="dateRange">
				<option value="d" <cfif form.dateRange eq "d">selected</cfif>>#application.adminBundle[session.dmProfile.locale].Today#
				<option value="ww" <cfif form.dateRange eq "ww">selected</cfif>>#application.adminBundle[session.dmProfile.locale].lastWeek#
				<option value="m" <cfif form.dateRange eq "m">selected</cfif>>#application.adminBundle[session.dmProfile.locale].lastMonth#
				<option value="q" <cfif form.dateRange eq "q">selected</cfif>>#application.adminBundle[session.dmProfile.locale].lastQuarter#
				<option value="yyyy" <cfif form.dateRange eq "yyyy">selected</cfif>>#application.adminBundle[session.dmProfile.locale].lastYear#
				<option value="all" <cfif form.dateRange eq "all">selected</cfif>>#application.adminBundle[session.dmProfile.locale].allDates#
			</select>
			
			<!--- drop down for max rows --->
			#application.adminBundle[session.dmProfile.locale].Rows#
			<select name="maxRows">
				<cfloop from="10" to="200" step=10 index="rows">
					<option value="#rows#" <cfif rows eq form.maxRows>selected</cfif>>#rows#
				</cfloop>
				<option value="all" <cfif form.maxRows eq "all">selected</cfif>>#application.adminBundle[session.dmProfile.locale].allRows#
			</select>
			
			IP <input type="text" name="remoteIP"> 
			<input type="submit" value="#application.adminBundle[session.dmProfile.locale].Update#">
			</td>
		</tr>
		</form>
		</table>
		
		<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
		<tr>
			<th class="dataheader">#application.adminBundle[session.dmProfile.locale].ipAddress#</td>
			<th class="dataheader">#application.adminBundle[session.dmProfile.locale].viewed#</td>
			<th class="dataheader">#application.adminBundle[session.dmProfile.locale].pagesViewed#</td>
			<th class="dataheader">&nbsp;</td>
		</tr>
		
		<!--- show stats with links to detail --->
		<cfloop query="qVisitors">
			<!--- fix for mysql and java date format --->
			<cfif application.dbType eq "mysql">
				<cfset initialDate = dateAdd("l",1,startDate)>
			<cfelse>
				<cfset initialDate = startDate>
			</cfif>
			<tr class="#IIF(qVisitors.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
				<td>#remoteIP#</td>
				<td align="center">#application.thisCalendar.i18nDateFormat(initialDate,session.dmProfile.locale,application.fullF)#</td>
				<td align="center">#Views#</td>
				<td><a href="statsVisitorPathDetail.cfm?sessionId=#sessionID#">#application.adminBundle[session.dmProfile.locale].viewPath#</a></td>
			</tr>
		</cfloop>
		
		</table>
	<cfelse>
		#application.adminBundle[session.dmProfile.locale].noVisitorsNow#
	</cfif>
	</cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="no">