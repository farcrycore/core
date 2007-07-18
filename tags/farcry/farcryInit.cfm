<cfsetting enablecfoutputonly="yes">

<!--- 
|| LEGAL ||
$Copyright: Daemon Internet 2002-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header:  $
$Author: $
$Date:  $
$Name:  $
$Revision: $

|| DESCRIPTION || 
$Description:  -- $


|| DEVELOPER ||
$Developer: Matthew Bryant (mat@daemon.com.au)$

|| ATTRIBUTES ||
$in: objectid -- $
--->


<cfif thistag.executionMode eq "Start">

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
	
	
	<cfparam name="attributes.bObjectBroker" default="true" />
	<cfparam name="attributes.ObjectBrokerMaxObjectsDefault" default="100" />
	
	<!--- Option to archive --->
	<cfparam name="attributes.bUseMediaArchive" default="false" />


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

	
	<!---<cferror type="request" template="/farcry/projects/#attributes.projectDirectoryName#/error/500.cfm"> --->
	
	
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
				<cfset application.path.project = expandpath("/farcry/projects/#attributes.projectDirectoryName#") />
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
				<cfset application.custompackagepath = "farcry.projects.#attributes.projectDirectoryName#.packages" />
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
								
			
		
				<!--- Initialise the stPlugins structure that will hold all the plugin specific settings. --->
				<cfset application.stPlugins = structNew() />
				
				
				<!--- ENSURE SYSINFO IS UPDATED EACH INITIALISATION --->
				<cfset application.sysInfo = structNew() />

				<!--- INITIALISE THE COAPIADMIN SINGLETON --->
				<cfset application.coapi.coapiadmin = createObject("component", "farcry.core.packages.coapi.coapiadmin").init() />
				<cfset application.coapi.coapiUtilities = createObject("component", "farcry.core.packages.coapi.coapiUtilities").init() />
	
	
				<!--- CALL THE PROJECTS SERVER SPECIFIC VARIABLES. --->
				<cfinclude template="/farcry/projects/#attributes.projectDirectoryName#/config/_serverSpecificVars.cfm" />
				
				
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
		
				
								
				<!--------------------------------- 
				INITIALISE DMSEC
				 --------------------------------->
				<cfinclude template="/farcry/core/tags/farcry/_dmSec.cfm">
			
				<!--------------------------------- 
				FARCRY CORE INITIALISATION
				 --------------------------------->
				<cfinclude template="/farcry/core/tags/farcry/_farcryApplicationInit.cfm">
		
		
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
					<cfinclude template="/farcry/projects/#attributes.name#/config/_serverSpecificVarsAfterInit.cfm" />
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


	<!--- general application code --->
	<cfinclude template="/farcry/core/tags/farcry/_farcryApplication.cfm">
	

</cfif>

<cfif thistag.executionMode eq "End">
	<!--- DO NOTHING IN CLOSING TAG --->
</cfif>

<cfsetting enablecfoutputonly="false" />