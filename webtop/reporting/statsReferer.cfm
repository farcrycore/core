<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/reporting/statsReferer.cfm,v 1.7 2005/08/17 03:28:39 pottery Exp $
$Author: pottery $
$Date: 2005/08/17 03:28:39 $
$Name: milestone_3-0-1 $
$Revision: 1.7 $

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

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="ReportingStatsTab">
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
	
	<cfif qReferers.recordcount>
		
		<form method="post" class="f-wrap-1 f-bg-short" action="">
		<fieldset>
		
			<h3>#application.rb.getResource("mostPopularReferers")#</h3>
			
			<label for="dateRange">
			<!--- drop down for date --->
			<b>#application.rb.getResource("Date")#</b>
			<select name="dateRange" id="dateRange">
				<option value="all" <cfif form.dateRange eq "all">selected="selected"</cfif>>#application.rb.getResource("allDates")#</option>
				<option value="d" <cfif form.dateRange eq "d">selected="selected"</cfif>>#application.rb.getResource("today")#</option>
				<option value="ww" <cfif form.dateRange eq "ww">selected="selected"</cfif>>#application.rb.getResource("lastWeek")#</option>
				<option value="m" <cfif form.dateRange eq "m">selected="selected"</cfif>>#application.rb.getResource("lastMonth")#</option>
				<option value="q" <cfif form.dateRange eq "q">selected="selected"</cfif>>#application.rb.getResource("lastQuarter")#</option>
				<option value="yyyy" <cfif form.dateRange eq "yyyy">selected="selected"</cfif>>#application.rb.getResource("lastYear")#</option>
			</select><br />
			</label>
			
			<label for="maxRows">
			<!--- drop down for max rows --->
			<b>#application.rb.getResource("Rows")#</b>
			<select name="maxRows" id="maxRows">
				<option value="all" <cfif form.maxRows eq "all">selected="selected"</cfif>>#application.rb.getResource("allRows")#</option>
				<cfloop from="10" to="200" step=10 index="rows">
					<option value="#rows#" <cfif rows eq form.maxRows>selected="selected"</cfif>>#rows#</option>
				</cfloop>
			</select><br />
			</label>
			
			<fieldset class="f-checkbox-wrap">
				
				<b>#application.rb.getResource("filterOwnSite")#</b>
				
				<fieldset>
				
				<label for="filter">
				<input type="checkbox" name="filter" id="filter" class="f-checkbox" value="1" <cfif form.filter>checked="checked"</cfif> />
				</label>
	
				</fieldset>
				
			</fieldset> 
			
			<div class="f-submit-wrap">
			<input type="submit" value="#application.rb.getResource("Update")#" class="f-submit" />
			</div>
			
		</fieldset>
		</form>
		
		<hr />
		
		<table class="table-3" cellspacing="0">
		<tr>
			<th>#application.rb.getResource("Referer")#</th>
			<th>#application.rb.getResource("Referals")#</th>
		</tr>
		
		<!--- show stats with links to detail --->
		<cfloop query="qReferers">
			<tr class="#IIF(qReferers.currentRow MOD 2, de(""), de("alt"))#">
				<td><a href="#referer#" class="referer">#left(referer,70)#<cfif len(referer) gt 70>...</cfif></a></td>
				<td>#count_referers#</td>
			</tr>
		</cfloop>
		
		</table>
		
		<hr />
		
		<!--- show graph --->
		<cfchart 
			chartHeight="300" 
			chartWidth="300" 
			scaleFrom="0" 
			seriesPlacement="default"
			showBorder = "no"
			fontsize="10"
			labelFormat = "number"
			yAxisTitle = "#application.rb.getResource("Referer")#" 
			show3D = "yes"
			rotated = "no" 
			showLegend = "no" 
			tipStyle = "MouseOver"
			pieSliceStyle="solid">
			
			<cfchartseries type="pie" query="qReferers" itemcolumn="referer" valuecolumn="count_referers" serieslabel="#application.rb.getResource("Today")#" paintstyle="shade"></cfchartseries>
		</cfchart>
		
	<cfelse>
		<h3>#application.rb.getResource("noReferersNow")#</h3>
	</cfif>
	</cfoutput>
</sec:CheckPermission>

<admin:footer>

<cfsetting enablecfoutputonly="no">