<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/statsLocale.cfm,v 1.4 2004/07/30 05:22:18 brendan Exp $
$Author: brendan $
$Date: 2004/07/30 05:22:18 $
$Name: milestone_2-3-2 $
$Revision: 1.4 $

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
	
	<!--- get stats --->
	<cfscript>
		qLocales = application.factory.oStats.getLocales(dateRange=#form.dateRange#,maxRows=#form.maxRows#);
	</cfscript>
	
	<cfoutput>
	<div class="formtitle">#application.adminBundle[session.dmProfile.locale].mostPopularUserLocales#</div>
	
	<cfif qLocales.recordcount>
		<table>
		<tr>
			<td valign="top" nowrap>
				<table cellpadding="5" cellspacing="0" border="0"  style="margin-left:30px;">
				<form action="" method="post">
				<tr>
					<td nowrap>		
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
					
					<input type="submit" value="#application.adminBundle[session.dmProfile.locale].update#">
					</td>
				</tr>
				</form>
				</table>
				<p></p>
				<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
				<tr>
					<th class="dataheader">#application.adminBundle[session.dmProfile.locale].country#</td>
					<th class="dataheader">#application.adminBundle[session.dmProfile.locale].language#</td>
					<th class="dataheader">#application.adminBundle[session.dmProfile.locale].sessions#</td>
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
					yAxisTitle = "#application.adminBundle[session.dmProfile.locale].referer#" 
					show3D = "yes"
					xOffset = "0.15" 
					yOffset = "0.15"
					rotated = "no" 
					showLegend = "no" 
					tipStyle = "MouseOver"
					pieSliceStyle="solid">
					
					<cfchartseries type="pie" query="qLocales" itemcolumn="locale" valuecolumn="count_locale" serieslabel="#application.adminBundle[session.dmProfile.locale].today#" paintstyle="shade"></cfchartseries>
				</cfchart>
			</td>
		</tr>
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
		
		</table>
	<cfelse>
		#application.adminBundle[session.dmProfile.locale].noLocalesNow#
	</cfif>
	</cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="no">