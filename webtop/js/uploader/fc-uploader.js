/**
 * $fc.uploader — FarCry's transport-only wrapper around Uppy Core + XHRUpload.
 *
 * Bridges FarCry formtools (file, image, arrayupload) onto Uppy without
 * using any of Uppy's UI plugins. The formtools' existing markup keeps
 * rendering the upload UI; this wrapper just moves bytes and forwards events.
 *
 * Public API:
 *
 *   var uploader = $fc.uploader.create({
 *       fileInput:         "#myfieldNEW",            // selector or DOM/jQuery element
 *       fieldName:         "myfieldNEW",             // multipart POST field name
 *       endpoint:          "https://.../upload",     // absolute URL from getAjaxURL(...)
 *       extraFormData:     function(){ return {}; }, // dynamic POST fields (uploadify scriptData)
 *       allowedFileTypes:  "*.jpg;*.png" | ["jpg","png"] | "jpg,png",
 *       maxFileSize:       5242880,                  // bytes; 0 / falsy = no limit
 *       maxNumberOfFiles:  1,                        // null = unlimited
 *       simultaneousUploads: 1,                      // XHRUpload concurrency limit
 *       autoProceed:       true,
 *       onSelect:          function(file){},
 *       onProgress:        function(file, percent){},
 *       onComplete:        function(file, parsedJSON){},
 *       onError:           function(file, error){},  // error = { type, message, status? }
 *       storage:           "local"                   // accepted, ignored in Phase 1
 *   });
 *
 *   uploader.cancel(fileId);
 *   uploader.cancelAll();
 *   uploader.destroy();
 *
 * Error categorisation for onError:
 *   { type: "size",    message }     // file exceeds maxFileSize, or restriction
 *   { type: "type",    message }     // file extension not in allowedFileTypes
 *   { type: "count",   message }     // exceeded maxNumberOfFiles
 *   { type: "http",    message, status }   // server returned non-2xx
 *   { type: "network", message }     // network failure
 *   { type: "server",  message }     // anything else
 *
 * Forward-compatibility (Phase 2):
 *   The `storage` option is accepted but currently ignored. A future revision
 *   will switch to `@uppy/aws-s3-multipart` when storage === "s3", without any
 *   change to the calling formtools.
 */
(function(jQuery){
	"use strict";

	window.$fc = window.$fc || {};
	$fc.uploader = $fc.uploader || {};

	function normalizeAllowedTypes(input){
		if (!input) return null;
		var raw = Array.isArray(input) ? input : String(input).split(/[,;]/);
		var out = [];
		for (var i = 0; i < raw.length; i++){
			var token = String(raw[i] || "").trim();
			if (!token) continue;
			// strip leading "*.", "*", or "."
			token = token.replace(/^\*\.?/, "").replace(/^\./, "");
			if (token && token !== "*") out.push("." + token.toLowerCase());
		}
		return out.length ? out : null;
	}

	/**
	 * Pull a short, readable snippet out of a response body. Strips script/style
	 * blocks, collapses tags to spaces, normalises whitespace, truncates.
	 * Useful when the server returns an HTML error page (Lucee/CF debug screen,
	 * Nginx 502 page, etc.) and we want to show something meaningful instead of
	 * a generic "upload failed".
	 */
	function bodySnippet(text){
		if (!text || typeof text !== "string") return "";
		return text.replace(/<style[\s\S]*?<\/style>/gi, " ")
		           .replace(/<script[\s\S]*?<\/script>/gi, " ")
		           .replace(/<[^>]+>/g, " ")
		           .replace(/&nbsp;/gi, " ")
		           .replace(/\s+/g, " ")
		           .trim()
		           .slice(0, 240);
	}

	/**
	 * Extract responseText from an Uppy upload-error payload. Uppy v5's XHRUpload
	 * stores the underlying XHR on the error/response args; we look in both.
	 */
	function extractResponseText(error, response){
		if (response && typeof response.responseText === "string") return response.responseText;
		if (error && error.request && typeof error.request.responseText === "string") return error.request.responseText;
		return "";
	}

	function categorizeError(file, error, response){
		var msg = (error && error.message) || (typeof error === "string" ? error : "Upload failed");

		if (error && error.isRestriction) {
			return classifyRestriction(msg);
		}
		if (error && error.isNetworkError) {
			return { type: "network", message: msg };
		}

		var status = (response && typeof response.status === "number") ? response.status
		           : (error && error.request && typeof error.request.status === "number") ? error.request.status
		           : null;

		// Pull a readable snippet from the response body, if there is one,
		// and append it to the message — keeps server error info visible.
		var snippet = bodySnippet(extractResponseText(error, response));
		var fullMsg = snippet ? (msg + ": " + snippet) : msg;

		if (status !== null && status >= 400) {
			return { type: "http", message: fullMsg, status: status };
		}
		if (status !== null) {
			return { type: "server", message: fullMsg, status: status };
		}
		return { type: "server", message: fullMsg };
	}

	function classifyRestriction(msg){
		var s = String(msg || "").toLowerCase();
		if (s.indexOf("size") !== -1 || s.indexOf("exceeds") !== -1 || s.indexOf("larger") !== -1 || s.indexOf("smaller") !== -1){
			return { type: "size", message: msg };
		}
		if (s.indexOf("type") !== -1 || s.indexOf("only upload:") !== -1 || s.indexOf("allowed") !== -1){
			return { type: "type", message: msg };
		}
		if (s.indexOf("number") !== -1 || s.indexOf("only upload ") !== -1){
			return { type: "count", message: msg };
		}
		return { type: "size", message: msg };
	}

	$fc.uploader.create = function fcUploaderCreate(opts){
		opts = opts || {};

		if (!window.Uppy || !window.Uppy.Uppy || !window.Uppy.XHRUpload){
			throw new Error("$fc.uploader.create: window.Uppy.Uppy / window.Uppy.XHRUpload not loaded — check <skin:loadJS id=\"fc-uppy\" />");
		}

		if (!opts.endpoint){
			throw new Error("$fc.uploader.create: 'endpoint' option is required");
		}

		var $input  = (typeof opts.fileInput === "string") ? jQuery(opts.fileInput) : jQuery(opts.fileInput);
		var inputEl = $input.length ? $input.get(0) : null;
		if (!inputEl){
			throw new Error("$fc.uploader.create: 'fileInput' element not found: " + opts.fileInput);
		}

		var fieldName        = opts.fieldName || $input.attr("name") || "files[]";
		var extraFormData    = (typeof opts.extraFormData === "function") ? opts.extraFormData : function(){ return {}; };
		var allowedFileTypes = normalizeAllowedTypes(opts.allowedFileTypes);
		var maxFileSize      = (opts.maxFileSize && Number(opts.maxFileSize) > 0) ? Number(opts.maxFileSize) : null;
		var maxNumberOfFiles = (typeof opts.maxNumberOfFiles === "number" && opts.maxNumberOfFiles > 0) ? opts.maxNumberOfFiles : null;
		var simultaneous     = (typeof opts.simultaneousUploads === "number" && opts.simultaneousUploads > 0) ? opts.simultaneousUploads : null;
		var autoProceed      = (typeof opts.autoProceed === "boolean") ? opts.autoProceed : true;

		var onSelect   = opts.onSelect   || function(){};
		var onProgress = opts.onProgress || function(){};
		var onComplete = opts.onComplete || function(){};
		var onError    = opts.onError    || function(){};

		var restrictions = {};
		if (maxFileSize !== null)             restrictions.maxFileSize       = maxFileSize;
		if (allowedFileTypes)                  restrictions.allowedFileTypes  = allowedFileTypes;
		if (maxNumberOfFiles !== null)         restrictions.maxNumberOfFiles  = maxNumberOfFiles;

		var uppy = new window.Uppy.Uppy({
			autoProceed: autoProceed,
			restrictions: restrictions,
			debug: false
		});

		var xhrOpts = {
			endpoint:     opts.endpoint,
			fieldName:    fieldName,
			formData:     true,
			method:       "POST",
			// Uppy v5 signature: receives the XMLHttpRequest (not response text).
			// We override the default so that a 2xx response with a non-JSON body
			// (typical when a CFML error page is returned with a 200 status, or
			// when an upstream proxy returns plaintext) surfaces a useful message
			// via results.error instead of throwing a generic Uppy error.
			getResponseData: function(xhr){
				var text = (xhr && typeof xhr.responseText === "string") ? xhr.responseText : "";
				if (!text) return { error: "Empty response from server" };
				try { return JSON.parse(text); }
				catch (err){
					var snippet = bodySnippet(text);
					return { error: "Non-JSON response from server" + (snippet ? ": " + snippet : "") };
				}
			}
		};
		if (simultaneous !== null) xhrOpts.limit = simultaneous;

		uppy.use(window.Uppy.XHRUpload, xhrOpts);

		// Refresh dynamic POST fields (uploadify scriptData) just before each upload batch.
		uppy.on("upload", function(){
			var meta;
			try { meta = extraFormData() || {}; }
			catch (e){ meta = {}; }
			try { uppy.setMeta(meta); } catch (e){}
		});

		uppy.on("file-added", function(file){
			try { onSelect(file); } catch (e){}
		});

		uppy.on("upload-progress", function(file, progress){
			var uploaded = (progress && progress.bytesUploaded) || 0;
			var total    = (progress && progress.bytesTotal)    || (file && file.size) || 0;
			var percent  = (total > 0) ? Math.round((uploaded / total) * 100) : 0;
			if (percent > 100) percent = 100;
			try { onProgress(file, percent); } catch (e){}
		});

		uppy.on("upload-success", function(file, response){
			var body = (response && response.body !== undefined) ? response.body : response;
			try { onComplete(file, body || {}); } catch (e){}
		});

		uppy.on("upload-error", function(file, error, response){
			try { onError(file, categorizeError(file, error, response)); } catch (e){}
		});

		uppy.on("restriction-failed", function(file, error){
			var msg = (error && error.message) || "Restriction violated";
			try { onError(file, classifyRestriction(msg)); } catch (e){}
		});

		function onInputChange(e){
			var files = e.target && e.target.files;
			if (!files || !files.length) return;
			for (var i = 0; i < files.length; i++){
				var f = files[i];
				try {
					uppy.addFile({
						source: "$fc.uploader",
						name:   f.name,
						type:   f.type,
						data:   f
					});
				} catch (err){
					// Uppy throws synchronously on restriction failure; the
					// restriction-failed event has already routed the error
					// through onError. Continue the loop for subsequent files.
				}
			}
			try { e.target.value = ""; } catch (resetErr){}
		}

		inputEl.addEventListener("change", onInputChange, false);

		return {
			cancel: function(fileId){
				try { uppy.removeFile(fileId); } catch (e){}
			},
			cancelAll: function(){
				try { uppy.cancelAll(); } catch (e){}
			},
			destroy: function(){
				try { inputEl.removeEventListener("change", onInputChange, false); } catch (e){}
				try {
					if (typeof uppy.destroy === "function") uppy.destroy();
					else if (typeof uppy.close === "function") uppy.close();
				} catch (e){}
			},
			_uppy: uppy
		};
	};
})($j);
