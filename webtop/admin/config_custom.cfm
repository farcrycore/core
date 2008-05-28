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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/admin/config_custom.cfm,v 1.7 2005/08/16 05:53:23 pottery Exp $
$Author: pottery $
$Date: 2005/08/16 05:53:23 $
$Name: milestone_3-0-1 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: Manages custom config items$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header title="Custom Config" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="AdminGeneralTab">
	<!--- get custom configs --->
	<cfdirectory action="LIST" directory="#application.path.project#/system/dmConfig" name="qConfigs" filter="*.cfm">
	<cfscript>
		if (isDefined("URL.deploy"))
			stStatus = application.factory.oConfig.deployCustomConfig(config=url.deploy,action=url.type);
	</cfscript>
	
	<cfoutput>
	<h3>#application.rb.getResource("customConfigTypes")#</h3></cfoutput>
	
	<cfif qConfigs.recordcount>
		<cfoutput>
		<!--- display any messages --->
		<cfif isdefined("stStatus")>
			<p>#stStatus.msg#</p>
		</cfif>
		<table class="table-3" cellspacing="0">
		<tr>
			<th scope="col">#application.rb.getResource("config")#</th>
			<th scope="col">#application.rb.getResource("deployed")#</th>
			<th scope="col">#application.rb.getResource("deploy")#</th>
		</tr>
		</cfoutput>
		
		<cfloop query="qConfigs">
			<!--- check if config has been deployed --->
			<cfset stConfig = application.factory.oConfig.getConfig(configName=listGetAt(qConfigs.name,1,"."))>
			<cfoutput>
		
			<tr class="#IIF(qConfigs.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
				<td>#listGetAt(qConfigs.name,1,".")#</td>
				<td align="center">
					<cfif not structIsEmpty(stConfig)>
						<img src="#application.url.farcry#/images/yes.gif">
					<cfelse>
						<img src="#application.url.farcry#/images/no.gif">
					</cfif>
				</td>
				
				<td align="center">
					<cfif not structIsEmpty(stConfig)>
						<a href="#CGI.SCRIPT_NAME#?deploy=#qConfigs.name#&type=redeploy">#application.rb.getResource("restoreDefault")#</a>
					<cfelse>
						<a href="#CGI.SCRIPT_NAME#?deploy=#qConfigs.name#&type=deploy">#application.rb.getResource("deploy")#</a>
					</cfif>
				</td>
			</tr>
			</cfoutput>
		</cfloop>
		
		<cfoutput>
		</table>
		</cfoutput>
	
	<cfelse>
		<cfoutput><p>#application.rb.getResource("noCustomConfigNow")#</p></cfoutput>
	</cfif>
</sec:CheckPermission>

<admin:footer>
<cfsetting enablecfoutputonly="No">

