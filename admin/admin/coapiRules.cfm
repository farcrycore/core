<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/fourq/tags/" prefix="q4">
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>COAPI Rules</title>
	<link rel="stylesheet" href="#application.url.farcry#/css/admin.css" type="text/css">
</head>

<body>
<span class="formtitle">Rule Classes</span><p></p>
</cfoutput>

<cfif isDefined("URL.deploy")>
	<!--- DEPLOY TYPE HERE TODO:--->
	<cftry>
	<cfscript>
		o = createObject("component", "#application.packagePath#.rules.#URL.deploy#");
		result = o.deployType(btestRun="false");
	</cfscript>
	<cfdump var="#result#">
	<cfcatch>
		<!--- Kind of guessing here really - the only reason this should fail is if the tables aready exist --->
		<cfoutput><h4 style="color:red">Rule Deployment Failed</h4>
		Type has already been deployed
		</cfoutput>
	</cfcatch>
	
	</cftry>
</cfif>

<!--- Work out the rules dir to parse--->
<cfset rulesDir = expandPath(replaceNoCase("/#application.packagepath#/rules",".","/","ALL"))>

<cfdirectory directory="#rulesDir#" name="qDir" filter="rule*.cfc" sort="name">

<cfoutput>

<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
<tr>
	<td class="dataheader">Component</td>
	<td class="dataheader">Deployed</td>
	<td class="dataheader">Integrity</td>
	<td class="dataheader">Deploy</td>
</tr>
</cfoutput>
<cfloop query="qDir">
<cfset componentName = left(qDir.name, len(qDir.name)-4)>
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
	<td><cfif NOT bDeployed><a href="#CGI.SCRIPT_NAME#?deploy=#componentName#">Deploy</a><cfelse><em>n/a</em></cfif></td>
</tr>
</cfoutput>
</cfloop>

<cfoutput>
</table>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">

