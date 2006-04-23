<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/statsReferer.cfm,v 1.4 2004/07/15 01:51:48 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:51:48 $
$Name: milestone_2-3-2 $
$Revision: 1.4 $

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

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iStatsTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingStatsTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iStatsTab eq 1>

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
		qReferers = application.factory.oStats.getReferers(dateRange=#form.dateRange#,maxRows=#form.maxRows#,filter="#filterReferers#");
	</cfscript>
	
	<cfoutput>
	<div class="formtitle">#application.adminBundle[session.dmProfile.locale].mostPopularReferers#</div>
	
	<cfif qReferers.recordcount>
		<table cellpadding="5" cellspacing="0" border="0"  style="margin-left:30px;">
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
			#application.adminBundle[session.dmProfile.locale].Rows#
			<select name="maxRows">
				<option value="all" <cfif form.maxRows eq "all">selected</cfif>>#application.adminBundle[session.dmProfile.locale].allRows#
				<cfloop from="10" to="200" step=10 index="rows">
					<option value="#rows#" <cfif rows eq form.maxRows>selected</cfif>>#rows#
				</cfloop>
			</select>
			
			#application.adminBundle[session.dmProfile.locale].filterOwnSite#
			<input type="checkbox" name="filter" value="1" <cfif form.filter>checked</cfif>>
			<input type="submit" value="#application.adminBundle[session.dmProfile.locale].Update#">
			</td>
		</tr>
		</form>
		</table>
		
		<table cellpadding="5" cellspacing="0" border="1" width="500" style="margin-left:30px;">
		<tr>
			<th class="dataheader">#application.adminBundle[session.dmProfile.locale].Referer#</td>
			<th class="dataheader">#application.adminBundle[session.dmProfile.locale].Referals#</td>
		</tr>
		
		<!--- show stats with links to detail --->
		<cfloop query="qReferers">
			<tr class="#IIF(qReferers.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
				<td><a href="#referer#" class="referer">#left(referer,70)#<cfif len(referer) gt 70>...</cfif></a></td>
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
			yAxisTitle = "#application.adminBundle[session.dmProfile.locale].Referer#" 
			show3D = "yes"
			xOffset = "0.15" 
			yOffset = "0.15"
			rotated = "no" 
			showLegend = "no" 
			tipStyle = "MouseOver"
			pieSliceStyle="solid">
			
			<cfchartseries type="pie" query="qReferers" itemcolumn="referer" valuecolumn="count_referers" serieslabel="#application.adminBundle[session.dmProfile.locale].Today#" paintstyle="shade"></cfchartseries>
		</cfchart>
		</div>
	<cfelse>
		#application.adminBundle[session.dmProfile.locale].noReferersNow#
	</cfif>
	</cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="no">