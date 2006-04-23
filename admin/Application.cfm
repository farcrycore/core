<cfinclude template="/Application.cfm">

<!--- check to see if the person has admin permissions --->
<cfif NOT request.mode.bAdmin>
	<!--- log the user out --->
	<cf_dmSec_logout>

	<!--- redirect them to the login page --->
	<cfif not ListContains( cgi.script_name, "#application.url.farcry#/login.cfm" )>
		<cflocation url="#application.url.farcry#/login.cfm?returnUrl=#URLEncodedFormat(cgi.script_name&'?'&cgi.query_string)#" addtoken="No">
		<cfabort>
	</cfif>

</cfif>
