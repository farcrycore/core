<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/admin/manageFU.cfm,v 1.6 2005/09/15 01:15:46 guy Exp $
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

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="AdminGeneralTab">
	
	
	<!--- check if items have been marked for deletion --->
	<cfif isDefined("form.lMappings") and len(form.lMappings)>
		<!--- loop over marked items --->
		<cfloop list="#form.lMappings#" index="i">
			<!--- delete fu --->
			<cfset application.fc.factory.farFU.deleteMapping(i)>
		</cfloop>
		<!--- update fu mappings in app scope --->
		<!--- <cfset objFU.updateAppScope()> --->
	</cfif>
	
	<cfoutput>
	<!--- show filter form --->
	
	<form method="post" class="f-wrap-1 f-bg-short" action="">
	<fieldset>
	
		<h3>#application.rb.getResource("fuadmin.headings.manageURLs@text","Manage Friendly URLs")#</h3>

		<label for="searchIn"><b>&nbsp;</b>
		<select name="searchIn" id="searchIn">
		<option value="#application.rb.getResource('fuadmin.labels.alias@label','Alias')#" <cfif form.searchIn eq "mapping">selected</cfif>>#application.rb.getResource("fuadmin.labels.alias@lable","Alias")#
		<option value="#application.rb.getResource('fuadmin.labels.contentitem@label','Content Item')#" <cfif form.searchIn eq "object">selected</cfif>>#application.rb.getResource("fuadmin.labels.contentitem@label","Content Item")#
		</select>
		<br />
		</label>
		
		<label for="searchText"><b>&nbsp;</b>
		<input type="text" name="searchText" id="searchText" value="#form.searchText#" />	
		</label>
		
		<div class="f-submit-wrap">
		<input type="submit" value="#application.rb.getResource('fuadmin.labels.filter@label','Filter')#" class="f-submit" />
		</div>
		
	</fieldset>
	</form>

	<form method="post" action="">				
	<!--- set up results table --->
	<table class="table-2" cellspacing="0">
	<tr>
		<th style="text-align:center">#application.rb.getResource("fuadmin.labels.delete@label","Delete")#</th>
		<th>#application.rb.getResource("fuadmin.labels.alias@label","Alias")#</th>
		<th>#application.rb.getResource("fuadmin.labels.contentitem@label","Content Item")#</th>
	</tr>
	</cfoutput>

	<!--- check mappings are loaded --->
	<cfif isDefined("application.fc.factory.farFU.stMappings")>
		<!--- loop over mappings --->
		<cfloop collection="#application.fc.factory.farFU.stMappings#" item="key">
			<!--- check if filter has been entered --->
			<cfif len(form.searchText)>
				<!--- check filter against mapping --->
				<cfif form.searchIn eq "mapping" and findNoCase(form.searchText,key)>
					<cfset bShow = 1>
				<!--- check filter against object --->
				<cfelseIf form.searchIn eq "object" and findNoCase(form.searchText,application.fc.factory.farFU.stMappings[key])>
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
						<td>#application.url.conjurer#?objectid=#application.fc.factory.farFU.stMappings[key].refObjectID#<cfif application.fc.factory.farFU.stMappings[key].queryString NEQ "">&#application.fc.factory.farFU.stMappings[key].queryString#</cfif></td>
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
		
		<input type="submit" value="#application.rb.getResource('fuadmin.buttons.delete@label','Delete')#" class="f-submit" />
		
		
		</form>
	</cfoutput>
</sec:CheckPermission>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">