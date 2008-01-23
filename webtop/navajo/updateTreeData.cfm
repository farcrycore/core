<cfsetting enablecfoutputonly="Yes">
<cfprocessingDirective pageencoding="utf-8">

<!--- import tag library --->
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">

<nj:treeData
	lObjectIds="#url.lObjectIds#"
	get="Children"
	topLevelVariable="objects"
	lStripFields="ORIGINALIMAGEPATH,OPTIMISEDIMAGEPATH,THUMBNAILIMAGEPATH,OPTIMISEDIMAGE,lNavidAlias,teaserimage,extendedmetadata,teaserimage,metakeywords,displayMethod,objecthistory,teaser,body,PATH,commentlog"
	r_javascript="jscode">

<cfoutput>
<script>
	parent.downloadDone("#JSStringFormat(jscode)# objectId='#url.lObjectIds#'");
</script>
</cfoutput>
<cfsetting enablecfoutputonly="No">
