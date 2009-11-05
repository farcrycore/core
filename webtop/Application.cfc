<cfcomponent extends="farcry.core.proxyApplication" displayname="Application" output="false" hint="Extends proxy which in turn in extends core Application.cfc.">

	<cffunction name="OnRequestStart" access="public" returntype="boolean" output="false">
		<cfargument name="TargetPage" type="string" required="true" />
		
		<!--- Call the main farcry Application.cfc --->
		<cfset var b = super.OnRequestStart(argumentCollection=arguments) />
		
		<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
		
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
		

		<!--- webtop: check to see if the person has general admin permissions --->
		<cfif not application.security.checkPermission("Admin")>
			<!--- logout illegal users --->
			<cfset application.factory.oAuthentication.logout() />
		    <cfif not ListContains( cgi.script_name, "#application.url.farcry#/login.cfm" )>
			    <extjs:bubble message="You do not have permission to access the webtop" />
		        <cflocation url="#application.url.farcry#/login.cfm?returnUrl=#replace(URLEncodedFormat(cgi.script_name&'?'&cgi.query_string),'##','%23','ALL')#" addtoken="No">
		        <cfabort>
		    </cfif>
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