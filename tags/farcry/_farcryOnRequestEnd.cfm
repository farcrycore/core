<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/_farcryOnRequestEnd.cfm,v 1.4 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name:  $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Functionality to be run at the end of every page, including stats logging$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->


<cfif structKeyExists(Request,"inHead") AND len(structKeyList(Request.InHead))>
	
	
		
		<cfset Request.Required = StructNew()>
		
		<cfif isDefined("Request.InHead.ScriptaculousDragAndDrop")>
			<cfset Request.Required.prototypeJS = 1>
			<cfset Request.Required.scriptaculousJS = 1>
			<cfset Request.Required.scriptaculousDragAndDropJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.ScriptaculousEffects")>
			<cfset Request.Required.prototypeJS = 1>
			<cfset Request.Required.scriptaculousJS = 1>
			<cfset Request.Required.scriptaculousEffectsJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.ScriptaculousBuilder")>
			<cfset Request.Required.prototypeJS = 1>
			<cfset Request.Required.scriptaculousJS = 1>
			<cfset Request.Required.scriptaculousBuilderJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.ScriptaculousSlider")>
			<cfset Request.Required.prototypeJS = 1>
			<cfset Request.Required.scriptaculousJS = 1>
			<cfset Request.Required.scriptaculousSliderJS = 1>
		</cfif>
		<cfif isDefined("Reques.InHeadt.ScriptaculousControls")>
			<cfset Request.Required.prototypeJS = 1>
			<cfset Request.Required.scriptaculousJS = 1>
			<cfset Request.Required.scriptaculousControlsJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.Lightbox")>
			<cfset Request.Required.prototypeJS = 1>
			<cfset Request.Required.scriptaculousJS = 1>
			<cfset Request.Required.lightboxJS = 1>
			<cfset Request.Required.lightboxCSS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.Tabs6")>
			<cfset Request.Required.tabsJS = 1>
			<cfset Request.Required.tabs6CSS = 1>
		</cfif>
		
		
	<cfsavecontent variable="RequiredHead">	
		<cfif isDefined("Request.Required.prototypeJS")>
			<cfoutput><script src="#application.url.webroot#/js/scriptaculous/lib/prototype.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.Required.scriptaculousJS")>
			<cfoutput><script src="#application.url.webroot#/js/scriptaculous/src/scriptaculous.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.Required.ScriptaculousDragAndDropJS")>
			<cfoutput><script src="#application.url.webroot#/js/scriptaculous/src/dragdrop.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.Required.ScriptaculousEffectsJS")>
			<cfoutput><script src="#application.url.webroot#/js/scriptaculous/src/effects.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.Required.ScriptaculousBuilderJS")>
			<cfoutput><script src="#application.url.webroot#/js/scriptaculous/src/builder.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.Required.ScriptaculousSliderJS")>
			<cfoutput><script src="#application.url.webroot#/js/scriptaculous/src/slider.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.Required.ScriptaculousControlsJS")>
			<cfoutput><script src="#application.url.webroot#/js/scriptaculous/src/controls.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.Required.lightboxJS")>
			<cfoutput><script src="#application.url.webroot#/js/lightbox/js/lightbox.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.Required.lightboxCSS")>
			<cfoutput><link rel="stylesheet" href="#application.url.webroot#/js/lightbox/css/lightbox.css" type="text/css" media="screen" /></cfoutput>
		</cfif>
		<cfif isDefined("Request.Required.TabsJS")>
			<cfoutput><script src="#application.url.webroot#/js/tabs.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.Required.Tabs6CSS")>
			<cfoutput><link rel="stylesheet" href="#application.url.webroot#/css/tabs6.css" type="text/css" media="screen" /></cfoutput>
		</cfif>
	
	
			
	</cfsavecontent>
	
	<cfhtmlhead text="#RequiredHead#">
</cfif>


<cfsetting enablecfoutputonly="yes">

<!--- log visit to page --->
<cf_statsLog>

<cfsetting enablecfoutputonly="no">