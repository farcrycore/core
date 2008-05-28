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
$Header: /cvs/farcry/core/webtop/reporting/statsGoogle.cfm,v 1.5 2005/08/17 03:28:39 pottery Exp $
$Author: pottery $
$Date: 2005/08/17 03:28:39 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: Displays summary stats for google referers$


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
	<cfparam name="form.dateRange" default="all">
	<cfparam name="form.maxRows" default="20">
	
	<!--- get stats --->
	<cfscript>
		qGoogle = application.factory.oStats.getGoogleStats(dateRange=#form.dateRange#,maxRows=#form.maxRows#);
	</cfscript>
	
	<cfoutput>
	
	<cfif qGoogle.recordcount>

				<form method="post" class="f-wrap-1 f-bg-short" action="">
				<fieldset>

					<h3>#application.rb.getResource("googleKeyWords")#</h3>
					
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
					<b>#application.rb.getResource("rows")#</b>
					<select name="maxRows" id="maxRows">
						<option value="all" <cfif form.maxRows eq "all">selected="selected"</cfif>>#application.rb.getResource("allRows")#</option>
						<cfloop from="10" to="200" step=10 index="rows">
							<option value="#rows#" <cfif rows eq form.maxRows>selected="selected"</cfif>>#rows#</option>
						</cfloop>
					</select><br />
					<label>
					
					<div class="f-submit-wrap">
					<input type="submit" value="#application.rb.getResource("update")#" class="f-submit" />
					</div>
					
				</fieldset>
				</form>

				
				<table class="table-3" cellspacing="0">
				<tr>
					<th>#application.rb.getResource("keyWords")#</th>
					<th>#application.rb.getResource("Referals")#</th>
				</tr>
				
				<!--- show stats with links to search page --->
				<cfloop query="qGoogle">
					<tr class="#IIF(qGoogle.currentRow MOD 2, de(""), de("alt"))#">
						<td><a href="#referer#" class="referer">#keywords#</a></td>
						<td>#referals#</td>				
					</tr>
				</cfloop>
				
				</table>

	<cfelse>
		<h3>#application.rb.getResource("noSearchesNow")#</h3>
	</cfif>
	</cfoutput>
</sec:CheckPermission>

<admin:footer>

<cfsetting enablecfoutputonly="no">