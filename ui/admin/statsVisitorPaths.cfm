<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/ui/admin/Attic/statsVisitorPaths.cfm,v 1.3 2003/04/29 00:47:26 brendan Exp $
$Author: brendan $
$Date: 2003/04/29 00:47:26 $
$Name: b131 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: Displays stats for visitors objects$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">

<admin:header>

<cfparam name="form.remoteIP" default="all">
<cfif form.remoteIP eq "">
	<cfset form.remoteIP = "all">
</cfif>
<cfparam name="form.dateRange" default="all">
<cfparam name="form.maxRows" default="20">

<!--- get stats --->
<cfscript>
	oStats = createObject("component", "#application.packagepath#.farcry.stats");
	qVisitors = oStats.getVisitors(dateRange=#form.dateRange#,maxRows=#form.maxRows#,remoteIP='#form.remoteIP#');
</cfscript>

<cfoutput>
<div class="formtitle">Recent Visitors</div>

<cfif qVisitors.recordcount>
	<table cellpadding="5" cellspacing="0" border="0"  style="margin-left:30px;">
	<form action="" method="post">
	<tr>
		<td width="450">
		<!--- drop down for date --->
		Date
		<select name="dateRange">
			<option value="d" <cfif form.dateRange eq "d">selected</cfif>>Today
			<option value="ww" <cfif form.dateRange eq "ww">selected</cfif>>Last Week
			<option value="m" <cfif form.dateRange eq "m">selected</cfif>>Last Month
			<option value="q" <cfif form.dateRange eq "q">selected</cfif>>Last Quarter
			<option value="yyyy" <cfif form.dateRange eq "yyyy">selected</cfif>>Last Year
			<option value="all" <cfif form.dateRange eq "all">selected</cfif>>All Dates
		</select>
		
		<!--- drop down for max rows --->
		Rows
		<select name="maxRows">
			<cfloop from="10" to="200" step=10 index="rows">
				<option value="#rows#" <cfif rows eq form.maxRows>selected</cfif>>#rows#
			</cfloop>
			<option value="all" <cfif form.maxRows eq "all">selected</cfif>>All Rows
		</select>
		
		IP <input type="text" name="remoteIP"> 
		<input type="submit" value="Update">
		</td>
	</tr>
	</form>
	</table>
	
	<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
	<tr>
		<th class="dataheader">IP Address</td>
		<th class="dataheader">Viewed</td>
		<th class="dataheader">Pages Viewed</td>
		<th class="dataheader">&nbsp;</td>
	</tr>
	
	<!--- show stats with links to detail --->
	<cfloop query="qVisitors">
		<tr class="#IIF(qVisitors.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
			<td>#remoteIP#</td>
			<td align="center">#dateformat(startDate,"dd-mmm-yyyy")#</td>
			<td align="center">#Views#</td>
			<td><a href="StatsVisitorPathDetail.cfm?sessionId=#sessionID#">View Path</a></td>
		</tr>
	</cfloop>
	
	</table>
<cfelse>
	No visitors have been logged at this time.
</cfif>
</cfoutput>

<admin:footer>

<cfsetting enablecfoutputonly="no">