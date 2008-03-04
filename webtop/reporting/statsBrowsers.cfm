<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/reporting/statsBrowsers.cfm,v 1.7 2005/08/17 03:28:39 pottery Exp $
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

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="ReportingStatsTab">
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
	
				<h3>#apapplication.rb.getResource("browserUsage")#</h3>
				
				<label for="dateRange">
				<!--- drop down for date --->
				<b>#apapplication.rb.getResource("Date")#</b>
				<select name="dateRange" id="dateRange">
					<option value="all" <cfif form.dateRange eq "all">selected="selected"</cfif>>#apapplication.rb.getResource("allDates")#</option>
					<option value="d" <cfif form.dateRange eq "d">selected="selected"</cfif>>#apapplication.rb.getResource("today")#</option>
					<option value="ww" <cfif form.dateRange eq "ww">selected="selected"</cfif>>#apapplication.rb.getResource("lastWeek")#</option>
					<option value="m" <cfif form.dateRange eq "m">selected="selected"</cfif>>#apapplication.rb.getResource("lastMonth")#</option>
					<option value="q" <cfif form.dateRange eq "q">selected="selected"</cfif>>#apapplication.rb.getResource("lastQuarter")#</option>
					<option value="yyyy" <cfif form.dateRange eq "yyyy">selected="selected"</cfif>>#apapplication.rb.getResource("lastYear")#</option>
				</select><br />
				</label>
				
				<label for="maxRows">
				<!--- drop down for max rows --->
				<b>#apapplication.rb.getResource("rows")#</b>
				<select name="maxRows" id="maxRows">
					<option value="all" <cfif form.maxRows eq "all">selected="selected"</cfif>>#apapplication.rb.getResource("allRows")#</option>
					<cfloop from="10" to="200" step=10 index="rows">
						<option value="#rows#" <cfif rows eq form.maxRows>selected="selected"</cfif>>#rows#</option>
					</cfloop>
				</select><br />
				</label>
				
				<div class="f-submit-wrap">
				<input type="submit" value="#apapplication.rb.getResource("update")#" class="f-submit" />
				</div>
			
			</fieldset>
			</form>

			<hr />
			
			<table class="table-3" cellspacing="0">
				<tr>
					<th>#apapplication.rb.getResource("browser")#</th>
					<th>#apapplication.rb.getResource("sessions")#</th>
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
				labelFormat = "number"
				yAxisTitle = "#apapplication.rb.getResource("browserUsage")#" 
				show3D = "yes"
				xOffset = "0.15" 
				yOffset = "0.15"
				rotated = "no" 
				showLegend = "no" 
				tipStyle = "MouseOver"
				pieSliceStyle="solid">
				
				<cfchartseries type="pie" query="q1" itemcolumn="browser" valuecolumn="views" serieslabel="#apapplication.rb.getResource("today")#" paintstyle="shade"></cfchartseries>
			</cfchart>

		</cfoutput>
	<cfelse>
		<cfoutput><h3>#apapplication.rb.getResource("noStatsNow")#</h3></cfoutput>
	</cfif>
</sec:CheckPermission>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="yes">