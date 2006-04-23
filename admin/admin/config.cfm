
<!---

|| LEGAL ||

$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$



|| VERSION CONTROL ||

$Header: /cvs/farcry/farcry_core/admin/admin/config.cfm,v 1.9 2004/06/21 03:51:32 paul Exp $

$Author: paul $

$Date: 2004/06/21 03:51:32 $

$Name: milestone_2-2-1 $

$Revision: 1.9 $



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



	<cfif isDefined("URL.configName")>

		<cfset stTemp = evaluate('application.config.#url.configName#')>

		<cfif structKeyExists(stTemp,'editHandler')>

			<cftry>

				<cfinclude template="#stTemp.edithandler#">

				<cfcatch>

					<cfoutput><h3>#url.configName# custom config template #stTemp.editHandler# was not found</h3></cfoutput>

				</cfcatch>

			</cftry>

			<cfabort>

		</cfif>



	</cfif>





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



				<!--- check if verity config, has unique edit handler TODO - update verity config to include this --->

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

							<cfif len(stTemp[field]) LT 80>

								<td>#field#</td>

								<td><input name="#field#" type="text" value="#stTemp[field]#" size="60"></td>

							<cfelse>

								<td valign="top">#field#</td>

								<td><textarea name="#field#" rows="#int(len(stTemp[field])/57)+1#" cols="57">#stTemp[field]#</textarea></td>

							</cfif>

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