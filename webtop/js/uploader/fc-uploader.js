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
 *       // Optional drag-and-drop:
 *       dropZone:          ".fc-dropzone",           // selector / jQuery / DOM element to accept dropped files
 *       onDragEnter:       function(event){},        // visual feedback when files enter the zone
 *       onDragLeave:       function(event){},        // visual feedback when files leave or are dropped
 *       storage:           "local" | "s3"             // "s3" uploads direct-to-bucket via Uppy.AwsS3
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
 * Direct-to-S3 (storage === "s3"):
 *   Instead of XHRUpload, the wrapper uses Uppy.AwsS3 with shouldUseMultipart
 *   false (presigned POST only). The browser POSTs the file straight to the
 *   bucket; the FarCry endpoint is hit twice over fetch():
 *     - `&s3op=sign`     before upload — returns the presigned POST params
 *                        ({ method, url, fields, headers }) for getUploadParameters
 *     - `&s3op=finalize` after the object lands in S3 — records the path, runs
 *                        post-processing, and returns the SAME JSON shape the
 *                        local XHR path returns, so onComplete is unchanged.
 *   shouldUseMultipart is the extension point for resumable multipart uploads
 *   of large files in a later phase — the sign/finalize structure stays.
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
			// normalise "*.jpg" / ".jpg" / "jpg" -> ".jpg"; allow-all is an empty list, not "*"
			token = token.replace(/^\*\.?/, "").replace(/^\./, "");
			if (token) out.push("." + token.toLowerCase());
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

		var storage = opts.storage || "local";
		var isS3    = (storage === "s3");

		if (!window.Uppy || !window.Uppy.Uppy){
			throw new Error("$fc.uploader.create: window.Uppy.Uppy not loaded — check <skin:loadJS id=\"fc-uppy\" />");
		}
		if (isS3 && !window.Uppy.AwsS3){
			throw new Error("$fc.uploader.create: window.Uppy.AwsS3 not loaded — check <skin:loadJS id=\"fc-uppy\" />");
		}
		if (!isS3 && !window.Uppy.XHRUpload){
			throw new Error("$fc.uploader.create: window.Uppy.XHRUpload not loaded — check <skin:loadJS id=\"fc-uppy\" />");
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

		// Optional drag-drop zone. Resolve to a DOM element if provided.
		var dropZoneEl = null;
		if (opts.dropZone){
			var $dz = (typeof opts.dropZone === "string") ? jQuery(opts.dropZone) : jQuery(opts.dropZone);
			dropZoneEl = $dz.length ? $dz.get(0) : null;
		}
		var onDragEnter = (typeof opts.onDragEnter === "function") ? opts.onDragEnter : function(){};
		var onDragLeave = (typeof opts.onDragLeave === "function") ? opts.onDragLeave : function(){};

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

		// --- Direct-to-S3 transport ------------------------------------------
		// Remembers the server-resolved CDN value per file (an opaque token from
		// the sign step) so the finalize step can echo it back unchanged — the
		// server never has to reverse an S3 key into a value.
		var s3ValueByFileId = {};

		function withParam(url, key, value){
			return url + (url.indexOf("?") === -1 ? "?" : "&") + encodeURIComponent(key) + "=" + encodeURIComponent(value);
		}

		function postJSON(url, payload){
			return fetch(url, {
				method:      "POST",
				headers:     { "Content-Type": "application/json", "Accept": "application/json" },
				credentials: "same-origin",
				body:        JSON.stringify(payload)
			}).then(function(res){
				return res.text().then(function(text){
					var data;
					try { data = text ? JSON.parse(text) : {}; }
					catch (err){ throw new Error("Non-JSON response from server" + (bodySnippet(text) ? ": " + bodySnippet(text) : "")); }
					if (!res.ok) throw new Error((data && data.error) || ("Request failed (" + res.status + ")"));
					if (data && data.error) throw new Error(data.error);
					return data;
				});
			});
		}

		function s3Meta(file){
			var payload = {};
			// Per-file meta set via Uppy setFileMeta (e.g. the bulk uploader's
			// uploaderID / fileID / default-property values) rides along to the
			// server so sign + finalize carry the same context as a local post.
			if (file && file.meta){
				for (var m in file.meta){ if (Object.prototype.hasOwnProperty.call(file.meta, m)) payload[m] = file.meta[m]; }
			}
			payload.filename = file.name;
			payload.type     = file.type;
			payload.size     = file.size;
			var extra;
			try { extra = extraFormData() || {}; } catch (e){ extra = {}; }
			for (var k in extra){ if (Object.prototype.hasOwnProperty.call(extra, k)) payload[k] = extra[k]; }
			return payload;
		}

		function fetchSignParams(file){
			return postJSON(withParam(opts.endpoint, "s3op", "sign"), s3Meta(file)).then(function(data){
				s3ValueByFileId[file.id] = data.value || "";
				return data;
			});
		}

		function finalizeS3(file){
			var payload = s3Meta(file);
			payload.value = s3ValueByFileId[file.id] || "";
			return postJSON(withParam(opts.endpoint, "s3op", "finalize"), payload);
		}

		// Override for @uppy/aws-s3's uploadPartBytes (the presigned-POST path).
		//
		// Stock AwsS3 reads the uploaded object's ETag from a response header and
		// treats a missing one as fatal: it logs and returns WITHOUT resolving or
		// rejecting, so the upload stalls — no upload-success, no finalize. The
		// header is only visible if the bucket exposes it via CORS, and we don't
		// need it: presigned POST returns its result in the response BODY and our
		// server "finalize" is the source of truth. So for POST we proceed even
		// when the ETag header is absent — no bucket CORS change required.
		//
		// Method-aware: PUT (multipart parts) keeps the stock ETag requirement, so
		// switching shouldUseMultipart on later stays correct.
		//
		// This is a faithful copy of @uppy/aws-s3@5.1.0's static uploadPartBytes
		// (the version inside the bundled uppy v5.2.4) with two deliberate edits:
		//   1. the "bail on null ETag" guard is skipped for POST (the fix above);
		//   2. the POST "Could not read the Location header" console.error is
		//      dropped — with success_action_status=201 the Location is always in
		//      the body, never a header, so stock logs it spuriously every upload.
		// Upgrader note: if you bump the bundle, re-diff against that version's
		// uploadPartBytes. If a future release stops treating a missing POST ETag
		// as fatal, this override can be removed.
		function s3UploadPartBytes(args){
			var signature  = args.signature || {};
			var url        = signature.url;
			var expires    = signature.expires;
			var headers    = signature.headers;
			var method     = (signature.method || "PUT").toUpperCase();   // stock default is PUT; relax only for explicit POST
			var body       = args.body;
			var size       = args.size != null ? args.size : (body && body.size);
			var onProgress = args.onProgress;
			var onComplete = args.onComplete;
			var signal     = args.signal;

			if (signal && signal.aborted) { return Promise.reject(new Error("Upload aborted")); }
			if (url == null) { return Promise.reject(new Error("Cannot upload to an undefined URL")); }

			return new Promise(function(resolve, reject){
				var xhr = new XMLHttpRequest();
				xhr.open(method, url, true);
				if (headers){
					Object.keys(headers).forEach(function(k){ xhr.setRequestHeader(k, headers[k]); });
				}
				xhr.responseType = "text";
				if (typeof expires === "number") xhr.timeout = expires * 1000;

				function onAbort(){ xhr.abort(); }
				function cleanup(){ if (signal) signal.removeEventListener("abort", onAbort); }
				if (signal){ signal.addEventListener("abort", onAbort); }

				xhr.upload.addEventListener("progress", function(ev){ if (onProgress) onProgress(ev); });
				xhr.addEventListener("abort", function(){ cleanup(); reject(new Error("Upload aborted")); });
				xhr.addEventListener("timeout", function(){ cleanup(); var err = new Error("Request has expired"); err.source = { status: 403 }; reject(err); });
				xhr.addEventListener("error", function(ev){ cleanup(); var err = new Error("Unknown error"); err.source = ev.target; reject(err); });
				xhr.addEventListener("load", function(){
					cleanup();
					if (xhr.status === 403 && xhr.responseText && xhr.responseText.indexOf("<Message>Request has expired</Message>") !== -1){
						var expErr = new Error("Request has expired"); expErr.source = xhr; reject(expErr); return;
					}
					if (xhr.status < 200 || xhr.status >= 300){
						var httpErr = new Error("Non 2xx"); httpErr.source = xhr; reject(httpErr); return;
					}
					if (onProgress) onProgress({ loaded: size, lengthComputable: true });

					// Parse all response headers into a lowercase-keyed map, exactly
					// as stock does, so the resolved object carries them through.
					var headersMap = {};
					var raw = xhr.getAllResponseHeaders().trim().split(/[\r\n]+/);
					for (var i = 0; i < raw.length; i++){
						var parts = raw[i].split(": ");
						var name  = parts.shift();
						headersMap[name] = parts.join(": ");
					}
					var etag = headersMap.etag;

					// PUT (multipart part) keeps the stock contract: ETag is required.
					// POST proceeds without it — see comment block above.
					if (method !== "POST" && etag == null){
						console.error("@uppy/aws-s3: Could not read the ETag header (required for multipart). Expose ETag via the bucket's CORS Access-Control-Expose-Headers.");
						return;
					}

					if (onComplete) onComplete(etag);
					resolve(Object.assign({}, headersMap, { ETag: etag }));
				});

				xhr.send(body);
			});
		}
		// ---------------------------------------------------------------------

		if (isS3){
			uppy.use(window.Uppy.AwsS3, {
				shouldUseMultipart:  false,               // presigned POST only; extension point for multipart later
				getUploadParameters: fetchSignParams,
				uploadPartBytes:     s3UploadPartBytes    // see comment above: 2xx = success, no ETag CORS exposure needed for POST
			});
		} else {
			uppy.use(window.Uppy.XHRUpload, xhrOpts);
		}

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

		// Drop a finished file from Uppy's internal state once we're done with it.
		// Uppy keeps completed AND errored files in state; with maxNumberOfFiles
		// set (e.g. 1 for the file/image formtools) the lingering entry blocks the
		// next add — re-picking the same file trips duplicate detection (which
		// classifyRestriction mislabels "size") and picking another trips the count
		// limit. Removing it returns a transient uploader to an empty slot so
		// Replace / re-upload work. Deferred so we don't mutate state mid-dispatch.
		function releaseFile(file){
			if (!file) return;
			setTimeout(function(){ try { uppy.removeFile(file.id); } catch (e){} }, 0);
		}

		uppy.on("upload-success", function(file, response){
			if (isS3){
				// The object is now in S3; ask the server to record it and run
				// post-processing, then hand the SAME JSON shape to onComplete.
				finalizeS3(file).then(function(body){
					try { onComplete(file, body || {}); } catch (e){}
					releaseFile(file);
				}).catch(function(err){
					try { onError(file, { type: "server", message: (err && err.message) || "Finalize failed" }); } catch (e){}
					releaseFile(file);
				});
				return;
			}
			var body = (response && response.body !== undefined) ? response.body : response;
			try { onComplete(file, body || {}); } catch (e){}
			releaseFile(file);
		});

		uppy.on("upload-error", function(file, error, response){
			try { onError(file, categorizeError(file, error, response)); } catch (e){}
			releaseFile(file);
		});

		uppy.on("restriction-failed", function(file, error){
			var msg = (error && error.message) || "Restriction violated";
			try { onError(file, classifyRestriction(msg)); } catch (e){}
		});

		/**
		 * Enqueue a list of File objects into Uppy. Used by both the file-input
		 * change handler and (optionally) the drag-drop drop handler.
		 *
		 * Uppy's addFile() throws synchronously on restriction failures; the
		 * restriction-failed event has already routed the error through onError,
		 * so we silently catch here and continue the loop for subsequent files.
		 */
		function addFiles(fileList, source){
			if (!fileList || !fileList.length) return;
			for (var i = 0; i < fileList.length; i++){
				var f = fileList[i];
				try {
					uppy.addFile({
						source: source || "$fc.uploader",
						name:   f.name,
						type:   f.type,
						data:   f
					});
				} catch (err){
					// see comment above
				}
			}
		}

		function onInputChange(e){
			addFiles(e.target && e.target.files, "$fc.uploader");
			try { e.target.value = ""; } catch (resetErr){}
		}

		inputEl.addEventListener("change", onInputChange, false);

		// Drag-drop wiring (only if dropZone option was provided)
		function onDragEnterHandler(e){ e.preventDefault(); e.stopPropagation(); try { onDragEnter(e); } catch (err){} }
		function onDragOverHandler(e){  e.preventDefault(); e.stopPropagation(); try { onDragEnter(e); } catch (err){} }
		function onDragLeaveHandler(e){ e.preventDefault(); e.stopPropagation(); try { onDragLeave(e); } catch (err){} }
		function onDropHandler(e){
			e.preventDefault();
			e.stopPropagation();
			var files = e.dataTransfer && e.dataTransfer.files;
			addFiles(files, "$fc.uploader.drop");
			try { onDragLeave(e); } catch (err){}
		}

		// Paste-from-clipboard. Gated on the dropzone being focused so that
		// multiple uploaders on the same page don't all grab the same paste —
		// only the one the user has clicked/tabbed into responds. The dropzone
		// must be focusable (tabindex) in the formtool markup for this to fire.
		function dropZoneFocused(){
			var active = document.activeElement;
			return active && (active === dropZoneEl || dropZoneEl.contains(active));
		}
		function onPasteHandler(e){
			if (!dropZoneFocused()) return;
			var data = e.clipboardData || window.clipboardData;
			var files = data && data.files;
			if (files && files.length){
				e.preventDefault();
				addFiles(files, "$fc.uploader.paste");
			}
		}
		if (dropZoneEl){
			dropZoneEl.addEventListener("dragenter", onDragEnterHandler, false);
			dropZoneEl.addEventListener("dragover",  onDragOverHandler,  false);
			dropZoneEl.addEventListener("dragleave", onDragLeaveHandler, false);
			dropZoneEl.addEventListener("drop",      onDropHandler,      false);
			// Paste listens on document (clipboard events don't reliably target a
			// non-editable element) but is gated to fire only when the dropzone holds focus.
			document.addEventListener("paste", onPasteHandler, false);
		}

		return {
			cancel: function(fileId){
				try { uppy.removeFile(fileId); } catch (e){}
			},
			cancelAll: function(){
				try { uppy.cancelAll(); } catch (e){}
			},
			destroy: function(){
				try { inputEl.removeEventListener("change", onInputChange, false); } catch (e){}
				if (dropZoneEl){
					try { dropZoneEl.removeEventListener("dragenter", onDragEnterHandler, false); } catch (e){}
					try { dropZoneEl.removeEventListener("dragover",  onDragOverHandler,  false); } catch (e){}
					try { dropZoneEl.removeEventListener("dragleave", onDragLeaveHandler, false); } catch (e){}
					try { dropZoneEl.removeEventListener("drop",      onDropHandler,      false); } catch (e){}
					try { document.removeEventListener("paste",       onPasteHandler,     false); } catch (e){}
				}
				try {
					if (typeof uppy.destroy === "function") uppy.destroy();
					else if (typeof uppy.close === "function") uppy.close();
				} catch (e){}
			},
			_uppy: uppy
		};
	};

	/**
	 * $fc.uploader.confirm — a small, framework-agnostic confirm dialog.
	 *
	 * Deliberately NOT built on Bootstrap (or any framework) so the planned
	 * Bootstrap 5 upgrade has nothing here to migrate. Styled by the
	 * .fc-uploader-confirm-* classes in webtop/css/uploader.css.
	 *
	 *   $fc.uploader.confirm({
	 *       title:   "Delete this file?",
	 *       message: "This cannot be undone.",
	 *       buttons: [
	 *           { label: "Delete", value: "delete", style: "danger" },
	 *           { label: "Cancel", value: "cancel", style: "cancel", isCancel: true }
	 *       ],
	 *       onSelect: function(value){ ... }   // value of the clicked button; "cancel" on Escape/overlay
	 *   });
	 *
	 * Buttons default to a Delete (danger) / Cancel pair when omitted. The
	 * image formtool passes a three-button set for the related-images case.
	 * Focus is trapped while open and returned to the previously-focused
	 * element on close (accessibility baseline in the UI plan).
	 */
	$fc.uploader.confirm = function fcUploaderConfirm(opts){
		opts = opts || {};

		var buttons = (opts.buttons && opts.buttons.length) ? opts.buttons : [
			{ label: "Delete", value: "delete", style: "danger" },
			{ label: "Cancel", value: "cancel", style: "cancel", isCancel: true }
		];
		var onSelect      = (typeof opts.onSelect === "function") ? opts.onSelect : function(){};
		var previousFocus = document.activeElement;
		var closed        = false;

		var overlay = document.createElement("div");
		overlay.className = "fc-uploader-confirm-overlay";
		overlay.setAttribute("role", "dialog");
		overlay.setAttribute("aria-modal", "true");

		var dialog = document.createElement("div");
		dialog.className = "fc-uploader-confirm-dialog";
		overlay.appendChild(dialog);

		if (opts.title){
			var titleEl = document.createElement("h3");
			titleEl.className = "fc-uploader-confirm-title";
			titleEl.textContent = opts.title;
			dialog.appendChild(titleEl);
		}
		if (opts.message){
			var msgEl = document.createElement("div");
			msgEl.className = "fc-uploader-confirm-message";
			msgEl.textContent = opts.message;
			dialog.appendChild(msgEl);
		}

		var btnBar = document.createElement("div");
		btnBar.className = "fc-uploader-confirm-buttons";
		// Three-or-more buttons (e.g. the related-images delete) carry long labels
		// that wrap awkwardly side-by-side in the narrow dialog; stack them vertically
		// so each gets a full row. Two-button confirms stay on one horizontal row.
		if (buttons.length >= 3) btnBar.className += " fc-uploader-confirm-buttons--stacked";
		dialog.appendChild(btnBar);

		var cancelValue = null;
		var btnEls = [];
		for (var i = 0; i < buttons.length; i++){
			(function(btn){
				var b = document.createElement("button");
				b.type = "button";
				b.className = "fc-uploader-confirm-btn"
				            + (btn.style ? " fc-uploader-confirm-btn--" + btn.style : "");
				b.textContent = btn.label;
				if (btn.isCancel) cancelValue = btn.value;
				b.addEventListener("click", function(){ close(btn.value); });
				btnBar.appendChild(b);
				btnEls.push(b);
			})(buttons[i]);
		}
		// Fall back to the last button as the cancel target for Escape/overlay.
		if (cancelValue === null && buttons.length) cancelValue = buttons[buttons.length - 1].value;

		function onKeyDown(e){
			if (e.key === "Escape" || e.keyCode === 27){
				e.preventDefault();
				close(cancelValue);
				return;
			}
			if (e.key === "Tab" || e.keyCode === 9){
				// Trap focus within the dialog's buttons.
				if (!btnEls.length) return;
				var first = btnEls[0];
				var last  = btnEls[btnEls.length - 1];
				if (e.shiftKey && document.activeElement === first){
					e.preventDefault();
					last.focus();
				} else if (!e.shiftKey && document.activeElement === last){
					e.preventDefault();
					first.focus();
				}
			}
		}

		function onOverlayClick(e){
			if (e.target === overlay) close(cancelValue);
		}

		function close(value){
			if (closed) return;
			closed = true;
			document.removeEventListener("keydown", onKeyDown, true);
			overlay.removeEventListener("click", onOverlayClick, false);
			if (overlay.parentNode) overlay.parentNode.removeChild(overlay);
			try { if (previousFocus && previousFocus.focus) previousFocus.focus(); } catch (e){}
			try { onSelect(value); } catch (e){}
		}

		document.addEventListener("keydown", onKeyDown, true);
		overlay.addEventListener("click", onOverlayClick, false);
		document.body.appendChild(overlay);

		// Focus the first action button so keyboard users land inside the dialog.
		if (btnEls.length) { try { btnEls[0].focus(); } catch (e){} }

		return { close: function(){ close(cancelValue); } };
	};
})($j);
