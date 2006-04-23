<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">

<cfsetting enablecfoutputonly="Yes">
<cfoutput>


<nj:treeData
	lObjectIds="#url.lObjectIds#"
	get="Children"
	topLevelVariable="objects"
	lStripFields="displayMethod,objecthistory,teaser,body,ATTR_ACTIVE,ATTR_ARCHIVED,ATTR_LOCKED,ATTR_LOCKEDBY,ATTR_PUBLIC,ATTR_PUBLISHED,ATTR_SECURE,ATTR_SYSTEM,LABEL,NSYSATTRIBUTES,PATH,STKEYWORDS,LCATEGORIES,commentlog"
	r_javascript="jscode">


<script>
	parent.downloadDone("#JSStringFormat(jscode)# objectId='#url.lObjectIds#'");
</script>


</cfoutput>
<cfsetting enablecfoutputonly="No">
