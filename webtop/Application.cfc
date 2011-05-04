<cfcomponent extends="farcry.core.proxyApplication" displayname="Application" output="false" hint="Extends proxy which in turn in extends core Application.cfc.">

	<cffunction name="OnRequestStart" access="public" returntype="boolean" output="false">
		<cfargument name="TargetPage" type="string" required="true" />
		
		<!--- Before we call the core application.cfc, turn off FU redirection for the webtop --->
		<cfset request.fc.disableFURedirction = true />
		
		<!--- Call the main farcry Application.cfc --->
		<cfset super.OnRequestStart(argumentCollection=arguments) />

		<!--- I18N config for Webtop --->
		<!--- TODO:	move all i18n vars into their own struct
					are these used in the new i18n framework? eg. debugRB appears to be irrelevant 
					perhaps these options should be set globally in the ./core/Application.cfc? --->
		<cfset application.shortF=3>        <!--- 3/27/25 --->
		<cfset application.mediumF=2>       <!--- Rabi' I 27, 1425 --->
		<cfset application.longF=1>         <!--- Rabi' I 27, 1425 --->
		<cfset application.fullF=0>         <!--- Monday, Rabi' I 27, 1425 --->
		<cfset debugRB=true>    			<!--- load rb with debug markup? --->
		<!--- /I18N config for Webtop --->
		

		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />		

		<cfif not findNoCase( "login.cfm", cgi.script_name )>  
			<!--- If the user is not logged in, then they are redirected to the login page with no message --->
			<sec:checkLoggedIn url="#arguments.targetPage#?#cgi.query_string#" />  
	
			<!--- If the user is logged in but does not have the admin permission, then they are redirected with a message --->
			<sec:checkLoggedIn url="#arguments.targetPage#?#cgi.query_string#" lPermissions="admin" message="You do not have permission to access the webtop" />  
		</cfif>  		
		
		<!--- Restrict access if webtop access is disabled --->
		<cfif not application.sysinfo.bwebtopaccess>
			<cfoutput>
			<div style="margin: 10% 30% 0% 30%; padding: 10px; border: 2px navy solid; background: ##dedeff; font-family: Verdana; font-color: navy; text-align: center;">
				<h2>Webtop Access Restricted</h2>
				<p>Webtop access has been specifically restricted on this server.  Please contact your system administrator for details.</p>
			</div>
			</cfoutput>
			<cfabort />
		</cfif>


		<cfreturn true />
	</cffunction>

</cfcomponent>