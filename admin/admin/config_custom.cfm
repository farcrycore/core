<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/config_custom.cfm,v 1.4 2004/07/15 01:10:24 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:10:24 $
$Name: milestone_2-3-2 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Manages custom config items$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">

<!--- check permissions --->
<cfscript>
	iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
</cfscript>

<admin:header title="Custom Config" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iGeneralTab eq 1>	

	<!--- get custom configs --->
	<cfdirectory action="LIST" directory="#application.path.project#/system/dmConfig" name="qConfigs" filter="*.cfm">
	<cfscript>
		if (isDefined("URL.deploy"))
			stStatus = application.factory.oConfig.deployCustomConfig(config=url.deploy,action=url.type);
	</cfscript>
	
	<cfoutput>
	<span class="formtitle">#application.adminBundle[session.dmProfile.locale].customConfigTypes#</span><p></p></cfoutput>
	
	<cfif qConfigs.recordcount>
		<cfoutput>
		<!--- display any messages --->
		<cfif isdefined("stStatus")>
			<div style="margin-left:30px;">#stStatus.msg#</div>
		</cfif>
		<p></p>
		<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
		<tr>
			<th class="dataheader">#application.adminBundle[session.dmProfile.locale].config#</th>
			<th class="dataheader">#application.adminBundle[session.dmProfile.locale].deployed#</th>
			<th class="dataheader">#application.adminBundle[session.dmProfile.locale].deploy#</th>
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
		<cfoutput>#application.adminBundle[session.dmProfile.locale].noCustomConfigNow#</cfoutput>
	</cfif>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>
<cfsetting enablecfoutputonly="No">

