<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/farcry_core/tags/misc/" prefix="misc">

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>adminMenuFrame</title>
	<misc:cachecontrol>
	<LINK href="../css/overviewFrame.css" rel="stylesheet" type="text/css">
</head>

<body>
<cfparam name="url.subtabindex" default="1">
<cfparam name="url.parenttabindex" default="1">
<div id="frameMenu">
		<cfset menuElements = application.customAdminXML.customtabs.parenttab[URL.parenttabindex].subtabs[URL.subtabindex].xmlchildren>
		<cfloop from="1" to="#ArrayLen(menuElements)#" index="i">
			<cfswitch expression="#MenuElements[i].xmlname#">
				<cfcase value="menutitle">
					<div class="frameMenuTitle">#MenuElements[i].xmltext#</div>
				</cfcase>
				<cfcase value="menuitem">
					<cfset label = xmlSearch(MenuElements[i],"label")>
					<cfset link = xmlSearch(MenuElements[i],"link")>
					<div class="frameMenuItem">
					<span class="frameMenuBullet">&raquo;</span>
  						<a href="#link[1].xmltext#" class="frameMenuItem" target="editFrame">#label[1].xmltext#</a>	
					</div>					 
				</cfcase>
			</cfswitch>
			
		</cfloop>
</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">