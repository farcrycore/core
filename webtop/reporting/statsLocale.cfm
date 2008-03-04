<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/reporting/statsLocale.cfm,v 1.8 2005/08/17 03:28:39 pottery Exp $
$Author: pottery $
$Date: 2005/08/17 03:28:39 $
$Name: milestone_3-0-1 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: Displays summary stats for viewed objects, filter by type,date,maxRows. Click through for graphs$

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
	
	<!--- get stats --->
	<cfscript>
		qLocales = application.factory.oStats.getLocales(dateRange=#form.dateRange#,maxRows=#form.maxRows#);
	</cfscript>
	
	<cfoutput>
	
	<cfif qLocales.recordcount>


				<form method="post" class="f-wrap-1 f-bg-short" action="">
				<fieldset>
				
					<h3>#apapplication.rb.getResource("mostPopularUserLocales")#</h3>
					
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
					
					<div class="f-submit-wrap">
					<input type="submit" value="#apapplication.rb.getResource("update")#" class="f-submit" />
					</div>
					
				</fieldset>
				</form>

				<hr />
				
				<table class="table-3" cellspacing="0">
				<tr>
					<th>#apapplication.rb.getResource("country")#</th>
					<th>#apapplication.rb.getResource("language")#</th>
					<th>#apapplication.rb.getResource("sessions")#</th>
				</tr>
				
				<!--- show stats with links to detail --->
				<cfloop query="qLocales">
					<tr class="#IIF(qLocales.currentRow MOD 2, de(""), de("alt"))#">
						<td>#country#</td>
						<td>#locale#</td>
						<td>#count_locale#</td>
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
					yAxisTitle = "#apapplication.rb.getResource("referer")#" 
					show3D = "yes"
					xOffset = "0.15" 
					yOffset = "0.15"
					rotated = "no" 
					showLegend = "no" 
					tipStyle = "MouseOver"
					pieSliceStyle="solid">
					
					<cfchartseries type="pie" query="qLocales" itemcolumn="locale" valuecolumn="count_locale" serieslabel="#apapplication.rb.getResource("today")#" paintstyle="shade"></cfchartseries>
				</cfchart>
				
				<hr />
			
		<cfset mapCountries=valueList(qLocales.isocode,"|")>
		<cfset countryHits=valueList(qLocales.count_locale,"|")>
		
		<!--- show map --->
		
				<div>
				<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
				 codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab##version=6,0,0,0"
				 WIDTH="650" HEIGHT="325" id="world" ALIGN="">
				 <param NAME=movie VALUE="worldg.swf"> 
				 <param NAME=quality VALUE=high>
				 <PARAM NAME='Flashvars' VALUE='country=#mapCountries#&hits=#countryHits#&colover=CCCCFF&colsel=FF9900'>
				  <param NAME=bgcolor VALUE=##003399> 
				 <embed src="worldg.swf" quality=high bgcolor=##003399  WIDTH="650" HEIGHT="325" NAME="world" ALIGN="" 
				 FlashVars='country=#mapCountries#&hits=#countryHits#&colover=CCCCFF&colsel=FF9900'
				 TYPE="application/x-shockwave-flash" PLUGINSPAGE="http://www.macromedia.com/go/getflashplayer"></embed>
				</object>
				
				<p>
				<small>flash map provided by <a href="mailto:eric.mauviere@emc3.fr?subject=geolocator">eric mauviere</a></small>
				</p>
				</div>

	<cfelse>
		<h3>#apapplication.rb.getResource("noLocalesNow")#</h3>
	</cfif>
	</cfoutput>
</sec:CheckPermission>

<admin:footer>

<cfsetting enablecfoutputonly="no">