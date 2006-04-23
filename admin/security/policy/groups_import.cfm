<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="fatalErrorMessage" default=""> <!--- fatal [ie something wrong with the db and page cant render] --->
<cfparam name="errorMessage" default=""> <!--- normal error [ie server side validation] --->
<cfparam name="bFormSubmitted" default="no">
<cfparam name="clearOldPolicyGroups" default="0">
<cfparam name="completionMessage" default="">

<cfif bFormSubmitted EQ "yes">
	<cfset stForm = StructNew()>
	<!--- server side validation of form varaiables before passing to components --->
	<cfif trim(filename) EQ "">
		<cfset errorMessage = "Please select a file to import from.">
	<cfelse>
		<cfset stForm.filename = trim(filename)>
	</cfif>
	<cfset stForm.fileFieldName = "filename">
	<cfset stForm.clearOldPolicyGroups = trim(clearOldPolicyGroups)>

	<cfif errorMessage EQ "">
		<cfset oAuthorisation = request.dmsec.oAuthorisation>
		<cfset stPolicyStore = oAuthorisation.getPolicyStore()>

		<cfset temp_path = ListDeleteAt(cgi.cf_template_path,listLen(cgi.cf_template_path,"\"),"\") & "\">
		<cffile action="UPLOAD" filefield="#stForm.fileFieldName#" destination="#temp_path#" nameconflict="OVERWRITE">
		<cffile action="READ" file="#cffile.serverDirectory#/#cffile.serverFile#" variable="qPolicyGroupsWDDX">
		<cffile action="delete" file="#cffile.serverDirectory#/#cffile.serverFile#">
		<cfwddx action="WDDX2CFML" input="#qPolicyGroupsWDDX#" output="qPolicyGroups">

		<cfif stForm.clearOldPolicyGroups EQ 1> <!--- delete existing records --->
			<cfset completionMessage = completionMessage & application.adminBundle[session.dmProfile.locale].deletingOldPolicyGroups & "<br />">
	
			<cfquery name="qDelete" datasource="#stPolicyStore.datasource#" dbtype="ODBC">
			DELETE FROM #application.dbowner#dmPolicyGroup
			</cfquery>

			<cfset completionMessage = completionMessage & application.adminBundle[session.dmProfile.locale].complete & "<br />">
		</cfif>
		

		<cftry>

			<cfloop query="qPolicyGroups">
				<cfset stObject = StructNew()>
				<cfset stObject.policyGroupID = qPolicyGroups.policyGroupID>
				<cfset stObject.policyGroupName = qPolicyGroups.policyGroupName>
				<cfset stObject.policyGroupNotes = qPolicyGroups.policyGroupNotes>
			
				<cfquery name="qCheck" datasource="#stPolicyStore.datasource#">
				SELECT	policyGroupID, policyGroupname FROM dmPolicyGroup WHERE policyGroupID = #stObject.policyGroupID#
				</cfquery>
			
				<cfif qCheck.recordcount EQ 0>
					<cfset oAuthorisation.createPolicyGroup(PolicyGroupId=stObject.policyGroupId,PolicyGroupName=stObject.policyGroupName,PolicyGroupNotes=stObject.policyGroupNotes)>
				<cfelse>
					<cfset errorMessage = errorMessage & "Policy Group #stObject.policyGroupName# could not be added because the Policy group ID [#stObject.policyGroupId#] already exist in the database. <br />">
					<!--- <cfset oAuthorisation.updatePolicyGroup(PolicyGroupId=stObject.policyGroupId,PolicyGroupName=stObject.policyGroupName,PolicyGroupNotes=stObject.policyGroupNotes)> --->
				</cfif>
			</cfloop>
			
			<cfcatch type="any">
			
			</cfcatch>
		</cftry>

		<cftry>
			<cfquery name="qInsertIdentityOff" datasource="#stPolicyStore.datasource#">
			SET Identity_Insert dmPolicyGroup OFF
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
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">

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
	<h3>Import Policy Groups</h3>
	
	<cfif fatalErrorMessage NEQ ""> <!--- if fatal error occurs then show error and dont render the page --->
	<h3 id="fading2" class="fade"><span class="error">Error</span>: #fatalErrorMessage#</h3>
	<cfelseif completionMessage NEQ "" AND errorMessage EQ ""> <!--- import a succes --->
	<h3 id="fading2" class="fade">#completionMessage#</h3>
	<cfelse> <!--- first entry to form or error occured --->
		<cfif errorMessage NEQ ""> <!--- display any non critical error [eg form validation] --->
	<h3 id="fading2" class="fade"><span class="error">Error</span>: #errorMessage#</h3>
		</cfif>
<form name="frm" method="post" class="f-wrap-1 f-bg-medium wider" action="#cgi.script_name#" enctype="multipart/form-data" onSubmit="return doSubmit(this);">
<fieldset>
	<label for="filename"><b>#application.adminBundle[session.dmProfile.locale].filenameLabel#</b>
	<input type="file" id="filename" name="filename" />
	</label>
	
	<label for="clearOldPolicyGroups"><b>#application.adminBundle[session.dmProfile.locale].clearAllPolicyGroupsBeforeImport#</b>
	<input type="checkbox" name="clearOldPolicyGroups" id="clearOldPolicyGroups" value="1">
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