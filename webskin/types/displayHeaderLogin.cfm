<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@displayname: Standard Login Header --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<cfset request.fc.inwebtop = true>


<skin:loadCSS id="fc-bootstrap" />
<skin:loadCSS id="fc-login" />
<skin:loadJS id="fc-jquery" />
<skin:loadJS id="fc-bootstrap" />


<cfset bodyStyle = "">
<cfset webtopBackgroundPath = application.fapi.getConfig("general", "webtopBackgroundPath", "")>
<cfif len(webtopBackgroundPath)>
	<cfset webtopBackgroundPath = application.fc.lib.cdn.ioGetFileLocation(location="images",file=webtopBackgroundPath).path>
	<cfset bodyStyle = "background-image:url(#webtopBackgroundPath#);">
	<cfset webtopBackgroundPosition = application.fapi.getConfig("general", "webtopBackgroundPosition", "")>
	<cfif len(webtopBackgroundPosition)>
		<cfset bodyStyle = bodyStyle & "background-position:#webtopBackgroundPosition#;">
	</cfif>
</cfif>
<cfset bWebtopBackgroundMask = application.fapi.getConfig("general", "bWebtopBackgroundMask", false)>


<cfoutput><!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>FarCry Login</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>

<body style="#bodyStyle#">
	<div class="wrap" <cfif bWebtopBackgroundMask>style="background-image:url(#application.url.webtop#/css/images/bg-mask-dot.png);"</cfif>>
		<div class="content-main">
			<div class="content-block">
				<div id="header" class="clearfix">
					<h1 class="pull-left"><a href="#application.url.webroot#/" target="_blank" class="logo webtop-logo">
						<skin:view typename="configGeneral" webskin="webtopHeaderLogo" bIgnoreSecurity="true" />
					</a></h1>
					<h1 class="pull-right"><a href="http://www.farcrycore.org/" target="_blank" class="logo farcry-logo">FarCry Core</a></h1>
				</div>
				<div class="content-pod">
</cfoutput>

<cfsetting enablecfoutputonly="false">