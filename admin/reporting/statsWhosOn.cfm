<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/reporting/statsWhosOn.cfm,v 1.10 2005/08/17 03:28:39 pottery Exp $
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

<sec:restricted permission="ReportingStatsTab">
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

				<h3>#application.adminBundle[session.dmProfile.locale].whoOnNow#</h3>
				
				<label for="order">
				<!--- drop down for ordering --->
				<b>#application.adminBundle[session.dmProfile.locale].orderBy#</b>
				<select name="order" id="order">
					<option value="sessionTime" <cfif form.order eq "sessionTime">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].beenActiveFor#</option>
					<option value="lastActivity" <cfif form.order eq "lastActivity">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].lastActivity#</option>
					<option value="views" <cfif form.order eq "views">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].views#</option>
					<option value="locale" <cfif form.order eq "locale">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].Locale#</option>
				</select><br />
				</label>
				
				<label for="orderDirection">
				<b>#application.adminBundle[session.dmProfile.locale].orderDirection#</b>
				<select name="orderDirection" id="orderDirection">
					<option value="asc" <cfif form.orderDirection eq "asc">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].ascending#</option>
					<option value="desc" <cfif form.orderDirection eq "desc">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].descending#</option>
				</select><br />
				</label>
				
				<div class="f-submit-wrap">
				<input type="submit" value="#application.adminBundle[session.dmProfile.locale].Update#" class="f-submit" />
				</div>

			</fieldset>
			</form>

		<hr />
		
		<table cellspacing="0">
		<tr>
			<th>#application.adminBundle[session.dmProfile.locale].ipAddress#</th>
			<th>#application.adminBundle[session.dmProfile.locale].Locale#</th>
			<th>#application.adminBundle[session.dmProfile.locale].beenActiveFor#</th>
			<th>#application.adminBundle[session.dmProfile.locale].lastActivity#</th>
			<th>#application.adminBundle[session.dmProfile.locale].pagesViewed#</th>
			<th>&nbsp;</td>
		</tr>
		
		<!--- show stats with links to detail --->
		<cfloop query="qActive">
			<tr class="#IIF(qActive.currentrow MOD 2, de(""), de("alt"))#">
				<td>#qActive.remoteIP#</td>
				<td><cfif len(qActive.locale)>#qActive.locale#<cfelse>#application.adminBundle[session.dmProfile.locale].Unknown#</cfif></td>
				<td>
				<cfif qActive.sessionTime gte 1>
				#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].sessionMinutes,"#qActive.sessionTime#")# 
				<cfelse>
				#application.adminBundle[session.dmProfile.locale].sessionLTMinute#
				</cfif>
				</td>
				<td>
				<cfif qActive.lastActivity gte 1>
				#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].sessionMinutes,"#qActive.lastActivity#")# 
				<cfelse>
				#application.adminBundle[session.dmProfile.locale].sessionLTMinute#
				</cfif> </td>
				<td>#qActive.views#</td>
				<td><a href="statsVisitorPathDetail.cfm?sessionId=#qActive.sessionId#">#application.adminBundle[session.dmProfile.locale].viewPath#</a></td>
			</tr>
		</cfloop>
		
		</table>
	<cfelse>
		<h3>#application.adminBundle[session.dmProfile.locale].noActiveVisitorsNow#</h3>
	</cfif>
	</cfoutput>
</sec:restricted>

<admin:footer>

<cfsetting enablecfoutputonly="no">