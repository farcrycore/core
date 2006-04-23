<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/farcry_core/tags/misc/" prefix="misc">

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>adminMenuFrame</title>
	<misc:cachecontrol>
	<LINK href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body>

<div id="frameMenu">
	<cftry>
		<cfmodule template="/farcry/#application.applicationname#/customadmin/#URL.module#">
		
		<cfcatch>
			Importing this template failed : 
				
			#cfcatch.Detail#
			#cfcatch.Message#
		</cfcatch>
	</cftry> 
	
</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">