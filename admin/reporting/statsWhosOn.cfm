<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/statsWhosOn.cfm,v 1.6 2004/07/15 01:51:48 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:51:48 $
$Name: milestone_2-3-2 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: Displays a listing for who's currently on the website$
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

	<cfparam name="form.order" default="sessionTime">
	<cfparam name="form.orderDirection" default="asc">
	
	<!--- get stats --->
	<cfscript>
		qActive = application.factory.oStats.getActiveVisitors(order="#form.order#",orderDirection="#form.orderDirection#");
	</cfscript>
	
	<cfoutput>
	<div class="formtitle">#application.adminBundle[session.dmProfile.locale].whoOnNow#</div>
		
	<cfif qActive.recordcount>
		<table cellpadding="5" cellspacing="0" border="0"  style="margin-left:30px;">
			<form action="" method="post">
			<tr>
				<td width="450">
				<!--- drop down for ordering --->
				#application.adminBundle[session.dmProfile.locale].orderBy#
				<select name="order">
					<option value="sessionTime" <cfif form.order eq "sessionTime">selected</cfif>>#application.adminBundle[session.dmProfile.locale].beenActiveFor#
					<option value="lastActivity" <cfif form.order eq "lastActivity">selected</cfif>>#application.adminBundle[session.dmProfile.locale].lastActivity#
					<option value="views" <cfif form.order eq "views">selected</cfif>>#application.adminBundle[session.dmProfile.locale].views#
					<option value="locale" <cfif form.order eq "locale">selected</cfif>>#application.adminBundle[session.dmProfile.locale].Locale#
				</select>
				
				#application.adminBundle[session.dmProfile.locale].orderDirection#
				<select name="orderDirection">
					<option value="asc" <cfif form.orderDirection eq "asc">selected</cfif>>#application.adminBundle[session.dmProfile.locale].ascending#
					<option value="desc" <cfif form.orderDirection eq "desc">selected</cfif>>#application.adminBundle[session.dmProfile.locale].descending#
				</select>
				
				<input type="submit" value="#application.adminBundle[session.dmProfile.locale].Update#">
				</td>
			</tr>
			</form>
			</table>
			
		<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
		<tr>
			<th class="dataheader">#application.adminBundle[session.dmProfile.locale].ipAddress#</td>
			<th class="dataheader">#application.adminBundle[session.dmProfile.locale].Locale#</td>
			<th class="dataheader">#application.adminBundle[session.dmProfile.locale].beenActiveFor#</td>
			<th class="dataheader">#application.adminBundle[session.dmProfile.locale].lastActivity#</td>
			<th class="dataheader">#application.adminBundle[session.dmProfile.locale].pagesViewed#</td>
			<th class="dataheader">&nbsp;</td>
		</tr>
		
		<!--- show stats with links to detail --->
		<cfloop query="qActive">
			<tr class="#IIF(qActive.currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
				<td>#qActive.remoteIP#</td>
				<td align="center"><cfif len(qActive.locale)>#qActive.locale#<cfelse>#application.adminBundle[session.dmProfile.locale].Unknown#</cfif></td>
				<td align="center">
				<cfif qActive.sessionTime gte 1>
				#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].sessionMinutes,"#qActive.sessionTime#")# 
				<cfelse>
				#application.adminBundle[session.dmProfile.locale].sessionLTMinute#
				</cfif>
				</td>
				<td align="center">
				<cfif qActive.lastActivity gte 1>
				#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].sessionMinutes,"#qActive.lastActivity#")# 
				<cfelse>
				#application.adminBundle[session.dmProfile.locale].sessionLTMinute#
				</cfif> </td>
				<td align="center">#qActive.views#</td>
				<td><a href="statsVisitorPathDetail.cfm?sessionId=#qActive.sessionId#">#application.adminBundle[session.dmProfile.locale].viewPath#</a></td>
			</tr>
		</cfloop>
		
		</table>
	<cfelse>
		#application.adminBundle[session.dmProfile.locale].noActiveVisitorsNow#
	</cfif>
	</cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="no">