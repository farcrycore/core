<!--- resolve default iframe for this section view --->
<cfparam name="url.sub" default="dynamic" type="string">

<cfimport taglib="/farcry/farcry_core/tags/admin" prefix="admin">
<admin:menu sectionid="content" subsectionid="#url.sub#" webTop="#application.factory.owebtop#" />
