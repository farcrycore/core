<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Job description --->

<cfif len(stObj.description)>
	<cfoutput>#encodeForHTML(stObj.description)#</cfoutput>
<cfelse>
	<cfset methodname = listFirst(listLast(stObj.template, "/"), ".") />
	<cftry>
		<cfset metadata = createobject("component", "farcry.core.packages.coapi.coapiadmin").parseWebskinMetadata(template=methodname, path=stObj.template, lProperties="displayname", lDefaults=methodname) />
		<cfif structKeyExists(metadata, "description")>
			<cfoutput>#metadata.description#</cfoutput>
		</cfif>
		<cfcatch>
			<cfset application.fapi.logEvent("coapi", "warning", "error retrieving template description", {template=stObj.template, error=cfcatch.message}) />
		</cfcatch>
	</cftry>
</cfif>

<cfsetting enablecfoutputonly="false">