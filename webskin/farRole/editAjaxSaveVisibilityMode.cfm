<cfparam name="form.webtopVisibilityMode" default="">

<cfif len(form.webtopVisibilityMode) AND listFindNoCase("inherit,individual", form.webtopVisibilityMode)>

	<cfset application.fapi.setData(typename="farRole",
							objectid="#stobj.objectid#",
							webtopVisibilityMode="#form.webtopVisibilityMode#",
							bSessionOnly="true")>

	<cfcontent
		reset="true"
		type="application/json"
		variable="#toBinary( toBase64( serializeJSON( application.fapi.success('visibility mode set to #form.webtopVisibilityMode#') ) ) )#"
		/>

<cfelse>

	<cfcontent
		reset="true"
		type="application/json"
		variable="#toBinary( toBase64( serializeJSON( application.fapi.fail('visibility mode not set') ) ) )#"
		/>

</cfif>
