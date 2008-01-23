<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

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
	<h3>#application.adminBundle[session.dmProfile.locale].customConfigTypes#</h3></cfoutput>
	
	<cfif qConfigs.recordcount>
		<cfoutput>
		<!--- display any messages --->
		<cfif isdefined("stStatus")>
			<p>#stStatus.msg#</p>
		</cfif>
		<table class="table-3" cellspacing="0">
		<tr>
			<th scope="col">#application.adminBundle[session.dmProfile.locale].config#</th>
			<th scope="col">#application.adminBundle[session.dmProfile.locale].deployed#</th>
			<th scope="col">#application.adminBundle[session.dmProfile.locale].deploy#</th>
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
						<a href="#CGI.SCRIPT_NAME#?deploy=#qConfigs.name#&type=redeploy">#application.adminBundle[session.dmProfile.locale].restoreDefault#</a>
					<cfelse>
						<a href="#CGI.SCRIPT_NAME#?deploy=#qConfigs.name#&type=deploy">#application.adminBundle[session.dmProfile.locale].deploy#</a>
					</cfif>
				</td>
			</tr>
			</cfoutput>
		</cfloop>
		
		<cfoutput>
		</table>
		</cfoutput>
	
	<cfelse>
		<cfoutput><p>#application.adminBundle[session.dmProfile.locale].noCustomConfigNow#</p></cfoutput>
	</cfif>
</sec:CheckPermission>

<admin:footer>
<cfsetting enablecfoutputonly="No">

