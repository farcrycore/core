<!--- @@description:
Update Image Config<br />
Adds the SourceImage, StandardImage and ThumbnailImage entry to dmImage table<br />
Create SourceImages, thumbnailImages and StandardImages directories<br />
Update SourceImage, StandardImage and ThumbnailImage initial values<br />
Copy Files from Old Locations to New Locations
Add Typename Field to each array table.
Populate each new typename field.

--->
<cfoutput>
<html>
<head>
<title>Farcry Core 4.1 Update - #application.applicationname#</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">
</cfoutput>

<cfif isdefined("form.submit")>
	<cfset alterType = createObject("component","#application.packagepath#.farcry.alterType") />
	<cfset migrateresult = "" />


	<!--- CONFIG --->
	<cfif NOT alterType.isCFCDeployed(typename="farConfig")>
		<cfset alterType.deployCFC(typename="farConfig") />
	</cfif>
	
	<cfquery datasource="#application.dsn#">
		delete from #application.dbowner#farConfig
	</cfquery>
	
	<cfset oConfig = createobject("component","farcry.core.packages.types.farConfig") />

	<cfquery datasource="#application.dsn#" name="qConfig">
		select	configname
		from	#application.dbowner#config
	</cfquery>
	
	<cfloop query="qConfig">
		<cfset stConfig = oConfig.migrateConfig(configname) />
		<cfset migrateresult = migrateresult & "Config '#stConfig.configkey#' migrated<br/>" />
	</cfloop>
	
	<!--- Load config data --->
	<cfset structclear(application.config) />
	<cfloop list="#oConfig.getConfigKeys()#" index="configkey">
		<cfset application.config[configkey] = oConfig.getConfig(configkey) />
	</cfloop>

	<!---
		clean up caching: kill all shared scopes and force application initialisation
			- application
			- session
			- server.dmSec[application.applicationname]
	 --->
	<cfset application.init=false>
	<cfset session=structnew()>
	<cfset server.dmSec[application.applicationname] = StructNew()>
	<cfoutput>
		<p>#migrateresult#</p>
		<p><strong>All done.</strong> Return to <a href="#application.url.farcry#/index.cfm">FarCry Webtop</a>.</p>
	</cfoutput>
	<cfflush>
<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li>Deploys new security types</li>
		<li>Migrates current security data</li>
		<li>Migrates config data</li>
	</ul>
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run 4.1 Update" name="submit">
	</form>

	</cfoutput>
</cfif>

</body>
</html>
