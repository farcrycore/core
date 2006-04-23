<cfsetting enablecfoutputonly="Yes">
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>COAPI Types</title>
	<link rel="stylesheet" href="../css/admin.css" type="text/css">
</head>

<body>
<h3>Type Classes</h3>
</cfoutput>
<!--- grab the list the type classes --->
<cfdirectory directory="#application.rootphy#\www\packages\types" name="qDir" filter="*.cfc" sort="name">
<cfoutput>
<table class="datatable">
<tr>
	<td class="dataheader">Component</td>
	<td class="dataheader">Deployed</td>
	<td class="dataheader">Integrity</td>
</tr>
</cfoutput>
<cfloop query="qDir">
<cfset componentName = application.dbowner & left(qDir.name, len(qDir.name)-4)>
<cfset bDeployed=true>

<!--- test if they have been deployed --->
<cftry>
<cfquery datasource="#application.dsn#" name="qTest">
SELECT Count(*) AS foo FROM #componentName#
</cfquery>
<cfcatch>
	<cfset bDeployed=false>
</cfcatch>
</cftry>

<cfoutput>
<tr class="#IIF(qDir.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
	<td>#componentName#</td>
	<td>#YesNoFormat(bDeployed)#</td>
	<td>unknown</td>
</tr>
</cfoutput>
</cfloop>

<cfoutput>
</table>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">

