<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="fatalErrorMessage" default=""> <!--- fatal [ie something wrong with the db and page cant render] --->
<cfparam name="errorMessage" default=""> <!--- normal error [ie server side validation] --->
<cfparam name="bFormSubmitted" default="no">
<!--- default all form variables --->
<cfparam name="objectID" default="0"> <!--- primary identifier --->
<cfparam name="name" default="">
<cfparam name="notes" default="">
<cfparam name="permissionType" default="">

<!--- create object specific for this page --->
<cfset editObject = request.dmsec.oAuthorisation>

<cfif bFormSubmitted EQ "yes">
	<!--- TODO: may want to dop some validation before commiting to database [ie make sure fields check] --->
	<cfset stForm = StructNew()>
	<cfset stForm.objectID = objectID>
	<cfif trim(name) EQ "">
		<cfset errormessage = errormessage & "Please enter a Permission Name.<br />">
	<cfelse>
		<cfset stForm.name = trim(name)>
	</cfif>

	<cfif trim(name) EQ "">
		<cfset errormessage = errormessage & "Please enter a Permission Type.<br />">
	<cfelse>
		<cfset stForm.permissionType = trim(permissionType)>
	</cfif>
	
	<cfset stForm.notes = trim(notes)>
			
	<!--- check out what action to take --->
	<cfif isDefined("form.delete")>

		<cfset returnstruct = editObject.deletePermission(permissionid=stForm.objectID)>
	<cfelseif isDefined("form.insert")>
		<cfset returnstruct = editObject.createPermission(permissionname=stForm.name,permissiontype=stForm.permissiontype,permissionnotes=stForm.notes)>
	<cfelse>
		<cfset returnstruct = editObject.updatePermission(permissionid=stForm.objectID,permissionname=stForm.name,permissiontype=stForm.permissiontype,permissionnotes=stForm.notes)>
	</cfif>

	<cfif returnstruct.returncode EQ 1>
		<cflocation url="permissions.cfm" addtoken="false">
		<cfabort>
	<cfelse>
		<cfset errorMessage = returnstruct.returnmessage>
	</cfif>
<cfelseif objectID NEQ 0 OR name NEQ ""> <!--- if valid id passed in then must be in edit mode .: retrieve data --->
	<!--- TODO: should be some error trapping in the oAuthorisation object as to indicate to the calling page if the operation is a success or failure .: displaying approipiate errormessage [instead of dying bad] --->
	<cfif objectID NEQ 0>
		<cfset returnstruct = editObject.getPermission(permissionID=objectID)>
	<cfelse>
		<cfset returnstruct = editObject.getPermission(permissionName="#name#")>
	</cfif>			

	<cfif NOT StructIsEmpty(returnstruct)>
		<cfset objectID = returnstruct.permissionID>
		<cfset name = returnstruct.permissionName>
		<cfset notes = returnstruct.permissionNotes>
		<cfset permissionType = returnstruct.permissionType>
	<cfelse> <!--- fatal error .: record does not exist --->
		<cfset fatalErrorMessage = fatalErrorMessage & "Sorry the Permission id [#objectID#] OR Permission name [#name#] does not exist.">
	</cfif>
</cfif>

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfoutput>
<cfif fatalErrorMessage NEQ ""> <!--- if fatal error occurs then show error and dont render the page --->
<h3 id="fading1" class="fade"><span class="error">Error</span>: #fatalErrorMessage#</h3>
<cfelse>
	<cfif errorMessage NEQ ""> <!--- display any non critical error [eg form validation] --->
<h3 id="fading2" class="fade"><span class="error">Error</span>: #errorMessage#</h3>
	</cfif>
<form name="frm" method="post" class="f-wrap-1 f-bg-medium wider" action="#cgi.script_name#">
<fieldset><cfif objectID EQ 0>
<h3>#application.adminBundle[session.dmProfile.locale].createPermission#</h3><cfelse>
<h3>#application.adminBundle[session.dmProfile.locale].updatePermission#</h3></cfif>
<label for="name"><b>Permission Name:</b>
	<input type="text" id="name" name="name" value="#name#" /><br />
</label>

<label for="notes"><b>Permission Notes:</b>
	<textarea name="notes" id="notes" rows="5" cols="30">#notes#</textarea><br />
</label>

<label for="permissionType"><b>Permission Type:</b>
	<input type="text" id="permissionType" name="permissionType" value="#permissionType#" /><br />
</label>
	
<div class="f-submit-wrap"><cfif objectID EQ 0>
	<input type="submit" name="Insert" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].createPermission#" /><cfelse>
	<input type="submit" name="Update" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].updatePermission#" />
	<input type="submit" name="Delete" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].deletePermission#" onclick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmDeletePermission#');"></cfif>
</div>
	<input type="hidden" name="objectID" value="#objectID#" />
	<input type="hidden" name="bFormSubmitted" value="yes" />
</fieldset>
</form>
</cfif></cfoutput>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="false">