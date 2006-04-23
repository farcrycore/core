<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/tags/misc/" prefix="misc">

<cfparam name="attributes.title" default="Farcry">

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>#attributes.title#</title></cfoutput>
	<misc:cachecontrol> 
	<!--- setup stylesheets --->
	<cfoutput><link href="<cfoutput>#application.url.farcry#</cfoutput>/css/admin.css" rel="stylesheet" type="text/css">
	<link href="<cfoutput>#application.url.farcry#</cfoutput>/css/tabs.css" rel="stylesheet" type="text/css">
	<!--- <link href="<cfoutput>#application.url.farcry#</cfoutput>/css/overviewFrame.css" rel="stylesheet" type="text/css"> --->
	
	<!--- setup javascript source --->
	<script type="text/javascript" src="<cfoutput>#application.url.farcry#</cfoutput>/includes/synchtab.js"></script>
	<script type="text/javascript" src="<cfoutput>#application.url.farcry#</cfoutput>/includes/resize.js"></script>
</head>

<cfoutput><body </cfoutput>
	<!--- set up javascript body functions if passed --->
	<cfif isdefined("attributes.onLoad")>
		<cfoutput>onLoad="#attributes.onLoad#"</cfoutput>
	</cfif>
	></cfoutput>

	
<cfsetting enablecfoutputonly="No">