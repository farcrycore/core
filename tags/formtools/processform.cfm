
<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>


<cfif thistag.ExecutionMode EQ "Start">

	<cfparam name="attributes.action" default="*" >

	<cfif isDefined("FORM.FarcryFormSubmitButton") AND len(FORM.FarcryFormSubmitButton) AND (listFindNoCase(attributes.action, FORM.FarcryFormSubmitButton) OR attributes.action EQ "*")>

	<cfelse>
		<cfexit>
	</cfif>


</cfif>


<cfif thistag.ExecutionMode EQ "End">
	<cfif isDefined("attributes.URL")>
		<cflocation url="#attributes.URL#">
	</cfif>
</cfif>