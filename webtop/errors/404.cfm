<cfsetting enablecfoutputonly="true" />

<cfheader statuscode="404" statustext="Not Found" />

<cfset showError = false>
<cfset urlDebug = "boolean">
<cfif structKeyExists(application, "fapi")>
	<cfset urlDebug = application.fapi.getConfig("security","urlDebug","boolean")>
</cfif>
<cfif isdefined("url.debug") AND urlDebug neq "disable">
	<cfif urlDebug eq "updateappkey" AND url.debug eq application.updateappKey>
		<cfset showError = true>
	<cfelseif urlDebug eq "boolean" AND url.debug eq 1>
		<cfset showError = true>
	<cfelseif cgi.remote_addr eq "127.0.0.1">
		<cfset showError = true>
	</cfif>
</cfif>

<!--- rudimentary error handler --->
<cfoutput>
	<html>
		<head>
			<title>#application.fapi.getResource('error.404@title','That page could not be found')#</title>
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
			<h1>#application.fapi.getResource('error.404@title','That page could not be found')#</h1>
			#application.fapi.getResource('error.goback@html','<p>Please push "back" on your browser or go back <a style="text-decoration:underline" href="/">home</a></p>')#
			
			<cfif showError>
				#errorHTML#
			</cfif>
		</body>
	</html>		
</cfoutput>

<cfsetting enablecfoutputonly="false" />