<html>
<head>
<title>Farcry Core b106 Update</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>

<cfif isdefined("form.submit")>
		<cfset error = 0>
			<!--- This table no longer required --->
		<cftry>
			<cfquery name="update" datasource="#form.dsn#">
				drop TABLE ruleHandpicked_aObjects
			</cfquery>
			<cfcatch type="database">
				<cfoutput><span style="color:red">#cfcatch.queryerror#</span></cfoutput><p></p>			<cfflush>
				<cfset error = 1>
			</cfcatch>
		</cftry>
		<cfif not error>
			<p>Dropped ruleHandpicked_aObjects</p><cfflush>
		</cfif>
	
		<cftry>
			<cfinvoke component="#application.packagepath#.rules.ruleHandpicked" method="deployType" btestrun="False" returnvariable="stStatus" bDropTable="true"/>
			<cfdump var="#stStatus#" label="ruleHandpicked deployment">
			<cfcatch type="any">
				<cfoutput><span style="color:red">#cfcatch.message#</span></cfoutput><p></p><cfflush>
			</cfcatch>
		</cftry>
		
		
<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Drops existing ruleHandpicked_aObjects table if it exists</li>
		<li type="square">Drops existing ruleHandpicked table, and redeploys with new schema</li>
	</ul> 
	</p>
	<form action="" method="post">
		Enter DSN : <input type="text" name="dsn" value="#application.dsn#">
				<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run b106 Updates" name="submit">
	</form>
	
	</cfoutput>
</cfif>

</body>
</html>
