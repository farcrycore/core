<!--- @@description:
Add new config item - FILENAMECONFLICT - for handling name conflicts when uploading files<br>
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

	<!--- Add NAMECONFLICT entry to general config --->
	<cfset application.config.general.fileNameConflict = "MAKEUNIQUE">
	<cfwddx action="CFML2WDDX" input="#application.config.general#" output="wConfig">

	<cfquery datasource="#application.dsn#" name="qUpdate">
		UPDATE #application.dbowner#config
		set wConfig = '#wConfig#'
		where configName = 'general'
	</cfquery>

	<cfoutput><span class="frameMenuBullet">&raquo;</span> Config updated<p></p></cfoutput><cfflush>

<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Adds new config items</li>
	</ul>
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run b201 Update" name="submit">
	</form>

	</cfoutput>
</cfif>

</body>
</html>
