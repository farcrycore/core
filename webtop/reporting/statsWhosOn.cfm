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
$Header: /cvs/farcry/core/webtop/reporting/statsWhosOn.cfm,v 1.10 2005/08/17 03:28:39 pottery Exp $
$Author: pottery $
$Date: 2005/08/17 03:28:39 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: Displays a listing for who's currently on the website$

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
	<cfparam name="form.order" default="sessionTime">
	<cfparam name="form.orderDirection" default="asc">
	
	<!--- get stats --->
	<cfscript>
		qActive = application.factory.oStats.getActiveVisitors(order="#form.order#",orderDirection="#form.orderDirection#");
	</cfscript>
	
	<cfoutput>
		
	<cfif qActive.recordcount>

			<form method="post" class="f-wrap-1 f-bg-short" action="">
			<fieldset>

				<h3>#application.rb.getResource("whoOnNow")#</h3>
				
				<label for="order">
				<!--- drop down for ordering --->
				<b>#application.rb.getResource("orderBy")#</b>
				<select name="order" id="order">
					<option value="sessionTime" <cfif form.order eq "sessionTime">selected="selected"</cfif>>#application.rb.getResource("beenActiveFor")#</option>
					<option value="lastActivity" <cfif form.order eq "lastActivity">selected="selected"</cfif>>#application.rb.getResource("lastActivity")#</option>
					<option value="views" <cfif form.order eq "views">selected="selected"</cfif>>#application.rb.getResource("views")#</option>
					<option value="locale" <cfif form.order eq "locale">selected="selected"</cfif>>#application.rb.getResource("Locale")#</option>
				</select><br />
				</label>
				
				<label for="orderDirection">
				<b>#application.rb.getResource("orderDirection")#</b>
				<select name="orderDirection" id="orderDirection">
					<option value="asc" <cfif form.orderDirection eq "asc">selected="selected"</cfif>>#application.rb.getResource("ascending")#</option>
					<option value="desc" <cfif form.orderDirection eq "desc">selected="selected"</cfif>>#application.rb.getResource("descending")#</option>
				</select><br />
				</label>
				
				<div class="f-submit-wrap">
				<input type="submit" value="#application.rb.getResource("Update")#" class="f-submit" />
				</div>

			</fieldset>
			</form>

		<hr />
		
		<table cellspacing="0">
		<tr>
			<th>#application.rb.getResource("ipAddress")#</th>
			<th>#application.rb.getResource("Locale")#</th>
			<th>#application.rb.getResource("beenActiveFor")#</th>
			<th>#application.rb.getResource("lastActivity")#</th>
			<th>#application.rb.getResource("pagesViewed")#</th>
			<th>&nbsp;</td>
		</tr>
		
		<!--- show stats with links to detail --->
		<cfloop query="qActive">
			<tr class="#IIF(qActive.currentrow MOD 2, de(""), de("alt"))#">
				<td>#qActive.remoteIP#</td>
				<td><cfif len(qActive.locale)>#qActive.locale#<cfelse>#application.rb.getResource("Unknown")#</cfif></td>
				<td>
				<cfif qActive.sessionTime gte 1>
				#application.rb.formatRBString("sessionMinutes","#qActive.sessionTime#")# 
				<cfelse>
				#application.rb.getResource("sessionLTMinute")#
				</cfif>
				</td>
				<td>
				<cfif qActive.lastActivity gte 1>
				#application.rb.formatRBString("sessionMinutes","#qActive.lastActivity#")# 
				<cfelse>
				#application.rb.getResource("sessionLTMinute")#
				</cfif> </td>
				<td>#qActive.views#</td>
				<td><a href="statsVisitorPathDetail.cfm?sessionId=#qActive.sessionId#">#application.rb.getResource("viewPath")#</a></td>
			</tr>
		</cfloop>
		
		</table>
	<cfelse>
		<h3>#application.rb.getResource("noActiveVisitorsNow")#</h3>
	</cfif>
	</cfoutput>
</sec:CheckPermission>

<admin:footer>

<cfsetting enablecfoutputonly="no">