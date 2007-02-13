<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_config/defaultFile.cfm,v 1.7.2.2 2005/11/28 04:06:54 suspiria Exp $
$Author: suspiria $
$Date: 2005/11/28 04:06:54 $
$Name: p300_b113 $
$Revision: 1.7.2.2 $

|| DESCRIPTION || 
$Description: deploys file config file $


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
stConfig.fileSize = 1024000; // bytes
stConfig.fileType = "application/msword,application/pdf,application/vnd.ms-excel"; // extension
stConfig.archiveFiles = "false";
stConfig.bAllowOverwrite = "false";
stConfig.insertHTML = "*fileTitle*";
stConfig.folderpath_flash = application.path.defaultFilePath;
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
		('#arguments.configName#', '#wConfig#' )
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