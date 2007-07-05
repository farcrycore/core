<cfsetting enablecfoutputonly="yes">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfprocessingDirective pageencoding="utf-8">

<admin:header title="Category manager" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
<cfif len(application.url.webroot)>
	<cfset appRoot = right(application.url.webroot,len(application.url.webroot)-1)>
	<cfset appRoot = replace(appRoot,"/",".")>
	<skin:flexWrapper SWFSource="#application.url.farcry#/admin/ui/swf/Category.swf" id="FarcryCategory" flashVars="appRoot=#appRoot#">
<cfelse>
	<skin:flexWrapper SWFSource="#application.url.farcry#/admin/ui/swf/Category.swf" id="FarcryCategory" />
</cfif>

<admin:footer>
<cfsetting enablecfoutputonly="no">