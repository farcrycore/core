<!--- @@description:

Updates dmFile objects with a default datePublished value<br/>
Deploys new overview tree config<br/>
Adds new 'alias' column to categories<br/>
Updates dmFile objects with a default documentDate value<br/>
Updates file config with archiveFiles attribute<br/>
Deploys new htmlArea config<br/>
Deploys new editOnPro v4.xx config<br/>
Converts existing Handpicked Rule instances<br/>
--->

<html>
<head>
<title>Farcry Core b220 Update - <cfoutput>#application.applicationname#</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="<cfoutput>#application.url.farcry#</cfoutput>/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">

<cfif isdefined("form.submit")>
	<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">
	<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">

	<!--- Add new 'fileSize' column to dmFile --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span>  Add new 'fileSize' column to dmFile..</cfoutput><cfflush>
	<cftry>
	<cfswitch expression="#application.dbtype#">
		<cfcase value="ora">
			<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmFile ADD
				fileSize VARCHAR2(50) NULL 
			</cfquery>
		</cfcase>
		<cfcase value="mysql">
			<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmFile ADD
				fileSize VARCHAR(50) NULL 
			</cfquery>
		</cfcase>
		<cfdefaultcase>
			<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmFile ADD
				fileSize VARCHAR(50) NULL 
			</cfquery>
		</cfdefaultcase>
	</cfswitch>
		<cfcatch>
			<cfoutput><br/>#cfcatch.detail#<br/></cfoutput>
			<cfflush>
		</cfcatch>
	</cftry>
	<cfoutput> done</p></cfoutput><cfflush>
	
	<!--- Add new 'fileType' column to dmFile --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span>  Add new 'fileType' column to dmFile..</cfoutput><cfflush>
	<cftry>
	<cfswitch expression="#application.dbtype#">
		<cfcase value="ora">
			<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmFile ADD
				fileType VARCHAR2(50) NULL 
			</cfquery>
		</cfcase>
		<cfcase value="mysql">
			<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmFile ADD
				fileType VARCHAR(50) NULL 
			</cfquery>
		</cfcase>
		<cfdefaultcase>
			<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmFile ADD
				fileType VARCHAR(50) NULL 
			</cfquery>
		</cfdefaultcase>
	</cfswitch>
		<cfcatch>
			<cfoutput><br/>#cfcatch.detail#<br/></cfoutput>
			<cfflush>
		</cfcatch>
	</cftry>
	<cfoutput> done</p></cfoutput><cfflush>
	
	<!--- Add new 'fileSubType' column to dmFile --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span>  Add new 'fileSubType' column to dmFile..</cfoutput><cfflush>
	<cftry>
	<cfswitch expression="#application.dbtype#">
		<cfcase value="ora">
			<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmFile ADD
				fileSubType VARCHAR2(50) NULL 
			</cfquery>
		</cfcase>
		<cfcase value="mysql">
			<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmFile ADD
				fileSubType VARCHAR(50) NULL 
			</cfquery>
		</cfcase>
		<cfdefaultcase>
			<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmFile ADD
				fileSubType VARCHAR(50) NULL 
			</cfquery>
		</cfdefaultcase>
	</cfswitch>
		<cfcatch>
			<cfoutput><br/>#cfcatch.detail#<br/></cfoutput>
			<cfflush>
		</cfcatch>
	</cftry>
	<cfoutput> done</p></cfoutput><cfflush>
	
	<!--- Add new 'fileExt' column to dmFile --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span>  Add new 'fileExt' column to dmFile..</cfoutput><cfflush>
	<cftry>
	<cfswitch expression="#application.dbtype#">
		<cfcase value="ora">
			<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmFile ADD
				fileExt VARCHAR2(50) NULL 
			</cfquery>
		</cfcase>
		<cfcase value="mysql">
			<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmFile ADD
				fileExt VARCHAR(50) NULL 
			</cfquery>
		</cfcase>
		<cfdefaultcase>
			<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmFile ADD
				fileExt VARCHAR(50) NULL 
			</cfquery>
		</cfdefaultcase>
	</cfswitch>
		<cfcatch>
			<cfoutput><br/>#cfcatch.detail#<br/></cfoutput>
			<cfflush>
		</cfcatch>
	</cftry>
	<cfoutput> done</p></cfoutput><cfflush>
	
	<!--- Add new 'documentDate' column to dmFile --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span>  Add new 'documentDate' column to dmFile..</cfoutput><cfflush>
	<cftry>
	<cfswitch expression="#application.dbtype#">
		<cfcase value="ora">
			<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmFile ADD
				documentDate date NULL 
			</cfquery>
		</cfcase>
		<cfcase value="mysql">
			<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmFile ADD
				documentDate datetime NULL 
			</cfquery>
		</cfcase>
		<cfdefaultcase>
			<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#dmFile ADD
				documentDate datetime NULL 
			</cfquery>
		</cfdefaultcase>
	</cfswitch>
		<cfcatch>
			<cfoutput><br/>#cfcatch.detail#<br/></cfoutput>
			<cfflush>
		</cfcatch>
	</cftry>
	<cfoutput> done</p></cfoutput><cfflush>
	
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating dmFile objects...</cfoutput><cfflush>
	
	<cfquery datasource="#application.dsn#" name="qFiles">
		select *
		from #application.dbowner#dmFile
	</cfquery>

	<cfloop query="qFiles">
		<cfquery datasource="#application.dsn#" name="qUpdate">
			UPDATE #application.dbowner#dmFile
			set documentDate = '#qFiles.dateTimeCreated#'
			where objectid = '#qFiles.objectid#'
		</cfquery>
	</cfloop>
			
	<cfoutput> done</p></cfoutput><cfflush>

	<!--- Adding tree overview config		 --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Deploying overview tree config...</cfoutput><cfflush>

	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultOverviewTree" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput> done</p></cfoutput><cfflush>
	
	<!--- Add new 'alias' column to categories --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span>  Add new 'alias' column to categories..</cfoutput><cfflush>
	<cftry>
	<cfswitch expression="#application.dbtype#">
		<cfcase value="ora">
			<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#categories ADD
				alias VARCHAR2(50) NULL 
			</cfquery>
		</cfcase>
		<cfcase value="mysql">
			<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#categories ADD
				alias VARCHAR(50) NULL 
			</cfquery>
		</cfcase>
		<cfdefaultcase>
			<cfquery name="update" datasource="#application.dsn#">
				ALTER TABLE #application.dbowner#categories ADD
				alias VARCHAR(50) NULL 
			</cfquery>
		</cfdefaultcase>
	</cfswitch>
		<cfcatch>
			<cfoutput><br/>#cfcatch.detail#<br/></cfoutput>
			<cfflush>
		</cfcatch>
	</cftry>
	<cfoutput> done</p></cfoutput><cfflush>

	<!--- Add archiveFile entry to file config --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating dmFile config...</cfoutput><cfflush>
	<cfset application.config.file.archiveFiles = "false">

	<cfwddx action="CFML2WDDX" input="#application.config.file#" output="wConfig">

	<cfquery datasource="#application.dsn#" name="qUpdate">
		UPDATE #application.dbowner#config
		set wConfig = '#wConfig#'
		where configName = 'file'
	</cfquery>

	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Config updated</p></cfoutput><cfflush>
	
	<!--- Adding htmlarea config		 --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Deploying htmlArea config...</cfoutput><cfflush>

	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultHTMLArea" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput> done</p></cfoutput><cfflush>
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Deploying editOnPro4.xx config  config...</cfoutput><cfflush>
	<!--- Add entry for EWebEditPro4 to Config ---><br><br>
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultEOPro4" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Updating Application Scope...<p></p></cfoutput><cfflush>
	<cfset error = 0>
	<cftry>
		<cfscript>
			//Load the new config into the application scope for the admin
			AConfig = createObject("component", "#application.packagepath#.farcry.config");
			"application.config.EOPro4" = AConfig.getConfig(configname='EOPro4');
		</cfscript>
		<cfcatch><cfset error=1><span class="frameMenuBullet">&raquo;</span> <cfdump var="#cfcatch#"><cfoutput><p></p></cfoutput></cfcatch>
	</cftry>	
	
	<cfif not error>
		<cfoutput><span class="frameMenuBullet">&raquo;</span> Application scope updated successfully.<p></p></cfoutput><cfflush>
	</cfif>
	
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Converting Handpicked Rule instances...</cfoutput><cfflush>
	
	<cfscript>
		sql = "select objectid,objectWDDX from #application.dbowner#ruleHandpicked";
		qRules = query(sql);
		writeOutput("Updating #qRules.recordcount# Handpicked Rules");
		flush();
		oHandpickedRule = createObject("component","#application.packagepath#.rules.ruleHandpicked");
		for(i=1;i lte qRules.recordcount;i=i+1){
			aObjectWDDX = oHandpickedRule.wddx2cfml(qRules.objectWDDX[i]);
			//dump(aObjectWDDX);
			//dump(qRules.objectid[i]);
			for(j=1;j lte arrayLen(aObjectWDDX);j=j+1){
				if(listlen(aObjectWDDX[j].typename,'.') gt 1){
					aObjectWDDX[j].typename = listlast(aObjectWDDX[j].typename,'.');	
				}
			}	
			//dump(aObjectWDDX);
			stProperties = structNew();
			stProperties.objectId = qRules.objectid[i];
			stProperties.objectWDDX = oHandpickedRule.cfml2wddx(aObjectWDDX);
			oHandpickedRule.setData(stProperties);
			writeOutput(".");
			flush();
		}
	</cfscript>
			
	<cfoutput> done</p></cfoutput><cfflush>

<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Updates dmFile objects with a default datePublished value</li>
		<li type="square">Deploys new overview tree config</li>
		<li type="square">Adds new 'alias' column to categories</li>		
		<li type="square">Updates file config with archiveFiles attribute</li>
		<li type="square">Deploys new htmlArea config</li>
		<li type="square">Converts existing Handpicked Rule instances</li>
	</ul>
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run b220 Update" name="submit">
	</form>

	</cfoutput>
</cfif>

</body>
</html>
