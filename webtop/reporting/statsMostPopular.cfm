<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/reporting/statsMostPopular.cfm,v 1.8 2005/08/17 03:28:39 pottery Exp $
$Author: pottery $
$Date: 2005/08/17 03:28:39 $
$Name: milestone_3-0-1 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: Displays summary stats for viewed objects, filter by type,date,maxRows. Click through for graphs$


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
		qDownloads = application.factory.oStats.getMostViewed(typeName=#form.typeName#,dateRange=#form.dateRange#,maxRows=#form.maxRows#);
	</cfscript>
	
	<cfoutput>
	
	
	<cfif qDownloads.recordcount>
		
		<form action="" method="post" class="f-wrap-1 f-bg-short">
		
			<fieldset>
			
			<h3>#application.adminBundle[session.dmProfile.locale].mostPopularObj#</h3>
			
			<label for="typeName">
			<!--- drop down for typeName --->
			<b>#application.adminBundle[session.dmProfile.locale].typeLC#</b>
			<select name="typeName" id="typeName">
				<option value="all" <cfif form.typeName eq "all">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].allTypes#</option>
				<!--- sort structure by Key name --->
				<cfset listofKeys = structKeyList(application.types)>
				<cfset listofKeys = listsort(listofkeys,"textnocase")>
				<cfloop list="#listofKeys#" index="key">
					<option value="#key#" <cfif key eq form.typeName>selected="selected"</cfif>>#key#</option>
				</cfloop>
			</select><br />
			</label>
			
			<label for="dateRange">
			<!--- drop down for date --->
			<b>#application.adminBundle[session.dmProfile.locale].date#</b>
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
			<b>#application.adminBundle[session.dmProfile.locale].rows#</b>
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
			<th>#application.adminBundle[session.dmProfile.locale].objectLC#</th>
			<th>#application.adminBundle[session.dmProfile.locale].views#</th>
			<th>#application.adminBundle[session.dmProfile.locale].typeLC#</th>
			<th>&nbsp;</th>
		</tr>
		
		<!--- show stats with links to detail --->
		<cfloop query="qDownloads">
			<tr class="#IIF(qDownloads.currentRow MOD 2, de(""), de("alt"))#">
				<td>#title#</td>
				<td>#downloads#</td>
				<td>#typename#</td>
				<td><a href="#application.url.farcry#/edittabStats.cfm?objectid=#objectid#">#application.adminBundle[session.dmProfile.locale].moreDetail#</a></td>
			</tr>
		</cfloop>
		
		</table>
	<cfelse>
		<h3>#application.adminBundle[session.dmProfile.locale].noViewsNow#</h3>
	</cfif>
	</cfoutput>
</sec:CheckPermission>

<admin:footer>

<cfsetting enablecfoutputonly="no">