<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Standard Mobile Header --->
<!--- @@author: Justin Carter (justin@daemon.com.au)--->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<cfparam name="stParam.pageTitle" default="">

<cfcontent reset="true">

<cfoutput><!doctype html>
<html>

<head>
<meta charset="utf-8">
<title>#stParam.pageTitle# - #application.config.general.sitetitle#</title>

<skin:loadJS id="jquery" />
<skin:loadJS id="farcry-devicetype" />

</head>

<body>

<h1>#application.config.general.sitetitle#</h1>
</cfoutput>

<skin:genericNav navID="#application.navid.home#" id="nav" depth="2" bActive="true" bIncludeHome="true">


<cfsetting enablecfoutputonly="false">