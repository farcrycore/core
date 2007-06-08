<cfsetting enablecfoutputonly="yes">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfprocessingDirective pageencoding="utf-8">

<admin:header title="Category manager" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<skin:flexWrapper SWFSource="#application.url.farcry#/admin/ui/swf/Category.swf" id="FarcryCategory" />
<admin:footer>
<cfsetting enablecfoutputonly="no">