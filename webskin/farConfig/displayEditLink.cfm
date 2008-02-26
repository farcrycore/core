<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit link --->

<cfoutput>
	<a href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&typename=farConfig&method=edit&ref=typeadmin&module=customlists/farConfig.cfm">#stObj.configkey#</a>
</cfoutput>

<cfsetting enablecfoutputonly="false" />