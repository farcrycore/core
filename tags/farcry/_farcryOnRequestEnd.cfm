<cfsetting enablecfoutputonly="yes">

<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/farcry/_farcryOnRequestEnd.cfm,v 1.4 2005/08/09 03:54:39 geoff Exp $
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
		<cfparam name="variables.stPlaceInHead" default="#StructNew()#">		
		
		<cfparam name="variables.stPlaceInHead.prototypeJS" default = "0">
		<cfparam name="variables.stPlaceInHead.prototypeLiteJS" default = "0">
		<cfparam name="variables.stPlaceInHead.moofxJS" default = "0">
		<cfparam name="variables.stPlaceInHead.moofxPackJS" default = "0">
		<cfparam name="variables.stPlaceInHead.mooAjaxJS" default = "0">
		<cfparam name="variables.stPlaceInHead.mooDomJS" default = "0">
		<cfparam name="variables.stPlaceInHead.tabsJS" default = "0">
		<cfparam name="variables.stPlaceInHead.scriptaculousJS" default = "0">
		<cfparam name="variables.stPlaceInHead.scriptaculousDragAndDropJS" default = "0">
		<cfparam name="variables.stPlaceInHead.scriptaculousEffectsJS" default = "0">
		<cfparam name="variables.stPlaceInHead.scriptaculousBuilderJS" default = "0">
		<cfparam name="variables.stPlaceInHead.scriptaculousSliderJS" default = "0">
		<cfparam name="variables.stPlaceInHead.scriptaculousControlsJS" default = "0">
		<cfparam name="variables.stPlaceInHead.lightboxJS" default = "0">
		<cfparam name="variables.stPlaceInHead.DateTimePickerJS" default = "0">
		<cfparam name="variables.stPlaceInHead.CalendarJS" default = "0">
		<cfparam name="variables.stPlaceInHead.CalendarSetupJS" default = "0">
		<cfparam name="variables.stPlaceInHead.TinyMCEJS" default = "0">
		<cfparam name="variables.stPlaceInHead.JSONJS" default = "0">
		<cfparam name="variables.stPlaceInHead.FormValidationJS" default = "0">
		<cfparam name="variables.stPlaceInHead.prototypeTreeJS" default = "0">
		<cfparam name="variables.stPlaceInHead.prototypeTreeCSS" default = "0">
		<cfparam name="variables.stPlaceInHead.prototypeWindowJS" default = "0">
		<cfparam name="variables.stPlaceInHead.ricoJS" default = "0">
		
		<cfparam name="variables.stPlaceInHead.spryAccordionJS" default = "0">
		<cfparam name="variables.stPlaceInHead.spryXPathJS" default = "0">
		<cfparam name="variables.stPlaceInHead.spryAccordionCSS" default = "0">
		
		
		<cfparam name="variables.stPlaceInHead.jQueryJS" default = "0">
		
		
		<cfparam name="variables.stPlaceInHead.TabStyle1CSS" default = "0">
		<cfparam name="variables.stPlaceInHead.TabStyle6CSS" default = "0">
		<cfparam name="variables.stPlaceInHead.CalendarStyle1CSS" default = "0">
		
		<cfparam name="variables.stPlaceInHead.WizardCSS" default = "0">
		<cfparam name="variables.stPlaceInHead.FormsCSS" default = "0">
		<cfparam name="variables.stPlaceInHead.iehtcCSS" default = "true">
		
		
		<cfparam name="variables.stPlaceInHead.swfObjectJS" default = "0">
		
		<cfparam name="variables.stPlaceInHead.libraryPopupJS" default = "0">
		
		

		
		
		
		<cfif isDefined("Request.InHead.PrototypeLite")>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.Prototype")>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 0>
		</cfif>
		<cfif isDefined("Request.InHead.MooFX")>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 1>
			<cfset variables.stPlaceInHead.moofxJS = 1>
			<cfset variables.stPlaceInHead.moofxPackJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.MooAjax")>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 1>
			<cfset variables.stPlaceInHead.mooAjaxJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.MooDOM")>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 1>
			<cfset variables.stPlaceInHead.MooDOMJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.TabStyle1")>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 1>
			<cfset variables.stPlaceInHead.tabsJS = 1>
			<cfset variables.stPlaceInHead.TabStyle1CSS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.TabStyle6")>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 1>
			<cfset variables.stPlaceInHead.tabsJS = 1>
			<cfset variables.stPlaceInHead.TabStyle6CSS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.Scriptaculous")>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 0>
			<cfset variables.stPlaceInHead.scriptaculousJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.ScriptaculousDragAndDrop")>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 0>
			<cfset variables.stPlaceInHead.scriptaculousJS = 1>
			<cfset variables.stPlaceInHead.scriptaculousDragAndDropJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.ScriptaculousEffects")>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 0>
			<cfset variables.stPlaceInHead.scriptaculousJS = 1>
			<cfset variables.stPlaceInHead.scriptaculousEffectsJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.ScriptaculousBuilder")>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 0>
			<cfset variables.stPlaceInHead.scriptaculousJS = 1>
			<cfset variables.stPlaceInHead.scriptaculousBuilderJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.ScriptaculousSlider")>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 0>
			<cfset variables.stPlaceInHead.scriptaculousJS = 1>
			<cfset variables.stPlaceInHead.scriptaculousSliderJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.ScriptaculousControls")>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 0>
			<cfset variables.stPlaceInHead.scriptaculousJS = 1>
			<cfset variables.stPlaceInHead.scriptaculousControlsJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.Lightbox")>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 0>
			<cfset variables.stPlaceInHead.scriptaculousJS = 1>
			<cfset variables.stPlaceInHead.lightboxJS = 1>
			<cfset variables.stPlaceInHead.lightboxCSS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.DateTimePicker")>
			<cfset variables.stPlaceInHead.DateTimePickerJS = 1>
		</cfif>
		<cfif isdefined("Request.InHead.Calendar")>
			<cfset variables.stPlaceInHead.CalendarJS = 1>
			<cfset variables.stPlaceInHead.CalendarSetupJS = 1>
			<cfset variables.stPlaceInHead.CalendarStyle1CSS = 1>
		</cfif>
		<cfif isdefined("Request.InHead.TinyMCE")>
			<cfset variables.stPlaceInHead.TinyMCEJS = 1>
		</cfif>
		<cfif isdefined("Request.InHead.JSON")>
			<cfset variables.stPlaceInHead.JSONJS = 1>
		</cfif>
		
		<cfif isdefined("Request.InHead.FormValidation")>
			<cfset variables.stPlaceInHead.FormValidationJS = 1>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
			<cfset variables.stPlaceInHead.scriptaculousEffectsJS = 1>
		</cfif>
		
		<cfif isdefined("Request.InHead.Wizard")>
			<cfset variables.stPlaceInHead.WizardCSS = 1>
		</cfif>
		<cfif isdefined("Request.InHead.FormsCSS") AND Request.InHead.FormsCSS>
			<cfset variables.stPlaceInHead.FormsCSS = 1>
		</cfif>
		<cfif isdefined("Request.InHead.iehtcCSS") AND Request.InHead.iehtcCSS>
			<cfset variables.stPlaceInHead.iehtcCSS = true>
		</cfif>
		
		<cfif isDefined("Request.InHead.prototypeTree")>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 0>
			<cfset variables.stPlaceInHead.scriptaculousJS = 1>
			<cfset variables.stPlaceInHead.scriptaculousEffectsJS = 1>
			<cfset variables.stPlaceInHead.prototypeTreeJS = 1>
			<cfset variables.stPlaceInHead.prototypeTreeCSS = 1>
		</cfif>
				
		
		<cfif isDefined("Request.InHead.prototypeWindow")>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 0>
			<cfset variables.stPlaceInHead.scriptaculousJS = 1>
			<cfset variables.stPlaceInHead.scriptaculousEffectsJS = 1>
			<cfset variables.stPlaceInHead.prototypeWindowJS = 1>
		</cfif>
				
		
		<cfif isDefined("Request.InHead.rico")>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 0>
			<cfset variables.stPlaceInHead.ricoJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.spryAccordion")>
			<cfset variables.stPlaceInHead.spryAccordionJS = 1>
			<cfset variables.stPlaceInHead.spryXpathJS = 1>
			<cfset variables.stPlaceInHead.spryAccordionCSS = 1>
		</cfif>
				
				
		<cfif isDefined("Request.InHead.jQueryJS")>
			<cfset variables.stPlaceInHead.jQueryJS = 1>
		</cfif>
		
		
		<cfif isDefined("Request.InHead.swfObject") AND Request.InHead.swfObject>
			<cfset variables.stPlaceInHead.swfObjectJS = 1>
		</cfif>
		
		<cfif isDefined("Request.InHead.libraryPopup") AND Request.InHead.libraryPopup>
			<cfset variables.stPlaceInHead.libraryPopupJS = 1>
		</cfif>
		
		<cfif isDefined("request.inHead.flashWrapperToggle") AND request.inHead.flashWrapperToggle>
			<cfset variables.stPlaceInHead.prototypeJS = 1 />
			<cfset variables.stPlaceInHead.scriptaculousJS = 1>
			<cfset variables.stPlaceInHead.flashWrapperToggle = 1/>
			
		</cfif>
		
	
	<!--- Check for each stPlaceInHead variable and output relevent html/css/js --->
	<cfparam name="request.inhead" default="#structNew()#" />
			
	<cfsavecontent variable="variables.placeInHead">	
		<cfif isDefined("variables.stPlaceInHead.prototypeLiteJS") AND variables.stPlaceInHead.prototypeLiteJS AND Not variables.stPlaceInHead.prototypeJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/prototype/prototype.lite.js" type="text/javascript"></script></cfoutput>
		</cfif>
		
		<cfif isDefined("variables.stPlaceInHead.prototypeJS") AND variables.stPlaceInHead.prototypeJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/prototype/prototype.js" type="text/javascript"></script></cfoutput>
		</cfif>
		
		<cfif isDefined("variables.stPlaceInHead.mooFxJS") AND variables.stPlaceInHead.mooFxJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/moofx/moo.fx.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.mooFxPackJS") AND variables.stPlaceInHead.mooFxPackJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/moofx/moo.fx.pack.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.mooAjaxJS") AND variables.stPlaceInHead.mooAjaxJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/moofx/moo.ajax.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.mooDOMJS") AND variables.stPlaceInHead.mooDOMJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/moofx/moo.dom.js" type="text/javascript"></script></cfoutput>
		</cfif>
		
		<cfif isDefined("variables.stPlaceInHead.scriptaculousJS") AND variables.stPlaceInHead.scriptaculousJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/scriptaculous/scriptaculous.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.ScriptaculousDragAndDropJS") AND variables.stPlaceInHead.ScriptaculousDragAndDropJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/scriptaculous/dragdrop.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.ScriptaculousEffectsJS") AND variables.stPlaceInHead.ScriptaculousEffectsJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/scriptaculous/effects.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.ScriptaculousBuilderJS") AND variables.stPlaceInHead.ScriptaculousBuilderJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/scriptaculous/builder.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.ScriptaculousSliderJS") AND variables.stPlaceInHead.ScriptaculousSliderJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/scriptaculous/slider.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.ScriptaculousControlsJS") AND variables.stPlaceInHead.ScriptaculousControlsJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/scriptaculous/controls.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.lightboxJS") AND variables.stPlaceInHead.lightboxJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/lightbox/lightbox.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.lightboxCSS") AND variables.stPlaceInHead.lightboxCSS>
			<cfoutput>
				<link rel="stylesheet" href="#application.url.webroot#/js/lightbox/css/lightbox.css" type="text/css" media="screen" /></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.TabsJS") AND variables.stPlaceInHead.TabsJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/tabs/tabs.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.TabStyle1CSS") AND variables.stPlaceInHead.TabStyle1CSS>
			<cfoutput>
				<link rel="stylesheet" href="#application.url.farcry#/css/tabs/TabStyle1.css" type="text/css" media="screen" /></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.TabStyle6CSS") AND variables.stPlaceInHead.TabStyle6CSS>
			<cfoutput>
				<link rel="stylesheet" href="#application.url.farcry#/css/tabs/TabStyle6.css" type="text/css" media="screen" /></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.DateTimePickerJS") AND variables.stPlaceInHead.DateTimePickerJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/DateTimePicker/DateTimePicker.js" type="text/javascript"></script></cfoutput>
		</cfif>
		
		<cfif isDefined("variables.stPlaceInHead.CalendarJS") AND variables.stPlaceInHead.CalendarJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/calendar/calendar.js" type="text/javascript"></script>
				<script src="#application.url.farcry#/js/calendar/lang/calendar-en.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.CalendarSetupJS") AND variables.stPlaceInHead.CalendarSetupJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/calendar/calendar-setup.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.CalendarStyle1CSS") AND variables.stPlaceInHead.CalendarStyle1CSS>
			<cfoutput>
				<link rel="stylesheet" href="#application.url.farcry#/css/calendar/calendar-win2k-1.css" type="text/css" media="screen" /></cfoutput>
		</cfif>
		
		
		<cfif isDefined("variables.stPlaceInHead.TinyMCEJS") AND variables.stPlaceInHead.TinyMCEJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/tiny_mce/tiny_mce.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.JSONJS") AND variables.stPlaceInHead.JSONJS>
			<cfoutput>
				<script src="#application.url.farcry#/includes/lib/json.js" type="text/javascript"></script></cfoutput>
		</cfif>
		
		<cfif isDefined("variables.stPlaceInHead.FormValidationJS") AND variables.stPlaceInHead.FormValidationJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/formValidation/validation.js" type="text/javascript"></script></cfoutput>
		</cfif>
		
		<cfif isDefined("variables.stPlaceInHead.prototypeTreeJS") AND variables.stPlaceInHead.prototypeTreeJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/prototypeTree/prototypeTree.js" type="text/javascript"></script></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.prototypeTreeCSS") AND variables.stPlaceInHead.prototypeTreeCSS>
			<cfoutput>
				<link rel="stylesheet" href="#application.url.farcry#/js/prototypeTree/prototypeTree.css" type="text/css" media="screen" /></cfoutput>
		</cfif>
		
		
		<cfif isDefined("variables.stPlaceInHead.jQueryJS") AND variables.stPlaceInHead.jQueryJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/jquery/jquery.js" type="text/javascript"></script></cfoutput>
		</cfif>
		
		
		<cfif isDefined("variables.stPlaceInHead.WizardCSS") AND variables.stPlaceInHead.WizardCSS>
			<cfoutput>
				<link rel="stylesheet" href="#application.url.farcry#/css/wizard.css" type="text/css" media="screen" /></cfoutput>
		</cfif>
		
		<cfif isDefined("variables.stPlaceInHead.FormsCSS") AND variables.stPlaceInHead.FormsCSS>
			<cfoutput>
				<link rel="stylesheet" type="text/css" href="#application.url.farcry#/css/forms.cfm" media="all" />
			</cfoutput>
		</cfif>
		

		<cfif isDefined("variables.stPlaceInHead.iehtcCSS") AND variables.stPlaceInHead.iehtcCSS>
			<cfoutput>
				<!--[if lt IE 7]>
				<link rel="stylesheet" href="#application.url.farcry#/css/htc/iehtc.cfm" type="text/css" media="screen" />
				<![endif]-->				
			</cfoutput>
		</cfif>
				
				
				
		
		<cfif isDefined("variables.stPlaceInHead.prototypeWindowJS") AND variables.stPlaceInHead.prototypeWindowJS>
			<cfoutput>
				<script src="#application.url.farcry#/js/prototypeWindow/window.js" type="text/javascript"></script>
				<link rel="stylesheet" type="text/css" href="#application.url.farcry#/js/prototypeWindow/themes/default.css" media="all" />
				<link rel="stylesheet" type="text/css" href="#application.url.farcry#/js/prototypeWindow/themes/mac_os_x.css" media="all"  />   
			</cfoutput>
		</cfif>
		
		
		
		<cfif isDefined("variables.stPlaceInHead.ricoJS") AND variables.stPlaceInHead.ricoJS>
			<cfoutput>
				<script language="JavaScript" type="text/javascript" src="#application.url.farcry#/js/rico/rico.js"></script></cfoutput>
		</cfif>
		
		
		
		<cfif isDefined("variables.stPlaceInHead.spryAccordionJS") AND variables.stPlaceInHead.spryAccordionJS>
			<cfoutput>
				<script language="JavaScript" type="text/javascript" src="#application.url.farcry#/js/spry/SpryAccordion.js"></script></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.spryxpathJS") AND variables.stPlaceInHead.spryxpathJS>
			<cfoutput>
				<script language="JavaScript" type="text/javascript" src="#application.url.farcry#/js/spry/xpath.js"></script></cfoutput>
		</cfif>
		<cfif isDefined("variables.stPlaceInHead.spryAccordionCSS") AND variables.stPlaceInHead.spryAccordionCSS>
			<cfoutput>
				<link href="#application.url.farcry#/js/spry/css/SpryAccordion.css" rel="stylesheet" type="text/css" /></cfoutput>
		</cfif>
		



		<cfif isDefined("variables.stPlaceInHead.swfObjectJS") AND variables.stPlaceInHead.swfObjectJS EQ "true">
			<cfoutput>
				<script language="JavaScript" type="text/javascript" src="#application.url.farcry#/js/swfobject.js"></script></cfoutput>
		</cfif>


		<cfif isDefined("variables.stPlaceInHead.libraryPopupJS") AND variables.stPlaceInHead.libraryPopupJS EQ "true">
			<cfoutput>
				<script src="#application.url.farcry#/js/libraryPopup.js" type="text/javascript"></script>	</cfoutput>
		</cfif>
		
		<cfif isDefined("variables.stPlaceInHead.flashWrapperToggle") and variables.stPlaceInHead.flashWrapperToggle EQ true>
			<cfoutput>
			<script type="text/javascript">
			function toggleFlashWrapper(id,width,height,displayselects) {
				//Element.setStyle(id, {width:width})
				Element.setStyle(id, {height:height})
				
				aInputs = $$("select");
				aInputs.each(function(child) {
					if(displayselects != true){
						Element.show(child);
					} else {
						Element.hide(child);
					}
				});
				
				
			}
			</script>
			</cfoutput>
		</cfif>
		
		
		<!--- any miscellaneous stuff to be placed in the head, is put into an array aMisc --->
		<cfparam name="request.inhead.aMisc" default="#arrayNew(1)#" />
		
		<cfif arrayLen(request.inhead.aMisc)>
			<cfloop from="1" to="#arrayLen(request.inhead.aMisc)#" index="i">
				<cfoutput>
				#request.inhead.aMisc[i]#
				</cfoutput>
			</cfloop>
		</cfif>
		
		
		<!--- any miscellaneous stuff to be placed in the head, is put into an array aMisc --->
		<cfparam name="request.inhead.stCustom" default="#structNew()#" />
		<cfparam name="request.inhead.aCustomIDs" default="#arrayNew(1)#" />
		
		<cfif arrayLen(request.inhead.aCustomIDs)>
			<cfloop from="1" to="#arrayLen(request.inHead.aCustomIDs)#" index="i">
				<cfif structKeyExists(request.inHead.stCustom, request.inHead.aCustomIDs[i])>
					<cfoutput>
					#request.inHead.stCustom[request.inHead.aCustomIDs[i]]#
					</cfoutput>
				</cfif>
			</cfloop>
		</cfif>

		
	</cfsavecontent>
	
	<cfhtmlhead text="#variables.placeInHead#">
</cfif>


<!--- log visit to page --->
<cf_statsLog>

<cfsetting enablecfoutputonly="no">