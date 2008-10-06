<cfsetting enablecfoutputonly="true">

<cfapplication name="farcryinstaller" sessionmanagement="true" />
	
<cfset lAllowHosts = "127.0.0.1,::1" />
<cfif NOT listFind(lAllowHosts, cgi.remote_addr)>
	<cfthrow errorcode="install_invalid_host" detail="Your IP address (#cgi.remote_addr#) is not permitted to access the install directory." extendedinfo="By default, installation is only permitted to the following hosts : 127.0.0.1  To give access to other hosts, then append the desired IP address to the variable lAllowHosts in /[projectname]/www/install/Application.cfm">
</cfif>

<!--- Farcry Application assumes existance of application.bObjectBroker so we default its value for the installer here. --->
<cfif NOT structKeyExists(application, "bObjectBroker")>
	<cflock scope="Application" type="exclusive" timeout="2">
		<cfset application.bObjectBroker = false />
	</cflock>
</cfif>


<cfsetting enablecfoutputonly="false">