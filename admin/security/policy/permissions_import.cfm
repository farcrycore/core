<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="fatalErrorMessage" default=""> <!--- fatal [ie something wrong with the db and page cant render] --->
<cfparam name="errorMessage" default=""> <!--- normal error [ie server side validation] --->
<cfparam name="completionMessage" default="">
<cfparam name="bFormSubmitted" default="no">
<cfparam name="clearOldPermissions" default="0">

<cfif bFormSubmitted EQ "yes">
	<cfset stForm = StructNew()>
	<!--- server side validation of form varaiables before passing to components --->
	<cfif trim(filename) EQ "">
		<cfset errorMessage = "Please select a file to import from.">
	<cfelse>
		<cfset stForm.filename = trim(filename)>
	</cfif>
	<cfset stForm.fileFieldName = "filename">
	<cfset stForm.clearOldPermissions = trim(clearOldPermissions)>

	<cfif errorMessage EQ "">
		<cfset oAuthorisation = request.dmsec.oAuthorisation>
		<cfset stPolicyStore = oAuthorisation.getPolicyStore()>

		<cfset temp_path = ListDeleteAt(cgi.cf_template_path,listLen(cgi.cf_template_path,"\"),"\") & "\">
		<cffile action="UPLOAD" filefield="#stForm.fileFieldName#" destination="#temp_path#" nameconflict="OVERWRITE">
		<cffile action="READ" file="#cffile.serverDirectory#/#cffile.serverFile#" variable="qPermissionsWDDX">
		<cffile action="delete" file="#cffile.serverDirectory#/#cffile.serverFile#">
		<cfwddx action="WDDX2CFML" input="#qPermissionsWDDX#" output="qPermissions">

		<cfif stForm.clearOldPermissions EQ 1> <!--- delete existing records --->
			<cfset completionMessage = completionMessage & application.adminBundle[session.dmProfile.locale].deletingOldPolicyGroups & "<br />">
	
			<cfquery name="qDelete" datasource="#stPolicyStore.datasource#" dbtype="ODBC">
			DELETE FROM #application.dbowner#dmPermission
			</cfquery>

			<cfset completionMessage = completionMessage & application.adminBundle[session.dmProfile.locale].complete & "<br />">
		</cfif>		
		
		<cftry>
			<cfquery name="qInsertIdentityOn" datasource="#stPolicyStore.datasource#">
			SET Identity_Insert dmPermission ON
			</cfquery>
			<cfcatch> <!--- ignore --->
			</cfcatch>
		</cftry>
		
		<cftry>

			<cfloop query="qPermissions">
				<cfset stObject = StructNew()>
				<cfset stObject.permissionID = qPermissions.permissionID>
				<cfset stObject.permissionName = qPermissions.permissionName>
				<cfset stObject.permissionType = qPermissions.permissionType>
				<cfset stObject.permissionNotes = qPermissions.permissionNotes>
			
				<cfquery name="qCheck" datasource="#stPolicyStore.datasource#">
				SELECT	permissionID, permissionName FROM dmPermission WHERE permissionID = #stObject.permissionID#
				</cfquery>
			
				<cfif qCheck.recordcount EQ 0>
					<cfset returnstruct = oAuthorisation.createPermission(PermissionId=stObject.permissionID,PermissionName=stObject.permissionName,PermissionNotes=stObject.permissionNotes,PermissionType=stObject.permissionType)>
					<cfif returnstruct.returncode EQ 0>
						<cfset errorMessage = errorMessage & returnstruct.returnmessage>
					</cfif>
				<cfelse>
					<cfset errorMessage = errorMessage & "Permission with ID [#stObject.permissionID#] already exist in the database. <br />">
				</cfif>
			</cfloop>
			
			<cfcatch type="any">
				<cfset errorMessage = errorMessage & "Sorry a Database error has occurred [#cfcatch.detail#]. <br />">				
			</cfcatch>
		</cftry>

		<cftry>
			<cfquery name="qInsertIdentityOff" datasource="#stPolicyStore.datasource#">
			SET Identity_Insert dmPermission OFF
			</cfquery>
			<cfcatch> <!--- ignore --->
			</cfcatch>
		</cftry>
		<cfset completionMessage = completionMessage & "Policy Group imported successfully. <br />">		
	</cfif>
</cfif>

<!--- check permissions --->
<cfset iSecurityTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="SecurityPolicyManagementTab")>

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
<cfoutput><script type="text/javascript">
function doSubmit(objForm){
	if(objForm.clearOldPolicyGroups.checked)
		return confirm('#application.adminBundle[session.dmProfile.locale].confrmClearPolicyGroups#')
	else
		return true;
}
</script></cfoutput>

<cfif iSecurityTab EQ 0>
	<admin:permissionError>
<cfelse><cfoutput>
	<h3>Import Policy Permissions</h3>
	
	<cfif fatalErrorMessage NEQ ""> <!--- if fatal error occurs then show error and dont render the page --->
	<h3 id="fading2" class="fade"><span class="error">Error</span>: #fatalErrorMessage#</h3>
	<cfelseif completionMessage NEQ "" AND errorMessage EQ ""> <!--- import a succes --->
	<h3 id="fading2" class="fade"><span class="success">Success</span>: #completionMessage#</span></h3>
	<cfelse> <!--- first entry to form or error occured --->
		<cfif errorMessage NEQ ""> <!--- display any non critical error [eg form validation] --->
	<h3 id="fading2" class="fade"><span class="error">Error</span>: #errorMessage#</h3>
		</cfif>
<form name="frm" method="post" class="f-wrap-1 f-bg-medium wider" action="#cgi.script_name#" enctype="multipart/form-data" onSubmit="return doSubmit(this);">
<fieldset>
	<label for="filename"><b>#application.adminBundle[session.dmProfile.locale].filenameLabel#</b>
	<input type="file" id="filename" name="filename" />
	</label>
	
	<label for="clearOldPermissions"><b>Clear original Permissions before Import</b>
	<input type="checkbox" name="clearOldPermissions" id="clearOldPermissions" value="1">
	</label>
	<input type="submit" name="Import" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].importData#" />
	<input type="hidden" name="bFormSubmitted" value="yes" />
</fieldset>
</form>
	</cfif></cfoutput>
</cfif>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="false">