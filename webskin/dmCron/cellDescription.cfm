<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Job description --->

<cfif len(stObj.description)>
	<cfoutput>#stObj.description#</cfoutput>
<cfelse>
	<cfset methodname = listFirst(listLast(stObj.template, "/"), ".") />
	<cfset metadata = createobject("component", "farcry.core.packages.coapi.coapiadmin").parseWebskinMetadata(template=methodname, path=stObj.template, lProperties="displayname", lDefaults=methodname) />
	<cfif structKeyExists(metadata, "description")>
		<cfoutput>#metadata.description#</cfoutput>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false">