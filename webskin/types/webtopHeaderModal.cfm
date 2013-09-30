<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="session.writingDir" default="ltr" />
<cfparam name="session.userLanguage" default="en" />

<cfset request.fc.inWebtop = 1>

<cfoutput><!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<title>[#application.applicationname#] #application.config.general.sitetitle# - FarCry Webtop</title>

<!--- TODO: register --->
	<skin:loadCSS id="fc-bootstrap" />
	<skin:loadCSS id="fc-fontawesome" />
	<skin:loadCSS id="webtop7" />
	<!--- <skin:loadCSS id="fc-icons" /> --->
	<skin:loadJS id="fc-jquery" />
	<skin:loadJS id="fc-bootstrap" />

</head>
<body class="webtop-modal">



	<div class="container-fluid">
		<div class="row-fluid">
			<div class="span12">
				<div id="bubbles"></div>
</cfoutput>

<cfsetting enablecfoutputonly="false">