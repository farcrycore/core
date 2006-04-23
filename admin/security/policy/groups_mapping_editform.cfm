<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="fatalErrorMessage" default=""> <!--- fatal [ie something wrong with the db and page cant render] --->
<cfparam name="errorMessage" default=""> <!--- normal error [ie server side validation] --->
<!--- default all form variables --->
<cfparam name="completionMessage" default=""> <!--- normal error [ie server side validation] --->

<cfset oAuthentication = request.dmsec.oAuthentication>
<cfset stUD = oAuthentication.getUserDirectory()>
<cfset oAuthorisation = request.dmsec.oAuthorisation>
<cfset aUserDirectoryKey = StructKeyArray(stUD)>
<!--- just default to the first directory --->
<cfparam name="userDirectory" default="#aUserDirectoryKey[1]#">
<cfparam name="groupName" default="">
<cfparam name="policyGroupID" default="0">

<cfset aGroups = oAuthentication.getMultipleGroups(userDirectory=userDirectory)>
<cfset aPolicyGroups = oAuthorisation.getAllPolicyGroups()>

<cfif isDefined("Submit")>
	<cfset returnstruct = oAuthorisation.createPolicyGroupMapping(groupname="#form.groupName#",userdirectory="#form.userdirectory#",policyGroupId="#form.policyGroupId#")>
	<cfif returnstruct.returncode EQ 1>
		<cfset completionMessage = returnstruct.returnmessage>
	<cfelse>
		<cfset errorMessage = returnstruct.returnmessage>
	</cfif>
</cfif>

<cfimport taglib="/farcry/farcry_core/tags/security/ui/" prefix="dmsec">
<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
<cfoutput>

<cfif fatalErrorMessage NEQ ""> <!--- if fatal error occurs then show error and dont render the page --->
<h3 id="fading1" class="fade"><span class="error">Error</span>: #fatalErrorMessage#</h3>
<cfelse>
	<cfif completionMessage NEQ ""> <!--- display any non critical error [eg form validation] --->
<h3 id="fading2" class="fade"><span class="success">Success</span>: #completionMessage#</h3>	
	<cfelse>
		<cfif errorMessage NEQ "">
<h3 id="fading2" class="fade"><span class="error">Error</span>: #errorMessage#</h3>
		</cfif>
<form name="frm" method="post" class="f-wrap-1 f-bg-medium wider" action="#cgi.script_name#">
<fieldset>

	<h3>#application.adminBundle[session.dmProfile.locale].mapAPolicyGroup#</h3>
	
	<label for="userDirectory"><b>#application.adminBundle[session.dmProfile.locale].selectUserDirLabel#</b>
	<select name="userDirectory" id="userDirectory" class="formselectlist" onchange="this.form.submit();"><cfloop item="ud" collection="#stUD#">
		<option value="#ud#"<cfif userDirectory EQ ud> selected="selected"</cfif>>#ud#</option></cfloop>		
	</select><br />
	</label>

	<label for="groupName"><b>#application.adminBundle[session.dmProfile.locale].selectExternalGroupLabel#</b>
	<select name="groupName" id="groupName" class="formselectlist"><cfloop index="i" from="1" to="#ArrayLen(aGroups)#">
		<option value="#aGroups[i].groupName#"<cfif groupName EQ aGroups[i].groupName> selected="selected"</cfif>>#aGroups[i].groupName#</option></cfloop>
	</select><br />
	</label>

	<label for="policyGroupID"><b>#application.adminBundle[session.dmProfile.locale].selectPolicyGroupLabel#</b>
	<select name="policyGroupID" id="policyGroupID" class="formselectlist"><cfloop index="i" from="1" to="#ArrayLen(aPolicyGroups)#">
		<option value="#aPolicyGroups[i].policyGroupID#"<cfif policyGroupID EQ aPolicyGroups[i].policyGroupID> selected="selected"</cfif>>#aPolicyGroups[i].policyGroupName#</option></cfloop>
	</select><br />

	<div class="f-submit-wrap">
		<input type="submit" name="Submit" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].mapGroup#" />
	</div>
	
</fieldset>
</form>
	</cfif>
</cfif></cfoutput>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="false">