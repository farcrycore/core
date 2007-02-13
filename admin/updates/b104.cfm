<html>
<head>
<title>Farcry Core b104 Update</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>

<cfif isdefined("form.submit")>
	<!--- dmProfile deploy --->
	<cfinvoke component="#application.packagepath#.types.dmProfile" method="deployType" btestrun="False" returnvariable="stStatus"></cfinvoke>
	<cfdump var="#stStatus#" label="dmProfile deployment">
	<cfflush><p></p>
	
	<!--- new stored procedures --->
	<cfinvoke component="#application.packagepath#.farcry.tree" method="deployTreeProcs" returnvariable="stStatus"></cfinvoke>
	<cfdump var="#stStatus#" label="stored procedures deployment">
	<cfflush><p></p>
	
	<!--- new permissions --->
	<cfquery name="dPerms" datasource="#application.dsn#">delete from dmPermissionBarnacle</cfquery>
	<cfoutput>Deleting old permissions...<p></p></cfoutput><cfflush>
	
	<cftry>
		<cffile action="READ" file="#application.path.core#\admin\install\permissionBarnacle.csv" variable="permFile">
		<cfcatch>Error reading file<p></p><cfdump var="#cfcatch#"><cfabort></cfcatch>
	</cftry>
	
	<cfoutput>Setting up new permissions...<p></p></cfoutput><cfflush>
	
	<!--- set up policy store --->
	<cfscript>
		
	</cfscript>
	
	
	
	<cf_dmSec_PermissionsDBInit datasource="#application.dsn#" bClearTable="true">
	
	<!--- set up permissions --->
	<cfloop list="#permFile#" index="lPerms" delimiters="#chr(13)##chr(10)#">
		<cfscript>
		oid = listGetAt(lPerms, 3);
		if (oid neq 'PolicyGroup')
			lPerms = listSetAt(lPerms, 3, application.navid.root);
		</cfscript>
	
		<!--- create permission barnacle --->
		<cf_dmSec_PermissionBarnacleCreate
			permissionID="#listGetAt(lPerms, 1)#"
			policyGroupID="#listGetAt(lPerms, 2)#"
			reference1="#listGetAt(lPerms, 3)#"
			state="#listGetAt(lPerms, 4)#">
	</cfloop>
	
	<!--- remove existing permissions cache WDDX file --->
	<cfif fileExists("#application.path.project#\permissionCache.wddx")>
		<cffile action="DELETE" file="#application.path.project#\permissionCache.wddx">
	</cfif>
	
	<cfoutput>All done :)<p></p>You may need to restart coldfusion</cfoutput><cfflush>
<cfelse>

	<form action="" method="post">
	<table>
	<!--- <tr>
		<td>Datasource: </td>
		<td><input type="text" name="dsn" size="50"></td>
	</tr>
	<tr>
		<td>Package Path:</td>
		<td><input type="text" name="packagepath" value="core.packages" size="50"></td>
	</tr>
	<tr>
		<td>Core directory:</td>
		<td><input type="text" name="core" value="c:\inetpub\applications\core" size="50"></td>
	</tr>
	<tr>
		<td>Project directory:</td>
		<td><input type="text" name="project" value="c:\inetpub\applications\" size="50"></td>
	</tr> --->
	<tr>
		<td>&nbsp;</td>
		<td><input type="submit" value="Run b104 Updates" name="submit"></td>
	</tr>
	</table>
	<input type="hidden" name="dummy" value="1">
	</form>
</cfif>
</body>
</html>
