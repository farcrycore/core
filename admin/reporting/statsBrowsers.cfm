<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/reporting/statsBrowsers.cfm,v 1.7 2005/08/17 03:28:39 pottery Exp $
$Author: pottery $
$Date: 2005/08/17 03:28:39 $
$Name: milestone_3-0-1 $
$Revision: 1.7 $

|| DESCRIPTION || 
Shows view statistics for browsers

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
out:
--->
<cfsetting enablecfoutputonly="yes" requestTimeOut="600">

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iStatsTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingStatsTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iStatsTab eq 1>

	<cfparam name="form.dateRange" default="all">
	<cfparam name="form.maxRows" default="20">
	
	<!--- get page log entries --->
	<cfscript>
		q1 = application.factory.oStats.getBrowsers(dateRange='#form.dateRange#',maxRows=#form.maxRows#);
	</cfscript>
	
	<cfif q1.recordcount>
		<cfoutput>
		
			<form method="post" class="f-wrap-1 f-bg-short" action="">
			<fieldset>
	
				<h3>#application.adminBundle[session.dmProfile.locale].browserUsage#</h3>
				
				<label for="dateRange">
				<!--- drop down for date --->
				<b>#application.adminBundle[session.dmProfile.locale].Date#</b>
				<select name="dateRange" id="dateRange">
					<option value="all" <cfif form.dateRange eq "all">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].allDates#</option>
					<option value="d" <cfif form.dateRange eq "d">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].today#</option>
					<option value="ww" <cfif form.dateRange eq "ww">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].lastWeek#</option>
					<option value="m" <cfif form.dateRange eq "m">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].lastMonth#</option>
					<option value="q" <cfif form.dateRange eq "q">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].lastQuarter#</option>
					<option value="yyyy" <cfif form.dateRange eq "yyyy">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].lastYear#</option>
				</select><br />
				</label>
				
				<label for="maxRows">
				<!--- drop down for max rows --->
				<b>#application.adminBundle[session.dmProfile.locale].rows#</b>
				<select name="maxRows" id="maxRows">
					<option value="all" <cfif form.maxRows eq "all">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].allRows#</option>
					<cfloop from="10" to="200" step=10 index="rows">
						<option value="#rows#" <cfif rows eq form.maxRows>selected="selected"</cfif>>#rows#</option>
					</cfloop>
				</select><br />
				</label>
				
				<div class="f-submit-wrap">
				<input type="submit" value="#application.adminBundle[session.dmProfile.locale].update#" class="f-submit" />
				</div>
			
			</fieldset>
			</form>

			<hr />
			
			<table class="table-3" cellspacing="0">
				<tr>
					<th>#application.adminBundle[session.dmProfile.locale].browser#</th>
					<th>#application.adminBundle[session.dmProfile.locale].sessions#</th>
				</tr>
				
				<!--- show stats with links to detail --->
				<cfloop query="q1">
					<tr class="#IIF(q1.currentRow MOD 2, de(""), de("alt"))#">
						<td>#browser#</td>
						<td>#views#</td>
					</tr>
				</cfloop>
				
				</table>

			<hr />
		
			<!--- show graph --->
			<cfchart 
				format="flash" 
				chartHeight="400" 
				chartWidth="400" 
				scaleFrom="0" 
				seriesPlacement="default"
				showBorder = "no"
				fontsize="10"
				font="arialunicodeMS" 
				labelFormat = "number"
				yAxisTitle = "#application.adminBundle[session.dmProfile.locale].browserUsage#" 
				show3D = "yes"
				xOffset = "0.15" 
				yOffset = "0.15"
				rotated = "no" 
				showLegend = "no" 
				tipStyle = "MouseOver"
				pieSliceStyle="solid">
				
				<cfchartseries type="pie" query="q1" itemcolumn="browser" valuecolumn="views" serieslabel="#application.adminBundle[session.dmProfile.locale].today#" paintstyle="shade"></cfchartseries>
			</cfchart>

		</cfoutput>
	<cfelse>
		<cfoutput><h3>#application.adminBundle[session.dmProfile.locale].noStatsNow#</h3></cfoutput>
	</cfif>
	
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="yes">