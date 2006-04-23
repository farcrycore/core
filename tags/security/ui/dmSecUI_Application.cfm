<cfsetting enablecfoutputonly="Yes">
<cfscript>
	oAuthorisation = request.dmsec.oAuthorisation;
	oAuthentication = request.dmsec.oAuthentication;
</cfscript>

<!---- ******** CHECK THE USER IS LOGGED IN AND HAS ADMIN PERMISSIONS *********** --->
<cfif StructKeyExists(request,"init") AND request.init eq 0>
	<cfscript>
		if (isDefined("url.logout"))
			oAuthorisation.logout();
	</cfscript>
	
	
	<cfif cgi.script_name neq "#application.RootUrl#/security/baseInit.cfm">
		<cfscript>
			stLoggedInUser = oAuthentication.getUserAuthenticationData();
		</cfscript>
		
	
		<cfif not stLoggedInUser.bLoggedIn>
			<cflocation url="#application.RootUrl#/navajo/login.cfm?returnUrl=#URLEncodedFormat(cgi.script_name&'?'&cgi.query_string)#" addtoken="no">
			<cfabort>
		</cfif>
		
		<!--- if they are not authorised for admin clear there session and send them back to the login --->
		<cfif stLoggedInUser.bLoggedIn>
			<cfscript>
				iState = oAuthorisation.checkPermission(permissionName="SecurityManagement",reference="PolicyGroup");
			</cfscript>
			 <cfif iState neq 1>
			
				<cfscript>
					oAuthorisation.logout();
				</cfscript>
				
				<cfoutput>
					<script>
					
					alert("You do not have permission to be in the security system.");
					this.location.reload();
					</script>
					<p>This page should automatically refresh when loaded, if not please hit the refresh key in your browser!</p>
				</cfoutput>	
				
				<cfabort>
				
			</cfif>  
		</cfif>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="No">