<cfsetting enablecfoutputonly="true">

<cfif len(trim(stObj.text))>
	<cfoutput>#stObj.text#</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">