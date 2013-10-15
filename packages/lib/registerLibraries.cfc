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
		<skin:registerJS 	id="fc-jquery" core="true"
							baseHREF="#application.url.webtop#/thirdparty/jquery/js"
							lFiles="jquery-1.9.1.min.js,noconflict.js" />
		<skin:registerJS 	id="jquery" aliasof="fc-jquery" core="false" />
			
		<skin:registerJS 	id="fc-jquery-ui" core="true"
							baseHREF="#application.url.webtop#/thirdparty/jquery/js"
							lFiles="jquery-ui-1.10.3.custom.min.js" bCombine="false" />
		<skin:registerJS 	id="jquery-ui" aliasof="fc-jquery-ui" core="false" />
		
		<skin:registerJS 	id="fc-underscore" core="true"
							baseHREF="#application.url.webtop#/thirdparty/underscore"
							lFiles="underscore.js" />
		<skin:registerJS 	id="underscore" aliasof="fc-underscore" core="false" />
		
		<skin:registerJS 	id="fc-backbone" core="true"
							baseHREF="#application.url.webtop#/thirdparty/backbone"
							lFiles="backbone.js" />
		<skin:registerJS 	id="backbone" aliasof="fc-backbone" core="false" />
		
		<skin:registerJS 	id="fc-handlebars" core="true"
							baseHREF="#application.url.webtop#/thirdparty/handlebars"
							lFiles="handlebars.js" />
		<skin:registerJS 	id="handlebars" aliasof="fc-handlebars" core="false" />
		
		<skin:registerJS 	id="tinymce" core="true" bCombine="false"
							baseHREF="#application.url.webtop#/thirdparty/tiny_mce"
							lFiles="tinymce.min.js" />

		<skin:registerJS 	id="jquery-validate" core="true"
							baseHREF="#application.url.webtop#/thirdparty/jquery-validate"
							lFiles="jquery.validate.js" />

		<skin:registerJS 	id="jquery-tooltip" core="true"
							baseHREF="#application.url.webtop#/thirdparty/jquery-tooltipster/js"
							lFiles="jquery.tooltipster.min.js" />

		<skin:registerJS	id="jquery-tooltip-auto" core="true">
							<cfoutput>
								jQuery(function(){
									// tooltip for title attributes
									$j('a[title],div[title],span[title],area[title]').not('.fancybox,.nojqtooltip,.fc-tooltip,.fc-richtooltip').tooltip();
									// tooltip for fc-tooltip elements
									$j('.fc-tooltip').tooltip();
									// rich tooltip for fc-richtooltip elements
									$j('.fc-richtooltip').each(function(){
										var $this = $j(this);
										var position = $this.data("tooltip-position") || "";
										var width = $this.data("tooltip-width") || 0;
										$this.tooltipster({
											theme: ".tooltipster-light",
											position: position,
											fixedWidth: width,
											delay: 0,
											speed: 200
										});
									});
								});
							</cfoutput>
		</skin:registerJS>

		<skin:registerJS 	id="jquery-autoresize" core="true"
							baseHREF="#application.url.webtop#/thirdparty/jquery.autoresize" 
							lFiles="jquery.autosize-min.js" />
		
		<skin:registerJS	id="image-formtool" core="true"
							baseHREF="#application.url.webtop#/thirdparty/image-formtool"
							lFiles="image-formtool.js" />
							
		<skin:registerJS	id="jquery-uploadify" core="true"
							baseHREF="#application.url.webtop#/thirdparty/jquery.uploadify-v2.1.4"
							lFiles="swfobject.js,jquery.uploadify.v2.1.4.min.js" />
							
		<skin:registerJS	id="jquery-crop" core="true"
							baseHREF="#application.url.webtop#/thirdparty/Jcrop/js"
							lFiles="jquery.Jcrop.js" />
							
		<skin:registerJS 	id="gritter" core="true"
							baseHREF="#application.url.webtop#/thirdparty/gritter/js"
							lFiles="jquery.gritter.js" />

		<skin:registerJS	id="jquery-file-upload" core="true"
							baseHREF="#application.url.webtop#/thirdparty/jQuery-File-Upload-8.1.0"
							lFiles="vendor/jquery.ui.widget.js,jquery.iframe-transport.js,jquery.fileupload.js,jquery.fileupload-process.js,jquery.fileupload-validate.js,jquery.fileupload-validate.js" />
		
		<skin:registerJS	id="bulk-upload" core="true"
							baseHREF="#application.url.webtop#/js/bulkUploader"
							lFiles="bulk-upload.js" />
							
		<skin:registerJS 	id="farcry-form" core="true"
							baseHREF="#application.url.webtop#"
							lFiles="/js/farcryForm.cfm,/thirdparty/loadmask/jquery.loadmask.min.js,/thirdparty/jquery-treeview/jquery.treeview.js,/thirdparty/jquery-treeview/jquery.treeview.async.js" />
		
		
		<skin:registerJS 	id="fc-uniform" core="true"
							baseHREF="#application.url.webtop#"
							lFiles="/thirdparty/uni-form/js/uni-form.jquery.js" />
		
		
		<skin:registerJS	id="jquery-tree" core="true"
							baseHREF="#application.url.webtop#/thirdparty/jqTree"
							lFiles="tree.jquery.js" />
		
		<skin:registerJS	id="category-formtool" core="true"
							baseHREF="#application.url.webtop#/thirdparty/jqTree"
							lFiles="category-formtool.js" />
		
		<skin:registerJS 	id="fc-ext" core="true"
							baseHREF="#application.url.webtop#/js/ext"
							lFiles="/adapter/ext/ext-base.js,/ext-all.js">
							<cfoutput>
							Ext.BLANK_IMAGE_URL = '#application.url.webtop#/js/ext/resources/images/default/s.gif';
							</cfoutput>
		</skin:registerJS>
		
		<skin:registerJS 	id="fc-farcry-devicetype" core="true"
							baseHREF="#application.url.webtop#/js"
							lFiles="devicetype.js" />
		<skin:registerJS 	id="farcry-devicetype" aliasof="fc-farcry-devicetype" core="false" />
		
		<skin:registerJS 	id="swfobject" core="true"
							baseHREF="#application.url.webtop#/js"
							lFiles="swfobject.js" />
							
		<skin:registerJS 	id="jquery-modal" core="true"
							baseHREF="#application.url.webtop#/thirdparty/jquery-modal"
							lFiles="jquery-modal.js" />
		
		<skin:registerJS	id="fc-bootstrap" core="true"
							baseHREF='#application.url.webtop#/thirdparty/bootstrap'
							lFiles="bootstrap.min.js" />

		<skin:registerJS	id="fc-bootstrap-tray" core="true"
							baseHREF='#application.url.webtop#/thirdparty/bootstrap-tray'
							lFiles="bootstrap.js" />

		<skin:registerJS	id="bootstrap-datepicker" core="true"
							baseHREF="#application.url.webtop#/thirdparty/bootstrap-datepicker"
							lFiles="bootstrap-datepicker.js" />
		
		<skin:registerJS	id="webtop7" core="true"
							baseHREF='#application.url.webtop#/js'
							lFiles="webtop7.js" />
							
		<skin:registerJS	id="typeahead" core="true"
							baseHREF="#application.url.webtop#/thirdparty/select2" 
							lFiles="select2.js,typeahead.js" />
		
		<!--- CSS LIBRARIES --->
		<skin:registerCSS 	id="webtop7"
							baseHREF="#application.url.webtop#/css"
							lFiles="webtop7.css,main7.css" />

		<skin:registerCSS 	id="webtop"
							baseHREF="#application.url.webtop#/css"
							lFiles="reset.css,fonts.css,main.css" />
							
		<skin:registerCSS	id="bulk-upload"
							baseHREF="#application.url.webtop#/js/bulkUploader"
							lFiles="bulk-upload.css" />
							
		<skin:registerCSS 	id="fc-login"
							baseHREF="#application.url.webtop#/css"
							lFiles="login7.css" />
							
		<skin:registerCSS	id="fc-bootstrap"
							baseHREF="#application.url.webtop#/thirdparty/bootstrap"
							lFiles="bootstrap.min.css"
							bCombined="false" />

		<skin:registerCSS	id="fc-bootstrap-tray"
							baseHREF="#application.url.webtop#/thirdparty/bootstrap-tray"
							lFiles="bootstrap.css"
							bCombined="false" />

		<skin:registerCSS	id="bootstrap-datepicker"
							baseHREF="#application.url.webtop#/thirdparty/bootstrap-datepicker"
							lFiles="bootstrap-datepicker.css" />
		
		<skin:registerCSS	id="fc-uniform"
							baseHREF="#application.url.webtop#"
							lFiles="/thirdparty/uni-form/css/uni-form-generic.css,/thirdparty/uni-form/css/uni-form.css"
							bCombined="false" />
							
		<skin:registerCSS	id="fc-icons"
							baseHREF="#application.url.webtop#/css"
							lFiles="" /><!--- icons.css. removed for incompatibility with font-awesome. re-apply as required. --->
							
		<skin:registerCSS	id="fc-fontawesome"
							baseHREF="#application.url.webtop#/thirdparty/font-awesome-3.2.1/css"
							lFiles="font-awesome.css" />
							
		<skin:registerCSS 	id="jquery-ui"
							baseHREF="#application.url.webtop#/thirdparty/jquery/css/smoothness"
							lFiles="jquery-ui-1.10.3.custom.css" />
		
		<skin:registerCSS	id="image-formtool"
							baseHREF="#application.url.webtop#/thirdparty/image-formtool"
							lFiles="image-formtool.css" />
							
		<skin:registerCSS	id="jquery-uploadify"
							baseHREF="#application.url.webtop#/thirdparty/jquery.uploadify-v2.1.4"
							lFiles="uploadify.css" />
							
		<skin:registerCSS	id="jquery-crop"
							baseHREF="#application.url.webtop#/thirdparty/Jcrop/css"
							lFiles="jquery.Jcrop.css" />
							
		<skin:registerCSS 	id="jquery-modal"
							baseHREF="#application.url.webtop#/thirdparty/jquery-modal"
							lFiles="jquery-modal.css" />
		
		<skin:registerCSS	id="jquery-tree" core="true"
							baseHREF="#application.url.webtop#/thirdparty/jqTree"
							lFiles="jqtree.css" />
		
		<skin:registerCSS 	id="farcry-form"
							baseHREF="#application.url.webtop#"
							lFiles="/css/wizard.css,/thirdparty/loadmask/jquery.loadmask.css,/thirdparty/jquery-treeview/jquery.treeview.css,/css/farcryform.css">
							
							<cfoutput>
							ul.treeview span { font-size:10px; vertical-align: top}
							ul.treeview span:hover { color: red; }
							ul.treeview span input { margin-right: 5px; }
							ul.treeview .hover { color: ##000; }
							</cfoutput>
		</skin:registerCSS>
		
		<skin:registerCSS	id="objectadmin-ie7"
							baseHREF="#application.url.webtop#/css"
							lFiles="objectadmin-ie7.css"
							condition="if IE 7" />

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
							baseHREF="#application.url.webtop#/thirdparty/jquery-tooltipster/css"
							lFiles="tooltipster.css,themes/tooltipster-light.css" />

		<skin:registerCSS 	id="ext"
							baseHREF="#application.url.webtop#/js/ext"
							lFiles="/resources/css/ext-all.css" />		
							
		<skin:registerCSS	id="typeahead" 
							baseHREf="#application.url.webtop#/thirdparty/select2" 
							lFiles="select2.css" append=".chzn-container-multi .chzn-choices .search-choice .search-choice-close { padding:0; }" />	
														
	</cffunction>	
	
</cfcomponent>