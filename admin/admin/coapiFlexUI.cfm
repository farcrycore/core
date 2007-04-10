<cfsetting enablecfoutputonly="yes">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfif NOT request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminCOAPITab")>	
	<admin:permissionError>
	<cfabort>
</cfif>

<admin:header title="#application.adminBundle[session.dmProfile.locale].COAPIrules#" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
<skin:flexWrapper SWFSource="/farcry/admin/ui/swf/Coapi.swf" id="CoapiUI" />
<admin:footer>

<cfsetting enablecfoutputonly="no">