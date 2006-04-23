<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/statsSearchesNoResults.cfm,v 1.2 2004/07/15 01:51:48 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:51:48 $
$Name: milestone_2-3-2 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Displays summary stats for searches that return no results$
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
	<cfparam name="form.typeName" default="all">
	<cfparam name="form.dateRange" default="all">
	<cfparam name="form.maxRows" default="20">
	
	<!--- get stats --->
	<cfscript>
		qSearches = application.factory.oStats.getSearchStatsNoResults(dateRange=#form.dateRange#,maxRows=#form.maxRows#);
	</cfscript>
	
	<cfoutput>
	<div class="formtitle">#application.adminBundle[session.dmProfile.locale].noResultSiteSearches#</div>
	
	<cfif qSearches.recordcount>
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
						<option value="d" <cfif form.dateRange eq "d">selected</cfif>>#application.adminBundle[session.dmProfile.locale].Today#
						<option value="ww" <cfif form.dateRange eq "ww">selected</cfif>>#application.adminBundle[session.dmProfile.locale].lastWeek#
						<option value="m" <cfif form.dateRange eq "m">selected</cfif>>#application.adminBundle[session.dmProfile.locale].lastMonth#
						<option value="q" <cfif form.dateRange eq "q">selected</cfif>>#application.adminBundle[session.dmProfile.locale].lastQuarter#
						<option value="yyyy" <cfif form.dateRange eq "yyyy">selected</cfif>>#application.adminBundle[session.dmProfile.locale].lastYear#
					</select>
					
					<!--- drop down for max rows --->
					#application.adminBundle[session.dmProfile.locale].Rows#
					<select name="maxRows">
						<option value="all" <cfif form.maxRows eq "all">selected</cfif>>#application.adminBundle[session.dmProfile.locale].allRows#
						<cfloop from="10" to="200" step=10 index="rows">
							<option value="#rows#" <cfif rows eq form.maxRows>selected</cfif>>#rows#
						</cfloop>
					</select>
			
					<input type="submit" value="#application.adminBundle[session.dmProfile.locale].Update#">
					</td>
				</tr>
				</form>
				</table>
				
				<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
				<tr>
					<th class="dataheader">#application.adminBundle[session.dmProfile.locale].searchString#</td>
					<th class="dataheader">#application.adminBundle[session.dmProfile.locale].searchNumbers#</td>
				</tr>
				
				<!--- show stats with links to detail --->
				<cfloop query="qSearches">
					<tr class="#IIF(qSearches.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
						<td>#searchString#</td>			
						<td align="center">#count_searches#</td>
					</tr>
				</cfloop>
				
				</table>
			</td>
		</tr>
		</table>
	<cfelse>
		#application.adminBundle[session.dmProfile.locale].noZeroResultSearches#
	</cfif>
	</cfoutput>
	
<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="no">