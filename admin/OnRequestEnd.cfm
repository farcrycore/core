<cftry>
<!--- Try to include apps.cfm from the farcry directory --->
<cfinclude template="/farcry/apps.cfm">
<cfinclude template="/farcry/#stApps[cgi.server_name]#/www/OnRequestEnd.cfm">

	<cfcatch>
		<cfinclude template="/OnRequestEnd.cfm">
	</cfcatch>
</cftry>


