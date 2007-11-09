<cfsetting enablecfoutputonly="yes">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<cfprocessingDirective pageencoding="utf-8">

<admin:header title="Multiple image uploader" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:restricted permission="AdminCOAPITab">
	<cfif len(application.url.webroot)>
		<cfset appRoot = right(application.url.webroot,len(application.url.webroot)-1)>
		<cfset appRoot = replace(appRoot,"/",".")>
		<skin:flexWrapper SWFSource="#application.url.farcry#/admin/ui/swf/multipleUploader.swf" id="multiple" flashVars="#lcase(session.urltoken)#&appRoot=#appRoot#">
	<cfelse>
		<skin:flexWrapper SWFSource="#application.url.farcry#/admin/ui/swf/multipleUploader.swf" id="multiple" flashVars="#lcase(session.urltoken)#">
	</cfif>
</sec:restricted>

<admin:footer>

<cfsetting enablecfoutputonly="no">