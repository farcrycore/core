
<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>


<cfif thistag.ExecutionMode EQ "Start">
	
	<cfparam name="attributes.action" default="*" >
	<cfset variables.EnterFormProcess = false>
	
	<cfif isDefined("FORM.FarcryFormSubmitButton") AND len(FORM.FarcryFormSubmitButton)>
		<cfloop list="#attributes.action#" index="i">
			<cfif listFindNoCase(FORM.FarcryFormSubmitButton,i) OR i EQ "*">
				<cfset variables.EnterFormProcess = true>
			</cfif>
		</cfloop>
	</cfif>

	<cfif NOT variables.EnterFormProcess>
		<cfexit>
	</cfif>

</cfif>


<cfif thistag.ExecutionMode EQ "End">
	<cfif isDefined("attributes.URL")>
		<cflocation url="#attributes.URL#" addtoken="false">
	</cfif>
</cfif>