<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="stParam.bodyInclude" default="">

<skin:view typename="dmHTML" webskin="webtopHeader" />

<!--- body --->
<cfif isValid("uuid", url.objectid)>
	<skin:view objectid="#url.objectid#" typename="#url.typename#" webskin="#url.bodyView#" />
<cfelseif structKeyExists(stParam, "bodyInclude") AND len(stParam.bodyInclude)>
	<cfmodule template="#stParam.bodyInclude#">
<cfelse>
	<skin:view typename="#url.typename#" webskin="#url.bodyView#" />
</cfif>

<skin:view typename="dmHTML" webskin="webtopFooter" />


<cfsetting enablecfoutputonly="false">