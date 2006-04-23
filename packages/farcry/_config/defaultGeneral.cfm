<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_config/defaultGeneral.cfm,v 1.18 2004/01/19 23:23:27 brendan Exp $
$Author: brendan $
$Date: 2004/01/19 23:23:27 $
$Name: milestone_2-2-1 $
$Revision: 1.18 $

|| DESCRIPTION || 
$Description: deploys general config file $
$TODO: $

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
stConfig.adminEmail = "brendan@daemon.com.au"; 
stConfig.bugEmail = "farcry@daemon.com.au"; 
stConfig.newsExpiry = "14";
stConfig.newsExpiryType = "d";
stConfig.sessionTimeOut = "60";
stConfig.genericAdminNumItems = "15";
stConfig.teaserLimit = "255";
stConfig.dmFilesSearchable = "Yes";
stConfig.showForgotPassword = "Yes";
stConfig.logStats = "Yes";
stConfig.richTextEditor = "soEditor";
stConfig.fileDownloadDirectLink = "false";
stConfig.fileNameConflict = "MAKEUNIQUE";
stConfig.verityStoragePath = "#server.coldfusion.rootdir#/verity/collections/";
stConfig.adminServer = "http://#cgi.HTTP_HOST#";
stConfig.exportPath = "www/xml";
stConfig.siteTitle = "farcry";
stConfig.siteTagLine = "tell it to someone who cares";
</cfscript>

<cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">

<cftry>
	<cfquery datasource="#arguments.dsn#" name="qDelete">
		delete from #application.dbowner#config
		where configname = '#arguments.configName#'
	</cfquery>
	
	<cfquery datasource="#arguments.dsn#" name="qUpdate">
		INSERT INTO #application.dbowner#config
		(configName, wConfig)
		VALUES
		('#arguments.configName#', '#wConfig#')
	</cfquery>
	
	<cfset stStatus.message = "#arguments.configName# created successfully">
	<cfcatch>
		<cfset stStatus.message = cfcatch.message>
		<cfset stStatus.detail = cfcatch.detail>
	</cfcatch>
</cftry>