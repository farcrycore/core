<cfcomponent displayname="Configuration" hint="Manages configuration files for FarCry CMS.">

<cffunction name="deployConfig" returntype="struct">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
    <cfargument name="bDropTable" type="boolean" default="false" required="false">

	<cfset var stStatus = StructNew()>
	<cfset stStatus.msg = "Table deployed successfully">
	<cftry>
    <cfif arguments.bDropTable>
        <cfquery datasource="#arguments.dsn#" name="dropConfig">
        if exists (select * from sysobjects where name = 'config')
		DROP TABLE dbo.config

        -- return recordset to stop CF bombing out?!?
        select count(*) as blah from sysobjects
        </cfquery>
    </cfif>
	<cfquery datasource="#arguments.dsn#" name="createConfig">
	CREATE TABLE dbo.config
		(
	 	configName char(50) NOT NULL,
		wConfig ntext NULL
		) ON [PRIMARY]
		 TEXTIMAGE_ON [PRIMARY];

	ALTER TABLE dbo.config ADD CONSTRAINT
		PK_config PRIMARY KEY NONCLUSTERED 
		(
		configName
		) ON [PRIMARY];
	</cfquery>
	<cfcatch>
        <cfset stStatus.bSuccess = "false">
		<cfset stStatus.message = cfcatch.message>
		<cfset stStatus.detail = cfcatch.detail>
	</cfcatch>
	</cftry>
    <cfset stStatus.bSuccess = "true">
	<cfreturn stStatus>
</cffunction>

<cffunction name="list" returntype="query">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">

	<cfset var q = "">
	
	<cfquery datasource="#arguments.dsn#" name="q">
	SELECT configName FROM config
	</cfquery>

	<cfreturn q>
</cffunction>


<cffunction name="getConfig" returntype="struct">
	<cfargument name="configName" required="Yes" type="string">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
	<cfset var q = "">
	
	<cfquery datasource="#arguments.dsn#" name="q">
	SELECT wConfig FROM config
	WHERE configName = '#arguments.configName#'
	</cfquery>

	<cfwddx action="WDDX2CFML" input="#q.wConfig#" output="stConfig">
	<cfreturn stConfig>
</cffunction>

<cffunction name="setConfig" returntype="struct">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
	<cfargument name="configName" required="Yes" type="string">
	<cfargument name="stConfig" required="Yes" type="struct">
	<cfset var stStatus = StructNew()>
		
	<cfwddx action="CFML2WDDX" input="#arguments.stConfig#" output="wConfig">
	
	<cfquery datasource="#arguments.dsn#" name="qUpdate">
	UPDATE config
	SET
	wConfig = '#wConfig#'
	WHERE 
	configName = '#arguments.configName#'
	</cfquery>
	
	<cfset stStatus.msg = "#arguments.configName# updated successfully">
	<cfreturn stStatus>
</cffunction>

<cffunction name="createConfig">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
	<cfargument name="configName" required="Yes" type="string">
	<cfargument name="stConfig" required="Yes" type="struct">
	<cfset var stStatus = StructNew()>
	
	<cfwddx action="CFML2WDDX" input="#arguments.stConfig#" output="wConfig">
	
	<cfquery datasource="#arguments.dsn#" name="qUpdate">
	INSERT INTO config
	(configName, wConfig)
	VALUES
	('#arguments.configName#', '#wConfig#')
	</cfquery>

	<cfset stStatus.msg = "#arguments.configName# created successfully">
	<cfreturn stStatus>
</cffunction>

<cffunction name="defaultVerity">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
	<cfargument name="configName" required="No" type="string" default="verity">
	<cfset var stStatus = StructNew()>
	<cfset var stConfig = StructNew()>
	<cfset var aTmp = ArrayNew(1)>
	
	<cfscript>
	stConfig.aIndices = ArrayNew(1);
	ArrayAppend(stConfig.aIndices, "dmHTML");
	ArrayAppend(stConfig.aIndices, "dmNews");
	aTmp = ListToArray("body, teaser, title");
	// dmHTML Indexed Properties<br>
	stConfig.contenttype.dmHTML.aProps = aTmp;
	// dmNews Indexed Properties
	stConfig.contenttype.dmNews.aProps = aTmp;
	</cfscript>
	
	<cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">
	
	<cftry>
	<cfquery datasource="#arguments.dsn#" name="qUpdate">
	INSERT INTO config
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
	<cfreturn stStatus>
</cffunction>

<cffunction name="defaultImage">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
	<cfargument name="configName" required="No" type="string" default="image">
	<cfset var stStatus = StructNew()>
	<cfset var stConfig = StructNew()>
	<cfset var aTmp = ArrayNew(1)>
	
	<cfscript>
	stConfig.imageSize = 102400; // bytes
	stConfig.imageType = "gif, jpg, jpeg, png"; // extension
	stConfig.imageWidth = 500; // pixels
	stConfig.imageHeight = 500; // pixels
	</cfscript>
	
	<cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">
	
	<cftry>
	<cfquery datasource="#arguments.dsn#" name="qUpdate">
	INSERT INTO config
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
	<cfreturn stStatus>
</cffunction>

<cffunction name="defaultFile">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
	<cfargument name="configName" required="No" type="string" default="file">
	<cfset var stStatus = StructNew()>
	<cfset var stConfig = StructNew()>
	<cfset var aTmp = ArrayNew(1)>
	
	<cfscript>
	stConfig.fileSize = 1024000; // bytes
	stConfig.fileType = "doc, pdf"; // extension
	</cfscript>
	
	<cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">
	
	<cftry>
	<cfquery datasource="#arguments.dsn#" name="qUpdate">
	INSERT INTO config
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
	<cfreturn stStatus>
</cffunction>

</cfcomponent>
