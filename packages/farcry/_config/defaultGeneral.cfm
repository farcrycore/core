<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_config/defaultGeneral.cfm,v 1.32 2005/10/13 09:14:53 geoff Exp $
$Author: geoff $
$Date: 2005/10/13 09:14:53 $
$Name: p300_b113 $
$Revision: 1.32 $

|| DESCRIPTION || 
$Description: deploys general config file $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfset stStatus = StructNew()>
<cfset stConfig = StructNew()>
<cfset aTmp = ArrayNew(1)>

<cfscript>
stConfig.adminEmail = "support@daemon.com.au"; 
stConfig.bugEmail = "farcry@daemon.com.au"; 
stConfig.newsExpiry = "14";
stConfig.newsExpiryType = "d";
stConfig.eventsExpiry = "14";
stConfig.eventsExpiryType = "d";
stConfig.sessionTimeOut = "60";
stConfig.genericAdminNumItems = "15";
stConfig.teaserLimit = "255";
stConfig.dmFilesSearchable = "Yes";
stConfig.showForgotPassword = "Yes";
stConfig.logStats = "Yes";
stConfig.richTextEditor = ""; //use default
stConfig.fileDownloadDirectLink = "false";
stConfig.fileNameConflict = "MAKEUNIQUE";
stConfig.verityStoragePath = Replace("#server.coldfusion.rootdir#/verity/collections/","\","/","All");
stConfig.adminServer = "http://#cgi.HTTP_HOST#";
stConfig.exportPath = "www/xml";
stConfig.siteTitle = "farcry";
stConfig.siteTagLine = "tell it to someone who cares";
stConfig.siteLogoPath = "";
stConfig.componentDocURL = "/CFIDE/componentutils/componentdetail.cfm";
stConfig.locale = "en_AU";
stConfig.contentReviewDaySpan = 90;
// login settings
stConfig.loginAttemptsAllowed = 3;
stConfig.loginAttemptsTimeOut = 10; // minutes
// archiving variables
stConfig.bDoArchive = "False";
stConfig.archiveDirectory = "#application.path.project#/archive/";
stConfig.archiveWeburl = "#application.url.webroot#archive/";
// added by bowden 7/23/2006. taken from b300.cfm
stConfig.categoryCacheTimeSpan = 0;
// end of add
</cfscript>

<cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">

<cftry>
	<cfquery datasource="#arguments.dsn#" name="qDelete">
		delete from #application.dbowner#config
		where configname = '#arguments.configName#'
	</cfquery>

	<!--- bowden1. changed to use cfqueryparam and clob for ora --->
	<cfswitch expression="#application.dbtype#">
	<cfcase value="ora">
	<cfquery datasource="#arguments.dsn#" name="qUpdate">
		INSERT INTO #application.dbowner#config
		(configName, wConfig)
		VALUES
		('#arguments.configName#', 
		  <cfqueryparam value='#wConfig#'  cfsqltype="cf_sql_clob" />
             )
	   </cfquery>
	</cfcase>
	<cfdefaultcase>
	   <cfquery datasource="#arguments.dsn#" name="qUpdate">
		INSERT INTO #application.dbowner#config
		(configName, wConfig)
		VALUES
		('#arguments.configName#', '#wConfig#')
	</cfquery>
	</cfdefaultcase>
	</cfswitch>
	<!--- end of change bowden1 --->
	
	<cfset stStatus.message = "#arguments.configName# created successfully">
	<cfcatch>
		<cfset stStatus.message = cfcatch.message>
		<cfset stStatus.detail = cfcatch.detail>
	</cfcatch>
</cftry>