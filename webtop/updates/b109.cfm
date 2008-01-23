<html>
<head>
<title>Farcry Core b109 Update</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>

<cfif isdefined("form.submit")>
	<cfset error = 0>
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultGeneral" returnvariable="stStatus"></cfinvoke>
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Re-deploys config</li>
		
	</ul> 
	</p>
	<form action="" method="post">
		Enter DSN : <input type="text" name="dsn" value="#application.dsn#">
				<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run b109 Updates" name="submit">
	</form>
	
	</cfoutput>
</cfif>

</body>
</html>
