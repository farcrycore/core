<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/ui/admin/Attic/coapiRules.cfm,v 1.2 2003/07/17 01:51:10 brendan Exp $
$Author: brendan $
$Date: 2003/07/17 01:51:10 $
$Name: b131 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">

<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">

<admin:header title="COAPI Rules">

<cfoutput>
	<span class="formtitle">Rule Classes</span><p></p>
</cfoutput>

<cfif isDefined("URL.deploy")>
	<cftry>
		<cfscript>
			if(NOT application.rules['#URL.deploy#'].bCustomRule)
				o = createObject("component", "#application.packagePath#.rules.#URL.deploy#");
			else
				o = createObject("component", "#application.custompackagePath#.rules.#URL.deploy#");
				result = o.deployType(btestRun="false");
		</cfscript>
		
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

<cfdirectory directory="#application.path.core#/packages/rules" name="qDir" filter="rule*.cfc" sort="name">

<cfoutput>
<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
<tr>
	<th class="dataheader">Integrity</th>
	<th class="dataheader">Rule</th>
	<th class="dataheader">Deployed</th>
	<th class="dataheader">Deploy</th>
</tr>
</cfoutput>
<cfloop collection="#application.rules#" item="componentname" >

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
	<tr>
		<td align="center">Unknown</td>
		<td>#evaluate("application.rules." & componentName & ".displayName")#</td>
		<td align="center">
			<cfif bDeployed>
				<img src="#application.url.farcry#/images/yes.gif">
			<cfelse>
				<img src="#application.url.farcry#/images/no.gif">
			</cfif>
		</td>
		<td align="center"><cfif NOT bDeployed><a href="#CGI.SCRIPT_NAME#?deploy=#componentName#">Deploy</a><cfelse>NA</cfif></td>
	</tr>
	</cfoutput>
</cfloop>

<cfoutput>
</table>
</cfoutput>

<admin:footer>
<cfsetting enablecfoutputonly="No">
