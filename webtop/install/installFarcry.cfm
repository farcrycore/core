
<cfsetting requesttimeout="600" />



<cfif NOT structKeyExists(session, "stFarcryInstall")>
	<cflocation url="index.cfm" addtoken="false" />
</cfif>

<cfif structKeyExists(url, "restartInstaller")>
	<cfset structDelete(session, "stFarcryInstall") />
	<cflocation url="index.cfm" addtoken="false" />
</cfif>

<!--------------------------------------- 
DETERMINE THE CURRENT VERSION OF FARCRY
 --------------------------------------->
<cfset request.coreVersion = getCoreVersion() />

<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
	<head>
		<title>FarCry Core Framework Installer</title>
		
		<!--- EXT CSS & JS--->
		<link rel="stylesheet" type="text/css" href="../js/ext/resources/css/ext-all.css">
		<script type="text/javascript" src="../js/ext/adapter/ext/ext-base.js"></script>
		<script type="text/javascript" src="../js/ext/ext-all.js"></script>
		
		<!--- INSTALL CSS & JS --->
		<link rel="stylesheet" type="text/css" href="css/install.css">
		<script type="text/javascript" src="js/install.js"></script>

		
	</head>
	<body style="background-color: ##5A7EB9;">
		<div style="border: 8px solid ##eee;background:##fff;width:600px;margin: 50px auto;padding: 20px;color:##666">
			
			<h1>Installing Your FarCry Application</h1>
			<p>&nbsp;</p>
			
			<div id="p2" style="width:100%;text-align:left;"></div>
			
			<div id="installComplete"></div>
			
			<script type="text/javascript">
			var pbar = new Ext.ProgressBar({
		        text:'Ready',
		        id:'pbar2',
		        cls:'left-align',
		        renderTo:'p2'
		    });
		    
			function updateProgressBar(pct, text){
				pbar.updateProgress(pct, text);
			}
			</script>
</cfoutput>

	

<cfoutput>
		<p style="text-align:right;border-top:1px solid ##e3e3e3;margin-top:25px;"><small>You are currently running version <strong>#request.coreVersion.major#-#request.coreVersion.minor#-#request.coreVersion.patch#</strong> of Farcry Core.</small></p>

</cfoutput>


<cfif not session.stFarcryInstall.bComplete>
	<cfset form.applicationName = session.stFarcryInstall.stConfig.applicationName />
	<cfset form.displayName = session.stFarcryInstall.stConfig.displayName />
	<cfset form.locales = session.stFarcryInstall.stConfig.locales />
	<cfset form.DSN = session.stFarcryInstall.stConfig.DSN />
	<cfset form.DBType = session.stFarcryInstall.stConfig.DBType />
	<cfset form.DBOwner = session.stFarcryInstall.stConfig.DBOwner />
	<cfset form.skeleton = session.stFarcryInstall.stConfig.skeleton />
	<cfset form.plugins = session.stFarcryInstall.stConfig.plugins />
	<cfset form.projectInstallType = session.stFarcryInstall.stConfig.projectInstallType />
	
	<!--- Skeletons --->
	<cfset form.skeletonPath = replaceNoCase(form.skeleton, ".", "/", "all") />
	<cfset form.skeletonPath = expandPath("/#form.skeletonPath#") />
	
	
		
	<!--- Project directory name can be changed from the default which is the applicationname --->
	<cfset application.projectDirectoryName =  form.applicationName />
	<cfset application.displayName =  form.displayName />
	
	<!----------------------------------------
	 SET THE DATABASE SPECIFIC INFORMATION 
	---------------------------------------->
	<cfset application.dsn = form.dsn />
	<cfset application.dbtype = form.dbtype />
	<cfset application.dbowner = form.dbowner />
	<!--- <cfset application.locales = this.locales /> --->
	
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
	<cfswitch expression="#form.projectInstallType#">
	<cfcase value="SubDirectory">
		<cfset application.url.webroot = "/#application.projectDirectoryName#" />
		<cfset application.url.webtop = "/farcry/core/webtop" />
	</cfcase>
	<cfcase value="Standalone">
		<cfset application.url.webroot = "" />
		<cfset application.url.webtop = "/farcry/core/webtop" />
	</cfcase>
	<cfcase value="CFMapping">
		<cfset application.url.webroot = "" />
		<cfset application.url.webtop = "/webtop" />
	</cfcase>
	<cfcase value="WebserverMapping">
		<cfset application.url.webroot = "" />
		<cfset application.url.webtop = "/farcry/core/webtop" />
	</cfcase>
	<cfdefaultcase>
		<cfabort showerror="INVALID Install Type.">
	</cfdefaultcase>
	</cfswitch>
	
	
	<cfset application.url.farcry = "#application.url.webtop#" />
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
	<cfset application.plugins = form.plugins />
	
	
	<!---------------------------------------------- 
	INITIALISE THE COAPIUTILITIES SINGLETON
	----------------------------------------------->
	<cfset application.coapi = structNew() />
	<cfset application.coapi.coapiUtilities = createObject("component", "farcry.core.packages.coapi.coapiUtilities").init() />
	<cfset application.coapi.coapiadmin = createObject("component", "farcry.core.packages.coapi.coapiadmin").init() />
	<cfset application.coapi.objectBroker = createObject("component", "farcry.core.packages.fourq.objectBroker").init() />
	
	
	<!------------------------------------------ 
	USE OBJECT BROKER?
	 ------------------------------------------>
	<cfset application.bObjectBroker = false />
	<cfset application.ObjectBrokerMaxObjectsDefault = 0 />
	
	
	<!--- Plugins --->
	<cfset pluginPath = expandPath('/farcry/plugins') />
	<cfdirectory action="list" directory="#pluginPath#" name="qPlugins" />
	
	<!--- Project --->
	<cfset farcryProjectsPath = expandPath('/farcry/projects') />
	<cfdirectory action="list" directory="#farcryProjectsPath#" name="qProjects" />
	
	
	<!--- Base --->
	<cfset installPath = expandPath('/farcry/core/webtop/install') />
	
	<!--- Webroot --->
	<cfset webrootPath = expandPath('/') />
	
	<!--- Webtop --->
	<cfset webtopPath = expandPath('/farcry/core/webtop') />
	
	<cfoutput>#updateProgressBar(value="0.1", text="#form.displayName# (SETUP): Creating your project")#</cfoutput><cfflush>
	
		
	<cfset oZip = createObject("component", "farcry.core.packages.farcry.zip") />
 
	<cfdirectory action="create" directory="#farcryProjectsPath#/#form.applicationName#" mode="777" />
	<cfset oZip.AddFiles(zipFilePath="#farcryProjectsPath#/#form.applicationName#-skeleton.zip", directory="#form.skeletonPath#", recurse="true", compression=0, savePaths="false") />
	<cfset oZip.Extract(zipFilePath="#farcryProjectsPath#/#form.applicationName#-skeleton.zip", extractPath="#farcryProjectsPath#/#form.applicationName#", overwriteFiles="true") />
	<cffile action="delete" file="#farcryProjectsPath#/#form.applicationName#-skeleton.zip" />


	<cfset directoryRemoveSVN(source="#farcryProjectsPath#/#form.applicationName#") />





	<cfswitch expression="#form.projectInstallType#">
	<cfcase value="subDirectory">
		<cfoutput>#updateProgressBar(value="0.2", text="#form.displayName# (SETUP): Copying your project to a subdirectory under the webroot")#</cfoutput><cfflush>
		
		
		<cfset projectWebrootPath = "#webrootPath#/#form.applicationName#" />
		<cfset projectWebrootURL = "http://#cgi.server_name#/#form.applicationName#" />
		<cfdirectory action="create" directory="#webrootPath#/#form.applicationName#" mode="777" />
		<cfset oZip = createObject("component", "farcry.core.packages.farcry.zip") />
		<cfset oZip.AddFiles(zipFilePath="#projectWebrootPath#/project-webroot.zip", directory="#farcryProjectsPath#/#form.applicationName#/www", recurse="true", compression=0, savePaths="false") />
		<cfset oZip.Extract(zipFilePath="#projectWebrootPath#/project-webroot.zip", extractPath="#projectWebrootPath#", overwriteFiles="true") />
		<cffile action="delete" file="#projectWebrootPath#/project-webroot.zip" />
		<cfif directoryExists("#farcryProjectsPath#/#form.applicationName#/wwwCopiedToFolderUnderWebroot")>
			<cfdirectory action="delete" directory="#farcryProjectsPath#/#form.applicationName#/wwwCopiedToFolderUnderWebroot" recurse="true" />
		</cfif>
		<cfdirectory action="rename" directory="#farcryProjectsPath#/#form.applicationName#/www" newdirectory="#farcryProjectsPath#/#form.applicationName#/wwwCopiedToFolderUnderWebroot" />
		
				
<!--- 	
		<cfset directoryCopy(source="#farcryProjectsPath#/#form.applicationName#/www", destination="#projectWebrootPath#", nameconflict="overwrite") /> --->

	</cfcase>
	<cfcase value="standalone">
		<cfoutput>#updateProgressBar(value="0.2", text="#form.displayName# (SETUP): Copying your project to the webroot")#</cfoutput><cfflush>
		<cfset projectWebrootPath = "#webrootPath#" />
		<cfset projectWebrootURL = "http://#cgi.server_name#" />
		
		<cfset oZip = createObject("component", "farcry.core.packages.farcry.zip") />
		<cfset oZip.AddFiles(zipFilePath="#projectWebrootPath#/project-webroot.zip", directory="#farcryProjectsPath#/#form.applicationName#/www", recurse="true", compression=0, savePaths="false") />
		<cfset oZip.Extract(zipFilePath="#projectWebrootPath#/project-webroot.zip", extractPath="#projectWebrootPath#", overwriteFiles="true") />
		<cffile action="delete" file="#projectWebrootPath#/project-webroot.zip" />
		<cfif directoryExists("#farcryProjectsPath#/#form.applicationName#/wwwCopiedToWebroot")>
			<cfdirectory action="delete" directory="#farcryProjectsPath#/#form.applicationName#/wwwCopiedToWebroot" recurse="true" />
		</cfif>		
		<cfdirectory action="rename" directory="#farcryProjectsPath#/#form.applicationName#/www" newdirectory="#farcryProjectsPath#/#form.applicationName#/wwwCopiedToWebroot" />
	
	</cfcase>
	<cfcase value="CFMapping">
		<cfset projectWebrootPath = "#farcryProjectsPath#/#form.applicationName#/www" />
		<cfset projectWebrootURL = "http://#cgi.server_name#" />
		<!--- Leave as is --->
	</cfcase>
	<cfcase value="webserverMapping">
		<cfset projectWebrootPath = "#farcryProjectsPath#/#form.applicationName#/www" />
		<cfset projectWebrootURL = "http://#cgi.server_name#" />
		<!--- Leave as is --->
	</cfcase>
	</cfswitch>
	
	

	<!--- read the master farcryConstructor file --->
	<cfset farcryConstructorLoc = "#installPath#/config_files/farcryConstructor.cfm" />
	<cffile action="read" file="#farcryConstructorLoc#" variable="farcryConstructorContent" />

	<cfset farcryConstructorContent = replaceNoCase(farcryConstructorContent, "@@applicationName@@", "#form.applicationName#", "all") />
	<cfset farcryConstructorContent = replaceNoCase(farcryConstructorContent, "@@applicationDisplayName@@", "#form.displayName#", "all") />
	<cfset farcryConstructorContent = replaceNoCase(farcryConstructorContent, "@@locales@@", "#form.locales#", "all") />
	<cfset farcryConstructorContent = replaceNoCase(farcryConstructorContent, "@@DSN@@", "#form.DSN#", "all") />
	<cfset farcryConstructorContent = replaceNoCase(farcryConstructorContent, "@@DBType@@", "#form.DBType#", "all") />
	<cfset farcryConstructorContent = replaceNoCase(farcryConstructorContent, "@@DBOwner@@", "#form.DBOwner#", "all") />
	<cfset farcryConstructorContent = replaceNoCase(farcryConstructorContent, "@@plugins@@", "#form.plugins#", "all") />	
	<cfset farcryConstructorContent = replaceNoCase(farcryConstructorContent, "@@projectURL@@", "#application.url.webroot#", "all") />
	<cfset farcryConstructorContent = replaceNoCase(farcryConstructorContent, "@@webtopURL@@", "#application.url.webtop#", "all") />

	<cffile action="write" file="#projectWebrootPath#/farcryConstructor.cfm" output="#farcryConstructorContent#" addnewline="false" mode="777" />	
	
	<cfoutput>#updateProgressBar(value="0.2", text="#form.displayName# (SETUP): Copying your plugins under the webroot")#</cfoutput><cfflush>
	<cfif listLen(session.stFarcryInstall.stConfig.plugins)>
		<cfloop list="#session.stFarcryInstall.stConfig.plugins#" index="pluginName">
			<cfif isDefined("session.stFarcryInstall.stConfig.addWebrootMapping#pluginName#") AND session.stFarcryInstall.stConfig["addWebrootMapping#pluginName#"]>
				
				<cfif directoryExists("#pluginPath#/#pluginName#/www")>
					<cfdirectory action="create" directory="#projectWebrootPath#/#pluginName#" mode="777" />
					<cfset oZip = createObject("component", "farcry.core.packages.farcry.zip") />
					<cfset oZip.AddFiles(zipFilePath="#projectWebrootPath#/plugin-webroot.zip", directory="#pluginPath#/#pluginName#/www", recurse="true", compression=0, savePaths="false") />
					<cfset oZip.Extract(zipFilePath="#projectWebrootPath#/plugin-webroot.zip", extractPath="#projectWebrootPath#/#pluginName#", overwriteFiles="true") />
					<cffile action="delete" file="#projectWebrootPath#/plugin-webroot.zip" />
					<cfset directoryRemoveSVN(source="#projectWebrootPath#/#pluginName#") />
				</cfif>
			</cfif>
		</cfloop>
	</cfif>


	
	
	
	<!----------------------------------------------------------------------------------------
	DATABASE INSTALLATION: 
		- Having written the application init in www/Application.cfm (or dbOnly), 
		  continue with the installation
	-----------------------------------------------------------------------------------------> 
	
	<cfset request.bSuccess = true />
	
	<cftry>
		
	    <!--- install farcry --->
	    <cfinclude template="includes/_installFarcry.cfm" />
	
	    <cfcatch type="any">
			<cfdump var="#cfcatch#">
	    </cfcatch>
	
	</cftry>
	
	<cfif request.bSuccess>
		<!--- copied by bowden 7/23/2006. copied from b300.cfm. --->
		<!--- FU updates --->
		<cftry>
			<cfoutput>#updateProgressBar(value="0.9", text="#form.displayName# (Friendly URL): Installing Friendly URLs")#</cfoutput><cfflush>
		   	<cfinclude template="fu.cfm" />
		   	<cfcatch>
				<!--- display form with error message --->
				<cfset errorMsg = "Problem building friendly URL table.">
		 	   	<cfdump var="#cfcatch#">
		    </cfcatch>
		</cftry>
	</cfif>
	
<cfelse>
	<cfset request.bSuccess = true>
</cfif>
	
	
	<cfif request.bSuccess>
	
		<!--- 
		This sets up a cookie on the users system so that if they try and login to the webtop and the webtop can't determine which project it is trying to update,
		it will know what projects they will be potentially trying to edit.  --->
		<cfparam name="server.stFarcryProjects" default="#structNew()#" />
		<cfif not structKeyExists(server.stFarcryProjects, application.projectDirectoryName)>
			<cfset server.stFarcryProjects[application.projectDirectoryName] = structnew() />
			<cfset server.stFarcryProjects[application.projectDirectoryName].displayname = application.displayName />
			<cfset server.stFarcryProjects[application.projectDirectoryName].domains = "" />
		</cfif>
		<cfif not listcontains(server.stFarcryProjects[application.projectDirectoryName].domains,cgi.http_host)>
			<cfset server.stFarcryProjects[application.projectDirectoryName].domains = listappend(server.stFarcryProjects[application.projectDirectoryName].domains,cgi.http_host) />
		</cfif>
	
		<cfoutput>#updateProgressBar(value="1", text="INSTALLATION SUCCESS")#</cfoutput><cfflush>
		
		<cfsavecontent variable="installCompleteHTML">
		<cfoutput>
			<p>&nbsp;</p>
			<div>
				<div class="item">
					<h2><strong>Congratualations!</strong>  Your application has sucessfully installed.</h2>
					<p>The installer has created an administration account for you to logon to the FarCry webtop:</p>
					<p>&nbsp;</p>
					
					<ul>
						<li>Username: <strong>farcry</strong></li>
						<li>Password: <strong>farcry</strong></li>
					</ul>
					
					<p>&nbsp;</p>
					<p class="warning">WARNING: Be sure to <strong>change this account</strong> information on your first login for security reasons.</p>
					<p>&nbsp;</p>

				</div>
				<div class="itemButtons">
					<form name="installComplete" id="installComplete" method="post" action="">
						<input type="button" name="login" value="LOGIN TO THE FARCRY WEBTOP" onClick="alert('Your default Farcry login is\n\n u: farcry\n p: farcry');window.open('#application.url.webtop#/login.cfm?farcryProject=#application.projectDirectoryName#')" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle'" onMouseOut="this.className='normalbttnstyle'" />
						<input type="button" name="view" value="VIEW SITE" onClick="window.open('#application.url.webroot#/index.cfm?updateapp=1')" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle'" onMouseOut="this.className='normalbttnstyle'" />
						<input type="button" name="install" value="INSTALL ANOTHER PROJECT" onClick="window.open('#cgi.script_name#?restartInstaller=1', '_self')" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle'" onMouseOut="this.className='normalbttnstyle'" />
					</form><br /> 
				</div>
			</div>

		</cfoutput>
		</cfsavecontent>
		
		<cfoutput>
		<script type="text/javascript">
			Ext.get('installComplete').dom.innerHTML = '#jsstringformat(installCompleteHTML)#';
		</script>
		</cfoutput>
		<cfset session.stFarcryInstall.bComplete = true />
		
	</cfif>

<cfoutput>
	</div>
</body>
</html>
</cfoutput>
	
	
<!--- REMOVE .SVN FOLDERS FROM ENTIRE DIRECTORY --->
<cffunction name="directoryRemoveSVN" output="true">
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
	
	
	<!--- getFarcryTypes UDF --->
<cffunction name="getFarcryTypes" returntype="string">
	
	<cfthrow detail="DEPRECATED">

</cffunction>



<cffunction name="getFarcryTypes2" returntype="string">
    <cfargument name="packagePath" type="string" required="yes">
    <cfargument name="type" type="string" required="yes" default="types">

    <!--- define local variables --->
    <cfset var lReturn = "">
    <cfset var qDir = "">
    <cfset var filter = "">

    <!--- determine appropriate file filter --->
    <cfif arguments.type eq "rules">
        <cfset filter = "rule*.cfc">
    <cfelse>
        <cfset filter = "dm*.cfc">
    </cfif>
	
    <!--- grab names of rules from farcry rules directory --->
    <cfdirectory directory="#arguments.packagePath#/packages/#arguments.type#" name="qDir" filter="#filter#" sort="name">
	
    <!--- process list accordingly --->
    <cfscript>
    lReturn = valueList(qDir.name);
    lReturn = replaceNoCase(lReturn, ".cfc", "", "ALL");
    </cfscript>

    <cfif arguments.type eq "rules">
        <cfscript>
        lReturn = listPrepend(lReturn, "container");
        lReturn = listDeleteAt(lReturn, listFindNoCase(lReturn, "rules"));
        </cfscript>
    </cfif>

    <cfreturn lReturn>
</cffunction>

<!--- dump UDF --->
<cffunction name="dump">
    <cfargument name="var" type="any">
    <cfdump var="#arguments.var#">
</cffunction>

<!--- abort UDF --->
<cffunction name="abort">
    <cfabort>
</cffunction>

<!--- dot anim UDF --->
<cffunction name="dotAnim">
    <cfoutput>.....</li></ul></td></cfoutput>
    <cfflush>
</cffunction>

<!--- dot anim UDF bookends --->
<cffunction name="dotAnimDiv" access="public" output="true" returntype="string" hint="Return left and right <div>'s for each install item">
	<cfargument name="arg" required="false" default="" type="string" hint="Text to place in <div>'s" />
	<cfargument name="class" required="false" default="" type="string" hint="Class for <div>" />
	
    <cfoutput><div<cfif len(trim(arguments.class))> class="#arguments.class#"</cfif>>#arguments.arg#</div></cfoutput>
    <cfflush />
	
</cffunction>


<cffunction name="getCoreVersion" access="private" returntype="struct" hint="returns a structure containing the major, minor and patch version of farcry.">
	
	<cfset var coreVersion = structNew() />
	
	<cftry>	
		<cffile action="read" file="#expandPath('/farcry/core/major.version')#" variable="coreVersion.major">
		<cffile action="read" file="#expandPath('/farcry/core/minor.version')#" variable="coreVersion.minor">
		<cffile action="read" file="#expandPath('/farcry/core/patch.version')#" variable="coreVersion.patch">

		<cfcatch>		
			<cfset coreVersion.major = 0 />
			<cfset coreVersion.minor = 0 />
			<cfset coreVersion.patch = 0 />
		</cfcatch>
	</cftry>
	
	<cfreturn coreVersion>
</cffunction>



<cffunction name="updateProgressBar" access="public" output="true" returntype="void" hint="Updates the installer progress bar">
	<cfargument name="value" required="false" />
	<cfargument name="text" required="false" />
	
	<cfparam name="request.stUpdateProgress" default="#structNew()#" />
	<cfparam name="request.stUpdateProgress.value" default="0" />
	<cfparam name="request.stUpdateProgress.text" default="" />
	
	<cfif structKeyExists(arguments, "value") AND isNumeric(arguments.value)>
		<cfset request.stUpdateProgress.value = arguments.value />
	</cfif>
	<cfif structKeyExists(arguments, "text")>
		<cfset request.stUpdateProgress.text = arguments.text />
	</cfif>
	
	<cfoutput><script type="text/javascript">updateProgressBar(#request.stUpdateProgress.value#, '#request.stUpdateProgress.text#');</script></cfoutput><cfflush>
</cffunction>
