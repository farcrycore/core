<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="fatalErrorMessage" default=""> <!--- fatal [ie something wrong with the db and page cant render] --->
<cfparam name="errorMessage" default=""> <!--- normal error [ie server side validation] --->
<cfparam name="bFormSubmitted" default="no">
<!--- default all form variables --->
<cfparam name="objectID" default="0">
<cfparam name="name" default="">
<cfparam name="notes" default="">
<cfparam name="bCopy" default="0">
<cfparam name="mode" default="Create">
<cfparam name="sourcePolicyGroupID" default="">
<!--- create object specific for this page --->
<cfset editObject = request.dmsec.oAuthorisation>
<cfset aPolicyGroup = editObject.getAllPolicyGroups()>
<cfif bFormSubmitted EQ "yes">
	<!--- TODO: may want to dop some validation before commiting to database [ie make sure fields check] --->
	<cfset stForm = StructNew()>
	<cfset stForm.name = trim(name)>
	<cfset stForm.notes = trim(notes)>
	<cfset stForm.sourcePolicyGroupID = trim(sourcePolicyGroupID)>

	<!--- check out what action to take --->
	<cfif isDefined("form.delete")>
		<cfset returnstruct = editObject.deletePolicyGroup(policygroupid=objectID)>

	<cfelseif isDefined("form.insert")>
		<cfset returnstruct = editObject.createPolicyGroup(policyGroupName=name,policyGroupNotes=notes)>

	<cfelseif isDefined("form.copy")>
		<cfset returnstruct = editObject.copyPolicyGroup(stForm)>

	<cfelse>
		<cfset returnstruct = editObject.updatePolicyGroup(policyGroupID=objectID,policyGroupName=name,policyGroupNotes=notes)>
	</cfif>

	<cfif returnstruct.returncode EQ 1>
		<cflocation url="groups.cfm" addtoken="false">
		<cfabort>
	<cfelse>
		<cfset errorMessage = returnstruct.returnmessage>
	</cfif>
<cfelseif objectID NEQ 0> <!--- if valid id passed in then must be in edit mode .: retrieve data --->
	<!--- TODO: should be some error trapping in the oAuthorisation object as to indicate to the calling page if the operation is a success or failure .: displaying approipiate errormessage [instead of dying bad] --->
	<cfset returnstruct = editObject.getPolicyGroup(policyGroupID=objectID)>
	<cfif NOT StructIsEmpty(returnstruct)>
		<cfset name = returnstruct.policyGroupName>
		<cfset notes = returnstruct.policyGroupNotes>
		<cfset objectID = returnstruct.policyGroupID>
	<cfelse> <!--- fatal error .: record does not exist --->
		<cfset fatalErrorMessage = fatalErrorMessage & "Sorry the policy group id [#objectID#] does not exist.">
	</cfif>
</cfif>

<cfif objectID NEQ 0>
	<cfset mode = "Edit">
<cfelseif bCopy NEQ 0>
	<cfset mode = "Copy">
</cfif>

<!--- check permissions --->
<cfset iSecurityTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="SecurityPolicyManagementTab")>

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iSecurityTab EQ 0>
	<admin:permissionError>
<cfelse><cfoutput>
	<cfif fatalErrorMessage NEQ ""> <!--- if fatal error occurs then show error and dont render the page --->
	<h3 id="fading1" class="fade"><span class="error">Error</span>: #fatalErrorMessage#</h3>
	<cfelse>
		<cfif errorMessage NEQ ""> <!--- display any non critical error [eg form validation] --->
	<h3 id="fading2" class="fade"><span class="error">Error</span>: #errorMessage#</h3>
		</cfif>
<form name="frm" method="post" class="f-wrap-1 f-bg-medium wider" action="#cgi.script_name#">
<fieldset>
	<h3>#mode# Policy Group</h3>
	<input type="hidden" name="UserId" value="-1" /> 
	<cfif mode EQ "Copy">
	<label for="sourcePolicyGroupID"><b>Source Policy Group:</b>
	<select name="sourcePolicyGroupID" id="sourcePolicyGroupID" class="formselectlist"><cfloop from="1" to="#ArrayLen(aPolicyGroup)#" index="i">
		<option value="#aPolicyGroup[i].policyGroupID#"<cfif sourcePolicyGroupID EQ aPolicyGroup[i].policyGroupID>selected="selected"</cfif>>#aPolicyGroup[i].policyGroupName#</option></cfloop>
	</select><br />
	</label>	
	</cfif>

	<label for="name"><b>Policy Group Name:</b>
	<input type="text" id="name" name="name" value="#name#" /><br />
	</label>	
	
	<label for="notes"><b>Policy Group Notes:</b>
	<textarea name="notes" id="notes" rows="5" cols="30">#notes#</textarea><br />	
	</label>	

	<div class="f-submit-wrap"><cfif objectID EQ 0><cfif bCopy EQ 0>
	<input type="submit" name="Insert" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].createPolicyGroup#" /><cfelse>
	<input type="submit" name="Copy" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].copyPolicyGroup#" /></cfif><cfelse>
	<input type="submit" name="Update" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].updatePolicyGroup#" />
	<input type="submit" name="Delete" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].deletePolicyGroup#" onclick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmPolicyGroupDelete#');"></cfif>
	</div>
	<input type="hidden" name="objectID" value="#objectID#" />
	<input type="hidden" name="bFormSubmitted" value="yes" />
	<input type="hidden" name="bCopy" value="#bCopy#" />
</fieldset>
</form>
	</cfif></cfoutput>
</cfif>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="false">