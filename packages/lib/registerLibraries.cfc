<cfcomponent displayname="Third Parth Library Registration" 
	hint="allows for the registration and loading of third party js and css libraries" output="No">



	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="Any">
		
		<cfset registerCoreLibraries() />
		
		<cfreturn this>
	</cffunction>



	<cffunction name="registerCoreLibraries" access="private" returntype="void" output="false" hint="Registers core js and css libraries">
	
		<!--- import tag libraries ---> 
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfset application.fc.stJSLibraries = structNew() />
		<cfset application.fc.stCSSLibraries = structNew() />
		
		<!--- JS LIBRARIES --->
		<skin:registerJS 	id="jquery"
							baseHREF="#application.url.webtop#/thirdparty/jquery/js"
							lFiles="jquery-1.3.2.min.js">
							
							<cfoutput>
								var $j = jQuery.noConflict();
								var $ = jQuery.noConflict();							
							</cfoutput>	
		</skin:registerJS>		
			
		<skin:registerJS 	id="jquery-ui"
							baseHREF="#application.url.webtop#/thirdparty/jquery/js"
							lFiles="ui.core.js,ui.accordion.js,ui.datepicker.js,ui.dialog.js,ui.draggable.js,ui.droppable.js,ui.progressbar.js,ui.resizable.js,ui.selectable.js,ui.slider.js,ui.sortable.js,ui.tabs.js,effects.core.js,effects.blind.js,effects.bounce.js,effects.clip.js,effects.drop.js,effects.explode.js,effects.fold.js,effects.highlight.js,effects.pulsate.js,effects.scale.js,effects.shake.js,effects.slide.js,effects.transfer.js" />
		
			
				

		<skin:registerJS 	id="tinymce"
							baseHREF="#application.url.webtop#/thirdparty/tiny_mce"
							lFiles="tiny_mce_gzip.js"
							bCombine="false" />

		<skin:registerJS 	id="jquery-validate"
							baseHREF="#application.url.webtop#/thirdparty/jquery-validate"
							lFiles="jquery.validate.pack.js" />

		<skin:registerJS 	id="jquery-tooltip"
							baseHREF="#application.url.webtop#/thirdparty/jquery-tooltip"
							lFiles="jquery.tooltip.min.js" />
							
							
		<skin:registerJS 	id="gritter"
							baseHREF="#application.url.webtop#/thirdparty/gritter/js"
							lFiles="jquery.gritter.js" />

		<skin:registerJS 	id="farcry-form"
							baseHREF="#application.url.webtop#"
							lFiles="/js/farcryForm.cfm,/thirdparty/loadmask/jquery.loadmask.min.js,/thirdparty/uni-form/js/uni-form.jquery.js" />

		<skin:registerJS 	id="ext"
							baseHREF="#application.url.webtop#/js/ext"
							lFiles="/adapter/ext/ext-base.js,/ext-all.js">
							<cfoutput>
							Ext.BLANK_IMAGE_URL = '#application.url.webtop#/js/ext/resources/images/default/s.gif';
							</cfoutput>
		</skin:registerJS>
							
	
		<skin:registerJS 	id="swfobject"
							baseHREF="#application.url.webtop#/js"
							lFiles="swfobject.js" />

		<!--- CSS LIBRARIES --->
		<skin:registerCSS 	id="webtop"
							baseHREF="#application.url.webtop#/css"
							lFiles="reset.css,fonts.css,main.css" />
							
		<skin:registerCSS 	id="jquery-ui"
							baseHREF="#application.url.webtop#/thirdparty/jquery/css/base"
							lFiles="ui.core.css,ui.resizable.css,ui.accordion.css,ui.dialog.css,ui.slider.css,ui.tabs.css,ui.datepicker.css,ui.progressbar.css,ui.theme.css">
							
							<cfoutput>
							.ui-widget {font-size:1em;}
							.ui-dialog .ui-dialog-titlebar {padding:1px 5px 1px 5px;}
							.ui-dialog .ui-dialog-content { padding:0.5em 0; }
							</cfoutput>
		</skin:registerCSS>
				
		<skin:registerCSS 	id="farcry-form"
							baseHREF="#application.url.webtop#"
							lFiles="/css/wizard.css,/thirdparty/loadmask/jquery.loadmask.css,/thirdparty/uni-form/css/uni-form-generic.css,/thirdparty/uni-form/css/uni-form.css" />

		<skin:registerCSS 	id="farcry-pagination"
							baseHREF="#application.url.webtop#"
							lFiles="/css/pagination.css" />

							
		<skin:registerCSS 	id="gritter"
							baseHREF="#application.url.webtop#/thirdparty/gritter/css"
							lFiles="gritter.css" />
							
		<skin:registerCSS 	id="farcry-tray"
							lDependsOn="jquery-ui,jquery-tooltip"
							baseHREF="#application.url.webtop#/css"
							lFiles="tray.css" />
				
		<skin:registerCSS 	id="jquery-tooltip"
							baseHREF="#application.url.webtop#/thirdparty/jquery-tooltip"
							lFiles="jquery.tooltip.css" />		
				
		<skin:registerCSS 	id="ext"
							baseHREF="#application.url.webtop#/js/ext"
							lFiles="/resources/css/ext-all.css" />		
							
							
														
	</cffunction>	
	
</cfcomponent>