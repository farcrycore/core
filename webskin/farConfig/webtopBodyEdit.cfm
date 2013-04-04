<cfsetting enablecfoutputonly="true" />

<cfparam name="url.key" />

<cfset q = application.fapi.getContentObjects(typename="farConfig",configkey_eq=url.key) />

<cfif q.recordcount>
	<cfoutput>#edit(objectid=q.objectid)#</cfoutput>
<cfelse>
	<cfoutput><div class="alert alert-error">The specified config does not exist</div></cfoutput>
</cfif>

<cfsetting enablecfoutputonly="true" />