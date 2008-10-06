<!--- THIS EMPTY APPLICATION ALLOWS THE UPDATE TO RUN AS ITS OWN STANDALONE APPLICATION --->
<cfset lAllowHosts = "127.0.0.1,::1" />
<cfif NOT listFind(lAllowHosts, cgi.remote_addr)>
	<cfthrow errorcode="upgrade_invalid_host" detail="Your IP address (#cgi.remote_addr#) is not permitted to access the 5.0 updater" 
			extendedinfo="By default, the 5.0 updater is only permitted to the following hosts : 127.0.0.1  To give access to other hosts, then append the desired IP address to the variable lAllowHosts in /farcry/projects/YOURPROJECT/upgrader5.0.0/Application.cfm">
</cfif>