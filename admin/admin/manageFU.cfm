<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/manageFU.cfm,v 1.6 2005/09/15 01:15:46 guy Exp $
$Author: guy $
$Date: 2005/09/15 01:15:46 $
$Name: milestone_3-0-1 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: Manage existing FU entries$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes" requestTimeOut="1000">

<cfprocessingDirective pageencoding="utf-8">

<cfparam name="form.searchIn" default="">
<cfparam name="form.searchText" default="">

<!--- check permissions --->
<cfscript>
	iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iGeneralTab eq 1>
	<cfset objFU = createObject("component","#application.packagepath#.farcry.FU")>
	
	<!--- check if items have been marked for deletion --->
	<cfif isDefined("form.lMappings") and len(form.lMappings)>
		<!--- loop over marked items --->
		<cfloop list="#form.lMappings#" index="i">
			<!--- delete fu --->
			<cfset objFU.deleteMapping(i)>
		</cfloop>
		<!--- update fu mappings in app scope --->
		<!--- <cfset objFU.updateAppScope()> --->
	</cfif>
	
	<cfoutput>
	<!--- show filter form --->
	
	<form method="post" class="f-wrap-1 f-bg-short" action="">
	<fieldset>
	
		<h3>#application.adminBundle[session.dmProfile.locale].manageURLs#</h3>

		<label for="searchIn"><b>&nbsp;</b>
		<select name="searchIn" id="searchIn">
		<option value="#application.adminBundle[session.dmProfile.locale].alias#" <cfif form.searchIn eq "mapping">selected</cfif>>#application.adminBundle[session.dmProfile.locale].alias#
		<option value="#application.adminBundle[session.dmProfile.locale].objectLC#" <cfif form.searchIn eq "object">selected</cfif>>#application.adminBundle[session.dmProfile.locale].objectLC#
		</select>
		<br />
		</label>
		
		<label for="searchText"><b>&nbsp;</b>
		<input type="text" name="searchText" id="searchText" value="#form.searchText#" />	
		</label>
		
		<div class="f-submit-wrap">
		<input type="submit" value="#application.adminBundle[session.dmProfile.locale].filter#" class="f-submit" />
		</div>
		
	</fieldset>
	</form>

	<form method="post" action="">				
	<!--- set up results table --->
	<table class="table-2" cellspacing="0">
	<tr>
		<th style="text-align:center">#application.adminBundle[session.dmProfile.locale].delete#</th>
		<th>#application.adminBundle[session.dmProfile.locale].alias#</th>
		<th>#application.adminBundle[session.dmProfile.locale].objectLC#</th>
	</tr>
	</cfoutput>

	<!--- check mappings are loaded --->
	<cfif isDefined("application.fu.mappings")>
		<!--- loop over mappings --->
		<cfloop collection="#application.fu.mappings#" item="key">
			<!--- check if filter has been entered --->
			<cfif len(form.searchText)>
				<!--- check filter against mapping --->
				<cfif form.searchIn eq "mapping" and findNoCase(form.searchText,key)>
					<cfset bShow = 1>
				<!--- check filter against object --->
				<cfelseIf form.searchIn eq "object" and findNoCase(form.searchText,application.fu.mappings[key])>
					<cfset bShow = 1>
				<cfelse>
					<!--- no match so don't show --->
					<cfset bShow = 0>
				</cfif>
			<cfelse>
				<!--- show all --->
				<cfset bShow = 1>
			</cfif>
			<cfif bShow>
				<cfoutput>
					<tr>
						<td style="text-align:center"><input type="checkbox" name="lMappings" value="#key#" /></td>
						<td>#key#</td>
						<td>#application.url.conjurer#?objectid=#application.fu.mappings[key].refObjectID#<cfif application.fu.mappings[key].query_string NEQ "">&#application.fu.mappings[key].query_string#</cfif></td>
					</tr>
				</cfoutput>
			</cfif>
		</cfloop>
	<cfelse>
		<cfoutput>
			<tr>
				<td colspan="3">No Friendly URLs are currently loaded.</td>
			</tr>
		</cfoutput>
	</cfif>
	<!--- end results table --->
	<cfoutput>
		</table>
		
		<input type="submit" value="#application.adminBundle[session.dmProfile.locale].delete#" class="f-submit" />
		
		
		</form>
	</cfoutput>
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">