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
	<cfparam name="attributes.lFarcryLib" default="farcrycms"  />
	
	<cfparam name="attributes.projectURL" default="" />
	
	
	<cfparam name="attributes.bObjectBroker" default="true" />
	<cfparam name="attributes.ObjectBrokerMaxObjectsDefault" default="100" />


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

	
	<!---<cferror type="request" template="/farcry/#attributes.projectDirectoryName#/error/500.cfm"> --->
	
	
	<!---------------------------------------- 
	BEGIN: Application Initialise 
	----------------------------------------->
	<cfif NOT IsDefined("application.bInit") OR IsDefined("url.updateapp")>
		
		
	<!---	<cfinclude template="/farcry/farcry_core/tags/farcry/flightcheck.cfm" /> --->
		
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
		<cfset application.path.project = expandpath("/farcry/#attributes.projectDirectoryName#") />
		<cfset application.path.core = expandpath("/farcry/farcry_core") />
		<cfset application.path.library = expandpath("/farcry/farcry_lib") />
		
		<cfset application.path.defaultFilePath = "#application.path.project#/www/files">
		<cfset application.path.secureFilePath = "#application.path.project#/securefiles">
		
		<!----------------------------------------
		 WEB URL PATHS
		 ---------------------------------------->
		<cfset application.url.webroot = attributes.projectURL />
		<cfset application.url.farcry = "#attributes.projectURL#/farcry" />
		<cfset application.url.imageroot = "#application.url.webroot#/images">
		<cfset application.url.fileroot = "#application.url.webroot#/files">
		
		
		<!----------------------------------------
		SHORTCUT PACKAGE PATHS
		 ---------------------------------------->
		<cfset application.packagepath = "farcry.farcry_core.packages" />
		<cfset application.custompackagepath = "farcry.#attributes.projectDirectoryName#.packages" />
		<cfset application.securitypackagepath = "farcry.farcry_core.packages.security" />
		
		<!----------------------------------------
		LIBRARYs To INCLUDE
		 ---------------------------------------->
		<cfset application.lFarcryLib = attributes.lFarcryLib />
		
		
		<!------------------------------------------ 
		USE OBJECT BROKER?
		 ------------------------------------------>
		<cfset application.bObjectBroker = attributes.bObjectBroker />
		<cfset application.ObjectBrokerMaxObjectsDefault = attributes.ObjectBrokerMaxObjectsDefault />
		
		
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
						
	


		<cfset application.farcryLib = structNew() />
		
		<cfinclude template="/farcry/#attributes.name#/config/_serverSpecificVars.cfm" />
		
		
		<!----------------------------------- 
		INITIALISE THE REQUESTED LIBRARIES
		 ----------------------------------->
		<cfif isDefined("application.lFarcryLib")>
			<cfloop list="#application.lFarcryLib#" index="library">
				<cfif fileExists("#application.path.library#/#library#/config/librarySpecificVars.cfm")>
					<cfinclude template="/farcry/farcry_lib/#library#/config/librarySpecificVars.cfm">
				</cfif>
			</cfloop>
		</cfif>

		
						
		<!--------------------------------- 
		INITIALISE DMSEC
		 --------------------------------->
		<cfinclude template="/farcry/farcry_core/tags/farcry/_dmSec.cfm">
	
		<!--------------------------------- 
		FARCRY CORE INITIALISATION
		 --------------------------------->
		<cfinclude template="/farcry/farcry_core/tags/farcry/_farcryApplicationInit.cfm">


		<!------------------------------------
		OBJECT BROKER
		 ------------------------------------>		
		<cfif structkeyexists(application, "bObjectBroker") AND application.bObjectBroker>
			<cfset objectBroker = createObject("component","farcry.fourq.objectBroker")>
			
			<cfloop list="#structKeyList(application.types)#" index="typename">
				<cfif application.types[typename].bObjectBroker>
					<cfset bSuccess = objectBroker.configureType(typename=typename, MaxObjects=application.types[typename].ObjectBrokerMaxObjects) />
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
			<cfinclude template="/farcry/#attributes.name#/config/_serverSpecificVarsAfterInit.cfm" />
		</cfif>
		
		
	</cfif>
	<!---------------------------------------- 
	END: Application Initialise 
	----------------------------------------->


		


	<!--- general application code --->
	<cfinclude template="/farcry/farcry_core/tags/farcry/_farcryApplication.cfm">
	
		

</cfif>

<cfif thistag.executionMode eq "End">
	
	<!--- DO NOTHING --->
	
</cfif>

<cfsetting enablecfoutputonly="no">