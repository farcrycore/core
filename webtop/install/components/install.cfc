<cfcomponent>

	<cffunction name="init" returntype="install" output="no" hint="">
		<cfargument name="ui" type="any" required="true" hint="Provides interface to UI" />
		
		<cfset this.uicomponent = arguments.ui />
		
		<cfreturn this />
	</cffunction>
	
	
	<cffunction name="getDBOwner" returntype="string" output="false" access="private" hint="Updates the DB owner with considerations for different database types">
		<cfargument name="dbowner" type="string" required="true" hint="Database owner as provided by user" />
		<cfargument name="dbtype" type="string" required="true" hint="Database type" />
		
		<cfswitch expression="#arguments.dbtype#">
			<cfcase value="mysql,ora" delimiters=",">
				<cfreturn arguments.dbowner />
			</cfcase>
			<cfdefaultcase><!--- Other databases do not have an owner --->
				<cfreturn "" />
			</cfdefaultcase>
		</cfswitch>
	</cffunction>
	
	<cffunction name="getPaths" returntype="struct" output="false" access="private" hint="Returns the file system paths required for installation">
		<cfargument name="webroot" type="string" required="true" hint="The full webroot path" />
		<cfargument name="projectdirectory" type="string" required="true" hint="The project directory name" />
		<cfargument name="projectInstallType" type="string" required="true" hint="Application setup (subDirectory|standalone|CFMapping|webserverMapping)" />
		
		<cfset var stResult = structnew() />
		
		<cfset stResult.webroot = arguments.webroot />
		
		<cfif listcontainsnocase("cfmapping,webservermapping",arguments.projectInstallType)>
			
			<cfset stResult.farcry = expandpath("/farcry") />
			<cfset stResult.webtop = expandpath("/farcry/core/webtop") />
			
		<cfelse>
			
			<cfset stResult.farcry = "#arguments.webroot#/farcry" />
			<cfset stResult.webtop = "#arguments.webroot#/farcry/core/webtop" />
		
		</cfif>
		
		<cfset stResult.projects = "#stResult.farcry#/projects" />
		<cfset stResult.project = "#stResult.projects#/#arguments.projectdirectory#" />
		<cfset stResult.core = "#stResult.farcry#/core" />
		<cfset stResult.plugins = "#stResult.farcry#/plugins" />
		
		<cfset stResult.defaultFilePath = "#arguments.webroot#/files" />
		<cfset stResult.secureFilePath = "#stResult.project#/securefiles" />
		<cfset stResult.imageRoot = "#arguments.webroot#" />
		<cfset stResult.mediaArchive = "#stResult.project#/mediaArchive" />
		
		<cfset stResult.install = "#stResult.core#/webtop/install" />
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="getURLs" returntype="struct" output="false" access="private" hint="Returns URL paths required for installation">
		<cfargument name="installType" type="string" required="true" hint="Type of installation" />
		<cfargument name="projectdirectory" type="string" required="true" hint="The project directory name" />
		
		<cfset var stResult = structnew() />
		
		<cfset stResult.webtop = "/farcry/core/webtop" />
		
		<cfswitch expression="#arguments.installType#">
			<cfcase value="SubDirectory">
				<cfset stResult.webroot = "/#arguments.projectdirectory#" />
			</cfcase>
			<cfcase value="Standalone">
				<cfset stResult.webroot = "" />
			</cfcase>
			<cfcase value="CFMapping">
				<cfset stResult.webroot = "" />
				<cfset stResult.webtop = "/webtop" />
			</cfcase>
			<cfcase value="WebserverMapping">
				<cfset stResult.webroot = "" />
			</cfcase>
		</cfswitch>
		
		<cfset stResult.farcry = "#stResult.webtop#" />
		<cfset stResult.imageRoot = "#stResult.webroot#">
		<cfset stResult.fileRoot = "#stResult.webroot#/files">
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="copyFullDirectory" returntype="void" output="false" access="private" hint="Performs a complete directory copy. Overwrites as necessary.">
		<cfargument name="source" type="string" required="true" hint="Source directory" />
		<cfargument name="destination" type="string" required="true" hint="The destination directory" />
		<cfargument name="intermediate" type="string" required="true" hint="Intermediate directory" />
		<cfargument name="archive" type="string" required="false" hint="The directory to archive the destination to if it already exists. Defaults to no archive.">
		
		<cfset var oZip = createObject("component", "farcry.core.packages.farcry.zip") />
		
		<!--- Archive or delete destination directory --->
		<cfif structkeyexists(arguments,"archive") and len(arguments.archive) and DirectoryExists(arguments.destination)>
			<cfdirectory action="rename" directory="#arguments.destination#" newdirectory="#arguments.archive#" />
		<cfelseif DirectoryExists(arguments.destination)>
			<cfdirectory action="delete" directory="#arguments.destination#" recurse="true" />
		</cfif>
		
		<!--- Create destination directory --->
		<cfdirectory action="create" directory="#arguments.destination#" mode="777" />
		
		<!--- Copy source by creating a zip with them, unzipping into the destination directory, then deleting the zip --->
		<cfset oZip.AddFiles(zipFilePath="#arguments.intermediate#/temp.zip", directory=arguments.source, recurse="true", compression=0, savePaths="false") />
		<cfset oZip.Extract(zipFilePath="#arguments.intermediate#/temp.zip", extractPath=arguments.destination, overwriteFiles="true") />
		<cffile action="delete" file="#arguments.intermediate#/temp.zip" />
		
		<!--- Remove SVN directories --->
		<cfset directoryRemoveSVN(source=arguments.destination) />
	</cffunction>
	
	<cffunction name="copySkeletonToProject" returntype="void" output="false" access="private" hint="Copies skeleton files to the project">
		<cfargument name="skeleton" type="string" required="true" hint="The name of the skeleton" />
		<cfargument name="applicationname" type="string" required="true" hint="The name of the application" />
		<cfargument name="path" type="struct" required="true" hint="Paths relevant to installation" />
		
		
	</cffunction>
	
	<cffunction name="getPackagePaths" returntype="struct" output="false" access="private" hint="Returns package paths required for installation">
		<cfargument name="projectdirectory" type="string" required="true" hint="The project directory name" />
		
		<cfset var stResult = structnew() />
		
		<cfset stResult.packagepath = "farcry.core.packages" />
		<cfset stResult.custompackagepath = "farcry.projects.#arguments.projectdirectory#.packages" />
		<cfset stResult.securitypackagepath = "farcry.core.packages.security" />
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="updateFarcryConstructor" returntype="void" output="false" access="private" hint="Update the farcry constructor">
		<cfargument name="applicationname" type="string" required="true" hint="Application name" />
		<cfargument name="applicationdisplayname" type="string" required="true" hint="" />
		<cfargument name="locales" type="string" required="true" hint="I18N locales" />
		<cfargument name="dsn" type="string" required="true" hint="Datasource" />
		<cfargument name="dbtype" type="string" required="true" hint="Database type" />
		<cfargument name="plugins" type="string" required="true" hint="Application plugins" />
		<cfargument name="projecturl" type="string" required="true" hint="The project URL" />
		<cfargument name="webtopurl" type="string" required="true" hint="The webtop URL" />
		<cfargument name="updateappkey" type="string" required="true" hint="The updateapp key" />
		<cfargument name="path" type="struct" required="true" hint="The paths necessary for installation" />
		
		<cfset var location = "#arguments.path.install#/config_files/farcryConstructor.cfm" />
		<cfset var content = "" />
		<cfset var prop = "" />
		
		<!--- Read the constructor template --->
		<cffile action="read" file="#location#" variable="content" />
		
		<!--- Update variables --->
		<cfloop collection="#arguments#" item="prop">
			<cfif issimplevalue(arguments[prop])>
				<cfset content = replaceNoCase(content, "@@#prop#@@", arguments[prop], "all") />
			</cfif>
		</cfloop>
		
		<cffile action="write" file="#arguments.path.projectwebroot#/farcryConstructor.cfm" output="#content#" addnewline="false" mode="777" />	
	</cffunction>
	
	<cffunction name="getPluginInstallers" access="private" output="false" returntype="query" hint="Get query of library install files. Install files limitd to CFM includes.">
		<cfargument name="plugins" required="true" type="string" hint="List of farcry libraries to process." />
	
		<cfset var qResult=querynew("ATTRIBUTES, DATELASTMODIFIED, DIRECTORY, MODE, NAME, SIZE, TYPE, library") />
		<cfset var qInstalls=querynew("ATTRIBUTES, DATELASTMODIFIED, DIRECTORY, MODE, NAME, SIZE, TYPE, library") />
		<cfset var installdir="" />
		<cfset var aCol=arrayNew(1) />
		<cfset var pluginName="" />
		<cfset var i="" />
	
		<cfloop list="#arguments.plugins#" index="pluginName">
			<cfset installdir=expandpath("/farcry/plugins/#pluginName#/config/install") />
			<cfif directoryexists(installdir)>
				<cfdirectory action="list" directory="#installdir#" filter="*.cfm" name="qInstalls" sort="asc" />
				
				<cfif qinstalls.recordcount>
					<cfset aCol=arrayNew(1) />
					<cfloop from="1" to="#qinstalls.recordcount#" index="i">
						<cfset arrayAppend(acol, pluginName) />
					</cfloop>
					<cfset queryAddColumn(qinstalls, "plugin", aCol) />
					
					<cfquery dbtype="query" name="qResult">
						SELECT * FROM qinstalls
						<cfif qResult.recordcount>
						UNION
						SELECT * FROM qResult
						</cfif>
					</cfquery>
				</cfif>
			
			</cfif>
		</cfloop>
	
		<cfreturn qResult />
	</cffunction>
	
	<cffunction name="runPluginInstallScripts" returntype="void" output="false" access="private" hint="Runs scripts needed for plugin installation">
		<cfargument name="plugins" type="string" required="true" hint="List of application plugins" />
		
		<cfset var qInstalls = getPluginInstallers(plugins=arguments.plugins) />
		
		<cfloop query="qInstalls">
		  <cfinclude template="/farcry/plugins/#qinstalls.Plugin#/config/install/#qinstalls.name#" />
		</cfloop>
	</cffunction>
	
	
	<cffunction name="install" returntype="struct" access="public" output="true" hint="called from Railo to install application">
		<cfargument name="webroot" type="string" required="true" hint="Website webroot path" />
		<cfargument name="bInstallDBOnly" type="boolean" required="true" hint="Database setup only, no files" />
		<cfargument name="applicationName" type="string" required="true" hint="The name of the application in FarCry" />
		<cfargument name="displayName" type="string" required="true" hint="The display name of the application" />
		<cfargument name="dbType" type="string" required="true" hint="The type of the database (mysql|mssql|ora|postgresql)" />
		<cfargument name="dsn" type="string" required="true" hint="The name of the datasource" />
		<cfargument name="dbowner" type="string" required="true" hint="The database owner (only used for MS SQL and Oracle)" />
		<cfargument name="projectInstallType" type="string" required="true" hint="Application setup (subDirectory|standalone|CFMapping|webserverMapping)" />
		<cfargument name="plugins" type="string" required="true" hint="List of the plugins to include with the application" />
		<cfargument name="pluginwebroots" type="string" required="true" hint="The plugin webroots to copy to the project webroot" />
		<cfargument name="skeleton" type="string" required="true" hint="The path of the skeleton to use" />
		<cfargument name="locales" type="string" required="true" hint="Locales to enable in the application" />
		<cfargument name="updateAppKey" type="string" required="true" hint="The key to use when updating the application anonymously" />
		<cfargument name="adminPassword" type="string" required="true" hint="The password to set up for 'farcry'" />
		
		<cfset var stResult = structnew() />
		
		<cftry>
			<cfreturn installInternal(argumentCollection=arguments) />
			
			<cfcatch>
				<cfset this.uicomponent.setError(error=duplicate(cfcatch)) />
				
				<!--- Return results --->
				<cfset stResult.bSuccess = false />
				<cfset stResult.error = cfcatch />
				<cfreturn stResult />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="uninstall" returntype="string" access="public" output="no" hint="called from Railo to install application">
		<cfargument name="path" type="string" />
		<cfargument name="config" type="struct" />
		
		<cftry>
			<cfreturn uninstallInternal(argumentCollection=arguments) />
			
			<cfcatch>
				<cfset this.uicomponent.setError(error=cfcatch) />
			</cfcatch>
		</cftry>
	</cffunction>
	
	
	<cffunction name="installInternal" returntype="struct" access="public" output="true" hint="Called from install() to install application">
		<cfargument name="webroot" type="string" required="true" hint="Website webroot path" />
		<cfargument name="bInstallDBOnly" type="boolean" required="true" hint="Database setup only, no files" />
		<cfargument name="applicationName" type="string" required="true" hint="The name of the application in FarCry" />
		<cfargument name="displayName" type="string" required="true" hint="The display name of the application" />
		<cfargument name="dbType" type="string" required="true" hint="The type of the database (mysql|mssql|ora|postgresql)" />
		<cfargument name="dsn" type="string" required="true" hint="The name of the datasource" />
		<cfargument name="dbowner" type="string" required="true" hint="The database owner (only used for MS SQL and Oracle)" />
		<cfargument name="projectInstallType" type="string" required="true" hint="Application setup (subDirectory|standalone|CFMapping|webserverMapping)" />
		<cfargument name="plugins" type="string" required="true" hint="List of the plugins to include with the application" />
		<cfargument name="pluginwebroots" type="string" required="true" hint="The plugin webroots to copy to the project webroot" />
		<cfargument name="skeleton" type="string" required="true" hint="The path of the skeleton to use" />
		<cfargument name="locales" type="string" required="true" hint="Locales to enable in the application" />
		<cfargument name="updateAppKey" type="string" required="true" hint="The key to use when updating the application anonymously" />
		<cfargument name="adminPassword" type="string" required="true" hint="The password to set up for 'farcry'" />
		
		<cfset var stResult = structnew() />
		<cfset var o = "" /><!--- Object placeholder for looped or generic operations --->
		<cfset var utils = createobject("component","farcry.core.packages.farcry.utils") />
		<cfset var result = structnew() /><!--- Generic function result --->
		
		<!--- Project directory name can be changed from the default which is the applicationname --->
		<cfset var projectDirectoryName =  arguments.applicationName />
		
		<!--- Database sql --->
		<cfset var oDBFactory = "" />
		
		<!--- Path information --->
		<cfset var path = getPaths(webroot=arguments.webroot,projectdirectory=projectDirectoryName,projectInstallType=arguments.projectInstallType) />
		<cfset var urls = getURLS(installtype=arguments.projectInstallType,projectdirectory=projectDirectoryName) />
		<cfset var pp = getPackagePaths(projectDirectory=projectDirectoryName) />
		
		<!--- Plugins --->
		<cfset var pluginName="" />
		
		<!--- For use in COAPI deployment --->
		<cfset var locations = 'project,#utils.listReverse(plugins)#,core' />
		<cfset var thispackage = "" />	
		<cfset var thiscomponent = "" />
		<cfset var stTableMetadata = structnew() />
		<cfset var qCreateFUTable = "" />
		
		
		<!--- Update dbowner for various databases --->
		<cfset arguments.dbowner = getDBOwner(dbowner=arguments.dbOwner,dbtype=arguments.dbtype) />
		<cfset oDBFactory = createobject("component","farcry.core.packages.fourq.DBGatewayFactory").init().getGateway(dsn=arguments.dsn,dbtype=arguments.dbtype,dbowner=arguments.dbowner) />
		
		<cfset this.uiComponent.setProgress(progressmessage="#arguments.displayName# (SETUP): Creating your project",progress=0.1) />
		
		<!--- Extract skeleton to the project --->
		<cfset copyFullDirectory(
			source=expandpath("/" & replaceNoCase(arguments.skeleton, ".", "/", "all")),
			destination=path.project,
			intermediate=path.projects,
			archive="#path.projects#/bkp-#arguments.applicationName#-#DateFormat(now(),'yyyy-mm-dd')#-#timeFormat(now(),'hh-mm-ss')#" ) />
		
		<!--- Determing project webroot path and URL, and copy webroot files as necessary --->
		<cfswitch expression="#arguments.projectInstallType#">
			<cfcase value="subDirectory">
				<cfset this.uiComponent.setProgress(progressmessage="#arguments.displayName# (SETUP): Copying your project to a subdirectory under the webroot",progress=0.2) />
				
				<cfset path.projectwebroot = "#path.webroot#/#arguments.applicationName#" />
				<cfset urls.projectwebroot = "http://#cgi.server_name#/#arguments.applicationName#" />
				
				<cfif NOT bInstallDBOnly>
					<!--- Copy webroot files into subdirectory --->
					<cfset copyFullDirectory(
						source="#path.project#/www",
						destination="#path.webroot#/#arguments.applicationName#",
						intermediate=path.projects,
						archive="#path.webroot#/bkp-#arguments.applicationName#-#DateFormat(now(),'yyyy-mm-dd')#-#timeFormat(now(),'hh-mm-ss')#") />
					
					<!--- Remove existing project WWW archive, and archive the current --->
					<cfif directoryExists("#path.project#/wwwCopiedToFolderUnderWebroot")>
						<cfdirectory action="delete" directory="#path.project#/wwwCopiedToFolderUnderWebroot" recurse="true" />
					</cfif>
					<cfdirectory action="rename" directory="#path.project#/www" newdirectory="#path.project#/wwwCopiedToFolderUnderWebroot" />
				</cfif>
			</cfcase>
			
			<cfcase value="standalone">
				<cfset this.uiComponent.setProgress(progressmessage="#arguments.displayName# (SETUP): Copying your project to the webroot",progress=0.2) />
				
				<cfset path.projectwebroot = path.webroot />
				<cfset urls.projectwebroot = "http://#cgi.server_name#" />
				
				<cfif NOT bInstallDBOnly>
					<!--- Copy webroot files into webroot --->
					<cfset copyFullDirectory(
						source="#path.project#/www",
						destination=path.projectwebroot,
						intermediate=path.projects,
						archive="") />
					
					<!--- Remove existing project WWW archive, and archive the current --->
					<cfif directoryExists("#path.project#/wwwCopiedToWebroot")>
						<cfdirectory action="delete" directory="#path.project#/wwwCopiedToWebroot" recurse="true" />
					</cfif>
					<cfdirectory action="rename" directory="#path.project#/www" newdirectory="#papplicationath.project#/wwwCopiedToWebroot" />
				</cfif>
			</cfcase>
			
			<cfcase value="CFMapping">
				<cfset path.projectwebroot = "#path.project#/www" />
				<cfset urls.projectwebroot = "http://#cgi.server_name#" />
				<!--- Leave as is --->
			</cfcase>
			
			<cfcase value="webserverMapping">
				<cfset path.projectwebroot = "#path.project#/www" />
				<cfset urls.projectwebroot = "http://#cgi.server_name#" />
				<!--- Leave as is --->
			</cfcase>
		</cfswitch>
		
		<!--- Update the constructor --->
		<cfset updateFarcryConstructor(
			applicationName=arguments.applicationName,
			applicationDisplayName=arguments.displayName,
			locales=arguments.locales,
			DSN=arguments.dsn,
			DBType=arguments.dbtype,
			dbowner=arguments.dbowner,
			plugins=arguments.plugins,
			projectURL=urls.webroot,
			webtopURL=urls.webtop,
			updateappKey=arguments.updateappKey,
			path=path) />
		
		<!--- Copy plugins webroot files --->
		<cfif NOT bInstallDBOnly>
			<cfloop list="#arguments.pluginwebroots#" index="pluginName">
				<cfif directoryExists("#path.plugins#/#pluginName#/www")>
					<cfset this.uiComponent.setProgress(progressmessage="#arguments.displayName# (SETUP): Copying your plugins under the webroot",progress=0.3) />
					
					<!--- Copy plugin webroot files into webroot/pluginname --->
					<cfset copyFullDirectory(
						source="#path.plugins#/#pluginName#/www",
						destination="#path.projectwebroot#/#pluginName#",
						intermediate=path.projects,
						archive="") />
				</cfif>
			</cfloop>
		</cfif>
		
		
		<!--- Deploy FarCry system tables --->
		<!--- TODO: These are either being deprecated and should be removed, or should be converted to use oDBFactory --->
			<!--- Create fqaudit table --->
			<cfset this.uiComponent.setProgress(progressmessage="#arguments.displayName# (DATABASE): Creating audit table",progress=0.4) />
			<cfset o = createObject("component", "farcry.core.packages.schema.fqaudit").init(dsn=arguments.dsn,dbtype=arguments.dbtype,dbowner=arguments.dbowner) />
			<cfset o.createTable() />
			
			<!--- Create nested_tree_objects table --->
			<cfset this.uiComponent.setProgress(progressmessage="#arguments.displayName# (DATABASE): Creating nested tree objects table",progress=0.4) />
			<cfset o = createObject("component", "farcry.core.packages.schema.nested_tree_objects").init(dsn=arguments.dsn,dbtype=arguments.dbtype,dbowner=arguments.dbowner) />
			<cfset o.createTable() />
			
			<!--- Setup refObjects table --->
			<cfset this.uiComponent.setProgress(progressmessage="#arguments.displayName# (DATABASE): Creating refObjects table",progress=0.4) />
			<cfset o = createObject("component", "farcry.core.packages.schema.refobjects").init(dsn=arguments.dsn,dbtype=arguments.dbtype,dbowner=arguments.dbowner) />
			<cfset o.createTable() />
			
			<!--- Set up refContainers table --->
			<cfset this.uiComponent.setProgress(progressmessage="#arguments.displayName# (DATABASE): Creating refContainers table",progress=0.4) />
			<cfset o = createObject("component","#pp.packagepath#.rules.container") />
			<cfset o.deployRefContainers(dsn=arguments.dsn,dbtype=arguments.dbtype,dbowner=arguments.dbowner) />
			
			<!--- Setup metadata categories --->
			<cfset this.uiComponent.setProgress(progressmessage="#arguments.displayName# (DATABASE): Creating categorisation table",progress=0.4) />
			<cfset o = createObject("component", "#pp.packagepath#.farcry.category") />
			<cfset o.deployCategories(dsn=arguments.dsn,dbtype=arguments.dbtype,dbowner=arguments.dbowner,bDropTables=true) />
			
			<!--- Setup stats table --->
			<cfset this.uiComponent.setProgress(progressmessage="#arguments.displayName# (DATABASE): Creating statistics tables",progress=0.4) />
			<cfset o = createObject("component", "#pp.packagepath#.farcry.stats") />
			<cfset o.deploy(dsn=arguments.dsn,dbtype=arguments.dbtype,dbowner=arguments.dbowner,bDropTable=true) />
		
		<!--- Deploy COAPI tables --->
		<cfloop list="rules,types" index="thispackage">
			<cfif thispackage eq "rules">
				<cfset this.uiComponent.setProgress(progressmessage="#arguments.displayName# (RULES): Creating rule and container",progress=0.5) />
			<cfelse>
				<cfset this.uiComponent.setProgress(progressmessage="#arguments.displayName# (TYPES): Creating content tables",progress=0.6) />
			</cfif>
			<cfloop list="#utils.getComponents(package=thispackage,locations=locations,path=path)#" index="thiscomponent">
				<cfset o = createObject("component",utils.getPath(package=thispackage,component=thiscomponent,locations=locations,path=path,projectDirectoryName=projectDirectoryName)) />
				<cfset stMD = getMetadata(o) />
				
				<cfif not structkeyexists(stMD,"bAbstract") or not stMD.bAbstract>
					<cfset stTableMetadata[thiscomponent] = createobject("component","farcry.core.packages.fourq.TableMetadata").init() />
					<cfset stTableMetadata[thiscomponent].parseMetadata(md=stMD) />
					<cfset oDBFactory.deployType(metadata=stTableMetadata[thiscomponent],bDropTable=true,bTestRun=false,dsn=arguments.dsn,dbtype=arguments.dbtype,dbowner=arguments.dbowner) />
				</cfif>
			</cfloop>
		</cfloop>
		
		<!--- Find and run plugin install includes --->
		<cfset this.uiComponent.setProgress(progressmessage="#arguments.displayName# (PLUGINS): Setting up plugins",progress=0.7) />
		<cfset runPluginInstallScripts(arguments.plugins) />
		
		<!--- Import skeleton data into the database --->
		<cfset this.uiComponent.setProgress(progressmessage="#arguments.displayName# (SKELETON): Installing Skeleton Data...",progress=0.8) />
		<cfset o = createObject("component", "#arguments.skeleton#.install.manifest") />
		<cfset result = o.install(dsn=arguments.dsn,dbowner=arguments.dbowner,dbtype=arguments.dbtype,path=path,factory=oDBFactory,stTableMetadata=stTableMetadata) />
		
		<!--- Update the farcry password --->
		<cfquery datasource="#arguments.dsn#">
			update		#arguments.dbowner#farUser
			set			password=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.adminPassword#" />
			where		userid=<cfqueryparam cfsqltype="cf_sql_varchar" value="farcry" />
		</cfquery>
		
		<!--- Remove the skelton instalation files --->
		<cfset this.uiComponent.setProgress(progressmessage="#arguments.displayName# (SKELETON): Removing the skelton instalation files",progress=0.85) />
		<cftry>
			<cfdirectory action="delete" directory="#path.project#/install" recurse="true" />
			
			<cfcatch type="any"><!--- ignore ---></cfcatch>
		</cftry>
		
		<!--- Flag the app as uninitialised --->
		<cfset application.bInit = false />
		
		<!--- If the reffriendlyURL table exists, drop it --->
		<cfset this.uiComponent.setProgress(progressmessage="#arguments.displayName# (SETUP): (Friendly URLs): Installing Friendly URLs",progress=0.9) />
		<cftry>
			<cfparam name="bTableExists" default="1" type="boolean" />
			
			<!--- not a great way, but this (at this stage) is quicker and easier that doing a case for all DB vendors. Error will be thown if table doesn't exist --->
			<cfquery name="qCheck" datasource="#arguments.dsn#" maxrows="1">
				SELECT 		objectid 
				FROM 		#arguments.dbowner#reffriendlyURL
			</cfquery>
			
			<cfif qCheck.recordCount>
				<cfquery name="qDrop" datasource="#arguments.dsn#">
					DROP TABLE #arguments.dbowner#reffriendlyURL
				</cfquery>
				<cfset bTableExists = 0 />
			</cfif>
			
			<cfcatch type="database">
				<cfset bTableExists = 0 />
			</cfcatch>
		</cftry>
		          
		<!--- Create reffriendlyURL --->
		<cftry>
			<cfif NOT bTableExists>
				<!--- only create table if one doesnt exist --->
				<!--- bowden --->
				
				<cfswitch expression="#arguments.dbtype#">
					<cfcase value="ora">
						<cfquery name="qCreateFUTable" datasource="#arguments.dsn#">
							CREATE TABLE #arguments.dbowner#reffriendlyURL ( 
								objectid    			varchar2(50) NOT NULL,
								refobjectid 			varchar2(50) NOT NULL,
								friendlyurl	            varchar2(4000) NULL,
								query_string            varchar2(4000) NULL,
								datetimelastupdated     date NULL,
								status      			numeric NULL 
							)
						</cfquery>
					</cfcase>
					
					<cfdefaultcase>
						<cfquery name="qCreateFUTable" datasource="#arguments.dsn#">
							CREATE TABLE #arguments.dbowner#reffriendlyURL ( 
								objectid    		varchar(50) NOT NULL,
								refobjectid 		varchar(50) NOT NULL,
								<cfswitch expression="#arguments.dbtype#">
									<cfcase value="ODBC,MSSQL">
										friendlyurl			varchar(8000) NULL,
										query_string 		varchar(8000) NULL,
										datetimelastupdated datetime NULL,
									</cfcase>
									<cfdefaultcase>
										friendlyurl 		text NULL,
										query_string		text NULL,
										datetimelastupdated timestamp NULL,
									</cfdefaultcase>
								</cfswitch>
								status      		numeric NULL 
							)
						</cfquery>
					</cfdefaultcase>
				</cfswitch>
			</cfif>
			
			<cfcatch>
				<!--- TODO: exception handling --->
				<cfrethrow />
			</cfcatch>
		</cftry>
		
		<!--- IF WE ONLY WANTED A DB INSTALL, WE NEED TO DELETE THE TEMPORARY APPLICATION --->
		<cfif bInstallDBOnly>
			<cfdirectory action="delete" directory="#path.project#" mode="777" recurse="yes" />
		</cfif>
		
		<!--- Return results --->
		<cfset stResult.bSuccess = true />
		<cfset stResult.projectDirectoryName = projectDirectoryName />
		<cfset stResult.adminuser = "farcry" />
		<cfset stResult.adminpassword = arguments.adminPassword />
		<cfset stResult.siteurl = "http://#cgi.http_host##urls.webroot#/index.cfm?updateapp=#arguments.updateappKey#" />
		<cfset stResult.webtopurl = "http://#cgi.http_host##urls.webtop#/login.cfm" />
		<cfif NOT bInstallDBOnly>
			<cfset stResult.webtopurl = "#stResult.webtopurl#?farcryProject=#projectDirectoryName#" />
		</cfif>
		
		<cfset this.uiComponent.setProgress(progressmessage="INSTALLATION SUCCESS",progress=1) />
		
		<cfreturn stResult />
	</cffunction>

	<cffunction name="uninstallInternal" returntype="string" access="public" output="no" hint="Called from uninstall() to uninstall application">
		<cfargument name="path" type="string" />
		<cfargument name="config" type="struct" />
		
		<!--- TODO uninstall code --->
		
		<cfreturn 'Farcry is now successfully removed' />
	</cffunction>
	
	
	<!--- Sanity checks --->
	<cffunction name="checkDSN" access="private" returntype="struct" output="false" hint="Check to see whether the DSN entered by the user is valid">
		<cfargument name="DSN" type="string" required="true" hint="DSN to check" />
		<cfargument name="DBOwner" type="string" required="true" hint="The database owner" />

		<cfset var qCheckDSN = queryNew("blah") />
		<cfset var stResult = structNew() />
		<cfset stResult.bSuccess = true />
		<cfset stResult.errorTitle = "" />
		<cfset stResult.errorDescription = "" />
		
		<cftry>
			<!--- run any query to see if the DSN is valid --->
			<cfquery name="qCheckDSN" datasource="#arguments.DSN#">
				SELECT 'patrick' AS theMAN
			</cfquery>
			
			<cfcatch type="database">
				<cftry>						
					<!--- First check for oracle will fail. This is the oracle check.
					Run any query to see if the DSN is valid --->
					<cfquery name="qCheckDSN" datasource="#arguments.DSN#">
						SELECT 'patrick' AS theMAN from dual
					</cfquery>
					
					<cfcatch type="database">
						<cftry>
							<!--- Both checks for HSQLDB will fail. see if this might an HSQLDB --->
							<cfquery name="qCheckDSN" datasource="#arguments.DSN#">
								SET READONLY FALSE;
							</cfquery>
							
							<cfcatch type="database">
								<cfset stResult.bSuccess = false />
								<cfset stResult.errorTitle = "Invalid Datasource (DSN)" />
								<cfsavecontent variable="stResult.errorDescription">
									<cfoutput>
									<p>Your DSN (#arguments.DSN#) is invalid.</p>
									<p>Please check it is setup and verifies within the ColdFusion Administrator.</p>
									</cfoutput>
								</cfsavecontent>
							</cfcatch>
						</cftry>
					</cfcatch>
					
				</cftry>
			</cfcatch>
			
		</cftry>
		
		<cfif stResult.bSuccess>
			<cfset stResult = checkExistingDatabase(dbOwner="#arguments.dbOwner#",dsn="#arguments.DSN#") />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="checkExistingDatabase" access="private" returntype="struct" output="false" hint="Check to see whether a farcry database exists">
		<cfargument name="DSN" type="string" required="true" hint="DSN to check" />
		<cfargument name="DBOwner" type="string" required="true" hint="The database owner" />

		<cfset var qCheckDSN = queryNew("blah") />
		<cfset var bExists = true />
		<cfset var stResult = structNew() />
		<cfset stResult.bSuccess = true />
		<cfset stResult.errorTitle = "" />
		<cfset stResult.errorDescription = "" />

		<cftry>
		
			<!--- run any query to see if there is an existing farcry project in the database --->
			<cfquery name="qCheckDSN" datasource="#arguments.DSN#">
				SELECT	count(objectId) AS theCount
				FROM	#arguments.DBOwner#refObjects
			</cfquery>
			
			<cfcatch type="database">
				<cfset bExists = false />
			</cfcatch>
			
		</cftry>
		
		<cfif bExists>
			
			<cfset stResult.bSuccess = false />
			<cfset stResult.errorTitle = "Existing Farcry Database Found" />
			<cfsavecontent variable="stResult.errorDescription">
				<cfoutput>
				<p>Your database contains an existing Farcry application.</p>
				<p>You can only install into an empty database.</p>
				</cfoutput>			
			</cfsavecontent>
		
		</cfif>		
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="checkDBType" access="private" returntype="struct" output="false" hint="Check to see whether the database is Oracle">
		<cfargument name="DSN" type="string" required="true" hint="DSN to check" />
		<cfargument name="DBType" type="string" required="true" hint="Type of DB to check" />
		<cfargument name="DBOwner" type="string" required="true" hint="The database owner" />

		<cfset var qCheckDSN = queryNew("blah") />
		<cfset var bCorrectDB = true />
		<cfset var databaseTypeName = "" />
		<cfset var stResult = structNew() />
		<cfset stResult.bSuccess = true />
		<cfset stResult.errorTitle = "" />
		<cfset stResult.errorDescription = "" />

		<cftry>
			<cfswitch expression="#arguments.DBType#">
			<cfcase value="ora">
				<cfset databaseTypeName = "Oracle" />
				<!--- run an oracle specific query --->
				<cfquery name="qCheckDSN" datasource="#arguments.DSN#">
				SELECT 'aj' AS theMAN from dual
				</cfquery>
			</cfcase>
			<cfcase value="MSSQL">
				<cfset databaseTypeName = "MSSQL" />
				<!--- run an MSSQL specific query --->
				<cfquery name="qCheckDSN" datasource="#arguments.DSN#">
				SELECT	count(*) AS theCount
				FROM	#arguments.DBOwner#sysobjects
				</cfquery>
			</cfcase>
			<cfcase value="MySQL">
				<cfset databaseTypeName = "MySQL" />						
				<!--- test temp table creation --->
				<cfquery name="qTestPrivledges" datasource="#arguments.dsn#">
					create temporary table tblTemp1
					(
					test  VARCHAR(255) NOT NULL
					)
				</cfquery>	
				<!--- delete temp table --->
				<cfquery name="qDeleteTemp" datasource="#arguments.dsn#">
					DROP TABLE IF EXISTS tblTemp1
				</cfquery>							
			</cfcase>
			<cfcase value="Postgres">
				<cfset databaseTypeName = "Postgres" />						
				<!--- TODO: perform test to validate dbtype is postgres --->									
			</cfcase>
			
			<cfcase value="HSQLDB">
				<cfset databaseTypeName = "HSQLDB" />
				<!--- TODO: perform test to validate dbtype is HSQLDB --->									
			</cfcase>
			
			</cfswitch>
			
			<cfcatch type="database">
				<cfset bCorrectDB = false />
			</cfcatch>
			
		</cftry>
		
		<cfif not bCorrectDB>
			
			<cfset stResult.bSuccess = false />
			<cfset stResult.errorTitle = "Not A #databaseTypeName# Database" />
			<cfsavecontent variable="stResult.errorDescription">
				<cfoutput>
				<p>Your database does not appear to be #databaseTypeName#.</p>
				<p>Please check the database type and try again.</p>
				<cfif arguments.dbtype eq "MySQL"><p>Please check that the database user has permission to create temporary tables.</p></cfif>
				</cfoutput>			
			</cfsavecontent>
		
		</cfif>		
		
		<cfreturn stResult />
	</cffunction>
	

	<!--- Validate ---->
	<cffunction name="validateDetails" returntype="struct" output="no" hint="Called to validate application details">
		<cfargument name="config" type="struct" />
		
		<cfset var stResult = structnew() />
		
		<cfif not structkeyexists(arguments.config,"displayName") and len(arguments.config.displayName)>
			<cfset stResult["displayName"] = "You must select the project name." />
		</cfif>
		
		<cfif not structkeyexists(arguments.config,"applicationName") and not len(arguments.config.applicationName)>
			<cfset stResult["applicationName"] = "You must select the project folder name." />
		<cfelseif not refindnocase("^[a-z][\w_]+$",arguments.config.applicationName)><!--- Check that it's a valid variable name --->
			<cfset stResult["applicationName"] = "- no spaces<br />- only alpha numerics and _ (underscore)<br />- must start with an alpha" />
		<cfelseif directoryExists(expandPath("/farcry/projects/#arguments.config.applicationName#"))><!--- Check its not already created. --->
			<cfset stResult["applicationName"] = "The project folder name <b>#arguments.config.applicationName#</b> is invalid or already exists on this server. Please remove this project folder or select an alternative name." />
		</cfif>
	
		<cfif not len(arguments.config.locales)>
			<cfset stResult["locales"] = "You must select at lease 1 locale." />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="validateDatabase" returntype="struct" output="no" hint="Called to validate database details">
		<cfargument name="config" type="struct" />
		
		<cfset var stResult = structnew() />
		<cfset var stDB = structnew() />
		
		<cfif not structkeyexists(arguments.config,"dbType") and len(arguments.config.dbType)>
			<cfset stResult.dbType = "You must select the database type" />
		</cfif>
		
		<cfif not structkeyexists(arguments.config,"dsn") and len(arguments.config.dsn)>
			<cfset stResult.dbType = "You must enter the database source" />
		</cfif>
		
		<cfif not structisempty(stResult)>
			<cfreturn stResult />
		</cfif>
		
		<cfset stDB = checkDSN(DBOwner=arguments.config.DBOwner,dsn=arguments.config.dsn) />
		
		<cfif not stDB.bSuccess>
			<cfset stResult.dsn = stDB.errorDescription />
		</cfif>
		
		<cfset stDB = checkDBType(DBOwner=arguments.config.DBOwner,dsn=arguments.config.dsn,DBType=arguments.config.DBType) />
		
		<cfif not stDB.bSuccess>
			<cfset stResult.dbType = stDB.errorDescription />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="validateSkeleton" returntype="struct" output="no" hint="Called to validate the skeleton">
		<cfargument name="config" type="struct" />
		
		<cfset var stResult = structnew() />
		
		<cfif structkeyexists(arguments.config,"skeleton") and not len(trim(arguments.config.skeleton))>
			<cfset stResult.skeleton = "You must select a skeleton in order to proceed." />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="validatePlugins" returntype="struct" output="no" hint="Called to validate the plugins (result includes 'plugins' aggregate, and 'plugin-[name]' specific errors)">
		<cfargument name="config" type="struct" />
		
		<cfset var stResult = structnew() />
		<cfset var oSkeletonManifest = createObject("component", "#arguments.config.skeleton#.install.manifest") />
		<cfset var qPlugins = getPlugins() />
		
		<cfloop query="qPlugins">
			<cfif listContainsNoCase(oSkeletonManifest.lRequiredPlugins, qPlugins.value) AND NOT listContainsNoCase(arguments.config.plugins, qPlugins.value)>
				<cfparam name="stResult.plugins" default="" />
				<cfset stResult.plugins = "#stResult.plugins#- #qPlugins.label# is required for the selected skeleton<br />" />
				<cfset stResult["plugin-#qPlugins.value#"] = "This plugin is required by the selected skeleton." />
			</cfif>
		</cfloop>
		
		<cfreturn stResult />
	</cffunction>
	

	<cffunction name="getCoreVersion" returntype="struct" output="false" access="public" hint="Returns a struct containing core version numbers">
		<cfset var coreVersion = structnew() />
		
		<cffile action="read" file="#expandpath('/farcry/core/major.version')#" variable="coreVersion.major" />
		<cffile action="read" file="#expandpath('/farcry/core/minor.version')#" variable="coreVersion.minor" />
		<cffile action="read" file="#expandpath('/farcry/core/patch.version')#" variable="coreVersion.patch" />
		
		<cfreturn coreVersion />
	</cffunction>


	<cffunction name="getLocales" returntype="query" access="public" output="no" hint="Returns a query containing the values and labels for a locales list">
		<cfset var aLocales = createObject("java","java.util.Locale").getAvailableLocales() />
		<cfset var qLocales = querynew("value,label") />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#arrayLen(aLocales)#" index="i">
			<cfif listLen(aLocales[i],"_") EQ 2>
				<cfset queryaddrow(qLocales) />
				<cfset querysetcell(qLocales,"value",aLocales[i].toString()) />
				<cfset querysetcell(qLocales,"label",aLocales[i].getDisplayName()) />
			</cfif>
		</cfloop>
		
		<cfquery dbtype="query" name="qLocales">
			select		*
			from		qLocales
			order by	label
		</cfquery>

		<cfreturn qLocales />
	</cffunction>
	
	<cffunction name="getSkeletons" returntype="query" access="public" output="no" hint="Returns a query containing the values and labels and core support for a skeleton list">
		<cfset var qDirs = "" />
		<cfset var qSkeletons = querynew("value,label,supported") />
		<cfset var manifest = "" />
		<cfset var coreVersion = getCoreVersion() />
		
		<cfdirectory action="list" directory="#expandpath('/farcry/skeletons')#" name="qDirs" />
		
		<cfloop query="qDirs">
			<cfif qDirs.type EQ "DIR" and fileExists(expandpath("/farcry/skeletons/#qDirs.name#/install/manifest.cfc"))>
				<cfset manifest = createObject("component", "farcry.skeletons.#qDirs.name#.install.manifest") />
				<cfset queryaddrow(qSkeletons) />
				<cfset querysetcell(qSkeletons,"value","farcry.skeletons.#qDirs.name#") />
				<cfset querysetcell(qSkeletons,"label",manifest.name) />
				<cfset querysetcell(qSkeletons,"supported",manifest.isSupported(coreMajorVersion="#coreVersion.major#", coreMinorVersion="#coreVersion.minor#", corePatchVersion="#coreVersion.patch#")) />
			</cfif>
		</cfloop>
		
		<cfdirectory action="list" directory="#expandpath('/farcry/projects')#" name="qDirs" />
		
		<cfloop query="qDirs">
			<cfif qDirs.type EQ "DIR" and fileExists(expandpath("/farcry/projects/#qDirs.name#/install/manifest.cfc"))>
				<cfset manifest = createObject("component", "farcry.projects.#qDirs.name#.install.manifest") />
				<cfset queryaddrow(qSkeletons) />
				<cfset querysetcell(qSkeletons,"value","farcry.projects.#qDirs.name#") />
				<cfset querysetcell(qSkeletons,"label",manifest.name) />
				<cfset querysetcell(qSkeletons,"supported",manifest.isSupported(coreMajorVersion="#coreVersion.major#", coreMinorVersion="#coreVersion.minor#", corePatchVersion="#coreVersion.patch#")) />
			</cfif>
		</cfloop>
		
		<cfquery dbtype="query" name="qSkeletons">
			select		*
			from		qSkeletons
			order by	label
		</cfquery>
		
		<cfreturn qSkeletons />
	</cffunction>
	
	<cffunction name="getPlugins" returntype="query" access="public" output="no" hint="Returns a query containing the values, label, supported, description and mapping requirement for each plugin">
		<cfset var qDirs = "" />
		<cfset var oManifest = "" />
		<cfset var pluginPath = expandpath('/farcry/plugins') />
		<cfset var coreVersion = getCoreVersion() />
		<cfset var qPlugins = querynew("value,label,supported,description,requiresmapping") />
		
		<cfdirectory action="list" directory="#pluginPath#" name="qDirs" />
		
		<cfloop query="qDirs">
			<cfif qDirs.type EQ "DIR" and fileExists("#pluginPath#/#qDirs.name#/install/manifest.cfc")>
				<cfset oManifest = createObject("component", "farcry.plugins.#qDirs.name#.install.manifest")>
				
				<cfset queryaddrow(qPlugins) />
				<cfset querysetcell(qPlugins,"value",qDirs.name) />
				<cfset querysetcell(qPlugins,"label",oManifest.name) />
				<cfset querysetcell(qPlugins,"supported",oManifest.isSupported(coreMajorVersion=coreVersion.major,coreMinorVersion=coreVersion.minor,corePatchVersion=coreVersion.patch)) />
				<cfset querysetcell(qPlugins,"description",oManifest.description) />
				<cfset querysetcell(qPlugins,"requiresmapping",directoryExists("#pluginPath#/#qDirs.name#/www")) />
			</cfif>
		</cfloop>
		
		<cfreturn qPlugins />
	</cffunction>
	
	
	<cffunction name="directoryRemoveSVN" returntype="void" output="false" access="private" hint="Remove .svn folders from entire directory">
		<cfargument name="source" required="true" type="string">
		
		<cfset var contents = "" />
		  
		<cfdirectory action="list" directory="#arguments.source#" name="contents">
		
		<cfloop query="contents">
		  <cfif contents.type eq "dir">
		      <cfif contents.name eq ".svn">
		          <cfdirectory action="delete" directory="#arguments.source#/#contents.name#" recurse="true" />
		      <cfelse>
		          <cfset directoryRemoveSVN(arguments.source & "/" & contents.name) />
		      </cfif>
		      
		  </cfif>
		</cfloop>
	</cffunction>	

</cfcomponent>