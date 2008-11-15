<cfsetting enablecfoutputonly="true" />
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
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
<cfset application.fc = structNew() />
<cfset application.fc.utils = createobject("component","farcry.core.packages.farcry.utils").init() />
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


<!--- SETUP farCoapi table first --->
<cfoutput>#updateProgressBar(value="0.4", text="#form.displayName# (COAPI): Creating COAPI table.")#</cfoutput><cfflush>
<cfset oCoapi = createObject("component", "#application.stcoapi.farCoapi.packagePath#") />
<cfset stResult = oCoapi.deployType(dsn=application.dsn,bDropTable=true,bTestRun=false,dbtype=application.dbtype, bDeployCoapiRecord="false") />


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
		<cfif NOT oRule.isDeployed()>
			<cfset stResult = oRule.deployType(dsn=application.dsn,bDropTable=true,bTestRun=false,dbtype=application.dbtype, bDeployCoapiRecord="false") />
			<cfoutput>#updateProgressBar(value="0.5", text="RULES): Creating #listfirst(qrules.name,".")# table.")#</cfoutput><cfflush>
		</cfif>
		
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
	<!--- Already deployed farCoapi. --->
	<cfif qtypes.name NEQ "farCoapi.cfc">
		<cfset oType = createObject("component", qtypes.typepath) />

		<cftry>
			<cfif NOT oType.isDeployed()>
				<cfset stResult = oType.deployType(dsn=application.dsn,bDropTable=true,bTestRun=false,dbtype=application.dbtype, bDeployCoapiRecord="false") />
				<cfoutput>#updateProgressBar(value="0.6", text="#form.displayName# (TYPES): Creating #listfirst(qtypes.name,".")# table.")#</cfoutput><cfflush>
			</cfif>
		
			<cfcatch type="farcry.core.packages.fourq.tablemetadata.abstractTypeException">
				<cfset stResult.bsucess="false" />
				<cfset stResult.message=cfcatch.message />
			</cfcatch>			
		</cftry>
		
	</cfif>
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
	<cfset oUser = createobject("component","farcry.core.packages.types.farUser") />
	<cfset stUser = oUser.getByUserID(userid="farcry") />
	<cfset stUser.password = form.adminPassword />
	<cfset oUser.setData(stProperties=stUser) />
	
	
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