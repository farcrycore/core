<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/tags/admin/" prefix="admin">

<admin:header title="COAPI Types">

<cfif isDefined("URL.deploy")>
	<!--- DEPLOY TYPE HERE TODO:--->
	<cftry>
	<cfscript>
		o = createObject("component", "#application.packagePath#.types.#URL.deploy#");
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

<cfoutput>
<span class="formtitle">Type Classes</span><p></p>
</cfoutput>
<!--- grab the list the type classes --->
<cfset typesDir = expandPath(replaceNoCase("/#application.packagepath#/types",".","/","ALL"))>
<!--- assumes types are dm* --->
<cfdirectory directory="#typesDir#" name="qDir" filter="dm*.cfc" sort="name">
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

<div style="padding: 5px; margin: 5px; border: 2px dashed ##333; text-align: left;">

<p><b>TODO</b></p>
<ul>
	<li>link to deploy types as required</li>
	<li>auto integrity test to confirm component matched DB schema deployed</li>
	<li>option to alter db table to match modified component</li>
</ul>
</div>

</cfoutput>

<admin:footer>
<cfsetting enablecfoutputonly="No">

