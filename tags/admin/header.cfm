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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header:  $
$Author:  $
$Date:  $
$Name: $
$Revision:  $

|| DESCRIPTION || 
$Description: Admin header$
$TODO: additional attributes.onLoad not clearly defined -- should be param'd and documented GB 20031116 $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$

|| ATTRIBUTES ||
$in: [title] page title for frame $
$in: [bCacheControl] output cache control headers; default true. $
--->
<cfimport taglib="/farcry/core/tags/misc/" prefix="misc">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">

<!--- exit tag if its been closed, ie don't run twice --->
<cfif thistag.executionmode eq "end">
	<cfexit method="exittag" />
</cfif>

<cfparam name="attributes.title" default="#application.config.general.siteTitle# :: Administration" type="string">
<cfparam name="attributes.bCacheControl" default="false" type="boolean">
<cfparam name="attributes.bDataRequestorJS" default="false" type="boolean">
<cfparam name="attributes.jsshowhide" default="" type="string">
<cfparam name="attributes.onLoad" type="string" default="">
<!--- i18n --->
<cfparam name="attributes.writingDir" type="string" default="ltr">
<cfparam name="attributes.userLanguage" type="string" default="en">

<!--- Allow dynamic body class --->
<cfparam name="attributes.bodyclass" default="iframed-content">

<!--- check for custom css --->
<cfset customCSS="">
<cfif directoryExists("#application.path.project#/www/css/customadmin")>
	<cfdirectory directory="#application.path.project#/www/css/customadmin" action="LIST" filter="*.css" name="qCSS">
	<cfsavecontent variable="customCSS">
	<cfloop query="qCSS">
		<cfoutput>
		<link href="#application.url.webroot#/css/customadmin/#qCSS.name#" rel="stylesheet" type="text/css" /></cfoutput>
	</cfloop>
	</cfsavecontent>
</cfif>

<!--- check for custom javascript --->
<cfset customJS="">
<cfif directoryExists("#application.path.project#/www/js/customadmin")>
	<cfdirectory directory="#application.path.project#/www/js/customadmin" action="LIST" filter="*.js" name="qJS">
	<cfsavecontent variable="customJS">
	<cfloop query="qJS">
		<cfoutput>
		<script type="text/javascript" src="#application.url.webroot#/js/customadmin/#qJS.name#"></script></cfoutput>
	</cfloop>
	</cfsavecontent>
</cfif>

<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="#attributes.writingDir#" lang="#attributes.userLanguage#">
	<head>
		<!---  apply cach control metadata as required --->
		</cfoutput><cfif attributes.bCacheControl><misc:cacheControl /></cfif><cfoutput>
		<meta content="text/html; charset=UTF-8" http-equiv="content-type" />
		<title>#attributes.title#</title>

		<style type="text/css">@import url(#application.url.webtop#/css/combine.cfm?files=/main.css,/tabs.css&randomID=#application.randomID#);</style>
		<script type="text/javascript" src="#application.url.webtop#/js/combine.cfm?files=/tables.js,/showhide.js,/fade.js,/tabs.js&randomID=#application.randomID#"></script>
		
		<cfif attributes.bDataRequestorJS>
			<skin:htmlHead library="DataRequestor" />
			<skin:htmlHead library="json" />
		</cfif>
		
		#customCSS#
		#customJS#
</cfoutput>

<cfoutput>
<!--- TODO: review these Javascript requirements -- remove if possible GB20050520 
 setup javascript source --->
	<script type="text/javascript">
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

</cfoutput>

<cfoutput>
	</head>
<body class="#attributes.bodyclass#"<cfif len(attributes.onload)> onload="#attributes.onload#"</cfif>>
</cfoutput>
<cfsetting enablecfoutputonly="No">