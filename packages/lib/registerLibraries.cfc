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
							lFiles="jquery-1.4.3.min.js">
							
							<cfoutput>
								var $j = jQuery.noConflict();
								var $ = jQuery.noConflict();							
							</cfoutput>	
		</skin:registerJS>		
			
		<skin:registerJS 	id="jquery-ui"
							baseHREF="#application.url.webtop#/thirdparty/jquery-1-4-1/js"
							lFiles="jquery-ui-1.8.custom.min.js" />
		
		<skin:registerJS 	id="tinymce"
							baseHREF="#application.url.webtop#/thirdparty/tiny_mce"
							lFiles="jquery.tinymce.js" />

		<skin:registerJS 	id="jquery-validate"
							baseHREF="#application.url.webtop#/thirdparty/jquery-validate"
							lFiles="jquery.validate.js" />

		<skin:registerJS 	id="jquery-tooltip"
							baseHREF="#application.url.webtop#/thirdparty/jquery-tooltip"
							lFiles="jquery.tooltip.min.js" />
		<skin:registerJS	id="jquery-tooltip-auto">
							<cfoutput>
								jQuery(function(){
									jQuery('a[title],div[title],span[title],area[title]').not('.fancybox,.nojqtooltip').tooltip({ 
									    delay: 0, 
									    showURL: false
									});
								});
							</cfoutput>
		</skin:registerJS>
		
		<skin:registerJS	id="jquery-uploadify"
							baseHREF="#application.url.webtop#/thirdparty/jquery.uploadify-v2.1.4"
							lFiles="swfobject.js,jquery.uploadify.v2.1.4.min.js" />
							
		<skin:registerJS	id="jquery-crop"
							baseHREF="#application.url.webtop#/thirdparty/Jcrop/js"
							lFiles="jquery.Jcrop.js" />
							
							
		<skin:registerJS 	id="gritter"
							baseHREF="#application.url.webtop#/thirdparty/gritter/js"
							lFiles="jquery.gritter.js" />

		<skin:registerJS 	id="farcry-form"
							baseHREF="#application.url.webtop#"
							lFiles="/js/farcryForm.cfm,/thirdparty/loadmask/jquery.loadmask.min.js,/thirdparty/uni-form/js/uni-form.jquery.js,/thirdparty/jquery-treeview/jquery.treeview.js,/thirdparty/jquery-treeview/jquery.treeview.async.js" />

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
							baseHREF="#application.url.webtop#/thirdparty/jquery-1-4-1/css/base"
							lFiles="jquery-ui-1.8.custom.css">
							
							<cfoutput>
							.ui-widget {font-size:1em;}
							.ui-dialog .ui-dialog-titlebar {padding:1px 5px 1px 5px;}
							.ui-dialog .ui-dialog-content { padding:0.5em 0; }
							</cfoutput>
		</skin:registerCSS>
		
		<skin:registerCSS	id="jquery-uploadify"
							baseHREF="#application.url.webtop#/thirdparty/jquery.uploadify-v2.1.4"
							lFiles="uploadify.css" />
							
		<skin:registerCSS	id="jquery-crop"
							baseHREF="#application.url.webtop#/thirdparty/Jcrop/css"
							lFiles="jquery.Jcrop.css" />
				
		<skin:registerCSS 	id="farcry-form"
							baseHREF="#application.url.webtop#"
							lFiles="/css/wizard.css,/thirdparty/loadmask/jquery.loadmask.css,/thirdparty/uni-form/css/uni-form-generic.css,/thirdparty/uni-form/css/uni-form.css,/thirdparty/jquery-treeview/jquery.treeview.css">
							
							<cfoutput>
							ul.treeview span { font-size:10px; vertical-align: top}
							ul.treeview span:hover { color: red; }
							ul.treeview span input { margin-right: 5px; }
							ul.treeview .hover { color: ##000; }
							</cfoutput>
		</skin:registerCSS>

		<skin:registerCSS 	id="farcry-pagination"
							baseHREF="#application.url.webtop#"
							lFiles="/css/pagination.css" />

							
		<skin:registerCSS 	id="gritter"
							baseHREF="#application.url.webtop#/thirdparty/gritter/css"
							lFiles="gritter.css" />
							
		<skin:registerCSS 	id="headerblock"
							baseHREF="#application.url.webtop#/thirdparty/headerblock"
							lFiles="default.css" />
							
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