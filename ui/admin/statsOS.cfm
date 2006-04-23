<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/ui/admin/Attic/statsOS.cfm,v 1.2 2003/05/29 04:05:30 brendan Exp $
$Author: brendan $
$Date: 2003/05/29 04:05:30 $
$Name: b131 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Displays summary stats for operating systems$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">

<admin:header>

<cfparam name="form.typeName" default="all">
<cfparam name="form.dateRange" default="all">
<cfparam name="form.maxRows" default="20">

<!--- get stats --->
<cfscript>
	oStats = createObject("component", "#application.packagepath#.farcry.stats");
	qOS = oStats.getOS(dateRange=#form.dateRange#,maxRows=#form.maxRows#);
</cfscript>

<cfoutput>
<div class="formtitle">Most Popular User Operating Systems</div>

<cfif qOS.recordcount>
	<table>
	<tr>
		<td valign="top" nowrap>
			<table cellpadding="5" cellspacing="0" border="0"  style="margin-left:30px;">
			<form action="" method="post">
			<tr>
				<td nowrap>			
				<!--- drop down for date --->
				Date
				<select name="dateRange">
					<option value="d" <cfif form.dateRange eq "d">selected</cfif>>Today
					<option value="ww" <cfif form.dateRange eq "ww">selected</cfif>>Last Week
					<option value="m" <cfif form.dateRange eq "m">selected</cfif>>Last Month
					<option value="q" <cfif form.dateRange eq "q">selected</cfif>>Last Quarter
					<option value="yyyy" <cfif form.dateRange eq "yyyy">selected</cfif>>Last Year
					<option value="all" <cfif form.dateRange eq "all">selected</cfif>>All Dates
				</select>
				
				<!--- drop down for max rows --->
				Rows
				<select name="maxRows">
					<cfloop from="10" to="200" step=10 index="rows">
						<option value="#rows#" <cfif rows eq form.maxRows>selected</cfif>>#rows#
					</cfloop>
					<option value="all" <cfif form.maxRows eq "all">selected</cfif>>All Rows
				</select>
				
				<input type="submit" value="Update">
				</td>
			</tr>
			</form>
			</table>
			
			<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
			<tr>
				<th class="dataheader">Locale</td>
				<th class="dataheader">Sessions</td>
			</tr>
			
			<!--- show stats with links to detail --->
			<cfloop query="qOS">
				<tr class="#IIF(qOS.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
					<td>#os#</td>
					<td align="center">#count_os#</td>
				</tr>
			</cfloop>
			
			</table>
		</td>
		<td valign="top">
			<!--- show graph --->
			<cfchart 
				format="flash" 
				chartHeight="300" 
				chartWidth="300" 
				scaleFrom="0" 
				seriesPlacement="default"
				showBorder = "no"
				fontsize="10"
				font="arialunicodeMS" 
				labelFormat = "number"
				yAxisTitle = "Operating Systems" 
				show3D = "yes"
				xOffset = "0.15" 
				yOffset = "0.15"
				rotated = "no" 
				showLegend = "no" 
				tipStyle = "MouseOver"
				pieSliceStyle="solid">
				
				<cfchartseries type="pie" query="qOS" itemcolumn="os" valuecolumn="count_os" serieslabel="Today" paintstyle="shade"></cfchartseries>
			</cfchart>
		</td>
	</tr>
	</table>
<cfelse>
	No operating systems have been logged at this time.
</cfif>
</cfoutput>

<admin:footer>

<cfsetting enablecfoutputonly="no">