<cfsetting enablecfoutputonly="yes">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<cfprocessingDirective pageencoding="utf-8">

<admin:header title="Multiple image uploader" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="AdminCOAPITab">
	<cfset flexCategoryFacadePath = replaceNoCase('#application.url.webtop#.facade.flexCategory','/','.','all') />
	<cfif left(flexCategoryFacadePath,1) EQ ".">
		<cfset flexCategoryFacadePath = mid(flexCategoryFacadePath,2,len(flexCategoryFacadePath)) />
	</cfif>
	<skin:flexWrapper SWFSource="#application.url.farcry#/admin/ui/swf/multipleUploader.swf" id="multiple" flashVars="#lcase(session.urltoken)#&bulkimgUploadURL=#application.url.webtop#/admin/bulkimgUpload.cfm&flexCategoryFacadePath=#flexCategoryFacadePath#&#session.urlToken#&farcryproject=#application.projectDirectoryName#&webtop=#application.url.webtop#">
</sec:CheckPermission>

<admin:footer>

<cfsetting enablecfoutputonly="no">