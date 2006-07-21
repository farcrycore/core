
<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>


<cfif thistag.ExecutionMode EQ "Start">
	
	<cfparam name="attributes.action" default="*" >
	<cfparam name="attributes.excludeAction" default="" >
	
	<cfset variables.EnterFormProcess = false>
	
	<cfif isDefined("FORM.FarcryFormSubmitButton") AND len(FORM.FarcryFormSubmitButton)>

		<cfif listFindNoCase(attributes.action,FORM.FarcryFormSubmitButton) OR attributes.action EQ "*">
			<cfif NOT listFindNoCase(attributes.excludeAction,FORM.FarcryFormSubmitButton)>
				<cfset variables.EnterFormProcess = true />
			</cfif>
		</cfif>

	</cfif>

	<cfif NOT variables.EnterFormProcess>
		<cfexit>
	</cfif>

</cfif>


<cfif thistag.ExecutionMode EQ "End">
	<cfif isDefined("attributes.URL")>
		<cfif attributes.URL EQ "reload">
			<cflocation url="#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#" addtoken="false">
		<cfelse>
			<cflocation url="#attributes.URL#" addtoken="false">
		</cfif>
		
	</cfif>
</cfif>