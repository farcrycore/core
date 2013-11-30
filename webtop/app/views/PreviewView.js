PreviewView = Backbone.View.extend({

	options: {
		attachTo: null,
		previewURL: null,
		currentDevice: "desktop",

		bUseTabletWebskins: false,
		bUseMobileWebskins: false,
		deviceWidth: {
			desktop: 1050,
			tablet: 768,
			mobile: 480,
			// optional, current device width is looked up on init
			current: 1050
		}

	},

	initialize: function PreviewView_initialize(options){
		this.template = Handlebars.compile(Backbone.$("#preview-dialog").html());
		// look up the width of the current device
		this.options.deviceWidth.current = this.options.deviceWidth[this.options.currentDevice] || this.options.deviceWidth.current;

	},

	events: {
		"click .modal-header .close, .btn-cancel": "close",
		"click .modal-header .btn-device": "clickDevice"

	},

	clickDevice: function PreviewView_clickDevice(evt){
		var button = Backbone.$(evt.currentTarget);
		var device = button.data("device");
		var deviceWidth = button.data("devicewidth");

		this.previewDevice(device, deviceWidth);

		evt.preventDefault();
		return false;
	},

	render: function PreviewView_render(){
		var self = this;

		this.$el.html(this.template(this.options));
		Backbone.$("body").append(this.$el);   

		// bind preview buttons on the element being attached to
		Backbone.$(this.options.attachTo).on("click", ".fc-btn-preview", function(evt){
			var previewURL = Backbone.$(this).attr("href");
			self.showPreview(previewURL);
			return false;
		});

		// resize the preview when the browser changes
		Backbone.$(window).resize(function resizePreview() {
			// update the max width
			var w = Backbone.$(document.body).width();
			self.previewMaxWidth(w);
			// update the iframe height
			var h = Backbone.$("#preview").height();
			Backbone.$("#preview iframe").height(h - 47);

			// keep the preview off screen
			if (!Backbone.$("#preview").hasClass("visible")) {
				Backbone.$("#preview").css("right", -w);
			}
		});


	},

	showPreview: function PreviewView_showPreview(previewURL, bShow) {
		previewURL = previewURL || null;
		bShow = bShow || null;

		var self = this;

		var w = Backbone.$("#preview").width();
		var maxWidth = Backbone.$("body").width();
		// update the iframe height
		var h = Backbone.$("#preview").height();
		var $iframe = Backbone.$("#preview iframe").height(h - 47);

		if (w > maxWidth) {
			w = maxWidth;
		}

		self.previewMaxWidth(maxWidth);

		if (Backbone.$("#preview").hasClass("visible") || bShow === false || previewURL == null) {
			if (previewURL != null && $iframe.attr("src") != previewURL) {
				$iframe.attr("src", previewURL);
				self.previewLoading();
			}
			else {
				Backbone.$("#preview").removeClass("visible").animate({ right: w * -1 }, 250);
			}
		}
		else {
			if (previewURL != null && $iframe.attr("src") != previewURL) {
				$iframe.attr("src", previewURL);
				self.previewLoading();
			}
			Backbone.$("#preview").addClass("visible").animate({ right: 0 }, 250);
		}

	},

	previewDevice: function PreviewView_previewDevice(targetDeviceType, width) {

		var self = this;

		// desktop is false to avoid reloads when device specific webskins are not used
		var reloadWebskin = {
			"desktop": false,
			"tablet": this.options.bUseTabletWebskins,
			"mobile": this.options.bUseMobileWebskins
		};

		// get the previous device type
		var previousDeviceType = $fc.getDeviceType();
		// set the new target device type
		$fc.setDeviceTypeCookie(targetDeviceType);
		// set the new device width
		self.previewWidth(width);

		// reload if different webskins will be used
			// previous == target (do nothing)
			// desktop -> tablet (only if target enabled)
			// desktop -> mobile (only if target enabled)
			// tablet -> desktop (only if previous enabled)
			// mobile -> desktop (only if previous enabled)
			// tablet -> mobile (if either enabled)
			// mobile -> tablet (if either enabled)
		if (previousDeviceType == targetDeviceType) {
			// no reload
		}
		else if (previousDeviceType == "desktop" && reloadWebskin[targetDeviceType]) {
			self.previewReload();
		}
		else if (targetDeviceType == "desktop" && reloadWebskin[previousDeviceType]) {
			self.previewReload();
		}
		else if (reloadWebskin[previousDeviceType] || reloadWebskin[targetDeviceType]) {
			self.previewReload();
		}
	},

	previewReload: function PreviewView_previewReload() {
		var iframe = document.getElementById("previewiframe");
		iframe.contentWindow.location.reload();
		this.previewLoading();
	},

	previewLoading: function PreviewView_previewLoading() {
		var iframe = document.getElementById("previewiframe");
		Backbone.$("#previewicon").attr("class", "fa fa-refresh fa-spin fa-fw");
		iframe.onload = (function() {
			Backbone.$("#previewicon").attr("class", "fa fa-eye fa-fw");
		});
	},

	previewWidth: function PreviewView_previewWidth(w) {
		Backbone.$("#preview").animate({ width: w }, 200);
	},

	previewMaxWidth: function PreviewView_previewMaxWidth(w) {
		Backbone.$("#preview").css("max-width", w);
	},


	close: function close(evt){
		this.showPreview();
	}

});
