<cfsetting enablecfoutputonly="true" />

<cfheader statuscode="500" statustext="Internal Server Error" />

<cfset showError = false>
<cfif reFindNoCase("^#application.url.webtop#", cgi.script_name)>
	<cfset showError = true>
<cfelseif isdefined("url.debug") AND url.debug>
	<cfset showError = true>
</cfif>

<!--- rudimentary error handler --->
<cfoutput>
	<html>
		<head>
			<title>There was a problem with that last request</title>
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
			<h1>There was a problem with that last request</h1>	
			<p>Please push "back" on your browser or go back <a style="text-decoration:underline" href="/">home</a></p>
			
			<cfif not showError><!--</cfif>
			#errorHTML#
			<cfif not showError>--></cfif>
		</body>
	</html>		
</cfoutput>

<cfsetting enablecfoutputonly="false" />