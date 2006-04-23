<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/statsLocale.cfm,v 1.2 2003/09/03 01:50:31 brendan Exp $
$Author: brendan $
$Date: 2003/09/03 01:50:31 $
$Name: b201 $
$Revision: 1.2 $

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

<!--- check permissions --->
<cfscript>
	iStatsTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingStatsTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iStatsTab eq 1>
	<cfparam name="form.typeName" default="all">
	<cfparam name="form.dateRange" default="all">
	<cfparam name="form.maxRows" default="20">
	
	<!--- get stats --->
	<cfscript>
		qLocales = application.factory.oStats.getLocales(dateRange=#form.dateRange#,maxRows=#form.maxRows#);
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
		<cfif application.config.plugins.geoLocator>
			<cfset mapCountries=valueList(qLocales.isocode,"|")>
			<cfset countryHits=valueList(qLocales.count_locale,"|")>
			
			<!--- show map --->
			<tr>
				<td colspan="2">
					<div style="padding-left:30px;padding-top:30px">
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
					<p></p>
					flash map provided by <a href="mailto:eric.mauviere@emc3.fr?subject=geolocator">eric mauviere</a>
					</div>
				</td>
			</tr>
		</cfif>
		</table>
	<cfelse>
		No locales have been logged at this time.
	</cfif>
	</cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="no">