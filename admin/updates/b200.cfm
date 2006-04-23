<!--- @@description:Adds number of items to show in generic Admin and teaser length to general config<br>
Deploys dmEmail object<br> 
Adds new permissions<br>
Deploys new stats table<br>
Deploys new dmCron object<br>
Deploys refContainer table<br>
Adds new directories to app--->

<html>
<head>
<title>Farcry Core b200 Update - <cfoutput>#application.applicationname#</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="<cfoutput>#application.url.farcry#</cfoutput>/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">

<cfif isdefined("form.submit")>
	<cfset error = 0>
	
	<!--- Add entry to general config --->
	<cfset application.config.general.genericAdminNumItems = "15">
	<cfset application.config.general.teaserLimit = "255">
	<cfset application.config.general.bugEmail = "farcry@daemon.com.au">
	<cfset application.config.general.exportPath = "www/xml">
	<cfwddx action="CFML2WDDX" input="#application.config.general#" output="wConfig">
	
	<cfquery datasource="#application.dsn#" name="qUpdate">
		UPDATE #application.dbowner#config
		set wConfig = '#wConfig#'
		where configName = 'general'
	</cfquery>	
	
	<!--- add entry to fu config --->
	<cfset application.config.fusettings.suffix = "">
	<cfwddx action="CFML2WDDX" input="#application.config.fusettings#" output="wConfig">
	
	<cfquery datasource="#application.dsn#" name="qUpdate">
		UPDATE #application.dbowner#config
		set wConfig = '#wConfig#'
		where configName = 'fusettings'
	</cfquery>	
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Config updated<p></p></cfoutput><cfflush>
	
	<!--- deploy dmEmail type --->
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Deploying dmEmail object type...</cfoutput><cfflush>
	<cfscript>
		alterType = createObject("component","#application.packagepath#.farcry.alterType");
		alterType.deployCFC("dmEmail");
	</cfscript>
	
	<cfoutput>done<p></p></cfoutput><cfflush>
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Creating new permissions...</cfoutput><cfflush>
	
	<!--- alter permission tables that weren't created with auto id --->
	<cfif application.dbtype eq "mysql">
		<cfquery name="alter" datasource="#application.dsn#">
			alter table `#application.dbowner#dmPermission` ,change `PermissionId` `PermissionId` int (11) NOT NULL AUTO_INCREMENT
		</cfquery>
		<cfquery name="alter" datasource="#application.dsn#">
			alter table `#application.dbowner#dmPolicyGroup` ,change `PolicyGroupId` `PolicyGroupId` int (11) NOT NULL AUTO_INCREMENT
		</cfquery>
	</cfif>
	
	<!--- add permissions --->
	<cfscript>
		oAuthorisation=createObject("component","#application.securitypackagepath#.authorisation");
		
		// create help tab permission
		oAuthorisation.createPermission(PermissionID = "-1",PermissionName = "MainNavHelpTab",PermissionNotes = "Allows access to the main help tab",PermissionType = "PolicyGroup");
		
		// get policy groups
		aGroups = oAuthorisation.getAllPolicyGroups();
		
		// loop over policy groups and set value for new permission
		for (i=1; i lte arrayLen(aGroups); i = i +1) {
			if (aGroups[i].policyGroupName eq "SysAdmin" or aGroups[i].policyGroupName eq "SiteAdmin") {
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="MainNavHelpTab",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
			} else {
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="MainNavHelpTab",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
			}
		}
		
		// create reporting tab permission
		oAuthorisation.createPermission(PermissionID = "-1",PermissionName = "MainNavReportingTab",PermissionNotes = "Allows access to the main reporting tab",PermissionType = "PolicyGroup");
		
		// get policy groups
		aGroups = oAuthorisation.getAllPolicyGroups();
		
		// loop over policy groups and set value for new permission
		for (i=1; i lte arrayLen(aGroups); i = i +1) {
			if (aGroups[i].policyGroupName eq "SysAdmin" or aGroups[i].policyGroupName eq "SiteAdmin") {
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="MainNavReportingTab",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
			} else {
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="MainNavReportingTab",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
			}
		}
		
		// create stats tab permission
		oAuthorisation.createPermission(PermissionID = "-1",PermissionName = "ReportingStatsTab",PermissionNotes = "Allows access to the reporting statistics sub tab",PermissionType = "PolicyGroup");
		
		// loop over policy groups and set value for new permission
		for (i=1; i lte arrayLen(aGroups); i = i +1) {
			if (aGroups[i].policyGroupName eq "SysAdmin" or aGroups[i].policyGroupName eq "SiteAdmin") {
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="ReportingStatsTab",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
			} else {
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="ReportingStatsTab",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
			}
		}
		
		// create export tab permission
		oAuthorisation.createPermission(PermissionID = "-1",PermissionName = "ContentExportTab",PermissionNotes = "Allows access to the export sub tab",PermissionType = "PolicyGroup");
		
		// get policy groups
		aGroups = oAuthorisation.getAllPolicyGroups();
		
		// loop over policy groups and set value for new permission
		for (i=1; i lte arrayLen(aGroups); i = i +1) {
			if (aGroups[i].policyGroupName eq "SysAdmin" or aGroups[i].policyGroupName eq "SiteAdmin") {
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="ContentExportTab",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
			} else {
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="ContentExportTab",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
			}
		}
		
		// create dmEvent permission
		oAuthorisation.createPermission(PermissionID = "-1",PermissionName = "EventCanApproveOwnContent",PermissionNotes = "Allows user to approve their own dmEvent objects",PermissionType = "PolicyGroup");
		
		// loop over policy groups and set value for new permission
		for (i=1; i lte arrayLen(aGroups); i = i +1) {
			//set permissions against different policy groupds
			if (aGroups[i].policyGroupName eq "SysAdmin" or aGroups[i].policyGroupName eq "SiteAdmin" or aGroups[i].policyGroupName eq "Publishers") {
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="EventCanApproveOwnContent",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
			} else if (aGroups[i].policyGroupName eq "Contributors") {
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="EventCanApproveOwnContent",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
			} else {
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="EventCanApproveOwnContent",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
			}
		}
		
		// create dmFact permission
		oAuthorisation.createPermission(PermissionID = "-1",PermissionName = "FactApprove",PermissionNotes = "Allows approval of dmFact objects",PermissionType = "PolicyGroup");
		oAuthorisation.createPermission(PermissionID = "-1",PermissionName = "FactCreate",PermissionNotes = "Allows creation of dmFact objects",PermissionType = "PolicyGroup");
		oAuthorisation.createPermission(PermissionID = "-1",PermissionName = "FactDelete",PermissionNotes = "Allows deletion of dmFact objects",PermissionType = "PolicyGroup");
		oAuthorisation.createPermission(PermissionID = "-1",PermissionName = "FactEdit",PermissionNotes = "Allows editing of dmFact objects",PermissionType = "PolicyGroup");
		oAuthorisation.createPermission(PermissionID = "-1",PermissionName = "FactRequestApproval",PermissionNotes = "Allows user to request approval for dmFact objects",PermissionType = "PolicyGroup");
		oAuthorisation.createPermission(PermissionID = "-1",PermissionName = "FactCanApproveOwnContent",PermissionNotes = "Allows user to approve their own dmFact objects",PermissionType = "PolicyGroup");
		
		// loop over policy groups and set value for new permission
		for (i=1; i lte arrayLen(aGroups); i = i +1) {
			//set permissions against different policy groupds
			if (aGroups[i].policyGroupName eq "SysAdmin" or aGroups[i].policyGroupName eq "SiteAdmin" or aGroups[i].policyGroupName eq "Publishers") {
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="FactApprove",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="FactCreate",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="FactDelete",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="FactEdit",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="FactRequestApproval",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="FactCanApproveOwnContent",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
			} else if (aGroups[i].policyGroupName eq "Contributors") {
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="FactApprove",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="FactCreate",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="FactDelete",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="FactEdit",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="FactRequestApproval",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="FactCanApproveOwnContent",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
			} else {
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="FactApprove",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="FactCreate",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="FactDelete",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="FactEdit",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="FactRequestApproval",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="FactCanApproveOwnContent",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
			}
		}
		
		// create dmLink permission
		oAuthorisation.createPermission(PermissionID = "-1",PermissionName = "LinkApprove",PermissionNotes = "Allows approval of dmLink objects",PermissionType = "PolicyGroup");
		oAuthorisation.createPermission(PermissionID = "-1",PermissionName = "LinkCreate",PermissionNotes = "Allows creation of dmLink objects",PermissionType = "PolicyGroup");
		oAuthorisation.createPermission(PermissionID = "-1",PermissionName = "LinkDelete",PermissionNotes = "Allows deletion of dmLink objects",PermissionType = "PolicyGroup");
		oAuthorisation.createPermission(PermissionID = "-1",PermissionName = "LinkEdit",PermissionNotes = "Allows editing of dmLink objects",PermissionType = "PolicyGroup");
		oAuthorisation.createPermission(PermissionID = "-1",PermissionName = "LinkRequestApproval",PermissionNotes = "Allows user to request approval for dmLink objects",PermissionType = "PolicyGroup");
		oAuthorisation.createPermission(PermissionID = "-1",PermissionName = "LinkCanApproveOwnContent",PermissionNotes = "Allows user to approve their own dmLink objects",PermissionType = "PolicyGroup");
		
		// loop over policy groups and set value for new permission
		for (i=1; i lte arrayLen(aGroups); i = i +1) {
			//set permissions against different policy groupds
			if (aGroups[i].policyGroupName eq "SysAdmin" or aGroups[i].policyGroupName eq "SiteAdmin" or aGroups[i].policyGroupName eq "Publishers") {
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="LinkApprove",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="LinkCreate",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="LinkDelete",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="LinkEdit",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="LinkRequestApproval",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="LinkCanApproveOwnContent",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
			} else if (aGroups[i].policyGroupName eq "Contributors") {
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="LinkApprove",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="LinkCreate",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="LinkDelete",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="LinkEdit",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="LinkRequestApproval",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="LinkCanApproveOwnContent",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
			} else {
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="LinkApprove",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="LinkCreate",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="LinkDelete",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="LinkEdit",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="LinkRequestApproval",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="LinkCanApproveOwnContent",PermissionType = "PolicyGroup",Reference="PolicyGroup",status=-1);
			}
		}
		
		// rename audit reporting permission
		stAuditPerm = oAuthorisation.getPermission(permissionName="SecurityAuditTab",permissionType="PolicyGroup");
		try {
			oAuthorisation.updatePermission(permissionID=stAuditPerm.permissionId,permissionName="ReportingAuditTab",PermissionNotes = "Allows access to the reporting audit sub tab",permissionType="policygroup");
		}
		catch (any excpt) {}
		
		// rename dynamic tab permission
		stAuditPerm = oAuthorisation.getPermission(permissionName="DyamicCategorisationTab",permissionType="PolicyGroup");
		try {
			oAuthorisation.updatePermission(permissionID=stAuditPerm.permissionId,permissionName="ContentCategorisationTab",PermissionNotes = "Allows access to the content categorisation sub tab",permissionType="policygroup");
		}
		catch (any excpt) {}
		
		stAuditPerm = oAuthorisation.getPermission(permissionName="MainNavDynamicTab",permissionType="PolicyGroup");
		try {
			oAuthorisation.updatePermission(permissionID=stAuditPerm.permissionId,permissionName="MainNavContentTab",PermissionNotes = "Access to the Content tab in the header",permissionType="policygroup");
		}
		catch (any excpt) {}
		
		// update permission cache
		oAuthorisation.updateObjectPermissionCache(reference="policygroup");
		
		//NEW sendToTrash dmNavigation Permission
		oAuthorisation.createPermission(PermissionID = "-1",PermissionName = "SendToTrash",PermissionNotes = "Allows user to send objects to the trash can",PermissionType = "dmNavigation");
				
		// loop over policy groups and set value for new permission
		lGroups = 'publishers,sysadmin,siteadmin';
		for (i=1; i lte arrayLen(aGroups); i = i +1)
		{
			if (listContainsNoCase(lGroups,aGroups[i].policyGroupName))
			{
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="SendToTrash",PermissionType = "dmNavigation",Reference="#application.navid.root#",status=1);
			} else
			{
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=aGroups[i].policyGroupId,PermissionName="SendToTrash",PermissionType = "dmNavigation",Reference="#application.navid.root#",status=-1);
			}
		}
		
		oAuthorisation.updateObjectPermissionCache(objectid="#application.navid.root#");
	</cfscript> 

	<cfoutput>done<p></p></cfoutput><cfflush>
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Deploying new stats table...</cfoutput><cfflush>
	<!--- deploy stats search table --->
	<cfswitch expression="#application.dbtype#">
		<cfcase value="ora">
			<!--- check search stats table exists, for later --->		
			<cfquery datasource="#application.dsn#" name="qCheck">
				SELECT count(*) AS tblExists FROM USER_TABLES
				WHERE TABLE_NAME = 'STATSSEARCH'
			</cfquery>
		
			<cfif qCheck.tblExists>
				<cfquery datasource="#application.dsn#" name="qDrop">
					DROP TABLE #application.dbowner#statsSearch
				</cfquery>
			</cfif>
			
			<!--- create the stats --->
			<cfscript>
				sql = "CREATE TABLE #application.dbowner#STATSSEARCH (
LOGID VARCHAR2(50) NOT NULL ,
SEARCHSTRING VARCHAR2(255) NOT NULL ,
LCOLLECTIONS VARCHAR2(1024) NOT NULL ,
RESULTS NUMBER NOT NULL,
REMOTEIP VARCHAR2(50) NOT NULL,
LOGDATETIME date NOT NULL,
REFERER VARCHAR2(1024) NOT NULL,
LOCALE VARCHAR2(100) NOT NULL,
CONSTRAINT PK_STATSSEARCH PRIMARY KEY (LOGID))
";	
			</cfscript>
			
			<cfquery datasource="#application.dsn#" name="qCreate">
				#sql#
			</cfquery>
			<cfscript>
				sql = "CREATE INDEX #application.dbowner#IDX_STATSSEARCH ON STATSSEARCH(searchstring,logdatetime)";
			</cfscript>
			<cfquery datasource="#application.dsn#" name="qCreate">
				#sql#
			</cfquery>
			
		</cfcase>
		<cfcase value="mysql">
			
			<cfquery datasource="#application.dsn#" name="qDrop">
				DROP TABLE IF EXISTS #application.dbowner#statsSearch
			</cfquery>			
			
			<!--- create the stats --->
			<cfscript>
				sql = "CREATE TABLE #application.dbowner#statsSearch (
LOGID VARCHAR(50) NOT NULL ,
SEARCHSTRING VARCHAR(255) NOT NULL ,
LCOLLECTIONS TEXT ,
RESULTS INTEGER NOT NULL,
REMOTEIP VARCHAR(50) NOT NULL,
LOGDATETIME datetime NOT NULL,
REFERER TEXT,
LOCALE VARCHAR(100) NOT NULL,
CONSTRAINT PK_STATSSEARCH PRIMARY KEY (LOGID))
";		
			</cfscript>
			
			<cfquery datasource="#application.dsn#" name="qCreate">
				#sql#
			</cfquery>
			<cfscript>
				sql = "CREATE INDEX #application.dbowner#IDX_STATSSEARCH ON statsSearch(searchString,logdatetime)";
			</cfscript>
			<cfquery datasource="#application.dsn#" name="qCreate">
				#sql#
			</cfquery>
			
		</cfcase>
	
		<cfdefaultcase>
		
			<cfquery datasource="#application.dsn#" name="qDrop">
			if exists (select * from sysobjects where name = 'statsSearch')
			DROP TABLE statsSearch
	
			-- return recordset to stop CF bombing out?!?
			select count(*) as blah from sysobjects
			</cfquery>
			
			
			<!--- create the stats --->
			<cfquery datasource="#application.dsn#" name="qCreate">
			CREATE TABLE #application.dbowner#statsSearch (
				[logId] [varchar] (50) NOT NULL ,
				[searchString] [varchar] (255) NOT NULL ,
				[lCollections] [varchar] (1024) NOT NULL ,
				[remoteip] [varchar] (50) NOT NULL ,
				[results] [int] NOT NULL,
				[referer] [varchar] (1024) NOT NULL ,
				[locale] [varchar] (100) NOT NULL ,
				[logDateTime] [datetime] NOT NULL			
			) ON [PRIMARY];
			
			ALTER TABLE #application.dbowner#statsSearch WITH NOCHECK ADD 
				CONSTRAINT [PK_statsSearch] PRIMARY KEY CLUSTERED 
				(
					[logId]
				)  ON [PRIMARY];
				
			CREATE NONCLUSTERED INDEX [statsSearch0] ON #application.dbowner#statsSearch([searchString], [logdatetime])
			</cfquery>
			
		</cfdefaultcase>
	</cfswitch>
	
	<cfoutput>done<p></p></cfoutput><cfflush>
	
	<!--- deploy dmCron type --->
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Deploying dmCron object type...</cfoutput><cfflush>
	<cfscript>
		alterType = createObject("component","#application.packagepath#.farcry.alterType");
		alterType.deployCFC("dmCron");
	</cfscript>
	
	<cfoutput>done<p></p></cfoutput><cfflush>

	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Creating new refContainers...</cfoutput><cfflush>
	<cfscript>
		oCon = createObject("component","#application.packagepath#.rules.container");
		oCon.deployRefContainers(dsn=application.dsn,dbtype=application.dbtype,dbowner=application.dbowner);
	</cfscript>

	<cfoutput>done<p></p></cfoutput><cfflush>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Adding new directories to app...</cfoutput><cfflush>
	
	<!--- try to add new directories to app --->
	<cftry>
		<cfdirectory action="CREATE" directory="#application.path.project#/#application.config.general.exportPath#">
		<cfdirectory action="CREATE" directory="#application.path.project#/system">
		<cfdirectory action="CREATE" directory="#application.path.project#/system/dmCron">
		<cfdirectory action="CREATE" directory="#application.path.project#/system/dmConfig">
		<cfdirectory action="CREATE" directory="#application.path.project#/customadmin/login">
		<cfoutput>done<p></p></cfoutput><cfflush>
		
		<cfcatch>
			<cfoutput>Error creating directories. You need to manually create the following directories<p></p>
			<ul>
				<li>#application.path.project#/#application.config.general.exportPath#</li>
				<li>#application.path.project#/system</li>
				<li>#application.path.project#/system/dmCron</li>
				<li>#application.path.project#/system/dmConfig</li>
				<li>#application.path.project#/customadmin/login</li>			
			</ul>
			</cfoutput><cfflush>
		</cfcatch>
	</cftry>
	
	

<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Adds new config items</li>
		<li type="square">Deploys dmEmail type</li>
		<li type="square">Adds new permissions</li>
		<li type="square">Deploys new stats table</li>
		<li type="square">Deploys new dmCron type</li>
		<li type="square">Deploys new refContainers Table</li>
		<li type="square">Adds new directories to app</li>
	</ul> 
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run b200 Update" name="submit">
	</form>
	
	</cfoutput>
</cfif>

</body>
</html>
