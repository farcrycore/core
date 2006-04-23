<cfset stStatus = StructNew()>
<cfset stConfig = StructNew()>
<cfset aTmp = ArrayNew(1)>

<cfscript>
stConfig.fileSize = 1024000; // bytes
stConfig.fileType = "application/msword,application/pdf,application/vnd.ms-excel"; // extension
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