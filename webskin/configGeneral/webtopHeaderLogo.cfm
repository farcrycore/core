<cfsetting enablecfoutputonly="true">

<cfif len(application.fapi.getConfig("general", "webtoplogopath"))>
	<!--- fit inside 180x60 --->
	<cfoutput><img src="#application.fapi.getConfig("general", "webtoplogopath")#" alt="#application.fapi.getConfig("general","sitetitle")#" style="max-width:180px;max-height:60px"></cfoutput>
<cfelse>
	<cfoutput>#application.fapi.getConfig("general", "sitetitle")#</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">