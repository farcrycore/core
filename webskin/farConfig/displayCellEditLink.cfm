<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit link --->

<cfset formname = getForm(key=stObj.configkey) />
<cfset title = stObj.configkey />

<cfif len(formname) and structkeyexists(application.stCOAPI[formname],"displayname")>
	<cfset title = application.stCOAPI[formname].displayname />
</cfif>

<cfoutput>
	<a href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&typename=farConfig&method=edit&ref=typeadmin&module=customlists/farConfig.cfm">#title#</a>
</cfoutput>

<cfsetting enablecfoutputonly="false" />