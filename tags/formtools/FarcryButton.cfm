<cfsetting enablecfoutputonly="yes">

<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>

<cfparam  name="attributes.Type" default="submit">
<cfparam  name="attributes.Value" default="#Attributes.Type#">
<cfparam  name="attributes.Onclick" default="">
<cfparam  name="attributes.Class" default="f-submit">
<cfparam  name="attributes.Style" default="">
<cfparam name="attributes.SelectedObjectID" default="">

<cfif thistag.ExecutionMode EQ "Start">
	<cfif len(attributes.SelectedObjectID)>
		<!--- Include Prototype light in the head --->
		<cfset Request.InHead.PrototypeLite = 1>
		
		<cfset attributes.Onclick = "#attributes.OnClick#;$('SelectedObjectID').value='#attributes.SelectedObjectID#';">
	</cfif>

	<cfoutput><input type="#attributes.Type#" name="FarcryFormSubmitButton" value="#attributes.Value#" onclick="#attributes.Onclick#" class="#attributes.Class#" style="#attributes.Style#" /></cfoutput>
	
</cfif>

<cfif thistag.ExecutionMode EQ "End">
	<!--- Do Nothing --->
</cfif>


<cfsetting enablecfoutputonly="no">