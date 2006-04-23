<!--- @@description:Adds exportPath path to general config --->

<html>
<head>
<title>Farcry Core b131 Update - <cfoutput>#application.applicationname#</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="<cfoutput>#application.url.farcry#</cfoutput>/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">

<cfif isdefined("form.submit")>
	<cfset error = 0>
	
	<!--- Add entry fto general config --->
	<cfset application.config.general.exportPath = "www/xml">
	<cfwddx action="CFML2WDDX" input="#application.config.general#" output="wConfig">
	
	<cfquery datasource="#application.dsn#" name="qUpdate">
		UPDATE #application.dbowner#config
		set wConfig = '#wConfig#'
		where configName = 'general'
	</cfquery>	
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> exportPath path added successfully.<p></p></cfoutput><cfflush>
		
<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Adds exportPath path to general config</li>
	</ul> 
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run b131 Update" name="submit">
	</form>
	
	</cfoutput>
</cfif>

</body>
</html>
