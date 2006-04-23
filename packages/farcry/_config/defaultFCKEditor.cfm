<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_config/defaultFCKEditor.cfm,v 1.2.2.1 2006/02/28 23:46:27 tom Exp $
$Author: tom $
$Date: 2006/02/28 23:46:27 $
$Name: milestone_3-0-1 $
$Revision: 1.2.2.1 $

|| DESCRIPTION || 
$Description: deploys FCKEditor config file $


|| DEVELOPER ||
$Developer: Nathan Mische (nmische@gmail.com) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfset stStatus = StructNew()>
<cfset stConfig = StructNew()>
<cfset aTmp = ArrayNew(1)>

<cfscript>
stConfig.toolbarSet = "Default";
stConfig.checkBrowser = "True";
stConfig.height = "500";
stConfig.width = "595";
stConfig.skin = "default";
stConfig.customConfigurationsPath = "/js/customfckconfig.js";
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