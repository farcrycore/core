<cfsetting enablecfoutputonly="true" />

<cfparam name="url.key" />

<cfset q = application.fapi.getContentObjects(typename="farConfig",lProperties="objectid,configtypename",configkey_eq=url.key) />

<cfif q.recordcount>
	<cfoutput>
		<h1><i class="fa #application.fapi.getContentTypeMetadata(typename="farConfig", md="icon", default='')#"></i> #application.fapi.getContentTypeMetadata(typename=q.configTypename, md="displayName", default=url.key)#<h1>
		#edit(objectid=q.objectid)#
	</cfoutput>
<cfelse>
	<cfoutput><div class="alert alert-error">The specified config does not exist</div></cfoutput>
</cfif>

<cfsetting enablecfoutputonly="true" />