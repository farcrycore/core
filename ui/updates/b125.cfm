<!--- @@description:Clears existing browser stats (refined browser stats) --->

<html>
<head>
<title>Farcry Core b125 Update - <cfoutput>#application.applicationname#</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="<cfoutput>#application.url.farcry#</cfoutput>/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">

<cfif isdefined("form.submit")>
	<cfset error = 0>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Clearing Browser Stats...<p></p></cfoutput><cfflush>
	
	<cfquery name="update" datasource="#application.dsn#">
		UPDATE STATS SET 
		browser = 'unknown'
	</cfquery>
				
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Update completed successfully<p></p></cfoutput><cfflush>
		
<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Clears existing browser stats (refined browser stats)</li>
	</ul> 
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run b125 Update" name="submit">
	</form>
	
	</cfoutput>
</cfif>

</body>
</html>
