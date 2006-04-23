<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/ui/admin/Attic/statsLocale.cfm,v 1.5 2003/05/15 05:24:43 brendan Exp $
$Author: brendan $
$Date: 2003/05/15 05:24:43 $
$Name: b131 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: Displays summary stats for viewed objects, filter by type,date,maxRows. Click through for graphs$
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
	qLocales = oStats.getLocales(dateRange=#form.dateRange#,maxRows=#form.maxRows#);
</cfscript>

<cfoutput>
<div class="formtitle">Most Popular User Locales</div>

<cfif qLocales.recordcount>
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
			<p></p>
			<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
			<tr>
				<th class="dataheader">Country</td>
				<th class="dataheader">Language</td>
				<th class="dataheader">Sessions</td>
			</tr>
			
			<!--- show stats with links to detail --->
			<cfloop query="qLocales">
				<tr class="#IIF(qLocales.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
					<td>#country#</td>
					<td>#locale#</td>
					<td align="center">#count_locale#</td>
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
				yAxisTitle = "Referers" 
				show3D = "yes"
				xOffset = "0.15" 
				yOffset = "0.15"
				rotated = "no" 
				showLegend = "no" 
				tipStyle = "MouseOver"
				pieSliceStyle="solid">
				
				<cfchartseries type="pie" query="qLocales" itemcolumn="locale" valuecolumn="count_locale" serieslabel="Today" paintstyle="shade"></cfchartseries>
			</cfchart>
		</td>
	</tr>
	</table>
<cfelse>
	No locales have been logged at this time.
</cfif>
</cfoutput>

<admin:footer>

<cfsetting enablecfoutputonly="no">