<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/config.cfm,v 1.6 2003/09/03 01:50:31 brendan Exp $
$Author: brendan $
$Date: 2003/09/03 01:50:31 $
$Name: b201 $
$Revision: 1.6 $

|| DESCRIPTION || 
$DESCRIPTION: config edit handler$
$TODO: $ 

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in:$ 
$out:$
--->
<cfsetting enablecfoutputonly="yes">

<!--- check permissions --->
<cfscript>
	iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>
	
<cfif iGeneralTab eq 1>
	
	<cfoutput><span class="formtitle">FarCry Internal Config Files</span><p></p></cfoutput>
	<cfparam name="form.action" default="none">
	
	<cfswitch expression="#form.action#">
	
		<cfcase value="update">
			<cfif form.stName eq "verity">
				<cfinclude template="config_verity.cfm">
			<cfelse>
			
				<!--- update configs for image and file --->
				<cfset stTemp = structNew()>
				<!--- loop through dynamic form fields and create temp structure with new values --->
				<cfloop list="#form.fieldnames#" index="i">
					<cfif i neq "action" and i neq "stName">
						<cfset stTemp[i] ="#evaluate('form.#i#')#">
					</cfif>
				</cfloop>
				<!--- duplicate temp structure to application scope --->
				<cfset "application.config.#form.stName#" = duplicate(stTemp)>
			</cfif>
			
			<!--- set config to database --->
			<cfinvoke component="#application.packagepath#.farcry.config" method="setConfig" returnvariable="setConfigRet">
				<cfinvokeargument name="configName" value="#form.stName#"/>
				<cfinvokeargument name="stConfig" value="#stTemp#"/>
			</cfinvoke>
			<cfoutput>Update complete.<p></p></cfoutput>
			
		</cfcase>
		
		<cfcase value="none">
			<cfif IsDefined("url.configName")>
				<cfoutput><span class="formTitle">#url.configName# Config</span></cfoutput>
				
				<!--- check if verity config, has unique edit handler --->
				<cfif url.configName eq "verity">
					<cfinclude template="config_verity.cfm">
				<cfelse>
				
					<cfset stTemp = evaluate('application.config.#url.configName#')>
					<!--- sort structure by Key name --->
					<cfset listofKeys = structKeyList(stTemp)>
					<cfset listofKeys = listsort(listofkeys,"textnocase")>			
					
					<cfoutput>
					<form action="#cgi.script_name#" method="post">
					<input type="Hidden" name="action" value="update">
					<input type="Hidden" name="stName" value="#url.configName#">
					<table>
					<!--- loop through config structure and set up form for editing --->
					<cfloop list="#listOfKeys#" index="field">
						<tr>
							<td>#field#</td>
							<td><input name="#field#" type="text" value="#stTemp[field]#"></td>
						</tr>
					</cfloop>
					<tr>
						<td>&nbsp;</td>
						<td><input type="submit" value="Update Config"></td>
					</tr>
					<tr>
						<td colspan="2">&nbsp;</td>
					</tr>
					</table>
					</form>
					</cfoutput>
				</cfif>
			</cfif>
		</cfcase>
		
		<cfdefaultcase><cfdump var="#form#"></cfdefaultcase>
	</cfswitch>
	
	<!--- list config files --->
	<cftry>
		<cfinvoke component="#application.packagepath#.farcry.config" method="list" returnvariable="qConfigs">
		
		<cfif qConfigs.RecordCount eq 0>
			<cfoutput>There are no configuration files specified.
			<form action="#cgi.script_name#" method="post">
			<input type="Hidden" name="action" value="defaults">
			<input type="submit" value="Install Default Configs">
			</form></cfoutput>
		<cfelse>
			<cfoutput query="qConfigs">
				<span class="frameMenuBullet">&raquo;</span> <a href="?configName=#qConfigs.configName#">#qConfigs.configName#</a><br>
			</cfoutput>
		</cfif>
		
		<cfcatch>
			<cfoutput><form action="#cgi.script_name#" method="post">
			<input type="Hidden" name="action" value="deploy">
			<input type="submit" value="Deploy Config Table">
			</form></cfoutput>
		</cfcatch>
	</cftry>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="no">