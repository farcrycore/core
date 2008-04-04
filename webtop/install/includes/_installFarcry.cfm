<cfsetting enablecfoutputonly="true" />

<!--- @@Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@Description: Installation scripts for FarCry database components --->


<!--- STEP 1 : setup farcry database --->
<cfparam name="successMsg" default="<td><span class=""success"">DONE</span></td></tr>#chr(13)##chr(10)#" />
<cfparam name="failureMsg" default="<td><span class=""failure"">FAILED!</span></td></tr>#chr(13)##chr(10)#" />



<!----------------------------------------------------------------------- 
DEPLOY SYSTEM TABLES
	- fqaudit
	- nested_tree_objects
------------------------------------------------------------------------>

<!--- build standard schema argument collection --->
<cfset stargs=structnew() />
<cfset stargs.dsn=application.dsn />
<cfset stargs.dbtype=application.dbtype />
<cfset stargs.dbowner=application.dbowner />


<!--- instantiate singletons needed for install --->
<cfset application.factory.oUtils = createobject("component","farcry.core.packages.farcry.utils") />
<cfset application.factory.oAudit = createObject("component","#application.packagepath#.farcry.audit") />

<cfoutput>#updateProgressBar(value="0.3", text="#form.displayName# (INITIALISING): Fetching projects metadata")#</cfoutput><cfflush>
<!--- build coapi metadata --->
<cfset oAlterType = createObject("component", "#application.packagepath#.farcry.alterType") />
<cfset oAlterType.refreshAllCFCAppData() />





<!--- // create fqaudit table --->
<cfoutput>#updateProgressBar(value="0.4", text="#form.displayName# (DATABASE): Creating audit table.")#</cfoutput><cfflush>
<cfset fqaudit = createObject("component", "farcry.core.packages.schema.fqaudit").init(argumentcollection=stargs) />
<cfset stResult = fqaudit.createTable() />
<cfflush />

<!--- // create nested_tree_objects table --->
<cfoutput>#updateProgressBar(value="0.4", text="#form.displayName# (DATABASE): Creating audit table.")#</cfoutput><cfflush>
<cfset nto = createObject("component", "farcry.core.packages.schema.nested_tree_objects").init(argumentcollection=stargs) />
<cfset stResult = nto.createTable() />
<cfflush />

<!--- // setup refObjects table --->
<cfoutput>#updateProgressBar(value="0.4", text="#form.displayName# (DATABASE): Creating refObjects table.")#</cfoutput><cfflush>	
<cfset refobj = createObject("component", "farcry.core.packages.schema.refobjects").init(argumentcollection=stargs) />
<cfset stResult = refobj.createTable() />
<cfflush />

<!--- // set up refContainers table --->
<cfoutput>#updateProgressBar(value="0.4", text="#form.displayName# (DATABASE): Creating refContainers table.")#</cfoutput><cfflush>	
<!--- 
<cfset nto = createObject("component", "farcry.core.packages.schema.nested_tree_objects").init(argumentcollection=stargs) />
<cfset stResult = nto.createTable() />
 --->
<cfset oCon = createObject("component","#application.packagepath#.rules.container") />
<cfset oCon.deployRefContainers(dsn=application.dsn,dbtype=application.dbtype,dbowner=application.dbowner) />
<cfflush />

<!--- // setup metadata categories --->
<!--- todo: build relevant schema component --->
<cfoutput>#updateProgressBar(value="0.4", text="#form.displayName# (DATABASE): Creating categorisation table.")#</cfoutput><cfflush>
<cfset category = createObject("component", "#application.packagepath#.farcry.category") />
<cfset stResult = category.deployCategories(dsn=application.dsn,bDropTables=true) />
<cfflush />

<!--- // setup stats table --->
<!--- todo: build relevant schema component --->
<cfoutput>#updateProgressBar(value="0.4", text="#form.displayName# (DATABASE): Creating table for site statistics.")#</cfoutput><cfflush>
<cfset stats = createObject("component", "#application.packagepath#.farcry.stats") />
<cfset stResult = stats.deploy(dsn=application.dsn,bDropTable=true) />
<cfflush />




<!--- // deploy rule tables --->
<!--- 
TODO:
	Appear to be missing the container table deploy with the new aggregated rule deploy
	May need to be built as an independent ./schema component
 --->	
<cfset qRules=application.coapi.coapiadmin.getCOAPIComponents(project=form.applicationName, package="rules", plugins=form.plugins) />

<cfoutput>#updateProgressBar(value="0.5", text="#form.displayName# (RULES): Creating container and rule tables.")#</cfoutput><cfflush>

<cfloop query="qRules">
	<cfset oRule = createObject("component", qrules.typepath) />
	<cftry>
		<cfset stResult = oRule.deployType(dsn=application.dsn,bDropTable=true,bTestRun=false,dbtype=application.dbtype) />
		<cfoutput>#updateProgressBar(value="0.5", text="RULES): Creating #listfirst(qrules.name,".")# table.")#</cfoutput><cfflush>
	
		<cfcatch type="farcry.core.packages.fourq.tablemetadata.abstractTypeException">
			<cfset stResult.bsucess="false" />
			<cfset stResult.message=cfcatch.message />
		</cfcatch>
	</cftry>
</cfloop>



<!--- // deploy type tables --->
<cfset qTypes=application.coapi.coapiadmin.getCOAPIComponents(project=form.applicationName, package="types", plugins=form.plugins) />


<cfoutput>#updateProgressBar(value="0.6", text="#form.displayName# (TYPES): Creating types tables.")#</cfoutput><cfflush>

<cfloop query="qTypes">
	<cfset oType = createObject("component", qtypes.typepath) />
	<cftry>
		<cfset stResult = oType.deployType(dsn=application.dsn,bDropTable=true,bTestRun=false,dbtype=application.dbtype) />
		<cfoutput>#updateProgressBar(value="0.6", text="#form.displayName# (TYPES): Creating #listfirst(qtypes.name,".")# table.")#</cfoutput><cfflush>

		<cfcatch type="farcry.core.packages.fourq.tablemetadata.abstractTypeException">
			<cfset stResult.bsucess="false" />
			<cfset stResult.message=cfcatch.message />
		</cfcatch>
	</cftry>
</cfloop>
<cfoutput></ul></cfoutput>

<!--- 
TODO: 
	am up to here for first pass refactoring
	GB 20061022
 --->


	<cfoutput>#updateProgressBar(value="0.65", text="#form.displayName# (SECURITY): Setting up user directories")#</cfoutput><cfflush>

	<!--- Get user directories --->
	<cfset oUtils = createobject("component","farcry.core.packages.farcry.utils") />
	<cfset application.factory.oUtils = oUtils />
	<cfset application.security = createobject("component","farcry.core.packages.security.security").init() />
	<cfloop list="#oUtils.getComponents('security')#" index="comp">
		<cfif oUtils.extends(oUtils.getPath("security",comp),"farcry.core.packages.security.UserDirectory")>
			<cfset ud = createobject("component",oUtils.getPath("security",comp)).init() />
			<cfset application.security.userdirectories[ud.key] = ud />
		</cfif>
	</cfloop>
	
	<cfoutput>#updateProgressBar(value="0.7", text="#form.displayName# (PLUGINS): Setting up plugins")#</cfoutput><cfflush>
	<!----------------------------------------------------------------------
	Plugin
	 - search and install Plugin install data
	----------------------------------------------------------------------->
	<cfset qInstalls=application.coapi.coapiadmin.getPluginInstallers(plugins=form.plugins) />
	<cfloop query="qInstalls">
		<cfoutput>#updateProgressBar(value="0.7", text="PLUGINS: Setting up #qinstalls.Plugin#")#</cfoutput><cfflush>
		<cfinclude template="/farcry/plugins/#qinstalls.Plugin#/config/install/#qinstalls.name#" />
	</cfloop>


	<cfoutput>#updateProgressBar(value="0.8", text="#form.displayName# (SKELETON): Installing Skeleton Data...")#</cfoutput><cfflush>
	
	<cfset oSkeletonManifest = createObject("component", "#form.skeleton#.install.manifest") />
	<cfset result = oSkeletonManifest.install() />
	<cfset application.navid = createObject("component", application.stcoapi["dmNavigation"].packagePath).getNavAlias() />
	
	
	<cfoutput>#updateProgressBar(value="0.8", text="#form.displayName# (SKELETON): Removing the skelton instalation files")#</cfoutput><cfflush>
	<!--- Remove the skelton instalation files --->
	<cftry>
		<cfdirectory action="delete" directory="#farcryProjectsPath#/#form.applicationName#/install" recurse="true" />
		<cfcatch type="any"><!--- ignore ---></cfcatch>
	</cftry>
	 
	<cfoutput>#updateProgressBar(value="0.9", text="#form.displayName# (CONFIG): Loading config data")#</cfoutput><cfflush>
	<!--- Load config data --->
	<cfset oConfig = createobject("component","farcry.core.packages.types.farConfig") />
	<cfloop list="#oConfig.getConfigKeys()#" index="configkey">
		<cfset application.config[configkey] = oConfig.getConfig(key=configkey,bAudit=false) />
	</cfloop>

	
	
	<!--- Flag the app as uninitialised --->
	<cfset application.bInit = false />



<cfsetting enablecfoutputonly="false" />