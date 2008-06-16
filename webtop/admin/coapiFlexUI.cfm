<cfsetting enablecfoutputonly="yes">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<cfprocessingDirective pageencoding="utf-8">

<admin:header title="#application.rb.getResource("COAPIrules")#" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="AdminCOAPITab">
	<skin:flexWrapper SWFSource="#application.url.webtop#/admin/ui/swf/Coapi.swf" id="CoapiUI">
</sec:CheckPermission>

<admin:footer>

<cfsetting enablecfoutputonly="no">