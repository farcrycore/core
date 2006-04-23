<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/statsOverview.cfm,v 1.2 2003/09/20 23:58:51 brendan Exp $
$Author: brendan $
$Date: 2003/09/20 23:58:51 $
$Name: b201 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Displays an overview report for site activity $
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
	<div class="formtitle">Statistics Overview Report - <cfif form.dateRange neq "all">#dateformat(dateAdd("#form.dateRange#",-1,now()),"dd-mmm-yyyy")# to #dateFormat(now(),"dd-mmm-yyyy")#<cfelse>All dates</cfif> (#numberformat(qSessions.sessions)# sessions)</div>
	
	<table cellpadding="5" cellspacing="0" border="0" style="margin-left:30px;">
	<form action="" method="post">
	<tr>
		<td width="450">
		<!--- drop down for date --->
		Date
		<select name="dateRange">
			<option value="all" <cfif form.dateRange eq "all">selected</cfif>>All Dates
			<option value="d" <cfif form.dateRange eq "d">selected</cfif>>Today
			<option value="ww" <cfif form.dateRange eq "ww">selected</cfif>>Last Week
			<option value="m" <cfif form.dateRange eq "m">selected</cfif>>Last Month
			<option value="q" <cfif form.dateRange eq "q">selected</cfif>>Last Quarter
			<option value="yyyy" <cfif form.dateRange eq "yyyy">selected</cfif>>Last Year
		</select>
		
		<input type="submit" value="Update">
		</td>
	</tr>
	</form>
	</table>
	<p></p>
	
	<!--- views --->
	<cfif qViews.recordcount>
		<div class="formtitle" style="margin-left:30px;padding-bottom:5px;">Most Popular Pages</div>
		<table cellpadding="5" cellspacing="0" border="1" width="500" style="margin-left:30px;">
		<tr>
			<th class="dataheader" align="left">Object</td>
			<th class="dataheader">Views</td>
			<th class="dataheader">Type</td>
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
		<div class="formtitle" style="margin-left:30px;padding-bottom:5px;">Most Popular Locales</div>
		<table cellpadding="5" cellspacing="0" border="1" width="500" style="margin-left:30px;">
		<tr>
			<th class="dataheader" align="left">Country</td>
			<th class="dataheader">Language</td>
			<th class="dataheader">Sessions</td>
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
		<div class="formtitle" style="margin-left:30px;padding-bottom:5px;">Most Popular Browsers</div>
		<table cellpadding="5" cellspacing="0" border="1" width="500" style="margin-left:30px;">
		<tr>
			<th class="dataheader" align="left">Browser</td>
			<th class="dataheader">Sessions</td>
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
		<div class="formtitle" style="margin-left:30px;padding-bottom:5px;">Most Popular Operating Systems</div>
		<table cellpadding="5" cellspacing="0" border="1" width="500" style="margin-left:30px;">
		<tr>
			<th class="dataheader" align="left">Operating System</td>
			<th class="dataheader">Sessions</td>
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
		<div class="formtitle" style="margin-left:30px;padding-bottom:5px;">Most Popular Referers</div>
		<table cellpadding="5" cellspacing="0" border="1" width="500" style="margin-left:30px;">
		<tr>
			<th class="dataheader" align="left">Referer</td>
			<th class="dataheader">Referals</td>
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
		<div class="formtitle" style="margin-left:30px;padding-bottom:5px;">Most Popular Searches</div>
		<table cellpadding="5" cellspacing="0" border="1" width="500" style="margin-left:30px;">
		<tr>
			<th class="dataheader" align="left">Search String</td>
			<th class="dataheader">Searches</td>
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

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="no">