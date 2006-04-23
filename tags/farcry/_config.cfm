<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/_config.cfm,v 1.36 2003/09/23 08:05:17 brendan Exp $
$Author: brendan $
$Date: 2003/09/23 08:05:17 $
$Name: b201 $
$Revision: 1.36 $

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

// load various metadata structures into memory
	loadCOAPIMetaData(); // official COAPI type structures
	
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

<!--- </cfif> --->

<!--------------------------------------------------------------------
Build NavIDs from Navigation Nodes 
--------------------------------------------------------------------->
<cfscript>
	// set up requested navid's application.navIds
	oNav = createObject("component", "#application.packagepath#.types.dmNavigation");
	application.navid = oNav.getNavAlias();
</cfscript>

<!--- application.stTypes -- legacy code required in site overview tree --->
<!--- $TODO: ferret through and remove this code GB $--->
<cfset application.stTypes = structNew()>

<!--- set the initialised flag --->
<cfset application.bInit = true>


<!--- 
$TODO:
 - move this function to the base fourq CFC or other more suitable place when ready$
--->
<cffunction name="loadCOAPIMetaData" hint="Load metadata for content and rule types.">
	<cfdirectory directory="#application.path.core#/packages/types" name="qTypesDir" filter="dm*.cfc" sort="name">
	<cfdirectory directory="#application.path.project#/packages/types" name="qCustomTypesDir" filter="*.cfc" sort="name">
	
	<!--- Init all CORE types --->
	<cfloop query="qTypesDir">
		<cftry>
			<cfscript>
			typename = left(qTypesDir.name, len(qTypesDir.name)-4); //remove the .cfc from the filename
			"#typename#" = createObject("Component", "#application.packagepath#.types.#typename#");
			evaluate(typename).initMetaData("application.types");
			setVariable("application.types['#typename#'].bCustomType",0);
			</cfscript>
			<cfcatch></cfcatch>
		</cftry>
	</cfloop>	
	<!--- Now init all Custom Types --->
	<cfloop query="qCustomTypesDir">
		<cftry>
			<cfscript>
			typename = left(qCustomTypesDir.name, len(qCustomTypesDir.name)-4); //remove the .cfc from the filename
			"#typename#" = createObject("Component", "#application.custompackagepath#.types.#typename#");
			evaluate(typename).initMetaData("application.types");
			setVariable("application.types['#typename#'].bCustomType",1);
			</cfscript>
			<cfcatch></cfcatch>
		</cftry>
	</cfloop>
	
	<cfscript>
	rules = createObject("Component", "#application.packagepath#.rules.rules");
	qRules = rules.getRules(); 
	</cfscript>

	<!--- Populate application.rules scope with rule metatdata --->
	<cfloop query="qRules">
		<cfscript>
			
			if(qRules.bCustom)
				"#qRules.rulename#" = createObject("Component","#application.custompackagepath#.rules.#qRules.rulename#");
			else
			{
				"#qRules.rulename#" = createObject("Component","#application.packagepath#.rules.#qRules.rulename#");
			}		
			evaluate("#qRules.rulename#").initMetaData("application.rules");
			/*************************************************************************************
			This will make sure that if developers have forgotten to include the BCustomRule attribute in
			each rule CFC, that it does indeed get included in the COAPI rule metadata.
			*************************************************************************************/
			if(qRules.bCustom)
				setVariable("application.rules['#qrules.rulename#'].bCustomRule",1);			
			else		
				setVariable("application.rules['#qrules.rulename#'].bCustomRule",0);
										
		</cfscript>
	</cfloop>
</cffunction>

<cfsetting enablecfoutputonly="no">