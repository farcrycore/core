<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_config/defaultEOPro4.cfm,v 1.1 2004/07/02 04:55:12 paul Exp $
$Author: paul $
$Date: 2004/07/02 04:55:12 $
$Name: milestone_2-2-1 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: deploys soEditor config file $
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
stConfig.codebase = "#application.url.farcry#/realobjects/eopro"; 
stConfig.height = "400";
stConfig.width = "650";
stConfig.StartUpScreenTextColor = "##000080";
stConfig.StartUpScreenBackgroundColor = "##c6d1f0";
stConfig.configURL = "#application.url.farcry#/realobjects/samples/common/config-samples.xml";
stConfig.UIConfigURL = "#application.url.farcry#/realobjects/samples/common/uiconfig-samples.xml";
stConfig.lookandfeel = "com.sun.java.swing.plaf.windows.WindowsLookAndFeel";
//stConfig.imageBase("/images
/*stConfig.cabbase = "edit-on-pro-signed.cab,tidy.cab,ssce.cab"; 
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
stConfig.width = '600';*/
stConfig.defaultcss = '#application.url.webroot#/css/dmStyle.css';
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