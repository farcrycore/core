<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/statsGoogle.cfm,v 1.2 2004/07/15 01:51:48 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:51:48 $
$Name: milestone_2-3-2 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Displays summary stats for google referers$
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
	<cfparam name="form.dateRange" default="all">
	<cfparam name="form.maxRows" default="20">
	
	<!--- get stats --->
	<cfscript>
		qGoogle = application.factory.oStats.getGoogleStats(dateRange=#form.dateRange#,maxRows=#form.maxRows#);
	</cfscript>
	
	<cfoutput>
	<div class="formtitle">#application.adminBundle[session.dmProfile.locale].googleKeyWords#</div>
	
	<cfif qGoogle.recordcount>
		<table>
		<tr>
			<td valign="top" nowrap>
				<table cellpadding="5" cellspacing="0" border="0"  style="margin-left:30px;">
				<form action="" method="post">
				<tr>
					<td nowrap>			
					<!--- drop down for date --->
					#application.adminBundle[session.dmProfile.locale].Date#
					<select name="dateRange">
						<option value="all" <cfif form.dateRange eq "all">selected</cfif>>#application.adminBundle[session.dmProfile.locale].allDates#
						<option value="d" <cfif form.dateRange eq "d">selected</cfif>>#application.adminBundle[session.dmProfile.locale].today#
						<option value="ww" <cfif form.dateRange eq "ww">selected</cfif>>#application.adminBundle[session.dmProfile.locale].lastWeek#
						<option value="m" <cfif form.dateRange eq "m">selected</cfif>>#application.adminBundle[session.dmProfile.locale].lastMonth#
						<option value="q" <cfif form.dateRange eq "q">selected</cfif>>#application.adminBundle[session.dmProfile.locale].lastQuarter#
						<option value="yyyy" <cfif form.dateRange eq "yyyy">selected</cfif>>#application.adminBundle[session.dmProfile.locale].lastYear#
					</select>
					
					<!--- drop down for max rows --->
					#application.adminBundle[session.dmProfile.locale].rows#
					<select name="maxRows">
						<option value="all" <cfif form.maxRows eq "all">selected</cfif>>#application.adminBundle[session.dmProfile.locale].allRows#
						<cfloop from="10" to="200" step=10 index="rows">
							<option value="#rows#" <cfif rows eq form.maxRows>selected</cfif>>#rows#
						</cfloop>
					</select>
					
					<input type="submit" value="#application.adminBundle[session.dmProfile.locale].update#">
					</td>
				</tr>
				</form>
				</table>
				
				<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
				<tr>
					<th class="dataheader">#application.adminBundle[session.dmProfile.locale].keyWords#</td>
					<th class="dataheader">#application.adminBundle[session.dmProfile.locale].Referals#</td>
				</tr>
				
				<!--- show stats with links to search page --->
				<cfloop query="qGoogle">
					<tr class="#IIF(qGoogle.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
						<td><a href="#referer#" class="referer">#keywords#</a></td>
						<td align="center">#referals#</td>				
					</tr>
				</cfloop>
				
				</table>
			</td>
		</tr>
		</table>
	<cfelse>
		#application.adminBundle[session.dmProfile.locale].noSearchesNow#
	</cfif>
	</cfoutput>
	
<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="no">