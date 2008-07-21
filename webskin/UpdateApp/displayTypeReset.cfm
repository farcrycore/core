<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: AJAX interface --->

<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />

<cftry>
	<cfif request.mode.bAdmin OR (structkeyexists(url,"key") and url.key eq application.updateappKey) OR (structkeyexists(form,"key") and form.key eq application.updateappKey)>
		<cfset structappend(form,url,false) /><!--- If resets are being passed in via URL, copy them to form scope --->
		
		<!--- Convert "on" to true and "off" to false --->
		<cfloop collection="#form#" item="field">
			<cfif form[field] eq "on">
				<cfset form[field] = true />
			</cfif>
			<cfif form[field] eq "off">
				<cfset form[field] = false />
			</cfif>
		</cfloop>
		
		<cfset process(form) /><!--- Do normal processing on the passed in form --->
		
		<cfset results = "" />
		<extjs:bubbleOutput>
			<cfset results = listappend(results,'{ index: #index#, title: "#jsstringformat(bubble.title)#", message: "#jsstringformat(bubble.message)#" }') />
		</extjs:bubbleOutput>
		
		<cfoutput>{ results: [ #results# ], success: true, errors: [] }</cfoutput>
	<cfelse>
		<cfoutput>{ results: [ ], success: false, errors: [ "You have not provided the valid key" ] }</cfoutput>
	</cfif>

	<cfcatch>
		<cfoutput>{ results: [ ], success: false, errors: [ "#jsstringformat(cfcatch.message)#" ] }</cfoutput>
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="false" />