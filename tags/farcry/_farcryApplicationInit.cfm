<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/_farcryApplicationInit.cfm,v 1.10.2.4 2006/01/24 09:48:36 geoff Exp $
$Author: geoff $
$Date: 2006/01/24 09:48:36 $
$Name:  $
$Revision: 1.10.2.4 $

|| DESCRIPTION ||
$Description: initialise application level code. Sets up site config and permissions cache $

|| DEVELOPER ||
$Developer: Mat Bryant (mat@daemon.com.au)$
--->
<cfsetting requestTimeOut="200">

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
    application.rb=createObject("component","#application.packagepath#.farcry.javaRB");
    application.thisCalendar=createObject("component","#application.packagepath#.farcry.gregorianCalendar"); // gregorian calendar
    // i18n utils, BIDI, locale names, etc.
    application.i18nUtils=createObject("component","#application.packagepath#.farcry.i18nUtil");
    //check if logged in
    if(isDefined("session.dmProfile.locale"))
        //load profile specific rb
        application.adminBundle[session.dmProfile.locale]=application.rB.getResourceBundle("#application.path.core#/packages/resources/admin.properties",session.dmProfile.locale,false);
    //Make sure that the default application rb is loaded.
    //This rb is used by scheduled tasks etc who don't create a session
    if(NOT structKeyExists(application.adminBundle, application.config.general.locale))
        //load the application specific rb
        application.adminBundle[application.config.general.locale]=application.rB.getResourceBundle("#application.path.core#/packages/resources/admin.properties",application.config.general.locale,false);

    // refresh the friendly url sub-system
    objFU = createObject("component","#application.packagepath#.farcry.fu");
    objFU.refreshApplicationScope();
    
    
    // System Information. This provides information about the environment on which the application is being run
    oSysInfo=createObject("component","#application.packagepath#.farcry.sysinfo");
    
    application.sysInfo=structNew();    
	application.sysInfo.machineName = oSysInfo.getMachineName();
	application.sysInfo.instanceName = oSysInfo.getInstanceName();
	application.sysInfo.farcryVersionTagLine = oSysInfo.getVersionTagline();
	
	
</cfscript>


<!--------------------------------------------------------------------------------------------------------------- 
Check to see if Important project specific files exist. This removes the need to continually check on each request. 
------------------------------------------------------------------------------------------------------------------>

<!--- _serverSpecificRequestScope.cfm --->
<cfif fileExists("#application.path.project#/config/_serverSpecificRequestScope.cfm")>
	<cfset application.sysInfo.bServerSpecificRequestScope = "true" />
<cfelse>
	<cfset application.sysInfo.bServerSpecificRequestScope = "false" />
</cfif>

<!--- apps.cfm --->
<cfif fileExists("/farcry/apps.cfm")>
	<cfset application.sysInfo.bApps = "true" />
<cfelse>
	<cfset application.sysInfo.bApps = "false" />
</cfif>
	

<!--- alert user that application scope has been refreshed --->
<cfif isDefined("URL.updateApp") AND URL.updateApp>
	<cfhtmlhead text="<script language='JavaScript'>alert('Application Scope Refreshed!');</script>">
</cfif>
