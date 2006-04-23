<cfcomponent displayname="Configuration" hint="Manages configuration files for FarCry CMS.">

<cffunction name="deployConfig" returntype="struct">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
    <cfargument name="bDropTable" type="boolean" default="false" required="false">

	
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_config/deployConfig.cfm">
	
	<cfreturn stStatus>
</cffunction>

<cffunction name="list" returntype="query">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">

	<cfset var q = "">
	
	<cfquery datasource="#arguments.dsn#" name="q">
		SELECT configName FROM #application.dbowner#config
	</cfquery>

	<cfreturn q>
</cffunction>


<cffunction name="getConfig" returntype="struct">
	<cfargument name="configName" required="Yes" type="string">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
	<cfset var q = "">
		
	<cfquery datasource="#arguments.dsn#" name="q">
		SELECT wConfig FROM #application.dbowner#config
		WHERE upper(configName) = '#ucase(arguments.configName)#'
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
		UPDATE #application.dbowner#config
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
	INSERT INTO #application.dbowner#config
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
	
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_config/defaultVerity.cfm">
	
	<cfreturn stStatus>
</cffunction>

<cffunction name="defaultPlugins">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
	<cfargument name="configName" required="No" type="string" default="plugins">
	
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_config/defaultPlugins.cfm">
	
	<cfreturn stStatus>
</cffunction>

<cffunction name="defaultImage">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
	<cfargument name="configName" required="No" type="string" default="image">
	
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_config/defaultImage.cfm">
	
	<cfreturn stStatus>
</cffunction>

<cffunction name="defaultFile">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
	<cfargument name="configName" required="No" type="string" default="file">
	
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_config/defaultFile.cfm">
	
	<cfreturn stStatus>
</cffunction>

<cffunction name="defaultSoEditorPro">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
	<cfargument name="configName" required="No" type="string" default="soEditorPro">
	
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_config/defaultSoEditorPro.cfm">
	
	<cfreturn stStatus>
</cffunction>

<cffunction name="defaultSoEditor">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
	<cfargument name="configName" required="No" type="string" default="soEditor">
	
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_config/defaultSoEditor.cfm">
	
	<cfreturn stStatus>
</cffunction>

<cffunction name="defaultGeneral">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
	<cfargument name="configName" required="No" type="string" default="general">
	
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_config/defaultGeneral.cfm">
	
	<cfreturn stStatus>
</cffunction>

<cffunction name="defaultEWebEditPro">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
	<cfargument name="configName" required="No" type="string" default="eWebEditPro">
	
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_config/defaultEWebEditPro.cfm">
	
	<cfreturn stStatus>
</cffunction>

<cffunction name="defaultFU">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
	<cfargument name="configName" required="No" type="string" default="FUSettings">
	
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_config/defaultFU.cfm">
	
	<cfreturn stStatus>
</cffunction>

</cfcomponent>
