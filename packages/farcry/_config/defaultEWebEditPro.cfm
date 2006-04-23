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
	<cfquery datasource="#stArgs.dsn#" name="qDelete">
		delete from #application.dbowner#config
		where configname = '#stArgs.configName#'
	</cfquery>
	
	<cfquery datasource="#stArgs.dsn#" name="qUpdate">
		INSERT INTO #application.dbowner#config
		(configName, wConfig)
		VALUES
		('#stArgs.configName#', '#wConfig#')
	</cfquery>

	<cfset stStatus.message = "#stArgs.configName# created successfully">
	<cfcatch>
		<cfset stStatus.message = cfcatch.message>
		<cfset stStatus.detail = cfcatch.detail>
	</cfcatch>
</cftry>