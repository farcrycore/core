<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_config/defaultHTMLArea.cfm,v 1.1 2004/06/16 07:35:42 brendan Exp $
$Author: brendan $
$Date: 2004/06/16 07:35:42 $
$Name: milestone_2-2-1 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: deploys HTMLArea config file $
$TODO: $

|| DEVELOPER ||
$Developer: Stephen Milligan (spike@spike.org.uk) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfset stStatus = StructNew()>
<cfset stConfig = StructNew()>
<cfset aTmp = ArrayNew(1)>

<cfscript>
stConfig.Toolbar1 = "['formatblock', 'space', 'bold', 'italic', 'underline', 'separator', 'strikethrough', 'subscript', 'superscript', 'separator', 'copy', 'cut', 'paste', 'space', 'undo', 'redo' ]";
stConfig.Toolbar2 = "[ 'justifyleft', 'justifycenter', 'justifyright', 'justifyfull', 'separator', 'insertorderedlist', 'insertunorderedlist', 'outdent', 'indent', 'separator', 'inserthorizontalrule', 'createlink', 'inserttable', 'htmlmode', 'separator', 'popupeditor' ]";
stConfig.URLPath = '/lib/htmlarea/';
stConfig.lang = 'en';
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