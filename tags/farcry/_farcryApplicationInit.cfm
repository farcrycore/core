<cfsetting requestTimeOut="200">
<cfsilent>
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
<!--- @@Description: initialise application level code. Sets up site config and permissions cache  --->
<!--- @@Developer: Mat Bryant (mat@daemon.com.au) --->


<!--- IMPORT TAG LIBRARIES --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!----------------------------------- 
GENERAL CONFIG VARIABLES
- merged _config.cfm
------------------------------------>

<!--- empty application.types structure --->
<cfset application.types = structNew()>

<!--- ########################################################################
Setup defaults for File and Image assets. Either of these values *might* be set
in the project code base in "_serverSpecificVars.cfm"

"application.default[File|Image]Path" is the pre b230 var that has been deprecated for
"application.path.default[File|Image]Path". 

Depending on the core version, either of both of these could be used so we'll
test for the existance of each and act accordingly

**These values can be set in the project codebase in _serverSpecificVars.cfm
######################################################################### --->

<!--- File path first --->
<cfif structKeyExists(application.path, "defaultFilePath")>
	<cfset application.defaultFilePath = application.path.defaultFilePath>
<cfelse>
	<!--- Defaults --->
	<cfset application.path.defaultFilePath = "#application.path.webroot#/files">
	<!--- Deprecated in b230; Use application.path.defaultFilePath instead --->
	<cfset application.defaultFilePath = application.path.defaultFilePath>
</cfif>		 

<!--- Image Path --->
<cfif structKeyExists(application.path, "defaultImagePath")>
	<cfset application.defaultImagePath = application.path.defaultImagePath>
<cfelse>
	<!--- Defaults --->
	<cfset application.path.defaultImagePath = "#application.path.webroot#/images">
	<!--- Deprecated in b230; Use application.path.defaultImagePath instead --->
	<cfset application.defaultImagePath = application.path.defaultImagePath>
</cfif>		 

<cfscript>
	// abs path to webskin handlers
	application.path.webskin = application.path.project & "/webskin";
	// path rel to project cf mapping for webskin handler root
	application.path.handler = "webskin";
	
	// application web urls
	application.url.conjurer = application.url.webroot & "/index.cfm"; // general invoker
	
	//initialise factory objects 
	application.factory.oAlterType = createobject("component","#application.packagepath#.farcry.alterType");
	application.factory.oWebtop = createObject("component", application.fc.utils.getPath(package="farcry", component="webtop")).init();
	application.factory.oUtils = createobject("component","#application.packagepath#.farcry.utils");
	application.factory.oTree = createObject("component","#application.packagepath#.farcry.tree");
	application.factory.oCache = createObject("component","#application.packagepath#.farcry.cache");
	application.factory.oLocking = createObject("component","#application.packagepath#.farcry.locking");
	application.factory.oVersioning = createObject("component","#application.packagepath#.farcry.versioning");
	application.factory.oWorkflow = createObject("component","#application.packagepath#.farcry.workflow");
	application.factory.oCategory = createObject("component","#application.packagepath#.farcry.category");
	application.factory.oCon = createObject("component","#application.packagepath#.rules.container");
	try {
		application.factory.oFU = createObject("component","#application.packagepath#.farcry.FU");
	}
	catch (Any excpt) {}
	
	application.security = createobject("component",application.factory.oUtils.getPath("security","security")).init();

	// load TYPE and RULE metadata structures into memory
	oAlterType = createObject("component", "#application.packagepath#.farcry.alterType");
	/***************************************************************************
	loadCOAPIMetaData() and alterType.refreshAllCFCAppData() were doing the exact
	same thing line for line, so I removed loadCOAPIMetaData() and we're now using alterType. Altertype
	is a less than ideal place for this kind of task but it will do until we can agree
	on some sort ot type initialisation. ~tom
	*/
	oAlterType.refreshAllCFCAppData(); // This replaces loadCOAPIMetaData for now. I'm thinking types.init()?? ~tom
	
	/* 
		Default for the DOCTYPE of the site.  This variable is used by some items to output 
		tags that conform differently based on the desired end doctype.  For example, 
		in html meta tags should not self close "/>", but in xhtml they need to.  This
		value is set to the w3c doctype string. For example all of these are valid:

		HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"
		HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"
		HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd"
		html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
		html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"
		html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"

		By default we are going with html 4.01 strict, in the future we'll go with html5. 
		You can override this in _serverSpecificVars etc.
		
		**********
		To get access to this variable for switches and what not, please use 
		application.fapi.getDocType()
		see core's fapi.cfc for details.
		**********
	*/
	application.fc.doctype = 'HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"';
</cfscript>


	
<!--- Initialize the Friendly URL Alias in the farcry application namespace --->
<cfset application.fc.factory.farFU = createObject("component", application.stcoapi["farFU"].packagePath).onAppInit() />



<!--- Load config data --->
<cfset oConfig = createobject("component",application.stCOAPI.farConfig.packagepath) />
<cfset application.config = structNew() />
<cfloop list="#oConfig.getConfigKeys()#" index="configkey">
	<cfset application.config[configkey] = oConfig.getConfig(key=configkey,bIgnoreCache=true) />
</cfloop>
<cfset application.fc.lib.db.setLogChangeFlags(application.fapi.getConfig("general","logDBChanges","")) />

<!--- set up the configs from the environment --->
<cfif structKeyExists(THIS, "bUseEnv") AND THIS.bUseEnv eq "true">
	<cfset system = createobject("java", "java.lang.System")>
	<cfset ENV = system.getEnv()>
	<cfset ENV_ARRAY = ENV.keySet().toArray()>
	<cfloop from="1" to="#arrayLen(ENV_ARRAY)#" index="i">
		<cfif left(ENV_ARRAY[i], 14) eq "FARCRY_CONFIG_" AND listLen(ENV_ARRAY[i], "_") gte 4>
			<cfset configKey = listGetAt(ENV_ARRAY[i], 3, "_")>
			<cfset configProperty = replaceNoCase(ENV_ARRAY[i], "FARCRY_CONFIG_#configKey#_" , "")>
			<cfset configValue = ENV.get(ENV_ARRAY[i])>
			<cfset application.fapi.setConfig(configKey, configProperty, configValue, true)>
		</cfif>
	</cfloop>
</cfif>


<!--- wrap this in a cftry catch in case the policystore isn't initialised yet  --->
<!--- <cfif StructKeyExists(request,"init") AND request.init eq 0> --->

<!--------------------------------------------------------------------
Build NavIDs from Navigation Nodes 
--------------------------------------------------------------------->
<cfscript>
	// set up requested navid's application.navIds
	oNav = createObject("component", application.types.dmNavigation.typePath);
	application.navid = oNav.getNavAlias(bIgnoreCache=true);
</cfscript>

<!--- Build catids from category nodes --->

<cfset application.catid = application.factory.oCategory.getCatAliases(bIgnoreCache=true) />
<!--- /_config.cfm --->


<cfscript>
    /* i18n specific stuff */
    // structure to hold resourceBundles for farcry admin
    application.adminBundle=structNew();
    // struct to hold all our calendar CFCs TODO
    //application.Calendars=structNew();
    // classpath rb files
    //application.rb=createObject("component","#application.packagepath#.farcry.rbJava");
    // non-classpath rb files, needs full path to rb files
   application.rb=createObject("component",application.factory.oUtils.getPath("resources","RBCFC")).init(application.locales);
    application.thisCalendar=createObject("component","#application.packagepath#.farcry.gregorianCalendar"); // gregorian calendar
    // i18n utils, BIDI, locale names, etc.
    application.i18nUtils=createObject("component","#application.packagepath#.farcry.i18nUtil");

    // System Information. This provides information about the environment on which the application is being run
    oSysInfo=createObject("component","#application.packagepath#.farcry.sysinfo");
</cfscript>

<!--- build sysinfo --->
<cfparam name="application.sysInfo" default="#structNew()#" type="struct" />
<cfparam name="application.sysInfo.machineName" default="#oSysInfo.getMachineName()#" />
<cfparam name="application.sysInfo.instanceName" default="#oSysInfo.getInstanceName()#" />
<cfparam name="application.sysInfo.farcryVersionTagLine" default="#oSysInfo.getVersionTagline()#" />
<cfparam name="application.sysInfo.version" default="#oSysInfo.getCoreVersion()#" />
<cfparam name="application.sysInfo.engine" default="#oSysInfo.getServerVersion()#" />
<cfparam name="application.sysinfo.bwebtopaccess" default="true" type="boolean" />

<!------------------------------------------------------------
Check to see if Important project specific files exist. 
This removes the need to continually check on each request. 
------------------------------------------------------------->

<!-------------------------------------------------------
Library Request Processing
	_serverSpecificRequestScope.cfm
-------------------------------------------------------->
<cfset application.sysInfo.aServerSpecificRequestScope = arrayNew(1) />
<cfif structkeyexists(application, "plugins")>
	<cfloop list="#application.plugins#" index="lib">
		<cfif fileExists("#application.path.plugins#/#lib#/config/_serverSpecificRequestScope.cfm")>
			<cfset arrayAppend(application.sysInfo.aServerSpecificRequestScope, "/farcry/plugins/#lib#/config/_serverSpecificRequestScope.cfm") />
		</cfif>
	</cfloop>
</cfif>
<!--- add project request scope processing --->
<cfif fileExists("#application.path.project#/config/_serverSpecificRequestScope.cfm")>
	<cfset arrayAppend(application.sysInfo.aServerSpecificRequestScope, "/farcry/projects/#application.projectDirectoryName#/config/_serverSpecificRequestScope.cfm") />
</cfif>

<!--- set flag for request processing --->
<cfif arraylen(application.sysInfo.aServerSpecificRequestScope)>
	<cfset application.sysInfo.bServerSpecificRequestScope = "true" />
<cfelse>
	<cfset application.sysInfo.bServerSpecificRequestScope = "false" />
</cfif>

<!-------------------------------------------------------
Library Request End
	_onRequestEnd.cfm
-------------------------------------------------------->
<cfset application.sysInfo.aOnRequestEnd = arrayNew(1) />
<cfif structkeyexists(application, "plugins")>
	<cfloop list="#application.plugins#" index="lib">
		<cfif fileExists("#application.path.plugins#/#lib#/config/_onRequestEnd.cfm")>
			<cfset arrayAppend(application.sysInfo.aOnRequestEnd, "/farcry/plugins/#lib#/config/_onRequestEnd.cfm") />
		</cfif>
	</cfloop>
</cfif>
<!--- add project request scope processing --->
<cfif fileExists("#application.path.project#/config/_onRequestEnd.cfm")>
	<cfset arrayAppend(application.sysInfo.aOnRequestEnd, "/farcry/projects/#application.projectDirectoryName#/config/_onRequestEnd.cfm") />
</cfif>


<!-------------------------------------------------------
Apps Processing
	/farcry/apps.cfm
	DEPRECATED: you should not need this crack anymore
-------------------------------------------------------->
<cfif fileExists(expandpath("/farcry/apps.cfm"))>
	<cfset application.sysInfo.bApps = "true" />
<cfelse>
	<cfset application.sysInfo.bApps = "false" />
</cfif>

<!-------------------------------------------------------
AUTOMATIC UPGRADES
-------------------------------------------------------->
<cfset application.fapi.getContentType("farRole").upgradeV62()>

<!-------------------------------------------------------
Alert user that application scope has been refreshed
-------------------------------------------------------->
<cfif isDefined("URL.updateApp") AND isBoolean(URL.updateApp) AND URL.updateApp>
	<skin:bubble title="Update App Complete" tags="system,updateapp,info" sticky="true">
		<cfoutput>The application scope has been refreshed</cfoutput>
	</skin:bubble>
</cfif>

</cfsilent>
