<cfsetting enablecfoutputonly="yes">
<cfparam name="attributes.linktext" default="Printer Friendly Version">

<cfoutput><a href="#application.url.webroot#/printFriendly.cfm?objectid=#url.objectid#" target="_blank">#attributes.linkText#</a></cfoutput>

<cfsetting enablecfoutputonly="no">