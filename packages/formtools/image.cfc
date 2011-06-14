<!--- @@Copyright: Copyright (c) 2010 Daemon Pty Limited. All rights reserved. ---> 
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

<!--- @@examples:
	<p>This example is taken from dmImage.cfc in farcry core. It has a source Image example, standard image example and thumbnail image example</p>
	<cfproperty ftSeq="22" ftFieldset="Image Files" name="SourceImage" type="string" hint="The URL location of the uploaded image" required="No" default="" 
	ftType="Image" 
	ftCreateFromSourceOption="false" 
	ftAllowResize="false"
	ftDestination="/images/dmImage/SourceImage" 
	ftlabel="Source Image" 
	ftImageWidth="" 
	ftImageHeight=""
	ftbUploadOnly="true"
	ftHint="Upload your high quality source image here."  />

<cfproperty ftSeq="24" ftFieldset="Image Files" name="StandardImage" type="string" hint="The URL location of the optimised uploaded image that should be used for general display" required="no" default="" 
	ftType="Image" 
	ftDestination="/images/dmImage/StandardImage" 
	ftImageWidth="400" 
	ftImageHeight="1000" 
	ftAutoGenerateType="FitInside" 
	ftSourceField="SourceImage" 
	ftCreateFromSourceDefault="true" 
	ftAllowUpload="true" 
	ftQuality=".75"
	ftlabel="Mid Size Image"
	ftHint="This image is generally used throughout your project as the main image. Most often you would have this created automatically from the high quality source image you upload." />  

<cfproperty ftSeq="26" ftFieldset="Image Files" name="ThumbnailImage" type="string" hint="The URL location of the thumnail of the uploaded image that should be used in " required="no" default="" 
	ftType="Image"  
	ftDestination="/images/dmImage/ThumbnailImage" 
	ftImageWidth="80" 
	ftImageHeight="80" 
	ftAutoGenerateType="center"
	ftSourceField="SourceImage" 
	ftCreateFromSourceDefault="true" 
	ftAllowUpload="true" 
	ftQuality=".75"
	ftlabel="Thumbnail Image"
	ftHint="This image is generally used throughout your project as the thumbnail teaser image. Most often you would have this created automatically from the high quality source image you upload." />

<p>Image with no resize otions</p>

<cfproperty name="featureImage" type="string" hint="Feature image for Lysaght site (landscape)." required="no" default="" 
	ftwizardStep="Body" 
	ftseq="34" ftfieldset="Feature Image" 
	ftAllowResize="false"
	ftType="image" 
	ftDestination="/images/lysaght/bslCaseStudy/featureImage" 
	ftlabel="Feature Image" />

--->


<cfcomponent name="Image" displayname="image" Extends="field" hint="Field component to liase with all Image types">
	<!--- 
	 // documentation 
	--------------------------------------------------------------------------------------------------->
	<cfproperty name="ftstyle" type="string" hint="???" required="false" default="" />
	<cfproperty name="ftDestination" type="string" hint="???" required="false" default="/images" />
	<!--- <cfproperty name="ftSourceField" type="string" hint="???" required="false" default="" /> --->
	<cfproperty name="ftCreateFromSourceOption" type="boolean" hint="???" required="false" default="true" />
	<cfproperty name="ftCreateFromSourceDefault" type="boolean" hint="???" required="false" default="true" />
	<cfproperty name="ftAllowUpload" type="boolean" hint="If there is more than one image, e.g thumbnail, use this to allow uploading a different thumbnail or turn this off to only autogenerate thumbnail from source image" required="false" default="true" />
	<cfproperty name="ftAllowResize" type="boolean" hint="Will not allow any resize options if switched off" required="false" default="true" />
	<cfproperty name="ftAllowResizeQuality" type="boolean" hint="Will not allow any quality change options if switched off" required="false" default="false" />
	<cfproperty name="ftImageWidth" type="string" hint="Use to resize an image from a source image" required="false" default="" />
	<cfproperty name="ftImageHeight" type="string" hint="Use to resize an image from a source image" required="false" default="" />
	<cfproperty name="ftAutoGenerateType" type="string" hint="Auto generate options include: none, center, fitinside, forcesize, pad, topcenter, topleft, topright, left, right, bottomleft, bottomcenter, bottomright." required="false" default="FitInside" />
	<cfproperty name="ftPadColor" type="string" hint="If ftAutoGenerateType = pad, this will be the colour of the pad" required="false" default="##ffffff" />
	<cfproperty name="ftShowConversionInfo" type="boolean" hint="Set to false to hide the conversion information that will be applied to the uploaded image." required="false" default="true" />
	<cfproperty name="ftAllowedExtensions" type="string" hint="The extensions allowed to be uploaded." required="false" default="jpg,jpeg,png,gif" />
	<cfproperty name="ftcustomEffectsObjName" type="string" hint="<cfimage> support property" required="false" default="imageeffects" />
	<cfproperty name="ftlCustomEffects" type="string" hint="<cfimage> support property" required="false" default="" />
	<cfproperty name="ftConvertImageToFormat" type="string" hint="<cfimage> support property" required="false" default="" />
	<cfproperty name="ftbSetAntialiasing" type="boolean" hint="<cfimage> support property" required="false" default="true" />
	<cfproperty name="ftInterpolation" type="string" hint="<cfimage> support property" required="false" default="highestQuality" />
	<cfproperty name="ftQuality" type="numeric" hint="<cfimage> support property" required="false" default="0.75" />
	<cfproperty name="ftbUploadOnly" type="boolean" hint="Only upload the image and do not optimize or process it. Very useful for source images. Otherwise FarCry will optimize the source image, then read from that dequalitized image to make other optimized images. Can be used for any image field (not just source images)." required="false" default="false" />
	<cfproperty name="ftCropPosition" type="string" hint="Used when ftAutoGenerateType = aspectCrop" required="false" default="center" />
	<cfproperty name="ftThumbnailBevel" type="boolean" hint="???" required="false" default="false" />
	<cfproperty name="ftWatermark" type="string" hint="The path relative to the webroot of an image to use as a watermark." required="false" default="" />
	<cfproperty name="ftWatermarkTransparency" type="numeric" hint="The transparency to apply to the watermark." required="false" default="90" />
	
	
	
	<!--- 
	 // formtool methods 
	--------------------------------------------------------------------------------------------------->
	<cffunction name="init" access="public" returntype="any" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
	    <cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
	    <cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
	    <cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
	    <cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
	    <cfargument name="stPackage" required="true" type="struct" hint="Contains the metadata for the all fields for the current typename.">
	    
	    
	    <cfset var html = "" />
	    <cfset var previewHTML = "" />
	    <cfset var dimensionAlert = "" />
	    <cfset var ToggleOffGenerateImageJS = "" />
	    <cfset var stImage = structnew() />
	    <cfset var stFile = structnew() />
	    <cfset var predefinedCrops = { none="None",center="Crop Center",fitinside="Fit Inside",forcesize="Force Size",pad="Pad",topcenter="Crop Top Center",topleft="Crop Top Left",topright="Crop Top Right",left="Crop Left",right="Crop Right",bottomright="Crop Bottom Left",bottomright="Crop Bottom Center" } />
	    <cfset var stInfo = "" />
	    <cfset var metadatainfo = "" />
	    <cfset var prefix = left(arguments.fieldname,len(arguments.fieldname)-len(arguments.stMetadata.name)) />
	    <cfset var thisdependant = "" />
	    <cfset var stAltMeta = structnew() />
		
		
		<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
		<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
	    
	    <cfparam name="arguments.stMetadata.ftstyle" default="">
	    <cfparam name="arguments.stMetadata.ftDestination" default="/images">
	    <cfparam name="arguments.stMetadata.ftSourceField" default="">
	    <cfparam name="arguments.stMetadata.ftInlineDependants" default="">
	    <cfparam name="arguments.stMetadata.ftInlineUpload" default="true">
	    <cfparam name="arguments.stMetadata.ftCreateFromSourceOption" default="true">
	    <cfparam name="arguments.stMetadata.ftCreateFromSourceDefault" default="true">
	    <cfparam name="arguments.stMetadata.ftAllowUpload" default="true">
	    <cfparam name="arguments.stMetadata.ftAllowResize" default="true">
	    <cfparam name="arguments.stMetadata.ftAllowResizeQuality" default="false">
		<cfif not structkeyexists(arguments.stMetadata,"ftImageWidth") or not isnumeric(arguments.stMetadata.ftImageWidth)><cfset arguments.stMetadata.ftImageWidth = 0 /></cfif>
		<cfif not structkeyexists(arguments.stMetadata,"ftImageHeight") or not isnumeric(arguments.stMetadata.ftImageHeight)><cfset arguments.stMetadata.ftImageHeight = 0 /></cfif>
	    <cfparam name="arguments.stMetadata.ftAutoGenerateType" default="FitInside">
	    <cfparam name="arguments.stMetadata.ftPadColor" default="##ffffff">
	    <cfparam name="arguments.stMetadata.ftShowConversionInfo" default="true"><!--- Set to false to hide the conversion information that will be applied to the uploaded image --->
	    <cfparam name="arguments.stMetadata.ftAllowedExtensions" default="jpg,jpeg,png,gif"><!--- The extentions allowed to be uploaded --->
	    
	    <cfif len(arguments.stMetadata.value) and not fileexists(application.path.imageroot & arguments.stMetadata.value)>
			<cfset arguments.stMetadata.value = "" />
		</cfif>
	    
	    <skin:loadJS id="jquery" />
	    <skin:loadJS id="jquery-tooltip" />
	    <skin:loadJS id="jquery-tooltip-auto" />
	    <skin:loadCSS id="jquery-tooltip" />
	    <skin:loadJS id="jquery-uploadify" />
	    <skin:loadCSS id="jquery-uploadify" />
	    <skin:loadJS id="jquery-crop" />
	    <skin:loadCSS id="jquery-crop" />
	    <!--- <skin:htmlHead id="farcry-imageformtool-css"><cfoutput><style type="text/css"> --->
	    <skin:loadCSS id="farcry-imageformtool"><cfoutput>
	    	##indicator { background: url("#application.url.webtop#/images/indicator.gif") repeat scroll 0 0 transparent; }
	    	.dependant-label { font-weight:bold; }
		</cfoutput></skin:loadCSS>
		<!--- </style></cfoutput></skin:htmlHead> --->
	    <skin:htmlHead id="farcry-imageformtool-js"><cfoutput><script type="text/javascript">
	    <!--- <cfoutput> <script type="text/javascript" charset="utf-8"> --->
	    	(function(jQuery){
	    		var defaults = {
	    			"selected"		: "",
	    			"onInit"		: null,
	    			"onOpen"		: null,
	    			"onOpenTarget"	: {},
	    			"onClose"		: null,
	    			"onCloseTarget"	: {},
	    			"autoWireClass"	: "a.select-view,button.select-view",
	    			"eventData"		: {}
	    		};
	    		
	    		jQuery.fn.multiView = function initMultiview(data){
	    			data = jQuery.extend(true,data || {},defaults);
	    			var views = [];
	    			
	    			if (data.onInit) this.bind("multiviewInit",data,eventData,data.onInit);
	    			if (data.onOpen) this.bind("multiviewOpen",data.eventData,data.onOpen);
    				for (target in data.onOpenTarget)
    					this.bind("multiviewOpen"+target,data.eventData,data.onOpenTarget[target]);
	    			if (data.onClose) this.bind("multiviewClose",data.eventData,data.onClose);
    				for (target in data.onCloseTarget)
    					this.bind("multiviewClose"+target,data.eventData,data.onCloseTarget[target]);
	    			
	    			jQuery("> div",this).each(function initMultiviewPage(){
	    				var $self = jQuery(this);
	    				var viewname = "";
	   					var classes = this.className.split(" ");
	   					for (var i=0;i<classes.length;i++)
	   						if (classes[i].search(/^\w+-view$/)>-1) viewname = classes[i].slice(0,-5);
	   					views.push(viewname);
	   					
	    				if (data.selected.length && $self.hasClass(data.selected+"-view") && !$self.not(":visible")){
	    					// show selected
	    					$self.show();
	    				}
	    				else if (!data.selected.length && $self.is(":visible")){
	    					// no initial view provided - select first visible one
    						data.selected = viewname;
	    				}
	    				else if ($self.is(":visible")){
	    					// hide everything else
	    					$self.hide();
	    				}
	    			});
	    			this.data("multiview.currentview",data.selected);
	    			this.data("multiview.allviews",views);
	    			this.trigger("multiviewOpen",[ this.find("> ."+data.selected+"-view"),data.selected ]);
	    			
	    			jQuery(data.autoWireClass,this).bind("click",{ "multiview":this },function onMultiviewAutowireClick(event){
	    				event.data.multiview.selectView(this.href.split("##")[1]);
	    				return false;
	    			});
	    			
		    		this.trigger("multiviewInit");
		    		
		    		return this;
	    		};
	    		
	    		jQuery.fn.selectView = function multiViewSelect(newview){
	    			var oldview = this.data("multiview.currentview");
	    			var history = this.data("multiview.history") || [];
	    			
	    			if (oldview && oldview != newview) {
	    				var $oldview = this.findView(oldview);
	    				this.trigger("multiviewClose",[ $oldview[0],oldview,newview ]).trigger("multiviewClose"+oldview,[ $oldview[0],oldview,newview ]);
	    				$oldview.hide();
	    				if (newview == "back") 
	    					newview = history.pop();
	    				else
	    					history.push(oldview);
	    				this.data("multiview.history",history);
	    			}
	    			if (oldview != newview){
		    			this.data("multiview.currentview",newview);
		    			var $newview = this.findView(newview);
		    			$newview.show();
		    			this.trigger("multiviewOpen",[ $newview[0],newview,oldview ]).trigger("multiviewOpen"+newview,[ $newview[0],newview,oldview ]);
		    		}
		    		
		    		return this;
	    		};
	    		
	    		jQuery.fn.currentView = function multiViewCurrent(){
	    			return this.data("multiview.currentview");
	    		};
	    		
	    		jQuery.fn.addView = function multiViewAdd(name,html,selected){
	    			this.append("<div class='"+name+"-view' style='display:none;'>"+html+"</div>");
	    			this.data("multiview.allviews",this.data("multiview.allviews").push(name));
	    			if (selected) this.selectView(name);
	    			return this;
	    		};
	    		
	    		jQuery.fn.findView = function multiViewFind(view){
	    			return this.find("> ."+view+"-view");
	    		};
	    	})($j);
	    	
	    	(function(jQuery){
		    	$fc.cropper = function cropperObject(sourceobject, url, width, height, postvalues, allowcancel){
		    		
		    		var cropper = this;
		    		
	    			var docwidth = jQuery(document).width();
					var docheight = jQuery(document).height();
					var viewportwidth = jQuery(window).width();
					var viewportheight = jQuery(window).height();
					var overlaywidth = viewportwidth - 100;
					var overlayheight = viewportheight - 100;
					var overlayleft = jQuery(document).scrollLeft()+(viewportwidth-overlaywidth)/2;
					var overlaytop = jQuery(document).scrollTop()+(viewportheight-overlayheight)/2;
					if (!(allowcancel===false)) allowcancel = true;
					
					var current_crop_selection = null;
					
					// Add crop dialog markup
					jQuery("body").append("<div id='image-crop-overlay'><div class='ui-widget-overlay' style='width:"+docwidth+"px;height:"+docheight+"px;'></div><div style='width:"+(overlaywidth+22)+"px;height:"+(overlayheight+22)+"px;position:absolute;left:"+overlayleft+"px; top:"+overlaytop+"px;' class='ui-widget-shadow ui-corner-all'></div><div id='image-crop-ui' class='ui-widget ui-widget-content ui-corner-all' style='position: absolute;width:"+overlaywidth+"px;height:"+overlayheight+"px;left:"+overlayleft+"px;top:"+overlaytop+"px; padding: 10px;'></div></div>");
					
					// Add event to end cropping when the overlay is clicked
					if (allowcancel) jQuery("##image-crop-overlay .ui-widget-overlay").bind("click",function onCropperOverlayClick(e) { if (this==e.target) cropper.cancelCrop(); });
					
					// Load and add events to crop HTML
					jQuery.ajaxSetup({ timeout:5000 });
					jQuery("##image-crop-ui").load(url+"&crop=1&allowcancel="+allowcancel,postvalues,function cropperLoadDialog(){
						var $x1 = jQuery("##image-crop-a-x");
						var $y1 = jQuery("##image-crop-a-y");
						var $x2 = jQuery("##image-crop-b-x");
						var $y2 = jQuery("##image-crop-b-y");
						var $w = jQuery("##image-crop-width");
						var $h = jQuery("##image-crop-height");
						var $rn = jQuery("##image-crop-ratio-num");
						var $rd = jQuery("##image-crop-ratio-den");
						jQuery("##cropable-image").Jcrop({
							"minSize" : [width,height],
							"aspectRatio" : (width && height)?width/height:0,
							"boxWidth" : overlaywidth * 0.65,
							"boxHeight" : overlayheight,
							"onChange" : function onCropperSelectionChange(c){
								$x1.html(c.x);
								$y1.html(c.y);
								$x2.html(c.x2);
								$y2.html(c.y2);
								$w.html(c.w);
								$h.html(c.h);
								if (c.w>c.h){
									$rn.html((c.w/c.h).toFixed(2));
									$rd.html("1");
								}
								else {
									$rn.html("1");
									$rd.html((c.h/c.w).toFixed(2));
								}
							},
							"onSelect" : function(c){
								current_crop_selection = c;
							}
						});
						jQuery("##image-crop-cancel").bind("click",function onCropperCancel() { cropper.cancelCrop(); return false; });
						jQuery("##image-crop-finalize").button({}).bind("click",function onCropperFinalize() {cropper.finalizeCrop(); return false; });
						jQuery("##image-crop-overlay .image-crop-instructions").height(overlayheight-50);
					});
					
					this.cancelCrop = function cropperCancel(){
						jQuery.Jcrop('##cropable-image').destroy();
						jQuery("##image-crop-overlay").remove();
						jQuery(sourceobject).trigger("cancelcrop");
					};
					
					this.finalizeCrop = function cropperFinalize(){
						
						jQuery.Jcrop('##cropable-image').destroy();
						$j("##image-crop-overlay").remove();
						
						if (current_crop_selection){
							var quality = "";
							if (jQuery("##image-crop-quality").length) parseFloat(jQuery("##image-crop-quality").val());
							
							jQuery(sourceobject).trigger("savecrop",[ current_crop_selection, quality ]);
						}
						else
							jQuery(sourceobject).trigger("cancelcrop");
					};
					
					return this;
		    	};
		    })($j);
	    	
	    	$fc.imageformtool = function imageFormtoolObject(prefix,property,bUUID){
				
	    		function ImageFormtool(prefix,property) {
	    			var imageformtool = this;
	    			this.prefix = prefix;
	    			this.property = property;
	    			this.multiview = "";
	    			
	    			this.inputs = {};
	    			this.views = {};
	    			this.elements = {};
	    			
	    			this.init = function initImageFormtool(url,filetypes,sourceField,width,height,inline){

	    				imageformtool.url = url;
	    				imageformtool.filetypes = filetypes;
	    				imageformtool.sourceField = sourceField;
	    				imageformtool.width = width;
	    				imageformtool.height = height;
	    				imageformtool.inline = inline || false;
	    				
	    				imageformtool.inputs.resizemethod  = $j('##'+prefix+property+'RESIZEMETHOD');
	    				imageformtool.inputs.quality  = $j('##'+prefix+property+'QUALITY');
	    				imageformtool.inputs.deletef = $j('##'+prefix+property+'DELETE');
	    				imageformtool.inputs.traditional = $j('##'+prefix+property+'TRADITIONAL');
	    				imageformtool.inputs.newf = $j('##'+prefix+property+'NEW');
	    				imageformtool.inputs.base = $j('##'+prefix+property);
	    				
			    		imageformtool.multiview = $j("##"+prefix+property+"-multiview").multiView({ 
				    			"onOpenTarget" : {
				    				"upload" : function onImageFormtoolOpenUpload(event){  },
				    				"complete" : function onImageFormtoolOpenComplete(event){ 
					    				if (imageformtool.inputs.base.val().length){
						    				$j(this).find(".image-cancel-upload").show();
						    				$j(this).find(".image-cancel-replace").show();
						    			}
					    			},
				    				"autogenerate" : function onImageFormtoolOpenAutogenerate(event){ 
					    				if (imageformtool.inputs.base.val().length){
						    				imageformtool.inputs.deletef.val("true");
											$j(this).find(".image-custom-crop, .image-crop-select-button").show().end();
						    			}
				    				},
				    				"traditional" : function onImageFormtoolOpenTraditional(event){  },
				    				"cancel" : function onImageFormtoolOpenCancel(event){ 
				    					imageformtool.inlineview.find("span.action-cancel").hide();
				    					imageformtool.inlineview.find("span.not-cancel").show();
				    				}
				    			},
				    			"onCloseTarget" : {
				    				"upload" : function onImageFormtoolCloseUpload(event){  },
				    				"complete" : function onImageFormtoolCloseComplete(event){  },
				    				"autogenerate" : function onImageFormtoolCloseAutogenerate(event,oldviewdiv,oldview,newview){
				    					if (newview!="working"){ 
					    					imageformtool.inputs.resizemethod.val("");
					    					imageformtool.inputs.deletef.val("false");
					    				}
				    				},
				    				"working" : function onImageFormtoolCloseAutogenerate(event){
				    					imageformtool.inputs.resizemethod.val("");
					    				imageformtool.inputs.deletef.val("false");
				    				},
				    				"traditional" : function onImageFormtoolCloseTraditional(event){ 
				    					imageformtool.inputs.traditional.val(""); 
				    				},
				    				"cancel" : function onImageFormtoolCloseCancel(event){
				    					imageformtool.inlineview.find("span.not-cancel").hide();
				    					imageformtool.inlineview.find("span.action-cancel").show();
				    				}
				    			}
				    		})
			    			.find("a.image-crop-select-button,button.image-crop-select-button").bind("click",function onImageFormtoolCustomCrop(){ imageformtool.beginCrop(true); return false; }).end()
			    			.find("a.image-crop-cancel-button,button.image-crop-cancel-button").bind("click",function onImageFormtoolCancelCrop(){ imageformtool.removeCrop(); return false; }).end()
			    			.find("button.image-delete-button").bind("click",function onImageFormtoolDelete(){ imageformtool.deleteImage(); return false; }).end()
			    			.find("button.image-deleteall-button").bind("click",function onImageFormtoolDeleteAll(){ imageformtool.deleteAllRelatedImages(); return false; }).end();
			    		if (imageformtool.inline){
			    			imageformtool.inlineview = $j("##"+prefix+property+"-inline")
			    				.find("a.image-crop-select-button").bind("click",function onImageFormtoolCustomCropInline(){ 
			    					imageformtool.inputs.deletef.val("true");
			    					imageformtool.beginCrop(true); 
			    					return false; 
			    				}).end()
			    				.find("span.action .select-view").bind("click",function(){
				    				imageformtool.multiview.selectView(this.href.split("##")[1]);
				    				return false;
			    				}).end();
				    	}
			    		
	    				$j(imageformtool).bind("filechange.updatedisplay",function onImageFormtoolFilechangeUpdate(event,results){
	    					if (results.value && results.value.length>0){
	    						var previewsize = { width:results.width, height:results.height };
	    						if (previewsize.width > 400) previewsize = { width:400, height:previewsize.height*400/previewsize.width };
	    						if (previewsize.height > 400) previewsize = { width:previewsize.width*400/previewsize.height, height:400 };
		    					var complete = imageformtool.multiview.findView("complete")
									.find(".image-status").attr("title","This file has been updated on the server").tooltip({ delay: 0, showURL: false	}).html('<span class="ui-icon ui-icon-info" style="float:left;">&nbsp;</span>').end()
									.find(".image-filename").html(results.filename).end()
									.find(".image-size").html(results.size).end()
									.find(".image-width").html(results.width).end()
									.find(".image-height").html(results.height).end();
								if (results.resizedetails){
									complete.find(".image-quality").html(results.resizedetails.quality.toString()).end();
									complete.find(".image-resize-information").show().end();
								}
								else {
									complete.find(".image-resize-information").hide().end();
								}
								if (imageformtool.inline){
									imageformtool.inlineview
										.find("a.image-preview").attr("href",results.fullpath).attr("title","<img src='"+results.fullpath+"?"+new Date().getTime()+"' width='"+previewsize.width.toString()+"px' height='"+previewsize.height.toString()+"px' /><br><div style='width:"+previewsize.width.toString()+"px;'>"+results.size.toString()+"</span>KB, "+results.width.toString()+"px x "+results.height+"px</div>").tooltip({ delay: 0, showURL: false	}).end()
										.find("span.action-preview").show().end()
										.find("span.dependant-options").show().end();
									imageformtool.multiview.selectView("cancel");
								}
								else{
									imageformtool.multiview.find("a.image-preview").attr("href",results.fullpath).attr("title","<img src='"+results.fullpath+"?"+new Date().getTime()+"' width='"+previewsize.width.toString()+"px' height='"+previewsize.height.toString()+"px' />").tooltip({ delay: 0, showURL: false	}).end()
									imageformtool.multiview.selectView("complete");
								}
							}
	    				}).bind("fileerror.updatedisplay",function onImageFormtoolFileerrorDisplay(event,action,error,message){
							$j('##'+prefix+property+"_"+action+"error").html(message).show();
	    				}).bind("cancelcrop",function(){
	    				
	    				}).bind("savecrop",function onImageFormtoolSaveCrop(event,c,q){
							imageformtool.inputs.resizemethod.val(c.x.toString()+","+c.y.toString()+"-"+c.x2.toString()+","+c.y2.toString());
							imageformtool.inputs.quality.val(q);
							imageformtool.multiview.findView("autogenerate")
								.find(".image-crop-select-button").hide().end()
								.find(".image-crop-information").show()
									.find(".image-crop-a-x").html(c.x).end()
									.find(".image-crop-a-y").html(c.y).end()
									.find(".image-crop-b-x").html(c.x2).end()
									.find(".image-crop-b-y").html(c.y2).end()
									.find(".image-crop-width").html(c.w).end()
									.find(".image-crop-height").html(c.h).end()
									.find(".image-crop-quality").html((q*100).toFixed(0)).end();
							imageformtool.applyCrop();
	    				});
	    				
	    				if (sourceField.length>0){
	    					
	    					function handleSourceChange(newval){
		    					if (newval && newval.length){
			    					//imageformtool.enableCrop(true);
									imageformtool.applyCrop();
									if (imageformtool.inline) 
										imageformtool.inlineview
											.find("span.action-crop").show().end()
											.find("span.dependant-options").show().end();
								}
								else {
									imageformtool.enableCrop(false);
								}
	    					};
	    					
	    					if (sourceField.indexOf(":")>-1){
	    						var $sourceField = $j("##"+prefix+sourceField.split(":")[0]);
	    						var existingval = $sourceField.val();
	    						var pending = false;
	    						function checkSource(){
	    							var newval = $sourceField.val();
	    							if (newval!=existingval && !pending){console.log(newval);
	    								existingval = newval;
	    								handleSourceChange(newval);
	    							};
	    						};
	    						setInterval(checkSource,500);
	    					}
	    					else {
			    				$j($fc.imageformtool(prefix,sourceField)).bind("filechange",function onImageFilechangePropogate(event,results){
			    					handleSourceChange(results.value);
			    				}).bind("deleteall",function onImageFormtoolDeleteAllPropogate(){
			    					imageformtool.deleteImage("autogenerate");
			    				});
			    			}
		    			}
			    		
			    		imageformtool.inputs.newf.uploadify({
				    		'buttonText'	: 'Select File',
							'uploader'  	: '#application.url.webtop#/thirdparty/jquery.uploadify-v2.1.4/uploadify.swf',
							'script'    	: url,
							'checkScript'	: url+"/check/1",
							'cancelImg' 	: '#application.url.webtop#/thirdparty/jquery.uploadify-v2.1.4/cancel.png',
							'auto'      	: true,
							'fileExt'		: filetypes,
							'fileDataName'	: property+"NEW",
							'method'		: "POST",
							'scriptData'	: {},
							'onSelectOnce' 	: function(event,data){
								// hide any previous results
								$j('##'+prefix+property+"_uploaderror").hide();
								
								// attached related fields to uploadify post
								imageformtool.inputs.newf.uploadifySettings("scriptData",imageformtool.getPostValues());
							},
							'onComplete'	: function(event, ID, fileObj, response, data){
								var results = $j.parseJSON(response);
								imageformtool.inputs.newf.uploadifyClearQueue();
								if (results.error) {
									$j(imageformtool).trigger("fileerror", ["upload", "500", results.error]);
								}
								else {
									imageformtool.inputs.base.val(results.value);
									$j(imageformtool).trigger("filechange", [results]);
								}
							},
							'onError'		: function(event, ID, fileObj, errorObj){
								imageformtool.inputs.newf.uploadifyClearQueue();
								if (d.status == 404)
									$j(imageformtool).trigger("fileerror",[ "upload",errorObj.status.toString(),'Could not find upload script' ]);
								else if (d.type === "HTTP")
									$j(imageformtool).trigger("fileerror",[ "upload",errorObj.status.toString(),'error '+errorObj.type+": "+errorObj.status ]);
								else if (d.type ==="File Size")
									$j(imageformtool).trigger("fileerror",[ "upload","filesize",fileObj.name+' '+errorObj.type+' Limit: '+Math.round(errorObj.sizeLimit) ]);
								else
									$j(imageformtool).trigger("fileerror",[ "upload",errorObj.type,'error '+errorObj.type+": "+errorObj.text ]);
							}
						});
	    			};
	    			
	    			this.getPostValues = function imageFormtoolGetPostValues(){
						// get the post values
						var values = {};
						$j('[name^="'+prefix+property+'"]').each(function(){ if (this.name!=prefix+property+"NEW") values[this.name.slice(prefix.length)]=""; });
						if (imageformtool.sourceField) values[imageformtool.sourceField.split(":")[0]] = "";
						values = getValueData(values,prefix);
						
						return values;
	    			};
	    			
	    			this.enableCrop = function imageFormtoolEnableCrop(enabled){
						if (enabled){
							imageformtool.multiview.findView("autogenerate").find(".image-custom-crop").show();
							imageformtool.multiview.findView("complete").find(".regenerate-link").show();
						}
						else {
							imageformtool.multiview.findView("autogenerate").find(".image-custom-crop").hide();
							imageformtool.multiview.findView("complete").find(".regenerate-link").hide();
						}
					};
	    			
	    			this.beginCrop = function imageFormtoolBeginCrop(allowcancel){
	    				$j('##'+prefix+property+"_croperror").hide();

						$fc.cropper(imageformtool,imageformtool.url,imageformtool.width,imageformtool.height,imageformtool.getPostValues(),allowcancel);
	    				
	    			};
	    			
	    			this.applyCrop = function imageFormtoolApplyCrop(){
	    				imageformtool.multiview.selectView("working");
	    				
						$j.ajax({
							type : "POST",
							url : imageformtool.url,
							data : imageformtool.getPostValues(),
							success : function imageFormtoolApplyCropSuccess(results){
								// results is null if there is already an image 
								if (results) {
									if (results.error) {
										$j(imageformtool).trigger("fileerror", ["crop", "500", results.error]);
										imageformtool.multiview.selectView("autogenerate");
									}
									else {
										imageformtool.inputs.base.val(results.value);
										$j('##' + prefix + property + "_croperror").hide();
										imageformtool.multiview.findView("autogenerate").find(".image-crop-information").hide();
										$j(imageformtool).trigger("filechange", [results]);
										imageformtool.multiview.selectView("complete");
									}
								}
								imageformtool.enableCrop(true)
							},
							error : function imageFormtoolApplyCropError(XMLHttpRequest, textStatus, errorThrown){
								$j(imageformtool).trigger("fileerror",[ "crop",textStatus,errorThrown.toString() ]);
								imageformtool.enableCrop(true);
								imageformtool.multiview.selectView("autogenerate");
							},
							dataType : "json",
							timeout : 120000
						});
	    			};
	    			
	    			this.removeCrop = function imageFormtoolRemoveCrop(){
						imageformtool.inputs.resizemethod.val("");
						imageformtool.inputs.quality.val("");
						imageformtool.multiview.findView("autogenerate")
							.find(".image-crop-information").hide().end()
							.find(".image-crop-select-button").show().end();
						$j(imageformtool).trigger("removedcrop");
					};
					
					this.deleteImage =  function imageFormtoolDeleteImage(viewToShow){
						var afterDeleteView = viewToShow || "upload";
						
						imageformtool.inputs.deletef.val("true");
						
						var postData = imageformtool.getPostValues();
						
						if (imageformtool.sourceField.length) postData[imageformtool.sourceField.split(":")[0]] = '';
						
						$j.ajax({
							type : "POST",
							url : imageformtool.url,
							data : postData,
							success : function imageFormtoolDeleteImageSuccess(results){
								imageformtool.inputs.base.val('');
								imageformtool.inputs.deletef.val("false");
								imageformtool.multiview.selectView(afterDeleteView);
								imageformtool.multiview.find('.image-cancel-upload, .image-custom-crop, .image-cancel-replace').hide();
								$j(imageformtool).trigger("filechange", [results]);
							},
							error : function imageFormtoolDeleteImageError(XMLHttpRequest, textStatus, errorThrown){
								$j(imageformtool).trigger("fileerror",[ "crop",textStatus,errorThrown.toString() ]);
							},
							dataType : "json"
						});						
					}
					this.deleteAllRelatedImages = function imageFormtoolDeleteAllRelatedImages(){
						//trigger related to be deleted
						$j(imageformtool).trigger("deleteall");
						
						//delete source
						imageformtool.deleteImage();
					}
	    		};
	    		
	    		if (!this[prefix+property]) this[prefix+property] = new ImageFormtool(prefix,property);
	    		return this[prefix+property];
	    	};
			</script></cfoutput>
		<skin:htmlHead>
	    
	    <cfsavecontent variable="metadatainfo">
			<cfif (isnumeric(arguments.stMetadata.ftImageWidth) and arguments.stMetadata.ftImageWidth gt 0) or (isnumeric(arguments.stMetadata.ftImageHeight) and arguments.stMetadata.ftImageHeight gt 0)>
				<cfoutput>Dimensions: <cfif isnumeric(arguments.stMetadata.ftImageWidth) and arguments.stMetadata.ftImageWidth gt 0>#arguments.stMetadata.ftImageWidth#<cfelse>any width</cfif> x <cfif isnumeric(arguments.stMetadata.ftImageHeight) and arguments.stMetadata.ftImageHeight gt 0>#arguments.stMetadata.ftImageHeight#<cfelse>any height</cfif> (#predefinedCrops[arguments.stMetadata.ftAutoGenerateType]#)<br>Quality Setting: #round(arguments.stMetadata.ftQuality*100)#%<br></cfoutput>
			</cfif>
			<cfoutput>Image must be of type #arguments.stMetadata.ftAllowedExtensions#</cfoutput>
		</cfsavecontent>
	    
	    <cfif len(arguments.stMetadata.ftSourceField)>
			
			<!--- This image will be generated from the source field --->
			<cfsavecontent variable="html"><cfoutput>
				<div class="multiField">
					<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" />
					<input type="hidden" name="#arguments.fieldname#DELETE" id="#arguments.fieldname#DELETE" value="false" />
					<div id="#arguments.fieldname#-multiview">
						<cfif arguments.stMetadata.ftAllowUpload>
					    	<div id="#arguments.fieldname#_upload" class="upload-view" style="display:none;">
				    			<a href="##traditional" class="select-view" title="Switch between traditional upload and inline upload" style="float:left;"><span class="ui-icon ui-icon-shuffle">&nbsp;</span></a>
								<div style="margin-left:15px">
						    		<input type="file" name="#arguments.fieldname#NEW" id="#arguments.fieldname#NEW" />
						    		<div id="#arguments.fieldname#_uploaderror" class="ui-state-error ui-corner-all" style="padding:0.7em;margin-top:0.7em;margin-bottom:0.7em;display:none;"></div>
						    		<div><span style="float:left;" title="#metadatainfo#" class="ui-icon ui-icon-help">&nbsp;</span> <span style="float:left;">Select an image to upload from your computer.</span></div>
						    		<div class="image-cancel-upload" style="clear:both;"><a href="##back" class="select-view">Cancel - I don't want to upload an image</a></div>
						    	</div>
							</div>
					    	<div id="#arguments.fieldname#_traditional" class="traditional-view" style="display:none;">
				    			<a href="##back" class="select-view" title="Switch between traditional upload and inline upload" style="float:left;"><span class="ui-icon ui-icon-shuffle">&nbsp;</span></a>
					    		<div style="margin-left:15px">
						    		<input type="file" name="#arguments.fieldname#TRADITIONAL" id="#arguments.fieldname#TRADITIONAL" />
						    		<div><span style="float:left;" title="#metadatainfo#" class="ui-icon ui-icon-help">&nbsp;</span> <span style="float:left;">Select an image to upload from your computer.</span></div>
						    		<div class="image-cancel-upload" style="clear:both;<cfif not len(arguments.stMetadata.value)>display:none;</cfif>"><a href="##back" class="select-view">Cancel - I don't want to replace this image</a></div>
						    	</div>
							</div>
					    	<div id="#arguments.fieldname#_delete" class="delete-view" style="display:none;">
					    		<span class="image-status" title=""><span class="ui-icon ui-icon-image" style="float:left;">&nbsp;</span></span>
								<div style="margin-left:15px">
						    		<ft:button class="image-delete-button" id="#arguments.fieldname#DeleteThis" type="button" value="Delete this image" onclick="return false;" />						    		
						    		<div class="image-cancel-upload"><a href="##back" class="select-view">Cancel - I don't want to delete</a></div>
						    	</div>
							</div>
						</cfif>
						<div id="#arguments.fieldname#_autogenerate" class="autogenerate-view"<cfif len(arguments.stMetadata.value)> style="display:none;"</cfif>>
							<span class="image-status" title="#metadatainfo#"><span class="ui-icon ui-icon-help" style="float:left;">&nbsp;</span></span>
						    <div style="margin-left:15px;">
								Image will be automatically generated based on the image selected for #application.stCOAPI[arguments.typename].stProps[listfirst(arguments.stMetadata.ftSourceField,":")].metadata.ftLabel#.<br>
								<cfif arguments.stMetadata.ftAllowResize>
									<div class="image-custom-crop"<cfif not structkeyexists(arguments.stObject,arguments.stMetadata.ftSourceField) or not len(arguments.stObject[listfirst(arguments.stMetadata.ftSourceField,":")])> style="display:none;"</cfif>>
										<input type="hidden" name="#arguments.fieldname#RESIZEMETHOD" id="#arguments.fieldname#RESIZEMETHOD" value="" />
										<input type="hidden" name="#arguments.fieldname#QUALITY" id="#arguments.fieldname#QUALITY" value="" />
										<ft:button value="Select Exactly How To Crop Your Image" class="image-crop-select-button" type="button" onclick="return false;" />
										<div id="#arguments.fieldname#_croperror" class="ui-state-error ui-corner-all" style="padding:0.7em;margin-top:0.7em;margin-bottom:0.7em;display:none;"></div>
						    			<div class="image-crop-information ui-state-highlight ui-corner-all" style="padding:0.7em;margin-top:0.7em;display:none;">Your crop settings will be applied when you save. <a href="##" class="image-crop-cancel-button">Cancel custom crop</a></div>
									</div>
								</cfif>
								<div><cfif arguments.stMetadata.ftAllowUpload><a href="##upload" class="select-view">Upload - I want to use my own image</a></cfif><span class="image-cancel-replace" style="clear:both;<cfif not len(arguments.stMetadata.value)>display:none;</cfif>"><cfif arguments.stMetadata.ftAllowUpload> | </cfif><a href="##complete" class="select-view">Cancel - I don't want to replace this image</a></span></div>
							</div>
						</div>
						<div id="#arguments.fieldname#_working" class="working-view" style="display:none;">
							<span class="image-status" title="#metadatainfo#"><span id="indicator" class="ui-icon" style="float:left;">>&nbsp;</span></span>
						    <div style="margin-left:15px;">Generating image...</div>
						</div>
						<cfif len(arguments.stMetadata.value)>
						    <cfset stFile = GetFileInfo("#application.path.imageroot##arguments.stMetadata.value#") />
						    <cfimage action="info" source="#application.path.imageroot##arguments.stMetadata.value#" structName="stImage" />
						    <cfset previewwidth = stImage.width />
						    <cfset previewheight = stImage.height />
						    <cfif previewwidth gt 400>
								<cfset previewheight = previewheight * 400 / previewwidth />
								<cfset previewwidth = 400 />
							</cfif>
						    <cfif previewheight gt 400>
								<cfset previewwidth = previewwidth * 400 / previewheight />
								<cfset previewheight = 400 />
							</cfif>
						    <div id="#arguments.fieldname#_complete" class="complete-view">
					    		<span class="image-status" title=""><span class="ui-icon ui-icon-image" style="float:left;">&nbsp;</span></span>
					    		<div style="margin-left:15px;">
						    		<span class="image-filename">#listlast(arguments.stMetadata.value,"/")#</span> ( <a class="image-preview" title="<img src='#application.url.imageroot##getDirectoryFromPath(arguments.stMetadata.value)##urlencodedformat(getFileFromPath(arguments.stMetadata.value))#' width='#previewwidth#' height='#previewheight#' />" href="#application.url.imageroot##arguments.stMetadata.value#" target="_blank">Preview</a><span class="regenerate-link"> | <a href="##autogenerate" class="select-view">Regenerate</a></span> <cfif arguments.stMetadata.ftAllowUpload>| <a href="##upload" class="select-view">Upload</a> | <a href="##delete" class="select-view">Delete</a></cfif> )<br>
						    		Size: <span class="image-size">#round(stFile.size/1024)#</span>KB, Dimensions: <span class="image-width">#stImage.width#</span>px x <span class="image-height">#stImage.height#</span>px
						    		<div class="image-resize-information ui-state-highlight ui-corner-all" style="padding:0.7em;margin-top:0.7em;display:none;">Resized to <span class="image-width"></span>px x <span class="image-height"></span>px (<span class="image-quality"></span>% quality)</div><br>
						    	</div>
							</div>
						<cfelse>
						    <div id="#arguments.fieldname#_complete" class="complete-view" style="display:none;">
					    		<span class="image-status" title=""><span class="ui-icon ui-icon-image" style="float:left;">&nbsp;</span></span>
					    		<div style="margin-left:15px;">
						    		<span class="image-filename"></span> ( <a class="image-preview" title="<img src='' />" href="##" target="_blank">Preview</a><span class="regenerate-link"> | <a href="##autogenerate" class="select-view">Regenerate</a></span> <cfif arguments.stMetadata.ftAllowUpload>| <a href="##upload" class="select-view">Upload</a> | <a href="##delete" class="select-view">Delete</a></cfif> )<br>
						    		Size: <span class="image-size"></span>KB, Dimensions: <span class="image-width"></span>px x <span class="image-height"></span>px
									<div class="image-resize-information ui-state-highlight ui-corner-all" style="padding:0.7em;margin-top:0.7em;display:none;">Resized to <span class="image-width"></span>px x <span class="image-height"></span>px (<span class="image-quality"></span>% quality)</div><br>
						    	</div>
							</div>
						</cfif>
					</div>
					<script type="text/javascript">$fc.imageformtool('#prefix#','#arguments.stMetadata.name#').init('#getAjaxURL(typename=arguments.typename,stObject=arguments.stObject,stMetadata=arguments.stMetadata,fieldname=arguments.fieldname,combined=true)#','#replace(rereplace(arguments.stMetadata.ftAllowedExtensions,"(^|,)(\w+)","\1*.\2","ALL"),",",";","ALL")#','#ListFirst(arguments.stMetadata.ftSourceField,":")#',#arguments.stMetadata.ftImageWidth#,#arguments.stMetadata.ftImageHeight#);</script>
				</div>
			</cfoutput></cfsavecontent>
			
		<cfelse>
			
			<!--- This IS the source field --->
		    <cfsavecontent variable="html"><cfoutput>
			    <div class="multiField">
					<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" />
					<input type="hidden" name="#arguments.fieldname#DELETE" id="#arguments.fieldname#DELETE" value="false" />
					<div id="#arguments.fieldname#-multiview">
				    	<div id="#arguments.fieldname#_upload" class="upload-view"<cfif len(arguments.stMetadata.value)> style="display:none;"</cfif>>
				    		<a href="##traditional" class="select-view" title="Switch between traditional upload and inline upload" style="float:left;"><span class="ui-icon ui-icon-shuffle">&nbsp;</span></a>
							<div style="margin-left:15px">
					    		<input type="file" name="#arguments.fieldname#NEW" id="#arguments.fieldname#NEW" />
					    		<div id="#arguments.fieldname#_uploaderror" class="ui-state-error ui-corner-all" style="padding:0.7em;margin-top:0.7em;margin-bottom:0.7em;display:none;"></div>
					    		<div><span style="float:left;" title="#metadatainfo#" class="ui-icon ui-icon-help">&nbsp;</span> <span style="float:left;">Select an image to upload from your computer.</span></div>
					    		<div class="image-cancel-upload" style="clear:both;<cfif not len(arguments.stMetadata.value)>display:none;</cfif>"><a href="##back" class="select-view">Cancel - I don't want to replace this image</a></div>
					    	</div>
						</div>
				    	<div id="#arguments.fieldname#_traditional" class="traditional-view" style="display:none;">
				    		<a href="##back" class="select-view" title="Switch between traditional upload and inline upload" style="float:left;"><span class="ui-icon ui-icon-shuffle">&nbsp;</span></a>
							<div style="margin-left:15px">
					    		<input type="file" name="#arguments.fieldname#TRADITIONAL" id="#arguments.fieldname#TRADITIONAL" />
					    		<div><span style="float:left;" title="#metadatainfo#" class="ui-icon ui-icon-help">&nbsp;</span> <span style="float:left;">Select an image to upload from your computer.</span></div>
					    		<div class="image-cancel-upload" style="clear:both;<cfif not len(arguments.stMetadata.value)>display:none;</cfif>"><a href="##back" class="select-view">Cancel - I don't want to replace this image</a></div>
					    	</div>
						</div>
				    	<div id="#arguments.fieldname#_delete" class="delete-view" style="display:none;">
				    		<span class="image-status" title=""><span class="ui-icon ui-icon-image" style="float:left;">&nbsp;</span></span>
							<div style="margin-left:15px">
					    		<ft:button class="image-delete-button" value="Delete this image" type="button" onclick="return false;" />
					    		<ft:button class="image-deleteall-button" value="Delete this and the related images" type="button" onclick="return false;" />
					    		
					    		<div class="image-cancel-upload"><a href="##back" class="select-view">Cancel - I don't want to delete</a></div>
					    	</div>
						</div>
						<cfif len(arguments.stMetadata.value)>
						    <cfset stFile = GetFileInfo("#application.path.imageroot##arguments.stMetadata.value#") />
						    <cfimage action="info" source="#application.path.imageroot##arguments.stMetadata.value#" structName="stImage" />
						    <cfset previewwidth = stImage.width />
						    <cfset previewheight = stImage.height />
						    <cfif previewwidth gt 400>
								<cfset previewheight = previewheight * 400 / previewwidth />
								<cfset previewwidth = 400 />
							</cfif>
						    <cfif previewheight gt 400>
								<cfset previewwidth = previewwidth * 400 / previewheight />
								<cfset previewheight = 400 />
							</cfif>
						    <div id="#arguments.fieldname#_complete" class="complete-view">
					    		<span class="image-status" title=""><span class="ui-icon ui-icon-image" style="float:left;">&nbsp;</span></span>
					    		<div style="margin-left:15px;">
						    		<span class="image-filename">#listlast(arguments.stMetadata.value,"/")#</span> ( <a class="image-preview" title="<img src='#application.url.imageroot##getDirectoryFromPath(arguments.stMetadata.value)##urlencodedformat(getFileFromPath(arguments.stMetadata.value))#' width='#previewwidth#' height='#previewheight#' />" href="#application.url.imageroot##arguments.stMetadata.value#" target="_blank">Preview</a> | <a href="##upload" class="select-view">Upload</a> | <a href="##delete" class="select-view">Delete</a> )<br>
						    		Size: <span class="image-size">#round(stFile.size/1024)#</span>KB, Dimensions: <span class="image-width">#stImage.width#</span>px x <span class="image-height">#stImage.height#</span>px
									<div class="image-resize-information ui-state-highlight ui-corner-all" style="padding:0.7em;margin-top:0.7em;display:none;">Resized to <span class="image-width"></span>px x <span class="image-height"></span>px (<span class="image-quality"></span>% quality)</div>
						    	</div>
							</div>
						<cfelse>
						    <div id="#arguments.fieldname#_complete" class="complete-view" style="display:none;">
					    		<span class="image-status" title=""><span class="ui-icon ui-icon-image" style="float:left;">&nbsp;</span></span>
					    		<div style="margin-left:15px;">
						    		<span class="image-filename"></span> ( <a class="image-preview" title="<img src='' />" href="##" target="_blank">Preview</a> | <a href="##upload" class="select-view">Upload</a> | <a href="##delete" class="select-view">Delete</a> )<br>
						    		Size: <span class="image-size"></span>KB, Dimensions: <span class="image-width"></span>px x <span class="image-height"></span>px
						    		<div class="image-resize-information ui-state-highlight ui-corner-all" style="padding:0.7em;margin-top:0.7em;display:none;">Resized to <span class="image-width"></span>px x <span class="image-height"></span>px (<span class="image-quality"></span>% quality)</div>
						    	</div>
							</div>
						</cfif>
					</div>
					<script type="text/javascript">$fc.imageformtool('#prefix#','#arguments.stMetadata.name#').init('#getAjaxURL(typename=arguments.typename,stObject=arguments.stObject,stMetadata=arguments.stMetadata,fieldname=arguments.fieldname,combined=true)#','#replace(rereplace(arguments.stMetadata.ftAllowedExtensions,"(^|,)(\w+)","\1*.\2","ALL"),",",";","ALL")#','#arguments.stMetadata.ftSourceField#',#arguments.stMetadata.ftImageWidth#,#arguments.stMetadata.ftImageHeight#);</script>
					<cfif len(arguments.stMetadata.ftInlineDependants)><div style="margin-top: 10px; margin-left: 20px; font-weight: bold; font-style: italic;">Image sizes:</div></cfif>
				</cfoutput>
				
				<cfloop list="#arguments.stMetadata.ftInlineDependants#" index="thisdependant">
					<cfif structkeyexists(arguments.stObject,thisdependant)>
						<cfset stAltMeta = duplicate(arguments.stPackage.stProps[thisdependant].metadata) />
						<cfset stAltMeta.ftAllowUpload = arguments.stMetadata.ftInlineUpload />
						<cfset stAltMeta.value = arguments.stObject[stAltMeta.name] />
						<cfoutput>#editInline(typename=arguments.typename,stObject=arguments.stObject,stMetadata=stAltMeta,fieldname="#prefix##stAltMeta.name#",stPackage=arguments.stPackage,prefix=prefix)#</cfoutput>
					</cfif>
				</cfloop>
				
				<cfoutput></div></cfoutput>
		    </cfsavecontent>
			
		</cfif>
	    
	    <cfreturn html>
	</cffunction>
	
	<cffunction name="editInline" output="false" returntype="string" hint="UI for editing a dependant image inline as part of the source field">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
	    <cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
	    <cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
	    <cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
	    <cfargument name="stPackage" required="true" type="struct" hint="Contains the metadata for the all fields for the current typename.">
	    <cfargument name="prefix" required="true" type="string" hint="Form prefix" />
	    
		<cfset var html = "" />
		<cfset var metadatainfo = "" />
		<cfset var preview = "" />
		<cfset var predefinedCrops = { none="None",center="Crop Center",fitinside="Fit Inside",forcesize="Force Size",pad="Pad",topcenter="Crop Top Center",topleft="Crop Top Left",topright="Crop Top Right",left="Crop Left",right="Crop Right",bottomright="Crop Bottom Left",bottomright="Crop Bottom Center" } />
	    <cfset var stImage = structnew() />
	    <cfset var stFile = structnew() />
	    
		<cfparam name="arguments.stMetadata.ftHint" default="" />
	    <cfparam name="arguments.stMetadata.ftstyle" default="">
	    <cfparam name="arguments.stMetadata.ftDestination" default="/images">
	    <cfparam name="arguments.stMetadata.ftSourceField" default="">
	    <cfparam name="arguments.stMetadata.ftCreateFromSourceOption" default="true">
	    <cfparam name="arguments.stMetadata.ftCreateFromSourceDefault" default="true">
	    <cfparam name="arguments.stMetadata.ftAllowUpload" default="true">
	    <cfparam name="arguments.stMetadata.ftAllowResize" default="true">
	    <cfparam name="arguments.stMetadata.ftAllowResizeQuality" default="false">
		<cfif not structkeyexists(arguments.stMetadata,"ftImageWidth") or not isnumeric(arguments.stMetadata.ftImageWidth)><cfset arguments.stMetadata.ftImageWidth = 0 /></cfif>
		<cfif not structkeyexists(arguments.stMetadata,"ftImageHeight") or not isnumeric(arguments.stMetadata.ftImageHeight)><cfset arguments.stMetadata.ftImageHeight = 0 /></cfif>
	    <cfparam name="arguments.stMetadata.ftAutoGenerateType" default="FitInside">
	    <cfparam name="arguments.stMetadata.ftPadColor" default="##ffffff">
	    <cfparam name="arguments.stMetadata.ftShowConversionInfo" default="true"><!--- Set to false to hide the conversion information that will be applied to the uploaded image --->
	    <cfparam name="arguments.stMetadata.ftAllowedExtensions" default="jpg,jpeg,png,gif"><!--- The extentions allowed to be uploaded --->
	    
	    <!--- Metadata --->
	    <cfsavecontent variable="metadatainfo">
			<cfif (isnumeric(arguments.stMetadata.ftImageWidth) and arguments.stMetadata.ftImageWidth gt 0) or (isnumeric(arguments.stMetadata.ftImageHeight) and arguments.stMetadata.ftImageHeight gt 0)>
				<cfoutput>Dimensions: <cfif isnumeric(arguments.stMetadata.ftImageWidth) and arguments.stMetadata.ftImageWidth gt 0>#arguments.stMetadata.ftImageWidth#<cfelse>any width</cfif> x <cfif isnumeric(arguments.stMetadata.ftImageHeight) and arguments.stMetadata.ftImageHeight gt 0>#arguments.stMetadata.ftImageHeight#<cfelse>any height</cfif> (#predefinedCrops[arguments.stMetadata.ftAutoGenerateType]#)<br>Quality Setting: #round(arguments.stMetadata.ftQuality*100)#%<br></cfoutput>
			</cfif>
			<cfoutput>Image must be of type #arguments.stMetadata.ftAllowedExtensions#</cfoutput>
		</cfsavecontent>
		
		<!--- Preview --->
		<cfif len(arguments.stMetadata.value)>
		    <cfset stFile = GetFileInfo("#application.path.imageroot##arguments.stMetadata.value#") />
		    <cfimage action="info" source="#application.path.imageroot##arguments.stMetadata.value#" structName="stImage" />
		    <cfset previewwidth = stImage.width />
		    <cfset previewheight = stImage.height />
		    <cfif previewwidth gt 400>
				<cfset previewheight = previewheight * 400 / previewwidth />
				<cfset previewwidth = 400 />
			</cfif>
		    <cfif previewheight gt 400>
				<cfset previewwidth = previewwidth * 400 / previewheight />
				<cfset previewheight = 400 />
			</cfif>
			<cfset preview = "<img src='#application.url.imageroot##arguments.stMetadata.value#' width='#previewwidth#' height='#previewheight#' /><br><div style='width:#previewwidth#px;'>#round(stFile.size/1024)#</span>KB, #stImage.width#px x #stImage.height#px</div>" />
		<cfelse>
			<cfset preview = "" />
		</cfif>
	    
		<cfsavecontent variable="html"><cfoutput>
			<div id="#arguments.fieldname#-inline" style="margin-left:20px;">
			
				<input type="hidden" name="#arguments.fieldname#RESIZEMETHOD" id="#arguments.fieldname#RESIZEMETHOD" value="" />
				<input type="hidden" name="#arguments.fieldname#DELETE" id="#arguments.fieldname#DELETE" value="false" />
				<span class="image-status" title="<cfif len(arguments.stMetadata.ftHint)>#arguments.stMetadata.ftHint#<br></cfif>#metadatainfo#"><span class="ui-icon ui-icon-image" style="float:left;">&nbsp;</span></span>
				<span class="dependant-label">#arguments.stMetadata.ftLabel#</span>
				<span class="dependant-options"<cfif not len(arguments.stMetadata.value) and not len(arguments.stObject[arguments.stMetadata.ftSourceField]) and not arguments.stMetadata.ftAllowUpload> style="display:none;"</cfif>>
					(
						<span class="not-cancel">
							<span class="action-preview action"<cfif not len(arguments.stMetadata.value)> style="display:none;"</cfif>>
								<a class="image-preview" href="#application.url.imageroot##arguments.stMetadata.value#" target="_blank" title="#preview#">Preview</a> | 
							</span>
							<span class="action-crop action"<cfif not len(arguments.stObject[listfirst(arguments.stMetadata.ftSourceField,":")])> style="display:none;"</cfif>>
								<a class="image-crop-select-button" href="##">Custom crop</a><cfif arguments.stMetadata.ftAllowUpload> | </cfif>
							</span>
							<cfif arguments.stMetadata.ftAllowUpload><span class="action-upload action"><a href="##upload" class="image-upload-select-button select-view">Upload</a></span></cfif>
						</span>
						<cfif arguments.stMetadata.ftAllowUpload><span class="action-cancel action" style="display:none;"><a href="##cancel" class="select-view">Cancel</a></span></cfif>
					)
				</span>
				<cfif arguments.stMetadata.ftAllowUpload>
					<div id="#arguments.fieldname#-multiview">
						<div id="#arguments.fieldname#_cancel" class="cancel-view"></div>
				    	<div id="#arguments.fieldname#_upload" class="upload-view" style="display:none;">
			    			<a href="##traditional" class="select-view" title="Switch between traditional upload and inline upload" style="float:left;"><span class="ui-icon ui-icon-shuffle">&nbsp;</span></a>
							<div style="margin-left:15px">
					    		<input type="file" name="#arguments.fieldname#NEW" id="#arguments.fieldname#NEW" />
					    		<div id="#arguments.fieldname#_uploaderror" class="ui-state-error ui-corner-all" style="padding:0.7em;margin-top:0.7em;margin-bottom:0.7em;display:none;"></div>
					    		<div><span style="float:left;" title="#metadatainfo#" class="ui-icon ui-icon-help">&nbsp;</span> <span style="float:left;">Select an image to upload from your computer.</span></div>
					    	</div>
						</div>
				    	<div id="#arguments.fieldname#_traditional" class="traditional-view" style="display:none;">
			    			<a href="##upload" class="select-view" title="Switch between traditional upload and inline upload" style="float:left;"><span class="ui-icon ui-icon-shuffle">&nbsp;</span></a>
				    		<div style="margin-left:15px">
					    		<input type="file" name="#arguments.fieldname#TRADITIONAL" id="#arguments.fieldname#TRADITIONAL" />
					    		<div><span style="float:left;" title="#metadatainfo#" class="ui-icon ui-icon-help">&nbsp;</span> <span style="float:left;">Select an image to upload from your computer.</span></div>
					    	</div>
						</div>
					</div>
				</cfif>
				<script type="text/javascript">$fc.imageformtool('#arguments.prefix#','#arguments.stMetadata.name#').init('#getAjaxURL(typename=arguments.typename,stObject=arguments.stObject,stMetadata=arguments.stMetadata,fieldname=arguments.fieldname,combined=true)#','#replace(rereplace(arguments.stMetadata.ftAllowedExtensions,"(^|,)(\w+)","\1*.\2","ALL"),",",";","ALL")#','#arguments.stMetadata.ftSourceField#',#arguments.stMetadata.ftImageWidth#,#arguments.stMetadata.ftImageHeight#,true);</script>
				<br class="clear">
			</div>
		</cfoutput></cfsavecontent>
		
		<cfreturn html />
	</cffunction>
	
	<cffunction name="ajax" output="false" returntype="string" hint="Response to ajax requests for this formtool">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var stResult = structnew() />
		<cfset var stFixed = structnew() />
		<cfset var stSource = structnew() />
		<cfset var stFile = structnew() />
		<cfset var stImage = structnew() />
		<cfset var resizeinfo = "" />
		<cfset var source = "" />
		<cfset var html = "" />
		<cfset var json = "" />
		<cfset var stJSON = structnew() />
		
		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
		
		<cfif structkeyexists(url,"check")>
			<cfreturn "[]" />
		</cfif>
		
		<cfif structkeyexists(url,"crop")>
			<cfset source = arguments.stObject[listfirst(arguments.stMetadata.ftSourceField,":")] />
			<cfif isvalid("uuid",source)>
				<cfset stSource = application.fapi.getContentObject(objectid=source) />
				<cfset source = stSource[listlast(arguments.stMetadata.ftSourceField,":")] />
			</cfif>
			
			<cfif not structkeyexists(arguments.stMetadata,"ftImageWidth") or not isnumeric(arguments.stMetadata.ftImageWidth)><cfset arguments.stMetadata.ftImageWidth = 0 /></cfif>
			<cfif not structkeyexists(arguments.stMetadata,"ftImageHeight") or not isnumeric(arguments.stMetadata.ftImageHeight)><cfset arguments.stMetadata.ftImageHeight = 0 /></cfif>
	    	<cfparam name="arguments.stMetadata.ftAllowResizeQuality" default="false">
	    	<cfparam name="url.allowcancel" default="1" />
	    	
			<cfif len(source)>
				<cfsavecontent variable="html"><cfoutput>
					<div style="float:left;background-color:##cccccc;height:100%;width:65%;margin-right:2%;">
						<img id="cropable-image" src="#application.url.imageroot##source#" />
					</div>
					<div style="float:left;width:30%;">
						<div class="image-crop-instructions" style="overflow-y:auto;overlow-y:hidden;">
							<p class="image-resize-information ui-state-highlight ui-corner-all" style="padding:0.7em;margin-top:0.7em;">
								Your selection:<br>
								Coordinates: (<span id="image-crop-a-x">?</span>,<span id="image-crop-a-y">?</span>) to (<span id="image-crop-b-x">?</span>,<span id="image-crop-b-y">?</span>)<br>
								Dimensions: <span id="image-crop-width">?</span>px x <span id="image-crop-height">?</span>px<br>
								<cfif arguments.stMetadata.ftImageWidth gt 0 and arguments.stMetadata.ftImageHeight gt 0>
									Ratio: 
									<cfif arguments.stMetadata.ftImageWidth gt arguments.stMetadata.ftImageHeight>
										#numberformat(arguments.stMetadata.ftImageWidth/arguments.stMetadata.ftImageHeight,"9.99")#:1
									<cfelseif arguments.stMetadata.ftImageWidth lt arguments.stMetadata.ftImageHeight>
										1:#numberformat(arguments.stMetadata.ftImageHeight/arguments.stMetadata.ftImageWidth,"9.99")#
									<cfelse><!--- Equal --->
										1:1
									</cfif> <span style="font-style:italic;">(NOTE: the size ratio is predefined for this field)</span><br>
								<cfelse>
									Ratio: <span id="image-crop-ratio-num">?</span>:<span id="image-crop-ratio-den">?</span><br>
								</cfif>
								Quality: <cfif arguments.stMetadata.ftAllowResizeQuality><input id="image-crop-quality" value="#arguments.stMetadata.ftQuality#" /><cfelse>#round(arguments.stMetadata.ftQuality*100)#%<input type="hidden" id="image-crop-quality" value="#arguments.stMetadata.ftQuality#" /></cfif>
							</p>
							<p>To choose a crop area:</p>
							<ol style="padding-left:40px;">
								<li style="list-style:decimal outside;">Click on the image where the first corner should be, and hold down the mouse button</li>
								<li style="list-style:decimal outside;">While holding the mouse button down, drag the pointer to the opposite corner. The area you're selecting should be highlighted.</li>
								<li style="list-style:decimal outside;">You can drag the selection box around the image if it isn't in the right place, or drag the edges and corners if the box isn't the right shape.</li>
								<li style="list-style:decimal outside;">Click "Crop and Resize" when you're happy.</li>
								<li style="list-style:decimal outside;">Our server will create the new image for you when you save.</li>
							</ol>
						</div>
						<div class="uniForm image-crop-actions">
							<ft:buttonPanel>
								<cfif url.allowcancel><a href="##" id="image-crop-cancel" style="padding-right:10px;">Cancel</a></cfif>
								<ft:button value="Crop and Resize" id="image-crop-finalize" onclick="$fc.imageformtool.finalizeCrop();return false;" />
							</ft:buttonPanel>
						</div>
					</div>
				</cfoutput></cfsavecontent>
				
				<cfreturn html />
			<cfelse>
				<cfreturn "<p>The source field is empty. <a href='##' onclick='$fc.imageformtool.endCrop();return false;'>Close</a></p>" />
			</cfif>
		</cfif>
		
		<cfset stResult = handleFilePost(objectid=arguments.stObject.objectid,existingfile=arguments.stMetadata.value,uploadfield="#arguments.stMetadata.name#NEW",destination=arguments.stMetadata.ftDestination,allowedExtensions=arguments.stMetadata.ftAllowedExtensions,stFieldPost=arguments.stFieldPost.stSupporting) />
		
		<cfif isdefined("stResult.stError.message") and len(stResult.stError.message)>
			<cfset stJSON = structnew() />
			<cfset stJSON["error"] = stResult.stError.message />
			<cfset stJSON["value"] = stResult.value />
			<cfreturn serializeJSON(stJSON) />
		</cfif>
		
		<cfif stResult.bChanged>
		
			<cfif isdefined("stResult.value") and len(stResult.value)>
			
				<cfif not structkeyexists(arguments.stFieldPost.stSupporting,"ResizeMethod") or not isnumeric(arguments.stFieldPost.stSupporting.ResizeMethod)><cfset arguments.stFieldPost.stSupporting.ResizeMethod = arguments.stMetadata.ftAutoGenerateType /></cfif>
				<cfif not structkeyexists(arguments.stFieldPost.stSupporting,"Quality") or not isnumeric(arguments.stFieldPost.stSupporting.Quality)><cfset arguments.stFieldPost.stSupporting.Quality = arguments.stMetadata.ftQuality /></cfif>
				
				<cfset stFixed = fixImage("#application.path.imageroot##stResult.value#",arguments.stMetadata,arguments.stFieldPost.stSupporting.ResizeMethod,arguments.stFieldPost.stSupporting.Quality) />
				
				<cfset stJSON = structnew() />
				<cfif stFixed.bSuccess>
					<cfset stJSON["resizedetails"] = structnew() />
					<cfset stJSON["resizedetails"]["method"] = arguments.stFieldPost.stSupporting.ResizeMethod />
					<cfset stJSON["resizedetails"]["quality"] = round(arguments.stFieldPost.stSupporting.Quality*100) />
					<cfset stResult.value = stFixed.value />
				</cfif>
				
				<cfset stFile = getFileInfo(application.path.imageroot & stResult.value) />
				<cfimage action="info" source="#application.path.imageroot##stResult.value#" structName="stImage" />
				<cfset stJSON["value"] = stResult.value />
				<cfset stJSON["filename"] = listlast(stResult.value,'/') />
				<cfset stJSON["fullpath"] = application.url.imageroot & getDirectoryFromPath(stResult.value) & urlencodedformat(getFileFromPath(stResult.value)) />
				<cfset stJSON["size"] = round(stFile.size/1024) />
				<cfset stJSON["width"] = stImage.width />
				<cfset stJSON["height"] = stImage.height />
				
				<cfset onFileChange(typename=arguments.typename,objectid=arguments.stObject.objectid,stMetadata=arguments.stMetadata,value=stResult.value) />
				
				<cfreturn serializeJSON(stJSON) />
			
			</cfif>
		</cfif>
		
		<cfif not len(stResult.value) and structkeyexists(arguments.stMetadata,"ftSourceField") and len(arguments.stMetadata.ftSourceField)>
		
			<cfset stResult = handleFileSource(sourceField=arguments.stMetadata.ftSourceField,stObject=arguments.stObject,destination=arguments.stMetadata.ftDestination,stFields=application.stCOAPI[arguments.typename].stProps) />
			
			<cfif not structkeyexists(arguments.stFieldPost.stSupporting,"ResizeMethod") or not len(arguments.stFieldPost.stSupporting.ResizeMethod)><cfset arguments.stFieldPost.stSupporting.ResizeMethod = arguments.stMetadata.ftAutoGenerateType /></cfif>
			<cfif not structkeyexists(arguments.stFieldPost.stSupporting,"Quality") or not isnumeric(arguments.stFieldPost.stSupporting.Quality)><cfset arguments.stFieldPost.stSupporting.Quality = arguments.stMetadata.ftQuality /></cfif>
			
			<cfif len(stResult.value)>
				<cfset stFixed = fixImage("#application.path.imageroot##stResult.value#",arguments.stMetadata,arguments.stFieldPost.stSupporting.ResizeMethod,arguments.stFieldPost.stSupporting.Quality) />
				
				<cfset stJSON = structnew() />
				<cfif stFixed.bSuccess>
					<cfset stJSON["resizedetails"] = structnew() />
					<cfset stJSON["resizedetails"]["method"] = arguments.stFieldPost.stSupporting.ResizeMethod />
					<cfset stJSON["resizedetails"]["quality"] = round(arguments.stFieldPost.stSupporting.Quality*100) />
					<cfset stResult.value = stFixed.value />
				</cfif>

				<cfset stFile = getFileInfo(application.path.imageroot & stResult.value) />
				<cfimage action="info" source="#application.path.imageroot##stResult.value#" structName="stImage" />
				<cfset stJSON["value"] = stResult.value />
				<cfset stJSON["filename"] = listlast(stResult.value,'/') />
				<cfset stJSON["fullpath"] = application.url.imageroot & getDirectoryFromPath(stResult.value) & urlencodedformat(getFileFromPath(stResult.value)) />
				<cfset stJSON["size"] = round(stFile.size/1024) />
				<cfset stJSON["width"] = stImage.width />
				<cfset stJSON["height"] = stImage.height />
				<cfset stJSON["q"] = cgi.query_string />
				
				<cfset onFileChange(typename=arguments.typename,objectid=arguments.stObject.objectid,stMetadata=arguments.stMetadata,value=stResult.value) />
				
				<cfreturn serializeJSON(stJSON) />
			</cfif>
		</cfif>
		
		<cfreturn "{}" />
	</cffunction>
	
	<cffunction name="fixImage" access="public" output="false" returntype="struct" hint="Fixes an image's size, returns true if the image needed to be corrected and false otherwise">
		<cfargument name="filename" type="string" required="true" hint="The image" />
		<cfargument name="stMetadata" type="struct" required="true" hint="Property metadata" />
		<cfargument name="resizeMethod" type="string" required="true" default="#arguments.stMetadata.ftAutoGenerateType#" hint="The resizing method to use to fix the size." />
		<cfargument name="quality" type="string" required="true" default="#arguments.stMetadata.ftQuality#" hint="Quality setting to use for resizing" />
		
		<cfset var stGeneratedImageArgs = structnew() />
		<cfset var stImage = structnew() />
		<cfset var stGeneratedImage = structnew() />
		<cfset var q = "" />
		
		<cfimage action="info" source="#arguments.filename#" structname="stImage" />
		
		<cfparam name="arguments.stMetadata.ftCropPosition" default="center" />
		<cfparam name="arguments.stMetadata.ftCustomEffectsObjName" default="imageEffects" />
		<cfparam name="arguments.stMetadata.ftLCustomEffects" default="" />
		<cfparam name="arguments.stMetadata.ftConvertImageToFormat" default="" />
		<cfparam name="arguments.stMetadata.ftbSetAntialiasing" default="true" />
		<cfparam name="arguments.stMetadata.ftInterpolation" default="highestQuality" />
		<cfparam name="arguments.stMetadata.ftQuality" default="#arguments.quality#" />
		<cfif not len(arguments.resizeMethod)><cfset arguments.resizeMethod = arguments.stMetadata.ftAutoGenerateType /></cfif>
		
		<cfset stGeneratedImageArgs.Source = arguments.filename />
		<cfset stGeneratedImageArgs.Destination = "" />
		
		<cfif isNumeric(arguments.stMetadata.ftImageWidth)>
			<cfset stGeneratedImageArgs.width = arguments.stMetadata.ftImageWidth />
		<cfelse>
			<cfset stGeneratedImageArgs.width = 0 />
		</cfif>
		
		<cfif isNumeric(arguments.stMetadata.ftImageHeight)>
			<cfset stGeneratedImageArgs.Height = arguments.stMetadata.ftImageHeight />
		<cfelse>
			<cfset stGeneratedImageArgs.Height = 0 />
		</cfif>
		
		<cfset stGeneratedImageArgs.customEffectsObjName = arguments.stMetadata.ftCustomEffectsObjName />
		<cfset stGeneratedImageArgs.lCustomEffects = arguments.stMetadata.ftLCustomEffects />
		<cfset stGeneratedImageArgs.convertImageToFormat = arguments.stMetadata.ftConvertImageToFormat />
		<cfset stGeneratedImageArgs.bSetAntialiasing = arguments.stMetadata.ftBSetAntialiasing />
		<cfif not isValid("boolean", stGeneratedImageArgs.bSetAntialiasing)>
			<cfset stGeneratedImageArgs.bSetAntialiasing = true />
		</cfif>
		<cfset stGeneratedImageArgs.interpolation = arguments.stMetadata.ftInterpolation />
		<cfset stGeneratedImageArgs.quality = arguments.stMetadata.ftQuality />
		<cfset stGeneratedImageArgs.bUploadOnly = false />
		<cfset stGeneratedImageArgs.PadColor = arguments.stMetadata.ftPadColor />
		<cfset stGeneratedImageArgs.ResizeMethod = arguments.resizeMethod />
		
		<cfif (stGeneratedImageArgs.width gt 0 and stGeneratedImageArgs.width neq stImage.width)
		   or (stGeneratedImageArgs.height gt 0 and stGeneratedImageArgs.height neq stImage.height)
		   or len(stGeneratedImageArgs.lCustomEffects)>
			<cfset stGeneratedImage = GenerateImage(argumentCollection=stGeneratedImageArgs) />
			<cfreturn passed(arguments.stMetadata.ftDestination & "/" & stGeneratedImage.filename) />
		<cfelse>
			<cfreturn failed(arguments.filename) />
		</cfif>
	</cffunction>
	
	<cffunction name="handleFilePost" access="public" output="false" returntype="struct" hint="Handles image post and returns standard formtool result struct">
		<cfargument name="objectid" type="uuid" required="true" hint="The objectid of the edited object" />
		<cfargument name="existingfile" type="string" required="true" hint="Current value of property" />
		<cfargument name="uploadfield" type="string" required="true" hint="Traditional form saves will use <PREFIX><PROPERTY>NEW, ajax posts will use <PROPERTY>NEW ... so the caller needs to say which it is" />
		<cfargument name="destination" type="string" required="true" hint="Destination of file" />
		<cfargument name="allowedExtensions" type="string" required="true" hint="The acceptable extensions" />
		<cfargument name="stFieldPost" type="struct" required="false" default="#structnew()#" hint="The supplementary data" />
		
		<cfset var uploadFileName = "" />
		<cfset var archivedFile = "" />
		<cfset var stResult = passed(arguments.existingfile) />
		
		<cfparam name="stFieldPost.NEW" default="" />
		<cfparam name="stFieldPost.DELETE" default="false" /><!--- Boolean --->
		
		<cfset stResult.bChanged = false />
		
		<!--- If developer has entered an ftDestination, make sure it starts with a slash --->
		<cfif len(arguments.destination) AND left(arguments.destination,1) NEQ "/">
			<cfset arguments.destination = "/#arguments.destination#" />
		</cfif>
		
		<cfif NOT DirectoryExists("#application.path.imageRoot##arguments.destination#")>
			<cfset createFolderPath("#application.path.imageRoot##arguments.destination#") />
		</cfif>
		
		<cfif ((structkeyexists(form,arguments.uploadfield) and len(form[arguments.uploadfield])) or stFieldPost.DELETE) and len(arguments.existingfile) AND fileExists("#application.path.imageRoot##arguments.existingfile#")>
			
			<cfif NOT DirectoryExists("#application.path.mediaArchive##arguments.destination#")>
				<cfdirectory action="create" directory="#application.path.mediaArchive##arguments.destination#" />
			</cfif>
			
			<cfset archivedFile = "#application.path.mediaArchive##arguments.destination#/#arguments.objectid#-#DateDiff('s', 'January 1 1970 00:00', now())#-#listLast(arguments.existingfile, '/')#" />
			<cffile action="move" source="#application.path.imageRoot##arguments.existingfile#" destination="#archivedFile#" />
		    
		    <cfset stResult = passed("") />
		    <cfset stResult.bChanged = true />
		    
		</cfif>
		
	  	<cfif structkeyexists(form,arguments.uploadfield) and len(form[arguments.uploadfield])>
	  	
	    	<cfif len(arguments.existingfile)>
	    		
				<!--- This means there is already a file associated with this object. The new file must have the same name. --->
				<cfset uploadFileName = listLast(arguments.existingfile, "/\") />
				
				<cffile action="upload" filefield="#arguments.uploadfield#" destination="#application.path.imageRoot##arguments.destination#" nameconflict="MakeUnique" mode="664" />
				
				<cfif listlast(arguments.existingfile,".") eq listlast(cffile.serverFileExt,".")>
					<cffile action="rename" source="#application.path.imageRoot##arguments.destination#/#cffile.ServerFile#" destination="#uploadFileName#" />
					<cfset stResult = passed("#arguments.destination#/#uploadFileName#") />
		    		<cfset stResult.bChanged = true />
				<cfelse>
					<cffile action="delete" file="#application.path.imageRoot##arguments.destination#/#cffile.ServerFile#" />
					<cffile action="move" source="#archivedFile#" destination="#application.path.imageRoot##arguments.existingfile#" />
					<cfset stResult = failed(value=arguments.existingfile,message="Replacement images must have the same extension") />
				</cfif>
				
			<cfelse>
				
				<!--- There is no image currently so we simply upload the image and make it unique  --->
				<cffile action="upload" filefield="#arguments.uploadfield#" destination="#application.path.imageRoot##arguments.destination#" nameconflict="MakeUnique" mode="664" />
				
				<cfif listFindNoCase(arguments.allowedExtensions,cffile.serverFileExt)>
					<cfset stResult = passed("#arguments.destination#/#cffile.ServerFile#") />
		    		<cfset stResult.bChanged = true />
				<cfelse>
					<cffile action="delete" file="#application.path.imageRoot##arguments.destination#/#cffile.ServerFile#" />
					<cfset stResult = failed(value="",message="Images must have one of these extensions: #arguments.allowedExtensions#") />
				</cfif>
				
			</cfif>
			
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="handleFileSource" access="public" output="false" returntype="struct" hint="Handles the alternate case to handleFileSubmission where the file is sourced from another property">
		<cfargument name="sourceField" type="string" required="true" hint="The source field to use" />
		<cfargument name="stObject" type="struct" required="true" hint="The full set of object properties" />
		<cfargument name="destination" type="string" required="true" hint="Destination of file" />
		<cfargument name="stFields" type="struct" required="true" hint="Full content type property metadata" />
		
		<cfset var sourceFieldName = "" />
		<cfset var libraryFieldName = "" />
		<cfset var stImage = structnew() />
		<cfset var sourcefilename = "" />
		<cfset var finalfilename = "" />
		<cfset var uniqueid = 0 />
		
		<cfif not len(arguments.sourceField) and structkeyexists(arguments.stObject,listfirst(arguments.sourceField,":")) and len(arguments.stObject[listfirst(arguments.sourceField,":")])>
			<cfreturn passed("") />
		<cfelse>
			<cfset sourceFieldName = listfirst(arguments.sourceField,":") />
			
			<!--- The source could be from an image library in which case, the source field will be in the form 'uuidField:imageLibraryField' --->
			<cfset libraryFieldName = listlast(arguments.sourceField,":") />
		</cfif>
		
		<!--- If developer has entered an ftDestination, make sure it starts with a slash --->
		<cfif len(arguments.destination) AND left(arguments.destination,1) NEQ "/">
			<cfset arguments.destination = "/#arguments.destination#" />
		</cfif>
		
		<cfif NOT DirectoryExists("#application.path.imageRoot##arguments.destination#")>
			<cfset createFolderPath("#application.path.imageRoot##arguments.destination#") />
		</cfif>
		
		<!--- Get the source filename --->
		<cfif len(arguments.stObject[sourceFieldName])>
		    <cfif arguments.stFields[sourceFieldName].metadata.ftType EQ "uuid">
				<!--- This means that the source image is from an image library. We now expect that the source image is located in the source field of the image library --->
				<cfset stImage = application.fapi.getContentObject(objectid="#arguments.stObject[sourceFieldName]#") />
				<cfif structKeyExists(stImage, libraryFieldName) AND len(stImage[libraryFieldName])>
					<cfset sourcefilename = stImage[libraryFieldName] />
				</cfif>
			<cfelse>
				<cfset sourcefilename = arguments.stObject[sourceFieldName] />
			</cfif>
		<cfelse>
			<cfset sourcefilename = "" />
		</cfif>
		
		<!--- Copy the source into the new field --->
		<cfif len(sourcefilename)>
			<cfset finalfilename = arguments.destination & '/' & listlast(sourcefilename,"\/") />
			<cfloop condition="fileexists(application.path.imageRoot & finalfilename)">
				<cfset uniqueid = uniqueid + 1 />
				<cfset finalfilename = arguments.destination & '/' & listfirst(listlast(sourcefilename,"\/"),".") & uniqueid & "." & listlast(sourcefilename,".") />
			</cfloop>
			
			<cffile action="copy" source="#application.path.imageRoot##sourcefilename#" destination="#application.path.imageRoot##finalfilename#" mode="664" />
			<cfreturn passed(finalfilename) />
		<cfelse>
			<cfreturn passed("") />
		</cfif>
				
	</cffunction>
	
	<cffunction name="display" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
	  <cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
	  <cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
	  <cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
	  <cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
	
	  <cfset var html = "" />
	  
	  <cfparam name="arguments.stMetadata.ftAutoGenerateType" default="FitInside">
	  <cfparam name="arguments.stMetadata.ftImageWidth" default="0">
	  <cfparam name="arguments.stMetadata.ftImageHeight" default="0">
	  
	  <cfsavecontent variable="html">
	    <cfif len(arguments.stMetadata.value)>
	      <cfoutput><img src="#application.fapi.getImageWebRoot()##arguments.stMetadata.value#" border="0"
	        <cfif arguments.stMetadata.ftAutoGenerateType EQ "ForceSize" OR arguments.stMetadata.ftAutoGenerateType EQ "Pad" >
	          <cfif len(arguments.stMetadata.ftImageWidth) and arguments.stMetadata.ftImageWidth GT 0>width="#arguments.stMetadata.ftImageWidth#"</cfif>
	          <cfif len(arguments.stMetadata.ftImageHeight) and arguments.stMetadata.ftImageHeight GT 0>height="#arguments.stMetadata.ftImageHeight#"</cfif>
	        </cfif>
	      /></cfoutput>
	    </cfif>
	  </cfsavecontent>
	  
	  <cfreturn html>
	</cffunction>
	
	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
	    <cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type. Includes Value and stSupporting">
	    <cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
	    <cfargument name="stImageArgs" required="true" type="struct" default="#structNew()#" hint="Append any additional image arguments for image generation.">
	    <cfargument name="objectid" required="true" type="uuid" hint="objectid of image object" />
	
		<cfset var stResult = structNew() />
		<cfset var stGeneratedImageArgs = arguments.stImageArgs />
		<cfset var uploadFileName = "" />
		<cfset var b = "" />
		<cfset var newFileName = "" />
		<cfset var lFormField = "" /> 
		
		
		<cfset stResult = handleFilePost(objectid=arguments.objectid,existingfile=arguments.stFieldPost.value,uploadfield="#arguments.stMetadata.FormFieldPrefix##arguments.stMetadata.name#TRADITIONAL",destination=arguments.stMetadata.ftDestination,allowedExtensions=arguments.stMetadata.ftAllowedExtensions,stFieldPost=arguments.stFieldPost.stSupporting) />
		
		<cfif stResult.bChanged>
			<cfif isdefined("stResult.value") and len(stResult.value)>
			
				<cfparam name="arguments.stFieldPost.stSupporting.ResizeMethod" default="#arguments.stMetadata.ftAutoGenerateType#" />
				<cfparam name="arguments.stFieldPost.stSupporting.Quality" default="#arguments.stMetadata.ftQuality#" />
				
				<cfset stFixed = fixImage("#application.path.imageroot##stResult.value#",arguments.stMetadata,arguments.stFieldPost.stSupporting.ResizeMethod,arguments.stFieldPost.stSupporting.Quality) />
				
				<cfif stFixed.bSuccess>
					<cfset stResult.value = stFixed.value />
				</cfif>
				
			</cfif>
			
			<cfset onFileChange(typename=arguments.typename,objectid=arguments.objectid,stMetadata=arguments.stMetadata,value=stResult.value) />
		</cfif>
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult />
		
	</cffunction>
	
	
	<cffunction name="createFolderPath" output="true" hint="Creates a folder branch" returntype="boolean">
	  <cfargument name="folderPath" type="string" required="true">
	  <cfargument name="mode" type="string" default="" required="false">
	  
	  
	  <cfset var depth = "" />
	  <cfset var thePath = replace(arguments.folderPath,"\", "/","ALL") />
	  <cfset var arFolders = "" />
	  <cfset var pathLen = 0 />
	  <cfset var workingPath = "" />
	  <cfset var bUNC = false />
	  <cfset var indexStart = 1 />
	
	  <cfif left(arguments.folderPath,1) eq "/"><!--- *nix path --->
	    <cfset workingPath = "/">
	  <cfelseif left(arguments.folderPath,2) eq "\\"><!--- UNC Path --->
	    <cfset bUNC = true>
	    <cfset workingPath = "\\" & listFirst(arguments.folderPath, "\") & "\">
	    <cfset indexStart = 2>
	  <cfelse>
	    <cfset workingPath = listFirst(thePath, "/")&"/"><!--- windows path --->
	    <cfset thePath = listDeleteAt(thePath,1, "/")>
	  </cfif>
	  <cfset arFolders = listToArray(thePath, "/")>
	  
	  
	  <cfloop from="#indexStart#" to="#arrayLen(arFolders)#" index="depth">
	    
	    <cfif bUNC>
	      <cfset workingPath = workingPath.concat(arFolders[depth]&"\")>
	    <cfelse>
	      <cfset workingPath = workingPath.concat(arFolders[depth]&"/")>
	    </cfif>
	
	    
	    <cfif not directoryExists(workingPath)>
	      <cftry>
	      <cfif arguments.mode eq "">
	        <cfdirectory action="create" directory="#workingPath#">     
	      <cfelse>
	        <cfdirectory action="create" directory="#workingPath#" mode="#arguments.mode#">
	      </cfif>
	      <cfcatch>
	        <cfoutput>failed creating folder #workingPath#</cfoutput>
	        <cfreturn false>
	      </cfcatch>
	      </cftry>
	    </cfif>
	  
	  </cfloop>
	  <cfreturn true>
	</cffunction>
	
	<cffunction name="GenerateImage" access="public" output="false" returntype="struct">
		<cfargument name="source" type="string" required="true" hint="The absolute path where the image that is being used to generate this new image is located." />
		<cfargument name="destination" type="string" required="false" default="" hint="The absolute path where the image will be stored." />
		<cfargument name="width" type="numeric" required="false" default="#application.config.image.StandardImageWidth#" hint="The maximum width of the new image." />
		<cfargument name="height" type="numeric" required="false" default="#application.config.image.StandardImageHeight#" hint="The maximum height of the new image." />
		<cfargument name="autoGenerateType" type="string" required="false" default="FitInside" hint="How is the new image to be generated (ForceSize,FitInside,Pad)" />
		<cfargument name="padColor" type="string" required="false" default="##ffffff" hint="If AutoGenerateType='Pad', image will be padded with this colour" />
		<cfargument name="customEffectsObjName" type="string" required="true" default="imageEffects" hint="The object name to run the effects on (must be in the package path)" />
		<cfargument name="lCustomEffects" type="string" required="false" default="" hint="List of methods to run for effects with their arguments and values. The methods are order dependant replecting how they are listed here. Example: ftLCustomEffects=""roundCorners();reflect(opacity=40,backgroundColor='black');""" />
		<cfargument name="convertImageToFormat" type="string" required="false" default="" hint6="Convert image to a specific format. Set value to image extension. Example: 'gif'. Leave blank for no conversion. Default=blank (no conversion)" />
		<cfargument name="bSetAntialiasing" type="boolean" required="true" default="true" hint="Use Antialiasing (better image, but slower performance)" />
		<cfargument name="interpolation" type="string" required="true" default="highestQuality" hint="set the interpolation level on the image compression" />
		<cfargument name="quality" type="string" required="false" default="0.75" hint="Quality of the JPEG destination file. Applies only to files with an extension of JPG or JPEG. Valid values are fractions that range from 0 through 1 (the lower the number, the lower the quality). Examples: 1, 0.9, 0.1. Default = 0.75" />
		<cfargument name="bUploadOnly" type="boolean" required="false" default="false" hint="The image file will be uploaded with no image optimization or changes." />
		<cfargument name="bSelfSourced" type="boolean" required="false" default="false" hint="The image file will be uploaded with no image optimization or changes." />
		<cfargument name="ResizeMethod" type="string" required="true" default="" hint="The y origin of the crop area. Options are center, topleft, topcenter, topright, left, right, bottomleft, bottomcenter, bottomright" />
		<cfargument name="watermark" type="string" required="false" default="" hint="The path relative to the webroot of an image to use as a watermark." />
		<cfargument name="watermarkTransparency" type="string" required="false" default="90" hint="The transparency to apply to the watermark." />
		
		<cfset var stResult = structNew() />
		<cfset var imageDestination = arguments.Source />
		<cfset var imageFileName = "" />
		<cfset var sourceImage = imageNew() />
		<cfset var newImage = "" />
		<cfset var cropXOrigin = 0 />
		<cfset var cropYOrigin = 0 />
		<cfset var padImage = imageNew() />
		<cfset var XCoordinate = 0 />
		<cfset var YCoordinate = 0 />
		<cfset var stBeveledImage = structNew() />
		<cfset var widthPercent = 0 />
		<cfset var heigthPercent = 0 />
		<cfset var usePercent = 0 />
		<cfset var pixels = 0 />
		<cfset var bModified = false />
		<cfset var oImageEffects = "" />
		<cfset var aMethods = "" />
		<cfset var stImageAttributeCollection = structnew() />
		<cfset stResult.bSuccess = true />
		<cfset stResult.message = "" />
		<cfset stResult.filename = "" />
		
		<cfsetting requesttimeout="120" />
		
		<cfif not fileexists(arguments.source)>
			<cfset stResult.bSuccess = False />
			<cfset stResult.message = "File doesn't exist" />
			<cfreturn stResult />
		</cfif>
		
		<!---
		FTAUTOGENERATETYPE OPTIONS
		ForceSize - Ignores source image aspect ratio and forces the new image to be the size set in the metadata width/height
		FitInside - Reduces the width and height so that it fits in the box defined by the metadata width/height
		CropToFit - A bit of both "ForceSize" and "FitInside" where it forces the image to conform to a fixed width and hight, but crops the image to maintain aspect ratio. It first attempts to crop the width because most photos are taken from a horizontal perspective with a better chance to remove a few pixels than from the header and footer.
		Pad - Reduces the width and height so that it fits in the box defined by the metadata width/height and then pads the image so it ends up being the metadata width/height
		--->
		
		<!--- Image has changed --->
		<cftry>
			<!--- Read image into memory --->
			<cfset sourceImage = ImageRead(arguments.source) />
			<!--- Duplicate the image so we don't damage the source --->
			<cfset newImage = imageDuplicate(sourceImage) />
			<cfif arguments.bSetAntialiasing is true>
				<cfset ImageSetAntialiasing(newImage,"on") />
			</cfif>
			
			<cfcatch type="any">
				<cftrace type="warning" text="Minimum version of ColdFusion 8 required for cfimage tag manipulation. Using default image.cfc instead" />
				<!--- Should we abort here with a dump? --->
				<cfdump var="#cfcatch#" expand="true" label="" /><cfabort />
				<cfset stResult = createObject("component", "farcry.core.packages.formtools.image").GenerateImage(Source=arguments.Source, Destination=arguments.Destination, Width=arguments.Width, Height=arguments.Height, AutoGenerateType=arguments.AutoGenerateType, PadColor=arguments.PadColor) />
				<cfreturn stResult />
			</cfcatch>
		</cftry>
	
		<cfif len(arguments.destination)>
			<cfset imageFileName = replace(arguments.source, "\", "/", "all") />
			<cfset imageFileName = listLast(imageFileName, "/") />
			
			<cfset imageDestination = arguments.Destination />
			
			<!--- Create the directory for the image if it doesnt already exist --->
			<cfif not directoryExists("#ImageDestination#")>
				<cfdirectory action="create" directory="#ImageDestination#" />
			</cfif>
			
			<!--- duplicates shouldnt exist, checks now in validate function for all image options --->
			<cfif fileExists("#ImageDestination#/#imageFileName#") AND NOT arguments.bSelfSourced>
			
				<cffile 
					action = "move"
					source = "#ImageDestination#/#imageFileName#"
					destination = "#ImageDestination#/#dateFormat(now(),'yyyymmdd')#_#timeFormat(now(),'hhmmssl')#_#imageFileName#">
			
			</cfif>
			
			<!--- Include the image filename into the image destination. --->
			<cfset ImageDestination = "#ImageDestination#/#imageFileName#" />                 
			
			<!--- Copy the image to the new destination folder --->
			<cfif NOT arguments.bSelfSourced>
				<cffile action="copy" 
					source="#arguments.Source#"
					destination="#ImageDestination#" mode="664">
			</cfif>
			
			<!--- update the return filename --->       
			<cfset stResult.filename = imageFileName /> 
		</cfif>
		
		
		<cfif arguments.bUploadOnly is true>
			<!--- We do not want to modify the file, so exit now --->
			<cfreturn stResult />
		</cfif>
	
		<cfswitch expression="#arguments.ResizeMethod#">
		
			<cfcase value="ForceSize">
				<!--- Simply force the resize of the image into the width/height provided --->
				<cfset imageResize(newImage,arguments.Width,arguments.Height,"#arguments.interpolation#") />
			</cfcase>
			
			<cfcase value="FitInside">
				<!--- If the Width of the image is wider than the requested width, resize the image in the correct proportions to be the width requested --->
				<cfif arguments.Width gt 0 and newImage.width gt arguments.Width>
					<cfset imageScaleToFit(newImage,arguments.Width,"","#arguments.interpolation#") />
				</cfif>
				
				<!--- If the height of the image (after the previous width setting) is taller than the requested height, resize the image in the correct proportions to be the height requested --->
				<cfif arguments.Height gt 0 and newImage.height gt arguments.Height>
					<cfset imageScaleToFit(newImage,"",arguments.Height,"#arguments.interpolation#") />
				</cfif>
			</cfcase>
			
			<cfcase value="CropToFit">
				<!--- First we try to crop the width because most photos are taken with a horizontal perspective --->
				
				<!--- If the height of the image (after the previous width setting) is taller than the requested height, resize the image in the correct proportions to be the height requested --->
				<cfif newImage.height gt arguments.Height>
					<cfset imageScaleToFit(newImage,"",arguments.Height,"#arguments.interpolation#") />
					<cfif newImage.width gt arguments.Width>
						<!--- Find where to start on the X axis, then crop (either use ceiling() or fix() ) --->
						<cfset cropXOrigin = ceiling((newImage.width - arguments.Width)/2) />
						<cfset ImageCrop(newImage,cropXOrigin,0,arguments.Width,arguments.Height) />
					</cfif>
					
					<!--- Else If the Width of the image is wider than the requested width, resize the image in the correct proportions to be the width requested --->
				<cfelseif newImage.width gt arguments.Width>
					<cfset imageScaleToFit(newImage,arguments.Width,"","#arguments.interpolation#") />
					<cfif newImage.height gt arguments.Height>
						<!--- Find where to start on the Y axis (either use ceiling() or fix() ) --->
						<cfset cropYOrigin = ceiling((newImage.height - arguments.Height)/2) />
						<cfset ImageCrop(newImage,0,cropYOrigin,arguments.Width,arguments.Height) />
					</cfif>
				</cfif>
			</cfcase>
	
			<cfcase value="Pad">
				<!--- Scale To Fit --->
				<cfset imageScaleToFit(newImage,arguments.Width,arguments.Height,"#arguments.interpolation#") />
				
				<!--- Check if either the new height or new width is smaller than the arugments width and height. If yes, then padding is needed --->
				<cfif newImage.height lt arguments.Height or newImage.width lt arguments.Width>
					<!--- Create a temp image with background color = PadColor --->
					<cfset padImage = ImageNew("",arguments.Width,arguments.Height,"argb",arguments.PadColor) />
					<!--- Because ImageScaleToFit doesn't always work correctly (it may make the width or height it used to scale by smaller than it should have been... usually by 1 pixel) we need to account for that becfore we paste --->
					<!--- Either use ceiling() or fix() depending on which side you want the extra pixeled padding on (This won't be a problem if Adobe fixes the bug in ImageScaleToFit in a future version of ColdFusion) --->
					<cfset XCoordinate = ceiling((arguments.Width - newImage.Width)/2) />
					<cfset YCoordinate = ceiling((arguments.Height - newImage.height)/2) />
					<!--- Paste the scaled image over the new drawn image --->
					<cfset ImagePaste(padImage,newImage,XCoordinate,YCoordinate) />
					<cfset newImage = imageDuplicate(padImage) />
				</cfif>
			</cfcase>
			
			<cfcase value="center,topleft,topcenter,topright,left,right,bottomleft,bottomcenter,bottomright">
				<!--- Resize image without going over crop dimensions--->
				<!--- Permission for original version of aspectCrop() method given by authors Ben Nadel and Emmet McGovern --->
				<cfset widthPercent = arguments.Width / newImage.width>
				<cfset heightPercent = arguments.Height / newImage.height>
				
				<cfif widthPercent gt heightPercent>
					<cfset usePercent = widthPercent>
					<cfset pixels = newImage.width * usePercent + 1>
					<cfset cropYOrigin = ((newImage.height - arguments.Height)/2)>
					<cfset imageResize(newImage,pixels,"") />
				<cfelse>
					<cfset usePercent = heightPercent>
					<cfset pixels = newImage.height * usePercent + 1>
					<cfset cropXOrigin = ((newImage.width - arguments.Height)/2)>
					<cfset imageResize(newImage,"",pixels) />
				</cfif>
				
				<!--- Set the xy offset for cropping, if not provided defaults to center --->
				<cfif listfindnocase("topleft,left,bottomleft", arguments.ResizeMethod)>
					<cfset cropXOrigin = 0>
				<cfelseif listfindnocase("topcenter,center,bottomcenter", arguments.ResizeMethod)>
					<cfset cropXOrigin = (newImage.width - arguments.Width)/2>
				<cfelseif listfindnocase("topright,right,bottomright", arguments.ResizeMethod)>
					<cfset cropXOrigin = newImage.width - arguments.Width>
				<cfelse>
					<cfset cropXOrigin = (newImage.width - arguments.Width)/2>
				</cfif>
				
				<cfif listfindnocase("topleft,topcenter,topright", arguments.ResizeMethod)>
					<cfset cropYOrigin = 0>
				<cfelseif listfindnocase("left,center,right", arguments.ResizeMethod)>
					<cfset cropYOrigin = (newImage.height - arguments.Height)/2>
				<cfelseif listfindnocase("bottomleft,bottomcenter,bottomright", arguments.ResizeMethod)>
					<cfset cropYOrigin = newImage.height - arguments.Height>
				<cfelse>
					<cfset cropYOrigin = (newImage.height - arguments.Height)/2>  
				</cfif> 
				
				<cftry>
					<cfset ImageCrop(newImage,cropXOrigin,cropYOrigin,arguments.Width,arguments.Height)>
					<cfcatch type="any">
						<cfdump var="#newImage#">
						<cfdump var="#arguments#" label="#cropXOrigin#-#cropYOrigin#">
						<cfdump var="#cfcatch#">
						<cfabort>
					</cfcatch>
				</cftry>
			</cfcase> 
			
			<cfdefaultcase>
				<cfif refind("^\d+,\d+-\d+,\d+$",arguments.resizeMethod)>
					<cfset pixels = listtoarray(arguments.resizeMethod,",-") />
					<cfset ImageCrop(newImage,pixels[1],pixels[2],pixels[3]-pixels[1],pixels[4]-pixels[2]) />
					
					<!--- If the Width of the image is wider than the requested width, resize the image in the correct proportions to be the width requested --->
					<cfif arguments.Width gt 0 and pixels[3]-pixels[1] gt arguments.Width>
						<cfset imageScaleToFit(newImage,arguments.Width,"","#arguments.interpolation#") />
					</cfif>
					
					<!--- If the height of the image (after the previous width setting) is taller than the requested height, resize the image in the correct proportions to be the height requested --->
					<cfif arguments.Height gt 0 and pixels[4]-pixels[2] gt arguments.Height>
						<cfset imageScaleToFit(newImage,"",arguments.Height,"#arguments.interpolation#") />
					</cfif>
				</cfif>
			</cfdefaultcase>
			
		</cfswitch>
	
		<!--- Apply Image Effects --->
		<cfif len(arguments.customEffectsObjName) and len(arguments.lCustomEffects)>
			<cfset oImageEffects = createObject("component", "#evaluate("application.formtools.#customEffectsObjName#.packagePath")#") />
			
			<!--- Covert the list to an array --->
			<cfset aMethods = listToArray(trim(arguments.lCustomEffects), ";") />
			
			<!--- Loop over array --->
			<cfloop index="i" array="#aMethods#">
				<cfset i = trim(i) />
				<cfset lArgs = "" />
				<cfset find = reFindNoCase("[^\(]+", i, 0, true) />
				<cfset methodName = mid(i, find.pos[1], find.len[1]) />
				<cfset find = reFindNoCase("\(([^\)]+)\)", i, 0, true) />
				<!--- Check if arguments exist --->
				<cfif arrayLen(find.pos) gt 1>
					<cfset lArgs = trim(mid(i, find.pos[2], find.len[2])) />
				</cfif>
				<cfset stArgCollection = structNew() />
				<cfset stArgCollection.oImage = newImage />
				<cfloop index="argsIndex" list="#lArgs#" delimiters=",">
					<cfset argName = trim(listGetAt(argsIndex,1,"=")) />
					<cfset argValue = trim(listGetAt(argsIndex,2,"=")) />
					<cfif len(argValue) gt 1 and left(argValue, 1) eq "'" and right(argValue, 1) eq "'">
						<cfset argValue = left(argValue, len(argValue)-1) />
						<!--- Allow blank values --->
						<cfif len(argValue)-1 eq 0>
							<cfset argValue = "" />
						<cfelse>
							<cfset argValue = right(argValue, len(argValue)-1) />
						</cfif>
					<cfelse>
						<cfset argValue = evaluate(argValue) />
					</cfif>
					<cfset stArgCollection[argName] = argValue />
				</cfloop>
				<!--- Run method --->
				<!--- <cfinvoke
				  component = "#oImageEffects#"
				  method = "#methodName#"
				  returnVariable = "newImage"
				  argumentCollection = "#stArgCollection#"> --->
				<cfset oImageEffects.methodName = oImageEffects[methodName] />
				<cfset newImage = oImageEffects.methodName(argumentCollection=stArgCollection) />
			</cfloop>
			
			<cfset bModified = true />
		</cfif>
	
		<cfif len(arguments.watermark) and fileExists("#application.path.webroot##arguments.watermark#")>
		
		
			<!--- THANKS KINKY SOLUTIONS FOR THE FOLLOWING CODE (http://www.bennadel.com) --->
			<!--- Read in the watermark. --->
			<cfset objWatermark = ImageNew("#application.path.webroot##arguments.watermark#") />
			
			
			<!---
			Turn on antialiasing on the existing image
			for the pasting to render nicely.
			--->
			<cfset ImageSetAntialiasing(newImage,"on") />
			
			<!---
			When we paste the watermark onto the photo, we don't
			want it to be fully visible. Therefore, let's set the
			drawing transparency before we paste.
			--->
			<cfset ImageSetDrawingTransparency(newImage,arguments.watermarkTransparency) />
	 
			<!---
			Paste the watermark on to the image. We are going
			to paste this into the center.
			--->
			<cfset ImagePaste(newImage,objWatermark,(newImage.GetWidth() - objWatermark.GetWidth()) / 2,(newImage.GetHeight() - objWatermark.GetHeight()) / 2) />
			
			<cfset bModified = true />
		</cfif>	

		<!--- Modify extension to convert image format --->
		<cfif len(arguments.convertImageToFormat)>
			<!--- Delete the working file --->
			<cftry>
				<cffile action="delete" file="#ImageDestination#">
				<cfcatch></cfcatch>
			</cftry>
			<cfset ImageDestination = listSetAt(ImageDestination, listLen(ImageDestination, "."), replace(convertImageToFormat, ".", "", "all"), ".") />
			<!--- update the return filename --->
			<cfset stResult.filename = listLast(ImageDestination,"/") />
			<cfset bModified = true />
		</cfif>
	
		<cfif arguments.ResizeMethod eq "none">
			<cfif bModified>
				<cfimage action="write" source="#newImage#" destination="#imageDestination#" overwrite="true" />
				<!--- Workaround for missing 'mode' attribute in the <cfimage> tag :: Set UNIX file rights to 'user:group' --->
				<cffile action="rename" source="#imageDestination#" destination="#imageDestination#" mode="664" />
			<cfelse>
				<!--- No changes, the file is already in place ... we're done --->
			</cfif>
		<cfelse>
			<cfscript>
				stImageAttributeCollection.action = "write";
				stImageAttributeCollection.source = newImage;
				stImageAttributeCollection.destination = imageDestination;
				stImageAttributeCollection.overwrite = "true";
				if(right(imageDestination, 4) eq ".jpg" or right(imageDestination, 5) eq ".jpeg"){
					stImageAttributeCollection.quality = arguments.quality; // This setting (from Adobe) is for jpg images only and would cause errors if used on other image types
				}
			</cfscript>
		
			<cfimage attributeCollection="#stImageAttributeCollection#" />
			<!--- Workaround for missing 'mode' attribute in the <cfimage> tag :: Set UNIX file rights to 'user:group' --->
			<cffile action="rename" source="#imageDestination#" destination="#imageDestination#" mode="664" />
			
			<cfset stResult.filename = listlast(stImageAttributeCollection.destination,"/\") />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="ImageAutoGenerateBeforeSave" access="public" output="false" returntype="struct" hint="This function is executed AFTER validation of the post (and therefore upload of source images) to trigger generation of dependant images. An updated properties struct containing any new file names is returned. NOTE: 'replacement' or regeneration is now implied - the user selects 'replace', validation deletes the existing file, and this function regenerates the image when it sees the empty field.">
		<cfargument name="stProperties" required="true" type="struct" />
		<cfargument name="stFields" required="true" type="struct" />
		<cfargument name="stFormPost" required="true" type="struct" hint="The cleaned up form post" />
		
		<cfset var thisfield = "" />
		<cfset var stResult = structnew() />
		<cfset var stFixed = false />
		
		<cfloop list="#StructKeyList(arguments.stFields)#" index="thisfield">
			<!--- If this is an image field and doesn't already have a file attached, is included in this POST update, and can be generated from a source... --->
			<cfif structKeyExists(arguments.stFields[thisfield].metadata, "ftType") AND arguments.stFields[thisfield].metadata.ftType EQ "Image" and (not structkeyexists(arguments.stProperties,thisfield) or not len(arguments.stProperties[thisfield]))
			  and structKeyExists(arguments.stFormPost, thisfield) AND structKeyExists(arguments.stFields[thisfield].metadata, "ftSourceField") and len(arguments.stFields[thisfield].metadata.ftSourceField)>
				
				<cfparam name="arguments.stFields.#thisfield#.metadata.ftDestination" default="" />    
				
				<cfset stResult = handleFileSource(sourceField=arguments.stFields[thisfield].metadata.ftSourceField,stObject=arguments.stProperties,destination=arguments.stFields[thisfield].metadata.ftDestination,stFields=arguments.stFields) />
				
				<cfif isdefined("stResult.value") and len(stResult.value)>
					
					<cfparam name="arguments.stFormPost.#thisfield#.stSupporting.ResizeMethod" default="#arguments.stFields[thisfield].metadata.ftAutoGenerateType#" />
					<cfparam name="arguments.stFormPost.#thisfield#.stSupporting.Quality" default="#arguments.stFields[thisfield].metadata.ftQuality#" />
					
					<cfset stFixed = fixImage("#application.path.imageroot##stResult.value#",arguments.stFields[thisfield].metadata,arguments.stFormPost[thisfield].stSupporting.ResizeMethod,arguments.stFormPost[thisfield].stSupporting.Quality) />
					
					<cfif stFixed.bSuccess>
						<cfset stResult.value = stFixed.value />
					</cfif>
					
					<cfset onFileChange(typename=arguments.typename,objectid=arguments.stProperties.objectid,stMetadata=arguments.stFields[thisfield].metadata,value=stResult.value) />
					<cfset stProperties[thisfield] = stResult.value />
					
				</cfif>
			
			</cfif>
		</cfloop>
		
		<cfreturn stProperties />
	</cffunction>
	
	
	<cffunction name="imageDuplicate" returntype="any" output="false" hint="Creates a clean copy of the image without references (Note: ColdFusion's duplicate() function retains references).">
		<cfargument name="oImage" type="any" required="true" hint="A ColdFusion Image Object" />
		<cfargument name="backgroundColor" type="string" required="false" default="white" hint="background color of image." />
		
		<cfset var imgInfo = imageInfo(arguments.oImage)/>
		<cfset var myImage = imageNew("", imgInfo.width, imgInfo.height, "argb", arguments.backgroundColor) />
		<cfset imagePaste(myImage, arguments.oImage, 0, 0) />
		
		<cfreturn myImage />
	</cffunction>
	
	<cffunction name="onFileChange" access="public" returntype="any" output="false" hint="Called internally (by the image formtool) just before a new image is returned to calling code.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="objectid" required="true" type="uuid" hint="The id of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="value" required="true" type="string" hint="The new filename value" />
		
		
	</cffunction>
	
	<cffunction name="onDelete" access="public" output="false" returntype="void" hint="Called from setData when an object is deleted">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
		
		<cfif not len(arguments.stObject[arguments.stMetadata.name])>
			<cfreturn /><!--- No file attached --->
		</cfif>
		
		<cfif fileexists("#application.path.defaultImagePath#/#arguments.stObject[arguments.stMetadata.name]#")>
			<cffile action="delete" file="#application.path.defaultImagePath#/#arguments.stObject[arguments.stMetadata.name]#" />
		<cfelse>
			<cfreturn /><!--- File doesn't actually exist --->
		</cfif>
	</cffunction> 

</cfcomponent> 
