<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/_config.cfm,v 1.41 2003/12/08 05:17:05 paul Exp $
$Author: paul $
$Date: 2003/12/08 05:17:05 $
$Name: milestone_2-1-2 $
$Revision: 1.41 $

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

<!---
*********************************************************************************
 Initialise the "Custom Admin"  variables 
 *********************************************************************************
 --->
<cfset customAdminXMLPath = "#application.path.project#/customadmin/customadmin.xml">
<cfif fileExists(customAdminXMLPath)>
	<cftry>
	<cffile action="read" file="#application.path.project#/customadmin/customadmin.xml" variable="XMLFile" charset="utf-8">
	<cfset application.customAdminXML=XmlParse(XMLFile)>
	<cfif NOT isXMLDoc(application.customAdminXML)>
		<cfset application.customAdminXML="false">		
	</cfif>
	<cfcatch>
		<cfset application.customAdminXML="false">		
	</cfcatch>
	</cftry>
<cfelse>
	<!--- When we do a isXMLDoc in the app - this will fail which is useful to determine if customadmin xml has been validly loaded into memmory--->
	<cfset application.customAdminXML="false">	
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

// load TYPE and RULE metadata structures into memory
	oAlterType = createObject("component", "#application.packagepath#.farcry.alterType");
	/***************************************************************************
	loadCOAPIMetaData() and alterType.refreshAllCFCAppData() were doing the exact
	same thing line for line, so I removed loadCOAPIMetaData() and we're now using alterType. Altertype
	is a less than ideal place for this kind of task but it will do until we can agree
	on some sort ot type initialisation. ~tom
	*/
	oAlterType.refreshAllCFCAppData(); // This replaces loadCOAPIMetaData for now. I'm thinking types.init()?? ~tom

// load config files into memory
	config = createObject("component", "#application.packagepath#.farcry.config");
	qConfigList = config.list();
	for (i=1;i LTE qConfigList.Recordcount; i=i+1) "application.config.#trim(qConfigList.configname[i])#" = config.getConfig(configname=qConfigList.configname[i]);

// activate PLP storage
	if (NOT isDefined("application.path.plpstorage"))
		application.path.plpstorage = application.path.core & "/plps/plpstorage";
	if (NOT isDefined("application.path.tempfiles"))
		application.path.tempfiles = application.path.core & "/plps/tempfiles";
	application.fourq.plpstorage = application.path.core & "/plps/plpstorage"; // deprecated
	application.fourq.plppath = "/farcry/farcry_core/plps"; // deprecated

	// assets 
	/* $TODO: 
	 - need to resolve how this would be overridden from project code base
	 - /files assumes web server access to this dir -> what about secure filestores?$ */
	application.defaultFilePath = expandPath("#application.url.webroot#/files");
	application.defaultImagePath = expandpath("#application.url.webroot#/images");


	//initialise factory objects 
	application.factory.oAudit = createObject("component","#application.packagepath#.farcry.audit");
	application.factory.oTree = createObject("component","#application.packagepath#.farcry.tree");
	application.factory.oCache = createObject("component","#application.packagepath#.farcry.cache");
	application.factory.oConfig = createObject("component","#application.packagepath#.farcry.config");
	application.factory.oLocking = createObject("component","#application.packagepath#.farcry.locking");
	application.factory.oVersioning = createObject("component","#application.packagepath#.farcry.versioning");
	application.factory.oWorkflow = createObject("component","#application.packagepath#.farcry.workflow");
	application.factory.oStats = createObject("component","#application.packagepath#.farcry.stats");
	application.factory.oCategory = createObject("component","#application.packagepath#.farcry.category");
	application.factory.oGenericAdmin = createObject("component","#application.packagepath#.farcry.genericAdmin");
	application.factory.oVerity = createObject("component","#application.packagepath#.farcry.verity");
	application.factory.oCon = createObject("component","#application.packagepath#.rules.container");
	try {
		application.factory.oFU = createObject("component","#application.packagepath#.farcry.FU");
	}
	catch (Any excpt) {}

	
// initialise the security structuress --->
	request.dmSec.oAuthorisation = createObject("component","#application.securitypackagepath#.authorisation");
	request.dmSec.oAuthentication = createObject("component","#application.securitypackagepath#.authentication");


	
</cfscript>
<!--- wrap this in a cftry catch in case the policystore isn't initialised yet  --->
<!--- <cfif StructKeyExists(request,"init") AND request.init eq 0> --->

<!--- $TODO: what is this try/catch doing here?? GB$ --->
<cftry>
	<cfscript>
		stAnon = request.dmSec.oAuthorisation.getPolicyGroup(policygroupname="anonymous");
	</cfscript>

	<cfif StructKeyExists( stAnon, "policyGroupId" )>
		<cfset Application.dmSec.lDefaultPolicyGroups=stAnon.policyGroupId>
		<!--- <cftrace inline="yes" var="stAnon.policyGroupId" text="stAnon.policyGroupId"> --->
	</cfif>

	<cfcatch type="All"><cfdump var="#cfcatch#"></cfcatch>
</cftry>

<!--------------------------------------------------------------------
inialise all permission types
 - for daemon Security Model
--------------------------------------------------------------------->
<cfscript>
	aPerms = request.dmSec.oAuthorisation.getAllPermissions();
</cfscript>

<cfset Application.Permission = StructNew()>

<cfloop from="1" to="#ArrayLen(aPerms)#" index="i">
	<cfset perm=aPerms[i]>
	<cfif not StructKeyExists( application.permission, perm.permissionType )>
		<cfset application.permission[perm.permissionType] = StructNew()>
	</cfif>
	
	<cfset temp = application.permission[perm.permissionType]>
	<cfset temp[perm.permissionName] = duplicate(perm)>
</cfloop>

<!--------------------------------------------------------------------
Build NavIDs from Navigation Nodes 
--------------------------------------------------------------------->
<cfscript>
	// set up requested navid's application.navIds
	oNav = createObject("component", application.types.dmNavigation.typePath);
	application.navid = oNav.getNavAlias();
</cfscript>

<!--- application.stTypes -- legacy code required in site overview tree --->
<!--- $TODO: ferret through and remove this code GB $--->
<cfset application.stTypes = structNew()>

<!--- set the initialised flag --->
<cfset application.bInit = true>

<cfsetting enablecfoutputonly="no">