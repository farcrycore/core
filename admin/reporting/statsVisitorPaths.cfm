<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/reporting/statsVisitorPaths.cfm,v 1.9 2005/08/17 03:28:39 pottery Exp $
$Author: pottery $
$Date: 2005/08/17 03:28:39 $
$Name: milestone_3-0-1 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: Displays stats for visitors objects$


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
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
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
	
	<cfif qVisitors.recordcount>

		<form method="post" class="f-wrap-1 f-bg-short" action="">
		<fieldset>
		
			<h3>#application.adminBundle[session.dmProfile.locale].recentVisitors#</h3>

			<label for="dateRange">
			<!--- drop down for date --->
			<b>#application.adminBundle[session.dmProfile.locale].Date#</b>
			<select name="dateRange" id="dateRange">
				<option value="d" <cfif form.dateRange eq "d">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].Today#</option>
				<option value="ww" <cfif form.dateRange eq "ww">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].lastWeek#</option>
				<option value="m" <cfif form.dateRange eq "m">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].lastMonth#</option>
				<option value="q" <cfif form.dateRange eq "q">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].lastQuarter#</option>
				<option value="yyyy" <cfif form.dateRange eq "yyyy">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].lastYear#</option>
				<option value="all" <cfif form.dateRange eq "all">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].allDates#</option>
			</select><br />
			</label>
			
			<label for="maxRows">
			<!--- drop down for max rows --->
			<b>#application.adminBundle[session.dmProfile.locale].Rows#</b>
			<select name="maxRows" id="maxRows">
				<cfloop from="10" to="200" step=10 index="rows">
					<option value="#rows#" <cfif rows eq form.maxRows>selected="selected"</cfif>>#rows#</option>
				</cfloop>
				<option value="all" <cfif form.maxRows eq "all">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].allRows#</option>
			</select><br />
			</label>
			
			<label for="remoteIP">
			<b>IP</b>
			<input type="text" name="remoteIP" id="remoteIP" /><br />
			</label>
			
			<div class="f-submit-wrap">
			<input type="submit" value="#application.adminBundle[session.dmProfile.locale].Update#" class="f-submit" />
			</div>
			
		</fieldset>
		</form>

		<hr />
		
		<table class="table-3" cellspacing="0">
		<tr>
			<th>#application.adminBundle[session.dmProfile.locale].ipAddress#</th>
			<th>#application.adminBundle[session.dmProfile.locale].viewed#</th>
			<th>#application.adminBundle[session.dmProfile.locale].pagesViewed#</th>
			<th>&nbsp;</th>
		</tr>
		
		<!--- show stats with links to detail --->
		<cfloop query="qVisitors">
			<!--- fix for mysql and java date format --->
			<cfif application.dbType eq "mysql">
				<cfset initialDate = dateAdd("l",1,startDate)>
			<cfelse>
				<cfset initialDate = startDate>
			</cfif>
			<tr class="#IIF(qVisitors.currentRow MOD 2, de(""), de("alt"))#">
				<td>#remoteIP#</td>
				<td>#application.thisCalendar.i18nDateFormat(initialDate,session.dmProfile.locale,application.fullF)#</td>
				<td>#Views#</td>
				<td><a href="statsVisitorPathDetail.cfm?sessionId=#sessionID#">#application.adminBundle[session.dmProfile.locale].viewPath#</a></td>
			</tr>
		</cfloop>
		
		</table>
	<cfelse>
		<h3>#application.adminBundle[session.dmProfile.locale].noVisitorsNow#</h3>
	</cfif>
	</cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="no">