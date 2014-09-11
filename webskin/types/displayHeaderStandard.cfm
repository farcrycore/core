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
<!--- @@displayname: Standard Header --->
<!--- @@description: Very basic header and is available to all content types  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<cfparam name="stParam.pageTitle" default="#application.fc.lib.seo.getTitle()#">


<cfoutput><!DOCTYPE html>
<html lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
	<title>#stParam.pageTitle# - #application.fapi.getConfig("general", "sitetitle")#</title>
</head>
<body>

	<div class="container">
	
		 <skin:genericNav navID="#application.fapi.getNavID('home')#"
			id="nav"
			depth="2"
			bActive="true"
			bIncludeHome="true">	
			
</cfoutput>

<cfsetting enablecfoutputonly="false">