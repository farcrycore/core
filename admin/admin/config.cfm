<cfsetting enablecfoutputonly="yes">

<!--- set up page header --->
<cfimport taglib="/farcry/tags/admin/" prefix="admin">
<admin:header>

<cfoutput><span class="formtitle">FarCry Internal Config Files</span><p></p></cfoutput>
<cfparam name="form.action" default="none">

<cfswitch expression="#form.action#">
<cfcase value="deploy">
	<cfoutput><h3>Deploying config table...</h3></cfoutput>
	<cfscript>
		o = createObject("component", "#application.packagepath#.farcry.config");
		status = o.deployConfig();
	</cfscript>
	<cfdump var="#status#">
</cfcase>

<cfcase value="defaults">
	<cfoutput><h3>Installing default configs...</h3></cfoutput>
	<cfscript>
		aStatus = ArrayNew(1);
		o = createObject("component", "#application.packagepath#.farcry.config");
		status = o.defaultVerity();
		ArrayAppend(aStatus, status);
		application.config.verity = o.getConfig("verity");
		status = o.defaultImage();
		ArrayAppend(aStatus, status);
		application.config.image = o.getConfig("image");
		status = o.defaultFile();
		ArrayAppend(aStatus, status);
		application.config.file = o.getConfig("file");
	</cfscript>
	<cfdump var="#aStatus#">
</cfcase>

<cfcase value="update">
	<cfif form.stName eq "verity">
		<!--- ### update verity config ### --->
		<cfset stTemp = structNew()>
		<!--- loop over form fields and build structure of new config--->
		<cfloop list="#form.fieldnames#" index="i">
			<!--- check form fields aren't hidden values past and are actually config elements --->
			<cfif i neq "action" and i neq "stName">
				<!--- derive type from form field --->
				<cfset type = listgetat(i,1,"_")>
				<!--- check temp array for type exists --->
				<cfif structkeyexists(stTemp,"#type#")>
					<!--- add field to existing type array --->
					<cfset temp = arrayappend(stTemp[type],listgetat(i,2,"_"))>
				<cfelse>
					<!--- set up new array for type --->
					<cfset stTemp[type] = arrayNew(1)>
					<!--- add field to type array --->
					<cfset temp = arrayappend(stTemp[type],listgetat(i,2,"_"))>
				</cfif>
			</cfif>
		</cfloop>
		
		<!--- ### update existing config ### --->
		<!--- delete current setup --->
		<cfloop collection="#application.config.verity.contenttype#" item="typeName">
			<cfset temp = structDelete(application.config.verity.contenttype,typeName)>
		</cfloop>
		<!--- reset aIndicies array --->
		<cfset application.config.verity.aindices = arrayNew(1)>
		
		<!--- loop over temp structure --->
		<cfloop collection="#stTemp#" item="typeName">
			<!--- check type exists in current config --->
			<cfif structkeyexists(evaluate('application.config.verity.contenttype'),"#typeName#")>
				<!--- update current config --->
				<cfset "application.config.verity.contenttype.#typeName#.aprops" = stTemp[typeName]>
			<cfelse>
				<!--- create config entry for type --->
				<cfset "application.config.verity.contenttype.#typeName#" = structNew()>
				<cfset "application.config.verity.contenttype.#typeName#.aprops" = stTemp[typeName]>
			</cfif>
			<!--- update aIndicies array --->
			<cfset temp = arrayappend(application.config.verity.aIndices,typeName)>
		</cfloop>
		<!--- duplicate structure to send to database --->
		<cfset stTemp = duplicate(application.config.verity)>
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
		<cfif url.configName eq "verity">
			<cfset stTemp = evaluate('application.config.#url.configName#.contenttype')>
			
			<cfoutput><form action="#cgi.script_name#" method="post">
			<input type="Hidden" name="action" value="update">
			<input type="Hidden" name="stName" value="#url.configName#">
			<table></cfoutput>
			
			<!--- loop through all application types --->
			<cfloop collection="#application.types#" item="typeName">
				<cfoutput>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2"><strong>#typename#</strong></td>
				</tr>
				</cfoutput>
				<!--- loop through these types and look at each field --->
				<cfloop collection="#application.types[typeName].stProps#" item="Field">
				
					<!--- check fields aren't of type array or uuid and aren't derived from types.types --->
					<cfif application.types[typeName].stProps[field].metaData.type neq "array"
						and application.types[typeName].stProps[field].metaData.type neq "UUID"
						and findnocase("types.types",application.types[typeName].stProps[field].origin) eq 0>
				
						<!--- check against config setup --->
						<cfset checked = false>
						<cfif structkeyexists(evaluate('application.config.verity.contenttype'),"#typeName#")>
							<cfset temp = arraytolist(evaluate('application.config.verity.contenttype.#typeName#.aprops'))>
							<cfif listcontainsnocase(temp,#field#) gt 0>
								<cfset checked = true>
							</cfif>
						</cfif>
						
						<!--- display check box to add field to verity setup --->
						<cfoutput>
						<tr>
							<td><input type="checkbox" name="#typename#_#field#" <cfif checked>checked</cfif>></td>
							<td>#field#</td>
						</tr></cfoutput>
						
					</cfif>
					
				</cfloop>
			</cfloop>
			
			<cfoutput><tr>
				<td>&nbsp;</td>
				<td><input type="submit" value="Update Config"></td>
			</tr>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			</table>
			</form></cfoutput>
			<!--- <cfdump var="#Evaluate('application.config.#url.configName#')#" label="application.config.#url.configName#"> --->
			
		<cfelse>
		
			<cfset stTemp = evaluate('application.config.#url.configName#')>
			
			<cfoutput>
			<form action="#cgi.script_name#" method="post">
			<input type="Hidden" name="action" value="update">
			<input type="Hidden" name="stName" value="#url.configName#">
			<table>
			<!--- loop through config structure and set up form for editing --->
			<cfloop collection="#stTemp#" item="field">
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
			<!--- <cfdump var="#Evaluate('application.config.#url.configName#')#" label="application.config.#url.configName#"> --->
		</cfif>
	</cfif>
	<!--- <cfdump var="#form#"> --->
</cfcase>

<cfdefaultcase><cfdump var="#form#"></cfdefaultcase>

</cfswitch>

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
	<!--- <cfdump var="#cfcatch#"> --->
	<cfoutput><form action="#cgi.script_name#" method="post">
	<input type="Hidden" name="action" value="deploy">
	<input type="submit" value="Deploy Config Table">
	</form></cfoutput>
</cfcatch>
</cftry>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="no">