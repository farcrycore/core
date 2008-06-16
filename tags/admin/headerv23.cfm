<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

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
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/admin/headerv23.cfm,v 1.1 2005/05/23 10:18:24 geoff Exp $
$Author: geoff $
$Date: 2005/05/23 10:18:24 $
$Name: milestone_3-0-1 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: Admin header$
$TODO: additional attributes.onLoad not clearly defined -- should be param'd and documented GB 20031116 $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Geoff Bowers (modius@daemon.com.au)$

|| ATTRIBUTES ||
$in: [title] page title for frame $
$in: [bCacheControl] output cache control headers; default true. $
--->
<cfimport taglib="/farcry/core/tags/misc/" prefix="misc">

<cfparam name="attributes.title" default="#application.config.general.siteTitle# :: Administration" type="string">
<cfparam name="attributes.bCacheControl" default="true" type="boolean">
<!--- i18n --->
<cfparam name="attributes.writingDir" type="string" default="ltr">
<cfparam name="attributes.userLanguage" type="string" default="en">
<!--- additional attributes.onLoad not clearly defined -- should be param'd and documented --->

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html dir="#attributes.writingDir#" lang="#attributes.userLanguage#">
<head>
	<title>#attributes.title#</title>
	<meta content="text/html; charset=UTF-8" http-equiv="content-type">
</cfoutput>

<!--- apply cach control metadata as required --->
<cfif attributes.bCacheControl><misc:cacheControl></cfif>

<cfoutput>
	<!--- setup stylesheets --->
	<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
	<link href="#application.url.farcry#/css/tabsv23.css" rel="stylesheet" type="text/css" title="standard">
	<link href="#application.url.farcry#/css/helptip.css" rel="stylesheet" type="text/css">
</cfoutput>

<cfif NOT CGI.USER_AGENT contains "MSIE">
	<cfoutput>
	<link href="#application.url.farcry#/css/tabs_mozilla.css" rel="stylesheet" type="text/css">
	</cfoutput>
</cfif>

<!--- check for custom css --->
<cfif directoryExists("#application.path.project#/www/css/customadmin")>
	<cfdirectory directory="#application.path.project#/www/css/customadmin" action="LIST" filter="*.css" name="qCSS">
	<cfloop query="qCSS">
		<cfoutput>
		<link href="#application.url.webroot#/css/customadmin/#qCSS.name#" rel="stylesheet" type="text/css"></cfoutput>
	</cfloop>
</cfif>

<!--- check for custom javascript --->
<cfif directoryExists("#application.path.project#/www/js/customadmin")>
	<cfdirectory directory="#application.path.project#/www/js/customadmin" action="LIST" filter="*.js" name="qJS">
	<cfloop query="qJS">
		<cfoutput>
		<script type="text/javascript" src="#application.url.webroot#/js/customadmin/#qJS.name#"></script></cfoutput>
	</cfloop>
</cfif>

<cfoutput>
	<!--- setup javascript source --->
	<cfinclude template="/farcry/core/webtop/includes/countdown.cfm">
	<script>
		//browser testing;
		var ns6 = document.getElementById && ! document.all;
		var ie5up = document.getElementById && document.all;  //ie5 ++
		
		function reloadTreeFrame(){
			// reload tree if not -- quick zoom -- option
			if (document.zoom.QuickZoom.options[document.zoom.QuickZoom.options.selectedIndex].value != '0') {
				window.frames.treeFrame.location.href = document.zoom.QuickZoom.options[document.zoom.QuickZoom.options.selectedIndex].value;
				return false;
			}
		}
	</script>
	
	<!--- qforms setup --->
	<script type="text/javascript" src="<cfoutput>#application.url.farcry#</cfoutput>/includes/synchtab.js"></script>
	<script type="text/javascript" src="<cfoutput>#application.url.farcry#</cfoutput>/includes/resize.js"></script>
	
	<!--// load the qForm JavaScript API //-->
	<SCRIPT SRC="<cfoutput>#application.url.farcry#</cfoutput>/includes/lib/qforms.js"></SCRIPT>
	<!--// you do not need the code below if you plan on just
		   using the core qForm API methods. //-->
	<!--// [start] initialize all default extension libraries  //-->
	<SCRIPT LANGUAGE="JavaScript">
	<!--//
	// specify the path where the "/qforms/" subfolder is located
	qFormAPI.setLibraryPath("<cfoutput>#application.url.farcry#</cfoutput>/includes/lib/");
	// loads all default libraries
	qFormAPI.include("*");
	//-->
	</SCRIPT>
	<!--// [ end ] initialize all default extension libraries  //-->
</head>

<!--- set up javascript body functions if passed --->
<body <cfif isdefined("attributes.onLoad")>onLoad="#attributes.onLoad#"</cfif>>
</cfoutput>
	
<cfsetting enablecfoutputonly="No">