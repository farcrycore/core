<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<skin:viewlite typename="dmHTML" webskin="webtopHeader" />

<!--- body --->
<cfif isValid("uuid", url.objectid)>
	<skin:view objectid="#url.objectid#" typename="#url.typename#" webskin="#url.bodyView#" />
<cfelseif structKeyExists(attributes, "bodyInclude") AND len(attributes.bodyInclude)>
	<cfmodule template="#attributes.bodyInclude#">
<cfelse>
	<skin:viewlite typename="#url.typename#" webskin="#url.bodyView#" />
</cfif>

<skin:viewlite typename="dmHTML" webskin="webtopFooter" />


<cfsetting enablecfoutputonly="false">