<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/statsBrowsers.cfm,v 1.4 2004/07/15 01:51:48 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:51:48 $
$Name: milestone_2-3-2 $
$Revision: 1.4 $

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
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iStatsTab eq 1>

	<cfparam name="form.dateRange" default="all">
	<cfparam name="form.maxRows" default="20">
	
	<!--- get page log entries --->
	<cfscript>
		q1 = application.factory.oStats.getBrowsers(dateRange='#form.dateRange#',maxRows=#form.maxRows#);
	</cfscript>
	
	<cfoutput><br>
	<span class="FormTitle">#application.adminBundle[session.dmProfile.locale].browserUsage#</span>
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
				#application.adminBundle[session.dmProfile.locale].Date#
				<select name="dateRange">
					<option value="all" <cfif form.dateRange eq "all">selected</cfif>>#application.adminBundle[session.dmProfile.locale].allDates#
					<option value="d" <cfif form.dateRange eq "d">selected</cfif>>#application.adminBundle[session.dmProfile.locale].today#
					<option value="ww" <cfif form.dateRange eq "ww">selected</cfif>>#application.adminBundle[session.dmProfile.locale].lastWeek#
					<option value="m" <cfif form.dateRange eq "m">selected</cfif>>#application.adminBundle[session.dmProfile.locale].lastMonth#
					<option value="q" <cfif form.dateRange eq "q">selected</cfif>>#application.adminBundle[session.dmProfile.locale].lastQuarter#
					<option value="yyyy" <cfif form.dateRange eq "yyyy">selected</cfif>>#application.adminBundle[session.dmProfile.locale].lastYear#
				</select>
				
				<!--- drop down for max rows --->
					#application.adminBundle[session.dmProfile.locale].rows#
					<select name="maxRows">
						<option value="all" <cfif form.maxRows eq "all">selected</cfif>>#application.adminBundle[session.dmProfile.locale].allRows#
						<cfloop from="10" to="200" step=10 index="rows">
							<option value="#rows#" <cfif rows eq form.maxRows>selected</cfif>>#rows#
						</cfloop>
					</select>
				<input type="submit" value="#application.adminBundle[session.dmProfile.locale].update#">
				</td>
			</tr>
			</form>
			</table>
			<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
				<tr>
					<th class="dataheader">#application.adminBundle[session.dmProfile.locale].browser#</td>
					<th class="dataheader">#application.adminBundle[session.dmProfile.locale].sessions#</td>
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
			</td>
		</tr>
		</table>
		</cfoutput>
	<cfelse>
		<cfoutput>#application.adminBundle[session.dmProfile.locale].noStatsNow#</cfoutput>
	</cfif>
	
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="yes">