<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Config hint --->

<cfif structKeyExists(application.stCOAPI, stObj.configtypename) AND structKeyExists(application.stCOAPI[stObj.configtypename], "hint")>
	<cfoutput>#application.stCOAPI[stObj.configtypename].hint#</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">