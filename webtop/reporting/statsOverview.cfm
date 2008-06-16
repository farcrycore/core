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
$Header: /cvs/farcry/core/webtop/reporting/statsOverview.cfm,v 1.7 2005/08/17 03:28:39 pottery Exp $
$Author: pottery $
$Date: 2005/08/17 03:28:39 $
$Name: milestone_3-0-1 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: Displays an overview report for site activity $


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
	<cfparam name="form.dateRange" default="ww">
		
	<!--- get stats --->
	<cfscript>
		qViews = application.factory.oStats.getMostViewed(typeName='all',dateRange=#form.dateRange#,maxRows=10);
		qLocales = application.factory.oStats.getLocales(dateRange=#form.dateRange#,maxRows=10);
		qBrowsers = application.factory.oStats.getBrowsers(dateRange='#form.dateRange#',maxRows=10);
		qOS = application.factory.oStats.getOS(dateRange=#form.dateRange#,maxRows=10);
		qReferers = application.factory.oStats.getReferers(dateRange=#form.dateRange#,maxRows=10,filter="#cgi.server_name#");
		qSessions = application.factory.oStats.getsessions(dateRange=#form.dateRange#);
		qSearches = application.factory.oStats.getSearchStatsMostPopular(dateRange=#form.dateRange#,maxRows=10);
	</cfscript>
	
	<cfoutput>
	<h3>
	<cfif form.dateRange neq "all">
	<cfset subS=listToArray('#application.thisCalendar.i18nDateFormat(dateAdd("#form.dateRange#",-1,now()),session.dmProfile.locale,application.longF)#--- #application.thisCalendar.i18nDateFormat(now(),session.dmProfile.locale,application.longF)#--- #numberformat(qSessions.sessions)#','---')>
	#application.rb.formatRBString("statsOverviewReport",subS)#
	<cfelse>
	#application.rb.formatRBString("allDatesOverviewReport","#numberformat(qSessions.sessions)#")#
	</cfif> 
	</h3>

	<br />
	
	<form method="post" class="f-wrap-1 f-bg-short" action="">
		<fieldset>
		
			<label for="dateRange"><b>Date:</b>
			<select name="dateRange" id="dateRange">
			<option value="all" <cfif form.dateRange eq "all">selected="selected"</cfif>>#application.rb.getResource("allDates")#</option>
			<option value="d" <cfif form.dateRange eq "d">selected="selected"</cfif>>#application.rb.getResource("Today")#</option>
			<option value="ww" <cfif form.dateRange eq "ww">selected="selected"</cfif>>#application.rb.getResource("lastWeek")#</option>
			<option value="m" <cfif form.dateRange eq "m">selected="selected"</cfif>>#application.rb.getResource("lastMonth")#</option>
			<option value="q" <cfif form.dateRange eq "q">selected="selected"</cfif>>#application.rb.getResource("lastQuarter")#</option>
			<option value="yyyy" <cfif form.dateRange eq "yyyy">selected="selected"</cfif>>#application.rb.getResource("lastYear")#</option>
			</select><br />
			</label>
			
			<div class="f-submit-wrap">
			<input type="submit" value="#application.rb.getResource("Update")#" class="f-submit" />
			</div>
			
		</fieldset>

	</form>

	<hr />
	
	<!--- views --->
	<cfif qViews.recordcount>
	
		<h3>#application.rb.getResource("mostPopularPages")#</h3>
		
		<table class="table-3" cellspacing="0">
		<tr>
			<th style="width:33%">#application.rb.getResource("objectLC")#</th>
			<th style="width:34%">#application.rb.getResource("views")#</th>
			<th style="width:33%">#application.rb.getResource("typeLC")#</th>
		</tr>
		
		<!--- show stats with links to detail --->
		<cfloop query="qViews">
			<tr class="#IIF(qViews.currentRow MOD 2, de(""), de("alt"))#">
				<td>#title#</td>
				<td>#downloads#</td>
				<td>#typename#</td>
			</tr>
		</cfloop>
		
		</table>
	</cfif>
	
	<!--- locales --->
	<cfif qLocales.recordcount>
	
		<h3>#application.rb.getResource("mostPopularLocales")#</h3>
		
		<table class="table-3" cellspacing="0">
		<tr>
			<th style="width:33%">#application.rb.getResource("country")#</th>
			<th style="width:34%">#application.rb.getResource("language")#</th>
			<th style="width:33%">#application.rb.getResource("sessions")#</th>
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
	</cfif>
	
	<!--- browsers --->
	<cfif qBrowsers.recordcount>
		<h3>#application.rb.getResource("mostPopularBrowsers")#</h3>
		<table class="table-3" cellspacing="0">
		<tr>
			<th style="width:67%">#application.rb.getResource("Browser")#</th>
			<th style="width:33%">#application.rb.getResource("Sessions")#</th>
		</tr>
		
		<!--- show stats with links to detail --->
		<cfloop query="qBrowsers">
			<tr class="#IIF(qBrowsers.currentRow MOD 2, de(""), de("alt"))#">
				<td>#browser#</td>
				<td>#views#</td>
			</tr>
		</cfloop>
		
		</table>
	</cfif>
	
	<!--- operating systems --->
	<cfif qOs.recordcount>
		<h3>#application.rb.getResource("mostPopularOS")#</h3>
		<table class="table-3" cellspacing="0">
		<tr>
			<th style="width:67%">#application.rb.getResource("OS")#</th>
			<th style="width:33%">#application.rb.getResource("Sessions")#</th>
		</tr>
		
		<!--- show stats with links to detail --->
		<cfloop query="qOS">
			<tr class="#IIF(qOS.currentRow MOD 2, de(""), de("alt"))#">
				<td>#os#</td>
				<td>#count_os#</td>
			</tr>
		</cfloop>
		
		</table>
	</cfif>
	<p>&nbsp;</p>
	
	<!--- referers --->
	<cfif qReferers.recordcount>
		<h3>Most Popular Referers</h3>
		<table class="table-3" cellspacing="0">
		<tr>
			<th style="width:67%">#application.rb.getResource("Referer")#</th>
			<th style="width:33%">#application.rb.getResource("Referals")#</th>
		</tr>
		
		<!--- show stats with links to detail --->
		<cfloop query="qReferers">
			<tr class="#IIF(qReferers.currentRow MOD 2, de(""), de("alt"))#">
				<td><a href="#referer#" class="referer">#left(referer,60)#<cfif len(referer) gt 60>...</cfif></a></td>
				<td>#count_referers#</td>
			</tr>
		</cfloop>
		
		</table>
	</cfif>
	
	<!--- searches --->
	<cfif qSearches.recordcount>
		<h3>#application.rb.getResource("mostPopularSearches")#</h3>
		<table class="table-3" cellspacing="0">
		<tr>
			<th style="width:67%">#application.rb.getResource("searchString")#</th>
			<th style="width:33%">#application.rb.getResource("searches")#</th>
		</tr>
		
		<!--- show stats with links to detail --->
		<cfloop query="qSearches">
			<tr class="#IIF(qSearches.currentRow MOD 2, de(""), de("alt"))#">
				<td>#searchString#</td>			
				<td>#count_searches#</td>
			</tr>
		</cfloop>
		
		</table>
	</cfif>
	
	</cfoutput>
</sec:CheckPermission>

<admin:footer>

<cfsetting enablecfoutputonly="no">