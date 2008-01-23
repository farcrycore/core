<!--- @@description:Creates the default config file for Friendly URLs --->

<html>
<head>
<title>Farcry Core b127 Update - <cfoutput>#application.applicationname#</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="<cfoutput>#application.url.farcry#</cfoutput>/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">

<cfif isdefined("form.submit")>
	<cfset error = 0>
	
	<!--- Add entry for FU to Config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultFU" returnvariable="stStatus"></cfinvoke>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Updating Application Scope...<p></p></cfoutput><cfflush>
	
	<cftry>
		<cfscript>
			//Load the new config into the application scope for the admin
			AConfig = createObject("component", "#application.packagepath#.farcry.config");
			"application.config.FUSettings" = AConfig.getConfig(configname='FUSettings');
		</cfscript>
		<cfcatch><cfset error=1><cfoutput><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch#"></span><p></p></cfoutput></cfcatch>
	</cftry>	
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Friendly URLs update completed successfully.<p></p></cfoutput><cfflush>
		
<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Creates the default configuration for Friendly URLs</li>
	</ul> 
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run b127 Update" name="submit">
	</form>
	
	</cfoutput>
</cfif>

</body>
</html>
