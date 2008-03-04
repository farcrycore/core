<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

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
		
			<h3>#apapplication.rb.getResource("mostPopularReferers")#</h3>
			
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
			<b>#apapplication.rb.getResource("Rows")#</b>
			<select name="maxRows" id="maxRows">
				<option value="all" <cfif form.maxRows eq "all">selected="selected"</cfif>>#apapplication.rb.getResource("allRows")#</option>
				<cfloop from="10" to="200" step=10 index="rows">
					<option value="#rows#" <cfif rows eq form.maxRows>selected="selected"</cfif>>#rows#</option>
				</cfloop>
			</select><br />
			</label>
			
			<fieldset class="f-checkbox-wrap">
				
				<b>#apapplication.rb.getResource("filterOwnSite")#</b>
				
				<fieldset>
				
				<label for="filter">
				<input type="checkbox" name="filter" id="filter" class="f-checkbox" value="1" <cfif form.filter>checked="checked"</cfif> />
				</label>
	
				</fieldset>
				
			</fieldset> 
			
			<div class="f-submit-wrap">
			<input type="submit" value="#apapplication.rb.getResource("Update")#" class="f-submit" />
			</div>
			
		</fieldset>
		</form>
		
		<hr />
		
		<table class="table-3" cellspacing="0">
		<tr>
			<th>#apapplication.rb.getResource("Referer")#</th>
			<th>#apapplication.rb.getResource("Referals")#</th>
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
			format="flash" 
			chartHeight="300" 
			chartWidth="300" 
			scaleFrom="0" 
			seriesPlacement="default"
			showBorder = "no"
			fontsize="10"
			labelFormat = "number"
			yAxisTitle = "#apapplication.rb.getResource("Referer")#" 
			show3D = "yes"
			xOffset = "0.15" 
			yOffset = "0.15"
			rotated = "no" 
			showLegend = "no" 
			tipStyle = "MouseOver"
			pieSliceStyle="solid">
			
			<cfchartseries type="pie" query="qReferers" itemcolumn="referer" valuecolumn="count_referers" serieslabel="#apapplication.rb.getResource("Today")#" paintstyle="shade"></cfchartseries>
		</cfchart>
		
	<cfelse>
		<h3>#apapplication.rb.getResource("noReferersNow")#</h3>
	</cfif>
	</cfoutput>
</sec:CheckPermission>

<admin:footer>

<cfsetting enablecfoutputonly="no">