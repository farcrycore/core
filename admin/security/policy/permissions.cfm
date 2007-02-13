<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="fatalErrorMessage" default=""> <!--- fatal [ie something wrong with the db and page cant render] --->
<cfparam name="errorMessage" default=""> <!--- normal error [ie server side validation] --->
<cfparam name="bExport" default="no">

<!--- User directory selection --->
<cfset oAuthorisation = request.dmsec.oAuthorisation>
<cfset oAuthentication = request.dmsec.oAuthentication>
<cfset stPolicyStore = oAuthorisation.getPolicyStore()>
<cfset aPermissions = oAuthorisation.getAllPermissions()>
<cfset lastType = "">

<cfif bExport EQ "yes"><!--- do export --->
	<cfquery name="qExport" datasource="#stPolicyStore.datasource#" dbtype="ODBC">
	SELECT * FROM #application.dbowner#dmPermission
	</cfquery>

	<cfset filename="permission.wddx">
	<CFHEADER NAME="content-disposition" VALUE="inline; filename=#filename#"><cfoutput>
	<cfcontent type="application/unknown" reset="yes">
	<cfwddx action="CFML2WDDX" input="#qExport#" usetimezoneinfo="No"></cfoutput>
	<cfabort>
</cfif>

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
<cfoutput>
<h3>#application.adminBundle[session.dmProfile.locale].permissions#</h3>
<cfif fatalErrorMessage NEQ "">
		<span class="error">#fatalErrorMessage#</span>
<cfelse>
	<cfif errorMessage NEQ "">
		<span class="error">#errorMessage#</span>
	</cfif>
	<p><strong><a href="permissions_editform.cfm">Add Permission</a></strong></p>
	<table class="table-4" cellspacing="0">
	<tr>
	<th scope="col">#application.adminBundle[session.dmProfile.locale].typeLC#</th>
	<th scope="col">#application.adminBundle[session.dmProfile.locale].name#</th>
	<th scope="col">#application.adminBundle[session.dmProfile.locale].notes#</th>
	</tr><cfloop index="i" from="1" to="#ArrayLen(aPermissions)#">
	<tr<cfif i MOD 2 EQ 0> class="alt"</cfif>><cfif lastType NEQ aPermissions[i].PermissionType><cfset lastType = aPermissions[i].PermissionType>
		<th scope="row" class="alt">#aPermissions[i].PermissionType#</th><cfelse>
		<th scope="row" class="alt">&nbsp;</th></cfif>
		<td><a href="permissions_editform.cfm?objectID=#aPermissions[i].permissionID#">#aPermissions[i].PermissionName#</a></td>
		<td><cfif trim(aPermissions[i].PermissionNotes) EQ "">N/A<cfelse>#trim(aPermissions[i].PermissionNotes)#</cfif></td>
	</tr></cfloop>
	</table>
	
	<hr />
	
	<ul>
		<li><a href="#cgi.script_name#?bExport=yes">#application.adminBundle[session.dmProfile.locale].exportPermissions#</a></li>
		<li><a href="permissions_import.cfm">#application.adminBundle[session.dmProfile.locale].importPermissions#</a></li>
	</ul>
</cfif></cfoutput>


<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="false">