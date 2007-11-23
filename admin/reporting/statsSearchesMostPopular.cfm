<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/reporting/statsSearchesMostPopular.cfm,v 1.5 2005/08/17 03:28:39 pottery Exp $
$Author: pottery $
$Date: 2005/08/17 03:28:39 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: Displays summary stats for the most popular site searches$


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
	<cfparam name="form.typeName" default="all">
	<cfparam name="form.dateRange" default="all">
	<cfparam name="form.maxRows" default="20">
	
	<!--- get stats --->
	<cfscript>
		qSearches = application.factory.oStats.getSearchStatsMostPopular(dateRange=#form.dateRange#,maxRows=#form.maxRows#);
	</cfscript>
	
	<cfoutput>
	
	<cfif qSearches.recordcount>

				<form method="post" class="f-wrap-1 f-bg-short" action="">
				<fieldset>
					
					<h3>#application.adminBundle[session.dmProfile.locale].mostPopularSiteSearches#</h3>

					<label for="dateRange">
					<!--- drop down for date --->
					<b>#application.adminBundle[session.dmProfile.locale].Date#</b>
					<select name="dateRange" id="dateRange">
						<option value="all" <cfif form.dateRange eq "all">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].allDates#</option>
						<option value="d" <cfif form.dateRange eq "d">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].Today#</option>
						<option value="ww" <cfif form.dateRange eq "ww">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].lastWeek#</option>
						<option value="m" <cfif form.dateRange eq "m">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].lastMonth#</option>
						<option value="q" <cfif form.dateRange eq "q">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].lastQuarter#</option>
						<option value="yyyy" <cfif form.dateRange eq "yyyy">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].lastYear#</option>
					</select><br />
					</label>
					
					<label for="maxRows">
					<!--- drop down for max rows --->
					<b>#application.adminBundle[session.dmProfile.locale].Rows#</b>
					<select name="maxRows" id="maxRows">
						<option value="all" <cfif form.maxRows eq "all">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].allRows#</option>
						<cfloop from="10" to="200" step=10 index="rows">
							<option value="#rows#" <cfif rows eq form.maxRows>selected="selected"</cfif>>#rows#</option>
						</cfloop>
					</select><br />
					</label>
					
					<div class="f-submit-wrap">
					<input type="submit" value="#application.adminBundle[session.dmProfile.locale].Update#" class="f-submit" />
					</div>
					
				</fieldset>
				</form>

				<hr />
				
				<table class="table-3" cellspacing="0">
				<tr>
					<th>#application.adminBundle[session.dmProfile.locale].searchString#</th>
					<th>#application.adminBundle[session.dmProfile.locale].searchNumbers#</th>
				</tr>
				
				<!--- show stats with links to detail --->
				<cfloop query="qSearches">
					<tr class="#IIF(qSearches.currentRow MOD 2, de(""), de("alt"))#">
						<td>#searchString#</td>			
						<td>#count_searches#</td>
					</tr>
				</cfloop>
				
				</table>

	<cfelse>
		<h3>#application.adminBundle[session.dmProfile.locale].noZeroResultSearches#</h3>
	</cfif>
	</cfoutput>
</sec:CheckPermission>

<admin:footer>

<cfsetting enablecfoutputonly="no">