<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/config_custom.cfm,v 1.3 2003/09/17 07:19:00 brendan Exp $
$Author: brendan $
$Date: 2003/09/17 07:19:00 $
$Name: b201 $
$Revision: 1.3 $

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
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">

<!--- check permissions --->
<cfscript>
	iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
</cfscript>

<admin:header title="Custom Config">

<cfif iGeneralTab eq 1>	

	<!--- get custom configs --->
	<cfdirectory action="LIST" directory="#application.path.project#/system/dmConfig" name="qConfigs" filter="*.cfm">
	<cfscript>
		if (isDefined("URL.deploy"))
			stStatus = application.factory.oConfig.deployCustomConfig(config=url.deploy,action=url.type);
	</cfscript>
	
	<cfoutput>
	<span class="formtitle">Custom Config Types</span><p></p></cfoutput>
	
	<cfif qConfigs.recordcount>
		<cfoutput>
		<!--- display any messages --->
		<cfif isdefined("stStatus")>
			<div style="margin-left:30px;">#stStatus.msg#</div>
		</cfif>
		<p></p>
		<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
		<tr>
			<th class="dataheader">Config</th>
			<th class="dataheader">Deployed</th>
			<th class="dataheader">Deploy</th>
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
						<a href="#CGI.SCRIPT_NAME#?deploy=#qConfigs.name#&type=redeploy">Restore Default</a>
					<cfelse>
						<a href="#CGI.SCRIPT_NAME#?deploy=#qConfigs.name#&type=deploy">Deploy</a>
					</cfif>
				</td>
			</tr>
			</cfoutput>
		</cfloop>
		
		<cfoutput>
		</table>
		</cfoutput>
	
	<cfelse>
		<cfoutput>There are no custom configs at this time.</cfoutput>
	</cfif>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>
<cfsetting enablecfoutputonly="No">

