<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.fieldName" default="ownedBy">
<cfparam name="attributes.fieldlabel" default="Owned By:">
<cfparam name="attributes.selectedValue" default="">
<cfparam name="errormessage" default="">
<cfset objProfile = CreateObject("component","#Application.packagepath#.types.dmProfile")>
<cfset returnstruct = objProfile.fListProfileByPermission("Admin")>
<cfif returnstruct.bSuccess>
	<cfset qList = returnstruct.queryObject>
<cfelse>
	<cfset errormessage = returnstruct.message>
</cfif>

<cfoutput>
<label for="#attributes.fieldName#"><b>#attributes.fieldlabel#</b>
<cfif errormessage NEQ "">
	<input type="hidden" name="#attributes.fieldName#" value="#attributes.selectedValue#"><cfelse>
	<select name="#attributes.fieldName#" id="#attributes.fieldName#"><cfloop query="qList">
		<option value="#qList.objectid#"<cfif qList.objectID EQ attributes.selectedValue> selected="selected"</cfif>><cfif Trim(qList.lastName) EQ "" AND Trim(qList.firstName) EQ "">#qList.username#<cfelse>#qList.lastName#, #qList.firstName#</cfif>
</option></cfloop>
	</select></cfif><br />	
</label></cfoutput>
<cfsetting enablecfoutputonly="false">
