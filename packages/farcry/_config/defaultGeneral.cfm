<cfset stStatus = StructNew()>
<cfset stConfig = StructNew()>
<cfset aTmp = ArrayNew(1)>

<cfscript>
stConfig.adminEmail = "brendan@daemon.com.au"; 
stConfig.newsExpiry = "14";
stConfig.newsExpiryType = "d";
stConfig.sessionTimeOut = "60";
stConfig.dmFilesSearchable = "Yes";
stConfig.showForgotPassword = "Yes";
stConfig.logStats = "Yes";
stConfig.richTextEditor = "soEditor";
stConfig.fileDownloadDirectLink = "false";
stConfig.exportPath = "www/xml";
stConfig.siteTitle = "farcry";
stConfig.siteTagLine = "tell it to someone who cares";
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