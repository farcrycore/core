<!--- @@description:
Adds adminServer address to general Config
--->

<html>
<head>
<title>Farcry Core b201 Update - <cfoutput>#application.applicationname#</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="<cfoutput>#application.url.farcry#</cfoutput>/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">

<cfif isdefined("form.submit")>
	<cffunction name="flush">
		<cfflush>
	</cffunction>
		
		<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating General Config...</cfoutput><cfflush>
		
		<!--- Add adminServer entry to general config --->
		<cfset application.config.general.adminServer = "http://#cgi.HTTP_HOST#">
		<cfwddx action="CFML2WDDX" input="#application.config.general#" output="wConfig">
	
		<cfquery datasource="#application.dsn#" name="qUpdate">
			UPDATE #application.dbowner#config
			set wConfig = '#wConfig#'
			where configName = 'general'
		</cfquery>
		<cfoutput> done</p></cfoutput><cfflush>
<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Adds adminServer address to general Config</li>
	</ul>
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run b203 Update" name="submit">
	</form>

	</cfoutput>
</cfif>

</body>
</html>
