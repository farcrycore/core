<!--- @@description:
Deploys new htmlArea config<br />
Deploys new fckEditor config<br />
--->

<html>
<head>
<title>Rich Text Editor Update - <cfoutput>#application.applicationname#</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="<cfoutput>#application.url.farcry#</cfoutput>/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">

<cfif isdefined("form.submit")>
	<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">
	<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">
		
	<!--- Add fckEditor config --->
	
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Deploying fckEditor config...</cfoutput><cfflush>

	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultFCKEditor" returnvariable="stStatus">
	
	</cfinvoke>
	
	<cfoutput>done</p></cfoutput>
	
	<cfflush>
	
	<p>Don't forget to refresh your FarCry application using &amp;updateApp=1.</p>

<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Deploys new fckEditor config</li>		
	</ul>
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run FCKEditor Update" name="submit">
	</form>

	</cfoutput>
</cfif>

</body>
</html>