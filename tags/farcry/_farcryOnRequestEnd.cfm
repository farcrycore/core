<cfsetting enablecfoutputonly="yes">

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

<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/core" prefix="core" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif structKeyExists(session, "aGritterMessages") AND arrayLen(session.aGritterMessages)>
	<skin:loadJS id="jquery" />
	<skin:loadJS id="gritter" />
	<skin:loadCSS id="gritter" />
	
	<skin:onReady>
		<cfloop from="1" to="#arrayLen(session.aGritterMessages)#" index="i">
			<cfoutput>
			$j.gritter.add({
				// (string | mandatory) the heading of the notification
				title: '#jsstringformat(session.aGritterMessages[i].title)#',
				// (string | mandatory) the text inside the notification
				text: '#jsstringformat(session.aGritterMessages[i].message)#',
				// (string | optional) the image to display on the left
				image: '#session.aGritterMessages[i].image#',
				// (bool | optional) if you want it to fade out on its own or just sit there
				sticky: #session.aGritterMessages[i].sticky#, 
				// (int | optional) the time you want it to be alive for before fading out (milliseconds)
				time: #session.aGritterMessages[i].pause#
			});
			</cfoutput>
		</cfloop>		
	</skin:onReady>
	
	<cfset session.aGritterMessages = arrayNew(1) />
</cfif>




<core:cssInHead />
<core:jsInHead />


<cfif structKeyExists(Request,"inHead") AND len(structKeyList(Request.InHead)) AND NOT request.mode.ajax>		

		<!--- THIS VERSION NUMBER IS USED TO MAKE SURE IF WE EVER REPLACE JAVASCRIPT LIBRARIES, THAT THE USERS CACHE WILL BE FLUSHED --->
		<cfset farcryJSVersion = "511c" />

		<cfparam name="variables.stPlaceInHead" default="#StructNew()#">		
		
		<cfparam name="variables.stPlaceInHead.extCoreJS" default="0">
		<cfparam name="variables.stPlaceInHead.extJS" default="0">
		<cfparam name="variables.stPlaceInHead.prototypeJS" default = "0">
		<cfparam name="variables.stPlaceInHead.prototypeLiteJS" default = "0">
		<cfparam name="variables.stPlaceInHead.tabsJS" default = "0">
		<cfparam name="variables.stPlaceInHead.scriptaculousJS" default = "0">
		<cfparam name="variables.stPlaceInHead.scriptaculousDragAndDropJS" default = "0">
		<cfparam name="variables.stPlaceInHead.scriptaculousEffectsJS" default = "0">
		<cfparam name="variables.stPlaceInHead.lightboxJS" default = "0">
		<cfparam name="variables.stPlaceInHead.DateTimePickerJS" default = "0">
		<cfparam name="variables.stPlaceInHead.CalendarJS" default = "0">
		<cfparam name="variables.stPlaceInHead.CalendarSetupJS" default = "0">
		<cfparam name="variables.stPlaceInHead.TinyMCEJS" default = "0">
		<cfparam name="variables.stPlaceInHead.JSONJS" default = "0">
		<cfparam name="variables.stPlaceInHead.dataRequestorJS" default = "0">
		<cfparam name="variables.stPlaceInHead.FormValidationJS" default = "0">
		<cfparam name="variables.stPlaceInHead.prototypeTreeJS" default = "0">
		<cfparam name="variables.stPlaceInHead.prototypeTreeCSS" default = "0">
		<cfparam name="variables.stPlaceInHead.prototypeWindowJS" default = "0">
		<cfparam name="variables.stPlaceInHead.jQueryJS" default = "0">				
		<cfparam name="variables.stPlaceInHead.TabStyle1CSS" default = "0">
		<cfparam name="variables.stPlaceInHead.TabStyle6CSS" default = "0">
		<cfparam name="variables.stPlaceInHead.CalendarStyle1CSS" default = "0">		
		<cfparam name="variables.stPlaceInHead.WizardCSS" default = "0">
		<cfparam name="variables.stPlaceInHead.FormsCSS" default = "0"> 		
		<cfparam name="variables.stPlaceInHead.iehtcCSS" default = "false">		
		<cfparam name="variables.stPlaceInHead.swfObjectJS" default = "0">		
		<cfparam name="variables.stPlaceInHead.farcryFormJS" default = "0">		
		
		
		<!--------------------- 
		CORE LIBRARIES
		 --------------------->
		<cfif isDefined("Request.InHead.extCoreJS") AND Request.InHead.extCoreJS>
			<cfset variables.stPlaceInHead.extCoreJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.extJS") AND Request.InHead.extJS>
			<cfset variables.stPlaceInHead.extCoreJS = 0>
			<cfset variables.stPlaceInHead.extJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.PrototypeLite") AND Request.InHead.PrototypeLite>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.Prototype") AND Request.InHead.Prototype>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 0>
		</cfif>
		<cfif isDefined("Request.InHead.Scriptaculous") AND Request.InHead.Scriptaculous>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 0>
			<cfset variables.stPlaceInHead.scriptaculousJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.ScriptaculousDragAndDrop") AND Request.InHead.ScriptaculousDragAndDrop>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 0>
			<cfset variables.stPlaceInHead.scriptaculousJS = 1>
			<cfset variables.stPlaceInHead.scriptaculousDragAndDropJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.ScriptaculousEffects") AND Request.InHead.ScriptaculousEffects>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 0>
			<cfset variables.stPlaceInHead.scriptaculousJS = 1>
			<cfset variables.stPlaceInHead.scriptaculousEffectsJS = 1>
		</cfif>
		<cfif isdefined("Request.InHead.JSON") AND Request.InHead.JSON>
			<cfset variables.stPlaceInHead.JSONJS = 1>
		</cfif>
		<cfif isdefined("Request.InHead.dataRequestor") AND Request.InHead.dataRequestor>
			<cfset variables.stPlaceInHead.dataRequestorJS = 1>
		</cfif>
		<cfif isdefined("Request.InHead.FormValidation") AND Request.InHead.FormValidation>
			<cfset variables.stPlaceInHead.FormValidationJS = 1>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.swfObject") AND Request.InHead.swfObject>
			<cfset variables.stPlaceInHead.swfObjectJS = 1>
		</cfif>		
		<cfif isDefined("Request.InHead.farcryForm") AND Request.InHead.farcryForm>
			<cfset variables.stPlaceInHead.farcryFormJS = 1>
		</cfif>
		
		
		
		<!--- MISCELLANEOUS LIBRARIES --->
		<cfif isDefined("Request.InHead.TabStyle1") AND Request.InHead.TabStyle1>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 1>
			<cfset variables.stPlaceInHead.tabsJS = 1>
			<cfset variables.stPlaceInHead.TabStyle1CSS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.Lightbox") AND Request.InHead.Lightbox>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 0>
			<cfset variables.stPlaceInHead.scriptaculousJS = 1>
			<cfset variables.stPlaceInHead.lightboxJS = 1>
			<cfset variables.stPlaceInHead.lightboxCSS = 1>
		</cfif>
		<cfif isDefined("Request.InHead.DateTimePicker") AND Request.InHead.DateTimePicker>
			<cfset variables.stPlaceInHead.DateTimePickerJS = 1>
		</cfif>
		<cfif isdefined("Request.InHead.Calendar") AND Request.InHead.Calendar>
			<cfset variables.stPlaceInHead.CalendarJS = 1>
			<cfset variables.stPlaceInHead.CalendarSetupJS = 1>
			<cfset variables.stPlaceInHead.CalendarStyle1CSS = 1>
		</cfif>
		<cfif isdefined("Request.InHead.TinyMCE") AND Request.InHead.TinyMCE>
			<cfset variables.stPlaceInHead.TinyMCEJS = 1>
		</cfif>
		
		
		<cfif isdefined("Request.InHead.Wizard") AND Request.InHead.Wizard>
			<cfset variables.stPlaceInHead.WizardCSS = 1>
		</cfif>
		<cfif isdefined("Request.InHead.FormsCSS") AND Request.InHead.FormsCSS>
			<cfset variables.stPlaceInHead.FormsCSS = 1>
		</cfif>
		<cfif isdefined("Request.InHead.iehtcCSS") AND Request.InHead.iehtcCSS>
			<cfset variables.stPlaceInHead.iehtcCSS = true>
		</cfif>
		
		<cfif isDefined("Request.InHead.prototypeTree") AND Request.InHead.prototypeTree>
			<cfset variables.stPlaceInHead.prototypeJS = 1>
			<cfset variables.stPlaceInHead.prototypeLiteJS = 0>
			<cfset variables.stPlaceInHead.scriptaculousJS = 1>
			<cfset variables.stPlaceInHead.scriptaculousEffectsJS = 1>
			<cfset variables.stPlaceInHead.prototypeTreeJS = 1>
			<cfset variables.stPlaceInHead.prototypeTreeCSS = 1>
		</cfif>				
				
		<cfif isDefined("Request.InHead.jQueryJS") AND Request.InHead.jQueryJS>
			<cfset variables.stPlaceInHead.jQueryJS = 1>
		</cfif>
		
		
		
		<cfif isDefined("request.inHead.flashWrapperToggle") AND request.inHead.flashWrapperToggle>
			<cfset variables.stPlaceInHead.prototypeJS = 1 />
			<cfset variables.stPlaceInHead.scriptaculousJS = 1>
			<cfset variables.stPlaceInHead.flashWrapperToggle = 1/>			
		</cfif>
		
	
	<!--- Check for each stPlaceInHead variable and output relevent html/css/js --->
	<cfparam name="request.inhead" default="#structNew()#" />
			
	<cfsavecontent variable="variables.placeInHead">		
		
		<!--- ONLY ADD THESE IF application.sysinfo.bwebtopaccess allowed --->	
		<cfif application.sysinfo.bwebtopaccess>			
			
			<!--- Used to contain CORE libraries passed to combine.cfm --->
			<cfset lCoreLibraries = "" />
			
			
			<!--- EXT --->
			<cfif variables.stPlaceInHead.extCoreJS>
				<cfset lCoreLibraries = listAppend(lCoreLibraries, "/ext/adapter/ext/ext-base.js") />
				<cfset lCoreLibraries = listAppend(lCoreLibraries, "/ext/ext-core.js") />
				<cfset lCoreLibraries = listAppend(lCoreLibraries, "/ext/ext-bubble.cfm") />
			</cfif>
		
			<cfif variables.stPlaceInHead.extJS>
				<cfset lCoreLibraries = listAppend(lCoreLibraries, "/ext/adapter/ext/ext-base.js") />
				<cfset lCoreLibraries = listAppend(lCoreLibraries, "/ext/ext-all.js") />
				<cfset lCoreLibraries = listAppend(lCoreLibraries, "/ext/ext-bubble.cfm") />
			</cfif>
			
			
			<!--- PROTOTYPE --->
			<cfif isDefined("variables.stPlaceInHead.prototypeLiteJS") AND variables.stPlaceInHead.prototypeLiteJS AND Not variables.stPlaceInHead.prototypeJS>
				<cfset lCoreLibraries = listAppend(lCoreLibraries, "/prototype/prototype.lite.js") />
			</cfif>
			
			<cfif isDefined("variables.stPlaceInHead.prototypeJS") AND variables.stPlaceInHead.prototypeJS>
				<cfset lCoreLibraries = listAppend(lCoreLibraries, "/prototype/prototype.js") />
				
			</cfif>

			<!--- SCRIPTACULOUS --->			
			<cfif isDefined("variables.stPlaceInHead.scriptaculousJS") AND variables.stPlaceInHead.scriptaculousJS>
				<cfset lCoreLibraries = listAppend(lCoreLibraries, "/scriptaculous/scriptaculous.js") /> 
			</cfif>
			<cfif isDefined("variables.stPlaceInHead.ScriptaculousEffectsJS") AND variables.stPlaceInHead.ScriptaculousEffectsJS>
				<cfset lCoreLibraries = listAppend(lCoreLibraries, "/scriptaculous/effects.js") />
			</cfif>
			<cfif isDefined("variables.stPlaceInHead.ScriptaculousDragAndDropJS") AND variables.stPlaceInHead.ScriptaculousDragAndDropJS>
				<cfset lCoreLibraries = listAppend(lCoreLibraries, "/scriptaculous/dragdrop.js") />
			</cfif>



			<!--- SWFOBJECT --->
			<cfif isDefined("variables.stPlaceInHead.swfObjectJS") AND variables.stPlaceInHead.swfObjectJS EQ "true">
				<cfset lCoreLibraries = listAppend(lCoreLibraries, "/swfobject.js") />
			</cfif>
	
			
			<!--- FARCRY FORM --->
			<cfif isDefined("variables.stPlaceInHead.farcryFormJS") AND variables.stPlaceInHead.farcryFormJS EQ "true">
				<cfset lCoreLibraries = listAppend(lCoreLibraries, "/farcryForm.cfm") />
			</cfif>		
			
			<cfif isDefined("variables.stPlaceInHead.FormValidationJS") AND variables.stPlaceInHead.FormValidationJS>
				<cfset lCoreLibraries = listAppend(lCoreLibraries, "/formValidation/validation.js") />
			</cfif>	
			
			
			<!--- JSON --->
			<cfif isDefined("variables.stPlaceInHead.JSONJS") AND variables.stPlaceInHead.JSONJS>
				<cfset lCoreLibraries = listAppend(lCoreLibraries, "/json.js") />
			</cfif>	
			<!--- JSON --->
			<cfif isDefined("variables.stPlaceInHead.dataRequestorJS") AND variables.stPlaceInHead.dataRequestorJS>
				<cfset lCoreLibraries = listAppend(lCoreLibraries, "/DataRequestor.js") />
			</cfif>			
			
			<!------------------------------------------------ 
			COMBINE ALL THE REQUESTED CORE LIBRARIES 
			------------------------------------------------>
			<cfif len(lCoreLibraries)>
				<cfoutput>
					<script type="text/javascript" src="#application.url.farcry#/js/combine.cfm?ajaxmode=1&amp;files=#lCoreLibraries#&amp;fjsv=#farcryJSVersion#"></script></cfoutput>
			</cfif>
			
						
			<!--- Prototype Tree --->
			<cfif isDefined("variables.stPlaceInHead.prototypeTreeJS") AND variables.stPlaceInHead.prototypeTreeJS>
				<cfoutput>
					<script src="#application.url.farcry#/js/prototypeTree/prototypeTree.js?fjsv=#farcryJSVersion#" type="text/javascript"></script></cfoutput>
			</cfif>
			
			<!--- LIGHTBOX --->
			<cfif isDefined("variables.stPlaceInHead.lightboxJS") AND variables.stPlaceInHead.lightboxJS>
				<cfoutput>
					<script type="text/javascript" src="#application.url.farcry#/js/lightbox/lightbox.js?fjsv=#farcryJSVersion#"></script></cfoutput>
			</cfif>
			
			<!--- TABS --->
			<cfif isDefined("variables.stPlaceInHead.TabsJS") AND variables.stPlaceInHead.TabsJS>
				<cfoutput>
					<script type="text/javascript" src="#application.url.farcry#/js/tabs/tabs.js?fjsv=#farcryJSVersion#"></script></cfoutput>
			</cfif>
			
			<!--- DATE PICKER --->
			<cfif isDefined("variables.stPlaceInHead.DateTimePickerJS") AND variables.stPlaceInHead.DateTimePickerJS>
				<cfoutput>
					<script type="text/javascript" src="#application.url.farcry#/js/DateTimePicker/DateTimePicker.js?fjsv=#farcryJSVersion#"></script></cfoutput>
			</cfif>
			
			
			<!--- CALENDAR --->
			<cfset lLibraries = "" />
			<cfif isDefined("variables.stPlaceInHead.CalendarJS") AND variables.stPlaceInHead.CalendarJS>
				<cfset lLibraries = listAppend(lLibraries, "/calendar/calendar.js") />
				<cfset lLibraries = listAppend(lLibraries, "/calendar/lang/calendar-en.js") />
			</cfif>
			<cfif isDefined("variables.stPlaceInHead.CalendarSetupJS") AND variables.stPlaceInHead.CalendarSetupJS>
				<cfset lLibraries = listAppend(lLibraries, "/calendar/calendar-setup.js") />
			</cfif>			
			<cfif len(lLibraries)>
				<cfoutput>
					<script type="text/javascript" src="#application.url.farcry#/js/combine.cfm?files=#lLibraries#&amp;fjsv=#farcryJSVersion#"></script></cfoutput>
			</cfif>
			
			
			
			<!--- TINY MCE --->
			<cfif isDefined("variables.stPlaceInHead.TinyMCEJS") AND variables.stPlaceInHead.TinyMCEJS>
				<cfoutput>
					<script src="#application.url.webtop#/js/tiny_mce/tiny_mce.js?fjsv=#farcryJSVersion#" type="text/javascript"></script></cfoutput>
			</cfif>


			<!--- JQUERY --->
			<cfif isDefined("variables.stPlaceInHead.jQueryJS") AND variables.stPlaceInHead.jQueryJS>
				<cfoutput>
					<script src="#application.url.farcry#/js/jquery/jquery.js?fjsv=#farcryJSVersion#" type="text/javascript"></script></cfoutput>
			</cfif>
			
	
			
			
						
	

			
			
			<cfif variables.stPlaceInHead.extCoreJS OR  variables.stPlaceInHead.extJS>
				<cfoutput>
					<link rel="stylesheet" type="text/css" href="#application.url.farcry#/js/ext/resources/css/ext-all.css" />
					<style type="text/css">
					.msg .x-box-mc {font-size:14px;}
					##msg-div {position:absolute;top:10px;width:250px;z-index:20000;}
					</style>
					<script type="text/javascript">Ext.BLANK_IMAGE_URL = '#application.url.webtop#/js/ext/resources/images/default/s.gif';</script>
				</cfoutput>
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
			
			
			
			

			
			<!--- INCLUDE CSS --->
		
			<cfif isDefined("variables.stPlaceInHead.prototypeTreeCSS") AND variables.stPlaceInHead.prototypeTreeCSS>
				<cfoutput>
					<link rel="stylesheet" href="#application.url.farcry#/js/prototypeTree/prototypeTree.css?fjsv=#farcryJSVersion#" type="text/css" media="screen" /></cfoutput>
			</cfif>			
			
			<cfif isDefined("variables.stPlaceInHead.WizardCSS") AND variables.stPlaceInHead.WizardCSS>
				<cfoutput>
					<link rel="stylesheet" href="#application.url.farcry#/css/wizard.css?fjsv=#farcryJSVersion#" type="text/css" media="screen" /></cfoutput>
			</cfif>
			
			<cfif isDefined("variables.stPlaceInHead.FormsCSS") AND variables.stPlaceInHead.FormsCSS>
				<cfoutput>
					<link rel="stylesheet" type="text/css" href="#application.url.farcry#/css/forms.cfm?fjsv=#farcryJSVersion#" media="all" />
				</cfoutput>
			</cfif>
			
			<cfif isDefined("variables.stPlaceInHead.lightboxCSS") AND variables.stPlaceInHead.lightboxCSS>
				<cfoutput>
					<link rel="stylesheet" href="#application.url.farcry#/css/lightbox/lightbox.css?fjsv=#farcryJSVersion#" type="text/css" media="screen" /></cfoutput>
			</cfif>
			<cfif isDefined("variables.stPlaceInHead.TabStyle1CSS") AND variables.stPlaceInHead.TabStyle1CSS>
				<cfoutput>
					<link rel="stylesheet" href="#application.url.farcry#/css/tabs/TabStyle1.css?fjsv=#farcryJSVersion#" type="text/css" media="screen" /></cfoutput>
			</cfif>
			<cfif isDefined("variables.stPlaceInHead.CalendarStyle1CSS") AND variables.stPlaceInHead.CalendarStyle1CSS>
				<cfoutput>
					<link rel="stylesheet" href="#application.url.farcry#/css/calendar/calendar-win2k-1.css?fjsv=#farcryJSVersion#" type="text/css" media="screen" /></cfoutput>
			</cfif>
						
	
			<cfif isDefined("variables.stPlaceInHead.iehtcCSS") AND variables.stPlaceInHead.iehtcCSS>
				<cfoutput>
					<!--[if lt IE 7]>
					<link rel="stylesheet" href="#application.url.farcry#/css/htc/iehtc.cfm?fjsv=#farcryJSVersion#" type="text/css" media="screen" />
					<![endif]-->				
				</cfoutput>
			</cfif>
					
					
								
			
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
		
			
		<!--- any extjs onready stuff to be placed in the head, is put into an array aMisc --->
		<cfparam name="request.inhead.stOnReady" default="#structNew()#" />
		<cfparam name="request.inhead.aOnReadyIDs" default="#arrayNew(1)#" />
		
		<cfif arrayLen(request.inhead.aOnReadyIDs)>
			<cfoutput>
			<script type="text/javascript">
				$j(document).ready(function() {	
			</cfoutput>
			
			<cfloop from="1" to="#arrayLen(request.inHead.aOnReadyIDs)#" index="i">
				<cfif structKeyExists(request.inHead.stOnReady, request.inHead.aOnReadyIDs[i])>
					<cfoutput>
					#request.inHead.stOnReady[request.inHead.aOnReadyIDs[i]]#
					</cfoutput>
				</cfif>
			</cfloop>
			
			<cfoutput>
				})
			</script>
			</cfoutput>
			
		</cfif>

		
	</cfsavecontent>
	
	<cfif len(variables.placeInHead)>
 		<cfhtmlHead text="#variables.placeInHead#" />
	</cfif>
</cfif>



<!--- USED TO DETERMINE OVERALL PAGE TICKCOUNT --->
<cfset request.farcryPageTimerEnd = getTickCount() />

<cfif structKeyExists(request, "farcryPageTimerStart")>
	<cfset farcryPageLoadTimer = request.farcryPageTimerEnd - request.farcryPageTimerStart />
	<cftrace var="farcryPageLoadTimer" />
</cfif>


<cfsetting enablecfoutputonly="no">