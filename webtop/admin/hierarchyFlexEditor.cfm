<cfsetting enablecfoutputonly="yes">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfprocessingDirective pageencoding="utf-8">

<admin:header title="Category manager" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">


<sec:CheckPermission error="true" permission="AdminCOAPITab">
	<cfset flexCategoryFacadePath = replaceNoCase('#application.url.webtop#.facade.flexCategory','/','.','all') />
	<cfif left(flexCategoryFacadePath,1) EQ ".">
		<cfset flexCategoryFacadePath = mid(flexCategoryFacadePath,2,len(flexCategoryFacadePath)) />
	</cfif>
	<skin:flexWrapper SWFSource="#application.url.farcry#/admin/ui/swf/Category.swf" id="FarcryCategory" flashVars="flexCategoryFacadePath=#flexCategoryFacadePath#">
</sec:CheckPermission>


<admin:footer>
<cfsetting enablecfoutputonly="no">