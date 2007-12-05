<html>
	<head>
		<title>Update to 4.1</title>
		<script type="text/javascript">
			function blocking(nr, status)
			{
				var current;		
				current = (status) ? 'block' : 'none';
				
				if (document.layers)
				{
					document.layers[nr].display = current;
				}
				else if (document.all)
				{
					document.all[nr].style.display = current;
				}
				else if (document.getElementById)
				{
					document.getElementById(nr).style.display = current;
				}
			}
			
			function checkDBType(dbType)
			{
				//alert(dbType);
				if(dbType == "postgresql" || dbType == "mysql" || dbType == "")
				{
					document.updateForm.dbOwner.value='';
					//hide DB Owner field for relevant db types
					blocking('divDBOwner', 0);		
				}
				else
				{
					document.updateForm.dbOwner.value='dbo.';
					blocking('divDBOwner', 1);
				}
			}
		</script>
	</head>
	<body>

<cfif structkeyexists(form,"submit")>
	<cfapplication name="#form.projectname#" />
	<cfscript>
		application.dsn = form.DSN;
		application.dbType = form.dbType;
		//check for valid dbOwner
		if (len(form.dbOwner) and right(form.dbOwner,1) neq ".") {
        	application.dbowner = form.dbOwner & ".";
		} else {
			application.dbowner = form.dbOwner;
		}
		application.packagepath = "farcry.core.packages";
	    application.securitypackagepath = application.packagepath & ".security";
		application.path.core = expandPath("/farcry/core");
	</cfscript>

	<cfset alterType = createObject("component","farcry.core.packages.farcry.alterType") />
	<cfset migrateresult = "" />
	
	<!--- =========== DATABASE SCHEMA UPDATE ============= --->	
	
	<!--- LOG --->
	<cfif NOT alterType.isCFCDeployed(typename="farLog")>
		<cfset createobject("component","farcry.core.packages.types.farLog").deployType(btestRun="false") />
	</cfif>
	
	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#farLog
	</cfquery>
	
	<!--- SECURITY --->
	<cfif NOT alterType.isCFCDeployed(typename="farUser")>
		<cfset createobject("component","farcry.core.packages.types.farUser").deployType(btestRun="false") />
	</cfif>
	<cfif NOT alterType.isCFCDeployed(typename="farGroup")>
		<cfset createobject("component","farcry.core.packages.types.farGroup").deployType(btestRun="false") />
	</cfif>
	<cfif NOT alterType.isCFCDeployed(typename="farRole")>
		<cfset createobject("component","farcry.core.packages.types.farRole").deployType(btestRun="false") />
	</cfif>
	<cfif NOT alterType.isCFCDeployed(typename="farPermission")>
		<cfset createobject("component","farcry.core.packages.types.farPermission").deployType(btestRun="false") />
	</cfif>
	<cfif NOT alterType.isCFCDeployed(typename="farBarnacle")>
		<cfset createobject("component","farcry.core.packages.types.farBarnacle").deployType(btestRun="false") />
	</cfif>
	
	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#farRole
		delete from #application.dbowner#farRole_groups
		delete from #application.dbowner#farRole_permissions
		delete from #application.dbowner#farUser
		delete from #application.dbowner#farUser_groups
		delete from #application.dbowner#farGroup
		delete from #application.dbowner#farPermission
		delete from #application.dbowner#farBarnacle
	</cfquery>
	
	<!--- CONFIG --->
	<cfif NOT alterType.isCFCDeployed(typename="farConfig")>
		<cfset createobject("component","farcry.core.packages.types.farConfig").deployType(btestRun="false") />
	</cfif>
	
	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#farConfig
	</cfquery>
	
	<!--- ============ DATA MIGRATION ============ --->
	
	<cfapplication name="#form.projectname#" sessionmanagement="true" />
	
	<cfoutput><h1>Upgrade results</h1></cfoutput>
	
	<!--- SECURITY --->
	<cfset application.security = createobject("component","farcry.core.packages.security.security").init() />
	<cfset migrateresult = createobject("component","farcry.core.packages.security.FarcryUD").migrate() />
	
	<!--- Flag the app as uninitialised --->
	<cfset application.bInit = false />
	
	<cfoutput><p class="success">#migrateresult#</p></cfoutput>
	
	<!--- CONFIG --->
	<cfquery datasource="#application.dsn#" name="qConfig">
		select	configname
		from	#application.dbowner#config
	</cfquery>
	
	<cfset oConfig = createobject("component","farcry.core.packages.types.farConfig") />
	<cfloop query="qConfig">
		<cfset stConfig = oConfig.migrateConfig(configname) />
		<cfset migrateresult = migrateresult & "Config '#stConfig.configkey#' migrated<br/>" />
	</cfloop>
	
	<cfoutput><p class="success"></cfoutput>
	
	<!--- Load config data --->
	<cfset structclear(application.config) />
	<cfloop list="#oConfig.getConfigKeys()#" index="configkey">
		<cfset application.config[configkey] = oConfig.getConfig(configkey) />
		<cfoutput>Config #configkey# migrated<br/></cfoutput>
	</cfloop>
	
	<cfset application.bInit = true />
	
<cfelse>
	<form action="" method="POST" id="updateForm" name="updateForm">
		<h1>Upgrade FarCry database to 4.1</h1>
		<p>
		<strong>This script :</strong>
		<ul>
			<li>Deploys new security types</li>
			<li>Migrates current security data</li>
			<li>Migrates config data</li>
			<li>Creates the new farLog table</li>
		</ul>
		</p>
		<p>NOTE: The old data will be left in place, but if the new tables already exist they will be wiped as part of the upgrade.</p>
		
		<table>
			<tr>
				<td><label for="projectname">Project name</label></td>
				<td><input id="projectname" name="projectname" /></td>
			</tr>
		
			<tr>
				<td><label for="dsn">Database</label></td>
				<td><input id="dsn" name="dsn" /></td>
			</tr>
			
			<tr>
				<td><label for="dbType">Database Type <em>*</em></label></td>
				<td>
					<select name="dbType" id="dbType" class="selectOne" onchange="checkDBType(this.options[this.selectedIndex].value);">
						<option value="">--Select</option>
						<option value="mssql">Microsoft SQL Server</option>
						<option value="ora">Oracle</option>
						<option value="mysql">MySQL</option>
						<option value="postgresql">PostgreSQL</option>
					</select>
				</td>
			</tr>

			<tr>
				<td><label for="dbOwner">Database Owner</label></td>
		      	<td><input type="text" name="dbOwner" id="dbOwner" size="15" maxlength="100" class="inputText" /></td>
			</tr>
		</table>

		<input type="submit" name="submit" value="Update" />
	</form>
</cfif>

	</body>
</html>