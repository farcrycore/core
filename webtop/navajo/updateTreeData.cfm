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


<!--- convert any lower case keys to uppercase for cfml engines that don't act like cfmx --->
<cfset start = REFind("\[\'", jscode, 0) />
<cfloop condition="#start GT 0#">
	<cfset end = REFind("\'\]", jscode, start) />
	<cfif end GT 0>
		<cfset found =  Mid(jscode,start,end-start+3) />
		<cfset jscode = Replace(jscode,found,UCase(found),"all") />
		<cfset start = REFind("\[\'", jscode, end) />
	<cfelse>
		<cfset start = 0 />
	</cfif>
</cfloop>
<cfset jscode = replace(jscode,"_TL1", "_tl1", "all") />
<cfset jscode = replace(jscode,"_TL0", "_tl0", "all") />
<cfset jscode = replace(jscode,"NEW OBJECT", "new Object", "all") />



<cfoutput>
<script>
	parent.downloadDone("#JSStringFormat(jscode)# objectId='#url.lObjectIds#'");
</script>
</cfoutput>
<cfsetting enablecfoutputonly="No">
