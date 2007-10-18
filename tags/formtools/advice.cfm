<cfparam name="attributes.objectid" />
<cfparam name="attributes.field" />
<cfparam name="attributes.message" />
<cfparam name="attributes.value" />
<cfparam name="attributes.class" default="validation-advice" />

<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>


<cfif thistag.ExecutionMode EQ "End">

	<cfset stResult=structnew()>
	<cfset stResult.value = attributes.value />
	<cfset stResult.bSuccess = false />
	<cfset stResult.stError = structNew() />
	<cfset stResult.stError.message = HTMLEditFormat(attributes.message) />
	<cfset stResult.stError.class = attributes.class />
	<cfset request.stFarcryFormValidation["#attributes.objectid#"][attributes.field] = stResult />

</cfif>