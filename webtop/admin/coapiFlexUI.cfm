<cfsetting enablecfoutputonly="yes">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<cfprocessingDirective pageencoding="utf-8">

<admin:header title="#application.rb.getResource("COAPIrules")#" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="AdminCOAPITab">
	<cfset connectString = "#replace(replace(application.url.webtop,"/",""),"/",".","all")#.facade.coapiFacade">
	<skin:flexWrapper SWFSource="#application.url.webtop#/admin/ui/swf/Coapi.swf" flashVars="connectString=#connectString#" id="CoapiUI">
</sec:CheckPermission>

<admin:footer>

<cfsetting enablecfoutputonly="no">