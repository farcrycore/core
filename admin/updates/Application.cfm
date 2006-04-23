<cfset request.bLoggedIn = "true">
<cftry>
    <!--- Try to include apps.cfm from the farcry directory --->
    <cfinclude template="/farcry/apps.cfm">
    <cfinclude template="/farcry/#stApps[cgi.server_name]#/www/Application.cfm">
<cfcatch>
    <cftry>
        <cfinclude template="/#listGetAt(CGI.SCRIPT_NAME, 1, '/')#/Application.cfm">
    <cfcatch>
        <cfinclude template="/Application.cfm">
    </cfcatch>
    </cftry>
</cfcatch>
</cftry>