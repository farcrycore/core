<cfcomponent extends="farcry.core.proxyApplication" displayname="Application" output="true" hint="Handle the application.">



	<cffunction name="OnRequestStart" access="public" returntype="boolean" output="true" hint="Fires at first part of page processing.">
		<!--- Define arguments. --->

		<cfargument name="TargetPage" type="string" required="true" />
		
		
		
		
		<!--- Call the main farcry Application.cfc --->
		<cfset var b = super.OnRequestStart(argumentCollection=arguments) />

		
		<!--- i18n date/time format styles --->
		<cfset application.shortF=3>        <!--- 3/27/25 --->
		<cfset application.mediumF=2>       <!--- Rabi' I 27, 1425 (yeah, i know) --->
		<cfset application.longF=1>         <!--- Rabi' I 27, 1425 --->
		<cfset application.fullF=0>         <!--- Monday, Rabi' I 27, 1425 --->
		<cfset debugRB=true>    <!--- load rb with debug markup? --->
		
		<!--- check to see if the person has general admin permissions --->
		<cfif not application.security.checkPermission("Admin")>
		    <!--- logout illegal users --->
		    <cfscript>
		        application.factory.oAuthentication.logout();
		    </cfscript>
		
		    <!--- redirect them to the login page --->
		    <cfif not ListContains( cgi.script_name, "#application.url.farcry#/login.cfm" )>
		        <cflocation url="#application.url.farcry#/login.cfm?returnUrl=#URLEncodedFormat(cgi.script_name&'?'&cgi.query_string)#" addtoken="No">
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


		<!--- Return out. --->

		<cfreturn true />

	</cffunction>

 

	<cffunction name="OnRequest" access="public" returntype="void" output="true" hint="Fires after pre page processing is complete.">
		<!--- Define arguments. --->

		<cfargument name="TargetPage" type="string" required="true" />
		
		<!--- Call the main farcry Application.cfc --->
		<cfset super.OnRequest(argumentCollection=arguments) />
		
		<!--- Include the requested page. --->
		<cfinclude template="#ARGUMENTS.TargetPage#" />

		<!--- Return out. --->

		<cfreturn />

	</cffunction>
 

</cfcomponent>