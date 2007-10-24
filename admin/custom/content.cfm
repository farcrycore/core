<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />

<!--- set up page header --->
<admin:header title="" />

<admin:subSectionOverview sectionid="#url.sec#" subsectionid="#url.sub#" webTop="#application.factory.owebtop#" />

<admin:footer />

<cfsetting enablecfoutputonly="false" />