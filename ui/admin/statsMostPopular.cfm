<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/ui/admin/Attic/statsMostPopular.cfm,v 1.2 2003/04/28 03:30:02 brendan Exp $
$Author: brendan $
$Date: 2003/04/28 03:30:02 $
$Name: b131 $
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

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">

<admin:header>

<cfparam name="form.typeName" default="all">
<cfparam name="form.dateRange" default="all">
<cfparam name="form.maxRows" default="20">

<!--- get stats --->
<cfscript>
	oStats = createObject("component", "#application.packagepath#.farcry.stats");
	qDownloads = oStats.getMostViewed(typeName=#form.typeName#,dateRange=#form.dateRange#,maxRows=#form.maxRows#);
</cfscript>

<cfoutput>
<div class="formtitle">Most Popular Objects</div>

<cfif qDownloads.recordcount>
	<table cellpadding="5" cellspacing="0" border="0"  style="margin-left:30px;">
	<form action="" method="post">
	<tr>
		<td width="450">
		<!--- drop down for typeName --->
		Type 
		<select name="typeName">
			<cfloop collection="#application.types#" item="key">
				<option value="#key#" <cfif key eq form.typeName>selected</cfif>>#key#
			</cfloop>
			<option value="all" <cfif form.typeName eq "all">selected</cfif>>All Types
		</select>
		
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
		
		<input type="submit" value="Update">
		</td>
	</tr>
	</form>
	</table>
	
	<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
	<tr>
		<th class="dataheader">Object</td>
		<th class="dataheader">Views</td>
		<th class="dataheader">Type</td>
		<th class="dataheader">&nbsp;</td>
	</tr>
	
	<!--- show stats with links to detail --->
	<cfloop query="qDownloads">
		<tr class="#IIF(qDownloads.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
			<td>#title#</td>
			<td align="center">#downloads#</td>
			<td>#typename#</td>
			<td><a href="#application.url.farcry#/editTabStats.cfm?objectid=#objectid#">More Detail</a></td>
		</tr>
	</cfloop>
	
	</table>
<cfelse>
	No views have been logged at this time.
</cfif>
</cfoutput>

<admin:footer>

<cfsetting enablecfoutputonly="no">