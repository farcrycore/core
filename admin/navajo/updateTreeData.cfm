<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">

<cfsetting enablecfoutputonly="Yes">
<cfoutput>


<nj:treeData
	lObjectIds="#url.lObjectIds#"
	get="Children"
	topLevelVariable="objects"
	lStripFields="ORIGINALIMAGEPATH,OPTIMISEDIMAGEPATH,THUMBNAILIMAGEPATH,OPTIMISEDIMAGE,height,width,alt,lNavidAlias,teaserimage,extendedmetadata,externallink,flashparams,flashheight,flashwidth,flashbgcolor,flashloop,flashmenu,flashplay,flashquality,flashversion,teaserimage,metakeywords,displayMethod,objecthistory,teaser,body,PATH,commentlog"
	r_javascript="jscode">


<script>
	parent.downloadDone("#JSStringFormat(jscode)# objectId='#url.lObjectIds#'");
</script>


</cfoutput>
<cfsetting enablecfoutputonly="No">
