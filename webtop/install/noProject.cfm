

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
			<h1>FarCry Project Not Found</h1>
			<p>I'm terribly sorry, I can't find a FarCry project on this server to administer.</p>
			<p><a href="index.cfm">CLICK HERE TO INSTALL A NEW PROJECT</a></p>
		</cfoutput>
		

<cfoutput>
		<p style="text-align:right;border-top:1px solid ##e3e3e3;margin-top:25px;"><small>You are currently running version <strong>#request.coreVersion.major#-#request.coreVersion.minor#-#request.coreVersion.patch#</strong> of Farcry Core.</small></p>
	</div>
</body>
</html>
</cfoutput>



