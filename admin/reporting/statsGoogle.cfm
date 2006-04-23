<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/statsGoogle.cfm,v 1.1 2004/01/07 23:30:17 brendan Exp $
$Author: brendan $
$Date: 2004/01/07 23:30:17 $
$Name: milestone_2-2-1 $
$Revision: 1.1 $

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

<!--- check permissions --->
<cfscript>
	iStatsTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingStatsTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iStatsTab eq 1>
	<cfparam name="form.dateRange" default="all">
	<cfparam name="form.maxRows" default="20">
	
	<!--- get stats --->
	<cfscript>
		qGoogle = application.factory.oStats.getGoogleStats(dateRange=#form.dateRange#,maxRows=#form.maxRows#);
	</cfscript>
	
	<cfoutput>
	<div class="formtitle">Google Key Words</div>
	
	<cfif qGoogle.recordcount>
		<table>
		<tr>
			<td valign="top" nowrap>
				<table cellpadding="5" cellspacing="0" border="0"  style="margin-left:30px;">
				<form action="" method="post">
				<tr>
					<td nowrap>			
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
					
					<!--- drop down for max rows --->
					Rows
					<select name="maxRows">
						<option value="all" <cfif form.maxRows eq "all">selected</cfif>>All Rows
						<cfloop from="10" to="200" step=10 index="rows">
							<option value="#rows#" <cfif rows eq form.maxRows>selected</cfif>>#rows#
						</cfloop>
					</select>
					
					<input type="submit" value="Update">
					</td>
				</tr>
				</form>
				</table>
				
				<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
				<tr>
					<th class="dataheader">Key Word(s)</td>
					<th class="dataheader">Referals</td>
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
		No searches have been logged at this time.
	</cfif>
	</cfoutput>
	
<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="no">