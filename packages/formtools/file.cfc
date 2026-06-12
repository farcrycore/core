<!--- 	
	@@examples:

	<p>Basic</p>
	<code>
		<cfproperty 
			name="someFile" type="string" default="" hint="The file to process" 
			ftSeq="1" ftFieldset="General" ftLabel="File" 
			ftType="file" ftDestination="/someDirectory" />
	</code>

	<p>Maximum file upload of 1mb</p>
	<code>
		<cfproperty 
			name="someFile" type="string" default="" hint="The file to process" 
			ftSeq="1" ftFieldset="General" ftLabel="File" 
			ftType="file" ftDestination="/someDirectory" ftMaxSize="1048576" />
	</code>

	<p>Flash upload</p>
	<code>
		<cfproperty 
			name="someFile" type="string" default="" hint="The file to process" 
			ftSeq="2" ftFieldset="General" ftLabel="File" 
			ftType="file" ftDestination="/someDirectory" ftRenderType="flash" />
	</code>

	<p>Secure file upload</p>
	<code>
		<cfproperty 
			name="someFile" type="string" default="" hint="The file to process" 
			ftSeq="4" ftFieldset="General" ftLabel="File" 
			ftType="file" ftDestination="/someDirectory" ftSecure="true" />
	</code>

	<p>PDF only (HTML)</p>
	<code>
		<cfproperty 
			name="someFile" type="string" default="" hint="The file to process" 
			ftSeq="5" ftFieldset="General" ftLabel="File" 
			ftType="file" ftDestination="/someDirectory" ftAllowedFileExtensions="*.pdf" />
	</code>


 --->

<cfcomponent name="File" displayname="file" Extends="field" hint="Field component to liase with all File types" bDocument="true"> 

	<!--- edit handler options --->
	<cfproperty name="ftStyle" default="" hint="Custom inline styles" />
	<cfproperty name="ftRenderType" default="html" hint="This formtool offers a number of ways to render the input. (html, flash, jquery)" />
	<cfproperty name="ftAllowedFileExtensions" default="pdf,doc,ppt,xls,docx,pptx,xlsx,jpg,jpeg,png,gif,zip,rar,flv,swf,mpg,mpe,mpeg,m1s,mpa,mp2,m2a,mp2v,m2v,m2s,mov,qt,asf,asx,wmv,wma,wmx,rm,ra,ram,rmvb,mp3,mp4,3gp,ogm,mkv,avi" hint="Used when ftRenderType is set to HTML, extentions allowed to be uploaded." />
	<cfproperty name="ftFileDescription" default="File Types" hint="Used when ftRenderType is set to HTML, text display above upload control." />
	<cfproperty name="ftMaxSize" default="0" hint="Maximum filesize upload in bytes." />
	<cfproperty name="ftOnComplete" default="" hint="Used when ftRenderType is set to HTML, javascript to execute after file upload." />
					
	<!--- jquery edit handler options --->
	<cfproperty name="ftStartMessage" default="Upload file here." hint="Used when ftRenderType is set to jQuery. Message to display at start of upload." />
	<cfproperty name="ftErrorSizeMessage" default="Maximum filesize is #chr(35)#arguments.stMetadata.ftMaxSize#chr(35)# kb" hint="Used when ftRenderType is set to jQuery. Error to display when max filesize error flagged." />
	<cfproperty name="ftCompleteMessage" default="File upload complete" hint="Used when ftRenderType is set to jQuery. Message to display at end of upload." />
	<cfproperty name="ftAfterUploadJSScript" default="" hint="Used when ftRenderType is set to jQuery. Javascript to execute after upload compeltes. " />

	<!--- validate options --->
	<cfproperty name="ftSecure" default="false" hint="Store files securely outside of public webspace." />
	<cfproperty name="ftLocation" default="" hint="Explicit CDN location to store the file in (e.g. 'publicfiles', 'privatefiles', 'temp'). When set it wins over ftSecure and the status/permission rules, pinning the file to this location." />
	<cfproperty name="ftDestination" default="" hint="Destination of file store relative of secure/public locations." />

	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
	<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" >
	<cfimport taglib="/farcry/core/tags/grid/" prefix="grid" >
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.file" output="false" hint="Returns a copy of this initialised object">
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="inputClass" required="false" type="string" default="" hint="This is the class value that will be applied to the input field.">

		<cfset var html = "" />
		<cfset var i = 0 />
		<cfset var uploadLocation = "" />
		<cfset var storageType = "local" />
		<cfset var existingFilename = "" />
		<cfset var existingBytes = 0 />
		<cfset var existingLoc = "" />
		<cfset var allowedExtsDisplay = "" />
		<cfset var maxSizeText = "" />
		<cfset var downloadURL = "" />

		<cfparam name="arguments.stMetadata.ftstyle" default="" />
		<cfparam name="arguments.stMetadata.ftRenderType" default="html" /><!--- html, jquery --->
		<!--- COAPI normally fills this from the cfproperty; guard only fires if a caller passed partial metadata --->
		<cfif not structKeyExists(arguments.stMetadata, "ftAllowedFileExtensions")>
			<cfset arguments.stMetadata.ftAllowedFileExtensions = application.fapi.getFormtoolMetadata(formtool="file", property="ftAllowedFileExtensions", md="default") />
		</cfif>
		
		<cfif NOT listfindNoCase("html,jquery", arguments.stMetadata.ftRenderType)>
			<cfset arguments.stMetadata.ftRenderType = "html">
		</cfif>

		<!--- Pick the uploader transport from the destination CDN: direct-to-S3 when it's an S3 bucket, else local XHR. --->
		<cfset uploadLocation = resolveUploadLocation(typename=arguments.typename, stObject=arguments.stObject, stMetadata=arguments.stMetadata) />
		<cfset storageType = application.fc.lib.cdn.getLocationType(uploadLocation) />

		<skin:loadJS id="fc-jquery" />
		<skin:loadJS id="fc-uppy" />
		<skin:loadJS id="fc-uploader" />
		<skin:loadCSS id="uploader" />

		<!--- Pre-compute the details shown for an already-stored file (filename, size, type)
		      and the constraint text. Size is a best-effort CDN lookup; if it fails the
		      details meta simply omits size (the ajax contract is unchanged). --->
		<cfset existingFilename = listLast(arguments.stMetadata.value, "/") />
		<cfif len(arguments.stMetadata.value)>
			<cftry>
				<cfset existingLoc = application.fc.lib.cdn.ioFindFile(locations="publicfiles,privatefiles", file=arguments.stMetadata.value) />
				<cfif len(existingLoc)>
					<cfset existingBytes = application.fc.lib.cdn.ioGetFileSize(location=existingLoc, file=arguments.stMetadata.value) />
				</cfif>
				<cfcatch type="any"></cfcatch>
			</cftry>
			<cfset downloadURL = "#application.url.webroot#/download.cfm?downloadfile=#arguments.stobject.objectid#&typename=#arguments.stobject.typename#&fieldname=#arguments.stmetadata.name#" />
		</cfif>
		<cfset allowedExtsDisplay = ucase(replace(arguments.stMetadata.ftAllowedFileExtensions, ",", ", ", "all")) />
		<cfif isNumeric(arguments.stMetadata.ftMaxSize) and val(arguments.stMetadata.ftMaxSize) gt 0>
			<cfset maxSizeText = application.fapi.humanFileSize(val(arguments.stMetadata.ftMaxSize)) />
		</cfif>

		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
			<cfdefaultcase>

				<cfsavecontent variable="html">
					<grid:div class="multiField">
						<cfoutput>
							<!--- Hidden inputs persist across the dropzone / uploading / details states.
							      '#arguments.fieldname#' holds the stored value; 'DELETE' marks it for removal
							      on save; 'NEW' is the file picker the uploader drives. --->
							<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#encodeForHTMLAttribute(arguments.stMetadata.value)#" />
							<input type="hidden" name="#arguments.fieldname#DELETE" id="#arguments.fieldname#DELETE" value="" />

							<!--- (1) Dropzone — initial state, and the Replace state. --->
							<div id="#arguments.fieldname#-dropzone" class="fc-uploader-dropzone" tabindex="0" role="button" aria-label="Upload file"<cfif len(arguments.stMetadata.value)> style="display:none;"</cfif>>
								<div class="fc-uploader-dropzone-icon"><i class="fa fa-cloud-upload"></i></div>
								<label class="fc-uploader-button">
									Select file
									<input type="file" name="#arguments.fieldname#NEW" id="#arguments.fieldname#NEW" fc:fieldname="#arguments.fieldname#"<cfif len(arguments.stMetadata.ftAllowedFileExtensions)> accept=".#replace(arguments.stMetadata.ftAllowedFileExtensions,",",",.","all")#"</cfif> class="fc-uploader-file-input #arguments.inputClass#<cfif arguments.stMetadata.ftValidation eq 'required'> required</cfif>" value="" style="#arguments.stMetadata.ftstyle#" />
								</label>
								<span class="fc-uploader-dropzone-hint">or drag and drop a file, or paste from clipboard</span>
								<a id="#arguments.fieldname#-cancel-replace" class="fc-uploader-cancel-replace" style="display:none;">Cancel &mdash; keep the current file</a>
							</div>

							<!--- Constraint text. Hidden while a file is present (only relevant when picking).
							      The full extension list lives in a hover tooltip to keep this line short. --->
							<div id="#arguments.fieldname#-constraints" class="fc-uploader-constraints"<cfif len(arguments.stMetadata.value)> style="display:none;"</cfif>>
								<span class="fc-richtooltip fc-uploader-help" data-tooltip-position="top" data-tooltip-width="280" title="Accepted: #allowedExtsDisplay#">Formats accepted <i class="fa fa-question-circle"></i></span><cfif len(maxSizeText)> &middot; Max size: #maxSizeText#</cfif>
							</div>

							<!--- (2) During-upload row — filename + size/percent + cancel, with the thin progress bar beneath. --->
							<div id="#arguments.fieldname#-uploading" class="fc-uploader-uploading" style="display:none;">
								<div class="fc-uploader-uploading-row">
									<span class="fc-uploader-uploading-icon"><i id="#arguments.fieldname#-uploading-icon" class="fa fa-file-o"></i></span>
									<div class="fc-uploader-uploading-body">
										<span class="fc-uploader-uploading-name" id="#arguments.fieldname#-uploading-name"></span>
										<span class="fc-uploader-uploading-meta" id="#arguments.fieldname#-uploading-meta"></span>
									</div>
									<span class="fc-uploader-uploading-cancel">
										<button type="button" class="fc-uploader-icon-btn" id="#arguments.fieldname#-uploading-cancel" aria-label="Cancel upload"><i class="fa fa-times"></i></button>
									</span>
								</div>
								<div class="fc-uploader-progress">
									<div class="fc-uploader-progress-bar" id="#arguments.fieldname#-progress-bar" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0"></div>
								</div>
							</div>

							<!--- (3) Details view — shown once a file is stored. Header row carries the
							      file-type icon, name/meta and the standalone red Delete button; Preview and
							      Replace sit on their own row beneath. --->
							<div id="#arguments.fieldname#-details" class="fc-uploader-details" data-bytes="#existingBytes#"<cfif not len(arguments.stMetadata.value)> style="display:none;"</cfif>>
								<div class="fc-uploader-details-row">
									<span class="fc-uploader-details-icon"><i id="#arguments.fieldname#-details-icon" class="fa fa-file-o"></i></span>
									<div class="fc-uploader-details-body">
										<div class="fc-uploader-details-name" id="#arguments.fieldname#-details-name"></div>
										<div class="fc-uploader-details-meta" id="#arguments.fieldname#-details-meta"></div>
									</div>
									<div class="fc-uploader-details-delete">
										<button type="button" id="#arguments.fieldname#-delete" class="fc-uploader-delete-btn" title="Delete" aria-label="Delete file"><i class="fa fa-trash-o"></i></button>
									</div>
								</div>
								<div class="fc-uploader-details-actions">
									<a id="#arguments.fieldname#-preview" class="fc-uploader-action" target="_blank" href="<cfif len(downloadURL)>#downloadURL#<cfelse>##</cfif>"><i class="fa fa-eye"></i> Preview</a>
									<a id="#arguments.fieldname#-replace" class="fc-uploader-action"><i class="fa fa-upload"></i> Replace</a>
								</div>
							</div>

							<!--- Error alert + screen-reader live region. --->
							<div id="#arguments.fieldname#-error" class="fc-uploader-error" style="display:none;"></div>
							<span id="#arguments.fieldname#-status" class="fc-uploader-file-input" aria-live="polite"></span>
						</cfoutput>

						<skin:onReady>
						<cfoutput>
							(function(){
								var DZ          = '###arguments.fieldname#-dropzone';
								var UP          = '###arguments.fieldname#-uploading';
								var DETAILS     = '###arguments.fieldname#-details';
								var CONSTRAINTS = '###arguments.fieldname#-constraints';
								var ERR         = '###arguments.fieldname#-error';
								var STATUS      = '###arguments.fieldname#-status';
								var BAR         = '###arguments.fieldname#-progress-bar';
								var allowedExts = '#arguments.stMetadata.ftAllowedFileExtensions#';
								var maxBytes    = <cfif isNumeric(arguments.stMetadata.ftMaxSize) and val(arguments.stMetadata.ftMaxSize) gt 0>#val(arguments.stMetadata.ftMaxSize)#<cfelse>0</cfif>;

								function announce(msg){ $j(STATUS).text(msg); }

								function fcFormatBytes(bytes){
									bytes = Number(bytes) || 0;
									if (bytes <= 0) return '';
									var units = ['B','KB','MB','GB','TB'];
									var i = Math.floor(Math.log(bytes) / Math.log(1024));
									if (i >= units.length) i = units.length - 1;
									var v = bytes / Math.pow(1024, i);
									return (i === 0 ? Math.round(v) : v.toFixed(1)) + ' ' + units[i];
								}

								function fcFileIcon(name){
									var ext = (name && name.indexOf('.') !== -1) ? name.split('.').pop().toLowerCase() : '';
									var map = {
										pdf:'fa-file-pdf-o',
										doc:'fa-file-word-o', docx:'fa-file-word-o',
										xls:'fa-file-excel-o', xlsx:'fa-file-excel-o', csv:'fa-file-excel-o',
										ppt:'fa-file-powerpoint-o', pptx:'fa-file-powerpoint-o',
										jpg:'fa-file-image-o', jpeg:'fa-file-image-o', png:'fa-file-image-o', gif:'fa-file-image-o', bmp:'fa-file-image-o', svg:'fa-file-image-o', webp:'fa-file-image-o',
										zip:'fa-file-archive-o', rar:'fa-file-archive-o', '7z':'fa-file-archive-o', gz:'fa-file-archive-o', tar:'fa-file-archive-o',
										mp3:'fa-file-audio-o', wav:'fa-file-audio-o', ogg:'fa-file-audio-o', wma:'fa-file-audio-o', m4a:'fa-file-audio-o',
										mp4:'fa-file-video-o', mov:'fa-file-video-o', avi:'fa-file-video-o', wmv:'fa-file-video-o', flv:'fa-file-video-o', mkv:'fa-file-video-o', mpg:'fa-file-video-o', mpeg:'fa-file-video-o',
										txt:'fa-file-text-o', rtf:'fa-file-text-o',
										js:'fa-file-code-o', css:'fa-file-code-o', html:'fa-file-code-o', htm:'fa-file-code-o', xml:'fa-file-code-o', json:'fa-file-code-o', cfm:'fa-file-code-o', cfc:'fa-file-code-o'
									};
									return map[ext] || 'fa-file-o';
								}

								function fcRenderDetails(filename, bytes){
									var ext = (filename && filename.indexOf('.') !== -1) ? filename.split('.').pop().toUpperCase() : '';
									$j(DETAILS + '-icon').attr('class', 'fa ' + fcFileIcon(filename));
									$j(DETAILS + '-name').text(filename).attr('title', filename);
									var meta = [];
									var sizeText = fcFormatBytes(bytes);
									if (sizeText) meta.push('Size: ' + sizeText);
									if (ext) meta.push('Type: ' + ext);
									$j(DETAILS + '-meta').text(meta.join('  ·  '));
								}

								function showDropzone(){
									$j('###arguments.fieldname#-cancel-replace').css('display','none');
									$j(UP).hide(); $j(DETAILS).hide(); $j(CONSTRAINTS).show(); $j(DZ).show();
								}
								function showUploading(file){
									hideError();
									$j('###arguments.fieldname#-cancel-replace').css('display','none');
									$j('###arguments.fieldname#-uploading-icon').attr('class', 'fa ' + fcFileIcon(file.name));
									$j('###arguments.fieldname#-uploading-name').text(file.name).attr('title', file.name);
									$j('###arguments.fieldname#-uploading-meta').text(fcFormatBytes(file.size));
									$j(BAR).css('width','0%').attr('aria-valuenow', 0).removeClass('is-complete is-error');
									$j(DZ).hide(); $j(DETAILS).hide(); $j(CONSTRAINTS).hide(); $j(UP).show();
									announce('Uploading ' + file.name);
								}
								function showDetails(){
									$j('###arguments.fieldname#-cancel-replace').css('display','none');
									$j(DZ).hide(); $j(UP).hide(); $j(CONSTRAINTS).hide(); $j(DETAILS).show();
								}
								function setProgress(file, percent){
									$j(BAR).css('width', percent + '%').attr('aria-valuenow', percent);
									var sizeText = fcFormatBytes(file.size);
									if (percent < 100)
										$j('###arguments.fieldname#-uploading-meta').text((sizeText ? sizeText + '  ·  ' : '') + percent + '%');
									else
										$j('###arguments.fieldname#-uploading-meta').text((sizeText ? sizeText + '  ·  ' : '') + 'Processing...');
								}
								function showError(msg){ $j(ERR).text(msg).show(); announce('Upload failed: ' + msg); }
								function hideError(){ $j(ERR).hide().text(''); }

								var uploader = $fc.uploader.create({
									fileInput:        '###arguments.fieldname#NEW',
									fieldName:        '#arguments.stMetadata.name#NEW',
									endpoint:         '#getAjaxURL(typename=arguments.typename, stObject=arguments.stObject, stMetadata=arguments.stMetadata, fieldname=arguments.fieldname, combined=true)#',
									storage:          '#storageType#',
									allowedFileTypes: allowedExts,
									maxFileSize:      <cfif isNumeric(arguments.stMetadata.ftMaxSize) and val(arguments.stMetadata.ftMaxSize) gt 0>#val(arguments.stMetadata.ftMaxSize)#<cfelse>0</cfif>,
									maxNumberOfFiles: 1,
									autoProceed:      true,
									dropZone:         DZ,
									onDragEnter: function(){ $j(DZ).addClass('is-dragover'); },
									onDragLeave: function(){ $j(DZ).removeClass('is-dragover'); },
									onSelect: function(file){
										showUploading(file);
									},
									onProgress: function(file, percent){
										setProgress(file, percent);
									},
									onComplete: function(file, results){
										if (results.error) {
											showError(results.error);
											if ($j('###arguments.fieldname#').val()) showDetails(); else showDropzone();
											return;
										}
										$j('###arguments.fieldname#').val(results.value || '');
										$j('###arguments.fieldname#DELETE').val('');
										var filename = results.filename || file.name || (results.value ? results.value.split('/').pop() : '');
										// Prefer the CDN-resolved fullpath (works pre-save). Fall back to download.cfm (works post-save).
										var previewURL = results.fullpath || '#application.url.webroot#/download.cfm?downloadfile=#arguments.stobject.objectid#&typename=#arguments.stobject.typename#&fieldname=#arguments.stmetadata.name#';
										$j('###arguments.fieldname#-preview').attr('href', previewURL);
										fcRenderDetails(filename, file.size || 0);
										showDetails();
										announce('File uploaded: ' + filename);
										$j(DETAILS).find('.fc-uploader-action').first().focus();
									},
									onError: function(file, error){
										var msg;
										if (error.type === 'size')
											msg = (file && file.name ? file.name + ' ' : '') + 'is not within the file size limit of ' + fcFormatBytes(maxBytes);
										else if (error.type === 'type')
											// space after each comma so the list wraps at extension boundaries (not mid-token)
											msg = 'Only files with the following extensions are allowed: ' + allowedExts.split(',').join(', ');
										else if (error.type === 'http')
											msg = 'Server error (' + (error.status||'') + '): ' + error.message;
										else if (error.type === 'network')
											msg = 'Network error: ' + error.message;
										else
											msg = error.message;
										showError(msg);
										if ($j('###arguments.fieldname#').val()) showDetails(); else showDropzone();
									}
								});

								// Cancel an in-flight upload.
								$j('###arguments.fieldname#-uploading-cancel').click(function(e){
									e.preventDefault();
									uploader.cancelAll();
									if ($j('###arguments.fieldname#').val()) showDetails(); else showDropzone();
								});

								// Keyboard: Enter / Space on the focused dropzone opens the file dialog.
								$j(DZ).on('keydown', function(e){
									if (e.keyCode === 13 || e.keyCode === 32){
										e.preventDefault();
										$j('###arguments.fieldname#NEW').click();
									}
								});

								// Replace: return to the dropzone with a "keep current file" escape hatch.
								$j('###arguments.fieldname#-replace').click(function(e){
									e.preventDefault();
									hideError();
									showDropzone();
									$j('###arguments.fieldname#-cancel-replace').css('display','inline');
									$j(DZ).focus();
								});
								$j('###arguments.fieldname#-cancel-replace').click(function(e){
									e.preventDefault();
									showDetails();
								});

								// Delete: confirm dialog. On confirm, mark the stored value for removal on save
								// (same field manipulation the previous inline workflow used) and return to the dropzone.
								$j('###arguments.fieldname#-delete').click(function(e){
									e.preventDefault();
									$fc.uploader.confirm({
										title:   'Delete this file?',
										message: 'This file will be removed when you save the form.',
										buttons: [
											{ label: 'Delete', value: 'delete', style: 'primary' },
											{ label: 'Cancel', value: 'cancel', isCancel: true }
										],
										onSelect: function(value){
											if (value !== 'delete') return;
											$j('###arguments.fieldname#DELETE').val($j('###arguments.fieldname#').val());
											$j('###arguments.fieldname#').val('');
											hideError();
											showDropzone();
											$j(DZ).focus();
										}
									});
								});

								// Render the details meta for an already-stored file on load.
								if ($j('###arguments.fieldname#').val()){
									fcRenderDetails('#jsStringFormat(existingFilename)#', $j(DETAILS).data('bytes'));
								}

								// Width-constrained hover tooltip for the accepted-formats list.
								// ft:form loads the Tooltipster library but the webtop only auto-inits
								// tooltips in its header, so edit-form triggers must be initialised here.
								if ($j.fn.tooltipster){
									$j(CONSTRAINTS).find('.fc-richtooltip').tooltipster({
										theme:      '.tooltipster-light',
										position:   'top',
										fixedWidth: 280,
										delay:      0,
										speed:      200
									});
								}
							})();
						</cfoutput>
						</skin:onReady>
					</grid:div>
				</cfsavecontent>
				
			</cfdefaultcase>
			
		</cfswitch>
	
		<cfreturn html>
	</cffunction>

	<cffunction name="ajax" output="false" returntype="string" hint="Response to ajax requests for this formtool. Handles XHR-on-select uploads from $fc.uploader.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<!--- Every return path in this method serialises JSON. Set the correct Content-Type
		      so consumers (and proxies / dev tooling) treat it as JSON, not the CFML default text/html. --->
		<cfheader name="Content-Type" value="application/json; charset=UTF-8" />

		<cfset var stResult = "" />
		<cfset var stFieldPost = structnew() />
		<cfset var stJSON = structnew() />
		<cfset var objStatus = "" />

		<cfparam name="arguments.stMetadata.ftSecure" default="false" />
		<cfparam name="arguments.stMetadata.ftLocation" default="" />
		<cfparam name="arguments.stMetadata.ftDestination" default="" />
		<cfparam name="arguments.stMetadata.ftAllowedFileExtensions" default="" />
		<cfparam name="arguments.stMetadata.ftMaxSize" default="0" />

		<!--- Direct-to-S3 transport (storage:"s3"): sign before upload, finalize after. --->
		<cfif structkeyexists(url,"s3op")>
			<cfreturn ajaxS3(typename=arguments.typename, stObject=arguments.stObject, stMetadata=arguments.stMetadata, fieldname=arguments.fieldname) />
		</cfif>

		<!--- Legacy 'check' endpoint (uploadify compatibility — harmless) --->
		<cfif structkeyexists(url,"check")>
			<cfreturn "[]" />
		</cfif>

		<cfif structkeyexists(arguments.stObject,"status")>
			<cfset objStatus = arguments.stObject.status />
		</cfif>

		<!--- handleFilePost expects stFieldPost.value (current value) and reads form[uploadfield] for the new file --->
		<cfset stFieldPost.value = arguments.stObject[arguments.stMetadata.name] />
		<cfset stFieldPost.NEW = "" />
		<cfset stFieldPost.DELETE = false />

		<cfset stResult = handleFilePost(
			objectid=arguments.stObject.objectid,
			typename=arguments.typename,
			existingFile=arguments.stObject[arguments.stMetadata.name],
			uploadField="#arguments.stMetadata.name#NEW",
			destination=arguments.stMetadata.ftDestination,
			secure=arguments.stMetadata.ftSecure,
			ftLocation=arguments.stMetadata.ftLocation,
			status=objStatus,
			allowedExtensions=arguments.stMetadata.ftAllowedFileExtensions,
			sizeLimit=arguments.stMetadata.ftMaxsize,
			bArchive=application.stCOAPI[arguments.typename].bArchive and (not structkeyexists(arguments.stMetadata,"ftArchive") or arguments.stMetadata.ftArchive),
			stFieldPost=stFieldPost
		) />

		<cfif stResult.bSuccess and len(stResult.value)>
			<cfset stJSON["objectid"] = arguments.stObject.objectid />
			<cfset stJSON["value"] = stResult.value />
			<cfset stJSON["filename"] = listLast(stResult.value, "/") />
			<cfset stJSON["error"] = "" />

			<!--- Resolve the CDN path so the client can show a working preview link
			      even before the form is saved (download.cfm would 404 pre-save because
			      no object record exists in the DB yet). --->
			<cfset stJSON["fullpath"] = "" />
			<cftry>
				<cfset stJSON["fullpath"] = application.fc.lib.cdn.ioGetFileLocation(
					location=application.fc.lib.cdn.ioFindFile(locations="publicfiles,privatefiles", file=stResult.value),
					file=stResult.value,
					bRetrieve=false
				).path />
				<cfcatch type="any">
					<!--- If CDN resolution fails, fullpath stays empty; the client falls back
					      to the download.cfm URL (which works post-save). --->
				</cfcatch>
			</cftry>
		<cfelse>
			<cfset stJSON["objectid"] = arguments.stObject.objectid />
			<cfset stJSON["value"] = stFieldPost.value />
			<cfset stJSON["filename"] = "" />
			<cfset stJSON["fullpath"] = "" />
			<cfif structkeyexists(stResult,"stError") and structkeyexists(stResult.stError,"message")>
				<cfset stJSON["error"] = stResult.stError.message />
			<cfelse>
				<cfset stJSON["error"] = "Upload failed" />
			</cfif>
		</cfif>

		<cfreturn serializeJSON(stJSON) />
	</cffunction>

	<cffunction name="resolveUploadLocation" access="private" output="false" returntype="string" hint="Determines the CDN location an upload targets, mirroring handleFilePost's location logic">
		<cfargument name="typename" required="true" type="string" />
		<cfargument name="stObject" required="true" type="struct" />
		<cfargument name="stMetadata" required="true" type="struct" />

		<cfset var filepermission = 0 />
		<cfset var objStatus = structKeyExists(arguments.stObject,"status") ? arguments.stObject.status : "" />

		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />

		<cfparam name="arguments.stMetadata.ftSecure" default="false" />
		<cfparam name="arguments.stMetadata.ftLocation" default="" />

		<sec:CheckPermission objectid="#arguments.stObject.objectid#" type="#arguments.typename#" permission="View" roles="Anonymous" result="filepermission" />

		<cfif len(arguments.stMetadata.ftLocation)>
			<cfreturn arguments.stMetadata.ftLocation />
		<cfelseif arguments.stMetadata.ftSecure eq "false" and not listfindnocase("draft,pending",objStatus) and filepermission>
			<cfreturn "publicfiles" />
		<cfelse>
			<cfreturn "privatefiles" />
		</cfif>
	</cffunction>

	<cffunction name="ajaxS3" access="private" output="false" returntype="string" hint="Handles direct-to-S3 sign / finalize requests (storage:s3). Returns the same JSON contract as ajax() so onComplete is unchanged.">
		<cfargument name="typename" required="true" type="string" />
		<cfargument name="stObject" required="true" type="struct" />
		<cfargument name="stMetadata" required="true" type="struct" />
		<cfargument name="fieldname" required="true" type="string" />

		<cfset var stBody = getAjaxRequestBody() />
		<cfset var location = resolveUploadLocation(typename=arguments.typename, stObject=arguments.stObject, stMetadata=arguments.stMetadata) />
		<cfset var stPrep = "" />
		<cfset var stJSON = structnew() />
		<cfset var value = "" />

		<cfparam name="arguments.stMetadata.ftDestination" default="" />
		<cfparam name="arguments.stMetadata.ftMaxSize" default="0" />
		<cfparam name="arguments.stMetadata.ftAllowedFileExtensions" default="" /><!--- real default comes from the file cfproperty via COAPI; "" mirrors ajax() --->


		<cfif url.s3op eq "sign">
			<cftry>
				<cfset stPrep = application.fc.lib.cdn.prepareDirectUpload(
					location=location,
					destination=arguments.stMetadata.ftDestination,
					filename=structKeyExists(stBody,"filename") ? stBody.filename : "upload",
					uniqueAmong="privatefiles,publicfiles",
					contentType=structKeyExists(stBody,"type") ? stBody.type : "",
					maxSize=val(arguments.stMetadata.ftMaxSize),
					acceptExtensions=arguments.stMetadata.ftAllowedFileExtensions
				) />
				<!--- Carry the resolved value to the client so finalize can echo it back
				      (the client treats it as an opaque token; no key->value reversal needed). --->
				<cfset stPrep.params["value"] = stPrep.value />
				<cfreturn serializeJSON(stPrep.params) />

				<cfcatch type="any">
					<cfreturn serializeJSON({ "error" = cfcatch.message }) />
				</cfcatch>
			</cftry>

		<cfelseif url.s3op eq "finalize">
			<cftry>
				<cfset value = structKeyExists(stBody,"value") ? stBody.value : "" />

				<!--- confirm the object actually landed before recording the client value (mirrors image.cfc) --->
				<cfif not len(value) or not application.fc.lib.cdn.ioFileExists(location=location, file=value)>
					<cfreturn serializeJSON({ "objectid"=arguments.stObject.objectid, "value"="", "filename"="", "fullpath"="", "error"="Uploaded file could not be found" }) />
				</cfif>

				<cfset stJSON["objectid"] = arguments.stObject.objectid />
				<cfset stJSON["value"] = value />
				<cfset stJSON["filename"] = listLast(value, "/") />
				<cfset stJSON["error"] = "" />
				<cfset stJSON["fullpath"] = "" />
				<cftry>
					<cfset stJSON["fullpath"] = application.fc.lib.cdn.ioGetFileLocation(location=location, file=value, bRetrieve=false).path />
					<cfcatch type="any"></cfcatch>
				</cftry>
				<cfreturn serializeJSON(stJSON) />

				<cfcatch type="any">
					<cfreturn serializeJSON({ "objectid"=arguments.stObject.objectid, "value"="", "filename"="", "fullpath"="", "error"=cfcatch.message }) />
				</cfcatch>
			</cftry>
		</cfif>

		<cfreturn serializeJSON({ "error" = "Unknown s3op [#url.s3op#]" }) />
	</cffunction>

	<cffunction name="display" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
	
		<cfsavecontent variable="html">
			<cfoutput><a target="_blank" href="#application.url.webroot#/download.cfm?downloadfile=#encodeForHTMLAttribute(arguments.stobject.objectid)#&typename=#encodeForHTMLAttribute(arguments.typename)#&fieldname=#encodeForHTMLAttribute(arguments.stmetadata.name)#">#encodeForHTML(listLast(arguments.stMetadata.value,"/"))#</a></cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>
	
	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type. Includes Value and stSupporting">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var filelocation = "" />
		<cfset var stResult = structNew()>
		<cfset var qDuplicates = queryNew("blah") />
		<cfset var cleanFileName = "" />
		<cfset var newFileName = "" />
		<cfset var stObj = application.fapi.getContentObject(objectid=arguments.objectid,typename=arguments.typename) />
		<cfset var filepermission = 0 />
		<cfset var objStatus = "">
			
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = stFieldPost.value>
		<cfset stResult.stError = StructNew()>
		
		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
		
		<cfparam name="arguments.stMetadata.ftSecure" default="false" />
		<cfparam name="arguments.stMetadata.ftLocation" default="" />
		<cfparam name="arguments.stMetadata.ftDestination" default="" />
		<cfparam name="arguments.stMetadata.ftRenderType" default="html" />
		<!--- COAPI normally fills this from the cfproperty; guard only fires if a caller passed partial metadata --->
		<cfif not structKeyExists(arguments.stMetadata, "ftAllowedFileExtensions")>
			<cfset arguments.stMetadata.ftAllowedFileExtensions = application.fapi.getFormtoolMetadata(formtool="file", property="ftAllowedFileExtensions", md="default") />
		</cfif>
		
		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
			<cfcase value="html">
				<cfif structKeyExists(stObj,"status")>
					<cfset objStatus = stObj.status>
				</cfif>
				<cfset stResult = handleFilePost(
					objectid=arguments.objectid,
					typename=arguments.typename,
					existingFile=form["#stMetadata.FormFieldPrefix##stMetadata.Name#"],
					uploadField="#stMetadata.FormFieldPrefix##stMetadata.Name#NEW",
					destination=arguments.stMetadata.ftDestination,
					secure=arguments.stMetadata.ftSecure,
					ftLocation=arguments.stMetadata.ftLocation,
					status=objStatus,
					allowedExtensions=arguments.stMetadata.ftAllowedFileExtensions,
					sizeLimit=arguments.stMetadata.ftMaxsize,
					bArchive=application.stCOAPI[arguments.typename].bArchive and (not structkeyexists(arguments.stMetadata,"ftArchive") or arguments.stMetadata.ftArchive),
					stFieldPost=arguments.stFieldPost
				) />
				<!--- validation cleanup to avoid additional/duplicate file uploads from further field validation processing in this request --->
				<cfset structDelete(FORM,"#stMetadata.FormFieldPrefix##stMetadata.name#NEW")>
				<cfset form["#stMetadata.FormFieldPrefix##stMetadata.name#"] = stResult.value>
			</cfcase>
		
			<cfdefaultcase><!--- value="flash" --->
				<cfif structkeyexists(session,"#stMetadata.FormFieldPrefix##stMetadata.Name#") and len(session["#stMetadata.FormFieldPrefix##stMetadata.Name#"])>
					<cfset stResult.value = session['#stMetadata.FormFieldPrefix##stMetadata.Name#'] />
					<cfset structdelete(session,"#stMetadata.FormFieldPrefix##stMetadata.Name#") />
				<cfelseif structkeyexists(form,"#stMetadata.FormFieldPrefix##stMetadata.Name#")>
					<cfset stResult.value = form['#stMetadata.FormFieldPrefix##stMetadata.Name#'] />
				</cfif>
			</cfdefaultcase>
		
		</cfswitch>
		
	
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>
	
	
	<cffunction name="handleFilePost" access="public" output="false" returntype="struct" hint="Handles file post and returns standard formtool result struct">
		<cfargument name="objectid" type="uuid" required="true" hint="The objectid of the edited object" />
		<cfargument name="typename" type="string" required="true" hint="The type of the edited object" />
		<cfargument name="existingfile" type="string" required="true" hint="Current value of property" />
		<cfargument name="uploadfield" type="string" required="true" hint="Traditional form saves will use <PREFIX><PROPERTY>NEW, ajax posts will use <PROPERTY>NEW ... so the caller needs to say which it is" />
		<cfargument name="destination" type="string" required="true" hint="Destination of file" />
		<cfargument name="allowedExtensions" type="string" required="true" hint="The acceptable extensions" />
		<cfargument name="secure" type="boolean" required="true" hint="Whether this file needs to be stored securely" />
		<cfargument name="status" type="string" required="true" hint="Status of object attached to" />
		<cfargument name="sizeLimit" type="numeric" required="false" default="0" hint="Maximum size of file in bytes" />
		<cfargument name="bArchive" type="boolean" required="true" hint="True to archive old files" />
		<cfargument name="stFieldPost" type="struct" required="false" default="#structnew()#" hint="The supplementary data" />
		<cfargument name="ftLocation" type="string" required="false" default="" hint="set to 'temp' to save to local CDN location" />
		
		<cfset var filelocation = "" />
		<cfset var stResult = structNew()>
		<cfset var filepermission = 0 />
		<cfset var archivedFile = "" />
			
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = stFieldPost.value>
		<cfset stResult.stError = StructNew()>
		
		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
		
		<!--- If developer has entered an ftDestination, make sure it starts with a slash --->
		<cfif len(arguments.destination) AND left(arguments.destination,1) NEQ "/">
			<cfset arguments.destination = "/#arguments.destination#" />
		</cfif>
		
		<sec:CheckPermission objectid="#arguments.objectid#" type="#arguments.typename#" permission="View" roles="Anonymous" result="filepermission" />
		<cfif len(arguments.ftLocation)>
			<cfset filelocation = arguments.ftLocation />
		<cfelseif arguments.secure eq "false" and not listfindnocase("draft,pending",arguments.status) and filepermission>
			<cfset filelocation = "publicfiles" />
		<cfelse>
			<cfset filelocation = "privatefiles" />
		</cfif>
		
		<cfparam name="stFieldPost.NEW" default="" />
		<cfparam name="stFieldPost.DELETE" default="false" /><!--- Boolean --->
		
		<cfif (
				(
					structkeyexists(form,arguments.uploadfield) 
					AND len(form[arguments.uploadfield])
				) 
				OR (
					isBoolean(stFieldPost.DELETE) 
					AND stFieldPost.DELETE
				)
			) 
			AND len(arguments.existingfile)
			AND application.fc.lib.cdn.ioFileExists(location=filelocation,file=arguments.existingfile)>
			
			<cfif arguments.bArchive>
				<cfset archivedFile = application.fc.lib.cdn.ioMoveFile(
					source_location=fileLocation,
					source_file=arguments.existingFile,
					dest_location="archive",
					dest_file="#arguments.destination#/#arguments.objectid#-#round(getTickCount()/1000)#-#listLast(arguments.existingfile, '/')#"
				) />
			<cfelse>
				<cfset archivedFile = application.fc.lib.cdn.ioCopyFile(
					source_location=fileLocation,
					source_file=arguments.existingfile,
					dest_localpath=getTempDirectory() & "#arguments.objectid#-#round(getTickCount()/1000)#-#listLast(arguments.existingfile, '/')#"
				) />
			</cfif>
			
		</cfif>
		
		<cfif structkeyexists(form,arguments.uploadfield) and len(form[arguments.uploadfield])>
			<cftry>
				<cfif len(arguments.existingFile)>
					<!--- This means there is currently a file associated with this object. We need to override this file --->
					<cfset stResult.value = application.fc.lib.cdn.ioUploadFile(
						location=fileLocation,
						destination=arguments.existingFile,
						field=arguments.uploadField,
						nameconflict="overwrite",
						acceptextensions=arguments.allowedExtensions,
						sizeLimit=arguments.sizeLimit
					) />
					
					<cfif not arguments.bArchive>
						<cffile action="delete" file="#archivedFile#" />
					</cfif>
				<cfelse>
					<!--- There is no file currently so we simply upload the file and make it unique  --->
					<cfset stResult.value = application.fc.lib.cdn.ioUploadFile(
						location=fileLocation,
						destination=arguments.destination,
						field=arguments.uploadField,
						nameconflict="makeunique",
						uniqueamong="privatefiles,publicfiles",
						acceptextensions=arguments.allowedExtensions,
						sizeLimit=arguments.sizeLimit
					) />
				</cfif>
				
				<cfcatch type="uploaderror">
					<cfif len(archivedFile) and arguments.bArchive>
						<cfset application.fc.lib.cdn.ioMoveFile(
							source_location="archive",
							source_file=archivedFile,
							dest_location=fileLocation,
							dest_file=arguments.existingFile
						) />
					<cfelseif len(archivedFile)>
						<cfset archivedFile = application.fc.lib.cdn.ioMoveFile(
							source_localpath=archivedFile,
							dest_location=fileLocation,
							dest_file=arguments.existingFile
						) />
					</cfif>
					
					<cfset stResult = failed(value=arguments.existingFile,message=cfcatch.message) />
				</cfcatch>
			</cftry>
		</cfif>
		
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>
	
	<cffunction name="handleFileLocal" access="public" output="false" returntype="struct" hint="Handles using a local file as the new file and returns standard formtool result struct">
		<cfargument name="objectid" type="uuid" required="true" hint="The objectid of the edited object" />
		<cfargument name="typename" type="string" required="true" hint="The type of the edited object" />
		<cfargument name="existingfile" type="string" required="true" hint="Current value of property" />
		<cfargument name="localfile" type="string" required="true" hint="The local file" />
		<cfargument name="destination" type="string" required="true" hint="Destination of file" />
		<cfargument name="secure" type="boolean" required="true" hint="Whether this file needs to be stored securely" />
		<cfargument name="status" type="string" required="true" hint="Status of object attached to" />
		<cfargument name="allowedExtensions" type="string" required="true" hint="The acceptable extensions" />
		<cfargument name="sizeLimit" type="numeric" required="false" default="0" hint="Maximum size of file in bytes" />
		<cfargument name="bArchive" type="boolean" required="true" hint="True to archive old files" />
		<cfargument name="location" type="string" required="false" default="" hint="Explicit CDN location override. When set it wins over secure/status/permission, pinning the file to this location." />

		<cfset var filelocation = "" />
		<cfset var uniqueamong = "privatefiles,publicfiles" />
		<cfset var stResult = structNew()>
		<cfset var filepermission = 0 />
		<cfset var archivedFile = "" />
		<cfset var errormessage = "" />

		<cfset stResult.bSuccess = true>
		<cfset stResult.value = arguments.existingFile>
		<cfset stResult.stError = StructNew()>

		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />

		<!--- If developer has entered an ftDestination, make sure it starts with a slash --->
		<cfif len(arguments.destination) AND left(arguments.destination,1) NEQ "/">
			<cfset arguments.destination = "/#arguments.destination#" />
		</cfif>

		<sec:CheckPermission objectid="#arguments.objectid#" type="#arguments.typename#" permission="View" roles="Anonymous" result="filepermission" />
		<!--- An explicit location override always wins and pins the file to that location. --->
		<cfif len(arguments.location)>
			<cfset filelocation = arguments.location />
			<cfset uniqueamong = arguments.location />
		<cfelseif arguments.secure eq "false" and not listfindnocase("draft,pending",arguments.status) and filepermission>
			<cfset filelocation = "publicfiles" />
		<cfelse>
			<cfset filelocation = "privatefiles" />
		</cfif>

		<cfif len(arguments.existingfile)
			AND application.fc.lib.cdn.ioFileExists(location=filelocation,file=arguments.existingfile)>
			
			<cfif arguments.bArchive>
				<cfset archivedFile = application.fc.lib.cdn.ioMoveFile(
					source_location=fileLocation,
					source_file=arguments.existingFile,
					dest_location="archive",
					dest_file="#arguments.destination#/#arguments.objectid#-#round(getTickCount()/1000)#-#listLast(FORM['#stMetadata.FormFieldPrefix##stMetadata.Name#Delete'], '/')#"
				) />
			<cfelse>
				<cfset archivedFile = application.fc.lib.cdn.ioCopyFile(
					source_location=fileLocation,
					source_file=arguments.existingfile,
					dest_localpath=getTempDirectory() & "#arguments.objectid#-#round(getTickCount()/1000)#-#listLast(arguments.existingfile, '/')#"
				) />
			</cfif>
			
		</cfif>
		
		<cftry>
    		<cfset errormessage = application.fc.lib.cdn.ioValidateFile(
    			localpath=arguments.localfile,
    			sizeLimit=arguments.sizeLimit,
    			acceptextensions=arguments.allowedExtensions,
    			existingFile=arguments.existingfile
    		) />
    		
			<cfif len(arguments.existingFile)>
				<!--- This means there is currently a file associated with this object. We need to overwrite this file --->
				<cfset stResult.value = application.fc.lib.cdn.ioCopyFile(
					source_localpath=arguments.localfile,
					dest_location=fileLocation,
					dest_file=arguments.existingFile
				) />
				
				<cfif not arguments.bArchive>
					<cffile action="delete" file="#archivedFile#" />
				</cfif>
			<cfelse>
				<!--- There is no file currently so we simply copy the file and make it unique  --->
				<cfset stResult.value = application.fc.lib.cdn.ioMoveFile(
					source_localpath=arguments.localfile,
					dest_location=fileLocation,
					dest_file=arguments.destination & "/" & listlast(arguments.localfile,"/\"),
					nameconflict="makeunique",
					uniqueamong=uniqueamong
				) />
			</cfif>
			
			<cfcatch type="uploaderror">
				<cfif len(archivedFile) and arguments.bArchive>
					<cfset application.fc.lib.cdn.ioMoveFile(
						source_location="archive",
						source_file=archivedFile,
						dest_location=fileLocation,
						dest_file=arguments.existingFile
					) />
				<cfelseif len(archivedFile)>
					<cfset archivedFile = application.fc.lib.cdn.ioMoveFile(
						source_localpath=archivedFile,
						dest_location=fileLocation,
						dest_file=arguments.existingFile
					) />
				</cfif>
				
				<cfset stResult = failed(value=arguments.existingFile,message=cfcatch.message) />
			</cfcatch>
		</cftry>
	
	
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>
	
	
	<cffunction name="onDraft" access="public" output="false" returntype="void" hint="Called from setData when an object's status is changed">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="previousStatus" type="string" required="true" hint="The previous status of the object" />
		
		<cfset var filepermission = 0 />
		<cfset var currentLocation = "" />
		
		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />

		<cfparam name="arguments.stMetadata.ftSecure" default="false" />

		<!--- An explicit ftLocation override pins the file; skip public/private movement. --->
		<cfif len(getLocationOverride(arguments.stMetadata))>
			<cfreturn />
		</cfif>

		<!--- Draft content should always be secured --->
		<!--- ftSecure=true will already be secured --->
		<!--- anonymous access=false will already be secured --->
		<cfif len(arguments.stObject[arguments.stMetadata.name])>
			<cfset currentLocation = application.fc.lib.cdn.ioFindFile(locations="publicfiles,privatefiles",file=arguments.stObject[arguments.stMetadata.name]) />
			<sec:CheckPermission objectid="#arguments.stObject.objectid#" type="#arguments.typename#" permission="View" roles="Anonymous" result="filepermission" />
			
			<cfif len(currentLocation) and currentLocation neq "privatefiles" and arguments.previousStatus eq "approved" and not arguments.stMetadata.ftSecure and filepermission>
				<cfset application.fc.lib.cdn.ioMoveFile(source_location=currentLocation,source_file=arguments.stObject[arguments.stMetadata.name],dest_location="privatefiles") />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="onApproved" access="public" output="false" returntype="void" hint="Called from setData when an object's status is changed">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="previousStatus" type="string" required="true" hint="The previous status of the object" />
		
		<cfset var filepermission = 0 />
		<cfset var currentLocation = "" />
		
		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />

		<!--- An explicit ftLocation override pins the file; skip public/private movement. --->
		<cfif len(getLocationOverride(arguments.stMetadata))>
			<cfreturn />
		</cfif>

		<!--- Approved content should be moved to public if not secured --->
		<!--- ftSecure=true should not be moved --->
		<!--- anonymous access=false should not be moved --->
		<cfif len(arguments.stObject[arguments.stMetadata.name])>
			<cfset currentLocation = application.fc.lib.cdn.ioFindFile(locations="privatefiles,publicfiles",file=arguments.stObject[arguments.stMetadata.name]) />

			<cfif len(currentLocation) and currentLocation neq "publicfiles" and not isSecured(arguments.stObject,arguments.stMetadata)>
				<cfset application.fc.lib.cdn.ioMoveFile(source_location=currentLocation,source_file=arguments.stObject[arguments.stMetadata.name],dest_location="publicfiles") />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="onDelete" access="public" output="false" returntype="void" hint="Called from setData when an object is deleted">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var currentLocation = "" />
		<cfset var locationOverride = getLocationOverride(arguments.stMetadata) />
		<cfset var searchLocations = len(locationOverride) ? locationOverride : "privatefiles,publicfiles" />

		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />

		<cfif (not structkeyexists(arguments.stObject,"versionID") or not len(arguments.stObject.versionID)) and len(arguments.stObject[arguments.stMetadata.name])>
			<cfset currentLocation = application.fc.lib.cdn.ioFindFile(locations=searchLocations,file=arguments.stObject[arguments.stMetadata.name]) />

			<cfif len(currentLocation)>
				<cfset application.fc.lib.cdn.ioDeleteFile(location=currentLocation,file=arguments.stObject[arguments.stMetadata.name]) />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="onSecurityChange" returntype="void" access="public" output="false" hint="Performs any updates necessary for a security change">
		<cfargument name="changetype" type="string" required="true" hint="type | object" />
		<cfargument name="objectid" type="uuid" required="false" hint="Object being changed" />
		<cfargument name="stObject" type="struct" required="false" hint="Object being changed" />
		<cfargument name="typename" type="string" required="false" hint="Type of object being changed" />
		<cfargument name="farRoleID" type="uuid" required="true" hint="The objectid of the role" />
		<cfargument name="farPermissionID" type="uuid" required="true" hint="The objectid of the permission" />
		<cfargument name="oldRight" type="numeric" required="true" hint="The old status" />
		<cfargument name="newRight" type="numeric" required="true" hint="The new status" />
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var access = 0 />
		<cfset var stPermission = "" />
		<cfset var currentLocation = "" />
		<cfset var newLocation = "" />

		<!--- An explicit ftLocation override pins the file; skip public/private movement. --->
		<cfif len(getLocationOverride(arguments.stMetadata))>
			<cfreturn />
		</cfif>

		<cfif not structkeyexists(arguments,"stObject")>
			<cfset arguments.stObject = getData(objectid=arguments.objectid) />
		</cfif>
		
		<cfif len(arguments.stObject[arguments.stMetadata.name])>
			<!--- Check for the other permission --->
			<cfset stPermission = application.security.factory.permission.getData(objectid=arguments.farPermissionID) />
			<cfif changetype eq "type">
				<cfset access = arguments.newRight and application.security.checkPermission(object=arguments.stObject.objectid,role=arguments.farRoleID,permission=right(stPermission.shortcut,len(stPermission.shortcut)-len(arguments.stObject.typename))) />
			<cfelse><!--- changetype eq "object" --->
				<cfif arguments.newRight eq -1>
					<cfset access = 0 />
				<cfelse>
					<cfset access = 1 />
				</cfif>
				<cfset access = access and application.security.checkPermission(permission=stPermission.shortcut,type=arguments.stObject.typename,role=arguments.farRoleID) />
			</cfif>
			
			<cfif access eq 1>
				<cfset currentLocation = application.fc.lib.cdn.ioFindFile(locations="privatefiles,publicfiles",file=arguments.stObject[arguments.stMetadata.name]) />
				<cfset newLocation = "publicfiles" />
			<cfelse>
				<cfset currentLocation = application.fc.lib.cdn.ioFindFile(locations="publicfiles,privatefiles",file=arguments.stObject[arguments.stMetadata.name]) />
				<cfset newLocation = "privatefiles" />
			</cfif>
			
			<!--- If it is the anonymous role and the view permission that has changed, move the file --->
			<cfif len(currentLocation)
				and currentLocation neq newLocation
				and arguments.farRoleID eq application.security.factory.role.getID("anonymous") 
				and (
					( changetype eq "object" and stPermission.shortcut eq "View" ) or
					( changetype eq "type" and arguments.farPermissionID eq application.security.factory.permission.getTypePermission(arguments.stObject.typename,"View") )
				)>
				
				<cfset application.fc.lib.cdn.ioMoveFile(source_location=currentLocation,source_file=arguments.stObject[arguments.stMetadata.name],dest_location=newLocation) />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="onArchive" access="public" output="false" returntype="string" hint="Called from setData when an object is deleted">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="archiveID" type="uuid" required="true" hint="The ID of the new archive" />
		
		<cfset var currentLocation = "" />
		<cfset var archiveFile = "" />
		<cfset var locationOverride = getLocationOverride(arguments.stMetadata) />
		<cfset var searchLocations = len(locationOverride) ? locationOverride : "publicfiles,privatefiles" />

		<cfif len(arguments.stObject[arguments.stMetadata.name])>
			<cfset currentLocation = application.fc.lib.cdn.ioFindFile(locations=searchLocations,file=arguments.stObject[arguments.stMetadata.name]) />
			
			<cfif len(currentLocation)>
				<cfset archiveFile = "/#arguments.stObject.typename#/#arguments.archiveID#.#arguments.stMetadata.name#.#ListLast(arguments.stObject[arguments.stMetadata.name],'.')#" />
				
				<cfset application.fc.lib.cdn.ioCopyFile(source_location=currentLocation,source_file=arguments.stObject[arguments.stMetadata.name],dest_location="archive",dest_file=archiveFile) />
			</cfif>
		</cfif>
		
		<cfreturn archiveFile />
	</cffunction>
	
	<cffunction name="onRollback" access="public" output="false" returntype="string" hint="Called from setData when an object is deleted">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="archiveID" type="uuid" required="true" hint="The ID of the archive being rolled back" />
	
		<cfset var filepermission = "" />
		<cfset var archiveFile = "/#arguments.stObject.typename#/#arguments.archiveID#.#arguments.stMetadata.name#.#ListLast(arguments.stObject[arguments.stMetadata.name],'.')#" />
		<cfset var targetlocation = "" />
		<cfset var locationOverride = getLocationOverride(arguments.stMetadata) />

		<cfparam name="arguments.stMetadata.ftSecure" default="false" />

		<cfif len(locationOverride)>
			<!--- An explicit ftLocation override pins the file. --->
			<cfset targetlocation = locationOverride />
		<cfelse>
			<sec:CheckPermission objectid="#arguments.stObject.objectid#" type="#arguments.typename#" permission="View" roles="Anonymous" result="filepermission" />
			<cfif arguments.stMetadata.ftSecure eq "false" and (not structkeyexists(arguments.stObject,"status") or arguments.stObject.status eq "approved") and filepermission>
				<cfset targetlocation = "publicfiles" />
			<cfelse>
				<cfset targetlocation = "privatefiles" />
			</cfif>
		</cfif>
		
		<cfreturn application.fc.lib.cdn.ioMoveFile(source_location="archive",source_file=archiveFile,dest_location=targetlocation,dest_file=arguments.stObject[arguments.stMetadata.name]) />
	</cffunction>
	
	
	<cffunction name="getFileLocation" access="public" output="false" returntype="struct" hint="Returns information used to access the file: type (stream | redirect), path (file system path | absolute URL), filename, mime type">
		<cfargument name="objectid" type="string" required="false" default="" hint="Object to retrieve" />
		<cfargument name="typename" type="string" required="false" default="" hint="Type of the object to retrieve" />
		<!--- OR --->
		<cfargument name="stObject" type="struct" required="false" hint="Provides the object" />
		
		<cfargument name="stMetadata" type="struct" required="false" hint="Property metadata" />
		<cfargument name="firstLook" type="string" required="false" hint="Where should we look for the file first. The default is to look based on permissions and status" />
		<cfargument name="bRetrieve" type="boolean" required="false" default="true" />

		<cfset var stResult = structnew() />
		<cfset var locationOverride = getLocationOverride(arguments.stMetadata) />

		<!--- Throw an error if the field is empty --->
		<cfif NOT len(arguments.stObject[arguments.stMetadata.name])>
			<cfset stResult = structnew() />
			<cfset stResult.method = "none" />
			<cfset stResult.path = "" />
			<cfset stResult.error = "No file defined" />
			<cfreturn stResult />
		</cfif>

		<cfif len(locationOverride)>
			<cfset stResult = application.fc.lib.cdn.ioGetFileLocation(location=locationOverride,file=arguments.stObject[arguments.stMetadata.name], bRetrieve=arguments.bRetrieve) />
		<cfelseif isSecured(stObject=arguments.stObject,stMetadata=arguments.stMetadata)>
			<cfset stResult = application.fc.lib.cdn.ioGetFileLocation(location="privatefiles",file=arguments.stObject[arguments.stMetadata.name], bRetrieve=arguments.bRetrieve) />
		<cfelse>
			<cfset stResult = application.fc.lib.cdn.ioGetFileLocation(location="publicfiles",file=arguments.stObject[arguments.stMetadata.name], bRetrieve=arguments.bRetrieve) />
		</cfif>

		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="checkFileLocation" access="public" output="false" returntype="struct" hint="Checks that the location of the specified file is correct (i.e. privatefiles vs publicfiles)">
		<cfargument name="objectid" type="string" required="false" default="" hint="Object to retrieve" />
		<cfargument name="typename" type="string" required="false" default="" hint="Type of the object to retrieve" />
		<!--- OR --->
		<cfargument name="stObject" type="struct" required="false" hint="Provides the object" />
		
		<cfargument name="stMetadata" type="struct" required="false" hint="Property metadata" />
		
		
		<cfset var stResult = structnew() />
		<cfset var locationOverride = getLocationOverride(arguments.stMetadata) />

		<!--- Throw an error if the field is empty --->
		<cfif NOT len(arguments.stObject[arguments.stMetadata.name])>
			<cfset stResult = structnew() />
			<cfset stResult.error = "No file defined" />
			<cfreturn stResult />
		</cfif>

		<cfif len(locationOverride)>
			<cfset stResult.correctlocation = locationOverride />
			<cfset stResult.currentlocation = application.fc.lib.cdn.ioFindFile(locations=locationOverride,file=arguments.stObject[arguments.stMetadata.name]) />
		<cfelseif isSecured(stObject=arguments.stObject,stMetadata=arguments.stMetadata)>
			<cfset stResult.correctlocation = "privatefiles" />
			<cfset stResult.currentlocation = application.fc.lib.cdn.ioFindFile(locations="privatefiles,publicfiles",file=arguments.stObject[arguments.stMetadata.name]) />
		<cfelse>
			<cfset stResult.correctlocation = "publicfiles" />
			<cfset stResult.currentlocation = application.fc.lib.cdn.ioFindFile(locations="publicfiles,privatefiles",file=arguments.stObject[arguments.stMetadata.name]) />
		</cfif>

		<cfset stResult.correct = stResult.correctlocation eq stResult.currentlocation />
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="getLocationOverride" access="private" output="false" returntype="string" hint="Returns the explicit ftLocation override for this field, or an empty string when none is set. When set, the file is pinned to that CDN location and the public/private status movement is bypassed.">
		<cfargument name="stMetadata" type="struct" required="true" hint="Property metadata" />

		<cfif structKeyExists(arguments.stMetadata,"ftLocation") and len(arguments.stMetadata.ftLocation)>
			<cfreturn arguments.stMetadata.ftLocation />
		</cfif>
		<cfreturn "" />
	</cffunction>

	<cffunction name="isSecured" access="private" output="false" returntype="boolean" hint="Encapsulates the security check on the file">
		<cfargument name="stObject" type="struct" required="false" hint="Provides the object" />
		<cfargument name="stMetadata" type="struct" required="false" hint="Property metadata" />

		<cfset var filepermission = false />
		
		
		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
		
		<sec:CheckPermission objectid="#arguments.stObject.objectid#" type="#arguments.stObject.typename#" permission="View" roles="Anonymous" result="filepermission" />
		<cfparam name="arguments.stMetadata.ftSecure" default="false" />
		<cfif arguments.stMetadata.ftSecure eq "false" and (not structkeyexists(arguments.stObject,"status") or arguments.stObject.status eq "approved") and filepermission>
			<cfreturn false />
		<cfelse>
			<cfreturn true />
		</cfif>
	</cffunction>
	
	<cffunction name="duplicateFile" access="public" output="false" returntype="string" hint="For use with duplicateObject, copies the associated file and returns the new unique filename">
		<cfargument name="stObject" type="struct" required="false" hint="Provides the object" />
		<cfargument name="stMetadata" type="struct" required="false" hint="Property metadata" />
		
		<cfset var currentfilename = arguments.stObject[arguments.stMetadata.name] />
		<cfset var currentlocation = "" />
		<cfset var locationOverride = getLocationOverride(arguments.stMetadata) />
		<cfset var searchLocations = len(locationOverride) ? locationOverride : "privatefiles,publicfiles" />

		<cfif not len(currentfilename)>
			<cfreturn "" />
		</cfif>

		<cfset currentlocation = application.fc.lib.cdn.ioFindFile(locations=searchLocations,file=currentfilename) />

		<cfif not len(currentlocation)>
			<cfreturn "" />
		</cfif>

		<cfif len(locationOverride)>
			<cfreturn application.fc.lib.cdn.ioCopyFile(source_location=currentlocation,source_file=currentfilename,dest_location=locationOverride,dest_file=currentfilename,nameconflict="makeunique",uniqueamong=locationOverride) />
		<cfelseif isSecured(arguments.stObject,arguments.stMetadata)>
			<cfreturn application.fc.lib.cdn.ioCopyFile(source_location=currentlocation,source_file=currentfilename,dest_location="privatefiles",dest_file=currentfilename,nameconflict="makeunique",uniqueamong="privatefiles,publicfiles") />
		<cfelse>
			<cfreturn application.fc.lib.cdn.ioCopyFile(source_location=currentlocation,source_file=currentfilename,dest_location="publicfiles",dest_file=currentfilename,nameconflict="makeunique",uniqueamong="privatefiles,publicfiles") />
		</cfif>
	</cffunction>
	
</cfcomponent> 
