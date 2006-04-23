<cfsetting enablecfoutputonly="Yes">
<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/admin/header.cfm,v 1.17 2004/06/17 00:18:23 spike Exp $
$Author: spike $
$Date: 2004/06/17 00:18:23 $
$Name: milestone_2-2-1 $
$Revision: 1.17 $

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
<cfimport taglib="/farcry/farcry_core/tags/misc/" prefix="misc">

<cfparam name="attributes.title" default="#application.config.general.siteTitle# :: Administration" type="string">
<cfparam name="attributes.bCacheControl" default="true" type="boolean">
<!--- additional attributes.onLoad not clearly defined -- should be param'd and documented --->

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>#attributes.title#</title>
</cfoutput>

<!--- apply cach control metadata as required --->
<cfif attributes.bCacheControl><misc:cacheControl></cfif>

<cfoutput>
	<!--- setup stylesheets --->
	<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
	<link href="#application.url.farcry#/css/tabs.css" rel="stylesheet" type="text/css" title="standard">
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
	<cfinclude template="/farcry/farcry_core/admin/includes/countdown.cfm">
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

	<!--- check for htmlarea --->
	<cfif application.config.general.richTextEditor EQ 'htmlArea'>

	<!-- // Load the HTMLEditor and set the preferences // -->
	<script type="text/javascript">
	   _editor_url = "#application.url.farcry#/includes/lib/htmlarea/";
	   _editor_lang = "en";
	</script>
	<script type="text/javascript" src="#application.url.farcry#/includes/lib/htmlarea/htmlarea.js"></script>
	<script type="text/javascript" src="#application.url.farcry#/includes/lib/htmlarea/dialog.js"></script>
	<script type="text/javascript" src="#application.url.farcry#/includes/lib/htmlarea/lang/en.js"></script>

	<script type="text/javascript">
	var config = new HTMLArea.Config();
					config.toolbar = [
						#application.config.htmlarea.Toolbar1#
						,#application.config.htmlarea.Toolbar2#
					];
	</script>


	<!-- // Finished loading HTMLEditor //-->
	</cfif>

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