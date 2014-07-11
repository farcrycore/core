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
			else if (!data.selected.length && ($self.is(":visible") || $self.css("display")=="block")){
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
			event.data.multiview.selectView(this.href.split("#")[1]);
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
		var overlaywidth = viewportwidth - 60;
		var overlayheight = viewportheight - 60;
		var overlayleft = jQuery(document).scrollLeft()-10+(viewportwidth-overlaywidth)/2;
		var overlaytop = jQuery(document).scrollTop()-10+(viewportheight-overlayheight)/2;
		if (!(allowcancel===false)) allowcancel = true;
		
		var current_crop_selection = null;
		
		// Add crop dialog markup
		jQuery("body").append("<div id='image-crop-overlay'><div class='ui-widget-overlay' style='width:"+docwidth+"px;height:"+docheight+"px;'></div><div style='width:"+(overlaywidth+22)+"px;height:"+(overlayheight+22)+"px;position:absolute;left:"+overlayleft+"px; top:"+overlaytop+"px;' class='ui-widget-shadow ui-corner-all'></div><div id='image-crop-ui' class='' style='position: absolute;background:white;width:"+overlaywidth+"px;height:"+overlayheight+"px;left:"+overlayleft+"px;top:"+overlaytop+"px; padding: 10px;'></div></div>");
		
		// Add event to end cropping when the overlay is clicked
		if (allowcancel) jQuery("#image-crop-overlay .ui-widget-overlay").bind("click",function onCropperOverlayClick(e) { if (this==e.target) cropper.cancelCrop(); });
		
		// Load and add events to crop HTML
		jQuery.ajaxSetup({ timeout:5000 });
		jQuery("#image-crop-ui").load(url+"&crop=1&allowcancel="+allowcancel,postvalues,function cropperLoadDialog(){
			var $x1 = jQuery("#image-crop-a-x");
			var $y1 = jQuery("#image-crop-a-y");
			var $x2 = jQuery("#image-crop-b-x");
			var $y2 = jQuery("#image-crop-b-y");
			var $d = jQuery("#image-crop-dimensions");
			var $w = jQuery("#image-crop-width");
			var $h = jQuery("#image-crop-height");
			var $wf = jQuery("#image-crop-width-final");
			var $hf = jQuery("#image-crop-height-final");
			var $rn = jQuery("#image-crop-ratio-num");
			var $rd = jQuery("#image-crop-ratio-den");
			var $warning = jQuery("#image-crop-warning");
			
			jQuery("#cropable-image").Jcrop({
				//"minSize" : [width,height],
				"aspectRatio" : (width && height)?width/height:0,
				"boxWidth" : overlaywidth * 0.65,
				"boxHeight" : overlayheight,
				"onChange" : function onCropperSelectionChange(c){
					$x1.html(parseInt(c.x));
					$y1.html(parseInt(c.y));
					$x2.html(parseInt(c.x2));
					$y2.html(parseInt(c.y2));
					$w.html(parseInt(c.w));
					$h.html(parseInt(c.h));
					if (c.w>c.h){
						if (c.h <= 0) {
							$rn.html("Any");
						}
						else {
							$rn.html((c.w/c.h).toFixed(2));
							$rd.html("1");
						}
					}
					else {
						if (c.w <= 0) {
							$rd.html("Any");
						}
						else {
							$rd.html((c.h/c.w).toFixed(2));
						}
						$rn.html("1");
					}
					if (width || height) {
						if (width == NaN || width == 0) {
							$wf.html(parseInt(height*(c.w/c.h)) || "?");
						}
						if (height == NaN || height == 0) {
							$hf.html(parseInt(width/(c.w/c.h)) || "?");
						}
						if ((width && c.w && c.w < width) || (height && c.h && c.h < height)) {
							$holder.css("background-color", "red");
							$d.css("color", "red");
							$warning.css("display", "block");
						}
						else {
							$holder.css("background-color", "green");
							$d.css("color", "inherit");
							$warning.css("display", "none");
						}
					}
				},
				"onSelect" : function(c){
					current_crop_selection = c;
				}
			});
			// get the jcrop holder div after jcrop has been created in the dom
			var $holder = jQuery(".jcrop-holder");

			jQuery("#image-crop-cancel").bind("click",function onCropperCancel() { cropper.cancelCrop(); return false; });
			jQuery("#image-crop-finalize").button({}).bind("click",function onCropperFinalize() {cropper.finalizeCrop(); return false; });
			jQuery("#image-crop-overlay .image-crop-instructions").height(overlayheight-70);
		});
		
		this.cancelCrop = function cropperCancel(){
			jQuery.Jcrop('#cropable-image').destroy();
			jQuery("#image-crop-overlay").remove();
			jQuery(sourceobject).trigger("cancelcrop");
		};
		
		this.finalizeCrop = function cropperFinalize(){
			
			jQuery.Jcrop('#cropable-image').destroy();
			jQuery("#image-crop-overlay").remove();
			
			if (current_crop_selection){
				var quality = "";
				if (jQuery("#image-crop-quality").length) parseFloat(jQuery("#image-crop-quality").val());
				
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
		
		this.init = function initImageFormtool(url,filetypes,sourceField,width,height,inline,sizeLimit){

			imageformtool.url = url;
			imageformtool.filetypes = filetypes;
			imageformtool.sourceField = sourceField;
			imageformtool.width = width;
			imageformtool.height = height;
			imageformtool.inline = inline || false;
			imageformtool.sizeLimit = sizeLimit || null;
			
			imageformtool.inputs.resizemethod  = $j('#'+prefix+property+'RESIZEMETHOD');
			imageformtool.inputs.quality  = $j('#'+prefix+property+'QUALITY');
			imageformtool.inputs.deletef = $j('#'+prefix+property+'DELETE');
			imageformtool.inputs.traditional = $j('#'+prefix+property+'TRADITIONAL');
			imageformtool.inputs.newf = $j('#'+prefix+property+'NEW');
			imageformtool.inputs.base = $j('#'+prefix+property);
			
			var bUUIDSource = false;
			if (sourceField.indexOf(":")>-1){
				bUUIDSource = true;
				sourceField = sourceField.split(":")[0];
				imageformtool.sourceField = sourceField;
			}
			
    		imageformtool.multiview = $j("#"+prefix+property+"-multiview").multiView({ 
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
    			imageformtool.inlineview = $j("#"+prefix+property+"-inline")
    				.find("a.image-crop-select-button").bind("click",function onImageFormtoolCustomCropInline(){ 
    					imageformtool.inputs.deletef.val("true");
    					imageformtool.beginCrop(true); 
    					return false; 
    				}).end()
    				.find("span.action .select-view").bind("click",function(){
	    				imageformtool.multiview.selectView(this.href.split("#")[1]);
	    				return false;
    				}).end();
	    	}

			$j(imageformtool).bind("filechange",function onImageFormtoolFilechangeUpdate(event,results){
				if (results.value && results.value.length>0){
					var imageMaxWidth = (results.width < 400) ? results.width : 400;
					var complete = imageformtool.multiview.findView("complete")
						.find(".image-status").html('<i class="fa fa-picture-o fa-fw"></i>').end()
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
							.find("a.image-preview").attr("href",results.fullpath).tooltipster("update", "<img src='"+results.fullpath+"?"+new Date().getTime()+"' style='"+(imageMaxWidth?"width:"+imageMaxWidth+"px":"")+"; max-width:400px; max-height:400px;'><br><div style='width:"+previewsize.width.toString()+"px;'>"+results.size.toString()+"</span>KB, "+results.width.toString()+"px x "+results.height+"px</div>").end()
							.find("span.action-preview").show().end()
							.find("span.dependant-options").show().end();
						imageformtool.multiview.selectView("cancel");
					}
					else{
						imageformtool.multiview.find("a.image-preview").attr("href",results.fullpath).tooltipster("update", "<img src='"+results.fullpath+"?"+new Date().getTime()+"' style='width:"+(imageMaxWidth?"width:"+imageMaxWidth+"px":"")+"px; max-width:400px; max-height:400px;'>");
						imageformtool.multiview.selectView("complete");
					}
				}
			}).bind("fileerror.updatedisplay",function onImageFormtoolFileerrorDisplay(event,action,error,message){
				$j('#'+prefix+property+"_"+action+"error").html(message).show();
			}).bind("cancelcrop",function(){
			
			}).bind("savecrop",function onImageFormtoolSaveCrop(event,c,q){
				imageformtool.inputs.resizemethod.val(parseInt(c.x)+","+parseInt(c.y)+"-"+parseInt(c.x2)+","+parseInt(c.y2));
				imageformtool.inputs.quality.val(q);
				imageformtool.multiview.findView("autogenerate")
					.find(".image-crop-select-button").hide().end()
					.find(".image-crop-information").show()
						.find(".image-crop-a-x").html(parseInt(c.x)).end()
						.find(".image-crop-a-y").html(parseInt(c.y)).end()
						.find(".image-crop-b-x").html(parseInt(c.x2)).end()
						.find(".image-crop-b-y").html(parseInt(c.y2)).end()
						.find(".image-crop-width").html(parseInt(c.w)).end()
						.find(".image-crop-height").html(parseInt(c.h)).end()
						.find(".image-crop-quality").html((q*100).toFixed(0)).end();
				imageformtool.applyCrop(true);
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
				
				if (bUUIDSource){
					var $sourceField = $j("#"+prefix+sourceField);
					var existingval = $sourceField.val();
					var pending = false;

					if (existingval.indexOf(",")>-1){
			    		existingval = existingval.split(",")[0];
				    };

					function checkSource(){
						var $sourceField = $j("#"+prefix+sourceField);
						var newval = $sourceField.val();

						if (newval.indexOf(",")>-1){
				    		newval = newval.split(",")[0];
					    };

						if (newval!=existingval && !pending){
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
	    		'buttonImg'		: $fc.imageformtool.buttonImg,
				'uploader'  	: $fc.imageformtool.uploader,
				'script'    	: url,
				'checkScript'	: url+"/check/1",
				'cancelImg' 	: $fc.imageformtool.cancelImg,
				'auto'      	: true,
				'fileExt'		: filetypes,
				'fileDataName'	: property+"NEW",
				'method'		: "POST",
				'scriptData'	: {},
				'sizeLimit'		: imageformtool.sizeLimit,
				'onSelectOnce' 	: function(event,data){
					// attached related fields to uploadify post
					imageformtool.inputs.newf.uploadifySettings("scriptData",imageformtool.getPostValues());
				},
				'onComplete'	: function(event, ID, fileObj, response, data){
					var results = $j.parseJSON(response);
					
					imageformtool.inputs.newf.uploadifyClearQueue();
					
					// hide any previous results
					$j('#'+prefix+property+"_uploaderror").hide();
					
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
					if (errorObj.type === "HTTP")
						$j(imageformtool).trigger("fileerror",[ "upload",errorObj.info.toString(),'Error '+errorObj.type+": "+errorObj.info ]);
					else if (errorObj.type ==="File Size")
						$j(imageformtool).trigger("fileerror",[ "upload","filesize",fileObj.name+" is not within the file size limit of "+Math.round(imageformtool.sizeLimit/1048576)+"MB" ]);
					else
						$j(imageformtool).trigger("fileerror",[ "upload",errorObj.type,'Error '+errorObj.type+": "+errorObj.text ]);
				}
			});
		};
		
		this.getPostValues = function imageFormtoolGetPostValues(){
			// get the post values
			var values = {};
			$j('[name^="'+prefix+property+'"]').each(function(){ if (this.name!=prefix+property+"NEW") values[this.name.slice(prefix.length)]=""; });
			if (imageformtool.sourceField) values[imageformtool.sourceField] = "";
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
			$j('#'+prefix+property+"_croperror").hide();

			$fc.cropper(imageformtool,imageformtool.url,imageformtool.width,imageformtool.height,imageformtool.getPostValues(),allowcancel);
			
		};
		
		this.applyCrop = function imageFormtoolApplyCrop(bForceCrop){
			imageformtool.multiview.selectView("working");
			
			var postvalues = imageformtool.getPostValues();
	    	postvalues.bForceCrop = bForceCrop || false;
	    	
			$j.ajax({
				type : "POST",
				url : imageformtool.url,
				data : postvalues,
				success : function imageFormtoolApplyCropSuccess(results){
					// results is null if there is already an image 
					if (results) {
						if (results.error) {
							$j(imageformtool).trigger("fileerror", ["crop", "500", results.error]);
							imageformtool.multiview.selectView("autogenerate");
						}
						else {
							imageformtool.inputs.base.val(results.value);
							$j('#' + prefix + property + "_croperror").hide();
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
			
			if (imageformtool.sourceField.length) postData[imageformtool.sourceField] = '';
			
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
$fc.imageformtool.buttonImg = '/webtop/thirdparty/jquery.uploadify-v2.1.4/selectImage.png';
$fc.imageformtool.uploader = '/webtop/thirdparty/jquery.uploadify-v2.1.4/uploadify.swf';
$fc.imageformtool.cancelImg = '/webtop/thirdparty/jquery.uploadify-v2.1.4/cancel.png';