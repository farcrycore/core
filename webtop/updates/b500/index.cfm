<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head> 
<title>FarCry 5.0 Updater</title>
<style type="text/css">
h1 {font-size:120%;color:##116EAF;margin-bottom: 20px;}
h2 {font-size:110%;font-weight:bold;margin-bottom: 5px;}
a {color: ##116EAF;}
</style>
</head>
<body style="background-color: ##5A7EB9;">
	<div style="border: 8px solid ##eee;background:##fff;width:37em;margin: 50px auto;padding: 20px;color:##666">
		<h1>Upgrade FarCry database to 5.0</h1>	
		<div style="margin-left:20px;">
</cfoutput>				



<cfif structkeyexists(form,"submit")>
	<cfapplication name="#form.projectname#_UpgradeV5" sessionmanagement="true" sessiontimeout="#createTimespan(0,0,2,0)#" />
	
		<cfsetting requesttimeout="1620" />
		
		
		<cfoutput><h2>RUNNING MIGRATION.... PLEASE BE PATIENT...</h2></cfoutput><cfflush>
	
	
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
	<cfoutput><p>updating secuirty...</cfoutput><cfflush>
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
	
	<cfoutput>complete</p></cfoutput><cfflush>
	
	
	<!--- CONFIG --->
	<cfoutput><p>updating config...</cfoutput><cfflush>
	<cfif NOT alterType.isCFCDeployed(typename="farConfig")>
		<cfset createobject("component","farcry.core.packages.types.farConfig").deployType(btestRun="false") />
	</cfif>
	
	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#farConfig
	</cfquery>
	
	<cfoutput>complete</p></cfoutput><cfflush>
	
	
	<!--- WORKFLOW --->
	
	<cfoutput><p>creating workflow...</cfoutput><cfflush>
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
	
	
	<cfoutput>complete</p></cfoutput><cfflush>
	
	
	<!--- CATEGORIES --->
	
	<cfoutput><p>updating categories...</cfoutput><cfflush>
	<cfif NOT alterType.isCFCDeployed(typename="dmCategory")>
		<cfset createobject("component","farcry.core.packages.types.dmCategory").deployType(btestRun="false") />
	</cfif>

	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#dmCategory
	</cfquery>
	<cfquery datasource="#application.dsn#">
	INSERT INTO  #application.dbowner#dmCategory(objectid,alias,categorylabel,createdby,ownedby,lastupdatedby,datetimecreated,datetimelastupdated,label)
	SELECT categoryID,alias,categorylabel,'farcry','farcry','farcry', #createODBCDate(now())#, #createODBCDate(now())# ,categorylabel
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
		
	<cfoutput>complete</p></cfoutput><cfflush>
	
	
	
	<!--- UPDATE dmWebskinAncestor --->
	<cfoutput><p>updating dmWebskinAncestor Table...</cfoutput><cfflush>
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmWebskinAncestor ADD webskinTypename VARCHAR2(255) NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmWebskinAncestor ADD webskinTemplate VARCHAR2(255) NULL
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmWebskinAncestor ADD webskinTypename VARCHAR(255) NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmWebskinAncestor ADD webskinTemplate VARCHAR(255) NULL
				</cfquery>
			</cfdefaultcase>
		</cfswitch>

		<cfcatch><cfset error=1><cfoutput><strong>field already exist.</strong></p></cfoutput></cfcatch>
	</cftry>	
	<cfoutput>complete</p></cfoutput><cfflush>
	
	<!--- ============ DATA MIGRATION ============ --->
	
	<cfoutput><h1>Fetching results...</h1></cfoutput><cfflush>
	
	
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
	
	<cfoutput>
		<h2>UPGRADE COMPLETE</h2>
		<p>Your old application.cfm is still in place. If you had code in the application.cfm you may wish to consider placing it in one of the relevent projects config files located in <strong>/projectdirectory/config</strong></p>
	    <ul>
	    	<li>webserver mappings will have to be updated after the upgrade is complete. You will need to rename the /farcry webserver mapping to /webtop and it now points to /farcry/core/webtop instead of /farcry/core/webtop</li>
		    <li>You may experience errors on the upgraded website. The first suggestion after the upgrade is to login to the webtop (using /webtop) go to admin:coapi utilities and make sure any undeployed properties are deployed. This could occur if the project was an early version of 4.x</li>
			<li>Security has been changed dramatically specifically the login.cfm. The most significant code change that may be required in your project is to replace any references to:
				<ul>
					<li><strong>request.dmsec</strong> to <strong>application.factory.dmsec</strong></li>
					<li><strong>request.factory</strong> to <strong>application.factory</strong></li>
				</ul>
			</li>
		    <li>If you have implemented an ldap userdirectory, more information can be found here (http://docs.farcrycms.org/labels/addfavourite.action?entityId=1798)</li>
		    <li>If you had code in the application.cfm you may wish to consider placing it in one of the relevent projects config files located in /projectdirectory/config The files available are:
		          <ul>
			          <li>serverSpecificVars.cfm - called only before application initialisation (ie. first time application is run after a restart or on application timeout).</li>
			          <li>serverSpecificVarsAfterInit.cfm - called only after application initialisation (ie. first time application is run after a restart or on application timeout).</li>
			          <li>serverSpecificRequestScope.cfm - called on every request.</li>
		          </ul>
			</li>
		</ul>
		
		<p><a href="/index.cfm">Visit upgraded website</a></p>
	</cfoutput>
<cfelse>

	<cfparam name="url.name" type="string" />
	<cfparam name="url.dsn" type="string" />
	<cfparam name="url.dbType" type="string" />
	<cfparam name="url.dbOwner" type="string" />
	
	<cfif url.dbtype EQ "mssql" AND NOT len(url.dbowner)>
		<cfset url.dbowner = "dbo." />
	</cfif>

	<cfoutput>
	<form action="" method="POST" id="updateForm" name="updateForm">
			
		<p>
		<strong>This script :</strong>
		<ul>
			<li>Deploys the new <strong>security</strong> types</li>
			<li>Deploys the new <strong>Log</strong> types</li>
			<li>Deploys the new <strong>Workflow</strong> types</li>
			<li>Migrates the current <strong>security</strong> data</li>
			<li>Migrates the current <strong>config</strong> data</li>
			<li>Migrates the current <strong>category</strong> data</li>
		</ul>
		</p>
		<p><strong>NOTE</strong>: The old data will be left in place, but if the new tables already exist they will be wiped as part of the upgrade.</p>
		<div style="border:1px dotted ##e3e3e3;padding:10px;margin:10px;">
		<table>
			<tr>
				<td><strong>Project name</strong></td>
				<td>#url.name#</td>
			</tr>
		
			<tr>
				<td><strong>Database DSN Name</strong></td>
				<td>#url.dsn#</td>
			</tr>
			
			<tr>
				<td><strong>Database Type</strong></td>
				<td>#url.dbType#</td>
			</tr>

			<tr>
				<td><strong>Database Owner</strong></td>
		      	<td>#url.dbOwner#</td>
			</tr>
		</table>
			<input type="hidden" name="projectName" value="#url.name#" />
			<input type="hidden" name="dsn" value="#url.dsn#" />
			<input type="hidden" name="dbType" value="#url.dbType#" />
			<input type="hidden" name="dbOwner" value="#url.dbOwner#" />
			<input type="submit" name="submit" value="Upgrade Now" />
		</div>
	</form>
	
	</cfoutput>
</cfif>


<cfoutput>
		</div>
	</div>
</body>
</html>
</cfoutput>