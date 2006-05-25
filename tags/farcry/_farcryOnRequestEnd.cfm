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
		<cfparam name="Request.RequiredInHead" default="#StructNew()#">		
		
		<cfparam name="Request.RequiredInHead.prototypeJS" default = "0">
		<cfparam name="Request.RequiredInHead.prototypeLiteJS" default = "0">
		<cfparam name="Request.RequiredInHead.moofxJS" default = "0">
		<cfparam name="Request.RequiredInHead.tabsJS" default = "0">
		<cfparam name="Request.RequiredInHead.scriptaculousJS" default = "0">
		<cfparam name="Request.RequiredInHead.scriptaculousDragAndDropJS" default = "0">
		<cfparam name="Request.RequiredInHead.scriptaculousEffectsJS" default = "0">
		<cfparam name="Request.RequiredInHead.scriptaculousBuilderJS" default = "0">
		<cfparam name="Request.RequiredInHead.scriptaculousSliderJS" default = "0">
		<cfparam name="Request.RequiredInHead.scriptaculousControlsJS" default = "0">
		<cfparam name="Request.RequiredInHead.lightboxJS" default = "0">
		<cfparam name="Request.RequiredInHead.DateTimePickerJS" default = "1">
		<cfparam name="Request.RequiredInHead.CalendarJS" default = "0">
		<cfparam name="Request.RequiredInHead.CalendarSetupJS" default = "0">
		<cfparam name="Request.RequiredInHead.TinyMCEJS" default = "0">
		<cfparam name="Request.RequiredInHead.JSONJS" default = "0">
		<cfparam name="Request.RequiredInHead.FormValidationJS" default = "0">
		
		
		
		<cfparam name="Request.RequiredInHead.TabStyle1CSS" default = "0">
		<cfparam name="Request.RequiredInHead.TabStyle6CSS" default = "0">
		<cfparam name="Request.RequiredInHead.CalendarStyle1CSS" default = "0">
		
		
		
		
		<cfif isDefined("Request.InHead.PrototypeLite")>
			<cfset Request.RequiredInHead.prototypeLiteJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.MooFX")>
			<cfset Request.RequiredInHead.prototypeLiteJS = 1>
			<cfset Request.RequiredInHead.moofxJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.TabStyle1")>
			<cfset Request.RequiredInHead.prototypeLiteJS = 1>
			<cfset Request.RequiredInHead.tabsJS = 1>
			<cfset Request.RequiredInHead.TabStyle1CSS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.TabStyle6")>
			<cfset Request.RequiredInHead.prototypeLiteJS = 1>
			<cfset Request.RequiredInHead.tabsJS = 1>
			<cfset Request.RequiredInHead.TabStyle6CSS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.Scriptaculous")>
			<cfset Request.RequiredInHead.prototypeJS = 1>
			<cfset Request.RequiredInHead.prototypeLiteJS = 0>
			<cfset Request.RequiredInHead.scriptaculousJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.ScriptaculousDragAndDrop")>
			<cfset Request.RequiredInHead.prototypeJS = 1>
			<cfset Request.RequiredInHead.prototypeLiteJS = 0>
			<cfset Request.RequiredInHead.scriptaculousJS = 1>
			<cfset Request.RequiredInHead.scriptaculousDragAndDropJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.ScriptaculousEffects")>
			<cfset Request.RequiredInHead.prototypeJS = 1>
			<cfset Request.RequiredInHead.prototypeLiteJS = 0>
			<cfset Request.RequiredInHead.scriptaculousJS = 1>
			<cfset Request.RequiredInHead.scriptaculousEffectsJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.ScriptaculousBuilder")>
			<cfset Request.RequiredInHead.prototypeJS = 1>
			<cfset Request.RequiredInHead.prototypeLiteJS = 0>
			<cfset Request.RequiredInHead.scriptaculousJS = 1>
			<cfset Request.RequiredInHead.scriptaculousBuilderJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.ScriptaculousSlider")>
			<cfset Request.RequiredInHead.prototypeJS = 1>
			<cfset Request.RequiredInHead.prototypeLiteJS = 0>
			<cfset Request.RequiredInHead.scriptaculousJS = 1>
			<cfset Request.RequiredInHead.scriptaculousSliderJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.ScriptaculousControls")>
			<cfset Request.RequiredInHead.prototypeJS = 1>
			<cfset Request.RequiredInHead.prototypeLiteJS = 0>
			<cfset Request.RequiredInHead.scriptaculousJS = 1>
			<cfset Request.RequiredInHead.scriptaculousControlsJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.Lightbox")>
			<cfset Request.RequiredInHead.prototypeJS = 1>
			<cfset Request.RequiredInHead.prototypeLiteJS = 0>
			<cfset Request.RequiredInHead.scriptaculousJS = 1>
			<cfset Request.RequiredInHead.lightboxJS = 1>
			<cfset Request.RequiredInHead.lightboxCSS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.DateTimePicker")>
			<cfset Request.RequiredInHead.DateTimePickerJS = 1>
		</cfif>
		<cfif isdefined("Request.InHead.Calendar")>
			<cfset Request.RequiredInHead.CalendarJS = 1>
			<cfset Request.RequiredInHead.CalendarSetupJS = 1>
			<cfset Request.RequiredInHead.CalendarStyle1CSS = 1>
		</cfif>
		<cfif isdefined("Request.InHead.TinyMCE")>
			<cfset Request.RequiredInHead.TinyMCEJS = 1>
		</cfif>
		<cfif isdefined("Request.InHead.JSON")>
			<cfset Request.RequiredInHead.JSONJS = 1>
		</cfif>
		
		<cfif isdefined("Request.InHead.FormValidation")>
			<cfset Request.RequiredInHead.FormValidationJS = 1>
			<cfset Request.RequiredInHead.prototypeJS = 1>
			<cfset Request.RequiredInHead.scriptaculousEffectsJS = 1>
		</cfif>
		
		
		
	<cfsavecontent variable="RequiredHead">	
		<cfif isDefined("Request.RequiredInHead.prototypeLiteJS") AND Request.RequiredInHead.prototypeLiteJS EQ 1 AND Request.RequiredInHead.prototypeJS EQ 0>
			<cfoutput><script src="#application.url.farcry#/js/prototype/prototype.lite.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.RequiredInHead.prototypeJS") AND Request.RequiredInHead.prototypeJS EQ 1>
			<cfoutput><script src="#application.url.farcry#/js/prototype/prototype.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.RequiredInHead.scriptaculousJS") AND Request.RequiredInHead.scriptaculousJS EQ 1>
			<cfoutput><script src="#application.url.farcry#/js/scriptaculous/scriptaculous.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.RequiredInHead.ScriptaculousDragAndDropJS") AND Request.RequiredInHead.ScriptaculousDragAndDropJS EQ 1>
			<cfoutput><script src="#application.url.farcry#/js/scriptaculous/dragdrop.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.RequiredInHead.ScriptaculousEffectsJS") AND Request.RequiredInHead.ScriptaculousEffectsJS EQ 1>
			<cfoutput><script src="#application.url.farcry#/js/scriptaculous/effects.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.RequiredInHead.ScriptaculousBuilderJS") AND Request.RequiredInHead.ScriptaculousBuilderJS EQ 1>
			<cfoutput><script src="#application.url.farcry#/js/scriptaculous/builder.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.RequiredInHead.ScriptaculousSliderJS") AND Request.RequiredInHead.ScriptaculousSliderJS EQ 1>
			<cfoutput><script src="#application.url.farcry#/js/scriptaculous/slider.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.RequiredInHead.ScriptaculousControlsJS") AND Request.RequiredInHead.ScriptaculousControlsJS EQ 1>
			<cfoutput><script src="#application.url.farcry#/js/scriptaculous/controls.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.RequiredInHead.lightboxJS") AND Request.RequiredInHead.lightboxJS EQ 1>
			<cfoutput><script src="#application.url.farcry#/js/lightbox/lightbox.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.RequiredInHead.lightboxCSS") AND Request.RequiredInHead.lightboxCSS EQ 1>
			<cfoutput><link rel="stylesheet" href="#application.url.farcry#/css/lightbox/lightbox.css" type="text/css" media="screen" /></cfoutput>
		</cfif>
		<cfif isDefined("Request.RequiredInHead.TabsJS") AND Request.RequiredInHead.TabsJS EQ 1>
			<cfoutput><script src="#application.url.farcry#/js/tabs/tabs.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.RequiredInHead.TabStyle1CSS") AND Request.RequiredInHead.TabStyle1CSS EQ 1>
			<cfoutput><link rel="stylesheet" href="#application.url.farcry#/css/tabs/TabStyle1.css" type="text/css" media="screen" /></cfoutput>
		</cfif>
		<cfif isDefined("Request.RequiredInHead.TabStyle6CSS") AND Request.RequiredInHead.TabStyle6CSS EQ 1>
			<cfoutput><link rel="stylesheet" href="#application.url.farcry#/css/tabs/TabStyle6.css" type="text/css" media="screen" /></cfoutput>
		</cfif>
		<cfif isDefined("Request.RequiredInHead.DateTimePickerJS") AND Request.RequiredInHead.DateTimePickerJS EQ 1>
			<cfoutput><script src="#application.url.farcry#/js/DateTimePicker/DateTimePicker.js" type="text/javascript"></script></cfoutput>
		</cfif>
		
		<cfif isDefined("Request.RequiredInHead.CalendarJS") AND Request.RequiredInHead.CalendarJS EQ 1>
			<cfoutput><script src="#application.url.farcry#/js/calendar/calendar.js" type="text/javascript"></script></cfoutput>
			<cfoutput><script src="#application.url.farcry#/js/calendar/lang/calendar-en.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.RequiredInHead.CalendarSetupJS") AND Request.RequiredInHead.CalendarSetupJS EQ 1>
			<cfoutput><script src="#application.url.farcry#/js/calendar/calendar-setup.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.RequiredInHead.CalendarStyle1CSS") AND Request.RequiredInHead.CalendarStyle1CSS EQ 1>
			<cfoutput><link rel="stylesheet" href="#application.url.farcry#/css/calendar/calendar-win2k-1.css" type="text/css" media="screen" /></cfoutput>
		</cfif>
		
		
		<cfif isDefined("Request.RequiredInHead.TinyMCEJS") AND Request.RequiredInHead.TinyMCEJS EQ 1>
			<cfoutput><script src="#application.url.farcry#/js/tiny_mce/tiny_mce.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("Request.RequiredInHead.JSONJS") AND Request.RequiredInHead.JSONJS EQ 1>
			<cfoutput><script src="#application.url.farcry#/includes/lib/json.js" type="text/javascript"></script></cfoutput>
		</cfif>
		
		<cfif isDefined("Request.RequiredInHead.FormValidationJS") AND Request.RequiredInHead.FormValidationJS EQ 1>
			<cfoutput><script src="#application.url.farcry#/js/formvalidation/validation.js" type="text/javascript"></script></cfoutput>
		</cfif>
		
	</cfsavecontent>
	
	<cfhtmlhead text="#RequiredHead#">
</cfif>


<cfsetting enablecfoutputonly="yes">

<!--- log visit to page --->
<cf_statsLog>

<cfsetting enablecfoutputonly="no">