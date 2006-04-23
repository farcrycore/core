<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/manageFU.cfm,v 1.2 2005/01/27 19:52:58 brendan Exp $
$Author: brendan $
$Date: 2005/01/27 19:52:58 $
$Name: milestone_2-3-2 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Manage existing FU entries$
$TODO: $

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

	<!--- check if items have been marked for deletion --->
	<cfif isDefined("form.lMappings") and len(form.lMappings)>
		<!--- loop over marked items --->
		<cfloop list="#form.lMappings#" index="i">
			<!--- delete fu --->
			<cfset application.factory.oFU.deleteMapping(i)>
		</cfloop>
		<!--- update fu mappings in app scope --->
		<cfset application.factory.oFU.updateAppScope()>
	</cfif>
	
	<cfoutput><span class="FormTitle">#application.adminBundle[session.dmProfile.locale].manageURLs#</span><p></p></cfoutput>
	
	<!--- check factory fu object loaded --->
	<cfif not structKeyExists(application.factory,"oFU")>
		<cftry>
			<cfset application.factory.oFU = createObject("component","#application.packagepath#.farcry.FU")>
			<cfcatch>
				<cfoutput>#application.adminBundle[session.dmProfile.locale].fuPluginError#</cfoutput><cfabort>
			</cfcatch>
		</cftry>
	</cfif>
	
	<cfoutput>
	<!--- show filter form --->
	<table cellpadding="5" cellspacing="0" border="0" style="margin-left:30px;">
	<form action="" method="post">
	<tr>
		<td nowrap>		
		<!--- drop down for filter type --->
		<select name="searchIn">
			<option value="#application.adminBundle[session.dmProfile.locale].alias#" <cfif form.searchIn eq "mapping">selected</cfif>>#application.adminBundle[session.dmProfile.locale].alias#
			<option value="#application.adminBundle[session.dmProfile.locale].objectLC#" <cfif form.searchIn eq "object">selected</cfif>>#application.adminBundle[session.dmProfile.locale].objectLC#
		</select>
		
		<input type="text" name="searchText" value="#form.searchText#"/>		
		<input type="submit" value="#application.adminBundle[session.dmProfile.locale].filter#" class="normalbttnstyle">
		</td>
	</tr>
	</table>
				
	<!--- set up results table --->
	<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
	<tr>
		<th class="dataheader">#application.adminBundle[session.dmProfile.locale].delete#</th>
		<th class="dataheader">#application.adminBundle[session.dmProfile.locale].alias#</th>
		<th class="dataheader">#application.adminBundle[session.dmProfile.locale].objectLC#</th>
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
						<td align="center"><input type="checkbox" name="lMappings" value="#key#"></td>
						<td>#key#</td>
						<td>#application.fu.mappings[key]#</td>
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
		<div style="margin:10px 0 0 30px;"><input type="submit" value="#application.adminBundle[session.dmProfile.locale].delete#" class="normalbttnstyle"></div>
		</form>
	</cfoutput>
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">