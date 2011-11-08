<cfsetting enablecfoutputonly="true" />

<cfheader statuscode="404" statustext="Not Found" />

<!--- rudimentary error handler --->
<cfoutput>
	<html>
		<head>
			<title>That page could not be found</title>
			<style type="text/css">
				body { 
					width:960px; 
					margin:20px auto; 
					border: 1px solid ##c8c8c8\9; 
					background-color:##FFFFFF; 
					padding:15px; 
					-webkit-box-shadow: 0 0 8px rgba(128,128,128,0.75); 
					-moz-box-shadow: 0 0 8px rgba(128,128,128,0.75); 
					box-shadow: 0 0 8px rgba(128,128,128,0.75); 
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
			</style>
		</head>
		<body>
			<h1>That page could not be found</h1>	
			<p>Please push "back" on your browser or go back <a style="text-decoration:underline" href="/">home</a></p>
			
			<cfif not isdefined("url.debug") or not url.debug><!--</cfif>
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
			<cfif not isdefined("url.debug") or not url.debug>--></cfif>
		</body>
	</html>		
</cfoutput>

<cfsetting enablecfoutputonly="false" />