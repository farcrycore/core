<!--- @@displayname: Statistics Overview Report --->

<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/scheduledTasks/statsOverviewReport.cfm,v 1.3 2004/05/04 22:54:32 brendan Exp $
$Author: brendan $
$Date: 2004/05/04 22:54:32 $
$Name: milestone_2-2-1 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: Emails an overview report for site activity $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: dateRange - day (d) or week (ww) or month (mm) or quarter (q) or year (yyyy)$
$in: emailTo - emailaddress(s) for report to be sent to$
$out:$
--->

<!--- work out parameters --->
<cfsetting requestTimeout="600">

<cfparam name="url.dateRange" default="ww">
<cfparam name="url.emailTo" default="brendan@daemon.com.au">
	
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

<cfmail to="#url.emailTo#" from="#application.config.general.adminEmail#" subject="#application.config.general.siteTitle# Statistics Report" type="HTML">
<style >
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

<div class="formtitle">Statistics Overview Report - <cfif dateRange neq "all">#dateformat(dateAdd("#dateRange#",-1,now()),"dd-mmm-yyyy")# to #dateFormat(now(),"dd-mmm-yyyy")#<cfelse>All dates</cfif> (#numberformat(qSessions.sessions)# sessions)</div>

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

</cfmail>

<cfoutput>Email sent</cfoutput>