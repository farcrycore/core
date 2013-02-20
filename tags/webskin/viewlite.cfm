<cfsetting enablecfoutputonly="true">

<cfif thistag.executionMode eq "start">

	<cfparam name="attributes.stObject" default="#structNew()#">
	<cfparam name="attributes.typename" default="#url.typename#">
	<cfparam name="attributes.webskin" default="#url.view#">
	<cfparam name="attributes.bodyInclude" default="">

	<!--- build attributes to pass through --->
	<cfset stAttributes = structNew()>
	<cfset stAttributes.stObj = duplicate(attributes.stObject)>
	<cfset stAttributes.bodyInclude = attributes.bodyInclude>
	<!--- put remaining attributes into stParam  --->
	<cfset stAttributes.stParam = duplicate(attributes)>
	<cfset structDelete(stAttributes.stParam, "stObject")>
	<cfset structDelete(stAttributes.stParam, "typename")>
	<cfset structDelete(stAttributes.stParam, "webskin")>
	<cfset structDelete(stAttributes.stParam, "bodyInclude")>

	<!--- lookup webskin inheritance --->
	<cfset pathViewWebskin = application.coapi.coapiadmin.getWebskinPath(typename=attributes.typename, template=attributes.webskin)>

	<!--- call webskin with appropriate attributes --->
	<cfmodule template="#pathViewWebskin#" attributeCollection="#stAttributes#">

</cfif>

<cfsetting enablecfoutputonly="false">