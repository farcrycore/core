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
	<cfapplication name="#form.projectname#_UpgradeV5" />
	
		<cfsetting requesttimeout="1620" />
	<!--- Project directory name can be changed from the default which is the applicationname --->
		<cfset application.projectDirectoryName =  #form.projectname# />
		
		<!----------------------------------------
		 SET THE DATABASE SPECIFIC INFORMATION 
		---------------------------------------->
		<cfset application.dsn = form.dsn />
		<cfset application.dbtype = form.dbtype />
		<cfset application.dbowner = form.dbowner />
		<cfset application.locales =  "en_AU" />
		
		<cfif application.dbtype EQ "mssql" AND NOT len(application.dbowner)>
			<cfset application.dbowner = "dbo." />
		</cfif>
		
		<!----------------------------------------
		 SET THE MAIN PHYSICAL PATH INFORMATION
		 ---------------------------------------->
		<cfset application.path.project = expandpath("/farcry/projects/#application.projectDirectoryName#") />
		<cfset application.path.core = expandpath("/farcry/core") />
		<cfset application.path.plugins = expandpath("/farcry/plugins") />
		
		<cfset application.path.defaultFilePath = "#application.path.project#/www/files">
		<cfset application.path.secureFilePath = "#application.path.project#/securefiles">		
		
		<cfset application.path.imageRoot = "#application.path.project#/www">
		
		<cfset application.path.mediaArchive = "#application.path.project#/mediaArchive">
		
		
		<!----------------------------------------
		 WEB URL PATHS
		 ---------------------------------------->
		<cfset application.url.webroot = "" />
		<cfset application.url.farcry = "#application.url.webroot#/webtop" />
		<cfset application.url.imageRoot = "#application.url.webroot#">
		<cfset application.url.fileRoot = "#application.url.webroot#/files">
		
		
		<!----------------------------------------
		SHORTCUT PACKAGE PATHS
		 ---------------------------------------->
		<cfset application.packagepath = "farcry.core.packages" />
		<cfset application.custompackagepath = "farcry.projects.#application.projectDirectoryName#.packages" />
		<cfset application.securitypackagepath = "farcry.core.packages.security" />
		
		<!----------------------------------------
		PLUGINS TO INCLUDE
		 ---------------------------------------->
		<cfset application.plugins = "" />
		
		
		<!------------------------------------------ 
		USE OBJECT BROKER?
		 ------------------------------------------>
		<cfset application.bObjectBroker = false />
		<cfset application.ObjectBrokerMaxObjectsDefault = 100 />
		
		
		<!------------------------------------------ 
		USE MEDIA ARCHIVE?
		 ------------------------------------------>
		<cfset application.bUseMediaArchive = false />
	
		<!---------------------------------------------- 
		INITIALISE THE COAPIUTILITIES SINGLETON
		----------------------------------------------->
		<cfset application.coapi = structNew() />
		<cfset application.coapi.coapiUtilities = createObject("component", "farcry.core.packages.coapi.coapiUtilities").init() />


		<!--- Initialise the stPlugins structure that will hold all the plugin specific settings. --->
		<cfset application.stPlugins = structNew() />
		
		
		<!--- ENSURE SYSINFO IS UPDATED EACH INITIALISATION --->
		<cfset application.sysInfo = structNew() />
		
	<cfparam name="application.factory" default="#structNew()#" />
	<cfparam name="application.factory.oUtils" default="#createobject("component","#application.packagepath#.farcry.utils")#" />
	
	<!---------------------------------------------- 
	INITIALISE THE COAPIADMIN SINGLETON
	----------------------------------------------->
	<cfset application.coapi.coapiadmin = createObject("component", "farcry.core.packages.coapi.coapiadmin").init() />
	<cfset application.coapi.objectBroker = createObject("component", "farcry.core.packages.fourq.objectBroker").init() />
		
	<cfset oAlterType = createObject("component", "#application.packagepath#.farcry.alterType") />
	<cfset oAlterType.refreshAllCFCAppData(dsn=form.dsn, dbowner=form.dbowner) />

	
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
	</cfquery>
	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#farRole_groups
	</cfquery>
	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#farRole_permissions
	</cfquery>
	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#farUser
	</cfquery>
	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#farUser_groups
	</cfquery>
	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#farGroup
	</cfquery>
	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#farPermission
	</cfquery>
	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#farBarnacle
	</cfquery>
	
	<!--- CONFIG --->
	<cfif NOT alterType.isCFCDeployed(typename="farConfig")>
		<cfset createobject("component","farcry.core.packages.types.farConfig").deployType(btestRun="false") />
	</cfif>
	
	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#farConfig
	</cfquery>
	
	<!--- WORKFLOW --->
	<cfif NOT alterType.isCFCDeployed(typename="farWorkflowDef")>
		<cfset createobject("component","farcry.core.packages.types.farWorkflowDef").deployType(btestRun="false") />
	</cfif>
	<cfif NOT alterType.isCFCDeployed(typename="farWorkflow")>
		<cfset createobject("component","farcry.core.packages.types.farWorkflow").deployType(btestRun="false") />
	</cfif>
	<cfif NOT alterType.isCFCDeployed(typename="farTaskDef")>
		<cfset createobject("component","farcry.core.packages.types.farTaskDef").deployType(btestRun="false") />
	</cfif>
	<cfif NOT alterType.isCFCDeployed(typename="farTask")>
		<cfset createobject("component","farcry.core.packages.types.farTask").deployType(btestRun="false") />
	</cfif>
	
	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#farWorkflowDef
	</cfquery>
	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#farWorkflow
	</cfquery>
	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#farTaskDef
	</cfquery>
	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#farTask
	</cfquery>
	
	
	<!--- CATEGORIES --->
	
	<cfif NOT alterType.isCFCDeployed(typename="dmCategory")>
		<cfset createobject("component","farcry.core.packages.types.dmCategory").deployType(btestRun="false") />
	</cfif>

	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#dmCategory
	</cfquery>
	<cfquery datasource="#application.dsn#">
	INSERT INTO  #application.dbowner#dmCategory(objectid,alias,categorylabel,createdby,ownedby,lastupdatedby,datetimecreated,datetimelastupdated,label)
	SELECT categoryID,alias,categorylabel,'farcry','farcry','farcry','#dateFormat(now(),"yyyy-mm-dd")#','#dateFormat(now(),"yyyy-mm-dd")#',categorylabel
	FROM categories
	</cfquery>
	
	<cftry>
		<!--- get objectId list for removal --->
		<cfquery name="qTypes" datasource="#application.dsn#">
			SELECT ObjectID 
			FROM #application.dbowner#dmCategory
		</cfquery>
	
		<cfif qTypes.recordCount GT 0>
			
			<!--- remove references from refObjects --->
			<cfquery name="qDelRefs" datasource="#application.dsn#">
				DELETE FROM #application.dbowner#refObjects
				WHERE typename = 'dmCategory'
			</cfquery>
			<!--- Do bulk insert into refObjects --->
			<cfquery name="qInsertRefs" datasource="#application.dsn#">
				INSERT INTO refObjects (objectid, typename)
					SELECT ObjectID as objectid, 'dmCategory' as typename
					FROM #application.dbowner#dmCategory
			</cfquery>
		</cfif>
		<cfcatch><cfoutput><p>Error indexing dmCategory into refObjects - perhaps type has not been deployed</p></cfoutput></cfcatch>
	</cftry>
		
		
	<!--- UPDATE dmCategory in NESTED_TREE_OBJECTS --->
	
	<cfquery datasource="#application.dsn#">
		update #application.dbowner#nested_tree_objects
		set typename = 'dmCategory'
		where typename = 'categories'
	</cfquery>
		
	<!--- ============ DATA MIGRATION ============ --->
	
	<cfapplication name="#form.projectname#" sessionmanagement="true" />
	
	<cfoutput><h1>Upgrade results</h1></cfoutput>
	
	<cfoutput>categories migrated<br/></cfoutput>
	
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
	<cfparam name="application.config" default="#structNew()#" />
	<cfset structclear(application.config) />
	<cfloop list="#oConfig.getConfigKeys()#" index="configkey">
		<cfset application.config[configkey] = oConfig.getConfig(configkey) />
		<cfoutput>Config #configkey# migrated<br/></cfoutput>
	</cfloop>
	
	
	
	<!--- CREATE APPLICATION.CFC and FARCRYCONSTRUCTOR.CFM --->

			
	<cfset projectPathWebroot = expandpath("/farcry/projects/#url.name#/www") />
	<cffile action="copy" source="#GetDirectoryFromPath(GetCurrentTemplatePath())#/Application.cf_" destination="#projectPathWebroot#/Application.cfc" mode="777" />
	<cffile action="copy" source="#GetDirectoryFromPath(GetCurrentTemplatePath())#/proxyApplication.cf_" destination="#projectPathWebroot#/proxyApplication.cfc" mode="777" />
	<cffile action="copy" source="#GetDirectoryFromPath(GetCurrentTemplatePath())#/farcryConstructor.cf_" destination="#projectPathWebroot#/farcryConstructor.cfm" mode="777" />
	
	<cfset application.bInit = true />
	
<cfelse>

	<cfparam name="url.name" default="" />
	<cfparam name="url.dsn" default="" />
	<cfparam name="url.dbType" default="" />
	<cfparam name="url.dbOwner" default="" />
	
	<cfif url.dbtype EQ "mssql" AND NOT len(url.dbowner)>
		<cfset url.dbowner = "dbo." />
	</cfif>

	<cfoutput>
	<form action="" method="POST" id="updateForm" name="updateForm">
		<h1>Upgrade FarCry database to 5.0</h1>		
		<p>
		<strong>This script :</strong>
		<ul>
			<li>Deploys new security types</li>
			<li>Migrates current security data</li>
			<li>Migrates config data</li>
			<li>Creates the new farLog table</li>
			<li>Creates the new farWorkflowDef table</li>
			<li>Creates the new farWorkflow table</li>
			<li>Creates the new farTask table</li>
			<li>Creates the new farTaskDef table</li>
			<li>Migrates current category data</li>
		</ul>
		</p>
		<p>NOTE: The old data will be left in place, but if the new tables already exist they will be wiped as part of the upgrade.</p>
		
		<table>
			<tr>
				<th><label for="projectname">Project name</label></th>
				<td>#url.name#</td>
			</tr>
		
			<tr>
				<th><label for="dsn">Database</label></th>
				<td>#url.dsn#</td>
			</tr>
			
			<tr>
				<th><label for="dbType">Database Type <em>*</em></label></th>
				<td>#url.dbType#</td>
			</tr>

			<tr>
				<th><label for="dbOwner">Database Owner</label></th>
		      	<td>#url.dbOwner#</td>
			</tr>
		</table>

		<input type="submit" name="submit" value="Upgrade" />
	</form>
	
	</cfoutput>
</cfif>

	</body>
</html>