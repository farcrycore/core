<cfsetting enablecfoutputonly="yes">

<cfif not isdefined("url.Typename")>
	<cfthrow type="Application" message="You must pass URL.Typename to the ajax form submission.">
</cfif>
<cfif not isdefined("url.Webskin")>
	<cfthrow type="Application" message="You must pass URL.Webskin to the ajax form submission.">
</cfif>
<cfif not isdefined("url.objectid")>
	<cfthrow type="Application" message="You must pass URL.Objectid to the ajax form submission.">
</cfif>

<cfset o = createObject("component", application.types[url.typename].typepath) />
<cfset HTML = o.getView(objectid=url.objectid,template=url.webskin) />
<cfoutput>#HTML#</cfoutput>


<cfsetting enablecfoutputonly="no">