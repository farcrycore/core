<cfsetting enablecfoutputonly="true">

<cfapplication name="farcryinstaller" sessionmanagement="true" />
	
<!------------------------------------------------------------------------
 The List of IP Addresses that are permitted to install new applications 
ADD YOUR IP TO THE LIST
------------------------------------------------------------------------>
<cfset variables.lAllowHosts = "127.0.0.1" />

<cfif NOT IsLocalHost(cgi.remote_addr) AND NOT listFind(variables.lAllowHosts, cgi.remote_addr)>


	
	<!--------------------------------------- 
	DETERMINE THE CURRENT VERSION OF FARCRY
	 --------------------------------------->
	<cfset request.coreVersion = getCoreVersion() />
	
	
	
	<cfoutput>
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
		<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
		<head>
			<title>FarCry Core Framework Installer</title>
			
			<!--- EXT CSS & JS--->
			<link rel="stylesheet" type="text/css" href="../js/ext/resources/css/ext-all.css" />
			<script type="text/javascript" src="../js/ext/adapter/ext/ext-base.js"></script>
			<script type="text/javascript" src="../js/ext/ext-all.js"></script>
			
			<!--- INSTALL CSS & JS --->
			<link rel="stylesheet" type="text/css" href="css/install.css" />
			<script type="text/javascript" src="js/install.js"></script>
			
	
			
		</head>
		<body style="background-color: ##5A7EB9;">
			<div style="border: 8px solid ##eee;background:##fff;width:600px;margin: 50px auto;padding: 20px;color:##666">
	
	</cfoutput>
	
			<cfoutput>
				<h1>Installation Is Secured</h1>
				<p>Your IP address (#cgi.remote_addr#) is not permitted to access the install directory.</p>
				<p>By default, installation is only permitted to the localhost </p>
				<p>To give access to other hosts, then append the desired IP address to the variable lAllowHosts in: <br />
				<strong>[farcry]/core/webtop/install/Application.cfm.</strong>
				</p>
				<p><a href="index.cfm">CLICK HERE</a> when you have added the your IP (#cgi.remote_addr#) to the list</p>
			</cfoutput>
			
	
	<cfoutput>
			<p style="text-align:right;border-top:1px solid ##e3e3e3;margin-top:25px;"><small>You are currently running version <strong>#request.coreVersion.major#-#request.coreVersion.minor#-#request.coreVersion.patch#</strong> of Farcry Core.</small></p>
		</div>
	</body>
	</html>
	</cfoutput>
	
	<cfabort>
	
</cfif>

<!--- Farcry Application assumes existance of application.bObjectBroker so we default its value for the installer here. --->
<cfif NOT structKeyExists(application, "bObjectBroker")>
	<cflock scope="Application" type="exclusive" timeout="2">
		<cfset application.bObjectBroker = false />
	</cflock>
</cfif>

<cffunction name="getCoreVersion" access="private" returntype="struct" hint="returns a structure containing the major, minor and patch version of farcry.">
	<cfset var coreVersion = structNew() />

	<cftry> 
		<cffile action="read" file="#expandPath('/farcry/core/major.version')#" variable="coreVersion.major">
		<cffile action="read" file="#expandPath('/farcry/core/minor.version')#" variable="coreVersion.minor">
		<cffile action="read" file="#expandPath('/farcry/core/patch.version')#" variable="coreVersion.patch">

		<cfcatch>               
			<cfset coreVersion.major = 0 />
			<cfset coreVersion.minor = 0 />
			<cfset coreVersion.patch = 0 />
		</cfcatch>
		</cftry>

	<cfreturn coreVersion>
</cffunction>

<cfsetting enablecfoutputonly="false">