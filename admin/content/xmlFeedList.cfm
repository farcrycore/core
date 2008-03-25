<cfsetting enablecfoutputonly="No">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/widgets/" prefix="widgets">

<cfset editobjectURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=##recordset.objectID[recordset.currentrow]##&typename=dmNews">

<!--- set up page header --->
<admin:header title="RSS Feeds" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1');">

<cfoutput>
	<p>This feed functionality is deprecated as of FarCry 4.11, and will be not be included in FarCry from 5.0.</p>
	<p>See <a href="#application.url.farcry#/customadmin/customlists/farWebfeed.cfm">RSS Feeds 2.0</a> for up to date functionality supporting RSS 2.0, Atom 1.0, and iTunes podcasts.</p>
</cfoutput>

<widgets:typeadmin 
	typename="dmXMLExport"
	permissionset="news"
	title="#application.adminBundle[session.dmProfile.locale].xmlExportAdministration#"
	bdebug="0">
</widgets:typeadmin>

<admin:footer>