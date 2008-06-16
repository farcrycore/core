<!--- @@displayname: Statistics Overview Report --->
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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/scheduledTasks/statsOverviewReport.cfm,v 1.8 2005/09/15 04:43:06 daniela Exp $
$Author: daniela $
$Date: 2005/09/15 04:43:06 $
$Name: milestone_3-0-1 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: Emails an overview report for site activity $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: dateRange - day (d) or week (ww) or month (mm) or quarter (q) or year (yyyy)$
$in: emailTo - emailaddress(s) for report to be sent to$
$out:$
--->

<!--- work out parameters --->
<cfprocessingDirective pageencoding="utf-8">

<cfsetting requestTimeout="600">

<cfparam name="url.dateRange" default="ww">
<cfparam name="url.emailTo" default="#application.config.general.adminemail#">
	
<!--- get stats --->
<cfscript>
	qViews = application.factory.oStats.getMostViewed(typeName='all',dateRange=#url.dateRange#,maxRows=10);
	qLocales = application.factory.oStats.getLocales(dateRange=#url.dateRange#,maxRows=10);
	qBrowsers = application.factory.oStats.getBrowsers(dateRange='#url.dateRange#',maxRows=10);
	qOS = application.factory.oStats.getOS(dateRange=#url.dateRange#,maxRows=10);
	qReferers = application.factory.oStats.getReferers(dateRange=#url.dateRange#,maxRows=10,filter="#cgi.server_name#");
	qSessions = application.factory.oStats.getsessions(dateRange=#url.dateRange#);
	qSearches = application.factory.oStats.getSearchStatsMostPopular(dateRange=#url.dateRange#,maxRows=10);
</cfscript>

<cfset tS=application.rb.formatRBString("emailStatReport","#application.config.general.siteTitle#")>

<cfmail to="#url.emailTo#" from="#application.config.general.adminEmail#" subject="#tS#" type="HTML">

<cfoutput>
<style>
.dataOddRow {
	background-color : ##ccc;
	color: ##333;
}

.dataEvenRow {
	background-color : ##ededed;
	color: ##333;
}
.dataHeader {
	background-color : ##666;
	color: ##ededed;
}
.FormTitle {
		font: bold 10px Verdana, Geneva, Arial, Helvetica, sans-serif;
		color:##666;
  		text-transform: uppercase;
		letter-spacing: .1em;
		padding: 0px 0px 15px 0px;
}	
table, td, div {
	font: 10px Verdana, Geneva, Arial, Helvetica, sans-serif;
}
</style>

<div class="formtitle">
<cfif dateRange neq "all">
	<cfset subS=listToArray('#application.thisCalendar.i18nDateFormat(dateAdd("#dateRange#",-1,now()),application.config.general.locale,application.fullF)#, #application.thisCalendar.i18nDateFormat(now(),application.config.general.locale,application.fullF)#, #numberformat(qSessions.sessions)#')>
	#application.rb.formatRBString("statsOverviewReport",subS)#
<cfelse>
	#application.rb.formatRBString("allDatesOverviewReport","#numberformat(qSessions.sessions)#")#
</cfif> 
</div>

<!--- views --->
<cfif qViews.recordcount>
	<div class="formtitle" style="margin-left:30px;padding-bottom:5px;">Most Popular Pages</div>
	<table cellpadding="5" cellspacing="0" border="1" width="500" style="margin-left:30px;">
	<tr>
		<th class="dataheader" align="left">#application.rb.getResource("objectLC")#</th>
		<th class="dataheader">#application.rb.getResource("views")#</th>
		<th class="dataheader">#application.rb.getResource("typeLC")#</th>
	</tr>
	
	<!--- show stats with links to detail --->
	<cfloop query="qViews">
		<tr class="#IIF(qViews.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
			<td>#title#</td>
			<td align="center" width="75">#downloads#</td>
			<td width="75">#typename#</td>
		</tr>
	</cfloop>
	
	</table>
</cfif>
<p>&nbsp;</p>

<!--- locales --->
<cfif qLocales.recordcount>
	<div class="formtitle" style="margin-left:30px;padding-bottom:5px;">#application.rb.getResource("mostPopularLocales")#</div>
	<table cellpadding="5" cellspacing="0" border="1" width="500" style="margin-left:30px;">
	<tr>
		<th class="dataheader" align="left">#application.rb.getResource("country")#</th>
		<th class="dataheader">#application.rb.getResource("language")#</th>
		<th class="dataheader">#application.rb.getResource("sessions")#</th>
	</tr>
	
	<!--- show stats with links to detail --->
	<cfloop query="qLocales">
		<tr class="#IIF(qLocales.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
			<td>#country#</td>
			<td width="75">#locale#</td>
			<td align="center" width="75">#count_locale#</td>
		</tr>
	</cfloop>
	
	</table>
</cfif>
<p>&nbsp;</p>

<!--- browsers --->
<cfif qBrowsers.recordcount>
	<div class="formtitle" style="margin-left:30px;padding-bottom:5px;">#application.rb.getResource("mostPopularBrowsers")#</div>
	<table cellpadding="5" cellspacing="0" border="1" width="500" style="margin-left:30px;">
	<tr>
		<th class="dataheader" align="left">#application.rb.getResource("browser")#</th>
		<th class="dataheader">#application.rb.getResource("sessions")#</th>
	</tr>
	
	<!--- show stats with links to detail --->
	<cfloop query="qBrowsers">
		<tr class="#IIF(qBrowsers.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
			<td>#browser#</td>
			<td align="center" width="75">#views#</td>
		</tr>
	</cfloop>
	
	</table>
</cfif>
<p>&nbsp;</p>

<!--- operating systems --->
<cfif qOs.recordcount>
	<div class="formtitle" style="margin-left:30px;padding-bottom:5px;">#application.rb.getResource("mostPopularOS")#</div>
	<table cellpadding="5" cellspacing="0" border="1" width="500" style="margin-left:30px;">
	<tr>
		<th class="dataheader" align="left">#application.rb.getResource("OS")#</th>
		<th class="dataheader">#application.rb.getResource("sessions")#</th>
	</tr>
	
	<!--- show stats with links to detail --->
	<cfloop query="qOS">
		<tr class="#IIF(qOS.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
			<td>#os#</td>
			<td align="center" width="75">#count_os#</td>
		</tr>
	</cfloop>
	
	</table>
</cfif>
<p>&nbsp;</p>

<!--- referers --->
<cfif qReferers.recordcount>
	<div class="formtitle" style="margin-left:30px;padding-bottom:5px;">#application.rb.getResource("mostPopularReferers")#</div>
	<table cellpadding="5" cellspacing="0" border="1" width="500" style="margin-left:30px;">
	<tr>
		<th class="dataheader" align="left">#application.rb.getResource("referer")#</th>
		<th class="dataheader">#application.rb.getResource("referals")#</th>
	</tr>
	
	<!--- show stats with links to detail --->
	<cfloop query="qReferers">
		<tr class="#IIF(qReferers.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
			<td><a href="#referer#" class="referer">#left(referer,60)#<cfif len(referer) gt 60>...</cfif></a></td>
			<td align="center" width="75">#count_referers#</td>
		</tr>
	</cfloop>
	
	</table>
</cfif>
<p>&nbsp;</p>

<!--- searches --->
<cfif qSearches.recordcount>
	<div class="formtitle" style="margin-left:30px;padding-bottom:5px;">#application.rb.getResource("mostPopularSearches")#</div>
	<table cellpadding="5" cellspacing="0" border="1" width="500" style="margin-left:30px;">
	<tr>
		<th class="dataheader" align="left">#application.rb.getResource("searchString")#</th>
		<th class="dataheader">#application.rb.getResource("searches")#</th>
	</tr>
	
	<!--- show stats with links to detail --->
	<cfloop query="qSearches">
		<tr class="#IIF(qSearches.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
			<td>#searchString#</td>			
			<td align="center" width="75">#count_searches#</td>
		</tr>
	</cfloop>
	
	</table>
</cfif>
<p>&nbsp;</p>
</cfoutput>
</cfmail>
<cfoutput>
#application.rb.getResource("emailSent")#
</cfoutput>