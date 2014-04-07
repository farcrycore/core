FileModel = Backbone.Model.extend({
	idAttribute : "fileID"
});

FileCollection = Backbone.Collection.extend({
	model : FileModel,
	initialize : function FileCollection_initialize(options){
		this.statusCheckTimer = 0;
		
		_.bindAll(this,"checkStatus","updateStatus");
		
		this.listenTo(this,"add",this.addFile,this);
		this.listenTo(this,"change:status",this.changeFile,this);
	},
	
	addFile : function FileCollection_addFile(file){
		if (file.get("status") === "uploaddone" && this.statusCheckTimer === 0) {
			this.statusCheckTimer = setTimeout(this.checkStatus,1000);
		}
	},
	changeFile : function FileCollection_changeFile(file){
		var processing = this.where({
			status : "uploaddone"
		});
		
		if (!this.statusCheckTimer && processing.length){
			this.statusCheckTimer = setTimeout(this.checkStatus,500);
		}
		else if (this.statusCheckTimer && processing.length===0){
			clearTimeout(this.statusCheckTimer);
			this.statusCheckTimer = 0;
		}
	},
	
	updateOptions : function FileCollection_updateOptions(options){
		this.options = this.options || {};
		
		for (var k in options)
			this.options[k] = options[k];
	},
	
	checkStatus : function FileCollection_checkStatus(){
		Backbone.$.getJSON(this.options.statusURL + (this.options.statusURL.indexOf("?")>-1 ? "&" : "?") + "&uploader=" + this.options.uploaderID, this.updateStatus);
	},
	updateStatus : function FileCollection_updateStatus(result){
		if (result.error) {
			if (result.error.message !== this.previousError) {
				this.options.generalErrors.add({
					error: result.error
				});
			}
			this.previousError = result.error.message;
		}
		else {
			if (this.previousError)
				delete this.previousError;
			
			// make sure all the CSS / JS required for the forms have been loaded
			for (var i = 0, ii = result.htmlhead.length; i < ii; i++) {
				if (result.htmlhead[i].id !== "onready") {
					if (Backbone.$("#" + result.htmlhead[i].id).size() === 0) {
						Backbone.$("head").append(result.htmlhead[i].html);
					}
				}
			}
			
			// update the queue with the edit forms
			for (var i = 0, ii = result.files.length; i < ii; i++) {
				var file = this.get(result.files[i].taskID);
				
				if (file && result.files[i].error) {
					file.set({
						status: "failed",
						error: result.files[i].error
					});
				}
				else {
					if (file) {
						file.set({
							status: "editable",
							teaserHTML: result.files[i].teaserHTML,
							editHTML: result.files[i].editHTML
						});
					}
				}
			}
			
			// run all "onready" JavaScript
			for (var i = 0, ii = result.htmlhead.length; i < ii; i++) {
				if (result.htmlhead[i].id === "onready") {
					eval(result.htmlhead[i].html);
				}
			}
		}
		
		// if there are still items pending, queue another check
		var processing = this.where({
			status : "uploaddone"
		});
		if (processing.length)
			this.statusCheckTimer = setTimeout(this.checkStatus,500);
		else
			this.statusCheckTimer = 0;
	}
});

FileView = Backbone.View.extend({
	initialize : function FileView_initialize(options){
		this.templates = {
			added : Handlebars.compile(Backbone.$("#added-file-template").html()),
			uploading : Handlebars.compile(Backbone.$("#uploading-file-template").html()),
			uploaddone : Handlebars.compile(Backbone.$("#uploaddone-file-template").html()),
			editable : Handlebars.compile(Backbone.$("#editable-file-template").html()),
			saved : Handlebars.compile(Backbone.$("#saved-file-template").html()),
			failed : Handlebars.compile(Backbone.$("#failed-file-template").html())
		};
		
		this.listenTo(this.model,"change",this.render,this);
	},
	events : {
		"click .remove" : "removeFile",
		"click .save" : "saveFile",
		"click .icon-info" : "showInfo"
	},
	
	render : function FileView_render(){
		if (this.model.hasChanged("status") || this.$el.html() === "")
			// if the status has changed, replace the HTML
			this.$el.html(this.templates[this.model.get("status")](this.model.attributes));
		else
			// if the status is the same, call the status specific update function
			this[this.model.get("status")+"Update"]()
	},
	
	removeFile : function FileView_removeFile(){
		if (this.model.has("jqXHR"))
			this.model.get("jqXHR").abort();
		
		// remove file from memory and DOM
		this.model.collection.remove(this.model);
		this.remove();
		delete this.model;
	},
	saveFile : function FileView_saveFile(){
		var formPrefix = this.$("input[name=FarcryFormPrefixes]").val(), 
			formData = serializeFormByPrefix(formPrefix,this.options.collectionView.options.editableProperties,true)
			self = this;
		
		this.$el.block();
		
		Backbone.$.post(this.model.get("saveURL"), formData, function(result){
			if (result.error){
				self.model.set({
					status : "error",
					error : result.error
				});
			}
			else{
				self.model.set({
					status : "saved",
					teaserHTML : result.teaserHTML,
					editHTML : result.editHTML
				});
			}
			
			self.$el.unblock();
		},"json");
	},
	showInfo : function FileView_showInfo(){
		this.$(".info").toggle();
	},
	
	addedUpdate : function FileView_addedUpdate(){
		// no updates
	},
	uploadingUpdate : function FileView_uploadingUpdate(){
		var progress = this.model.get("progress");
		
		this.$(".bar").stop().animate({
			"width": formatPercentage(progress.loaded, progress.total)
		}, "fast");
		this.$(".progress-loaded").text(formatFileSize(progress.loaded));
		this.$(".progress-total").text(formatFileSize(progress.total));
		this.$(".progress-bitrate").text(formatBitRate(progress.bitrate));
	},
	uploaddoneUpdate : function FileView_uploaddoneUpdate(){
		// no updates
	},
	editableUpdate : function FileView_editableUpdate(){
		this.$(".teaser").html(this.model.get("teaserHTML"));
	},
	savedUpdate : function FileView_savedUpdated(){
		// no updates
	},
	failedUpdate : function FileView_failedUpdate(){
		// noupdates
	}
});

FileCollectionView = Backbone.View.extend({
	initialize : function FileCollectionView_initialize(options){
		this.listenTo(this.collection,"add",this.addFile,this);
	},
	
	addFile : function FileCollectionView_addFile(file){
		var fileView = new FileView({
			model : file,
			collectionView : this
		});
		
		this.$el.append(fileView.el);
		
		fileView.render();
	}
});

FileUploadView = Backbone.View.extend({
	initialize : function FileUploadView_initialize(options){
		this.template = Handlebars.compile(Backbone.$("#upload-area-template").html());

		this.indexFileID = 1;

		if (options.uploadURL === undefined)
			throw "uploadURL must be defined in FileUploadView options";
		
		if (options.saveURL === undefined)
			throw "saveURL must be defined in FileUploadView options";
		
		if (options.uploaderID === undefined)
			throw "uploaderID must be defined in FileUploadView options";
		
		this.fileUpload = {
			url : options.uploadURL,
			dataType : "json",
			sequentialUploads : true,
			limitMultiFileUploads : 1,
			autoUpload : true
		};
		
		if (options.sizeLimit)
			this.fileUpload.maxFileSize = options.sizeLimit;
		
		if (options.allowedExtensions)
        	this.fileUpload.acceptFileTypes = new RegExp("\.("+options.allowedExtensions.replace(/,/g,"|")+")$","i");
		
		Backbone.$(document).bind('drop dragover', function (e) {
		    e.preventDefault();
		});
		
		this.stopShow = 0;
		
		this.render();
	},
	events : {
		"fileuploadadd #fileupload" : "uploadAdd",
		"fileuploadsubmit #fileupload" : "uploadSubmit",
		"fileuploadsend #fileupload" : "uploadSend",
		"fileuploadprogress #fileupload" : "uploadProgress",
		"fileuploaddone #fileupload" : "uploadDone",
		"fileuploadfail #fileupload" : "uploadFail",
		
		"dragenter .targetarea" : "dragEnter",
		"dragover .targetarea" : "dragOver",
		"dragleave .targetarea" : "dragLeave"
	},
	
	render : function FileUploadView_render(){
		this.$el.html(this.template());
		this.fileUpload.dropZone = this.$(".targetarea");
	    this.$("#fileupload").fileupload(this.fileUpload);
		this.delegateEvents();
	},
	
	uploadAdd : function FileUploadView_uploadAdd(e,data){
		for (var i = 0, ii = data.files.length; i < ii; i++) {
			var file = this.collection.findWhere({
				name : data.files[i].name,
				size : data.files[i].size
			});
			
			if (file === undefined) {
				file = new FileModel({
					name: data.files[i].name,
					size: data.files[i].size,
					status: "added",
					editableProperties : this.options.editableProperties,
					saveURL : this.options.saveURL
				});
				
				this.collection.add([ file ]);
				
				file.set("jqXHR",data.submit());
			}
		}
	},
	uploadSubmit : function FileUploadView_uploadSubmit(e,data){
		var file = this.collection.findWhere({
			name : data.files[0].name,
			size : data.files[0].size
		});
		
		if (file){
			data.formData = serializeFormByPrefix("default",this.options.defaultProperties);
			data.formData.uploaderID = this.options.uploaderID;
			data.formData.fileID = this.indexFileID++;
			
			file.set("fileID",data.formData.fileID);
		}
	},
	uploadSend : function FileUploadView_uploadSend(e,data){
		var file = this.collection.findWhere({
			name : data.files[0].name,
			size : data.files[0].size
		});
		
		if (file) {
			file.set({
				status : "uploading",
				progress : {
					loaded : 0,
					total : 0,
					bitrate : 0
				}
			});
		}
	},
	uploadProgress : function FileUploadView_uploadProgress(e,data){
		var file = this.collection.get(data.formData.fileID);
		
		if (file){
			file.set({
				status : "uploading",
				progress : data._progress
			});
		}
	},
	uploadDone : function FileUploadView_uploadDone(e,data){
		var file = this.collection.findWhere({
			fileID : data.formData.fileID
		});

		if (file && data.result.error){
			file.set({
				status : "failed",
				error : data.result.error,
				jqXHR : undefined
			});
		}
		else if (data.result.error && Window.app && Window.app.errorCollection){
			Window.app.errorCollection.add({
				message : data.result.error.message,
				error: data.result.error
			});
		}
		else if (file){
			file.set({
				jqXHR : undefined,
				fileID: data.result.files[0].taskID,
				status : "uploaddone",
				uploadProgress : undefined
			});
		}

	},
	uploadFail : function FileUploadView_uploadFail(e,data){
		var file = this.collection.findWhere({
			name : data.files[0].name,
			size : data.files[0].size
		});
		
		if (file){
			file.set({
				jqXHR : undefined,
				status : "failed",
				error : data._response.errorThrown,
				uploadProgress : undefined
			});
		}
		else{
			this.options.generalErrors.add({ 
				error: {
					message: data._response.errorThrown
				} 
			});
		}
	},
	
	dragEnter: function FileUploadView_dragEnter(){
		this.$(".targetarea").addClass("dragover");
		if (this.stopShow) {
			clearTimeout(this.stopShow);
			this.stopShow = 0;
		}
	},
	dragOver: function FileUploadView_dragOver(){
		this.$(".targetarea").addClass("dragover");
		if (this.stopShow) {
			clearTimeout(this.stopShow);
			this.stopShow = 0;
		}
	},
	dragLeave : function FileUploadView_dragLeave(){
		var self = this;
		
		this.stopShow = setTimeout(function(){
			self.$(".targetarea").removeClass("dragover");
		},200);
	}
});

ErrorModel = Backbone.Model.extend();

ErrorCollection = Backbone.Collection.extend({
	model : ErrorModel
});

ErrorView = Backbone.View.extend({
	initialize : function ErrorView_initialize(options){
		this.template = Handlebars.compile(Backbone.$("#general-error-template").html());
		
		this.listenTo(this.model,"change",this.render,this);
	},
	events : {
		"click .remove" : "removeError",
		"click .icon-info" : "showInfo"
	},
	
	render : function Error_render(){
		this.$el.html(this.template(this.model.attributes));
	},
	
	removeFile : function ErrorView_removeFile(){
		// remove file from memory and DOM
		this.collection.remove(this.model);
		this.remove();
		delete this.model;
	},
	showInfo : function ErrorView_showInfo(){
		this.$(".info").toggle();
	},
});

ErrorCollectionView = Backbone.View.extend({
	initialize : function ErrorCollectionView_initialize(options){
		this.listenTo(this.collection,"add",this.addError,this);
	},
	
	addError : function ErrorCollectionView_addFile(error){
		var errorView = new ErrorView({
			model : error
		});
		
		this.$el.append(errorView.el);
		
		errorView.render();
	}
});

/* FORMATTING HELPERS */
function formatFileSize(bytes) {
	if (typeof bytes !== 'number') {
		return '';
	}
	
	if (bytes >= 1000000000) {
		return (bytes / 1000000000).toFixed(2) + ' GB';
	}
	
	if (bytes >= 1000000) {
		return (bytes / 1000000).toFixed(2) + ' MB';
	}
	
	return (bytes / 1000).toFixed(2) + ' KB';
};
Handlebars.registerHelper('filesize', safeStringify(formatFileSize));

function formatBitRate(bits) {
	if (typeof bits !== 'number') {
		return '';
	}
	
	if (bits >= 1000000000) {
		return (bits / 1000000000).toFixed(2) + ' Gbit/s';
	}
	
	if (bits >= 1000000) {
		return (bits / 1000000).toFixed(2) + ' Mbit/s';
	}
	
	if (bits >= 1000) {
		return (bits / 1000).toFixed(2) + ' kbit/s';
	}
	
	return bits.toFixed(2) + ' bit/s';
}
Handlebars.registerHelper('bitrate', safeStringify(formatBitRate));

function formatPercentage(value,total) {
	return Math.floor(value / total * 100).toString() + '%'
}
Handlebars.registerHelper('percentage', safeStringify(formatPercentage));

function syntaxHighlight(json) {
    if (typeof json != 'string') {
         json = JSON.stringify(json, undefined, 2);
    }
    json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
        var cls = 'number';
        if (/^"/.test(match)) {
            if (/:$/.test(match)) {
                cls = 'key';
            } else {
                cls = 'string';
            }
        } else if (/true|false/.test(match)) {
            cls = 'boolean';
        } else if (/null/.test(match)) {
            cls = 'null';
        }
        return '<span class="' + cls + '">' + match + '</span>';
    });
}
Handlebars.registerHelper('syntaxhighlight',safeStringify(syntaxHighlight));

function safeStringify(fn){
	return function(){
		return new Handlebars.SafeString(fn.apply(this,Array.prototype.slice.call(arguments)));
	};
};

/* JQUERY HELPERS */
jQuery.fn.block = function(){
	var thispos = this.offset(), blocker = "";
	
	if (this.data("blocker"))
		blocker = this.data("blocker");
	else
		blocker = jQuery("<div style='position:absolute;background-color:#333333;padding:10px 20px;border:1px solid #000000;'><img src='/webtop/images/loading-dark.gif' alt='Loading...' width='54' height='55'></div>");
	
	blocker.css({
		top : thispos.top,
		left : thispos.left,
		width : this.width(),
		height : this.height(),
		opacity : 0.5
	})
		.find("img").css({
			position : "absolute",
			top : thispos.top + (this.height()-55) / 2,
			left : thispos.left + (this.width()-54) / 2
		}).end()
		.appendTo(jQuery("body"));
	
	this.data("blocker",blocker);
	
	return blocker;
};
jQuery.fn.unblock = function(){
	if (this.data("blocker")){
		this.data("blocker").remove();
		this.data("blocker",null);
	}
	
	return this;
};

function serializeFormByPrefix(prefix,properties,includeprefix){
	var inputs = "", tmp = {}, data = {};
	
	properties = Array.prototype.slice.call(properties);
	if (properties.indexOf("ObjectID")===-1)
		properties.push("ObjectID");
	if (properties.indexOf("Typename")===-1)
		properties.push("Typename");
	includeprefix = includeprefix === true;
	
	// get the post values
	for (var i=0; i<properties.length; i++){
		inputs = jQuery('input[name='+prefix+properties[i]+']:not([type]),input[name='+prefix+properties[i]+'][type=text],input[name='+prefix+properties[i]+'][type=checkbox]:checked,input[name='+prefix+properties[i]+'][type=radio]:checked,input[name='+prefix+properties[i]+'][type=hidden],select[name='+prefix+properties[i]+'],textarea[name='+prefix+properties[i]+']');
		
		if (inputs.size()) {
			tmp[properties[i]] = [];
			
			inputs.each(function(){ 
				var self = jQuery(this);
				if ((!(self.is("[type=radio]") || self.is("[type=radio]")) || self.is(":checked")) && self.val()!=="") 
					tmp[properties[i]].push(self.val());
			});
			
			data[(includeprefix ? prefix : "")+properties[i]] = tmp[properties[i]].join();
		}
	}
	
	data["FarcryFormPrefixes"] = prefix;
	data["FarcryFormSubmitted"] = "";
	data["FarcryFormSubmitButton"] = "Submit";
	
	return data;
}