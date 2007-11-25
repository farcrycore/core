<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/farcry/_config.cfm,v 1.48 2005/09/08 15:53:36 tom Exp $
$Author: tom $
$Date: 2005/09/08 15:53:36 $
$Name: milestone_3-0-1 $
$Revision: 1.48 $

|| DESCRIPTION || 
$Description: included file for one-time initialisation of application constants $
$TODO: clean-up deprecated variables$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (paul@daemon.com.au) $
--->
<cfsetting enablecfoutputonly="Yes">

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
<cfelseif structKeyExists(application, "defaultFilePath")>
	<cfset application.path.defaultFilePath = application.defaultFilePath>
<cfelse>
	<!--- Defaults --->
	<cfset application.path.defaultFilePath = "#application.path.project#/www/files">
	<!--- Deprecated in b230; Use application.path.defaultFilePath instead --->
	<cfset application.defaultFilePath = application.path.defaultFilePath>
</cfif>		 

<!--- Image Path --->
<cfif structKeyExists(application.path, "defaultImagePath")>
	<cfset application.defaultImagePath = application.path.defaultImagePath>
<cfelseif structKeyExists(application, "defaultImagePath")>
	<cfset application.path.defaultImagePath = application.defaultImagePath>
<cfelse>
	<!--- Defaults --->
	<cfset application.path.defaultImagePath = "#application.path.project#/www/images">
	<!--- Deprecated in b230; Use application.path.defaultImagePath instead --->
	<cfset application.defaultImagePath = application.path.defaultImagePath>
</cfif>		 

<cfscript>
	/* $TODO:
	maybe path.webskin should be replaced by a component level 
	extended metadata for handler path?  The primary reference for 
	this var in any event is types.types.getDisplay()$ */
	// abs path to webskin handlers
	application.path.webskin = application.path.project & "/webskin";
	// path rel to project cf mapping for webskin handler root
	application.path.handler = "webskin";
	
// application web urls
	application.url.conjurer = application.url.webroot & "/index.cfm"; // general invoker
	//initialise factory objects 
	application.factory.oAuthorisation = createobject("component","#application.packagepath#.security.authorisation");
	application.factory.oWebtop = createobject("component","#application.packagepath#.farcry.webtop").init();
	application.factory.oUtils = createobject("component","#application.packagepath#.farcry.utils");
	application.factory.oAudit = createObject("component","#application.packagepath#.farcry.audit");
	application.factory.oTree = createObject("component","#application.packagepath#.farcry.tree");
	application.factory.oCache = createObject("component","#application.packagepath#.farcry.cache");
	application.factory.oLocking = createObject("component","#application.packagepath#.farcry.locking");
	application.factory.oVersioning = createObject("component","#application.packagepath#.farcry.versioning");
	application.factory.oWorkflow = createObject("component","#application.packagepath#.farcry.workflow");
	application.factory.oStats = createObject("component","#application.packagepath#.farcry.stats");
	application.factory.oCategory = createObject("component","#application.packagepath#.farcry.category");
	application.factory.oGenericAdmin = createObject("component","#application.packagepath#.farcry.genericAdmin");
	application.factory.oVerity = createObject("component","#application.packagepath#.farcry.verity");
	application.factory.oCon = createObject("component","#application.packagepath#.rules.container");
	application.factory.oGeoLocator = createObject("component","#application.packagepath#.farcry.geoLocator");
	application.bGeoLocatorInit = application.factory.oGeoLocator.init();
	try {
		application.factory.oFU = createObject("component","#application.packagepath#.farcry.FU");
	}
	catch (Any excpt) {}
	
	application.security = createobject("component","#application.packagepath#.security.security").init();

	// load TYPE and RULE metadata structures into memory
	oAlterType = createObject("component", "#application.packagepath#.farcry.alterType");
	/***************************************************************************
	loadCOAPIMetaData() and alterType.refreshAllCFCAppData() were doing the exact
	same thing line for line, so I removed loadCOAPIMetaData() and we're now using alterType. Altertype
	is a less than ideal place for this kind of task but it will do until we can agree
	on some sort ot type initialisation. ~tom
	*/
	oAlterType.refreshAllCFCAppData(); // This replaces loadCOAPIMetaData for now. I'm thinking types.init()?? ~tom

// activate PLP storage
	if (NOT isDefined("application.path.plpstorage"))
		application.path.plpstorage = application.path.core & "/plps/plpstorage";
	if (NOT isDefined("application.path.tempfiles"))
		application.path.tempfiles = application.path.core & "/plps/tempfiles";
	application.fourq.plpstorage = application.path.core & "/plps/plpstorage"; // deprecated
	application.fourq.plppath = "/farcry/core/plps"; // deprecated

</cfscript>

<!--- Load config data --->
<cfset oConfig = createobject("component",application.stCOAPI.farConfig.packagepath) />
<cfloop list="#oConfig.getConfigKeys()#" index="configkey">
	<cfset application.config[configkey] = oConfig.getConfig(configkey) />
</cfloop>

<!--- wrap this in a cftry catch in case the policystore isn't initialised yet  --->
<!--- <cfif StructKeyExists(request,"init") AND request.init eq 0> --->

<!--------------------------------------------------------------------
Build NavIDs from Navigation Nodes 
--------------------------------------------------------------------->
<cfscript>
	// set up requested navid's application.navIds
	oNav = createObject("component", application.types.dmNavigation.typePath);
	application.navid = oNav.getNavAlias();
</cfscript>

<!--- Build catids from category nodes --->

<cfscript>
	oCat = createObject("component", "#application.packagepath#.farcry.category");
	application.catid = oCat.getCatAliases();
</cfscript>

<!--- application.stTypes -- legacy code required in site overview tree --->
<!--- $TODO: ferret through and remove this code GB $--->
<cfset application.stTypes = structNew()>


<cfsetting enablecfoutputonly="no">