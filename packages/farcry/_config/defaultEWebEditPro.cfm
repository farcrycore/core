<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_config/defaultEWebEditPro.cfm,v 1.3 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-0 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: deploys eWebEditPro config file $


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
stConfig.path = "undefined";
stConfig.maxContentSize="undefined"; 
stConfig.editorName="body"; 
stConfig.alternativeEditorName="undefined"; 
stConfig.width="100%"; 
stConfig.height="100%"; 
stConfig.license="undefined"; 
stConfig.locale="undefined"; 
stConfig.config="undefined"; 
stConfig.styleSheet="undefined"; 
stConfig.bodyStyle="undefined"; 
stConfig.hideAboutButton="false"; 
stConfig.onDblClickElement="undefined"; 
stConfig.onExecCommand="undefined"; 
stConfig.onFocus="undefined"; 
stConfig.onBlur="undefined"; 
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