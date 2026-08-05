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
		
		this.init = function initImageFormtool(url,filetypes,sourceField,width,height,inline,sizeLimit,storage){

			imageformtool.url = url;
			imageformtool.filetypes = filetypes;
			imageformtool.sourceField = sourceField;
			imageformtool.width = width;
			imageformtool.height = height;
			imageformtool.inline = inline || false;
			imageformtool.sizeLimit = sizeLimit || null;
			imageformtool.storage = storage || "local";
			
			imageformtool.inputs.resizemethod  = $j('#'+prefix+property+'RESIZEMETHOD');
			imageformtool.inputs.quality  = $j('#'+prefix+property+'QUALITY');
			imageformtool.inputs.deletef = $j('#'+prefix+property+'DELETE');
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
	    				"upload" : function onImageFormtoolOpenUpload(event){ imageformtool.resetUploadView(); },
	    				"complete" : function onImageFormtoolOpenComplete(event){ 
		    				if (imageformtool.inputs.base.val().length){
			    				$j(this).find(".image-cancel-upload").show();
			    				$j(this).find(".image-cancel-replace").show();
			    				$j(this).find(".alert-error-readimg").remove();
			    			}
		    			},
	    				"autogenerate" : function onImageFormtoolOpenAutogenerate(event){ 
		    				if (imageformtool.inputs.base.val().length){
			    				imageformtool.inputs.deletef.val("true");
								$j(this).find(".image-custom-crop, .image-crop-select-button").show().end();
			    			}
	    				},
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
	    				"cancel" : function onImageFormtoolCloseCancel(event){
	    					imageformtool.inlineview.find("span.not-cancel").hide();
	    					imageformtool.inlineview.find("span.action-cancel").show();
	    				}
	    			}
	    		})
    			.find("a.image-crop-select-button,button.image-crop-select-button").bind("click",function onImageFormtoolCustomCrop(){ imageformtool.beginCrop(true); return false; }).end()
    			.find("a.image-recrop-button").bind("click",function onImageFormtoolRecrop(){
    				// Re-crop an existing image straight from the completed view. (The old
    				// "Regenerate" link round-tripped through the autogenerate empty-state,
    				// which only offered this same crop action plus a duplicate Upload link.)
    				// Replicate the one side effect that view had for the crop path: flag the
    				// current image for replacement so applyCrop regenerates it instead of
    				// short-circuiting ("image already exists"). _recropPending lets a cancelled
    				// cropper undo the flag — this path has no view-close to reset it, unlike
    				// the autogenerate flow.
    				if (imageformtool.inputs.base.val().length) imageformtool.inputs.deletef.val("true");
    				imageformtool._recropPending = true;
    				imageformtool.beginCrop(true);
    				return false;
    			}).end()
    			.find("a.image-crop-cancel-button,button.image-crop-cancel-button").bind("click",function onImageFormtoolCancelCrop(){ imageformtool.removeCrop(); return false; }).end()
    			.find("button.image-delete-button").bind("click",function onImageFormtoolDelete(){ imageformtool.deleteImage(); return false; }).end()
    			.find("button.image-deleteall-button").bind("click",function onImageFormtoolDeleteAll(){ imageformtool.deleteAllRelatedImages(); return false; }).end();

    		// Standalone delete button in the details panel opens a framework-agnostic
    		// confirm dialog. Source images (data-deleteall) offer the related-images variant.
    		imageformtool.multiview.find(".image-delete-trigger").bind("click",function onImageFormtoolDeleteTrigger(){
    			var deleteAll = String($j(this).attr("data-deleteall")) === "true";
    			var buttons = deleteAll
    				? [ { label:"Delete this image", value:"one", style:"primary" },
    				    { label:"Delete this and the related images", value:"all" },
    				    { label:"Cancel", value:"cancel", isCancel:true } ]
    				: [ { label:"Delete", value:"one", style:"primary" },
    				    { label:"Cancel", value:"cancel", isCancel:true } ];
    			$fc.uploader.confirm({
    				title:   "Delete this image?",
    				message: deleteAll ? "Choose whether to delete just this image, or this image and its related images." : "Are you sure you want to delete this image?",
    				buttons: buttons,
    				onSelect: function(value){
    					// A derived image (one with a source field) falls back to its autogenerate
    					// empty-state on delete — matching a fresh record, where the field offers to
    					// re-derive from the source or upload your own — rather than the bare dropzone.
    					if (value === "one") imageformtool.deleteImage(imageformtool.sourceField.length ? "autogenerate" : "upload");
    					else if (value === "all") imageformtool.deleteAllRelatedImages();
    				}
    			});
    			return false;
    		}).end();

    		// Cancel an in-flight upload from the progress row.
    		$j("#"+prefix+property+"-uploading-cancel").bind("click",function onImageFormtoolCancelUpload(e){
    			e.preventDefault();
    			if (imageformtool.uploader) imageformtool.uploader.cancelAll();
    			imageformtool.resetUploadView();
    			if (!imageformtool.inputs.base.val().length) imageformtool.multiview.selectView("upload");
    		});

    		// Keyboard: Enter / Space on the focused dropzone opens the file dialog.
    		$j("#"+prefix+property+"-dropzone").on("keydown",function onImageFormtoolDropzoneKey(e){
    			if (e.keyCode === 13 || e.keyCode === 32){ e.preventDefault(); imageformtool.inputs.newf.click(); }
    		});
    		// NB: the constraints '.fc-richtooltip' (and '.image-preview') are initialised by
    		// the 'jquery-tooltip-auto' library this formtool loads — no manual tooltipster() here.

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
					// Proportional preview box (long edge capped at 400) so the tooltip <img>
					// reserves its space immediately — tooltipster then positions correctly on
					// the first hover, before the image bytes load. (Previously it measured a
					// zero-height image and only snapped into place on a second hover.)
					var imageMaxHeight = (results.width && results.height) ? Math.round(results.height * imageMaxWidth / results.width) : 0;
					if (imageMaxHeight > 400) { imageMaxWidth = Math.round(imageMaxWidth * 400 / imageMaxHeight); imageMaxHeight = 400; }
					var complete = imageformtool.multiview.findView("complete")
						.find(".image-status").html('<i class="fa fa-file-image-o"></i>').end()
						.find(".image-filename").text(results.filename).end()
						.find(".image-size").text(results.size).end()
						.find(".image-width").text(results.width).end()
						.find(".image-height").text(results.height).end();

					if (results.resizedetails){
						complete.find(".image-quality").text(results.resizedetails.quality.toString()).end();
						// When no transform happened the server reports resized:false — say "Uploaded"
						// rather than "Resized to" so the dimensions read accurately. Backwards-compatible:
						// only an explicit false (boolean or "false" string, depending on the CF engine's
						// JSON serialization) flips the verb; a missing key falls back to "Resized to".
						var bNoResize = (results.resizedetails.resized === false || results.resizedetails.resized === "false");
						complete.find(".image-resize-verb").text(bNoResize ? "Uploaded" : "Resized to").end();
						complete.find(".image-resize-information").show().end();
					}
					else {
						complete.find(".image-resize-information").hide().end();
					}

					// Only cache-bust plain (local) URLs. Skip when the URL already carries a
					// query string — e.g. an S3 presigned URL (?X-Amz-...) — because appending a
					// second "?<timestamp>" corrupts the signature, yielding 403 Forbidden /
					// net::ERR_BLOCKED_BY_ORB on the preview tooltip image (the href is left
					// untouched, which is why opening it in a new tab still worked). Presigned
					// URLs are unique per generation, so they're inherently cache-busted anyway.
					// (Cloudinary URLs were already excluded.)
					var cachebust = "";
					if (! results.fullpath.match(/res.cloudinary.com/gi) && results.fullpath.indexOf("?") === -1) {
						cachebust = "?"+new Date().getTime();
					}
					// The preview URL is the CDN path this upload resolved to server side, but it
					// is assigned to an href/src, so it goes through the uploader's URL gate first
					// and the tooltip is built as nodes rather than as a markup string.
					var previewHREF = $fc.uploader.safeURL(results.fullpath);
					var previewSRC = $fc.uploader.safeURL(results.fullpath + cachebust);
					if (imageformtool.inline){
						imageformtool.inlineview
							.find("a.image-preview").attr("href",previewHREF || "#").tooltipster("update", imageformtool.buildPreviewTooltip(previewSRC,imageMaxWidth,imageMaxHeight,results)).end()
							.find("span.action-preview").show().end()
							.find("span.dependant-options").show().end();
						imageformtool.multiview.selectView("cancel");
					}
					else{
						imageformtool.multiview.find("a.image-preview").attr("href",previewHREF || "#").tooltipster("update", imageformtool.buildPreviewTooltip(previewSRC,imageMaxWidth,imageMaxHeight));
						imageformtool.multiview.selectView("complete");
					}
				}
			}).bind("fileerror.updatedisplay",function onImageFormtoolFileerrorDisplay(event,action,error,message){
				// message carries filenames, server exception text and HTTP response
				// snippets, so it is displayed as text, never as markup.
				$j('#'+prefix+property+"_"+action+"error").text(message).show();
				if (action === "upload") imageformtool.resetUploadView();
			}).bind("cancelcrop",function onImageFormtoolCancelCropEvent(){
				// A complete-view "Re-crop image" sets deletef=true up front; if the user
				// backs out of the cropper we clear it here so a later form save keeps the
				// current image. Scoped by _recropPending so the autogenerate flow (which
				// resets deletef on its own view-close) is left exactly as it was.
				if (imageformtool._recropPending) imageformtool.inputs.deletef.val("false");
				imageformtool._recropPending = false;
			}).bind("savecrop",function onImageFormtoolSaveCrop(event,c,q){
				imageformtool._recropPending = false;
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
    		
    		imageformtool.uploader = $fc.uploader.create({
				fileInput:         imageformtool.inputs.newf,
				fieldName:         property+"NEW",
				endpoint:          url,
				storage:           imageformtool.storage,
				allowedFileTypes:  filetypes,
				maxFileSize:       imageformtool.sizeLimit,
				maxNumberOfFiles:  1,
				autoProceed:       true,
				dropZone:          "#"+prefix+property+"-dropzone",
				onDragEnter: function(){ $j("#"+prefix+property+"-dropzone").addClass("is-dragover"); },
				onDragLeave: function(){ $j("#"+prefix+property+"-dropzone").removeClass("is-dragover"); },
				onSelect: function(file){
					imageformtool.showUploading(file);
				},
				onProgress: function(file, percent){
					imageformtool.setUploadProgress(file, percent);
				},
				extraFormData: function(){
					return imageformtool.getPostValues();
				},
				onComplete: function(file, results){
					if (imageformtool.uploader) imageformtool.uploader.cancel(file.id);

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
				onError: function(file, error){
					if (imageformtool.uploader && file) imageformtool.uploader.cancel(file.id);
					if (error.type === "http")
						$j(imageformtool).trigger("fileerror",[ "upload",String(error.status||""),'Error HTTP: '+(error.status||error.message) ]);
					else if (error.type === "size")
						$j(imageformtool).trigger("fileerror",[ "upload","filesize",(file&&file.name?file.name+" ":"")+"is not within the file size limit of "+imageformtool.formatBytes(imageformtool.sizeLimit) ]);
					else if (error.type === "type")
						$j(imageformtool).trigger("fileerror",[ "upload","filetype",error.message ]);
					else if (error.type === "network")
						$j(imageformtool).trigger("fileerror",[ "upload","network",'Network error: '+error.message ]);
					else
						$j(imageformtool).trigger("fileerror",[ "upload",error.type||"server",'Error: '+error.message ]);
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
				imageformtool.multiview.findView("complete").find(".image-recrop-link").show();
			}
			else {
				imageformtool.multiview.findView("autogenerate").find(".image-custom-crop").hide();
				imageformtool.multiview.findView("complete").find(".image-recrop-link").hide();
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

		// Preview tooltip content, built as nodes rather than as a markup string.
		// tooltipster 2.1.4 hands its content to .html(), which appends a node as-is
		// instead of parsing it, so the src is the only thing that has to be trusted -
		// and it arrives already gated by $fc.uploader.safeURL (empty = show no image).
		this.buildPreviewTooltip = function imageFormtoolBuildPreviewTooltip(src,width,height,results){
			var $content = $j("<span></span>");

			if (src){
				var $img = $j("<img>").attr("src",src).css({ "max-width":"400px", "max-height":"400px" });
				if (width) $img.attr("width",width);
				if (height) $img.attr("height",height);
				$content.append($img);
			}
			// the inline view captions the preview with the size and dimensions
			if (results){
				$content.append($j("<br>"))
					.append($j("<span></span>").text(results.size+"KB, "+results.width+"px x "+results.height+"px"));
			}

			return $content;
		};

		// --- During-upload dropzone / progress UI (mirrors the file formtool) ---------
		this.formatBytes = function imageFormtoolFormatBytes(bytes){
			bytes = Number(bytes) || 0;
			if (bytes <= 0) return "";
			var units = ["B","KB","MB","GB","TB"];
			var i = Math.floor(Math.log(bytes) / Math.log(1024));
			if (i >= units.length) i = units.length - 1;
			var v = bytes / Math.pow(1024, i);
			return (i === 0 ? Math.round(v) : v.toFixed(1)) + " " + units[i];
		};
		this.showUploading = function imageFormtoolShowUploading(file){
			var base = "#"+prefix+property;
			$j(base+"_uploaderror").hide().html("");
			$j(base+"-uploading-icon").attr("class","fa fa-file-image-o");
			$j(base+"-uploading-name").text(file.name).attr("title", file.name);
			$j(base+"-uploading-meta").text(imageformtool.formatBytes(file.size));
			$j(base+"-progress-bar").css("width","0%").attr("aria-valuenow",0).removeClass("is-complete is-error");
			$j(base+"-dropzone").hide();
			$j(base+"-constraints").hide();
			$j(base+"-uploading").show();
		};
		this.setUploadProgress = function imageFormtoolSetUploadProgress(file, percent){
			var base = "#"+prefix+property;
			$j(base+"-progress-bar").css("width", percent+"%").attr("aria-valuenow", percent);
			var sizeText = imageformtool.formatBytes(file.size);
			if (percent < 100)
				$j(base+"-uploading-meta").text((sizeText ? sizeText+"  \u00B7  " : "") + percent + "%");
			else
				$j(base+"-uploading-meta").text((sizeText ? sizeText+"  \u00B7  " : "") + "Processing...");
		};
		this.resetUploadView = function imageFormtoolResetUploadView(){
			var base = "#"+prefix+property;
			$j(base+"-uploading").hide();
			$j(base+"-progress-bar").css("width","0%").attr("aria-valuenow",0).removeClass("is-complete is-error");
			$j(base+"-dropzone").show();
			$j(base+"-constraints").show();
		};
	};
	
	if (!this[prefix+property]) this[prefix+property] = new ImageFormtool(prefix,property);
	return this[prefix+property];
};