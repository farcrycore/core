<cfset stStatus = StructNew()>
<cfset stConfig = StructNew()>
<cfset aTmp = ArrayNew(1)>

<cfscript>
stConfig.aIndices = ArrayNew(1);
ArrayAppend(stConfig.aIndices, "#application.applicationname#_dmHTML");
ArrayAppend(stConfig.aIndices, "#application.applicationname#_dmNews");
aTmp = ListToArray("body, teaser, title");
// dmHTML Indexed Properties<br>
stConfig.contenttype.dmHTML.aProps = aTmp;
// dmNews Indexed Properties
stConfig.contenttype.dmNews.aProps = aTmp;
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