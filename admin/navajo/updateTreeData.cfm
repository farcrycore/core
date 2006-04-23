<cfimport taglib="/farcry/tags/navajo" prefix="nj">

<cfsetting enablecfoutputonly="Yes">
<cfoutput>


<nj:treeData
	lObjectIds="#url.lObjectIds#"
	get="Children"
	topLevelVariable="objects"
	lStripFields="displayMethod,objecthistory,teaser,body,ATTR_ACTIVE,ATTR_ARCHIVED,ATTR_LOCKED,ATTR_LOCKEDBY,ATTR_PUBLIC,ATTR_PUBLISHED,ATTR_SECURE,ATTR_SYSTEM,LABEL,NSYSATTRIBUTES,PATH,STKEYWORDS,LCATEGORIES,commentlog"
	r_javascript="jscode">

<!--- 
old navitron f# code (bhpdevcorp)
<cf_nj2TreeData
	lObjectIds="#url.lObjectIds#"
	get="Children"
	topLevelVariable="objects"
	lStripFields="displayMethod,objecthistory,teaser,body,ATTR_ACTIVE,ATTR_ARCHIVED,ATTR_LOCKED,ATTR_LOCKEDBY,ATTR_PUBLIC,ATTR_PUBLISHED,ATTR_SECURE,ATTR_SYSTEM,LABEL,NSYSATTRIBUTES,PATH,STKEYWORDS,LCATEGORIES"
	r_javascript="jscode"
	r_lObjectIds="lObjectIds">
--->


<script>
	parent.downloadDone("#JSStringFormat(jscode)# objectId='#url.lObjectIds#'");
</script>


</cfoutput>
<cfsetting enablecfoutputonly="No">

<!---  <cfset application.updatetreedata = ArrayNew(1)>

<cfset ArrayAppend(application.updatetreedata, url.lobjectids)>  --->