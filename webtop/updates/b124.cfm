<!--- @@description:
Creates the default config file for EWebEditPro rich text editor
--->

<html>
<head>
<title>Farcry Core b124 Update - <cfoutput>#application.applicationname#</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="<cfoutput>#application.url.farcry#</cfoutput>/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">

<cfif isdefined("form.submit")>
	<cfset error = 0>
	
	<!--- Add entry for EWebEditPro to Config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultEWebEditPro" returnvariable="stStatus"></cfinvoke>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Updating Application Scope...<p></p></cfoutput><cfflush>
	
	<cftry>
		<cfscript>
			//Load the new config into the application scope for the admin
			AConfig = createObject("component", "#application.packagepath#.farcry.config");
			"application.config.EWebEditPro" = AConfig.getConfig(configname='EWebEditPro');
		</cfscript>
		<cfcatch><cfset error=1><span class="frameMenuBullet">&raquo;</span> <cfdump var="#cfcatch#"><cfoutput><p></p></cfoutput></cfcatch>
	</cftry>	
	
	<cfif not error>
		<cfoutput><span class="frameMenuBullet">&raquo;</span> Application scope updated successfully.<p></p></cfoutput><cfflush>
	<cfelse>
		<cfoutput><span class="frameMenuBullet">&raquo;</span> <span class="error">Application scope update failed.</span><p></p></cfoutput><cfflush>
	</cfif>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> EWebEditPro update completed successfully.<p></p></cfoutput><cfflush>
		
<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Creates the default configuration for EWebEditPro rich text editor</li>
	</ul> 
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run b124 Update" name="submit">
	</form>
	
	</cfoutput>
</cfif>

</body>
</html>
