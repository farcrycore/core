<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/statsBrowsers.cfm,v 1.3 2003/09/09 04:25:03 brendan Exp $
$Author: brendan $
$Date: 2003/09/09 04:25:03 $
$Name: b201 $
$Revision: 1.3 $

|| DESCRIPTION || 
Shows view statistics for browsers

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
out:
--->
<cfsetting enablecfoutputonly="yes" requestTimeOut="600">

<!--- check permissions --->
<cfscript>
	iStatsTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingStatsTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iStatsTab eq 1>

	<cfparam name="form.dateRange" default="all">
	<cfparam name="form.maxRows" default="20">
	
	<!--- get page log entries --->
	<cfscript>
		q1 = application.factory.oStats.getBrowsers(dateRange='#form.dateRange#',maxRows=#form.maxRows#);
	</cfscript>
	
	<cfoutput><br>
	<span class="FormTitle">Browser Usage</span>
	<p></p></cfoutput>
	
	<cfif q1.recordcount>
		<cfoutput>
		<table>
		<tr>
			<td valign="top" nowrap>
			<table cellpadding="5" cellspacing="0" border="0">
			<form action="" method="post">
			<tr>
				<td width="450">
				<!--- drop down for date --->
				Date
				<select name="dateRange">
					<option value="all" <cfif form.dateRange eq "all">selected</cfif>>All Dates
					<option value="d" <cfif form.dateRange eq "d">selected</cfif>>Today
					<option value="ww" <cfif form.dateRange eq "ww">selected</cfif>>Last Week
					<option value="m" <cfif form.dateRange eq "m">selected</cfif>>Last Month
					<option value="q" <cfif form.dateRange eq "q">selected</cfif>>Last Quarter
					<option value="yyyy" <cfif form.dateRange eq "yyyy">selected</cfif>>Last Year
				</select>
				
				<!--- drop down for max rows --->
					Rows
					<select name="maxRows">
						<option value="all" <cfif form.maxRows eq "all">selected</cfif>>All Rows
						<cfloop from="10" to="200" step=10 index="rows">
							<option value="#rows#" <cfif rows eq form.maxRows>selected</cfif>>#rows#
						</cfloop>
					</select>
				<input type="submit" value="Update">
				</td>
			</tr>
			</form>
			</table>
			<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
				<tr>
					<th class="dataheader">Browser</td>
					<th class="dataheader">Sessions</td>
				</tr>
				
				<!--- show stats with links to detail --->
				<cfloop query="q1">
					<tr class="#IIF(q1.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
						<td>#browser#</td>
						<td align="center">#views#</td>
					</tr>
				</cfloop>
				
				</table>
			</td>
			<td valign="top">
		
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
				yAxisTitle = "Browser Usage" 
				show3D = "yes"
				xOffset = "0.15" 
				yOffset = "0.15"
				rotated = "no" 
				showLegend = "no" 
				tipStyle = "MouseOver"
				pieSliceStyle="solid">
				
				<cfchartseries type="pie" query="q1" itemcolumn="browser" valuecolumn="views" serieslabel="Today" paintstyle="shade"></cfchartseries>
			</cfchart>
			</td>
		</tr>
		</table>
		</cfoutput>
	<cfelse>
		<cfoutput>No stats recorded at this time</cfoutput>
	</cfif>
	
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="yes">