<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Config hint --->

<cfset formname = getForm(key=stObj.configkey) />
<cfset hint = "" />

<cfif len(formname) and structkeyexists(application.stCOAPI[formname],"hint")>
	<cfset hint = application.stCOAPI[formname].hint />
</cfif>

<cfoutput>
	#hint#
</cfoutput>

<cfsetting enablecfoutputonly="false" />