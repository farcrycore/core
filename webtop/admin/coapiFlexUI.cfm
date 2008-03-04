<cfsetting enablecfoutputonly="yes">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<cfprocessingDirective pageencoding="utf-8">

<admin:header title="#apapplication.rb.getResource("COAPIrules")#" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="AdminCOAPITab">
	<cfif len(application.url.webroot)>
		<cfset appRoot = right(application.url.webroot,len(application.url.webroot)-1)>
		<cfset appRoot = replace(appRoot,"/",".")>
		<skin:flexWrapper SWFSource="#application.url.farcry#/admin/ui/swf/Coapi.swf" id="CoapiUI" flashVars="appRoot=#appRoot#">
	<cfelse>
		<skin:flexWrapper SWFSource="#application.url.farcry#/admin/ui/swf/Coapi.swf" id="CoapiUI">
	</cfif>
</sec:CheckPermission>

<admin:footer>

<cfsetting enablecfoutputonly="no">