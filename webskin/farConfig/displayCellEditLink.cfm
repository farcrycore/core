<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Edit link --->

<cfset title = stObj.configkey>
<cfif not structKeyExists(stObj, "configTypename") or not len(stObj.configtypename) and isjson(stObj.configdata)>
      <cfset stData = deserializeJSON(stObj.configData) />
      <cfset stObj.configTypename = stData.typename />
      <cfset setData(stProperties=stObj) />
</cfif>
<cfif structKeyExists(stObj, "configTypename") AND len(stObj.configtypename) AND isDefined("application.stCOAPI.#stObj.configtypename#.displayname")>
	<cfset title = application.stCOAPI[stObj.configtypename].displayname>
</cfif>

<cfoutput>
	<a href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&typename=farConfig&method=edit&ref=dialogiframe" onclick="$fc.objectAdminAction('#title#', this.href + '&iframe=1'); return false;">#title#</a>
</cfoutput>

<cfsetting enablecfoutputonly="false">