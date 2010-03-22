<cfsetting enablecfoutputonly="Yes">
<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

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

<!--- exit tag if its been closed, ie don't run twice --->
<cfif thistag.executionmode eq "end">
	<cfexit method="exittag" />
</cfif>

<cfparam name="attributes.title" default="#application.config.general.siteTitle# :: Administration" type="string">
<cfparam name="attributes.bCacheControl" default="false" type="boolean">
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
		<!--- apply cach control metadata as required --->
		</cfoutput><cfif attributes.bCacheControl><misc:cacheControl /></cfif><cfoutput>
		<meta content="text/html; charset=UTF-8" http-equiv="content-type" />
		<title>#attributes.title#</title>
		<script type="text/javascript" src="#application.url.farcry#/js/tabs.js"></script>
		<!--- DataRequestor Object : used to retrieve xml data via javascript --->
		<script type="text/javascript" src="#application.url.farcry#/includes/lib/DataRequestor.js"></script>
		<!--- JSON javascript object --->
		<script type="text/javascript" src="#application.url.farcry#/includes/lib/json.js"></script>
		<style type="text/css" title="default" media="screen">@import url(#application.url.farcry#/css/main.css);</style><!--- 
		<style type="text/css" title="default" media="screen">@import url(#application.url.farcry#/css/forms.css);</style> --->
		<style type="text/css" title="default" media="screen">@import url(#application.url.farcry#/css/tabs.css);</style>
		<script type="text/javascript" src="#application.url.farcry#/js/tables.js"></script>
		<script type="text/javascript" src="#application.url.farcry#/js/showhide.js"></script>
		<script type="text/javascript" src="#application.url.farcry#/js/fade.js"></script>
		#customCSS#
		#customJS#
</cfoutput>

<cfoutput>
<!--- TODO: review these Javascript requirements -- remove if possible GB20050520 --->
<!--- setup javascript source --->
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
	
	<!--- qforms setup --->
	<!--// load the qForm JavaScript API //-->
	<script type="text/javascript" src="<cfoutput>#application.url.farcry#</cfoutput>/includes/lib/qforms.js"></script>
	<!--// you do not need the code below if you plan on just
		   using the core qForm API methods. //-->
	<!--// [start] initialize all default extension libraries  //-->
	<script type="text/javascript">
	<!--//
	// specify the path where the "/qforms/" subfolder is located
	qFormAPI.setLibraryPath("<cfoutput>#application.url.farcry#</cfoutput>/includes/lib/");
	// loads all default libraries
	qFormAPI.include("*");
	//-->
	</script>
	<!--// [ end ] initialize all default extension libraries  //-->
</cfoutput>

<cfoutput>
	</head>
<body class="#attributes.bodyclass#"<cfif len(attributes.onload)> onload="#attributes.onload#"</cfif>>
</cfoutput>
<cfsetting enablecfoutputonly="No">