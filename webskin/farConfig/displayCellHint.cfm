<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Config hint --->

<cfif structKeyExists(stObj, "configTypename") AND len(stObj.configtypename) AND isDefined("application.stCOAPI.#stObj.configtypename#.hint")>
	<cfoutput>#application.stCOAPI[stObj.configtypename].hint#</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">