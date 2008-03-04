<cfsetting enablecfoutputonly="No">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/widgets/" prefix="widgets">

<cfset editobjectURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=##recordset.objectID[recordset.currentrow]##&typename=dmNews">

<!--- set up page header --->
<admin:header title="RSS Feeds" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1');">

<widgets:typeadmin 
	typename="dmXMLExport"
	permissionset="news"
	title="#apapplication.rb.getResource("xmlExportAdministration")#"
	bdebug="0">
</widgets:typeadmin>

<admin:footer>