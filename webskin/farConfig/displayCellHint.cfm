<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Config hint --->

<cfif len(stObj.configtypename) and structkeyexists(application.stCOAPI[stObj.configtypename],"hint")>
	<cfoutput>#application.stCOAPI[stObj.configtypename].hint#</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">