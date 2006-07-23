<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_config/defaultImage.cfm,v 1.7.2.2 2005/11/17 01:31:39 guy Exp $
$Author: guy $
$Date: 2005/11/17 01:31:39 $
$Name: p300_b113 $
$Revision: 1.7.2.2 $

|| DESCRIPTION || 
$Description: deploys image config file $


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
stConfig.imageSize = 102400; // bytes
stConfig.imageType = "image/pjpeg,image/gif,image/png,image/jpg,image/jpeg,image/x-png"; // extension
stConfig.imageWidth = 500; // pixels
stConfig.imageHeight = 500; // pixels
stConfig.archiveFiles = "false";
// bowden 7/23/2006. Changed default to be true. taken from b300.cfm
stConfig.bAllowOverwrite = "true";
// end of change
stConfig.thumbnailWidth = 80;
stConfig.thumbnailHeight = 80;
stConfig.insertHTML = "<a href='*imagefile*' target='_blank'><img src='*thumbnail*' border=0 alt='*alt*'></a>";

stConfig.SourceImagePath = "#application.path.project#\www\images\SourceImages"; // Server path of Source Images
stConfig.ThumbnailImagePath = "#application.path.project#\www\images\ThumbnailImages"; // Server path of Thumbnail Images
stConfig.StandardImagePath = "#application.path.project#\www\images\StandardImages"; // Server path of Standard Images
stConfig.SourceImageURL = "/images/SourceImages"; // URL path of Standard Images
stConfig.ThumbnailImageURL = "/images/ThumbnailImages"; // URL path of Thumbnail Images
stConfig.StandardImageURL = "/images/StandardImages"; // URL path of Standard Images

// added by bowden 7/23/2006. taken from b300.cfm
stConfig.folderpath_optimised = "#application.path.project#/www/images";
stConfig.folderpath_original = "#application.path.project#/www/images";
stConfig.folderpath_thumbnail = "#application.path.project#/www/images";
//end of add
// added by bowden 7/23/2006. taken from b310.cfm
stConfig.ThumbnailImageWidth = "80" ;
stConfig.ThumbnailImageHeight = "80" ;
stConfig.StandardImageWidth = "400" ;
stConfig.StandardImageHeight = "400" ;
//end of add
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