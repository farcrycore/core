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

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<skin:loadCSS id="fc-bootstrap" />
<skin:loadCSS id="fc-login" />
<skin:loadJS id="fc-jquery" />
<skin:loadJS id="fc-bootstrap" />

<cfoutput>
	<!DOCTYPE HTML>
	<html>
		<head>
			<meta charset="UTF-8">
			<title>FarCry Login</title>
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
			<link href="#application.url.webtop#/css/icons.css" rel="stylesheet" media="screen">
		</head>

		<body>
			<div id="header">
				<div class="container-fluid">
					<h1><a href="#application.url.webroot#/" target="_blank" class="logo webtop-logo"<cfif structKeyExists(application.config.general,'webtopLogoPath') and application.config.general.webtopLogoPath NEQ ""> style="background-image:url(#application.config.general.webtopLogoPath#);text-indent:-99999px;"</cfif>>#application.config.general.siteTitle#</a></h1>
					<h1><a href="http://www.farcrycore.org/" target="_blank" class="logo farcry-logo">FarCry Core</a></h1>
				</div><!-- /.container -->
			</div><!-- /##header -->
			<div id="content-main">
				<div class="content-block">
					<div class="content-header">
						<h3>Sign In to FarCry</h3>
					</div><!-- /.content-header -->
					<div class="content-main">
</cfoutput>

<cfsetting enablecfoutputonly="false">