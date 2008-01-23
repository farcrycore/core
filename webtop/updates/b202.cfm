<cfsetting requesttimeout="120">

<!--- @@description:
Add new config item - VERITYSTORAGEPATH - for handling shared file servers<br>
Add new config for Site Objects edit-on Pro 3.x rich text editor<br>
Copys live HTML containers to underlying draft objects<br>
--->

<html>
<head>
<title>Farcry Core b201 Update - <cfoutput>#application.applicationname#</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="<cfoutput>#application.url.farcry#</cfoutput>/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">

<cfif isdefined("form.submit")>
	<cfset error = 0>

	<!--- Add VERITYSTORAGEPATH entry to general config --->
	<cfset application.config.general.verityStoragePath = "#server.coldfusion.rootdir#/verity/collections/">

	<cfwddx action="CFML2WDDX" input="#application.config.general#" output="wConfig">

	<cfquery datasource="#application.dsn#" name="qUpdate">
		UPDATE #application.dbowner#config
		set wConfig = '#wConfig#'
		where configName = 'general'
	</cfquery>

	<cfoutput><span class="frameMenuBullet">&raquo;</span> Config updated<p></p></cfoutput><cfflush>
	
	<!--- Add SESURLs entry to fu config --->
	<cfset application.config.fusettings.SESURLs = "no">

	<cfwddx action="CFML2WDDX" input="#application.config.fusettings#" output="wConfig">

	<cfquery datasource="#application.dsn#" name="qUpdate">
		UPDATE #application.dbowner#config
		set wConfig = '#wConfig#'
		where configName = 'FUSettings'
	</cfquery>

	<cfoutput><span class="frameMenuBullet">&raquo;</span> Config updated<p></p></cfoutput><cfflush>

	<cfoutput><span class="frameMenuBullet">&raquo;</span> Adding new directory to app...</cfoutput><cfflush>
	
	<!--- try to add new directory to app --->
	<cftry>
		<cfdirectory action="CREATE" directory="#application.path.project#/packages/system">
		<cfoutput>done<p></p></cfoutput><cfflush>
		
		<cfcatch>
			<cfoutput>Error creating directories. You need to manually create the following directories<p></p>
			<ul>
				<li>#application.path.project#/packages/system</li>
			</ul>
			</cfoutput><cfflush>
		</cfcatch>
	</cftry>
	
	<!--- Copy live containers to draft --->
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Copying Live containers to draft...</cfoutput><cfflush>
	<cfquery name="q" datasource="#application.dsn#">
		SELECT objectid,versionid from dmHTML where versionID <> ''
	</cfquery>
	<cfscript>
		oCon = createobject("component","#application.packagepath#.rules.container");
	</cfscript>
	<cfloop query="q">
		<cfscript>
			oCon.copyContainers(srcObjectID=q.versionid,destObjectId=q.objectid);
		</cfscript>
		<cfoutput>.</cfoutput><cfflush>
		
	</cfloop>
	
	<!--- Add entry for EWebEditPro to Config ---><br><br>
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultEOPro" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Updating Application Scope...<p></p></cfoutput><cfflush>
	
	<cftry>
		<cfscript>
			//Load the new config into the application scope for the admin
			AConfig = createObject("component", "#application.packagepath#.farcry.config");
			"application.config.EOPro" = AConfig.getConfig(configname='EOPro');
		</cfscript>
		<cfcatch><cfset error=1><span class="frameMenuBullet">&raquo;</span> <cfdump var="#cfcatch#"><cfoutput><p></p></cfoutput></cfcatch>
	</cftry>	
	
	<cfif not error>
		<cfoutput><span class="frameMenuBullet">&raquo;</span> Application scope updated successfully.<p></p></cfoutput><cfflush>
	</cfif>

<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Adds new config items</li>
		<li type="square">Adds new directory to app</li>
		<li type="square">Copys live HTML containers to underlying draft objects</li>
	</ul>
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run b202 Update" name="submit">
	</form>

	</cfoutput>
</cfif>

</body>
</html>
