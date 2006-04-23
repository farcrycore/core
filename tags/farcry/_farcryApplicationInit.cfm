<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/_farcryApplicationInit.cfm,v 1.8.2.1 2005/03/04 22:29:03 tom Exp $
$Author: tom $
$Date: 2005/03/04 22:29:03 $
$Name: milestone_2-3-2 $
$Revision: 1.8.2.1 $

|| DESCRIPTION || 
$Description: initialise application level code. Sets up site config and permissions cache$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting requestTimeOut="200">

<!--- set up general config variables --->
<cfinclude template="_config.cfm">

<!--- Initialise the permissions cache for navajo/overview.cfm if they don't already exist (which they should) --->
<cfscript>
	oInit = createObject("component","#application.packagepath#.security.init");
	oInit.initPermissionCache(bForceRefresh=true);
</cfscript>

<!--- i18n specific stuff --->
<cfscript>
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
</cfscript>
