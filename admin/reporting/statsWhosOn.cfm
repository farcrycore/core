<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/statsWhosOn.cfm,v 1.5 2003/09/22 03:45:38 brendan Exp $
$Author: brendan $
$Date: 2003/09/22 03:45:38 $
$Name: b201 $
$Revision: 1.5 $

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

<!--- check permissions --->
<cfscript>
	iStatsTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingStatsTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iStatsTab eq 1>

	<cfparam name="form.order" default="sessionTime">
	<cfparam name="form.orderDirection" default="asc">
	
	<!--- get stats --->
	<cfscript>
		qActive = application.factory.oStats.getActiveVisitors(order="#form.order#",orderDirection="#form.orderDirection#");
	</cfscript>
	
	<cfoutput>
	<div class="formtitle">Who's On Now</div>
		
	<cfif qActive.recordcount>
		<table cellpadding="5" cellspacing="0" border="0"  style="margin-left:30px;">
			<form action="" method="post">
			<tr>
				<td width="450">
				<!--- drop down for ordering --->
				Order By
				<select name="order">
					<option value="sessionTime" <cfif form.order eq "sessionTime">selected</cfif>>Been Active For
					<option value="lastActivity" <cfif form.order eq "lastActivity">selected</cfif>>Last Activity
					<option value="views" <cfif form.order eq "views">selected</cfif>>Views
					<option value="locale" <cfif form.order eq "locale">selected</cfif>>Locale
				</select>
				
				Order Direction
				<select name="orderDirection">
					<option value="asc" <cfif form.orderDirection eq "asc">selected</cfif>>Ascending
					<option value="desc" <cfif form.orderDirection eq "desc">selected</cfif>>Descending
				</select>
				
				<input type="submit" value="Update">
				</td>
			</tr>
			</form>
			</table>
			
		<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
		<tr>
			<th class="dataheader">IP Address</td>
			<th class="dataheader">Locale</td>
			<th class="dataheader">Been Active For</td>
			<th class="dataheader">Last Activity</td>
			<th class="dataheader">Pages Viewed</td>
			<th class="dataheader">&nbsp;</td>
		</tr>
		
		<!--- show stats with links to detail --->
		<cfloop query="qActive">
			<tr class="#IIF(qActive.currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
				<td>#qActive.remoteIP#</td>
				<td align="center"><cfif len(qActive.locale)>#qActive.locale#<cfelse>Unknown</cfif></td>
				<td align="center"><cfif qActive.sessionTime gte 1>#qActive.sessionTime# minute<cfif qActive.sessionTime gt 1>s</cfif><cfelse>< 1 minute</cfif></td>
				<td align="center"><cfif qActive.lastActivity gte 1>#qActive.lastActivity# minute<cfif qActive.lastActivity gt 1>s</cfif><cfelse>< 1 minute</cfif> ago</td>
				<td align="center">#qActive.views#</td>
				<td><a href="statsVisitorPathDetail.cfm?sessionId=#qActive.sessionId#">View Path</a></td>
			</tr>
		</cfloop>
		
		</table>
	<cfelse>
		No active visitors at this time.
	</cfif>
	</cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="no">