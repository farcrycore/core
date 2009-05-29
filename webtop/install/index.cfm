<cfsetting enablecfoutputonly="true" requesttimeout="600" />
<!--- @@displayname: Installation UI --->

<cfif not structkeyexists(session,"oUI") or structkeyexists(url,"resetinstall")>
	<cfset session.oUI = createobject('component','components.farcryui').init(structnew()) />
	<cfset session.oInstall = createobject('component','components.install').init(session.oUI) />
</cfif>

<cfset coreVersion = session.oInstall.getCoreVersion() />

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
				<p style="text-align:right;margin-top:25px;"><small>You are currently running version <strong>#coreVersion.major#-#coreVersion.minor#-#coreVersion.patch#</strong> of Farcry Core.</small></p>
</cfoutput>

<!--- Show wizard --->
<cfif not session.oUI.currentStep eq "install">
	<cfinclude template="includes/_wizard.cfm" />
</cfif>

<!--- If the installation is now complete, send to the confirmation page --->
<cfif session.oUI.currentStep eq "install">
	<cfinclude template="includes/_install.cfm" />
</cfif>

<cfoutput>
			</div>
		</body>
	</html>
</cfoutput>
