<cfset stStatus = StructNew()>
<cfset stConfig = StructNew()>
<cfset aTmp = ArrayNew(1)>

<cfscript>
stConfig.imageSize = 102400; // bytes
stConfig.imageType = "image/pjpeg,image/gif,image/png,image/jpg,image/jpeg,image/x-png"; // extension
stConfig.imageWidth = 500; // pixels
stConfig.imageHeight = 500; // pixels
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