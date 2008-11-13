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
<!--- @@description: Application initialisation. --->
<cfcomponent displayname="Application" output="false" hint="Core Application.cfc.">

	<!--- import tag libraries ---> 
	<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
	
	
	<!--- 
	IF WE HAVE RECEIVED A PING TO CHECK FOR FRIENDLY URL's SEND BACK A RESPONSE.
	THIS MUST BE DONE OUTSIDE OF THE APPLICATION AS IT MAY BE CALLED BEFORE THE APPLICATION IS INITIALISED
	 --->
	<cfif structKeyExists(url, "furl") AND url.furl EQ "/pingFU">				
		<cfoutput>PING FU SUCCESS</cfoutput>
		<cfabort>
	</cfif>
	
	
	<!--- run the active project's constructor --->
	<cfset this.projectConstructorLocation = getProjectConstructorLocation(plugin="webtop") />
	<cfinclude template="#this.projectConstructorLocation#" />	

	
	
	<cffunction name="OnApplicationStart" access="public" returntype="boolean" output="false" hint="Fires when the application is first created.">

		<cfset var qServerSpecific = queryNew("blah") />
		<cfset var qServerSpecificAfterInit = queryNew("blah") />
		<cfset var machineName = createObject("java", "java.net.InetAddress").localhost.getHostName() />

		<!--- intialise application scope --->
		<cfset initApplicationScope() />
		
		<!----------------------------------- 
		CALL THE PROJECTS SERVER SPECIFIC VARIABLES
		 ----------------------------------->
		<cfinclude template="/farcry/projects/#application.projectDirectoryName#/config/_serverSpecificVars.cfm" />
		
		<!--- Add Server Specific Request Scope files --->
		<cfif directoryExists("#application.path.project#/config/#machineName#")>
			<cfif fileExists("#application.path.project#/config/#machineName#/_serverSpecificVars.cfm")>
				<cfinclude template="/farcry/projects/#application.projectDirectoryName#/config/#machineName#/_serverSpecificVars.cfm" />
			</cfif>
		</cfif>
		
		
		<!----------------------------------- 
		INITIALISE THE REQUESTED PLUGINS
		 ----------------------------------->
		<cfif isDefined("application.plugins")>
			<cfloop list="#application.plugins#" index="plugin">
				<cfif fileExists("#application.path.plugins#/#plugin#/config/_serverSpecificVars.cfm")>
					<cfinclude template="/farcry/plugins/#plugin#/config/_serverSpecificVars.cfm" />
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


		<!---------------------------------------------- 
		INITIALISE THE COAPIADMIN SINGLETON
		----------------------------------------------->
		<cfset application.coapi.coapiadmin = createObject("component", "farcry.core.packages.coapi.coapiadmin").init() />
		<cfset application.coapi.objectBroker = createObject("component", "farcry.core.packages.fourq.objectBroker").init(bFlush="true") />

	
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

		<!----------------------------------- 
		SETUP CATEGORY APPLICATION STRUCTURE
		 ----------------------------------->
		<cfquery datasource="#application.dsn#" name="qCategories">
		SELECT objectid, categoryLabel
		FROM #application.dbowner#dmCategory
		</cfquery>
		
		<cfparam name="application.catid" default="#structNew()#" />
		<cfloop query="qCategories">
			<cfset application.catID[qCategories.objectid] = qCategories.categoryLabel />
		</cfloop>

		
		<!----------------------------------- 
		CALL THE PROJECTS AFTER INIT VARIABLES
		------------------------------------>
		<cfif fileExists("#application.path.project#/config/_serverSpecificVarsAfterInit.cfm") >
			<cfinclude template="/farcry/projects/#application.projectDirectoryName#/config/_serverSpecificVarsAfterInit.cfm" />
		</cfif>


		<!----------------------------------- 
		ADD SERVER SPECIFIC AFTER INIT VARIABLES
		------------------------------------>
		<cfif directoryExists("#application.path.project#/config/#machineName#")>
			<cfif fileExists("#application.path.project#/config/#machineName#/_serverSpecificVarsAfterInit.cfm")>
				<cfinclude template="/farcry/projects/#application.projectDirectoryName#/config/#machineName#/_serverSpecificVarsAfterInit.cfm" />
			</cfif>
		</cfif>


		<!----------------------------------- 
		CALL THE PLUGINS AFTER INIT VARIABLES
		 ----------------------------------->
		<cfif isDefined("application.plugins")>
			<cfloop list="#application.plugins#" index="plugin">
				<cfif fileExists("#application.path.plugins#/#plugin#/config/_serverSpecificVarsAfterInit.cfm")>
					<cfinclude template="/farcry/plugins/#plugin#/config/_serverSpecificVarsAfterInit.cfm">
				</cfif>
			</cfloop>
		</cfif>
		
		<cfset application.bInit = true />
		<cfreturn true />

	</cffunction>
 

	<cffunction name="OnSessionStart" access="public" returntype="void" output="false" hint="Fires when the session is first created.">
		<cfreturn />
	</cffunction>

 
	<cffunction name="OnRequestStart" access="public" returntype="boolean" output="false" hint="Fires at first part of page processing.">
		<cfargument name="TargetPage" type="string" required="true" />

		<!--- Setup FarCry Namespace in the request scope --->
		<cfparam name="request.fc" default="#structNew()#" />
		
		<!--- Update the farcry application if instructed --->
		<cfset farcryUpdateApp() />		
		
		<!--- Initialize the request as a farcry application --->
		<cfset farcryRequestInit() />
	
		
		<!---
		SHARED WEBTOP LOGIN 
		This sets up a cookie on the users system so that if they try and login to
		the webtop and the webtop can't determine which project it is trying to update,
		it will know what projects they will be potentially trying to edit.  
		--->
		<cfparam name="server.stFarcryProjects" default="#structNew()#" />
		<cfif not structKeyExists(server.stFarcryProjects, application.projectDirectoryName) or not isstruct(server.stFarcryProjects[application.projectDirectoryName])>
			<cfset server.stFarcryProjects[application.projectDirectoryName] = structnew() />
			<cfset server.stFarcryProjects[application.projectDirectoryName].displayname = application.displayName />
			<cfset server.stFarcryProjects[application.projectDirectoryName].domains = "" />
		</cfif>
		<cfif not listcontains(server.stFarcryProjects[application.projectDirectoryName].domains,cgi.http_host)>
			<cfset server.stFarcryProjects[application.projectDirectoryName].domains = listappend(server.stFarcryProjects[application.projectDirectoryName].domains,cgi.http_host) />
		</cfif>
		<cfset cookie.currentFarcryProject = application.projectDirectoryName />	
	
		<cfparam name="session.loginReturnURL" default="#application.url.webroot#/index.cfm" />
		<cfif structKeyExists(url, "returnURL")>
			<cfset session.loginReturnURL = url.returnURL />
		</cfif>

		<cfreturn true />
	</cffunction>
 

	<cffunction name="OnRequestEnd" access="public" returntype="void" output="false" hint="Fires after the page processing is complete.">
		
		<cfinclude template="/farcry/core/tags/farcry/_farcryOnRequestEnd.cfm">

		<cfreturn />
	</cffunction>

 
	<cffunction name="OnSessionEnd" access="public" returntype="void" output="false" hint="Fires when the session is terminated.">
		<cfargument name="SessionScope" type="struct" required="true" />
		<cfargument name="ApplicationScope" type="struct" required="false" default="#StructNew()#" />
 
		<cfreturn />
	</cffunction>

 
	<cffunction name="OnApplicationEnd" access="public" returntype="void" output="false" hint="Fires when the application is terminated.">
		<cfargument name="ApplicationScope" type="struct" required="false" default="#StructNew()#" />

		<cfreturn />
	</cffunction>


	<cffunction name="OnError" access="public" returntype="void" output="true" hint="Fires when an exception occures that is not caught by a try/catch.">
		<cfargument name="Exception" type="any" required="true" />
		<cfargument name="EventName" type="string" required="false" default="" />

		<!--- rudimentary error handler --->
		<!--- TODO: need a pretty error handler for the webtop --->
		<cfdump var="#arguments.exception#" expand="true" label="arguments" />

		<cfreturn />
	</cffunction>

 
	<cffunction name="farcryUpdateApp" access="private" output="false" hint="Initialise farcry Application." returntype="void">
		<!--- USED TO DETERMINE OVERALL PAGE TICKCOUNT --->
		<cfset request.farcryPageTimerStart = getTickCount() />
			
		<!---------------------------------------- 
		BEGIN: Application Initialise 
		----------------------------------------->
		<cfparam name="url.updateapp" default="" />
		
		<cftry>
		<!--- TODO: this needs to be removed eventually. It is currently only in here so that users can updateapp when they upgrade without having to recycle CF --->
		<cfparam name="application.updateappKey" default="1" />
		
		<!--- determine if user has permission to perform updateapp; blocks potential denial of service attack --->
		<cfif len(url.updateapp)>
			<cfif url.updateapp EQ application.updateappKey>
				<!--- CAN FORCE AND UPDATE IF THE USER KNOWS THE updateappKey --->
				<cfset url.updateapp = true>
			<cfelse>		
				<cfif isBoolean(url.updateapp) AND isDefined("session.dmSec.Authentication.bAdmin") and session.dmSec.Authentication.bAdmin>
					<!--- ADMINISTRATORS CAN ALWAYS UPDATE APP WITH 1 --->
				<cfelse>
					<!--- Not an adminstrator and didnt know the updateappkey --->
					<cfset url.updateapp = false>
				</cfif>			
			</cfif>
		<cfelse>
			<cfset url.updateapp = false>
		</cfif>
		
		<!--- force application start sequence to be single threaded --->
		<cfif (NOT structkeyexists(application, "bInit") OR NOT application.binit) OR url.updateapp>
			<cflock name="#application.applicationName#_init" type="exclusive" timeout="3" throwontimeout="true">
				<cfif (NOT structkeyexists(application, "bInit") OR NOT application.binit) OR url.updateapp>

					<!--- set binit to false to block users accessing on restart --->
					<cfset application.bInit =  false />
	
					<cfset OnApplicationStart() />
					
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

	</cffunction>


	<cffunction name="farcryRequestInit" access="private" output="false" hint="Initialise farcry Application." returntype="void">
		<!---------------------------------------- 
		GENERAL APPLICATION REQUEST PROCESSING
		- formally /farcry/core/tags/farcry/_farcryApplication.cfm
		----------------------------------------->
		
		<!----------------------------------------
		EVENT: URL logout
		----------------------------------------->
		<cfif isDefined("url.logout") and url.logout eq 1>
			<cfset application.security.logout() />
		</cfif>
		
		<!-------------------------------------------------------
		Run Request Processing
			_serverSpecificRequestScope.cfm
		-------------------------------------------------------->
		<!--- core request processing --->
		<cfscript>
		request.fc.bShowTray = true;
			
		// init request.mode with defaults
		request.mode = structNew();
		request.mode.design = 0;
		request.mode.flushcache = 0;
		request.mode.showdraft = 0;
		request.mode.ajax = 0;
		
		// Developer Mode
		request.mode.bDeveloper = 0;
		
		// container management
		// default to off, conjurer determines permissions based on nav-node
		request.mode.showcontainers = 0; 
		
		// miscellaneous options to be added
		request.mode.showtables = 0;
		request.mode.showerror = 0;
		request.mode.showdebugoutput = 0;
		
		// admin options visible in page
		if (IsDefined("session.dmSec.Authentication.bAdmin")) {
			request.mode.bAdmin = session.dmSec.Authentication.bAdmin; 
		} else {
			request.mode.bAdmin = 0; // default to off
		}
			
		// if user has admin priveleges, determine mode values
		if (request.mode.bAdmin) {
		// designmode
			if (isDefined("url.designmode")) {
				request.mode.design = val(url.designmode);
				session.dmSec.Authentication.designmode = request.mode.design;
			} else if (isDefined("session.dmSec.Authentication.designmode")) {
				request.mode.design = session.dmSec.Authentication.designmode;
			} else {
				request.mode.design = 0;
			}
		
		// bypass caching
			if (isDefined("url.flushcache")) {
				request.mode.flushcache = val(url.flushcache);
				session.dmSec.Authentication.flushcache = request.mode.flushcache;
			} else if (isDefined("session.dmSec.Authentication.flushcache")) {
				request.mode.flushcache = session.dmSec.Authentication.flushcache;
			} else {
				request.mode.flushcache = 0;
			}
		
		// view content as stage
			if (isDefined("url.showdraft")) {
				request.mode.showdraft = val(url.showdraft);
				session.dmSec.Authentication.showdraft = request.mode.showdraft;
			} else if (isDefined("session.dmSec.Authentication.showdraft")) {
				request.mode.showdraft = session.dmSec.Authentication.showdraft;
			} else {
				request.mode.showdraft = 0;
			}
		
		// disable tray
			if (isDefined("url.bShowTray")) {
				request.fc.bShowTray = val(url.bShowTray);
				session.dmProfile.bShowTray = request.fc.bShowTray;
			} else if (isDefined("session.dmProfile.bShowTray")) {
				request.fc.bShowTray = session.dmProfile.bShowTray;
			} else {
				request.fc.bShowTray = 1;
			}
		
		}
		
		// set valid status for content
		if (request.mode.showdraft) {
			request.mode.lValidStatus = "draft,pending,approved";
		} else {
			request.mode.lValidStatus = "approved";
		}
	
		// ajaxmode
		if ((isDefined("url.ajaxmode") and url.ajaxmode) or (isDefined("form.ajaxmode") and form.ajaxmode)) {
			request.mode.ajax = true;
		} else {
			request.mode.ajax = false;
		}
			
		// Deprecated variables
		// TODO remove these when possible
		request.lValidStatus = request.mode.lValidStatus; //deprecated
		</cfscript>


		<!--- project and plugin request processing --->
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

	</cffunction>
	
	
	<cffunction name="getProjectConstructorLocation" access="public" output="false" hint="Returns the location of the active project constructor." returntype="string">
		<cfargument name="plugin" type="string" hint="The name of the plugin.">
		
		<cfset var loc = "" />
		<cfset var virtualDirectory = "" />
		
		<!--- strip the context path first (for J2EE deployments) --->
		<cfset var script_path = right( cgi.SCRIPT_NAME, len( cgi.SCRIPT_NAME ) - len( cgi.context_path ) )>

		<!--- Get the first directory after the url if there is one (ie. if its just index.cfm then we know we are just under the webroot) --->
		<cfif listLen(script_path, "/") GT 1>
			<cfset virtualDirectory = listFirst(script_path, "/") />
				
			<!--- If the first directory name is the same name as the plugin, then we assume we are running the project from the webroot --->
			<cfif virtualDirectory EQ arguments.plugin>
				<cfset virtualDirectory = "" />
			</cfif>					
		</cfif>

		<!--- If we ended up with a virtual directory we check to see if there is a farcryConstructor --->
		<cfif len(virtualDirectory) AND fileExists(expandPath("/#virtualDirectory#/farcryConstructor.cfm"))>
			<cfset loc = trim("/#virtualDirectory#/farcryConstructor.cfm") />

		<cfelseif fileExists(expandPath("/farcryConstructor.cfm"))>
			<!--- Otherwise we check in the webroot --->
			<cfset loc = trim("/farcryConstructor.cfm") />
		<cfelse>
			<!--- If all else fails, see if the user has a cookie telling us what project to look at. --->
			<cfif structKeyExists(url, "farcryProject")>
				<cfset cookie.currentFarcryProject = url.farcryProject />
			</cfif>
			<cfif arguments.plugin EQ "webtop" AND structKeyExists(cookie, "currentFarcryProject")>
		
				<cfif fileExists(expandPath("/#currentFarcryProject#/farcryConstructor.cfm"))>
					<cfset loc = trim("/#currentFarcryProject#/farcryConstructor.cfm") />
				</cfif>
			</cfif>
		</cfif>

		<cfif not len(loc)>				
			<cfif fileExists(expandPath("#cgi.context_path#/webtop/install/noProject.cfm"))>
				<cfset installLink = "#cgi.context_path#/webtop/install/noProject.cfm" />
			<cfelse>
				<cfset installLink = "#cgi.context_path#/farcry/core/webtop/install/noProject.cfm" />
			</cfif>
			
			<cflocation url="#installLink#" addtoken="false">
			
			<cfoutput>
				<h1>FarCry Project Not Found</h1>
				<p>I'm terribly sorry, I can't find a FarCry project on this server to administer.</p>
				<p><a href="#installLink#">CLICK HERE TO INSTALL A NEW PROJECT</a></p>
			</cfoutput>
			<cfabort />		
		</cfif>
	
		<cfreturn loc />
	</cffunction>
	

	<cffunction name="getPluginName" access="public" output="false" hint="Returns the name of this plugin; core returns 'farcry'." returntype="string">
		<cfreturn "farcry" />
	</cffunction>


	<cffunction name="initApplicationScope" access="private" output="false" hint="Sets up the main farcry application scope variables." returntype="void">

		<!--- REQUIRED VARIABLES SETUP IN THE FARCRYCONSTRUCTOR --->
		<cfif not isDefined("this.name")>
			<cfabort showerror="this.name not defined in your projects farcryConstructor.">
		</cfif>
		<cfif not isDefined("this.dbtype")>
			<cfabort showerror="this.dbtype not defined in your projects farcryConstructor.">
		</cfif>
		
		<cfparam name="this.displayName" default="#this.name#" />
		
		<cfparam name="this.dsn" default="#this.name#" />
		<cfparam name="this.dbowner" default="" />
		<cfparam name="this.locales" default="en_AU,en_US" />
		
		<cfparam name="this.projectDirectoryName" default="#this.name#"  />
		<cfparam name="this.plugins" default="farcrycms"  />
		
		<cfparam name="this.projectURL" default="" />
		<cfparam name="this.webtopURL" default="" />
		
		<cfparam name="this.bObjectBroker" default="true" />
		<cfparam name="this.ObjectBrokerMaxObjectsDefault" default="100" />
		
		<!--- Option to archive --->
		<cfparam name="this.bUseMediaArchive" default="false" />
		
		<!--- updateapp key used to updateapp without administrator privilages. Set to your own string in the farcryConstructor --->
		<cfparam name="this.updateappKey" default="#createUUID()#" />
		
		<!--- Used to identify subsites that are available to this application --->
		<cfparam name="this.subsites" default="#structNew()#" />
		
		<cfset application.fc = structNew() /><!--- FarCry Namespace in the application scope --->
		<cfset application.fc.factory = structNew() /><!--- Struct to contain any factory classes that can be used by the application --->
		<cfset application.fc.subsites = this.subsites /><!--- Struct to contain any subsites that may be included with the application --->
		<cfset application.fc.utils = createObject("component", "farcry.core.packages.farcry.utils").init() /><!--- FarCry Utility Functions --->
		
		<!--- Project directory name can be changed from the default which is the applicationname --->
		<cfset application.projectDirectoryName =  this.projectDirectoryName />
		<cfset application.displayName =  this.displayName />
		
		<!--- Set an application random string that can be used to force refresh of various browser caching. Restarting application will effectively flush those browser caches --->
		<cfset application.randomID =  application.fc.utils.createJavaUUID() />
		
		<!----------------------------------------
		 SET THE DATABASE SPECIFIC INFORMATION 
		----------------------------------------->
		<cfset application.dsn = this.dsn />
		<cfset application.dbtype = this.dbtype />
		<cfset application.dbowner = this.dbowner />
		<cfset application.locales = replaceNoCase(this.locales, " ","",  "all") />
		
		<cfif application.dbtype EQ "mssql" AND NOT len(this.dbowner)>
			<cfset application.dbowner = "dbo." />
		</cfif>


		<!----------------------------------------
		 LOCALES
		 - Append Locales currently used in the project
		----------------------------------------->
		<cfswitch expression="#application.dbtype#">
			<cfdefaultcase>
				<cfquery datasource="#application.dsn#" name="qProfileLocales">
				SELECT distinct(locale) as locale
				from #application.dbowner#dmProfile
				</cfquery>
				
				<cfif qProfileLocales.recordCount>
					<cfloop query="qProfileLocales">
						<cfif not listFindNoCase(application.locales, qProfileLocales.locale)>
							<cfset application.locales = listAppend(application.locales,qProfileLocales.locale) />
						</cfif>
					</cfloop>
				</cfif>
			</cfdefaultcase>
		</cfswitch>


		<!----------------------------------------
		 WEB URL PATHS
		 ---------------------------------------->
		<cfset application.url.webroot = "#cgi.context_path##this.projectURL#" />
		<cfif len(this.webtopURL)>
			<cfset application.url.webtop = "#cgi.context_path##this.webtopURL#" />
		<cfelse>
			<cfset application.url.webtop = "#cgi.context_path##application.url.webroot#/webtop" />
		</cfif>
		<cfset application.url.farcry = "#application.url.webtop#" /><!--- Legacy variable. Developers should use application.url.webtop --->
		<cfset application.url.imageRoot = "#application.url.webroot#">
		<cfset application.url.fileRoot = "#application.url.webroot#/files">
		
		
		<!----------------------------------------
		 SET THE MAIN PHYSICAL PATH INFORMATION
		 ---------------------------------------->
		<cfset application.path.project = expandpath("/farcry/projects/#application.projectDirectoryName#") />
		<cfset application.path.core = expandpath("/farcry/core") />
		<cfset application.path.plugins = expandpath("/farcry/plugins") />
		
		<cfif len(cgi.context_path)>
		    <!--- remove the context path before expanding the path --->
		    <cfset application.path.webroot = expandPath("#right(application.url.webroot, len(application.url.webroot)-len(cgi.context_path))#")>
		<cfelseif len(application.url.webroot)>
			<cfset application.path.webroot = expandPath("#application.url.webroot#")>
		<cfelse>
			<cfset application.path.webroot = expandPath("/")><!--- Doesnt work if empty string. Have to set to  "/" otherwise it returns cf root --->
		</cfif>
		
		<cfset application.path.defaultFilePath = "#application.path.webroot#/files">
		<cfset application.path.secureFilePath = "#application.path.project#/securefiles">		
		
		<cfset application.path.imageRoot = "#application.path.webroot#">
		
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
		<cfset application.plugins = this.plugins />


		<!------------------------------------------ 
		USE OBJECT BROKER?
		 ------------------------------------------>
		<cfset application.bObjectBroker = this.bObjectBroker />
		<cfset application.ObjectBrokerMaxObjectsDefault = this.ObjectBrokerMaxObjectsDefault />


		<!------------------------------------------ 
		INITIALISE THE COMBINED JS STRUCTURE USED TO COMBINE MULTIPLE JS FILES
		 ------------------------------------------>
		<cfset application.stCombinedFarcryJS = structNew() />


		<!------------------------------------------ 
		USE MEDIA ARCHIVE?
		 ------------------------------------------>
		<cfset application.bUseMediaArchive = this.bUseMediaArchive />


		<!------------------------------------------ 
		UPDATE APP KEY
		 ------------------------------------------>
		<cfset application.updateappKey = this.updateappKey />


		<!---------------------------------------------- 
		INITIALISE THE COAPIUTILITIES SINGLETON
		----------------------------------------------->
		<cfset application.coapi = structNew() />
		<cfset application.coapi.coapiUtilities = createObject("component", "farcry.core.packages.coapi.coapiUtilities").init() />


		<!--- Initialise the stPlugins structure that will hold all the plugin specific settings. --->
		<cfset application.stPlugins = structNew() />


		<!--- ENSURE SYSINFO IS UPDATED EACH INITIALISATION --->
		<cfset application.sysInfo = structNew() />

	</cffunction>

</cfcomponent>