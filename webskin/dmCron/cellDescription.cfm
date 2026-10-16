<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Job description --->

<cfif len(stObj.description)>
	<cfoutput>#stObj.description#</cfoutput>
<cfelse>
	<cfset methodname = listFirst(listLast(stObj.template, "/"), ".") />
	<cftry>
		<cfset metadata = createobject("component", "farcry.core.packages.coapi.coapiadmin").parseWebskinMetadata(template=methodname, path=stObj.template, lProperties="displayname", lDefaults=methodname) />
		<cfif structKeyExists(metadata, "description")>
			<cfoutput>#metadata.description#</cfoutput>
		</cfif>
		<cfcatch>
			<cflog log="exception" type="error"	text="Error retrieving description for template [#stObj.template#].">
		</cfcatch>
	</cftry>
</cfif>

<cfsetting enablecfoutputonly="false">