<cfcomponent displayname="Application" output="true" hint="Handle the application.">
 
	<cfsetting enablecfoutputonly="true" />
	
	<!--- LOCATE THE PROJECTS CONSTRUCTOR FILE --->
	<cfset this.projectConstructorLocation = getProjectConstructorLocation(plugin="webtop") />

	<cfinclude template="#this.projectConstructorLocation#" />	

	
	<cfsetting enablecfoutputonly="false" />
	
	
	<cffunction name="OnApplicationStart" access="public" returntype="boolean" output="true" hint="Fires when the application is first created.">

		<cfset var qServerSpecific = queryNew("blah") />
		<cfset var qServerSpecificAfterInit = queryNew("blah") />
		<cfset var machineName = "" />


		<cfset initApplicationScope() />
		

		<!--- CALL THE PROJECTS SERVER SPECIFIC VARIABLES. --->
		<cfinclude template="/farcry/projects/#application.projectDirectoryName#/config/_serverSpecificVars.cfm" />
		
		<!--- Add Server Specific Request Scope files --->
		<cfset machineName = createObject("java", "java.net.InetAddress").localhost.getHostName() />
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
		SELECT objectid, categoryLabel
		FROM #application.dbowner#dmCategory
		</cfquery>
		
		<cfparam name="application.catid" default="#structNew()#" />
		<cfloop query="qCategories">
			<cfset application.catID[qCategories.objectid] = qCategories.categoryLabel>
		</cfloop>
		
		
		<!--- CALL THE PROJECTS AFTER INIT VARIABLES. --->
		<cfif fileExists("#application.path.project#/config/_serverSpecificVarsAfterInit.cfm") >
			<cfinclude template="/farcry/projects/#application.projectDirectoryName#/config/_serverSpecificVarsAfterInit.cfm" />
		</cfif>


		<!--- ADD SERVER SPECIFIC AFTER INIT VARIABLES --->
		<cfset machineName = createObject("java", "java.net.InetAddress").localhost.getHostName() />
		<cfif directoryExists("#application.path.project#/config/#machineName#")>
			<cfif fileExists("#application.path.project#/config/#machineName#/_serverSpecificVarsAfterInit.cfm")>
				<cfinclude template="/farcry/projects/#application.projectDirectoryName#/config/#machineName#/_serverSpecificVarsAfterInit.cfm" />
			</cfif>
		</cfif>
		
		<!--- Return out. --->
		<cfreturn true />

	</cffunction>

 

 

	<cffunction name="OnSessionStart" access="public" returntype="void" output="false" hint="Fires when the session is first created.">
		<!--- Return out. --->

		<cfreturn />

	</cffunction>

 

 

	<cffunction name="OnRequestStart" access="public" returntype="boolean" output="true" hint="Fires at first part of page processing.">
		<!--- Define arguments. --->

		<cfargument name="TargetPage" type="string" required="true" />

		<!--- Update the farcry application if instructed --->
		<cfset farcryUpdateApp() />		
		
		<!--- Initialize the request as a farcry application --->
		<cfset farcryRequestInit() />
	
		
		<!--- 
		This sets up a cookie on the users system so that if they try and login to the webtop and the webtop can't determine which project it is trying to update,
		it will know what projects they will be potentially trying to edit.  --->
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
	
		<!--- Return out. --->
		<cfreturn true />

	</cffunction>

 


 

 

	<cffunction name="OnRequestEnd" access="public" returntype="void" output="true" hint="Fires after the page processing is complete.">
		<!--- Return out. --->
		
		<cfinclude template="/farcry/core/tags/farcry/_farcryOnRequestEnd.cfm">

		<cfreturn />

	</cffunction>

 

 

	<cffunction name="OnSessionEnd" access="public" returntype="void" output="false" hint="Fires when the session is terminated.">
		<!--- Define arguments. --->

		<cfargument name="SessionScope" type="struct" required="true" />

 

		<cfargument name="ApplicationScope" type="struct" required="false" default="#StructNew()#" />
 

		<!--- Return out. --->

		<cfreturn />

	</cffunction>

 

 

	<cffunction name="OnApplicationEnd" access="public" returntype="void" output="false" hint="Fires when the application is terminated.">
		<!--- Define arguments. --->

		<cfargument name="ApplicationScope" type="struct" required="false" default="#StructNew()#" />

 

		<!--- Return out. --->

		<cfreturn />

	</cffunction>

 

 

	<cffunction name="OnError" access="public" returntype="void" output="true" hint="Fires when an exception occures that is not caught by a try/catch.">
		<!--- Define arguments. --->

		<cfargument name="Exception" type="any" required="true" />


		<cfargument name="EventName" type="string" required="false" default="" />

		<cfdump var="#arguments#" expand="false" label="arguments" />
		<!--- Return out. --->

		<cfreturn />

	</cffunction>

 



	<cffunction name="farcryUpdateApp" access="private" output="false" hint="Initialise farcry Application." returntype="void">
	
	<!--- @@copyright: Daemon Internet 2002-2007, http://www.daemon.com.au --->
	<!--- @@license: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
	<!--- @@displayname: farcryInit --->
	<!--- @@description: Application initialisation tag. --->
		
		
		<!--- USED TO DETERMINE OVERALL PAGE TICKCOUNT --->
		<cfset request.farcryPageTimerStart = getTickCount() />
			
		
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
	
	<cffunction name="farcryRequestInit" access="private" output="true" hint="Initialise farcry Application." returntype="void">
	
		<!---------------------------------------- 
		GENERAL APPLICATION REQUEST PROCESSING
		- formally /farcry/core/tags/farcry/_farcryApplication.cfm
		----------------------------------------->
		
		<!--- set legacy logout/login parameters --->
		<cfif isDefined("url.logout") and url.logout eq 1>
			<cfset application.security.logout() />
		</cfif>
		
		
		
		<!-------------------------------------------------------
		Run Request Processing
			_serverSpecificRequestScope.cfm
		-------------------------------------------------------->
		<!--- core request processing --->
		<cfscript>

		// init request.mode with defaults
		request.mode = structNew();
		request.mode.design = 0;
		request.mode.flushcache = 0;
		request.mode.showdraft = 0;
		
		// Developer Mode
		request.mode.bDeveloper = 0;
		
		// container management
		// default to off, conjurer determines permissions based on nav-node
		request.mode.showcontainers = 0; 
		
		// TODO other options to be added
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
		
		}
		
		// set valid status for content
		if (request.mode.showdraft) {
			request.mode.lValidStatus = "draft,pending,approved";
		} else {
			request.mode.lValidStatus = "approved";
		}
		
		// Deprecated variables
		// TODO remove these when possible
		request.lValidStatus = request.mode.lValidStatus; //deprecated
		</cfscript>
		
		
		
		
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



	</cffunction>
	
	
	<cffunction name="getProjectConstructorLocation" access="public" output="true" hint="returns the location of the farcry project''s constructor is located" returntype="string">
		
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
			<cfoutput>
				<p>I can't find a FarCry project on this server to administer.</p>
				<p><a href="#cgi.context_path#/farcry/core/webtop/install/index.cfm">CLICK HERE</a> TO INSTALL A NEW PROJECT.</p>
			</cfoutput>
			<cfabort />		
		</cfif>

	
		<cfreturn loc />
	</cffunction>
	

	<cffunction name="getPluginName" access="public" output="true" hint="returns the name of this plugin" returntype="string">
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
		
		
		<!--- Project directory name can be changed from the default which is the applicationname --->
		<cfset application.projectDirectoryName =  this.projectDirectoryName />
		<cfset application.displayName =  this.displayName />
		
		<!----------------------------------------
		 SET THE DATABASE SPECIFIC INFORMATION 
		---------------------------------------->
		<cfset application.dsn = this.dsn />
		<cfset application.dbtype = this.dbtype />
		<cfset application.dbowner = this.dbowner />
		<cfset application.locales = replaceNoCase(this.locales, " ","",  "all") />
		
		<cfif application.dbtype EQ "mssql" AND NOT len(this.dbowner)>
			<cfset application.dbowner = "dbo." />
		</cfif>

		<!--- Append Locales currently used in the project --->
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
		
		<cfif len(application.url.webroot)>
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