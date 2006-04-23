<!--- resolve default iframe for this section view --->
<cfparam name="url.sub" default="users" type="string">
<cfset oWebTop=application.factory.owebtop>

<cfimport taglib="/farcry/farcry_core/tags/admin" prefix="admin">
<admin:menu sectionid="security" subsectionid="#url.sub#" webTop="#application.factory.owebtop#">