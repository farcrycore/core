<cfsetting enablecfoutputonly="true" />

<cfheader statuscode="404" statustext="Not Found" />

<cfset showError = false>
<cfif isdefined("url.debug") AND url.debug>
	<cfset showError = true>
</cfif>

<!--- rudimentary error handler --->
<cfoutput>
	<html>
		<head>
			<title>That page could not be found</title>
			<style type="text/css">
				body { 
					margin:0px; 
					background-color:##FFFFFF; 
					padding:15px; 
					font-family: Arial, Helvetica, sans-serif;
				}
				table, td, th {
					border: 0 none;
					border-collapse:collapse;
				}
				th { 
					text-align:right;
					vertical-align:top;
				}
				td, th {
					padding:5px;
				}
				h1 {
					margin-top: 0;
				}
			</style>
		</head>
		<body>
			<h1>That page could not be found</h1>	
			<p>Please push "back" on your browser or go back <a style="text-decoration:underline" href="/">home</a></p>
			
			<cfif not showError><!--</cfif>
				<h2>Error Overview</h2>
				<table>
					<tr><th>Machine:</th><td>#machineName#</td></tr>
					<tr><th>Instance:</th><td>#instancename#</td></tr>
					<tr><th>Browser:</th><td>#cgi.http_user_agent#</td></tr>
					<tr><th>DateTime:</th><td>#now()#</td></tr>
					<tr><th>Host:</th><td>#cgi.http_host#</td></tr>
					<tr><th>HTTPReferer:</th><td>#cgi.http_referer#</td></tr>
					<tr><th>QueryString:</th><td>#cgi.query_string#</td></tr>
					<tr><th>RemoteAddress:</th><td>#cgi.remote_addr#</td></tr>
				</table>
			<cfif not showError>--></cfif>
		</body>
	</html>		
</cfoutput>

<cfsetting enablecfoutputonly="false" />