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


<!--- build coapi metadata --->
<cfset oAlterType = createObject("component", "#application.packagepath#.farcry.alterType") />
<cfset oAlterType.refreshAllCFCAppData() />


<cfoutput><h3>System Tables</h3></cfoutput>


<!--- // create fqaudit table --->
<cfoutput><p>Creating audit table.</p></cfoutput>
<cfset fqaudit = createObject("component", "farcry.core.packages.schema.fqaudit").init(argumentcollection=stargs) />
<cfset stResult = fqaudit.createTable() />
<cfflush />

<!--- // create nested_tree_objects table --->
<cfoutput><p>Creating nested tree model table.</p></cfoutput>
<cfset nto = createObject("component", "farcry.core.packages.schema.nested_tree_objects").init(argumentcollection=stargs) />
<cfset stResult = nto.createTable() />
<cfflush />

<!--- // setup refObjects table --->	
<cfoutput><p>Creating refObjects table.</p></cfoutput>
<cfset refobj = createObject("component", "farcry.core.packages.schema.refobjects").init(argumentcollection=stargs) />
<cfset stResult = refobj.createTable() />
<cfflush />

<!--- // set up refContainers table --->
<cfoutput><p>Creating refContainers table.</p></cfoutput>
<!--- 
<cfset nto = createObject("component", "farcry.core.packages.schema.nested_tree_objects").init(argumentcollection=stargs) />
<cfset stResult = nto.createTable() />
 --->
<cfset oCon = createObject("component","#application.packagepath#.rules.container") />
<cfset oCon.deployRefContainers(dsn=application.dsn,dbtype=application.dbtype,dbowner=application.dbowner) />
<cfflush />

<!--- // setup metadata categories --->
<!--- todo: build relevant schema component --->
<cfoutput><p>Creating tables for categorisation actions</p></cfoutput>
<cfset category = createObject("component", "#application.packagepath#.farcry.category") />
<cfset stResult = category.deployCategories(dsn=application.dsn,bDropTables=true) />
<cfflush />

<!--- // setup stats table --->
<!--- todo: build relevant schema component --->
<cfoutput><p>Creating table for site statistics.</p></cfoutput>
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


<cfoutput><p>Creating container and rule tables.</p></cfoutput>
<cfoutput><ul></cfoutput>
<cfloop query="qRules">
	<cfset oRule = createObject("component", qrules.typepath) />
	<cftry>
		<cfset stResult = oRule.deployType(dsn=application.dsn,bDropTable=true,bTestRun=false,dbtype=application.dbtype) />
		<cfoutput><li>#listfirst(qrules.name,".")#</li></cfoutput>
		<cfflush />
	
		<cfcatch type="farcry.core.packages.fourq.tablemetadata.abstractTypeException">
			<cfset stResult.bsucess="false" />
			<cfset stResult.message=cfcatch.message />
		</cfcatch>
	</cftry>
</cfloop>
<cfoutput></ul></cfoutput>


<!--- // deploy type tables --->
<cfset qTypes=application.coapi.coapiadmin.getCOAPIComponents(project=form.applicationName, package="types", plugins=form.plugins) />


<cfoutput><p>Creating types tables.</p></cfoutput>
<cfoutput><ul></cfoutput>
<cfloop query="qTypes">
	<cfset oType = createObject("component", qtypes.typepath) />
	<cftry>
		<cfset stResult = oType.deployType(dsn=application.dsn,bDropTable=true,bTestRun=false,dbtype=application.dbtype) />
		<cfoutput><li>#listfirst(qtypes.name,".")#</li></cfoutput>
		<cfflush />
	
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
	
	<!--- Load config data --->
	<cfset oConfig = createobject("component","farcry.core.packages.types.farConfig") />
	<cfloop list="#application.factory.oUtils.getComponents('forms')#" index="configkey">
		<cfif refindnocase("^config", configkey)>
			<cfset application.config[configkey] = oConfig.getConfig(key=configkey,bAudit=false) />
		</cfif>
	</cfloop>


	
	<!--- STEP 3 : setup Daemon security --->
	<cfoutput>
	<table border="0" cellpadding="1" cellspacing="0" width="600">
		<tr><td colspan="2">&nbsp;</td></tr>
		<tr><td colspan="2"><h4>[STEP 3] setup Daemon security (dmSec)</h4></td></tr>
	</cfoutput>
	<cfflush />
	
	
	
	
	
	<cfoutput><tr><td width="100%"><ul><li>Setting up user directories</cfoutput>
	<cfset dotAnim() />
	
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
	
	<cfoutput>#successMsg#</cfoutput>
	<cfflush />
	
	
	
	<!----------------------------------------------------------------------
	Plugin
	 - search and install Plugin install data
	----------------------------------------------------------------------->
	<cfset qInstalls=application.coapi.coapiadmin.getPluginInstallers(plugins=form.plugins) />
	<cfloop query="qInstalls">
		<cfinclude template="/farcry/plugins/#qinstalls.Plugin#/config/install/#qinstalls.name#" />
	</cfloop>



	<cfset oSkeletonManifest = createObject("component", "#form.skeleton#.install.manifest") />
	<cfset result = oSkeletonManifest.install() />
	<cfset application.navid = createObject("component", application.stcoapi["dmNavigation"].packagePath).getNavAlias() />
	
	
	
	<!--- Remove the skelton instalation files --->
	<cftry>
		<cfdirectory action="delete" directory="#farcryProjectsPath#/#form.applicationName#/install" recurse="true" />
		<cfcatch type="any"><!--- ignore ---></cfcatch>
	</cftry>
	 
	<!--- Flag the app as uninitialised --->
	<cfset application.bInit = false />
	
	<cfoutput>
	</table>
	</cfoutput>
	<cfflush />



<cfsetting enablecfoutputonly="false" />