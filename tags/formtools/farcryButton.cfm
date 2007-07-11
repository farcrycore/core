<cfsetting enablecfoutputonly="yes">

<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>

<cfparam  name="attributes.Type" default="submit">
<cfparam  name="attributes.Value" default="#Attributes.Type#">
<cfparam  name="attributes.Onclick" default="">
<cfparam  name="attributes.Class" default="">
<cfparam  name="attributes.Style" default="">
<cfparam name="attributes.SelectedObjectID" default="">
<cfparam name="attributes.ConfirmText" default="">
<cfparam name="attributes.validate" default="true">




<cfif thistag.ExecutionMode EQ "Start">

	<!--- Include Prototype light in the head --->
	<cfset Request.InHead.PrototypeLite = 1>
	
	<cfif len(attributes.SelectedObjectID)>		
		<cfset attributes.Onclick = "#attributes.OnClick#;$('SelectedObjectID#Request.farcryForm.Name#').value='#attributes.SelectedObjectID#';">
	</cfif>
	
	<cfif len(Attributes.ConfirmText)>
		<!--- Confirm the click before submitting --->
		<cfset attributes.OnClick = "#attributes.OnClick#;if(confirm('#Attributes.ConfirmText#')) {dummyconfirmvalue=1} else {return false};">
	</cfif>	
	 
	
	<cfset attributes.onClick = "#attributes.onClick#;$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value = '#attributes.Value#';">


	
	<cfif Request.farcryForm.Validation AND Attributes.validate>
		<!--- Confirm the click before submitting --->
		<cfset attributes.OnClick = "#attributes.OnClick#;return realeasyvalidation#Request.farcryForm.Name#.validate();">
		
		
		
	</cfif>	
	

	<cfoutput><input type="#attributes.Type#" name="FarcryFormSubmitButton" value="#attributes.Value#" onclick="#attributes.Onclick#" class="formButton #attributes.Class#" style="#attributes.Style#" /></cfoutput>
</cfif>

<cfif thistag.ExecutionMode EQ "End">
	<!--- Do Nothing --->
</cfif>


<cfsetting enablecfoutputonly="no">