<!--- @@description:
Adds the overviewHome property to dmProfile object<br />
Adds the fu property to dmNavigation object<br />
Adds the blLibrary and status property to dmFile object<br />
Adds the blLibrary and status property to dmImage object<br />
Adds the blLibrary and status property to dmFlash object<br />
Adds the ownedBy to all content types object<br />
Adds archive properties<br />
Adds contentReviewDaySpan properties to general Config<br />
Adds loginAttemptsAllowed properties to general Config<br />
Adds eventExpiry properties to general Config<br />
Adds categoryCacheTimeSpan properties to general Config<br />
Adds siteLogoPath properties to general Config<br />
Adds componentDocURL properties to general Config<br />
Adds reviewDate field to dmHTML<br />
Adds thumbnail image width and height<br />
Adds the source field to the dmnews table<br />
Adds versionID to dmNews,dmHTML,dmEvents<br />
Adds TinyMCE Rich Text Editor Config<br />
Adds suffix to ruleNews,ruleEvents<br />
--->
<cfoutput>
<html>
<head>
<title>Farcry Core 3.0.0 Update - #application.applicationname#</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">
</cfoutput>

<cfif isdefined("form.submit")>

	<cfset error = 0>
	<!--- Add overviewHome entry to dmProfile table --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating dmProfile table...</cfoutput><cfflush>
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmProfile ADD
					overviewHome VARCHAR2(50) NULL
				</cfquery>
			</cfcase>
			<cfcase value="mysql,mysql5">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmProfile ADD
					overviewHome VARCHAR(50) NULL
				</cfquery>
			</cfcase>
			<cfcase value="postgresql">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmProfile ADD
					overviewHome VARCHAR(50) NULL
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmProfile ADD
					overviewHome VARCHAR(50) NULL
				</cfquery>
			</cfdefaultcase>
		</cfswitch>

		<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
	</cftry>

	<!--- Add fu entry to dmNavigation table --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating dmNavigation table...</cfoutput><cfflush>
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmNavigation ADD
					fu VARCHAR2(255) NULL
				</cfquery>
			</cfcase>
			<cfcase value="mysql,mysql5">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmNavigation ADD
					fu VARCHAR(255) NULL
				</cfquery>
			</cfcase>
			<cfcase value="postgresql">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmNavigation ADD
					fu VARCHAR(255) NULL
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmNavigation ADD
					fu VARCHAR(255) NULL
				</cfquery>
			</cfdefaultcase>
		</cfswitch>

		<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
	</cftry>

	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>

	<!--- Add bLibrary and status entry to dmFile table --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating dmFile table...</cfoutput><cfflush>
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmFile ADD bLibrary INTEGER DEFAULT 0 NOT NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmFile ADD status VARCHAR2(255) default 'draft' NOT NULL
				</cfquery>
			</cfcase>
			<cfcase value="mysql,mysql5">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmFile ADD bLibrary INTEGER UNSIGNED NOT NULL DEFAULT 0
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmFile ADD status VARCHAR(255) NOT NULL default 'draft'
				</cfquery>
			</cfcase>
			<cfcase value="postgresql">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmFile ADD bLibrary INTEGER NOT NULL DEFAULT 0
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmFile ADD status VARCHAR(255) NOT NULL default 'draft'
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmFile ADD bLibrary INTEGER NOT NULL DEFAULT 0
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmFile ADD status VARCHAR(255) NOT NULL default 'draft'
				</cfquery>
			</cfdefaultcase>
		</cfswitch>

		<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
	</cftry>

	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>

	<!--- Add bLibrary and status entry to dmImage table --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating dmImage table...</cfoutput><cfflush>
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD bLibrary INTEGER DEFAULT 0 NOT NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD bAutoGenerateThumbnail INTEGER DEFAULT 0 NOT NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD status VARCHAR2(255) default 'draft' NOT NULL
				</cfquery>
			</cfcase>
			<cfcase value="mysql,mysql5">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD bAutoGenerateThumbnail INTEGER UNSIGNED NOT NULL DEFAULT 0
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD bLibrary INTEGER UNSIGNED NOT NULL DEFAULT 0
				</cfquery>

				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD status VARCHAR(255) NOT NULL default 'draft'
				</cfquery>
			</cfcase>
			<cfcase value="postgresql">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD bLibrary INTEGER NOT NULL DEFAULT 0
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD bAutoGenerateThumbnail INTEGER UNSIGNED NOT NULL DEFAULT 0
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD status VARCHAR(255) NOT NULL default 'draft'
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD bLibrary INTEGER NOT NULL DEFAULT 0
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD bAutoGenerateThumbnail INTEGER NOT NULL DEFAULT 0
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD status VARCHAR(255) NOT NULL default 'draft'
				</cfquery>
			</cfdefaultcase>
		</cfswitch>

		<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
	</cftry>

	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>

	<!--- Add bLibrary and status entry to dmFlash table --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating dmFlash table...</cfoutput><cfflush>
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmFlash ADD bLibrary INTEGER DEFAULT 0 NOT NULL
				</cfquery>
			</cfcase>
			<cfcase value="mysql,mysql5">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmFlash ADD bLibrary INTEGER UNSIGNED NOT NULL DEFAULT 0
				</cfquery>
			</cfcase>
			<cfcase value="postgresql">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmFlash ADD bLibrary INTEGER NOT NULL DEFAULT 0
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmFlash ADD bLibrary INTEGER NOT NULL DEFAULT 0
				</cfquery>
			</cfdefaultcase>
		</cfswitch>

		<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
	</cftry>
	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>



	<!--- Add ownedby property to all content types --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Adding OWNEDBY properties...</p><ul></cfoutput><cfflush>

	<cfloop item="tableName" collection="#application.types#">
		<cfoutput><li>Altering #tableName#</cfoutput><cfflush>
		<cftry>
			<cfswitch expression="#application.dbtype#">
				<cfcase value="ora">
					<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner##tableName# ADD ownedby VARCHAR2(255) NULL
					</cfquery>

					<cfquery name="update" datasource="#application.dsn#">
					UPDATE #application.dbowner##tableName# SET ownedby = createdBy WHERE ownedBy = '' OR ownedBy IS NULL
					</cfquery>
				</cfcase>
				<cfcase value="mysql,mysql5">
					<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner##tableName# ADD ownedby VARCHAR(255) NULL
					</cfquery>

					<cfquery name="update" datasource="#application.dsn#">
					UPDATE #application.dbowner##tableName# SET ownedby = createdBy WHERE ownedBy = '' OR ownedBy IS NULL
					</cfquery>
				</cfcase>
				<cfcase value="postgresql">
					<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner##tableName# ADD ownedby VARCHAR(255) NULL
					</cfquery>

					<cfquery name="update" datasource="#application.dsn#">
					UPDATE #application.dbowner##tableName# SET ownedby = createdBy WHERE ownedBy = '' OR ownedBy IS NULL
					</cfquery>
				</cfcase>
				<cfdefaultcase>
					<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner##tableName# ADD ownedby VARCHAR(255) NULL
					</cfquery>

					<cfquery name="update" datasource="#application.dsn#">
					UPDATE #application.dbowner##tableName# SET ownedby = createdBy WHERE ownedBy = '' OR ownedBy IS NULL
					</cfquery>
				</cfdefaultcase>
			</cfswitch>
			<cfcatch><cfoutput><br /><span class="frameMenuBullet">&raquo;</span> <span class="error">#cfcatch.detail#</span></cfoutput></cfcatch>
		</cftry>
		<cfoutput></li></cfoutput>
	</cfloop>

	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>

	<!--- add archive struct to the general web configurable attribute --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Adding general config properties...</cfoutput><cfflush>
	<cfquery name="qList" datasource="#application.dsn#">
	SELECT	wconfig
	FROM	#application.dbowner#config
	WHERE	configname = 'general'
	</cfquery>

	<cfwddx action="wddx2cfml" input="#qList.wconfig#" output="stConfig">
	<cfif NOT StructKeyExists(stConfig,"bDoArchive")>
		<cfset stConfig.bDoArchive = "False">
		<cfset stConfig.archiveDirectory = "#application.path.project#/archive/">
		<cfset stConfig.archiveWeburl = "#application.url.webroot#archive/">
	</cfif>

	<cfif NOT StructKeyExists(stConfig,"contentReviewDaySpan")>
		<cfset stConfig.contentReviewDaySpan = 90>
	</cfif>

	<cfif NOT StructKeyExists(stConfig,"loginAttemptsAllowed")>
		<cfset stConfig.loginAttemptsAllowed = 3>
		<cfset stConfig.loginAttemptsTimeOut = 10> <!--- minutes --->
	</cfif>

	<cfif NOT StructKeyExists(stConfig,"eventsExpiry")>
		<cfset stConfig.eventsExpiry = 14>
		<cfset stConfig.eventsExpiryType = "d">
	</cfif>

	<!--- add the cache timespan for cachetimespan --->
	<cfif NOT StructKeyExists(stConfig,"categoryCacheTimeSpan")>
		<cfset stConfig.categoryCacheTimeSpan = "0">
	</cfif>

	<!--- site logo --->
	<cfif NOT StructKeyExists(stConfig,"siteLogoPath")>
		<cfset stConfig.siteLogoPath = "">
	</cfif>

	<!--- component doc url --->
	<cfif NOT StructKeyExists(stConfig,"componentDocURL")>
		<cfset stConfig.componentDocURL = "/CFIDE/componentutils/componentdetail.cfm">
	</cfif>
	
	<cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">
	<cfquery name="qUpdate" datasource="#application.dsn#">
	UPDATE	#application.dbowner#config
	SET		wconfig = '#wConfig#'
	WHERE	configname = 'general'
	</cfquery>


	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>

	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Adding suffix column to ruleNews...</cfoutput><cfflush>
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#ruleNews ADD
					suffix VARCHAR2(255) NULL
				</cfquery>
			</cfcase>
			<cfcase value="mysql,mysql5">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#ruleNews ADD
					suffix VARCHAR(255) NULL
				</cfquery>
			</cfcase>
			<cfcase value="postgresql">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#ruleNews ADD
					suffix VARCHAR(255) NULL
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#ruleNews ADD
					suffix VARCHAR(255) NULL
				</cfquery>
			</cfdefaultcase>
		</cfswitch>

		<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
	</cftry>


	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>

	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Adding suffix column to ruleEvents...</cfoutput><cfflush>
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#ruleEvents ADD
					suffix VARCHAR2(255) NULL
				</cfquery>
			</cfcase>
			<cfcase value="mysql,mysql5">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#ruleEvents ADD
					suffix VARCHAR(255) NULL
				</cfquery>
			</cfcase>
			<cfcase value="postgresql">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#ruleEvents ADD
					suffix VARCHAR(255) NULL
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#ruleEvents ADD
					suffix VARCHAR(255) NULL
				</cfquery>
			</cfdefaultcase>
		</cfswitch>

		<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
	</cftry>


	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>



	<!--- add the new text rule --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Creating new text rule table...</cfoutput><cfflush>
	<cftry>
	<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<!--- bowden1 --->
				<cfquery name="qCreateTable" datasource="#application.dsn#">
					CREATE TABLE #application.dbowner#ruleText (
						label varchar(255) default NULL,
						 objectid varchar(50) default NULL,
						 text varchar(255) default NULL,
						 title varchar(255) default NULL
						)
				</cfquery>
				<!--- bowden1 - end --->
			</cfcase>
			<cfcase value="postgresql">
				<cfquery name="qCreateTable" datasource="#application.dsn#">
					CREATE TABLE #application.dbowner#ruleText (
						label varchar(255) default NULL,
						objectid varchar(50) default NULL,
						text varchar(255) default NULL,
						title varchar(255) default NULL
					)
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="qCreateTable" datasource="#application.dsn#">
					CREATE TABLE #application.dbowner#ruleText (
						label varchar(255) default NULL,
						objectid varchar(50) default NULL,
						text varchar(255) default NULL,
						title varchar(255) default NULL
					)
				</cfquery>
			</cfdefaultcase>
		</cfswitch>
		<cfcatch><cfset error=1><cfoutput><br /><span class="frameMenuBullet">&raquo;</span> <span class="error">#cfcatch.detail#</span></cfoutput></cfcatch>
	</cftry>
	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>

	<!--- create new aRelatedIDs table --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Creating new aRelatedIDs table...</cfoutput><cfflush>
	<cfset lTypeName = StructKeyList(application.types)>
	<cfloop index="typeName" list="#lTypeName#">
		<cfif StructKeyExists(application.types[typeName].stProps,"aRelatedIDs")>
	<cfoutput><li>Creating #typeName#_aRelatedIDs</cfoutput><cfflush>
			<cftry>
				<cfswitch expression="#application.dbtype#">
					<cfcase value="ora">
						<!--- bowden1 --->
						<cfquery name="qCreateTable" datasource="#application.dsn#">
						CREATE TABLE #application.dbowner##typeName#_aRelatedIDs (
							data varchar(255) default NULL,
						  	objectid varchar(50) default NULL,
						  	seq decimal(10,0) default NULL
							)
						</cfquery>
						<!--- bowden1 - end --->
					</cfcase>
					<cfcase value="postgresql">
						<cfquery name="qCreateTable" datasource="#application.dsn#">
						CREATE TABLE #application.dbowner##typeName#_aRelatedIDs (
							data varchar(255) default NULL,
						  	objectid varchar(50) default NULL,
						  	seq decimal(10,0) default NULL
							)
						</cfquery>
					</cfcase>
					<cfdefaultcase>
						<cfquery name="qCreateTable" datasource="#application.dsn#">
						CREATE TABLE #application.dbowner##typeName#_aRelatedIDs (
							data varchar(255) default NULL,
						  	objectid varchar(50) default NULL,
						  	seq decimal(10,0) default NULL
							)
						</cfquery>
					</cfdefaultcase>
				</cfswitch>
				<cfcatch><cfoutput><br /><span class="frameMenuBullet">&raquo;</span> <span class="error">#cfcatch.detail#</span></cfoutput></cfcatch>
			</cftry>
		</cfif>
	</cfloop>

	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>

	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Adding new bAllowOverwrite to config ...</cfoutput><cfflush>
	<!--- add the bAllowOverwrite on the config --->
	<cfquery name="qList" datasource="#application.dsn#">
	SELECT	wconfig
	FROM	#application.dbowner#config
	WHERE	configname = 'file'
	</cfquery>
	<cfwddx action="wddx2cfml" input="#qList.wconfig#" output="stConfig">
	<cfset stConfig.bAllowOverwrite = "true">
	<cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">
	<cfquery name="qUpdate" datasource="#application.dsn#">
	UPDATE	#application.dbowner#config
	SET		wconfig = '#wConfig#'
	WHERE	configname = 'file'
	</cfquery>

	<cfquery name="qList" datasource="#application.dsn#">
	SELECT	wconfig
	FROM	#application.dbowner#config
	WHERE	configname = 'image'
	</cfquery>
	<cfwddx action="wddx2cfml" input="#qList.wconfig#" output="stConfig">
	<cfset stConfig.bAllowOverwrite = "true">
	<cfset stConfig.archivefiles = "false">
	<cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">
	<cfquery name="qUpdate" datasource="#application.dsn#">
	UPDATE	#application.dbowner#config
	SET		wconfig = '#wConfig#'
	WHERE	configname = 'image'
	</cfquery>

	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>

	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Adding new image thumbnail width and height to config ...</cfoutput><cfflush>
	<cftry>
		<cfquery name="qList" datasource="#application.dsn#">
		SELECT	wconfig
		FROM	#application.dbowner#config
		WHERE	configname = 'image'
		</cfquery>

		<cfwddx action="wddx2cfml" input="#qList.wconfig#" output="stConfig">

		<cfset stConfig.thumbnailWidth = 80>
		<cfset stConfig.thumbnailHeight = 80>

		<cfset stConfig.folderpath_optimised = application.defaultImagePath>
		<cfset stConfig.folderpath_original = application.defaultImagePath>
		<cfset stConfig.folderpath_thumbnail = application.defaultImagePath>
				
		<cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">

		<cfquery name="qUpdate" datasource="#application.dsn#">
		UPDATE	#application.dbowner#config
		SET		wconfig = '#wConfig#'
		WHERE	configname = 'image'
		</cfquery>

		<cfoutput><strong>done</strong></p></cfoutput><cfflush>

		<cfcatch><cfoutput><br /><span class="frameMenuBullet">&raquo;</span> <span class="error">#cfcatch.detail#</span></cfoutput></cfcatch>
	</cftry>

	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Adding new bAllowDuplicateNavAlias attribute to overviewTree config ...</cfoutput><cfflush>
	<cftry>
		<cfquery name="qList" datasource="#application.dsn#">
		SELECT	wconfig
		FROM	#application.dbowner#config
		WHERE	configname = 'overviewTree'
		</cfquery>

		<cfwddx action="wddx2cfml" input="#qList.wconfig#" output="stConfig">

		<cfset stConfig.bAllowDuplicateNavAlias = "Yes">
		<cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">

		<cfquery name="qUpdate" datasource="#application.dsn#">
		UPDATE	#application.dbowner#config
		SET		wconfig = '#wConfig#'
		WHERE	configname = 'overviewTree'
		</cfquery>

		<cfoutput><strong>done</strong></p></cfoutput><cfflush>

		<cfcatch><cfoutput><br /><span class="frameMenuBullet">&raquo;</span> <span class="error">#cfcatch.detail#</span></cfoutput></cfcatch>
	</cftry>


	<!--- Add source field to the dmNews table --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Adding source properties to dmNews...</p><ul></cfoutput><cfflush>

	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmNews ADD source VARCHAR2(255) NULL
				</cfquery>
			</cfcase>
			<cfcase value="mysql,mysql5">
				<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmNews ADD source VARCHAR(255) NULL
				</cfquery>
			</cfcase>
			<cfcase value="postgresql">
				<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmNews ADD source VARCHAR(255) NULL
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmNews ADD source VARCHAR(255) NULL
				</cfquery>
			</cfdefaultcase>
		</cfswitch>
		<cfcatch><cfoutput><br /><span class="frameMenuBullet">&raquo;</span> <span class="error">#cfcatch.detail#</span></cfoutput></cfcatch>
	</cftry>

	<!--- Add new 'reviewDate' column to dmFile --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span>  Add new 'reviewDate' column to dmdmHTML..</cfoutput><cfflush>
	<cftry>
		<cfset defaultdate = CreateODBCDate(CreateDate(2050,month(Now()),day(Now())))>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmHTML ADD reviewDate date NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
				UPDATE #application.dbowner#dmHTML SET reviewDate = #defaultdate# WHERE reviewDate IS NULL
				</cfquery>
			</cfcase>
			<cfcase value="mysql,mysql5">
				<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmHTML ADD reviewDate datetime NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
				UPDATE #application.dbowner#dmHTML SET reviewDate = #defaultdate# WHERE reviewDate IS NULL
				</cfquery>
			</cfcase>
			<cfcase value="postgresql">
				<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmHTML ADD reviewDate timestamp NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
				UPDATE #application.dbowner#dmHTML SET reviewDate = #defaultdate# WHERE reviewDate IS NULL
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmHTML ADD reviewDate datetime NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
				UPDATE #application.dbowner#dmHTML SET reviewDate = #defaultdate# WHERE reviewDate IS NULL
				</cfquery>
			</cfdefaultcase>
		</cfswitch>
		<cfcatch><cfoutput><br /><span class="frameMenuBullet">&raquo;</span> <span class="error">#cfcatch.detail#</span></cfoutput></cfcatch>
	</cftry>

	<!--- Update dmFile FileSize to 0 if null or '' --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Update dmFlash flashWidth and flashHeight to 0 ...</cfoutput><cfflush>
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="odbc">
		<cfquery name="qUpdate" datasource="#application.dsn#">
		ALTER TABLE #application.dbowner#dmFlash  ADD CONSTRAINT DF_dmFlash_flashWidth DEFAULT 0 FOR flashWidth
		</cfquery>

		<cfquery name="qUpdate" datasource="#application.dsn#">
		ALTER TABLE #application.dbowner#dmFlash  ADD CONSTRAINT DF_dmFlash_flashHeight DEFAULT 0 FOR flashHeight
		</cfquery>
			</cfcase>

			<cfdefaultcase>
		<cfquery name="qUpdate" datasource="#application.dsn#">
		ALTER TABLE #application.dbowner#dmFlash ALTER COLUMN flashWidth SET DEFAULT 0
		</cfquery>

		<cfquery name="qUpdate" datasource="#application.dsn#">
		ALTER TABLE #application.dbowner#dmFlash ALTER COLUMN flashHeight SET DEFAULT 0
		</cfquery>
			</cfdefaultcase>

		</cfswitch>
		<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
	</cftry>

	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>

	<!--- adding versionid to dmNews,dmHTML,dmEvents --->

	<cfset lTypesWithVersions = "dmNews,dmHTML,dmEvent">
	<cfloop index="tableName" list="#lTypesWithVersions#">
		<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating #tableName# ...</cfoutput><cfflush>
		<cftry>
			<cfswitch expression="#application.dbtype#">
				<cfcase value="ora">
					<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner##tableName# ADD versionID VARCHAR2(255) DEFAULT '' NOT NULL
					</cfquery>
				</cfcase>
				<cfcase value="mysql,mysql5">
					<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner##tableName# ADD versionID VARCHAR(255) NOT NULL DEFAULT ''
					</cfquery>
				</cfcase>
				<cfcase value="postgresql">
					<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner##tableName# ADD versionID VARCHAR(255) NOT NULL DEFAULT ''
					</cfquery>
				</cfcase>
				<cfdefaultcase>
					<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner##tableName# ADD versionID VARCHAR(255) NOT NULL DEFAULT ''
					</cfquery>
				</cfdefaultcase>
			</cfswitch>
			<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
		</cftry>
	</cfloop>

	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>

	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating Container ...</cfoutput><cfflush>
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#container ADD displayMethod VARCHAR2(255) NULL
				</cfquery>
			</cfcase>
			<cfcase value="mysql,mysql5">
				<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#container ADD displayMethod VARCHAR(255) NULL
				</cfquery>
			</cfcase>
			<cfcase value="postgresql">
				<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#container ADD displayMethod VARCHAR(255) NULL
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#container ADD displayMethod VARCHAR(255) NULL
				</cfquery>
			</cfdefaultcase>
		</cfswitch>
		<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
	</cftry>

	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>

	<!--- Adding TinyMCE config		 --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Deploying TinyMCE Rich Text Editor config...</cfoutput><cfflush>

	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultTinyMCE" returnvariable="stStatus">
	</cfinvoke>
	
	<!--- FU updates --->
	<cftry>
	<cfinclude template="fu.cfm">
	<cfcatch>
		<cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput>
	</cfcatch>
	</cftry>

	<cfoutput> done</p></cfoutput><cfflush>

	<cfoutput></ul></cfoutput>
	<!---
		clean up caching: kill all shared scopes and force application initialisation
			- application
			- session
			- server.dmSec[application.applicationname]
	 --->
	<cfset application.init=false>
	<cfset session=structnew()>
	<cfset server.dmSec[application.applicationname] = StructNew()>
	<cfoutput><p><strong>All done.</strong> Return to <a href="#application.url.farcry#/index.cfm">FarCry Webtop</a>.</p></cfoutput>
	<cfflush>
<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Adds the overviewHome property to dmProfile object</li>
		<li type="square">Adds the fu property to dmNavigation object</li>
		<li type="square">Adds the blLibrary and status property to dmFile object</li>
		<li type="square">Adds the blLibrary and status property to dmImage object</li>
		<li type="square">Adds the blLibrary and status property to dmFlash object</li>
		<li type="square">Adds the ownedBy to all content types object</li>
		<li type="square">Adds archive properties</li>
		<li type="square">Adds contentReviewDaySpan properties to general Config</li>
		<li type="square">Adds loginAttemptsAllowed properties to general Config</li>
		<li type="square">Adds eventExpiry properties to general Config</li>
		<li type="square">Adds categoryCacheTimeSpan properties to general Config</li>
		<li type="square">Adds siteLogoPath to general Config</li>
		<li type="square">Adds componentDocURL properties to general Config</li>
		<li type="square">Adds reviewDate field to dmHTML</li>
		<li type="square">Adds thumbnail image width and height</li>
		<li type="square">Adds the source field to the dmNews table</li>
		<li type="square">Adds versionID to dmNews,dmHTML,dmEvents</li>
		<li type="square">Adds TinyMCE Rich Text Editor Config</li>
		<li type="square">Adds suffix to ruleNews,ruleEvents</li>
	</ul>
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run 3.0.0 Update" name="submit">
	</form>

	</cfoutput>
</cfif>

</body>
</html>
