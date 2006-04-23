<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="fatalErrorMessage" default=""> <!--- fatal [ie something wrong with the db and page cant render] --->
<cfparam name="errorMessage" default=""> <!--- normal error [ie server side validation] --->
<cfparam name="bExport" default="no">

<cfset oAuthorisation = request.dmsec.oAuthorisation>
<cfset aPolicyGroup = oAuthorisation.getAllPolicyGroups()>

<cfif bExport EQ "yes"><!--- do export --->
	<cfset stPolicyStore = oAuthorisation.getPolicyStore()>	
	<cfquery name="qExport" datasource="#stPolicyStore.datasource#" dbtype="ODBC">
	SELECT * FROM #application.dbowner#dmPolicyGroup
	</cfquery>

	<cfset filename="policyGroups.wddx">
	<CFHEADER NAME="content-disposition" VALUE="inline; filename=#filename#"><cfoutput>
	<cfcontent type="application/unknown" reset="yes">
	<cfwddx action="CFML2WDDX" input="#qExport#" usetimezoneinfo="No"></cfoutput>
	<cfabort>
</cfif>
<!--- check permissions --->
<cfset iSecurityTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="SecurityPolicyManagementTab")>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iSecurityTab EQ 0>
	<admin:permissionError>
<cfelse><cfoutput>
	<h3>#application.adminBundle[session.dmProfile.locale].policyGroups#</h3>
	<cfif errorMessage NEQ "">
	<span class="error">#errorMessage#</span>
	<cfelse>
	
	<p><strong><a href="groups_editform.cfm">Add a policy group</a></strong></p>

	<table class="table-4" cellspacing="0">
	<tr>
		<th scope="col">#application.adminBundle[session.dmProfile.locale].name#</th>
		<th scope="col">#application.adminBundle[session.dmProfile.locale].description#</th>
	</tr><cfset iCounter = 1><cfloop index="i" from="1" to="#ArrayLen(aPolicyGroup)#">
	<tr <cfif (iCounter MOD 2) EQ 0> class="alt"</cfif>>
		<th scope="row" class="alt"><a href="groups_editform.cfm?objectID=#aPolicyGroup[i].PolicygroupId#">#aPolicyGroup[i].PolicygroupName#</a></th>
		<td>#aPolicyGroup[i].PolicygroupNotes#</td>
	</tr><cfset iCounter = iCounter + 1></cfloop>
	</table>
	<hr />
	<ul>
		<li><a href="#cgi.script_name#?bExport=yes">#application.adminBundle[session.dmProfile.locale].exportPolicyGroups#</a></li>
		<li><a href="groups_import.cfm">#application.adminBundle[session.dmProfile.locale].importPolicyGroups#</a></li>
	</ul>
	</cfif></cfoutput>
</cfif>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="false">