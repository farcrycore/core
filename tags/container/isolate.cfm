<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Ajaxify generate content --->

<cfparam name="attributes.active" default="#request.mode.ajax#" />
<cfparam name="attributes.type" default="text/html" />
<cfparam name="attributes.removewhitespace" default="false" />

<cfif not thistag.HasEndTag>
	<cfthrow message="The isolate tag must be closed" />
</cfif>

<cfif thistag.ExecutionMode eq "end" and attributes.active>
	<cfif attributes.removewhitespace>
		<cfset thistag.GeneratedContent = rereplace(trim(thistag.generatedcontent),"[[:cntrl:]]{2,}"," ","ALL") />
	</cfif>
	<cfcontent type="#attributes.type#" variable="#charsetdecode(thistag.GeneratedContent,'utf-8')#" />
</cfif>

<cfsetting enablecfoutputonly="false" />