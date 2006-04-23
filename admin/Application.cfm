<cfsetting enablecfoutputonly="yes">

<cftry>
<!--- Try to include apps.cfm from the farcry directory --->
<cfinclude template="/farcry/apps.cfm">
<cfinclude template="/farcry/#stApps[cgi.server_name]#/www/Application.cfm">

	<cfcatch>
		<cfinclude template="/Application.cfm">
	</cfcatch>
</cftry>

<!--- check to see if the person has admin permissions --->

<cfif NOT request.mode.bAdmin>
	<!--- log the user out --->

	<cfscript>
		request.dmsec.oAuthentication.logout();
	</cfscript>

	<!--- redirect them to the login page --->
	<cfif not ListContains( cgi.script_name, "#application.url.farcry#/login.cfm" )>
		<cflocation url="#application.url.farcry#/login.cfm?returnUrl=#URLEncodedFormat(cgi.script_name&'?'&cgi.query_string)#" addtoken="No">
		<cfabort>
	</cfif>

</cfif>

<cfsetting enablecfoutputonly="no">