<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/tags/misc/" prefix="misc">

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>dynamicMenuFrame</title>
	<misc:cachecontrol>
	<LINK href="../css/overviewFrame.css" rel="stylesheet" type="text/css">
</head>

<body>
<div id="frameMenu">

<!--- <div class="frameMenuHeader">Dynamic Content</div> --->

<!--- <div class="frameMenuTitle">News</div> --->
<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/GenericAdmin.cfm?type=News&typename=dmNews" class="frameMenuItem" target="editFrame">News Objects</a></div>

<!--- <div class="frameMenuTitle">Calendar Events</div>
<div class="frameMenuItem"><a href="#application.url.farcry#/navajo/GenericAdmin.cfm?type=Event" target="editFrame">Event Objects</a></div>
 --->
<!--- <div class="frameMenuTitle">Facts</div>
<div class="frameMenuItem"><a href="#application.url.farcry#/navajo/GenericAdmin.cfm?type=factsCollection" target="editFrame">Fact Collection</a></div>
<div class="frameMenuItem"><a href="#application.url.farcry#/navajo/GenericAdmin.cfm?type=facts" target="editFrame">Fact Objects</a></div>
 --->
</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">