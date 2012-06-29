<cfsetting enablecfoutputonly="true" />

<cfheader statuscode="500" statustext="Internal Server Error" />

<!--- rudimentary error handler --->
<cfoutput>
	<html>
		<head>
			<title>There was a problem with that last request</title>
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
			<h1>There was a problem with that last request</h1>	
			<p>Please push "back" on your browser or go back <a style="text-decoration:underline" href="/">home</a></p>
			
			<cfif not isdefined("url.debug") or not url.debug><!--</cfif>
			#errorHTML#
			<cfif not isdefined("url.debug") or not url.debug>--></cfif>
		</body>
	</html>		
</cfoutput>

<cfsetting enablecfoutputonly="false" />