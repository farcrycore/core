<html>
<head>
<title>Farcry Core Friendly URLs Update: <cfoutput>#application.applicationname#</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="<cfoutput>#application.url.farcry#</cfoutput>/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">
<cfoutput><img src="#application.url.farcry#/images/farcry_logo.gif" border="0" alt="FarCry Updater"><P></P></cfoutput>

<cfif isdefined("form.submit")>
	
	<cfset error2 = 0>
	
	<!--- Create an instance of the component --->
	<cfobject component="#application.packagepath#.farcry.fu" name="fu">
	<!--- call create method --->
	<cfset fu.createALL()>
	
	<cfif not error2>
		<cfoutput><span class="frameMenuBullet">&raquo;</span> Friendly url's created.<p></p></cfoutput><cfflush>
	</cfif>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Update Complete</cfoutput><cfflush>	
	
<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Sets up friendly urls for your site</li>
	</ul> 
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run Friendly URLs Update" name="submit">
	</form>
	
	</cfoutput>
</cfif>

</body>
</html>
