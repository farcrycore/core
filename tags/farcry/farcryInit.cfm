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
<!--- @@displayname: farcryInit --->
<!--- @@description: Application initialisation tag. --->

<cfif thistag.executionMode eq "End">
	<!--- DO NOTHING IN CLOSING TAG --->
	<cfexit method="exittag" />
</cfif>

<!--- USED TO DETERMINE OVERALL PAGE TICKCOUNT --->
<cfset request.farcryPageTimerStart = getTickCount() />

<!--- DEFAULT ATTRIBUTES THAT CAN BE PASSED IN TO FARCRYINIT TO SET SOME MAJOR APPLICATION SCOPE VARIABLES --->
<cfif not isDefined("attributes.name")>
	<cfabort showerror="attributes.name not passed.">
</cfif>
<cfif not isDefined("attributes.dbtype")>
	<cfabort showerror="attributes.dbtype not passed.">
</cfif>

<cfparam name="attributes.sessionmanagement" default="true"  />
<cfparam name="attributes.sessiontimeout" default="#createTimeSpan(0,0,20,0)#" />
<cfparam name="attributes.applicationtimeout" default="#createTimeSpan(2,0,0,0)#" />
<cfparam name="attributes.clientmanagement" default="false" />
<cfparam name="attributes.clientstorage" default="registry" />
<cfparam name="attributes.loginstorage" default="cookie" />
<cfparam name="attributes.scriptprotect" default="" />
<cfparam name="attributes.setclientcookies" default="true" />
<cfparam name="attributes.setdomaincookies" default="true" />

<cfparam name="attributes.dsn" default="#attributes.name#" />
<cfparam name="attributes.dbowner" default="" />

<cfparam name="attributes.projectDirectoryName" default="#attributes.name#"  />
<cfparam name="attributes.plugins" default="farcrycms"  />

<cfparam name="attributes.projectURL" default="" />
<cfparam name="attributes.webtopURL" default="/webtop" />


<cfparam name="attributes.bObjectBroker" default="true" />
<cfparam name="attributes.ObjectBrokerMaxObjectsDefault" default="100" />

<cfparam name="attributes.locales" default="" />

<!--- Option to archive --->
<cfparam name="attributes.bUseMediaArchive" default="false" />
	
<cfif attributes.dbtype EQ "mssql" AND NOT len(attributes.dbowner)>
	<cfset attributes.dbowner = "dbo." />
</cfif>


<!--- Determine Locales currently used in the project --->
<cfif not len(attributes.locales)>
	<cfswitch expression="#attributes.dbtype#">
		<cfdefaultcase>
			<cfquery datasource="#attributes.dsn#" name="qProfileLocales">
			SELECT distinct(locale) as locale
			from dmProfile
			</cfquery>
			
			<cfif qProfileLocales.recordCount>
				<cfset attributes.locales = valueList(qProfileLocales.locale) />
			</cfif>
		</cfdefaultcase>
	</cfswitch>

</cfif>



<!--- 
FARCRY INIT WAS A 4.0 CUSTOM TAG USED TO INITIALIZE THE APPLICATION.
5.0 is initialised via the application.cfc
This tag is now used to invoke the updater and can only be run from the local machine

 --->

<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head> 
<title>Farcry 5.0 Updater</title>
<style type="text/css">
h1 {font-size:120%;color:##116EAF;margin-bottom: 20px;}
h2 {font-size:110%;font-weight:bold;margin-bottom: 5px;}
a {color: ##116EAF;}
</style>
</head>
<body style="background-color: ##5A7EB9;">
	<div style="border: 8px solid ##eee;background:##fff;width:37em;margin: 50px auto;padding: 20px;color:##666">
		<h1>FarCry 5.0 Updater</h1>
		<div style="margin-left:20px;">
</cfoutput>				
				
<cfif structKeyExists(url, "upgrade") and url.upgrade EQ 1>

	<cfset varibles.projectPath = expandpath('/farcry/projects/#attributes.projectDirectoryName#/www') />
	<cfset varibles.upgraderPath = expandpath('/farcry/core/webtop/updates/b500') />

	<cfif directoryExists("#varibles.projectPath#")>
		<cfif directoryExists("#varibles.projectPath#/updater5.0.0")>
			<cfdirectory action="delete" directory="#varibles.projectPath#/updater5.0.0" mode="777" recurse="true" />
		</cfif>
		<cfif not directoryExists("#varibles.projectPath#/updater5.0.0")>
			
			<cfdirectory action="create" directory="#varibles.projectPath#/updater5.0.0" mode="777" />
			<cffile action="copy" source="#varibles.upgraderPath#/Application.cfm" destination="#varibles.projectPath#/updater5.0.0" mode="777" />
			<cffile action="copy" source="#varibles.upgraderPath#/index.cfm" destination="#varibles.projectPath#/updater5.0.0" mode="777" />
			<cffile action="copy" source="#varibles.upgraderPath#/readme.txt" destination="#varibles.projectPath#/updater5.0.0" mode="777" />
			<cffile action="copy" source="#varibles.upgraderPath#/Application.cf_" destination="#varibles.projectPath#/updater5.0.0" mode="777" />
			<cffile action="copy" source="#varibles.upgraderPath#/proxyApplication.cf_" destination="#varibles.projectPath#/updater5.0.0" mode="777" />
			<cffile action="copy" source="#varibles.upgraderPath#/farcryConstructor.cf_" destination="#varibles.projectPath#/updater5.0.0" mode="777" />
			
			
			<cffile action="read" file="#varibles.projectPath#/updater5.0.0/farcryConstructor.cf_" variable="sFarcryConstructor" />
		
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@Name", "#attributes.name#") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@sessionmanagement", "#attributes.sessionmanagement#") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@sessiontimeout", "createTimeSpan(0,1,0,0)") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@applicationtimeout", "createTimeSpan(2,0,0,0)") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@clientmanagement", "#attributes.clientmanagement#") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@clientstorage", "#attributes.clientstorage#") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@loginstorage", "#attributes.loginstorage#") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@scriptprotect", "#attributes.scriptprotect#") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@setclientcookies", "#attributes.setclientcookies#") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@setdomaincookies", "#attributes.setdomaincookies#") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@locales", "#attributes.locales#") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@dsn", "#attributes.dsn#") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@dbType", "#attributes.dbType#") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@dbOwner", "#attributes.dbOwner#") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@plugins", "#attributes.plugins#") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@projectDirectoryName", "#attributes.projectDirectoryName#") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@projectURL", "#attributes.projectURL#") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@webtopURL", "#attributes.webtopURL#") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@dsn", "#attributes.dsn#") />
			<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@dsn", "#attributes.dsn#") />
			
			<cffile action="write" file="#varibles.projectPath#/updater5.0.0/farcryConstructor.cf_" output="#sFarcryConstructor#" addnewline="false" mode="777" />
		</cfif>
				
		<cflocation url="#attributes.projectURL#/updater5.0.0/index.cfm?Name=#attributes.name#&dsn=#attributes.dsn#&dbtype=#attributes.dbtype#&dbOwner=#attributes.dbOwner#&plugins=#attributes.plugins#" addtoken="false" />
	<cfelse>
	
		<cfset farcryProjectsPath = expandPath("/farcry/projects") />
		<cfset farcryProjectsPath = replaceNoCase(farcryProjectsPath, "\", "/", "all") />
		
		<cfset currentProjectName = getDirectoryFromPath(GetBaseTemplatePath()) />
		<cfset currentProjectName = replaceNoCase(currentProjectName, "\", "/", "all") />
		
		<cfset currentProjectName = replaceNoCase(currentProjectName, farcryProjectsPath, "", "all") />
		<cfset currentProjectName = replaceNoCase(currentProjectName, "/www", "", "all") />
		<cfset currentProjectName = replaceNoCase(currentProjectName, "/", "", "all") />

		<cfoutput>
			<h2>INVALID PROJECT DIRECTORY NAME</h2>
			<p>It seems that the farcryInit tag for this project is not valid</p>
			<p>Your ProjectDirectoryName is currently set to <strong>#attributes.projectDirectoryName#</strong> and I think it should be <strong>#currentProjectName#</strong></p>
			<p>You may have changed the name of your projects folder.</p>
			<p>Please change the value of the projectDirectoryName or if you are not passing this value, update the value of the name attribute.</p>

			
			<p><a href="#cgi.SCRIPT_NAME#?upgrade=1">Try Again</a></p>
		</cfoutput>

	</cfif>
<cfelse>

	<cfoutput>
	<h2>You are trying to initialise a 4.0 application using a 5.0 core.</h2>
	<p>Would you like to setup and run the updater now?</p>
	
	<a href="#cgi.SCRIPT_NAME#?upgrade=1">Continue to updater</a>
	</cfoutput>

</cfif>

<cfoutput>
		</div>
	</div>
</body>
</html>
</cfoutput>

<cfabort>



<cfapplication name="#attributes.name#" 
	sessionmanagement="#attributes.sessionmanagement#" 
	sessiontimeout="#attributes.sessiontimeout#"
	applicationtimeout="#attributes.applicationtimeout#"  
	clientmanagement="#attributes.clientmanagement#" 
	clientstorage="#attributes.clientstorage#"
	loginstorage="#attributes.loginstorage#" 
	scriptprotect="#attributes.scriptprotect#" 
	setclientcookies="#attributes.setclientcookies#" 
	setdomaincookies="#attributes.setdomaincookies#">


<!---------------------------------------- 
BEGIN: Application Initialise 
----------------------------------------->
<cfif NOT structkeyExists(url, "updateapp")>
	<cfset url.updateapp=false />
</cfif>

<cftry>

<cfif (NOT structkeyexists(application, "bInit") OR NOT application.binit) OR url.updateapp>
	<cflock name="#application.applicationName#_init" type="exclusive" timeout="3" throwontimeout="true">
		<cfif (NOT structkeyexists(application, "bInit") OR NOT application.binit) OR url.updateapp>
			
			<!--- set binit to false to block users accessing on restart --->
			<cfset application.bInit =  false />
			
			<!--- Project directory name can be changed from the default which is the applicationname --->
			<cfset application.projectDirectoryName =  attributes.projectDirectoryName />
			
			<!--- Set available locales --->
			<cfset application.locales = attributes.locales />
			
			<!----------------------------------------
			 SET THE DATABASE SPECIFIC INFORMATION 
			---------------------------------------->
			<cfset application.dsn = attributes.dsn />
			<cfset application.dbtype = attributes.dbtype />
			<cfset application.dbowner = attributes.dbowner />
			
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
			<cfset application.url.webroot = attributes.projectURL />
			<cfset application.url.farcry = "#attributes.projectURL#/farcry" />
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
			<cfset application.plugins = attributes.plugins />
			
			
			<!------------------------------------------ 
			USE OBJECT BROKER?
			 ------------------------------------------>
			<cfset application.bObjectBroker = attributes.bObjectBroker />
			<cfset application.ObjectBrokerMaxObjectsDefault = attributes.ObjectBrokerMaxObjectsDefault />
			
			
			<!------------------------------------------ 
			USE MEDIA ARCHIVE?
			 ------------------------------------------>
			<cfset application.bUseMediaArchive = attributes.bUseMediaArchive />
		
			<!---------------------------------------------- 
			INITIALISE THE COAPIUTILITIES SINGLETON
			----------------------------------------------->
			<cfset application.coapi = structNew() />
			<cfset application.coapi.coapiUtilities = createObject("component", "farcry.core.packages.coapi.coapiUtilities").init() />

	
			<!--- Initialise the stPlugins structure that will hold all the plugin specific settings. --->
			<cfset application.stPlugins = structNew() />
			
			
			<!--- ENSURE SYSINFO IS UPDATED EACH INITIALISATION --->
			<cfset application.sysInfo = structNew() />

			<!--- CALL THE PROJECTS SERVER SPECIFIC VARIABLES. --->
			<cfinclude template="/farcry/projects/#application.projectDirectoryName#/config/_serverSpecificVars.cfm" />
			
			
			<!----------------------------------- 
			INITIALISE THE REQUESTED PLUGINS
			 ----------------------------------->
			<cfif isDefined("application.plugins")>
				<cfloop list="#application.plugins#" index="plugin">
					<cfif fileExists("#application.path.plugins#/#plugin#/config/_serverSpecificVars.cfm")>
						<cfinclude template="/farcry/plugins/#plugin#/config/_serverSpecificVars.cfm">
					</cfif>
				</cfloop>
			</cfif>
			
							
			<!----------------------------------------
			SECURITY
			 ---------------------------------------->		
			<!---// dmSecurity settings --->
			<!---//Init Application dmsec scope --->
			<cfset Application.dmSec=StructNew() />
			<!---// --- Initialise the userdirectories --- --->
			<cfset Application.dmSec.UserDirectory = structNew() />
			
			<!---// Client User Directory --->
			<cfset Application.dmSec.UserDirectory.ClientUD = structNew() />
			<cfset temp = Application.dmSec.UserDirectory.ClientUD />
			<cfset temp.type = "Daemon" />
			<cfset temp.datasource = application.dsn />
			
			<!---//Policy Store settings --->
			<cfset Application.dmSec.PolicyStore = StructNew() />
			<cfset ps = Application.dmSec.PolicyStore />
			<cfset ps.dataSource = application.dsn />
			<cfset ps.permissionTable = "dmPermission" />
			<cfset ps.policyGroupTable = "dmPolicyGroup" />
			<cfset ps.permissionBarnacleTable = "dmPermissionBarnacle" />
			<cfset ps.externalGroupToPolicyGroupTable = "dmExternalGroupToPolicyGroup" />

			<!--------------------------------- 
			INITIALISE DMSEC
			 --------------------------------->
			<cfinclude template="/farcry/core/tags/farcry/_dmSec.cfm">


			<!---------------------------------------------- 
			INITIALISE THE COAPIADMIN SINGLETON
			----------------------------------------------->
			<cfset application.coapi.coapiadmin = createObject("component", "farcry.core.packages.coapi.coapiadmin").init() />
			<cfset application.coapi.objectBroker = createObject("component", "farcry.core.packages.fourq.objectBroker").init() />

		
			<!--------------------------------- 
			FARCRY CORE INITIALISATION
			 --------------------------------->
			<cfinclude template="/farcry/core/tags/farcry/_farcryApplicationInit.cfm" />

	
			<!------------------------------------
			OBJECT BROKER
			 ------------------------------------>		
			<cfif structkeyexists(application, "bObjectBroker") AND application.bObjectBroker>
				<cfset objectBroker = createObject("component","farcry.core.packages.fourq.objectBroker")>
				
				<cfloop list="#structKeyList(application.stcoapi)#" index="typename">
					<cfif application.stcoapi[typename].bObjectBroker>
						<cfset bSuccess = objectBroker.configureType(typename=typename, MaxObjects=application.stcoapi[typename].ObjectBrokerMaxObjects) />
					</cfif>
				</cfloop>
			</cfif>
			
	
			<!--- SETUP CATEGORY APPLICATION STRUCTURE --->
			<cfquery datasource="#application.dsn#" name="qCategories">
			SELECT categoryID, categoryLabel
			FROM #application.dbowner#categories
			</cfquery>
			
			<cfparam name="application.catid" default="#structNew()#" />
			<cfloop query="qCategories">
				<cfset application.catID[qCategories.categoryID] = qCategories.categoryLabel>
			</cfloop>
			
			
			<!--- CALL THE PROJECTS SERVER SPECIFIC AFTER INIT VARIABLES. --->
			<cfif fileExists("#application.path.project#/config/_serverSpecificVarsAfterInit.cfm") >
				<cfinclude template="/farcry/projects/#application.projectDirectoryName#/config/_serverSpecificVarsAfterInit.cfm" />
			</cfif>
			
			<!--- set the initialised flag --->
			<cfset application.bInit = true />
		</cfif>
	</cflock>
</cfif>

<cfcatch type="lock">
	<cfoutput><h1>Application Restarting</h1><p>Please come back in a few minutes.</p></cfoutput>
	<cfabort />
</cfcatch>

<cfcatch type="any">
	<!--- remove binit to force reinitialisation on next page request --->
	<cfset structdelete(application,"bInit") />
	<!--- report error to user --->
	<cfoutput><h1>Application Failed to Initialise</h1></cfoutput>
	<cfdump var="#cfcatch#" expand="false" />
	<cfabort />
</cfcatch>

</cftry>
<!---------------------------------------- 
END: Application Initialise 
----------------------------------------->


<!---------------------------------------- 
GENERAL APPLICATION REQUEST PROCESSING
- formally /farcry/core/tags/farcry/_farcryApplication.cfm
----------------------------------------->

<!--- set legacy logout/login parameters --->
<cfif isDefined("url.logout") and url.logout eq 1>
	<cfset application.factory.oAuthentication.logout(bAudit=1) />
</cfif>
<cfset stLoggedIn = application.factory.oAuthentication.getUserAuthenticationData() />
<cfset request.loggedin = stLoggedin.bLoggedIn />


<!-------------------------------------------------------
Run Request Processing
	_serverSpecificRequestScope.cfm
-------------------------------------------------------->
<!--- core request processing --->
<cfinclude template="_requestScope.cfm">

<!--- project and library request processing --->
<cfif application.sysInfo.bServerSpecificRequestScope>
	<cfloop from="1" to="#arraylen(application.sysinfo.aServerSpecificRequestScope)#" index="i">
		<cfinclude template="#application.sysinfo.aServerSpecificRequestScope[i]#" />
	</cfloop>
</cfif>


<!--- This parameter is used by _farcryOnRequestEnd.cfm to determine which javascript libraries to include in the page <head> --->
<cfparam name="Request.inHead" default="#structNew()#">


<!--- IF the project has been set to developer mode, we need to refresh the metadata on each page request. --->
<cfif request.mode.bDeveloper>
	<cfset createObject("component","#application.packagepath#.farcry.alterType").refreshAllCFCAppData() />
</cfif>

<cfsetting enablecfoutputonly="false" />