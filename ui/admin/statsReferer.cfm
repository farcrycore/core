<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/ui/admin/Attic/statsReferer.cfm,v 1.2 2003/05/06 08:12:47 brendan Exp $
$Author: brendan $
$Date: 2003/05/06 08:12:47 $
$Name: b131 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Displays summary stats for viewed objects, filter by type,date,maxRows. Click through for graphs$
$TODO: filter as a config item$

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
<cfparam name="form.filter" default="0">

<cfif form.filter>
	<!--- todo, needs to be a config list --->
	<cfset filterReferers = cgi.server_name>
<cfelse>
	<cfset filterReferers = "all">
</cfif>

<!--- get stats --->
<cfscript>
	oStats = createObject("component", "#application.packagepath#.farcry.stats");
	qReferers = oStats.getReferers(dateRange=#form.dateRange#,maxRows=#form.maxRows#,filter="#filterReferers#");
</cfscript>

<cfoutput>
<div class="formtitle">Most Popular Referers</div>

<cfif qReferers.recordcount>
	<table cellpadding="5" cellspacing="0" border="0"  style="margin-left:30px;">
	<form action="" method="post">
	<tr>
		<td width="450">		
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
		
		Filter own site 
		<input type="checkbox" name="filter" value="1" <cfif form.filter>checked</cfif>>
		<input type="submit" value="Update">
		</td>
	</tr>
	</form>
	</table>
	
	<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
	<tr>
		<th class="dataheader">Referer</td>
		<th class="dataheader">Referals</td>
	</tr>
	
	<!--- show stats with links to detail --->
	<cfloop query="qReferers">
		<tr class="#IIF(qReferers.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
			<td>#referer#</td>
			<td align="center">#count_referers#</td>
		</tr>
	</cfloop>
	
	</table>
	<div align="center">
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
		
		<cfchartseries type="pie" query="qReferers" itemcolumn="referer" valuecolumn="count_referers" serieslabel="Today" paintstyle="shade"></cfchartseries>
	</cfchart>
	</div>
<cfelse>
	No referers have been logged at this time.
</cfif>
</cfoutput>

<admin:footer>

<cfsetting enablecfoutputonly="no">