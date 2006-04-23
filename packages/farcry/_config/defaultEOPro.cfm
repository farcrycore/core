<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_config/defaultEOPro.cfm,v 1.3 2005/08/19 05:22:13 guy Exp $
$Author: guy $
$Date: 2005/08/19 05:22:13 $
$Name: milestone_3-0-0 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: deploys soEditor config file $


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
stConfig.codebase = "#application.url.farcry#/realobjects/eopro"; 
stConfig.cabbase = "edit-on-pro-signed.cab,tidy.cab,ssce.cab"; 
stConfig.locale = "en_US"; 
stConfig.help = "eophelp/en_US/help_en_US.htm"; 
stConfig.configurl = "config.xml"; 
stConfig.toolbarurl = "toolbar.xml"; 
stConfig.sourceview = "true"; 
stConfig.sourceviewwordwrap = "false"; 
stConfig.bodyonly = "true"; 
stConfig.smartindent = "true"; 
stConfig.multipleundoredo = "true"; 
stConfig.oldfontstylemode = "false"; 
stConfig.nbspfill = "false"; 
stConfig.customcolorsenabled = "true"; 
stConfig.tablenbspfill = "true"; 
stConfig.inserttext_html = "true"; 
stConfig.oneditorloaded = "loadData"; 
stConfig.ondataloaded = "setstyle"; 
stConfig.windowfacecolor = "##ebf0ff"; 
stConfig.tabpaneactivecolor = "##b5c9e2"; 
stConfig.windowhighlightcolor = "##ffffff"; 
stConfig.lightedgecolor = "##ffffff"; 
stConfig.darkedgecolor = "##7d93ff"; 
stConfig.innertextcolor = "##000000"; 
stConfig.startupscreenbackgroundcolor = "##ebf0ff"; 
stConfig.startupscreentextcolor = "navy"; 
stConfig.height = '350';
stConfig.width = '600';
stConfig.defaultcss = '#application.url.webroot#/css/main.css';
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