<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Standard Mobile Header --->
<!--- @@author: Justin Carter (justin@daemon.com.au)--->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<cfparam name="stParam.pageTitle" default="#application.fc.lib.seo.getTitle()#">


<cfoutput><!DOCTYPE html>
<html>

<head>
<meta charset="utf-8">
<title>#stParam.pageTitle# - #application.fapi.getConfig("general", "sitetitle")#</title>

<skin:loadJS id="fc-jquery" />
<skin:loadJS id="farcry-devicetype" />

</head>

<body>

<h1>#application.fapi.getConfig("general","sitetitle")#</h1>
</cfoutput>

<skin:genericNav navID="#application.fapi.getNavID('home')#" id="nav" depth="1" bActive="true" bIncludeHome="true">


<cfsetting enablecfoutputonly="false">