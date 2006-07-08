<!--- @@description:
Added file insert html into body config item <br />
Added image insert html into body config item <br />
Added image/file tinymce callback <br />
Added jTidy Plugin config <br />
Added file Flash movie path config <br />
Added dmFacts change to now use dmImage <br  />
Updates FCKEditor config<br />
--->
<cfoutput>
<html>
<head>
<title>Farcry Core 3.0.1 Update - #application.applicationname#</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">
</cfoutput>

<cfif isdefined("form.submit")>
    <cfset error = 0>
    <!--- Added file insert html into body config item --->
    <cfoutput><p><span class="frameMenuBullet">&raquo;</span> Added file insert html into body config item...</cfoutput><cfflush>
    <cfquery name="qList" datasource="#application.dsn#">
    SELECT  wconfig
    FROM    #application.dbowner#config
    WHERE   configname = 'file'
    </cfquery>

    <cfwddx action="wddx2cfml" input="#qList.wconfig#" output="stConfig">
    <cfset stConfig.insertHTML = "*filetitle*">

    <cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">
    <cfquery name="qUpdate" datasource="#application.dsn#">
    UPDATE  #application.dbowner#config
    SET     wconfig = '#wConfig#'
    WHERE   configname = 'file'
    </cfquery>
    <cfoutput>COMPLETE</p></cfoutput><cfflush>

    <!--- Added image insert html into body config item --->
    <cfoutput><p><span class="frameMenuBullet">&raquo;</span> Added image insert html into body config item...</cfoutput><cfflush>
    <cfquery name="qList" datasource="#application.dsn#">
    SELECT  wconfig
    FROM    #application.dbowner#config
    WHERE   configname = 'image'
    </cfquery>

    <cfwddx action="wddx2cfml" input="#qList.wconfig#" output="stConfig">
    <cfset stConfig.insertHTML = "<a href='*imagefile*' target='_blank'><img src='*thumbnail*' border=0 alt='*alt*'></a>">

    <cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">
    <cfquery name="qUpdate" datasource="#application.dsn#">
    UPDATE  #application.dbowner#config
    SET     wconfig = '#wConfig#'
    WHERE   configname = 'image'
    </cfquery>
    <cfoutput>COMPLETE</p></cfoutput><cfflush>

    <!--- Added image/file tinymce callback --->
    <cfoutput><p><span class="frameMenuBullet">&raquo;</span> Added image/file tinymce callback...</cfoutput><cfflush>
    <cfquery name="qList" datasource="#application.dsn#">
    SELECT  wconfig
    FROM    #application.dbowner#config
    WHERE   upper(configname) = 'TINYMCE'
    </cfquery>

    <cfwddx action="wddx2cfml" input="#qList.wconfig#" output="stConfig">
    <cfset stConfig.insertimage_callback = "showWindowdmImage">
    <cfset stConfig.file_browser_callback = "showWindowdmFile">

    <cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">

    <!--- bowden1. changed to use cfqueryparam and clob for ora --->
    <cfswitch expression="#application.dbtype#">
	<cfcase value="ora">
	   <cfquery datasource="#application.dsn#" name="qUpdate">
		UPDATE  #application.dbowner#config
			SET     wconfig = <cfqueryparam value='#wConfig#'  cfsqltype="cf_sql_clob" /> 
		    	WHERE   upper(configname) = 'TINYMCE'
	   </cfquery>
	</cfcase>
	<cfdefaultcase>
    <cfquery name="qUpdate" datasource="#application.dsn#">
    UPDATE  #application.dbowner#config
    SET     wconfig = '#wConfig#'
    WHERE   upper(configname) = 'TINYMCE'
    </cfquery>
	</cfdefaultcase>
    </cfswitch>
    <!--- end of change bowden1 --->

    <cfoutput>COMPLETE</p></cfoutput><cfflush>


    <!--- Added jTidy Plugin config --->
    <cfoutput><p><span class="frameMenuBullet">&raquo;</span> Added jTidy plugin config...</cfoutput><cfflush>
    <cfquery name="qList" datasource="#application.dsn#">
    SELECT  wconfig
    FROM    #application.dbowner#config
    WHERE   configname = 'plugins'
    </cfquery>

    <cfwddx action="wddx2cfml" input="#qList.wconfig#" output="stConfig">
    <cfset stConfig.jtidy = "no">

    <cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">
    <cfquery name="qUpdate" datasource="#application.dsn#">
    UPDATE  #application.dbowner#config
    SET     wconfig = '#wConfig#'
    WHERE   configname = 'plugins'
    </cfquery>
    <cfoutput>COMPLETE</p></cfoutput><cfflush>

    <!--- Added file/Flash path config item --->
    <cfoutput>
    <p><span class="frameMenuBullet">&raquo;</span> Added file Flash movie path config...</cfoutput>
    <cfflush>
    <cfquery name="qList" datasource="#application.dsn#">
    SELECT  wconfig
    FROM    #application.dbowner#config
    WHERE   configname = 'file'
    </cfquery>

    <cfwddx action="wddx2cfml" input="#qList.wconfig#" output="stConfig">
    <cfset stConfig.folderpath_flash = application.path.defaultFilePath>

    <cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">
    <cfquery name="qUpdate" datasource="#application.dsn#">
    UPDATE  #application.dbowner#config
    SET     wconfig = '#wConfig#'
    WHERE   configname = 'file'
    </cfquery>
    <cfoutput>COMPLETE</p></cfoutput><cfflush>

    <!--- Added dmFacts change to now use dmImage --->
    <cfset error = 0>
    <cfoutput>
    <p><span class="frameMenuBullet">&raquo;</span> Added dmFacts change to now use dmImage...
    <br />
    <li>Adding imageID property to dmFacts...</cfoutput>
    <cfflush>
    <cftry>
        <cfif application.dbtype eq "ora">
            <cfquery name="update" datasource="#application.dsn#">
            ALTER TABLE #application.dbowner#dmFacts ADD imageID VARCHAR2(255) NULL
            </cfquery>
        <cfelse>
            <cfquery name="update" datasource="#application.dsn#">
            ALTER TABLE #application.dbowner#dmFacts ADD imageID VARCHAR(255) NULL
            </cfquery>
        </cfif>
    <cfcatch>
        <cfset error = 1>
        <cfoutput>
        <br />
        <span class="frameMenuBullet">&raquo;</span> <span class="error">#cfcatch.detail#</span>
        </cfoutput>
    </cfcatch>
    </cftry>
    <cfoutput></li></cfoutput>
    <cfif NOT error>
        <cfquery name="qFacts" datasource="#application.dsn#">
        SELECT * FROM dmFacts WHERE image IS NOT NULL
        </cfquery>
        <cfloop query="qFacts">
            <cfif fileExists("#application.path.defaultImagePath#\#qFacts.image#")>
                <cftry>
                    <cfif application.path.defaultImagePath neq application.config.image.folderpath_original>
                        <cffile action="COPY" source="#application.path.defaultImagePath#\#qFacts.image#" destination="#application.config.image.folderpath_original#">
                        <cffile action="COPY" source="#application.path.defaultImagePath#\#qFacts.image#" destination="#application.config.image.folderpath_thumbnail#">
                    </cfif>
                <cfcatch>
                    <cfset error = 1>
                    <cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput>
                </cfcatch>
                </cftry>
            </cfif>
            <cfscript>
            stImage = structNew();
            stImage.objectID = createUUID();
            stImage.label = "#qFacts.title# dmFacts image";
            stImage.title = stImage.label;
            stImage.alt = qFacts.title;
            stImage.originalImagePath = application.config.image.folderpath_original;
            stImage.imageFile = qFacts.image;
            stImage.thumbnailImagePath = application.config.image.folderpath_thumbnail;
            stImage.thumbnail = qFacts.image;
            stImage.ownedBy = qFacts.ownedBy;
            stImage.bAutoGenerateThumbnail = 0;
            stImage.bLibrary = 1;
            stImage.createdBy = qFacts.createdBy;
            stImage.lastUpdatedBy = qFacts.lastUpdatedBy;
            stImage.datetimeCreated = qFacts.datetimeCreated;
            stImage.datetimeLastUpdated = now();
            stImage.locked = 0;
            stImage.lockedBy = "";
            stImage.status = "approved";
            o_dmImage = createObject("component", "#application.packagepath#.types.dmImage");
            stResult = o_dmImage.createData(dsn=application.dsn, stProperties=stImage, bAudit=false, user=qFacts.createdBy);
            </cfscript>
            <cfif stResult.bSuccess>
                <cfquery name="uFacts" datasource="#application.dsn#">
                UPDATE dmFacts
                SET imageID = '#stImage.objectID#'
                WHERE objectID = '#qFacts.objectID#'
                </cfquery>
                <cfif application.path.defaultImagePath neq application.config.image.folderpath_original>
                    <cffile action="DELETE" file="#application.path.defaultImagePath#\#qFacts.image#">
                </cfif>
            </cfif>
        </cfloop>
    </cfif>
    <cfif NOT error>
        <cftry>
            <cfoutput>
            <li>Removing image property from dmFacts...</cfoutput>
            <cfflush>
            <cfquery name="update" datasource="#application.dsn#">
            ALTER TABLE #application.dbowner#dmFacts DROP COLUMN image
            </cfquery>
            <cfoutput></li>
            <p>COMPLETE</p></cfoutput>
            <cfflush>
        <cfcatch>
            <cfset error = 1>
            <cfoutput>
            <br />
            <span class="frameMenuBullet">&raquo;</span> <span class="error">#cfcatch.detail#</span>
            </cfoutput>
        </cfcatch>
        </cftry>
    </cfif>

    <!--- Added lExcludeNavAlias and lExcludeObjectID to Friendly url setting --->
    <cfoutput><p><span class="frameMenuBullet">&raquo;</span> Added file insert html into body config item...</cfoutput><cfflush>
    <cfquery name="qList" datasource="#application.dsn#">
    SELECT  wconfig
    FROM    #application.dbowner#config
    WHERE   configname = 'FUSettings'
    </cfquery>

    <cfwddx action="wddx2cfml" input="#qList.wconfig#" output="stConfig">
    <cfset stConfig.lExcludeNavAlias = "">
    <cfset stConfig.lExcludeObjectIDs = "">
	
    <cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">
    <cfquery name="qUpdate" datasource="#application.dsn#">
    UPDATE  #application.dbowner#config
    SET     wconfig = '#wConfig#'
    WHERE   configname = 'FUSettings'
    </cfquery>
    <cfoutput>COMPLETE</p></cfoutput><cfflush>
	
    <!--- //
	We don't want to overwrite any existing FCKEditor config values so...
	Check for the existance of the FCKEditor config. If the
	config exists then only add the updates. Else deploy the
	entire config using the FCK config component in farcry/packages/config
	 //--->
    <cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating FCKEditor config...</cfoutput><cfflush>
    <cfquery name="qList" datasource="#application.dsn#">
    SELECT  wconfig
    FROM    #application.dbowner#config
    WHERE   configname = 'FCKEditor'
    </cfquery>
	
	<cfif qList.recordcount>
	    <cfwddx action="wddx2cfml" input="#qList.wconfig#" output="stConfig">
	    <cfset stConfig.skin = "default">
	    <cfset stConfig.customConfigurationsPath = "/js/customfckconfig.js">
	
	    <cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">
	    <cfquery name="qUpdate" datasource="#application.dsn#">
		    UPDATE  #application.dbowner#config
		    SET     wconfig = '#wConfig#'
		    WHERE   configname = 'FCKEditor'
	    </cfquery>
	<cfelse>
		<cfinvoke component="#application.packagepath#.farcry.config" method="defaultFCKEditor" returnvariable="stStatus"></cfinvoke>
	</cfif>
    <cfoutput>COMPLETE</p></cfoutput><cfflush>

    <cfoutput><p><span class="frameMenuBullet">&raquo;</span> Adding FCKEditor Custom Configurations File...</cfoutput><cfflush>
	
	<cfset jsDirectoryPath = "#application.path.project#/www/js/" />
	<cfset customFCKConfigFilePath = "#jsDirectoryPath#customfckconfig.js" />
	
	<cfif NOT directoryExists(jsDirectoryPath)>
		<cfdirectory action="create" directory="#jsDirectoryPath#" />
	</cfif>
	
	<cfif NOT fileExists(customFCKConfigFilePath)>
		<cfset fckCustomConfigFileContent = "
/*
FCKEditor Custom Configurations File
=========================================================
Use this file to override the default FCKEditor configurations.
Information about the FCKEditor Custom Config can be found on the 
FCKEditor Wiki: 

http://wiki.fckeditor.net/Developer%27s_Guide/Configuration/Configurations_File

!!IF YOU DELETE OR MOVE THIS FILE YOU MUST UPDATE THE FCKEDITOR
CONFIG IN FARCRY/ADMIN/CONFIG_FILES
=========================================================
*/
		
		" />
		
		<cffile action="write" file="#customFCKConfigFilePath#" output="#fckCustomConfigFileContent#">
	</cfif>
	
    <cfoutput>COMPLETE</p></cfoutput><cfflush>
	
<cfelse>
    <cfoutput>
    <p>
    <strong>This script :</strong>
    <ul>
        <li>Added file insert html config</li>
        <li>Added image insert html config</li>
        <li>Added image/file tinymce callback</li>
        <li>Added jTidy plugin config</li>
        <li>Added file Flash movie path config</li>
        <li>Added dmFacts change to now use dmImage</li>
        <li>Added lExcludeNavAlias and lExcludeObjectID to Friendly url setting</li>
		<li>Updated FCKEditor config</li>
    </ul>
    </p>
    <form action="" method="post">
        <input type="hidden" name="dummy" value="1">
        <input type="submit" value="Run 3.0.1 Update" name="submit">
    </form>
    </cfoutput>
</cfif>

</body>
</html>
