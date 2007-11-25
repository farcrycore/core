<cfsetting requestTimeOut="200">
<cfsilent>
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@Description: initialise application level code. Sets up site config and permissions cache  --->
<!--- @@Developer: Mat Bryant (mat@daemon.com.au) --->


<!--- set up general config variables --->
<cfinclude template="_config.cfm">

<!--- Initialise the permissions cache for navajo/overview.cfm if they don't already exist (which they should) --->
<cfscript>
    oInit = createObject("component","#application.packagepath#.security.init");
    oInit.initPermissionCache(bForceRefresh=true);

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

   // refresh the friendly url sub-system
    objFU = createObject("component","#application.packagepath#.farcry.fu");
    objFU.refreshApplicationScope();
    
    
    // System Information. This provides information about the environment on which the application is being run
    oSysInfo=createObject("component","#application.packagepath#.farcry.sysinfo");
</cfscript>

<!--- build sysinfo --->
<cfparam name="application.sysInfo" default="#structNew()#" type="struct" />
<cfparam name="application.sysInfo.machineName" default="#oSysInfo.getMachineName()#" />
<cfparam name="application.sysInfo.instanceName" default="#oSysInfo.getInstanceName()#" />
<cfparam name="application.sysInfo.farcryVersionTagLine" default="oSysInfo.getVersionTagline()" />
<cfparam name="application.sysinfo.bwebtopaccess" default="true" type="boolean" />

<!------------------------------------------------------------
Check to see if Important project specific files exist. 
This removes the need to continually check on each request. 
------------------------------------------------------------->

<!-------------------------------------------------------
Library Request Processing
	_serverSpecificRequestScope.cfm
-------------------------------------------------------->
<cfif structkeyexists(application, "plugins")>
	<cfset application.sysInfo.aServerSpecificRequestScope = arrayNew(1) />
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
Alert user that application scope has been refreshed
-------------------------------------------------------->
<cfif isDefined("URL.updateApp") AND URL.updateApp>
	<cfhtmlhead text="<script language='JavaScript'>alert('Application Scope Refreshed!');</script>">
</cfif>

</cfsilent>