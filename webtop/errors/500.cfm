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
				<h2>Error Overview</h2>
				<table>
					<tr><th>Machine:</th><td>#machineName#</td></tr>
					<tr><th>Instance:</th><td>#instancename#</td></tr>
					<tr><th>Message:</th><td>#stException.message#</td></tr>
					<tr><th>Browser:</th><td>#cgi.http_user_agent#</td></tr>
					<tr><th>DateTime:</th><td>#now()#</td></tr>
					<tr><th>Host:</th><td>#cgi.http_host#</td></tr>
					<tr><th>HTTPReferer:</th><td>#cgi.http_referer#</td></tr>
					<tr><th>QueryString:</th><td>#cgi.query_string#</td></tr>
					<tr><th>RemoteAddress:</th><td>#cgi.remote_addr#</td></tr>
					<tr><th>Bot:</th><td>#bot#</td></tr>
				</table>
				
				<h2>Error Details</h2>
				<table>
					<cfif structKeyExists(stException, "type") and len(stException.type)>
						<tr><th>Exception Type</th><td>#stException.type#</td></tr>
					</cfif>
					<cfif structKeyExists(stException, "detail") and len(stException.detail)>
						<tr><th>Detail</th><td>#stException.detail#</td></tr>
					</cfif>
					<cfif structKeyExists(stException, "extended_info") and len(stException.extended_info)>
						<tr><th>Extended Info</th><td>#stException.extended_info#</td></tr>
					</cfif>
					<cfif structKeyExists(stException, "queryError") and len(stException.queryError)>
						<tr><th>Error</th><td>#stException.queryError#</td></tr>
					</cfif>
					<cfif structKeyExists(stException, "sql") and len(stException.sql)>
						<tr><th>SQL</th><td>#stException.sql#</td></tr>
					</cfif>
					<cfif structKeyExists(stException, "where") and len(stException.where)>
						<tr><th>Where</th><td>#stException.where#</td></tr>
					</cfif>
					
					<cfif structKeyExists(stException, "TagContext") and arraylen(stException.TagContext)>
						<tr>
							<th>Tag Context</th>
							<td>
								<ul>
								<cfloop from="1" to="#arrayLen(stException.TagContext)#" index="i">
									<li>#stException.TagContext[i].template# (line: #stException.TagContext[i].line#)</li>
								</cfloop>
								</ul>	
							</td>
						</tr>
					</cfif>
					
					<cfif structkeyexists(stException, "detail") and len(stException.detail)>
						<tr>
							<th>Detail</th>
							<td>#stException.detail#</td>
						</tr>
					</cfif>
					
					<cfif structkeyexists(stException, "extendedinfo") and len(stException.extendedinfo)>
						<tr>
							<th>Extended Information</th>
							<td>#stException.extendedinfo#</td>
						</tr>
					</cfif>
					
					<cfif structkeyexists(stException, "stacktrace") and len(stException.stacktrace)>
						<tr>
							<th>Stack Trace</th>
							<td>#rereplace(stException.stacktrace,"\sat ","<br>at ","ALL")#</td>
						</tr>
					</cfif>
				</table>
			<cfif not showError>--></cfif>
		</body>
	</html>		
</cfoutput>

<cfsetting enablecfoutputonly="false" />