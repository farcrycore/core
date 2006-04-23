<cfsetting enablecfoutputonly="Yes">

<cfif not isDefined("form.submit")>

<cfoutput>
	<br>
	<h3>Import Policy Groups</h3>
	<form action=""
	      method="post"
	      enctype="multipart/form-data"
	      name="importPolicyGroupsForm.cfm"
	      id="importPolicyGroupsForm.cfm"
	      onSubmit="if ( document.all.clearOldPolicyGroups.checked ) return confirm('Are you sure you want to clear all previous PolicyGroups before importing?');">
		
		Filename:  <input type="file" name="filename"><br>
		<input type="checkbox" name="clearOldPolicyGroups" value="off">Clear all PolicyGroups before import<br><br>
		<input type="submit" name="submit" value="Import Data">
	</form>
</cfoutput>

<cfelse>
	
	<cfscript>
		oAuthorisation = request.dmsec.oAuthorisation;
		stPolicyStore = oAuthorisation.getPolicyStore();
	</cfscript>
	
	<cfif isDefined("form.clearOldPolicyGroups")>
		<cfoutput>Deleting old PolicyGroups</cfoutput>

		<cfquery name="qDelete" datasource="#stPolicyStore.datasource#" dbtype="ODBC">
		Delete FROM #application.dbowner#dmPolicyGroup
		</cfquery>
		
		<cfoutput> - complete<bR></cfoutput>
	</cfif>
	
	<cftry>
	<cfquery name="test" datasource="#stPolicyStore.datasource#">
	Set Identity_Insert dmPolicyGroup ON
	</cfquery>
	<cfcatch type="Database">
	</cfcatch>
	</cftry>
	
	<cfoutput>Importing new PolicyGroups</cfoutput>

	<cffile action="UPLOAD" filefield="filename" destination="#application.RootDynamicPHY#" nameconflict="OVERWRITE">
	<cffile action="READ" file="#cffile.serverDirectory#/#cffile.serverFile#" variable="qPolicyGroupsWDDX">
	
	<cfwddx action="WDDX2CFML" input="#qPolicyGroupsWDDX#" output="qPolicyGroups">
	
	<cfloop query="qPolicyGroups">
	
	<cftry>
		<cfscript>
			stObj=structNew();
			stObj.PolicyGroupId=qPolicyGroups.PolicyGroupId;
			stObj.PolicyGroupName=qPolicyGroups.PolicyGroupName;
			stObj.PolicyGroupNotes=qPolicyGroups.PolicyGroupNotes;
			oAuthorisation.createPolicyGroup(PolicyGroupId=qPolicyGroups.PolicyGroupId,PolicyGroupName=qPolicyGroups.PolicyGroupName,PolicyGroupNotes=qPolicyGroups.PolicyGroupNotes);
		</cfscript>
	
		
	<cfcatch type="dmSec">
	</cfcatch>
	</cftry>
		
		
	</cfloop>
<cftry>
	<cfquery name="test" datasource="#stPolicyStore.datasource#">
	Set Identity_Insert dmPolicyGroup OFF
	</cfquery>
	<cfcatch type="Database">
	</cfcatch>
	</cftry>
	
	<cfoutput> - complete<bR></cfoutput>
	
</cfif>

<cfsetting enablecfoutputonly="No">