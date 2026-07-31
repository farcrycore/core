<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Edit link --->

<cfset title = stObj.configkey>
<cfif structKeyExists(application.stCOAPI, stObj.configtypename) AND structKeyExists(application.stCOAPI[stObj.configtypename], "displayname")>
	<cfset title = application.stCOAPI[stObj.configtypename].displayname>
</cfif>

<cfoutput>
	<a href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#encodeForHTMLAttribute(stObj.objectid)#&typename=farConfig&method=edit&ref=dialogiframe" onclick="$fc.objectAdminAction('#encodeForJavaScript(title)#', this.href + '&iframe=1'); return false;">#encodeForHTML(title)#</a>
</cfoutput>

<cfsetting enablecfoutputonly="false">