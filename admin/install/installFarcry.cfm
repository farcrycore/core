
<cfsetting requesttimeout="600" />



<cfif NOT structKeyExists(session, "stFarcryInstall")>
	<cflocation url="index.cfm" addtoken="false" />
</cfif>

<cfset form.applicationName = session.stFarcryInstall.stConfig.applicationName />
<cfset form.DSN = session.stFarcryInstall.stConfig.DSN />
<cfset form.DBType = session.stFarcryInstall.stConfig.DBType />
<cfset form.DBOwner = session.stFarcryInstall.stConfig.DBOwner />
<cfset form.skeleton = session.stFarcryInstall.stConfig.skeleton />
<cfset form.plugins = session.stFarcryInstall.stConfig.plugins />
<cfset form.projectInstallType = session.stFarcryInstall.stConfig.projectInstallType />
<cfset form.webtopInstallType = session.stFarcryInstall.stConfig.webtopInstallType />

<!--- Skeletons --->
<cfset form.skeletonPath = replaceNoCase(form.skeleton, ".", "/", "all") />
<cfset form.skeletonPath = expandPath("/#form.skeletonPath#") />


<!--- Plugins --->
<cfset pluginPath = expandPath('/farcry/plugins') />
<cfdirectory action="list" directory="#pluginPath#" name="qPlugins" />

<!--- Project --->
<cfset farcryProjectsPath = expandPath('/farcry/projects') />
<cfdirectory action="list" directory="#farcryProjectsPath#" name="qProjects" />


<!--- Base --->
<cfset installPath = expandPath('/farcry/core/admin/install') />

<!--- Webroot --->
<cfset webrootPath = expandPath('/') />

<!--- Webtop --->
<cfset webtopPath = expandPath('/farcry/core/admin') />



	<cfoutput><div>CREATING PROJECT...</cfoutput><cfflush>
		
	<cfset oZip = createObject("component", "farcry.core.packages.farcry.zip") />

	<cfset oZip.AddFiles(zipFilePath="#farcryProjectsPath#/#form.applicationName#-skeleton.zip", directory="#form.skeletonPath#", recurse="true", compression=0, savePaths="false") />
	<cfset oZip.Extract(zipFilePath="#farcryProjectsPath#/#form.applicationName#-skeleton.zip", extractPath="#farcryProjectsPath#/#form.applicationName#", overwriteFiles="true") />
	<cffile action="delete" file="#farcryProjectsPath#/#form.applicationName#-skeleton.zip" />


	<cfset directoryRemoveSVN(source="#farcryProjectsPath#/#form.applicationName#") />



	<!--- read the master farcryConstructor file --->
	<cfset farcryConstructorLoc = "#installPath#/config_files/farcryConstructor.cfm" />
	<cffile action="read" file="#farcryConstructorLoc#" variable="farcryConstructorContent" />

	<cfset farcryConstructorContent = replaceNoCase(farcryConstructorContent, "@@applicationName@@", "#form.applicationName#", "all") />
	<cfset farcryConstructorContent = replaceNoCase(farcryConstructorContent, "@@DSN@@", "#form.DSN#", "all") />
	<cfset farcryConstructorContent = replaceNoCase(farcryConstructorContent, "@@DBType@@", "#form.DBType#", "all") />
	<cfset farcryConstructorContent = replaceNoCase(farcryConstructorContent, "@@DBOwner@@", "#form.DBOwner#", "all") />
	<cfset farcryConstructorContent = replaceNoCase(farcryConstructorContent, "@@plugins@@", "#form.plugins#", "all") />
	
	<cfif form.projectInstallType EQ "subDirectory">
		<cfset farcryConstructorContent = replaceNoCase(farcryConstructorContent, "@@projectURL@@", "/#form.applicationName#", "all") />
	<cfelse>
		<cfset farcryConstructorContent = replaceNoCase(farcryConstructorContent, "@@projectURL@@", "", "all") />
	</cfif>
	
	<cffile action="write" file="#farcryProjectsPath#/#form.applicationName#/www/farcryConstructor.cfm" output="#farcryConstructorContent#" addnewline="false" mode="777" />	

	<cfoutput>COMPLETE</div></cfoutput><cfflush>


	<cfswitch expression="#form.projectInstallType#">
	<cfcase value="subDirectory">
		<cfoutput><div>COPYING PROJECT TO SUBDIRECTORY UNDER THE WEBROOT...</cfoutput><cfflush>
		
		
		<cfset projectWebrootPath = "#webrootPath#/#form.applicationName#" />
		<cfset projectWebrootURL = "http://#cgi.server_name#/#form.applicationName#" />
		<cfdirectory action="create" directory="#webrootPath#/#form.applicationName#" mode="777" />
		<cfset oZip = createObject("component", "farcry.core.packages.farcry.zip") />
		<cfset oZip.AddFiles(zipFilePath="#projectWebrootPath#/project-webroot.zip", directory="#farcryProjectsPath#/#form.applicationName#/www", recurse="true", compression=0, savePaths="false") />
		<cfset oZip.Extract(zipFilePath="#projectWebrootPath#/project-webroot.zip", extractPath="#projectWebrootPath#", overwriteFiles="true") />
		<cffile action="delete" file="#projectWebrootPath#/project-webroot.zip" />
		<cfdirectory action="rename" directory="#farcryProjectsPath#/#form.applicationName#/www" newdirectory="wwwCopiedToFolderUnderWebroot" />
		
				
<!--- 	
		<cfset directoryCopy(source="#farcryProjectsPath#/#form.applicationName#/www", destination="#projectWebrootPath#", nameconflict="overwrite") /> --->
		<cfoutput>COMPLETE</div></cfoutput><cfflush>
	</cfcase>
	<cfcase value="webroot">
		<cfoutput><div>COPYING PROJECT TO THE WEBROOT...</cfoutput><cfflush>
		<cfset projectWebrootPath = "#webrootPath#" />
		<cfset projectWebrootURL = "http://#cgi.server_name#" />
		
		<cfset oZip = createObject("component", "farcry.core.packages.farcry.zip") />
		<cfset oZip.AddFiles(zipFilePath="#projectWebrootPath#/project-webroot.zip", directory="#farcryProjectsPath#/#form.applicationName#/www", recurse="true", compression=0, savePaths="false") />
		<cfset oZip.Extract(zipFilePath="#projectWebrootPath#/project-webroot.zip", extractPath="#projectWebrootPath#", overwriteFiles="true") />
		<cffile action="delete" file="#projectWebrootPath#/project-webroot.zip" />
		<cfdirectory action="rename" directory="#farcryProjectsPath#/#form.applicationName#/www" newdirectory="#farcryProjectsPath#/#form.applicationName#/wwwCopiedToWebroot" />
		<!--- 
		<cfset directoryCopy(source="#farcryProjectsPath#/#form.applicationName#/www", destination="#projectWebrootPath#", nameconflict="overwrite") /> --->
		<cfoutput>COMPLETE</div></cfoutput><cfflush>
	</cfcase>
	<cfcase value="farcry">
		<cfset projectWebrootURL = "http://#cgi.server_name#" />
		<!--- Leave as is --->
	</cfcase>
	</cfswitch>
	
	
	<cfswitch expression="#form.webtopInstallType#">
	<cfcase value="project">
		<cfoutput><div>COPYING WEBTOP TO PROJECT....</cfoutput><cfflush>
		<cfset oZip = createObject("component", "farcry.core.packages.farcry.zip") />
		<cfset oZip.AddFiles(zipFilePath="#projectWebrootPath#/webtop.zip", directory="#webtopPath#", recurse="true", compression=0, savePaths="false") />
		<cfset oZip.Extract(zipFilePath="#projectWebrootPath#/webtop.zip", extractPath="#projectWebrootPath#/webtop", overwriteFiles="true") />
		<cffile action="delete" file="#projectWebrootPath#/webtop.zip" />
		
		
		<cfset directoryRemoveSVN(source="#projectWebrootPath#/webtop") />
	
		<cfoutput>COMPLETE</div></cfoutput><cfflush>
		<!--- <cfset directoryCopy(source="#webtopPath#", destination="#projectWebrootPath#/webtop", nameconflict="overwrite") /> --->
	</cfcase>
	<cfcase value="farcry">
		<!--- Leave as is --->
	</cfcase>
	</cfswitch>

	
	<!----------------------------------------------------------------------------------------
	DATABASE INSTALLATION: 
		- Having written the application init in www/Application.cfm (or dbOnly), 
		  continue with the installation
	-----------------------------------------------------------------------------------------> 
	
	<cfset request.bSuccess = true />
	
	<cftry>
			
	    <cfoutput>
			<div id="content">
			<h2>Installing your FarCry project</h2>
		</cfoutput>
	    <cfflush />

	
	
		<!--- Project directory name can be changed from the default which is the applicationname --->
		<cfset application.projectDirectoryName =  form.applicationName />
		
		<!----------------------------------------
		 SET THE DATABASE SPECIFIC INFORMATION 
		---------------------------------------->
		<cfset application.dsn = form.dsn />
		<cfset application.dbtype = form.dbtype />
		<cfset application.dbowner = form.dbowner />
		<!--- <cfset application.locales = this.locales /> --->
		
		<cfif application.dbtype EQ "mssql" AND NOT len(this.dbowner)>
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
		   	<cfinclude template="fu.cfm" />
		   	<cfcatch>
				<!--- display form with error message --->
				<cfset errorMsg = "Problem building friendly URL table.">
		 	   	<cfoutput>#errorMsg#</cfoutput>
		 	   	<cfdump var="#cfcatch#">
		    </cfcatch>
		</cftry>
	</cfif>
	
	<cfif request.bSuccess>
		<cfoutput>
			<div>
				<div class="item">
					<h3>Installation Success!</h3>
					<p>Default Farcry credentials (sa) are:</p>
					<ul>
						<li>U: farcry</li>
						<li>P: farcry</li>
					</ul>
					<p>Please be sure to change this account information on your first login for security reasons</p>
					<cfif isDefined("form.bDeleteApp")>
						<p>Note that your installation directory is being deleted.</p>
					</cfif>
				</div>
				<div class="itemButtons">
					<form name="installComplete" id="installComplete" method="post" action="">
						<input type="button" name="login" value="LOGIN TO FARCRY" onClick="alert('Your default Farcry login is\n\n u: farcry\n p: farcry');window.open('#projectWebrootURL#/webtop')" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle'" onMouseOut="this.className='normalbttnstyle'" />
						<input type="button" name="view" value="VIEW SITE" onClick="window.open('#projectWebrootURL#?updateapp=1')" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle'" onMouseOut="this.className='normalbttnstyle'" />
					</form><br /> 
				</div>
			</div>
		</div>
		</cfoutput>
	</cfif>
	
	
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

