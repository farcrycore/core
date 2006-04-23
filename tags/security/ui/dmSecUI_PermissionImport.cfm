<cfsetting enablecfoutputonly="Yes">

<cfif not isDefined("form.submit")>

<cfoutput>
	<br>
	<span class="formtitle">Import Permissions</span><p></p>
	<form
		name="importPermissionsForm.cfm"
		action=""
		method="Post"
		enctype="multipart/form-data"
		onSubmit="if ( document.all.clearOldPermissions.checked ) return confirm('Are you sure you want to clear all previous permissions before importing?');">
		<table class="formtable">
		<tr>
			<td rowspan="10">&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>
			<span class="formlabel">Filename:</span>  <input type="file" name="filename"><p>
			<input type="checkbox" name="clearOldPermissions">Clear all permissions before import<br><br>
			<input type="submit" name="submit" value="Import Data">
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		</table>
		
	</form>
</cfoutput>

<cfelse>
	<cfscript>
		oAuthorisation = request.dmsec.oAuthorisation;
		stPolicyStore = oAuthorisation.getPolicyStore();
	</cfscript>
	
	
	<cfif isDefined("form.clearOldPermissions")>
		<cfoutput>Deleting old permissions</cfoutput>

		<cfquery name="qDelete" datasource="#stPolicyStore.datasource#" dbtype="ODBC">
		DELETE FROM #application.dbowner#dmPermission
		</cfquery>
		
		<cfoutput> - complete<bR></cfoutput>
	</cfif>
	
	<cfoutput>Importing new permissions</cfoutput>
	
	<cffile action="UPLOAD" filefield="filename" destination="#application.path.project#/" nameconflict="OVERWRITE">
	<cffile action="READ" file="#cffile.serverDirectory#/#cffile.serverFile#" variable="qPermissionsWDDX">
	
	<cfwddx action="WDDX2CFML" input="#qPermissionsWDDX#" output="qPermissions">
	
	<cftry>
	<cfquery name="test" datasource="#stPolicyStore.datasource#">
	Set Identity_Insert dmPermission ON
	</cfquery>
	<cfcatch type="Database">
	</cfcatch>
	</cftry>
	
	<cfloop query="qPermissions">
	
	<cftry>
		<cfscript>
			stObj=structNew();
			stObj.PermissionId=qPermissions.PermissionId;
			stObj.PermissionName=qPermissions.PermissionName;
			stObj.PermissionNotes=qPermissions.PermissionNotes;
			stObj.PermissionType=qPermissions.PermissionType;
		</cfscript>
		
		<cfscript>
			oAuthorisation.createPermission(PermissionId=qPermissions.PermissionId,PermissionName=qPermissions.PermissionName,PermissionNotes=qPermissions.PermissionNotes,PermissionType=qPermissions.PermissionType);
		</cfscript>
			
		
	<cfcatch type="dmSec">
	</cfcatch>
	</cftry>
		
		
	</cfloop>
	
	<cftry>
	<cfquery name="test" datasource="#stPolicyStore.datasource#">
	Set Identity_Insert dmPermission OFF
	</cfquery>
	<cfcatch type="Database">
	</cfcatch>
	</cftry>

	
	<cfoutput> - complete<bR></cfoutput>
	
</cfif>

<cfsetting enablecfoutputonly="No">