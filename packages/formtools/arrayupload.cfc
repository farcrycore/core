<cfcomponent displayname="Array Upload" 
	extends="farcry.core.packages.formtools.field"
	hint="A cross between the array and image formtools; designed for use on the front-end. Consider bulk upload options on array for the webtop." output="false">

	<cfproperty name="ftlibrarydatasqlwhere" required="false" default=""
		hint="A simple where clause filter for the library data result set. Must be in the form PROPERTY OPERATOR VALUE. For example, status = 'approved'">

	<cfproperty name="ftJoin" required="true" default="" 
		options="comma separated list of types"
		hint="A single related content type e.g 'dmImage'">

	<cfproperty name="ftAllowCreate" required="false" default="true" 
		options="true,false"
		hint="Allows user create new record within the library picker">

	<cfproperty name="ftAllowEdit" required="false" default="false" 
		options="true,false"
		hint="Allows user edit new record within the library picker">

	<cfproperty name="ftAllowRemove" required="false" default="true"
		options="true,false"
		hint="Allows user to remove individual items. Set false to hide the per-item remove control.">

	<cfproperty name="ftAllowRemoveAll" required="false" default="false"
		options="true,false"
		hint="Allows user to remove all items at once">

	<cfproperty name="ftRemoveType" required="false" default="remove"
		options="remove,delete,detach"
		hint="remove/detach will only remove from the join, delete will remove from the database">

	<cfproperty name="ftFileProperty" required="false" default=""
		hint="The property on the related type that the file is uploaded against. This defaults to sourceImage for dmImage and filename for dmFile. Other relationships must have an explicit value.">

	<cfproperty name="ftAllowedFileExtensions" required="false" default=""
		hint="The list of file extensions allowed. The default is to borrow the attribute on the related file property.">

	<cfproperty name="ftSizeLimit" required="false" default=""
		hint="The upload size limit. The default is to borrow the attribute on the related file property.">

	<cfproperty name="ftSimUploadLimit" required="false" default="1"
		hint="The maximum number of simultaneous uploads.">

	<cfproperty name="ftEditableProperties" required="false" default=""
		hint="If ftAllowEdit is enabled, this property restricts which properties are ediable. Note that using this value will switch the default edit dialog to a minimalist one suitable for front end use.">

	<cfproperty name="ftAllowSelect" required="false" default="true" 
		options="true,false"
		hint="Allows user to select existing records within the library picker">

	<cfproperty name="ftlibrarydatasqlorderby" required="false" default="datetimelastupdated desc"
		hint="Nominate a specific property to order library results by.">

	<cfproperty name="ftView" type="string" default="list" 
		options="tiled,list"
		hint="Allows the formtool to be switched between the traditional list view of normal array fields and a tiled view appropriate for images.">

	<cfproperty name="ftTileWidth" type="numeric" default="100"
		hint="Width of item tile">

	<cfproperty name="ftTileHeight" type="numeric" default="100"
		hint="Height of item tile">

	<cfproperty name="ftListWebskin" type="string" default="librarySelected"
		hint="The webskin to use for items displayed in the form">

	<cfproperty name="ftLibrarySelectedWebskin" type="string" default="librarySelected"
		hint="The webskin to use for items displayed in the library picker">

	<cfproperty name="ftLibraryListItemWidth" type="string" default=""
		hint="???">

	<cfproperty name="ftLibraryListItemHeight" type="string" default=""
		hint="???">

	<cfproperty name="ftFirstListLabel" default="-- SELECT --"
		hint="Used with ftRenderType, this is the value of the first element in the list">

	<cfproperty name="ftLibraryData" default=""
		hint="Name of a function to return the library data. By default will look for ./webskin/typename/librarySelected.cfm">

	<cfproperty name="ftLibraryDataTypename" default=""
		hint="Typename containing the function defined in ftLibraryData">

	
	<cffunction name="init" access="public" returntype="any" output="false" hint="Returns a copy of this initialised object">
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="This is going to called from ft:object and will always be passed 'typename,stobj,stMetadata,fieldname'.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="stPackage" required="true" type="struct" hint="Contains the metadata for the all fields for the current typename.">
				
		<cfset var stActions = structNew() />
		<cfset var htmlLabel = "" />
		<cfset var joinItems = "" />
		<cfset var i = "" />
		<cfset var counter = "" />
		<cfset var returnHTML = "" />
		<cfset var factoryScript = "" />
		<cfset var uploadAjaxURL = "" />
		<cfset var fieldToken = "" />
		<cfset var qArrayField = "" />
	    <cfset var prefix = left(arguments.fieldname,len(arguments.fieldname)-len(arguments.stMetadata.name)) />
	    <cfset var uploadLocation = "" />
	    <cfset var storageType = "local" />
	    <cfset var allowedExtsDisplay = "" />
	    <cfset var maxSizeText = "" />
	    <cfset var stJoinRestrict = "" />

	    <cfif not listlen(arguments.stMetadata.ftJoin) eq 1>
			<cfthrow message="One related type must be specified in the ftJoin attribute" />
		</cfif>
	    <cfif not len(arguments.stMetadata.ftFileProperty)>
			<cfif arguments.stMetadata.ftJoin eq "dmImage">
				<cfset arguments.stMetadata.ftFileProperty = "sourceImage" />
			<cfelseif arguments.stMetadata.ftJoin eq "dmFile">
				<cfset arguments.stMetadata.ftFileProperty = "filename" />
			<cfelse>
				<cfthrow message="ftFileProperty is a required attribute" />
			</cfif>
		</cfif>
	    <!--- inherit restrictions from the joined file property (ftType-aware; COAPI has merged in the formtool defaults). an explicit override on the arrayupload field still wins. --->
	    <cfset stJoinRestrict = resolveJoinUploadRestrictions(arguments.stMetadata) />
	    <cfif not len(arguments.stMetadata.ftAllowedFileExtensions)>
			<cfset arguments.stMetadata.ftAllowedFileExtensions = stJoinRestrict.extensions />
		</cfif>
	    <cfif not len(arguments.stMetadata.ftSizeLimit)>
			<cfset arguments.stMetadata.ftSizeLimit = stJoinRestrict.sizeLimit />
		</cfif>

		<!--- Constraint caption values: short ext list (full list goes in a tooltip) and
		      a human-readable max size (ftSizeLimit is bytes, like file.cfc's ftMaxSize). --->
		<cfset allowedExtsDisplay = ucase(replace(arguments.stMetadata.ftAllowedFileExtensions, ",", ", ", "all")) />
		<cfif val(arguments.stMetadata.ftSizeLimit) gt 0>
			<cfset maxSizeText = application.fapi.humanFileSize(val(arguments.stMetadata.ftSizeLimit)) />
		</cfif>

		<!--- Pick the uploader transport from the joined file property's CDN location:
		      direct-to-S3 for an S3 bucket, else local XHR. The location is resolved
		      the same way the ajax() upload / finalize branches resolve it (ftLocation
		      wins for both types; else image->images, file->publicfiles/privatefiles by ftSecure). --->
		<cfset uploadLocation = resolveJoinUploadLocation(arguments.stMetadata) />
		<cfset storageType = application.fc.lib.cdn.getLocationType(uploadLocation) />

		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
		<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
		
		
		<!--- SETUP stActions --->
		<cfset stActions.ftAllowSelect = arguments.stMetadata.ftAllowSelect />
		<cfset stActions.ftAllowCreate = arguments.stMetadata.ftAllowCreate />
		<cfset stActions.ftAllowEdit = arguments.stMetadata.ftAllowEdit />
		<cfset stActions.ftAllowRemove = arguments.stMetadata.ftAllowRemove />
		<cfset stActions.ftRemoveType = arguments.stMetadata.ftRemoveType />

		<cfif structKeyExists(arguments.stMetadata, "ftAllowAttach")>
			<cfset stActions.ftAllowSelect = arguments.stMetadata.ftAllowAttach />
		</cfif>
		<cfif structKeyExists(arguments.stMetadata, "ftAllowAdd")>
			<cfset stActions.ftAllowCreate = arguments.stMetadata.ftAllowAdd />
		</cfif>
		<cfif arguments.stMetadata.ftRemoveType EQ "detach">
			<cfset stActions.ftRemoveType = "remove" />
		</cfif>
		
		
		<cfif arguments.stMetadata.type EQ "array">		
			<cfset joinItems = arguments.stObject[arguments.stMetadata.name] />
		<cfelse>
			<cfset joinItems = listtoarray(arguments.stObject[arguments.stMetadata.name]) />
		</cfif>
		
		
		<skin:loadJS id="fc-jquery" />
		<skin:loadJS id="fc-jquery-ui" />
		<skin:loadCSS id="jquery-ui" />
	    <skin:loadJS id="fc-uppy" />
	    <skin:loadJS id="fc-uploader" />
		<skin:loadJS id="jquery-modal" />
		<skin:loadCSS id="jquery-modal" />
		<skin:loadCSS id="fc-fontawesome" />
		<skin:loadCSS id="uploader" />
	    
		<!--- Capture the factory so it ships inside returnHTML (a <skin:loadJS> page zone
		      isn't re-emitted in AJAX modals). Guarded so repeat emits are no-ops. --->
		<cfsavecontent variable="factoryScript"><cfoutput><script type="text/javascript">
			if (typeof $fc.arrayuploadformtool !== "function") {
			(function($){
				if (!fcForm.arrayuploadwrapped){
					fcForm.arrayuploadwrapped = true;
					fcForm.editing = "";
					
					fcForm.traditionalOpenLibrarySelect = fcForm.openLibrarySelect;
					fcForm.openLibrarySelect = function(typename,objectid,property,id,urlparameters) {
						if (fcForm.arrayuploadfields[id]) fcForm.arrayuploadfields[id].beginSelect();
						fcForm.traditionalOpenLibrarySelect(typename,objectid,property,id,urlparameters);
					};

					// Create (ftAllowCreate): the displayLibraryAdd modal appends the new
					// objectid to the #fieldname# hidden input then triggers refreshProperty,
					// which routes to finishSelect() below. Seed beforeSelect first (exactly
					// as openLibrarySelect does) so the diff sees only the new id as an add
					// and doesn't mistake the existing rows for removals. editing is cleared
					// since Create never edits an existing item.
					fcForm.traditionalOpenLibraryAdd = fcForm.openLibraryAdd;
					fcForm.openLibraryAdd = function(typename,objectid,property,id) {
						if (fcForm.arrayuploadfields[id]) {
							fcForm.editing = "";
							fcForm.arrayuploadfields[id].beginSelect();
						}
						fcForm.traditionalOpenLibraryAdd(typename,objectid,property,id);
					};

					fcForm.traditionalRefreshProperty = fcForm.refreshProperty;
					fcForm.refreshProperty = function(typename,objectid,property,id) {
						if (fcForm.arrayuploadfields[id]) return fcForm.arrayuploadfields[id].finishSelect(fcForm.editing);
						fcForm.traditionalRefreshProperty(typename,objectid,property,id);
					};
					
					fcForm.traditionalOpenLibraryEdit = fcForm.openLibraryEdit;
					fcForm.openLibraryEdit = function(typename,objectid,property,id,editid) {
						if (fcForm.arrayuploadfields[id]) fcForm.editing = editid;
						fcForm.traditionalOpenLibraryEdit(typename,objectid,property,id,editid);
					};
				};
				
				$fc.arrayuploadformtool = function arrayuploadFormtoolObject(prefix,property){
					var regexes = {};
					
		    		function ArrayUploadFormtool(prefix,property) {
		    			var arrayuploadformtool = this;
		    			this.prefix = prefix;
		    			this.property = property;
		    			this.elements = {};
		    			// The quick-edit modal this field opened, once it has. openModal appends it
		    			// to body, so it is not inside the field and cannot be reached from it.
		    			this.modal = $();
		    			
		    			function getBytesOutput(bytes){
							bytes = Number(bytes) || 0;
							if (bytes <= 0) return "";
							var units = ["B","KB","MB","GB","TB"];
							var i = Math.floor(Math.log(bytes) / Math.log(1024));
							if (i >= units.length) i = units.length - 1;
							var v = bytes / Math.pow(1024, i);
							return (i === 0 ? Math.round(v) : v.toFixed(1)) + " " + units[i];
		    			};
		    			
		    			function getFilenameOutput(filename){
							if (filename.length > 20) return filename.substr(0,20) + '...';
							return filename;
		    			};

		    			// Row feedback: the styled span is built here and the message goes in as
		    			// text. Messages carry server exception text and HTTP response snippets.
		    			function showItemError(errorloc,message){
		    				errorloc.empty().append($("<span></span>").addClass("fc-uploader-error-text").text(message));
		    			};

		    			// These rows carry no feedback area, so a server refusal goes in the
		    			// same dialog the confirms use.
		    			function showActionError(message){
		    				$fc.uploader.confirm({
		    					title: "Unable to complete",
		    					message: message || "The request could not be completed.",
		    					buttons: [ { label: "OK", value: "ok", style: "primary", isCancel: true } ]
		    				});
		    			};

		    			// These actions post outside the enclosing form and carry the field's own
		    			// token, issued by the render. Nothing is read out of the DOM, so it does
		    			// not matter which tag drew the form or how the field was injected.
		    			function getRequestToken(){
		    				return arrayuploadformtool.token ? { FarcryFormToken: arrayuploadformtool.token } : {};
		    			};
		    			
		    			this.init = function initArrayUploadFormtool(typename,objectid,url,filetypes,sizeLimit,uploadLimit,allowEdit,allowRemove,removeType,quickEdit,view,tilewidth,tileheight,storage,token){
		    				var fieldname = prefix + property;
							arrayuploadformtool.displaylist = $("##join-"+objectid+"-"+property);
							arrayuploadformtool.fileInput = $("##"+fieldname+"UPLOAD");
							arrayuploadformtool.typename = typename;
							arrayuploadformtool.objectid = objectid;
							arrayuploadformtool.url = url;
							arrayuploadformtool.filetypes = filetypes;
							arrayuploadformtool.sizeLimit = sizeLimit;
							arrayuploadformtool.allowEdit = allowEdit;
							arrayuploadformtool.allowRemove = allowRemove;
							arrayuploadformtool.removeType = removeType;
							arrayuploadformtool.beforeSelect = [];
							arrayuploadformtool.pendingSelect = false;
							arrayuploadformtool.quickEdit = quickEdit;
							arrayuploadformtool.storage = storage;
							arrayuploadformtool.token = token;
		    				
		    				if (view=="tiled")
								arrayuploadformtool.displaylist.sortable({ items:'li.sort', forceHelperSize:true, forcePlaceholderSize:true, tolerance:"pointer" });
		    				else
								arrayuploadformtool.displaylist.sortable({ items:'li.sort', axis:"y" });
							
							fcForm.arrayuploadfields = fcForm.arrayuploadfields || {};
							fcForm.arrayuploadfields[prefix+property] = arrayuploadformtool;

							// Map Uppy file IDs → local sequential numbers so existing template
							// markup and CSS selectors (which assume short, selector-safe IDs) keep working.
							arrayuploadformtool.idMap = {};
							arrayuploadformtool.idCounter = 0;

							// Items attached since this render, which the relationship does not
							// hold yet. Cleared by the save, which re-renders the field.
							arrayuploadformtool.unsaved = {};

				    		arrayuploadformtool.uploader = $fc.uploader.create({
								fileInput:           arrayuploadformtool.fileInput,
								fieldName:           property+"UPLOAD",
								endpoint:            url+"/upload/1",
								storage:             arrayuploadformtool.storage,
								allowedFileTypes:    filetypes,
								maxFileSize:         sizeLimit,
								simultaneousUploads: uploadLimit,
								autoProceed:         true,
								dropZone:            "##"+fieldname+"-dropzone",
								onDragEnter: function(){ $("##"+fieldname+"-dropzone").addClass("is-dragover"); },
								onDragLeave: function(){ $("##"+fieldname+"-dropzone").removeClass("is-dragover"); },
								extraFormData: function(){
									return arrayuploadformtool.getPostValues();
								},
								onSelect: function(file){
									arrayuploadformtool.idCounter += 1;
									var ID = arrayuploadformtool.idCounter;
									arrayuploadformtool.idMap[file.id] = ID;
									arrayuploadformtool.displaylist.append(arrayuploadformtool.getHTML("uploaditem",{
										index 		: ($("> li",arrayuploadformtool.displaylist).size() + 1).toString(),
										ID 			: ID,
										filename	: getFilenameOutput(file.name),
										filesize	: getBytesOutput(file.size)
									}));
									arrayuploadformtool.displaylist.sortable("refresh");
								},
								onProgress: function(file, percent){
									var ID = arrayuploadformtool.idMap[file.id];
									if (ID == null) return;
									if (percent < 100)
										$("##"+fieldname+ID+"ProgressBar").animate({'width': percent + '%'},250);
									else
										$("##join-item-#arguments.stMetadata.name#-"+ID+" .fc-arrayupload-feedback",arrayuploadformtool.displaylist).html('<span class="fc-uploader-pill fc-uploader-pill--uploading">Processing&hellip;</span>');
								},
								onComplete: function(file, results){
									var ID = arrayuploadformtool.idMap[file.id];
									if (ID == null) return;
									if (arrayuploadformtool.uploader) arrayuploadformtool.uploader.cancel(file.id);
									delete arrayuploadformtool.idMap[file.id];

									if (results.error && results.error.length){
										showItemError($("##join-item-#arguments.stMetadata.name#-"+ID+" .fc-arrayupload-feedback",arrayuploadformtool.displaylist),"Server error: "+results.error);
									}
									else {
										arrayuploadformtool.unsaved[itemKey(results.objectid)] = true;
										$("##join-item-#arguments.stMetadata.name#-"+ID,arrayuploadformtool.displaylist).replaceWith(arrayuploadformtool.getHTML("newitem",{
											itemid		: results.objectid,
											displayhtml : results.html
										}));
									};
								},
								onError: function(file, error){
									var ID = (file && arrayuploadformtool.idMap[file.id]) || null;
									if (file && arrayuploadformtool.uploader) {
										arrayuploadformtool.uploader.cancel(file.id);
										delete arrayuploadformtool.idMap[file.id];
									}
									if (ID == null) return;
									var errorloc = $("##join-item-#arguments.stMetadata.name#-"+ID+" .fc-arrayupload-feedback",arrayuploadformtool.displaylist);
									if (error.type === "http")
										showItemError(errorloc,"HTTP error: "+(error.status||""));
									else if (error.type === "size")
										showItemError(errorloc,"File size: File is not within the file size limit of "+getBytesOutput(sizeLimit));
									else if (error.type === "type")
										showItemError(errorloc,"File type: "+error.message);
									else if (error.type === "network")
										showItemError(errorloc,"Network error: "+error.message);
									else
										showItemError(errorloc,(error.type||"server")+": "+error.message);
								}
							});
							
							$("> li",arrayuploadformtool.displaylist).on("mouseover",function(e){
								$(this).addClass("fc-grabbable");
							}).on("mouseout",function(e){
								$(this).removeClass("fc-grabbable");
							});

		    			};
		    			
		    			this.getPostValues = function imageFormtoolGetPostValues(){
							// get the post values
							var values = {};
							$('[name^="'+prefix+property+'"]').each(function(){ if (this.name!=prefix+property+"UPLOAD") values[this.name.slice(prefix.length)]=""; });
							values = getValueData(values,prefix);
							
							return values;
		    			};
		    			
		    			// A template value lands in markup, so it is escaped on the way in.
		    			// displayhtml is the one exception: it IS the server-rendered webskin
		    			// for the item, so it stays markup (see rawvars in getHTML).
		    			// An objectid is only ever alphanumerics and dashes.
		    			function itemKey(id){
		    				return String(id).replace(/[^A-Za-z0-9_\-]/g,"");
		    			};

		    			function escapeTemplateValue(value){
		    				if (value === null || value === undefined) return "";
		    				return String(value)
		    					.replace(/&/g,"&amp;")
		    					.replace(/</g,"&lt;")
		    					.replace(/>/g,"&gt;")
		    					.replace(/"/g,"&quot;")
		    					.replace(/'/g,"&##39;");
		    			};

		    			this.getHTML = function(templateid,tempvars){
		    				var html = $.trim($("##"+templateid+"-"+prefix+property+", ##"+templateid).html());
		    				var rawvars = { displayhtml:true };

		    				// {{itemid}} names a content object and lands in element ids, an input
		    				// value and the inline handlers, so it is held to an identifier shape
		    				// rather than escaped for one of them: an objectid is only ever
		    				// alphanumerics and dashes.
		    				if ("itemid" in tempvars) tempvars.itemid = itemKey(tempvars.itemid);

		    				// A row added since this render is not in the relationship yet - the join
		    				// is written on save - so it gets the controls that work on an unattached
		    				// record: no quick-edit, no delete, plain remove. The library edit modal
		    				// is unaffected.
		    				var pending = ("itemid" in tempvars) && !!arrayuploadformtool.unsaved[tempvars.itemid];

		    				$.extend(tempvars,{
		    					typename 		: arrayuploadformtool.typename,
		    					objectid 		: arrayuploadformtool.objectid,
		    					url 			: arrayuploadformtool.url,
		    					prefix 			: prefix,
		    					property 		: property,
		    					fieldname 		: prefix+property,
								allowedit		: arrayuploadformtool.allowEdit && !(pending && arrayuploadformtool.quickEdit),
								allowremove		: arrayuploadformtool.allowRemove && (arrayuploadformtool.removeType!="delete" || pending),
								allowdelete		: arrayuploadformtool.allowRemove && arrayuploadformtool.removeType=="delete" && !pending,
								quickedit		: arrayuploadformtool.quickEdit
		    				});
		    				
		    				for (var k in tempvars){
		    					if (!(k in regexes)) {
		    						regexes[k] = new RegExp("\x7B\x7B"+k+"\x7D\x7D","ig");
		    						regexes[k+"-ifthen"] = new RegExp("\x7B\x7Bif-"+k+"\x7D\x7D(.*?)\x7B\x7Bif-"+k+"\x7D\x7D","ig");
		    						regexes[k+"-ifnot"] = new RegExp("\x7B\x7Bifnot-"+k+"\x7D\x7D(.*?)\x7B\x7Bifnot-"+k+"\x7D\x7D","ig");
		    					}
		    					html = html.replace(regexes[k+"-ifthen"],tempvars[k] ? "$1" : "");
			    				html = html.replace(regexes[k+"-ifnot"],tempvars[k] ? "" : "$1");
		    					// replacer function, not a string: a value is inserted verbatim
		    					// rather than being read for $1 / $& substitution patterns
		    					html = html.replace(regexes[k],(function(v){ return function(){ return v; }; })(rawvars[String(k).toLowerCase()] ? tempvars[k] : escapeTemplateValue(tempvars[k])));
		    				}
		    				
		    				return html;
		    			};
		    			
		    			this.addItems = function(objectids){
							$j.ajax({
								cache: false,
								type: "POST",
					 			url: arrayuploadformtool.url+"/add/1",
								data: { 
									items:objectids.join(","),
									startindex:$("> li",arrayuploadformtool.displaylist).size()
								},
								dataType: "json",
								success: function(data){
									for (var i=0;i<data.length;i++){
										arrayuploadformtool.unsaved[itemKey(data[i].objectid)] = true;
									}
									for (var i=0;i<data.length;i++)
										arrayuploadformtool.displaylist.append(arrayuploadformtool.getHTML("newitem",{
											itemid		: data[i].objectid,
											displayhtml : data[i].html
										}));
									arrayuploadformtool.displaylist.sortable("refresh");
								}
							});
		    			};
		    			
		    			function dropRows(objectids){
		    				for (var i=0;i<objectids.length;i++){
		    					$("##join-item-#arguments.stMetadata.name#-"+objectids[i],arrayuploadformtool.displaylist).remove();
		    					delete arrayuploadformtool.unsaved[itemKey(objectids[i])];
		    				}
		    				if (objectids.length) arrayuploadformtool.displaylist.sortable("refresh");
		    			};

		    			this.removeItems = function(objectids){
		    				// An unsaved row is not in the relationship, so there is nothing joined
		    				// to delete; it just comes out of the list.
		    				var pending = [], attached = [];
		    				for (var i=0;i<objectids.length;i++){
		    					(arrayuploadformtool.unsaved[itemKey(objectids[i])] ? pending : attached).push(objectids[i]);
		    				}
		    				dropRows(pending);
		    				if (!attached.length) return;

		    				if (arrayuploadformtool.removeType=="delete"){
								$j.ajax({
									cache: false,
									type: "POST",
						 			url: arrayuploadformtool.url+"/delete/1",
									data: $.extend({
										items:attached.join(",")
									},getRequestToken()),
									dataType: "json",
									// Rows come out when the server confirms the delete, not before.
									success: function(data){
										if (data && data.error){ showActionError(data.error); return; }
										dropRows(attached);
									},
									error: function(){ showActionError("The item could not be deleted."); }
								});
		    				}
		    				else {
		    					dropRows(attached);
		    				};
		    			};
		    			
		    			this.removeAllItems = function(){
		    				arrayuploadformtool.removeItems(arrayuploadformtool.getSelected());
		    			};

		    			// Styled, framework-agnostic confirm (matches the file/image
		    			// uploaders) in place of the old native confirm() prompt. The
		    			// primary action is blue, not red.
		    			this.confirmRemove = function(itemid){
		    				// an unsaved row is unlinked, not deleted, so it gets the unlink wording
		    				var isDelete = arrayuploadformtool.removeType == "delete" && !arrayuploadformtool.unsaved[itemKey(itemid)];
		    				$fc.uploader.confirm({
		    					title: isDelete ? "Delete item" : "Remove item",
		    					message: isDelete
		    						? "Are you sure you want to delete this item? Doing so will immediately remove this item from the database."
		    						: "Are you sure you want to remove this item? Doing so will only unlink this content item. The content will remain in the database.",
		    					buttons: [
		    						{ label: isDelete ? "Delete" : "Remove", value: "remove", style: "primary" },
		    						{ label: "Cancel", value: "cancel", isCancel: true }
		    					],
		    					onSelect: function(value){
		    						if (value != "remove") return;
		    						// this dialog restored focus to the control that opened it, and that
		    						// control is inside the row about to go. Let go of focus first, so
		    						// the browser is not reassigning it out of a removed node - which
		    						// lands it on whatever is focusable next and scrolls that into view.
		    						if (document.activeElement && document.activeElement.blur) document.activeElement.blur();
		    						arrayuploadformtool.removeItems([ itemid ]);
		    					}
		    				});
		    			};

		    			// Remove All uses the same framework-agnostic confirm as the
		    			// per-item remove (the toolbar <a> lost the old native confirmText
		    			// when it became an icon button). Wording is delete-vs-unlink
		    			// depending on removeType, and operates on every attached item.
		    			this.confirmRemoveAll = function(){
		    				var isDelete = arrayuploadformtool.removeType == "delete";
		    				$fc.uploader.confirm({
		    					title: isDelete ? "Delete all items" : "Remove all items",
		    					message: isDelete
		    						? "Are you sure you want to delete all attached items? Doing so will immediately remove them from the database."
		    						: "Are you sure you want to remove all attached items? Doing so will only unlink them. The content will remain in the database.",
		    					buttons: [
		    						{ label: isDelete ? "Delete all" : "Remove all", value: "remove", style: "primary" },
		    						{ label: "Cancel", value: "cancel", isCancel: true }
		    					],
		    					onSelect: function(value){
		    						if (value != "remove") return;
		    						if (document.activeElement && document.activeElement.blur) document.activeElement.blur();
		    						arrayuploadformtool.removeAllItems();
		    					}
		    				});
		    			};

		    			this.refreshItems = function(objectids){
		    				var updated = 0;
		    				for (var i=0;i<objectids.length;i++){
		    					var thisid = objectids[i];
								$j.ajax({
									cache: false,
									type: "POST",
						 			url: arrayuploadformtool.url+"/add/1",
									data: { 
										items:thisid,
										startindex:$("> li",arrayuploadformtool.displaylist).size()
									},
									dataType: "json",
									success: function(data){
										for (var i=0;i<data.length;i++)
											$("##join-item-#arguments.stMetadata.name#-"+data[i].objectid,arrayuploadformtool.displaylist).replaceWith(arrayuploadformtool.getHTML("newitem",{
												itemid		: data[i].objectid,
												displayhtml : data[i].html
											}));
										updated += 1;
										if (updated == objectids.length) arrayuploadformtool.displaylist.sortable("refresh");
									}
								});
		    				}
		    			};
		    			
		    			this.editItem = function(objectid){
		    				$("##join-item-#arguments.stMetadata.name#-"+objectid+" .fc-edit").html("<img src='#application.url.webtop#/images/indicator.gif' />");
							$.ajax({
								cache: false,
								type: "POST",
					 			url: arrayuploadformtool.url+"/edit/1",
								data: $.extend({
									item:objectid
								},getRequestToken()),
								dataType: "html",
								success: function(data){
		    						$("##join-item-#arguments.stMetadata.name#-"+objectid+" .fc-edit").html("<i class='fa fa-pencil'></i>");
									$fc.openModal(data,"auto","auto",true);
									arrayuploadformtool.modal = $(".fc-overlaycontainer");
								},
								// A refusal comes back as markup and shows in the modal; this is for
								// the request not arriving at all.
								error: function(){
		    						$("##join-item-#arguments.stMetadata.name#-"+objectid+" .fc-edit").html("<i class='fa fa-pencil'></i>");
									showActionError("The item could not be opened for editing.");
								}
							});
		    			};
		    			
		    			this.saveItem = function(objectid,values){
		    				// Held so the buttons can go back if the save is refused. Taken from the
		    				// modal this field opened, so it cannot reach another field's modal or a
		    				// button panel on the page behind it. Empty until one is open, and empty
		    				// again once it closes, both of which are no-ops here.
		    				var buttons = arrayuploadformtool.modal.find(".buttonHolder");
		    				var buttonsHTML = buttons.html();
		    				buttons.html("<img src='#application.url.webtop#/images/indicator.gif' />");
		    				var d = { "_objectid":objectid,"startindex":0 };
		    				for (var k in values) d["_"+k] = values[k];
		    				$.extend(d,getRequestToken());
							$.ajax({
								cache: false,
								type: "POST",
					 			url: arrayuploadformtool.url+"/update/1",
								data: d,
								dataType: "json",
								success: function(data){
									if (!data || data.error){
										buttons.html(buttonsHTML);
										showActionError(data && data.error);
										return;
									}
									$("##join-item-#arguments.stMetadata.name#-"+data.objectid,arrayuploadformtool.displaylist).replaceWith(arrayuploadformtool.getHTML("newitem",{
										itemid		: data.objectid,
										displayhtml : data.html
									}));
									arrayuploadformtool.displaylist.sortable("refresh");
									$fc.closeModal();
								},
								error: function(){
									buttons.html(buttonsHTML);
									showActionError("The item could not be saved.");
								}
							});
		    			};
		    			
		    			this.getSelected = function(){
		    				var sel = [];
		    				$("input[name="+prefix+property+"]",arrayuploadformtool.displaylist).each(function(){
		    					sel.push(this.value);
		    				});
		    				return sel;
		    			};
		    			
		    			this.beginSelect = function beginSelect(){
		    				arrayuploadformtool.pendingSelect = true;
		    				arrayuploadformtool.beforeSelect = arrayuploadformtool.getSelected();
		    				$("##"+prefix+property).val(arrayuploadformtool.beforeSelect.join(","));
		    			};
		    			
		    			this.finishSelect = function finishSelect(editid){
		    				// refreshProperty fires after BOTH Select/Create (membership may change)
		    				// and Edit (only the row's rendered content changes). The add/remove diff
		    				// is meaningful ONLY when a Select/Create seeded it via beginSelect; on a
		    				// pure edit beforeSelect is stale and the scratch field is empty, so the
		    				// diff would misread every attached item as a removal. Gate it accordingly.
		    				if (arrayuploadformtool.pendingSelect) {
		    					var afterSelect = $("##"+prefix+property).val().split(",");
		    					var aAdd = [];
		    					var aRemove = [];
		    					for (var i=0;i<arrayuploadformtool.beforeSelect.length;i++){
		    						var stillSelected = false;
		    						for (var j=0;j<afterSelect.length;j++) stillSelected = stillSelected || afterSelect[j]==arrayuploadformtool.beforeSelect[i];
		    						if (!stillSelected)	aRemove.push(arrayuploadformtool.beforeSelect[i]);
		    					}
		    					if (aRemove.length) arrayuploadformtool.removeItems(aRemove);
		    					for (var i=0;i<afterSelect.length;i++){
		    						if ($("##join-item-#arguments.stMetadata.name#-"+afterSelect[i],arrayuploadformtool.displaylist).size()==0) aAdd.push(afterSelect[i]);
		    					}
		    					if (aAdd.length) arrayuploadformtool.addItems(aAdd);
		    					$("##"+prefix+property).val("");
		    					arrayuploadformtool.pendingSelect = false;
		    				}
		    				if (editid && editid.length) arrayuploadformtool.refreshItems([ editid ]);
		    			}

		    			this.cancelByLocalId = function arrayUploadCancelByLocalId(localId){
		    				localId = parseInt(localId, 10);
		    				for (var fid in arrayuploadformtool.idMap){
		    					if (arrayuploadformtool.idMap[fid] === localId){
		    						if (arrayuploadformtool.uploader) arrayuploadformtool.uploader.cancel(fid);
		    						delete arrayuploadformtool.idMap[fid];
		    						break;
		    					}
		    				}
		    				$("##join-item-#arguments.stMetadata.name#-"+localId,arrayuploadformtool.displaylist).remove();
		    			};

		    		};
		    		
		    		if (!this[prefix+property]) this[prefix+property] = new ArrayUploadFormtool(prefix,property);
		    		return this[prefix+property];
		    	};
			})(jQuery);
			}
		</script></cfoutput></cfsavecontent>
		<skin:loadCSS id="array-upload"><style type="text/css"><cfoutput>
			/* Bordered array-field panel: frames the item list, the add dropzone and the
			   action toolbar into one cohesive control (the s3arrayupload look, modern dropzone). */
				.fc-arrayupload-panel { border:1px solid ##dddddd; border-radius:3px; background:##ffffff; overflow:hidden; }
				/* Row separators come from forms.css (ul.arrayDetailView li { border-bottom });
				   the panel supplies the outer frame, so the list itself needs no border. */
				.fc-arrayupload-panel > ul.arrayDetailView { border:none; }
				/* Add dropzone sits inset within the panel, below any existing items. */
				.fc-arrayupload-dropzone { margin:10px; }
				/* Action toolbar rendered as a footer bar (Create / Select / Remove All). */
				.fc-arrayupload-toolbar { padding:8px 10px; background:##f5f5f5; border-top:1px solid ##e5e5e5; text-align:left; }
				/* Constraint caption sits just below the panel (outside its border). */
				.fc-arrayupload-constraints { margin:6px 0 0; }
				/* Modal-sized panel for a message returned in place of the edit form. */
				.fc-arrayupload-message { padding:15px; background:##ffffff; border:1px solid ##dddddd; border-radius:3px; }
					.fc-arrayupload-toolbar .btn { margin-right:4px; }
				.fc-arrayupload-item { zoom:1; }
				/* Drag handle: a quiet FontAwesome glyph (no image), tinted on row hover. */
				.fc-arrayupload-item .fc-grabbar { color:##cccccc; cursor:ns-resize; text-align:center; vertical-align:middle; }
					.fc-arrayupload-item .fc-grabbar .fa { font-size:14px; }
					.fc-grabbable .fc-grabbar { color:##999999; }
				/* Inline action links (edit / remove) reuse the shared icon-button look. */
				.fc-arrayupload-actions a, .fc-arrayupload-item .fc-edit, .fc-arrayupload-item .fc-remove { display:inline-block; padding:0 4px; color:##999999; font-size:16px; text-decoration:none; }
					.fc-arrayupload-actions a:hover, .fc-arrayupload-actions a:focus,
					.fc-arrayupload-item .fc-edit:hover, .fc-arrayupload-item .fc-edit:focus,
					.fc-arrayupload-item .fc-remove:hover, .fc-arrayupload-item .fc-remove:focus { color:##333333; outline:none; text-decoration:none; }
					.fc-arrayupload-item .fc-remove:hover, .fc-arrayupload-item .fc-remove:focus { color:##d2322d; }
				/* Progress: match the shared .fc-uploader-progress primitive. */
				.fc-arrayupload-progress { background:##e6e6e6; border-radius:2px; overflow:hidden; height:3px; margin-top:8px; }
					.fc-arrayupload-progress-bar { background:##3e84b5; height:3px; width:0; }
				.fc-list-view { clear:both; padding:8px; }
					.fc-list-view-container { width:100%; }
					.fc-list-view-table { width:100%; }
					.fc-list-view .fc-arrayupload-feedback { margin-top:4px; }
					.fc-list-view .fc-grabbar { width:22px; }
				.fc-tile-view { float:left; }
					.fc-tile-view .fc-tile-view-container { padding:10px; text-align:center; overflow:hidden; cursor:move; position:relative; }
						.fc-tile-view .fc-arrayupload-actions { position:absolute; top:4px; right:4px; }
					.fc-tile-view .fc-grabbar { position:absolute; top:4px; left:4px; }
		</cfoutput></style></skin:loadCSS>
	
		<cfsavecontent variable="returnHTML">	
			<grid:div class="multiField">
			
				<cfoutput><div class="fc-arrayupload-panel"><ul id="join-#stObject.objectid#-#arguments.stMetadata.name#" class="arrayDetailView" style="list-style-type:none;margin:0px;overflow:auto;"></cfoutput>
				
				<cfloop from="1" to="#arraylen(joinItems)#" index="i">
					<cfif arguments.stMetadata.ftView eq 'tiled'>
						<cfoutput>
							<li id="join-item-#arguments.stMetadata.name#-#joinItems[i]#" class="sort arrayupload-item fc-tile-view">
								<div class="fc-tile-view-container" style="width:#arguments.stMetadata.ftTileWidth#px;height:#arguments.stMetadata.ftTileHeight#px;">
									<div class="fc-grabbar" title="Drag to reorder"><i class="fa fa-sort"></i></div>
									<div class="fc-arrayupload-actions">
										<cfif stActions.ftAllowEdit>
											<a href="##" class="fc-edit" onclick="<cfif len(arguments.stMetadata.ftEditableProperties)>$fc.arrayuploadformtool('#prefix#','#arguments.stMetadata.name#').editItem('#encodeForJavaScript(joinItems[i])#');<cfelse>fcForm.openLibraryEdit('#encodeForJavaScript(arguments.typename)#','#encodeForJavaScript(arguments.stObject.objectid)#','#arguments.stMetadata.name#','#arguments.fieldname#','#encodeForJavaScript(joinItems[i])#');</cfif>return false;" title="Edit"><i class="fa fa-pencil"></i></a>
										</cfif>
										<cfif stActions.ftAllowRemove>
											<a href="##" class="fc-remove" onclick="$fc.arrayuploadformtool('#prefix#','#arguments.stMetadata.name#').confirmRemove('#encodeForJavaScript(joinItems[i])#');return false;" title="<cfif stActions.ftRemoveType EQ 'delete'>Delete<cfelse>Remove</cfif>"><i class="fa <cfif stActions.ftRemoveType EQ 'delete'>fa-trash-o<cfelse>fa-times</cfif>"></i></a>
										</cfif>
									</div>
									<input type="hidden" name="#arguments.fieldname#" value="#joinItems[i]#" />
									<skin:view objectid="#joinItems[i]#" typename="#arguments.stMetadata.ftJoin#" webskin="#arguments.stMetadata.ftListWebskin#" alternateHTML="OBJECT NO LONGER EXISTS" />
								</div>
							</li>
						</cfoutput>
					<cfelse>
						<cfoutput>
							<li id="join-item-#arguments.stMetadata.name#-#joinItems[i]#" class="sort fc-arrayupload-item fc-list-view">
								<div class="fc-list-view-container">
									<table class="fc-list-view-table">
										<tr>
											<td class="fc-grabbar" title="Drag to reorder"><i class="fa fa-sort"></i></td>
											<td class="" style="width:100%;padding:3px;"><input type="hidden" name="#arguments.fieldname#" value="#joinItems[i]#" />
												<skin:view objectid="#joinItems[i]#" typename="#arguments.stMetadata.ftJoin#" webskin="#arguments.stMetadata.ftListWebskin#" alternateHTML="OBJECT NO LONGER EXISTS" />
											</td>
											<td class="" style="padding:3px;white-space:nowrap;">
												<cfif stActions.ftAllowEdit>
													<a href="##" class="fc-edit" onclick="<cfif len(arguments.stMetadata.ftEditableProperties)>$fc.arrayuploadformtool('#prefix#','#arguments.stMetadata.name#').editItem('#encodeForJavaScript(joinItems[i])#');<cfelse>fcForm.openLibraryEdit('#encodeForJavaScript(arguments.typename)#','#encodeForJavaScript(arguments.stObject.objectid)#','#arguments.stMetadata.name#','#arguments.fieldname#','#encodeForJavaScript(joinItems[i])#');</cfif>return false;" title="Edit"><i class="fa fa-pencil"></i></a>
												</cfif>
												<cfif stActions.ftAllowRemove>
													<a href="##" class="fc-remove" onclick="$fc.arrayuploadformtool('#prefix#','#arguments.stMetadata.name#').confirmRemove('#encodeForJavaScript(joinItems[i])#');return false;" title="<cfif stActions.ftRemoveType EQ 'delete'>Delete<cfelse>Remove</cfif>"><i class="fa <cfif stActions.ftRemoveType EQ 'delete'>fa-trash-o<cfelse>fa-times</cfif>"></i></a>
												</cfif>
											</td>
										</tr>
									</table>
								</div>
							</li>
						</cfoutput>
					</cfif>
				</cfloop>
				
				<cfoutput>
					</ul>
					<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" />
				</cfoutput>
				
				<cfoutput>
					<!--- Modern dropzone: file picker + drag-drop + paste, mirroring the file/image
					      formtools. Multi-file (this is an array). The #arguments.fieldname#UPLOAD
					      input keeps the id/name the JS binds to ($fc.uploader attaches Uppy to it),
					      and the dropzone id is what init() passes to create() as the dropZone. --->
					<div id="#arguments.fieldname#-dropzone" class="fc-uploader-dropzone fc-arrayupload-dropzone" tabindex="0" role="button" aria-label="Upload files">
						<div class="fc-uploader-dropzone-icon"><i class="fa fa-cloud-upload"></i></div>
						<label class="fc-uploader-button">
							Select files
							<input type="file" name="#arguments.fieldname#UPLOAD" id="#arguments.fieldname#UPLOAD" multiple<cfif len(arguments.stMetadata.ftAllowedFileExtensions)> accept=".#replace(arguments.stMetadata.ftAllowedFileExtensions,",",",.","all")#"</cfif> class="fc-uploader-file-input" />
						</label>
						<span class="fc-uploader-dropzone-hint">or drag and drop files, or paste from clipboard</span>
					</div>
				</cfoutput>

				<!--- Toolbar always renders so it anchors the panel as an array field (not a
				      bare upload box). Upload is always first; the others are gated by flags. --->
				<cfoutput><div class="fc-arrayupload-toolbar">
					<!--- Upload: opens the file picker by triggering the dropzone's file input
					      (same input Uppy is bound to), so selections flow through one transport. --->
					<a class="btn" onclick="document.getElementById('#arguments.fieldname#UPLOAD').click();return false;"><i class="fa fa-cloud-upload"></i> Upload</a>

					<cfif stActions.ftAllowCreate>
						<!--- Create a brand-new related record. fcForm.openLibraryAdd reads
						      the "-add-type" hidden input below for the type to create (always
						      the single ftJoin here), saves via the displayLibraryAdd modal,
						      then routes back through the wrapped refreshProperty -> finishSelect. --->
						<a class="btn" onclick="fcForm.openLibraryAdd('#encodeForJavaScript(stObject.typename)#','#encodeForJavaScript(stObject.objectid)#','#arguments.stMetadata.name#','#arguments.fieldname#');return false;"><i class="fa fa-plus"></i> Create</a>
						<input type="hidden" id="#arguments.fieldname#-add-type" value="#arguments.stMetadata.ftJoin#" />
					</cfif>

					<cfif stActions.ftAllowSelect>
						<a class="btn" onclick="fcForm.openLibrarySelect('#encodeForJavaScript(stObject.typename)#','#encodeForJavaScript(stObject.objectid)#','#arguments.stMetadata.name#','#arguments.fieldname#');return false;"><i class="fa fa-search"></i> Select</a>
					</cfif>

					<cfif arguments.stMetadata.ftAllowRemoveAll>
						<!--- Remove All routes through confirmRemoveAll() so it uses the same
						      framework-agnostic confirm as the per-item remove (delete vs detach
						      wording is decided client-side from removeType). --->
						<a class="btn" onclick="$fc.arrayuploadformtool('#prefix#','#arguments.stMetadata.name#').confirmRemoveAll();return false;"><i class="fa <cfif stActions.ftRemoveType EQ 'delete'>fa-trash-o<cfelse>fa-times</cfif>"></i> Remove All</a>
					</cfif>
				</div></cfoutput>

				<!--- Close .fc-arrayupload-panel (opened before the item list). --->
				<cfoutput></div></cfoutput>

				<!--- Constraint caption: sits just below the panel (outside its border), so the
				      short label + ext-list tooltip + max size read as a caption for the control.
				      Not the field-level hint, which remains its own thing. --->
				<cfif len(allowedExtsDisplay) or len(maxSizeText)>
					<cfoutput>
						<div id="#arguments.fieldname#-constraints" class="fc-uploader-constraints fc-arrayupload-constraints"><cfif len(allowedExtsDisplay)><span class="fc-richtooltip fc-uploader-help" data-tooltip-position="top" data-tooltip-width="280" title="Accepted: #allowedExtsDisplay#">Formats accepted <i class="fa fa-question-circle"></i></span></cfif><cfif len(maxSizeText)><cfif len(allowedExtsDisplay)> &middot; </cfif>Max size: #maxSizeText#</cfif></div>
					</cfoutput>
				</cfif>

				<!--- Factory must be defined before init() runs. --->
				<cfoutput>#factoryScript#</cfoutput>

				<!--- Record the ftJoin this render resolved, so ajax() can recover it without
				      trusting the request: ajax() rebuilds stMetadata from COAPI and would
				      otherwise lose a render-time-injected ftJoin (e.g. the bulk-upload form).
				      Still carried in the URL as well, but only as a cross-check now - the
				      session copy is the authority, because it is the value the server chose. --->
				<cfset rememberJoinType(typename=arguments.typename, property=arguments.stMetadata.name, objectid=arguments.stObject.objectid, ftJoin=listFirst(arguments.stMetadata.ftJoin)) />
				<!--- this field's own request token: these actions post outside the enclosing
				      form, and that form is not always an ft:form - a wizard renders its own
				      form tag and emits no token. Minted whether or not form tokens are on, so
				      switching them on does not strand an open page. --->
				<cfset fieldToken = csrfGenerateToken(fieldTokenKey(typename=arguments.typename, property=arguments.stMetadata.name, objectid=arguments.stObject.objectid)) />
				<cfset uploadAjaxURL = application.formtools.field.oFactory.getAjaxURL(typename=arguments.typename,stObject=arguments.stObject,stMetadata=arguments.stMetadata,fieldname=arguments.fieldname,combined=true) & "/ftjoin/" & listFirst(arguments.stMetadata.ftJoin) />
				<cfoutput><script type="text/javascript">$fc.arrayuploadformtool('#prefix#','#arguments.stMetadata.name#').init('#encodeForJavaScript(arguments.typename)#','#encodeForJavaScript(arguments.stObject.objectid)#','#uploadAjaxURL#','#replace(rereplace(arguments.stMetadata.ftAllowedFileExtensions,"(^|,)(\w+)","\1*.\2","ALL"),",",";","ALL")#',#arguments.stMetadata.ftSizeLimit#,#arguments.stMetadata.ftSimUploadLimit#,#stActions.ftAllowEdit#,#stActions.ftAllowRemove#,'#stActions.ftRemoveType#',#len(arguments.stMetadata.ftEditableProperties) gt 0#,'#arguments.stMetadata.ftView#',#arguments.stMetadata.ftTileWidth#,#arguments.stMetadata.ftTileHeight#,'#storageType#','#encodeForJavaScript(fieldToken)#');</script></cfoutput>

			<!--- Width-constrained hover tooltip for the accepted-formats list. ft:form loads
			      Tooltipster but the webtop only auto-inits tooltips in its header, so edit-form
			      triggers must be initialised here (same as file/image). --->
			<skin:onReady>
				<cfoutput>
					if ($j.fn.tooltipster){
						$j('###arguments.fieldname#-constraints').find('.fc-richtooltip').tooltipster({
							theme:      '.tooltipster-light',
							position:   'top',
							fixedWidth: 280,
							delay:      0,
							speed:      200
						});
					}
				</cfoutput>
			</skin:onReady>
				<cfif arguments.stMetadata.ftView eq 'tiled'>
					<cfoutput>
						<script type="text/template" id="uploaditem-#arguments.fieldname#">
							<li id="join-item-{{property}}-{{ID}}" class="sort fc-arrayupload-item fc-tile-view">
								<div class="fc-tile-view-container" style="width:#arguments.stMetadata.ftTileWidth#px;height:#arguments.stMetadata.ftTileHeight#px;">
									<div class="fc-grabbar" title="Drag to reorder"><i class="fa fa-sort"></i></div>
									<div class="fc-arrayupload-actions">
										<a href="javascript:$fc.arrayuploadformtool('{{prefix}}','{{property}}').cancelByLocalId('{{ID}}')" class="fc-uploader-icon-btn" title="Cancel upload">
											<i class="fa fa-times"></i>
										</a>
									</div>
									{{filename}} ({{filesize}})
									<div class="fc-arrayupload-feedback">
										<div class="fc-arrayupload-progress">
											<div id="{{fieldname}}{{ID}}ProgressBar" class="fc-arrayupload-progress-bar"><!--Progress Bar--></div>
										</div>
									</div>
								</div>
							</li>
						</script>
						<script type="text/template" id="newitem-#arguments.fieldname#">
							<li id="join-item-{{property}}-{{itemid}}" class="sort fc-arrayupload-item fc-tile-view">
								<div class="fc-tile-view-container" style="width:#arguments.stMetadata.ftTileWidth#px;height:#arguments.stMetadata.ftTileHeight#px;">
									<div class="fc-grabbar" title="Drag to reorder"><i class="fa fa-sort"></i></div>
									<div class="fc-arrayupload-actions">
										{{if-allowedit}}<a href="##" class="fc-edit" onclick="{{if-quickedit}}$fc.arrayuploadformtool('{{prefix}}','{{property}}').editItem('{{itemid}}');{{if-quickedit}}{{ifnot-quickedit}}fcForm.openLibraryEdit('{{typename}}','{{objectid}}','{{property}}','{{fieldname}}','{{itemid}}');{{ifnot-quickedit}}return false;" title="Edit"><i class="fa fa-pencil"></i></a>{{if-allowedit}}
										{{if-allowdelete}}<a href="##" class="fc-remove" onclick="$fc.arrayuploadformtool('{{prefix}}','{{property}}').confirmRemove('{{itemid}}');return false;" title="Delete"><i class="fa fa-trash-o"></i></a>{{if-allowdelete}}
										{{if-allowremove}}<a href="##" class="fc-remove" onclick="$fc.arrayuploadformtool('{{prefix}}','{{property}}').confirmRemove('{{itemid}}');return false;" title="Remove"><i class="fa fa-times"></i></a>{{if-allowremove}}
									</div>
									<input type="hidden" name="{{fieldname}}" value="{{itemid}}" />
									{{displayhtml}}
								</div>
							</li>
						</script>
					</cfoutput>
				<cfelse>
					<cfoutput>
						<script type="text/template" id="uploaditem-#arguments.fieldname#">
							<li id="join-item-{{property}}-{{ID}}" class="sort fc-arrayupload-item fc-list-view">
								<div class="fc-list-view-container">
									<table class="fc-list-view-table">
										<tr>
											<td class="fc-grabbar" title="Drag to reorder"><i class="fa fa-sort"></i></td>
											<td class="" style="width:100%;padding:3px;">
												{{filename}} ({{filesize}})
												<div class="fc-arrayupload-feedback">
													<div class="fc-arrayupload-progress">
														<div id="{{fieldname}}{{ID}}ProgressBar" class="fc-arrayupload-progress-bar"><!--Progress Bar--></div>
													</div>
												</div>
											</td>
											<td class="" style="padding:3px;white-space:nowrap;">
												<a href="javascript:$fc.arrayuploadformtool('{{prefix}}','{{property}}').cancelByLocalId('{{ID}}')" class="fc-uploader-icon-btn" title="Cancel upload">
													<i class="fa fa-times"></i>
												</a>
											</td>
										</tr>
									</table>
								</div>
							</li>
						</script>
						<script type="text/template" id="newitem-#arguments.fieldname#">
							<li id="join-item-{{property}}-{{itemid}}" class="sort fc-arrayupload-item fc-list-view">
								<div class="fc-list-view-container">
									<table class="fc-list-view-table">
										<tr>
											<td class="fc-grabbar" title="Drag to reorder"><i class="fa fa-sort"></i></td>
											<td class="" style="width:100%;padding:3px;"><input type="hidden" name="{{fieldname}}" value="{{itemid}}" />{{displayhtml}}</td>
											<td class="" style="padding:3px;white-space:nowrap;">
												{{if-allowedit}}<a href="##" class="fc-edit" onclick="{{if-quickedit}}$fc.arrayuploadformtool('{{prefix}}','{{property}}').editItem('{{itemid}}');{{if-quickedit}}{{ifnot-quickedit}}fcForm.openLibraryEdit('{{typename}}','{{objectid}}','{{property}}','{{fieldname}}','{{itemid}}');{{ifnot-quickedit}}return false;" title="Edit"><i class="fa fa-pencil"></i></a>{{if-allowedit}}
												{{if-allowdelete}}<a href="##" class="fc-remove" onclick="$fc.arrayuploadformtool('{{prefix}}','{{property}}').confirmRemove('{{itemid}}');return false;" title="Delete"><i class="fa fa-trash-o"></i></a>{{if-allowdelete}}
												{{if-allowremove}}<a href="##" class="fc-remove" onclick="$fc.arrayuploadformtool('{{prefix}}','{{property}}').confirmRemove('{{itemid}}');return false;" title="Remove"><i class="fa fa-times"></i></a>{{if-allowremove}}
											</td>
										</tr>
									</table>
								</div>
							</li>
						</script>
					</cfoutput>
				</cfif>
			</grid:div>
		</cfsavecontent>
		
		<cfif structKeyExists(request, "hideLibraryWrapper") AND request.hideLibraryWrapper>
			<cfreturn "#returnHTML#" />
		<cfelse>
			<cfreturn "<div id='#arguments.fieldname#-library-wrapper'>#returnHTML#</div>" />	
		</cfif>
		
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
		<cfset var i = 0 />
		<cfset var html = "" />
		<cfset var json = "" />
		<cfset var stJSON = structnew() />
	    <cfset var prefix = left(arguments.fieldname,len(arguments.fieldname)-len(arguments.stMetadata.name)) />
	    <cfset var stFP = structnew() />
	    <cfset var thisfield = "" />
	    <cfset var aItems = "" />
	    <cfset var stActions = structnew() />
	    <cfset var editprefix = "" />
	    <cfset var stNewObject = structnew() />
	    <cfset var stBody = structnew() />
	    <cfset var stPrep = "" />
	    <cfset var uploadLocationS3 = "" />
	    <cfset var joinLocation = "" />
	    <cfset var stJoinRestrict = "" />
	    <cfset var bJoinRecovered = false />
	    <cfset var recoveredJoin = "" />
	    <cfset var stBind = structnew() />
	    <cfset var stClaim = "" />
	    <cfset var maxsize = 0 />
	    <cfset var uploadid = "" />
	    <!--- the id the authorization named for the record this finalize creates. empty on
	          the local upload path, which mints its own as it always has --->
	    <cfset var joinRecordID = "" />
	    <cfset var joinedItems = "" />
	    <!--- the facade hands over an empty struct when the request names no parent --->
	    <cfset var parentid = structKeyExists(arguments.stObject,"objectid") ? arguments.stObject.objectid : "" />

		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

		<!--- Recover ftJoin when COAPI has none (render-time-injected ftJoin). The value comes
		      from what edit() recorded for this property in this session, never from the
		      request, so a caller cannot select the target type. Gated to genuine arrayupload
		      fields. When the request also carries one it must agree, which catches a page
		      rendered against different metadata as well as outright tampering.

		      The provenance is still kept: a value recovered this way is a rendering aid, and
		      the branches that act on an existing record require declared metadata. --->
		<cfif (not structKeyExists(arguments.stMetadata,"ftJoin") or not listlen(arguments.stMetadata.ftJoin) eq 1)
				and structKeyExists(arguments.stMetadata,"ftType") and arguments.stMetadata.ftType EQ "arrayupload">
			<cfset recoveredJoin = recallJoinType(typename=arguments.typename, property=arguments.stMetadata.name, objectid=arguments.stObject.objectid) />

			<cfif not len(recoveredJoin)>
				<cfheader name="Content-Type" value="application/json; charset=UTF-8" />
				<cfreturn serializeJSON({ "error" = "This field does not declare a related type" }) />
			</cfif>
			<cfif structKeyExists(url,"ftjoin") and compareNoCase(trim(url.ftjoin),recoveredJoin) neq 0>
				<cfheader name="Content-Type" value="application/json; charset=UTF-8" />
				<cfreturn serializeJSON({ "error" = "This field does not declare a related type" }) />
			</cfif>

			<cfset arguments.stMetadata.ftJoin = recoveredJoin />
			<cfset bJoinRecovered = true />
		</cfif>

	    <cfif not listlen(arguments.stMetadata.ftJoin) eq 1>
			<cfthrow message="One related type must be specified in the ftJoin attribute" />
		</cfif>
	    <cfif not len(arguments.stMetadata.ftFileProperty)>
			<cfif arguments.stMetadata.ftJoin eq "dmImage">
				<cfset arguments.stMetadata.ftFileProperty = "sourceImage" />
			<cfelseif arguments.stMetadata.ftJoin eq "dmFile">
				<cfset arguments.stMetadata.ftFileProperty = "filename" />
			<cfelse>
				<cfthrow message="ftFileProperty is a required attribute" />
			</cfif>
		</cfif>
	    <!--- inherit restrictions from the joined file property (ftType-aware; COAPI has merged in the formtool defaults). an explicit override on the arrayupload field still wins. --->
	    <cfset stJoinRestrict = resolveJoinUploadRestrictions(arguments.stMetadata) />
	    <cfif not len(arguments.stMetadata.ftAllowedFileExtensions)>
			<cfset arguments.stMetadata.ftAllowedFileExtensions = stJoinRestrict.extensions />
		</cfif>
	    <cfif not len(arguments.stMetadata.ftSizeLimit)>
			<cfset arguments.stMetadata.ftSizeLimit = stJoinRestrict.sizeLimit />

		</cfif>
		
		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

		<!--- Direct-to-S3 sign request (storage:s3). Mirrors file/image ajaxS3:
		      presign a POST to the FINAL location and echo the resolved value so
		      finalize can record it. Secret key never leaves the server. --->
		<cfif structkeyexists(url,"s3op") and url.s3op eq "sign">
			<cfheader name="Content-Type" value="application/json; charset=UTF-8" />
			<cfset stBody = application.formtools.field.oFactory.getAjaxRequestBody() />
			<cfset uploadLocationS3 = resolveJoinUploadLocation(arguments.stMetadata) />
			<cftry>
				<!--- signing authorises the write that follows it, so it is gated on the same
				      permission as the upload branch rather than only that branch --->
				<cfif not application.fc.lib.directupload.checkUploadPermission(typename=arguments.typename, objectid=arguments.stObject.objectid, joinTypename=arguments.stMetadata.ftJoin)>
					<cfreturn serializeJSON({ "error" = "You do not have permission to add #arguments.stMetadata.ftJoin# records to this field." }) />
				</cfif>

				<cfset maxsize = (val(arguments.stMetadata.ftSizeLimit) gt 0) ? val(arguments.stMetadata.ftSizeLimit) : 0 />
				<cfset stBind = directUploadBind(typename=arguments.typename, stObject=arguments.stObject, stMetadata=arguments.stMetadata, location=uploadLocationS3) />

				<cfset stPrep = application.fc.lib.cdn.prepareDirectUpload(
					location=uploadLocationS3,
					destination=application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftDestination,
					filename=structKeyExists(stBody,"filename") ? stBody.filename : "upload",
					uniqueAmong=listfindnocase("publicfiles,privatefiles", uploadLocationS3) ? "privatefiles,publicfiles" : uploadLocationS3,
					contentType=structKeyExists(stBody,"type") ? stBody.type : "",
					maxSize=maxsize,
					acceptExtensions=arguments.stMetadata.ftAllowedFileExtensions
				) />
				<!--- Carry the resolved value to the client so finalize can echo it back. --->
				<cfset stPrep.params["value"] = stPrep.value />
				<!--- and the authorization finalize has to present. what it grants is held
				      server side; the client only ever carries the id --->
				<cfset stPrep.params["uploadid"] = application.fc.lib.directupload.issue(
					bind = stBind,
					grant = {
						"value" = stPrep.value,
						"key" = structKeyExists(stPrep.params,"key") ? stPrep.params.key : "",
						"maxsize" = maxsize,
						"extension" = listlast(stPrep.value,".")
					}
				) />
				<cfreturn serializeJSON(stPrep.params) />

				<cfcatch type="any">
					<cfreturn serializeJSON({ "error" = cfcatch.message }) />
				</cfcatch>
			</cftry>
		</cfif>

		<cfif structkeyexists(url,"check")>
			<cfheader name="Content-Type" value="application/json; charset=UTF-8" />
			<cfreturn "[]" />
		</cfif>
		
		<cfif structkeyexists(url,"add")>
			<cfheader name="Content-Type" value="application/json; charset=UTF-8" />
			<cfif not structKeyExists(form, "items") or not len(form.items)>
				<cfreturn "" />
			</cfif>
			
			<!--- SETUP stActions --->
			<cfset stActions.ftAllowEdit = arguments.stMetadata.ftAllowEdit />
			<cfset stActions.ftRemoveType = arguments.stMetadata.ftRemoveType />
			
			<cfif arguments.stMetadata.ftRemoveType EQ "detach">
				<cfset stActions.ftRemoveType = "remove" />
			</cfif>
			
			<cfset aItems = arraynew(1) />
			<cfloop list="#form.items#" index="source">
				<cfset stResult = structnew() />
				<cfset stResult["objectid"] = source />
				<skin:view objectid="#source#" typename="#arguments.stMetadata.ftJoin#" webskin="#arguments.stMetadata.ftListWebskin#" alternateHTML="OBJECT NO LONGER EXISTS" r_html="html" />
				<cfset stResult["html"] = html />
				<cfset arrayappend(aItems,stResult) />
			</cfloop>
			
			<cfreturn serializeJSON(aItems) />
		</cfif>
		
		<cfif structkeyexists(url,"edit")><!--- Edit an array item --->
			<!--- this branch answers into fc.openModal, which parses what it gets as markup,
			      so a message is returned as markup too --->
			<cfif bJoinRecovered>
				<cfreturn editMessage("This field does not declare a related type") />
			</cfif>
			<!--- these branches dispatch through the ajax facade, not ft:processform, so they
			      assert a request token themselves --->
			<cfif not checkFormToken(typename=arguments.typename, property=arguments.stMetadata.name, objectid=parentid)>
				<cfreturn editMessage("There was a problem with the form submission. Please try again.") />
			</cfif>
			<cfif not structKeyExists(form, "item") or not len(form.item)>
				<cfreturn editMessage("No item specified") />
			</cfif>
			<!--- returns an editable form for the joined record, so it takes the authority to edit one --->
			<cfif not checkItemPermission(typename=arguments.typename, objectid=parentid, joinTypename=arguments.stMetadata.ftJoin, permission="Edit")>
				<cfreturn editMessage("You do not have permission to edit #arguments.stMetadata.ftJoin# records in this field.") />
			</cfif>
			<cfset joinedItems = currentJoinItems(typename=arguments.typename, property=arguments.stMetadata.name, objectid=parentid) />
			<cfif not isJoinItem(itemid=form.item, items=joinedItems)>
				<cfreturn editMessage("That item is not attached to this record.") />
			</cfif>
			<!--- ft:object renders a new-object form for an id that names no row, and saving that
			      would create rather than edit --->
			<cfif not isPersistedItem(typename=arguments.stMetadata.ftJoin, objectid=form.item)>
				<cfreturn editMessage("That item no longer exists.") />
			</cfif>

			<cfset request.mode.ajax = true />
			<cfsavecontent variable="html"><cfoutput>
				<div style="border: 1px solid ##c8c8c8\9;background-color:##FFFFFF;padding:15px;-webkit-box-shadow: 0 0 8px rgba(128,128,128,0.75);-moz-box-shadow: 0 0 8px rgba(128,128,128,0.75);box-shadow: 0 0 8px rgba(128,128,128,0.75);">
					<ft:form>
						<ft:object objectid="#form.item#" lFields="#arguments.stMetadata.ftEditableProperties#" r_stPrefix="editprefix" />
						<ft:buttonPanel>
							<a href="##" class="closeModal">cancel</a>&nbsp;<ft:button value="Save" onclick="var base={};var props='#arguments.stMetadata.ftEditableProperties#'.split(',');for (var i in props) base[props[i]]='';$fc.arrayuploadformtool('#prefix#','#arguments.stMetadata.name#').saveItem('#form.item#',getValueData(base,'#editprefix#'));return false;" />
						</ft:buttonPanel>
					</ft:form>
				</div>
			</cfoutput></cfsavecontent>

			<cfreturn html />
		</cfif>
		
		<cfif structkeyexists(url,"update")><!--- Update an array item --->
			<cfheader name="Content-Type" value="application/json; charset=UTF-8" />
			<cfif bJoinRecovered>
				<cfreturn serializeJSON({ "error" = "This field does not declare a related type" }) />
			</cfif>
			<cfif not checkFormToken(typename=arguments.typename, property=arguments.stMetadata.name, objectid=parentid)>
				<cfreturn serializeJSON({ "error" = "There was a problem with the form submission. Please try again." }) />
			</cfif>
			<cfif not structKeyExists(form, "_objectid") or not len(form._objectid)>
				<cfreturn serializeJSON({ "error" = "No data specified" }) />
			</cfif>
			<cfif not checkItemPermission(typename=arguments.typename, objectid=parentid, joinTypename=arguments.stMetadata.ftJoin, permission="Edit")>
				<cfreturn serializeJSON({ "error" = "You do not have permission to edit #arguments.stMetadata.ftJoin# records in this field." }) />
			</cfif>
			<cfset joinedItems = currentJoinItems(typename=arguments.typename, property=arguments.stMetadata.name, objectid=parentid) />
			<cfif not isJoinItem(itemid=form["_objectid"], items=joinedItems)>
				<cfreturn serializeJSON({ "error" = "That item is not attached to this record." }) />
			</cfif>
			<!--- fourq's setData creates when the id names no row, so a missing record is refused
			      here rather than being written as a new one --->
			<cfif not isPersistedItem(typename=arguments.stMetadata.ftJoin, objectid=form["_objectid"])>
				<cfreturn serializeJSON({ "error" = "That item no longer exists." }) />
			</cfif>
			
			<!--- SETUP stActions --->
			<cfset stActions.ftAllowEdit = arguments.stMetadata.ftAllowEdit />
			<cfset stActions.ftRemoveType = arguments.stMetadata.ftRemoveType />
			
			<cfif arguments.stMetadata.ftRemoveType EQ "detach">
				<cfset stActions.ftRemoveType = "remove" />
			</cfif>
			
			<cftry>
				<cfset stSource = structnew() />
				<cfset stSource.objectid = form["_objectid"] />
				<cfset stSource.typename = arguments.stMetadata.ftJoin />
				<cfloop list="#arguments.stMetadata.ftEditableProperties#" index="thisfield">
					<cfset stSource[thisfield] = form["_#thisfield#"] />
				</cfloop>
				<cfset application.fapi.setData(stProperties=stSource) />

				<cfcatch type="any">
					<cfreturn serializeJSON({ "error" = cfcatch.message }) />
				</cfcatch>
			</cftry>

			<cfset stJSON = structnew() />
			<cfset stJSON["objectid"] = stSource.objectid />
			<skin:view objectid="#stSource.objectid#" typename="#arguments.stMetadata.ftJoin#" webskin="#arguments.stMetadata.ftListWebskin#" alternateHTML="OBJECT NO LONGER EXISTS" r_html="html" />
			<cfset stJSON["html"] = html />
			
			<cfreturn serializeJSON(stJSON) />
		</cfif>
		
		<cfif structkeyexists(url,"delete")>
			<cfheader name="Content-Type" value="application/json; charset=UTF-8" />
			<cfif bJoinRecovered>
				<cfreturn serializeJSON({ "error" = "This field does not declare a related type" }) />
			</cfif>
			<cfif not checkFormToken(typename=arguments.typename, property=arguments.stMetadata.name, objectid=parentid)>
				<cfreturn serializeJSON({ "error" = "There was a problem with the form submission. Please try again." }) />
			</cfif>
			<!--- the only branch that reaches the database. remove and detach are client side
			      and persist with the parent form --->
			<cfif arguments.stMetadata.ftRemoveType neq "delete">
				<cfreturn serializeJSON({ "error" = "This field does not delete items." }) />
			</cfif>
			<cfif not structKeyExists(form, "items") or not len(form.items)>
				<cfreturn "[]" />
			</cfif>
			<cfif not checkItemPermission(typename=arguments.typename, objectid=parentid, joinTypename=arguments.stMetadata.ftJoin, permission="Delete")>
				<cfreturn serializeJSON({ "error" = "You do not have permission to delete #arguments.stMetadata.ftJoin# records from this field." }) />
			</cfif>

			<cfset aItems = listtoarray(form.items) />
			<cfset joinedItems = currentJoinItems(typename=arguments.typename, property=arguments.stMetadata.name, objectid=parentid) />

			<!--- checked in full before anything is deleted: the batch is all or nothing --->
			<cfloop from="1" to="#arraylen(aItems)#" index="i">
				<cfif not isJoinItem(itemid=aItems[i], items=joinedItems)>
					<cfreturn serializeJSON({ "error" = "That item is not attached to this record." }) />
				</cfif>
			</cfloop>

			<cfset source = application.fapi.getContentType(arguments.stMetadata.ftJoin) />
			<cfloop from="1" to="#arraylen(aItems)#" index="i">
				<cfset source.deleteData(aItems[i]) />
			</cfloop>

			<cfreturn serializeJSON(aItems) />
		</cfif>
		
		<cfif structkeyexists(url,"upload")><!--- Upload / finalise a new array item --->
			<cfheader name="Content-Type" value="application/json; charset=UTF-8" />

			<!--- Upload creates a new ftJoin record and mutates the parent's relationship, so
			      require Create on the joined type AND the parent's own Edit/Create - the same
			      mapping the direct-to-bucket branch uses, so both transports agree. Guards the
			      recovered ftJoin and the declared-in-type path alike. --->
			<cfif not application.fc.lib.directupload.checkUploadPermission(typename=arguments.typename, objectid=arguments.stObject.objectid, joinTypename=arguments.stMetadata.ftJoin)>
				<cfreturn serializeJSON({ "error" = "You do not have permission to add #arguments.stMetadata.ftJoin# records to this field." }) />
			</cfif>

			<!--- stFieldPost is supplied by the dispatcher for form posts but may be
			      absent on a direct-S3 finalize (an AJAX fetch); guard it so the
			      shared image post-processing below can default ResizeMethod/Quality. --->
			<cfif not structKeyExists(arguments,"stFieldPost") or not isStruct(arguments.stFieldPost)>
				<cfset arguments.stFieldPost = structnew() />
			</cfif>
			<cfif not structKeyExists(arguments.stFieldPost,"stSupporting")>
				<cfset arguments.stFieldPost.stSupporting = structnew() />
			</cfif>

			<!--- Resolve the joined file property's CDN location once (ftLocation wins for
			      both types; else image->images, file->publicfiles/privatefiles by ftSecure)
			      and use it for both the local and direct-S3 paths so they stay consistent. --->
			<cfset joinLocation = resolveJoinUploadLocation(arguments.stMetadata) />

			<cfif structkeyexists(url,"s3op") and url.s3op eq "finalize">
				<!--- Direct-to-S3 finalize: the object is already in S3. Synthesize the
				      handleFilePost result from the AUTHORIZED value so the existing
				      object-create / resize / render pipeline below runs unchanged
				      (no temp file, no server-side copy).

				      Inside a JSON error boundary so this surface fails the same
				      recognisable way as its siblings rather than as an error page. --->
				<cftry>
					<cfset stBody = application.formtools.field.oFactory.getAjaxRequestBody() />
					<cfset uploadid = structKeyExists(stBody,"uploadid") ? stBody.uploadid : "" />

					<cfif not application.fc.lib.directupload.checkUploadPermission(typename=arguments.typename, objectid=arguments.stObject.objectid, joinTypename=arguments.stMetadata.ftJoin)>
						<cfreturn serializeJSON({ "error" = "You do not have permission to add #arguments.stMetadata.ftJoin# records to this field.", "value" = "" }) />
					</cfif>

					<!--- existence and size are established here, ahead of the row creation
					      below, so no joined record describes an object that is not in the
					      bucket or that exceeds the limit the server signed for --->
					<cfset stClaim = application.fc.lib.directupload.claimAndVerify(
						uploadid = uploadid,
						expect = directUploadBind(typename=arguments.typename, stObject=arguments.stObject, stMetadata=arguments.stMetadata, location=joinLocation),
						clientValue = structKeyExists(stBody,"value") ? stBody.value : ""
					) />

					<cfif stClaim.status neq "ok">
						<cfreturn serializeJSON({ "error" = stClaim.message, "value" = "" }) />
					</cfif>

					<!--- the accepted value is the one the server authorised, never the request's --->
					<cfset stResult.location = joinLocation />
					<cfset stResult.value = stClaim.value />
					<cfset stResult.bSuccess = true />
					<!--- the joined record is created at the id the authorization names, so a
					      finalize arriving twice for one upload writes that record twice rather
					      than creating a second one alongside it --->
					<cfset joinRecordID = stClaim.recordid />

					<cfcatch type="any">
						<cfreturn serializeJSON({ "error" = cfcatch.message, "value" = "" }) />
					</cfcatch>
				</cftry>

			<cfelse>

				<cfset stResult = handleFilePost(
					objectid=arguments.stObject.objectid,
					uploadfield="#arguments.stMetadata.name#UPLOAD",
					destination=application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftDestination,
					location=joinLocation,
					allowedExtensions=arguments.stMetadata.ftAllowedFileExtensions,
					stFieldPost=arguments.stFieldPost.stSupporting,
					sizeLimit=arguments.stMetadata.ftSizeLimit) />
				<cfset stResult.location = joinLocation />

			</cfif>
			
			<cfif structKeyExists(stResult, "stError") and structKeyExists(stResult.stError, "message") and len(stResult.stError.message)>
				<cfset stJSON = structnew() />
				<cfset stJSON["error"] = stResult.stError.message />
				<cfset stJSON["value"] = stResult.value />
				<cfreturn serializeJSON(stJSON) />
			</cfif>
			
			<cfif structKeyExists(stResult, "bSuccess") and stResult.bSuccess and structKeyExists(stResult, "value") and len(stResult.value)>
				
				<cfif application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftType eq "file">
					
					<cfset stFile = application.fc.lib.cdn.ioGetFileLocation(location=stResult.location,file=stResult.value) />
					
					<cfset stNewObject = application.fapi.getNewContentObject(typename=arguments.stMetadata.ftJoin) />
					<cfif len(joinRecordID)>
						<cfset stNewObject.objectid = joinRecordID />
					</cfif>
					<cfset stNewObject.label = listfirst(listlast(stResult.value,"/"),".") />
					<cfset stNewObject[arguments.stMetadata.ftFileProperty] = stResult.value />
					<cfset application.fapi.setData(stProperties=stNewObject) />
					
					<cfif structkeyexists(application.formtools.file.oFactory,"onFileChange")>
						<cfset application.formtools.file.oFactory.onFileChange(typename=arguments.stMetadata.ftJoin,objectid=stNewObject.objectid,stMetadata=application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata,value=stResult.value) />
					</cfif>
					
					<cfset stJSON = structnew() />
					<cfset stJSON["objectid"] = stNewObject.objectid />
					<cfset stJSON["value"] = stResult.value />
					<cfset stJSON["filename"] = listlast(stResult.value,"/") />
					<cfset stJSON["fullpath"] = stFile.path />
					<cfset stJSON["size"] = round(application.fc.lib.cdn.ioGetFileSize(location=stResult.location,file=stResult.value)/1024) />
					<skin:view objectid="#stNewObject.objectid#" typename="#arguments.stMetadata.ftJoin#" webskin="#arguments.stMetadata.ftListWebskin#" bIgnoreSecurity="true" r_html="html" alternateHTML="OBJECT NO LONGER EXISTS" />
					<cfset stJSON["html"] = html />
					
				<cfelse><!--- File property is an image formtool --->
					
					<cfif not structkeyexists(arguments.stFieldPost.stSupporting,"ResizeMethod") or not isnumeric(arguments.stFieldPost.stSupporting.ResizeMethod)>
						<cfset arguments.stFieldPost.stSupporting.ResizeMethod = application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftAutoGenerateType />
					</cfif>
					<cfif not structkeyexists(arguments.stFieldPost.stSupporting,"Quality") or not isnumeric(arguments.stFieldPost.stSupporting.Quality)>
						<cfset arguments.stFieldPost.stSupporting.Quality = application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftQuality />
					</cfif>
					
					<cftry>
						<cfset stJSON = structnew() />
						<cfset stFixed = application.formtools.image.oFactory.fixImage(stResult.value,application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata,arguments.stFieldPost.stSupporting.ResizeMethod,arguments.stFieldPost.stSupporting.Quality) />
						
						<cfset stNewObject = application.fapi.getNewContentObject(typename=arguments.stMetadata.ftJoin) />
						<cfif len(joinRecordID)>
							<cfset stNewObject.objectid = joinRecordID />
						</cfif>
						<cfset stNewObject.label = listfirst(listlast(stResult.value,"/"),".") />
						<cfif structkeyexists(application.stCOAPI[arguments.stMetadata.ftJoin].stProps,"title")>
							<cfset stNewObject.title = stNewObject.label />
						</cfif>
						<cfif structkeyexists(application.stCOAPI[arguments.stMetadata.ftJoin].stProps,"name")>
							<cfset stNewObject.name = stNewObject.label />
						</cfif>
						<cfset stNewObject[arguments.stMetadata.ftFileProperty] = stResult.value />
						<cfloop collection="#application.stCOAPI[arguments.stMetadata.ftJoin].stProps#" item="thisfield">
							<cfif structKeyExists(application.stCOAPI[arguments.stMetadata.ftJoin].stProps[thisfield].metadata, "ftType") 
								and application.stCOAPI[arguments.stMetadata.ftJoin].stProps[thisfield].metadata.ftType eq "image"
								and structKeyExists(application.stCOAPI[arguments.stMetadata.ftJoin].stProps[thisfield].metadata, "ftSourceField")
								and listfirst(application.stCOAPI[arguments.stMetadata.ftJoin].stProps[thisfield].metadata.ftSourceField,":") eq arguments.stMetadata.ftFileProperty>
								
								<cfset stFP[thisfield] = structnew() />
								
							</cfif>
						</cfloop>
						<cfset stNewObject = application.formtools.image.oFactory.ImageAutoGenerateBeforeSave(typename=stNewObject.typename,stProperties=stNewObject,stFields=application.stCOAPI[arguments.stMetadata.ftJoin].stProps,stFormPost=stFP) />
						<cfset application.fapi.setData(stProperties=stNewObject) />
						
						<cfif structkeyexists(application.formtools.image.oFactory,"onFileChange")>
							<cfset application.formtools.image.oFactory.onFileChange(typename=arguments.stMetadata.ftJoin,objectid=stNewObject.objectid,stMetadata=application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata,value=stResult.value) />
						</cfif>
						
						<cfset stFile = application.fc.lib.cdn.ioGetFileLocation(location=stResult.location,file=stResult.value) />
						
						<cfimage action="info" source="#application.fc.lib.cdn.ioReadFile(location=stResult.location,file=stResult.value,datatype='image')#" structName="stImage" />
						<cfset stJSON["objectid"] = stNewObject.objectid />
						<cfset stJSON["value"] = stResult.value />
						<cfset stJSON["filename"] = listlast(stResult.value,'/') />
						<cfset stJSON["fullpath"] = stFile.path />
						<cfset stJSON["size"] = round(application.fc.lib.cdn.ioGetFileSize(location=stResult.location,file=stResult.value)/1024) />
						<skin:view objectid="#stNewObject.objectid#" typename="#arguments.stMetadata.ftJoin#" webskin="#arguments.stMetadata.ftListWebskin#" bIgnoreSecurity="true" r_html="html" alternateHTML="OBJECT NO LONGER EXISTS" />
						<cfset stJSON["html"] = html />
						
						<cfcatch>
							<cfset stJSON["error"] = cfcatch.message />
							<cfset stJSON["value"] = "" />
						</cfcatch>
					</cftry>
					
				</cfif>

				<cfreturn serializeJSON(stJSON) />

			</cfif>
		</cfif>

		<cfheader name="Content-Type" value="application/json; charset=UTF-8" />
		<cfreturn "{}" />
	</cffunction>

	<cffunction name="joinTypeKey" access="private" output="false" returntype="string" hint="Identifies the field the render resolved a join type for: the type, the property and the parent record. Deliberately NOT keyed on fieldname - that arrives as url.fieldname on the ajax request, so keying on it would let a request naming one parent present another parent's fieldname and recover its entry. The parent is the target of the operation, so it is what the entry has to be tied to.">
		<cfargument name="typename" required="true" type="string" />
		<cfargument name="property" required="true" type="string" />
		<cfargument name="objectid" required="true" type="string" />

		<cfreturn "#arguments.typename#|#arguments.property#|#arguments.objectid#" />
	</cffunction>

	<cffunction name="rememberJoinType" access="private" output="false" returntype="void" hint="Records the ftJoin a render resolved for this parent, so the matching ajax request can recover it from the server rather than from the request. Only records when COAPI cannot supply the value itself, which is the only case ajax() consults it - so the store holds render-time-injected fields only, not every arrayupload ever rendered.">
		<cfargument name="typename" required="true" type="string" />
		<cfargument name="property" required="true" type="string" />
		<cfargument name="objectid" required="true" type="string" />
		<cfargument name="ftJoin" required="true" type="string" />

		<cfset var stDeclared = "" />

		<cfif structKeyExists(application.stCOAPI,arguments.typename) and structKeyExists(application.stCOAPI[arguments.typename].stProps,arguments.property)>
			<cfset stDeclared = application.stCOAPI[arguments.typename].stProps[arguments.property].metadata />
			<cfif structKeyExists(stDeclared,"ftJoin") and listlen(stDeclared.ftJoin) eq 1>
				<cfreturn />
			</cfif>
		</cfif>

		<cfparam name="session.fc" default="#structNew()#" />
		<cfparam name="session.fc.arrayuploadJoins" default="#structNew()#" />

		<!--- the parent is stored as well as keyed on, so recall asserts it rather than
		      trusting that the key was assembled from the requested parent --->
		<cfset session.fc.arrayuploadJoins[joinTypeKey(argumentCollection=arguments)] = {
			"ftJoin" = arguments.ftJoin,
			"objectid" = arguments.objectid
		} />
	</cffunction>

	<cffunction name="recallJoinType" access="private" output="false" returntype="string" hint="The ftJoin a render recorded for this property against this parent in this session, or an empty string when there is none. Server authoritative: the only writer is edit(), from the metadata the server was given, and the stored parent must match the one being operated on.">
		<cfargument name="typename" required="true" type="string" />
		<cfargument name="property" required="true" type="string" />
		<cfargument name="objectid" required="true" type="string" />

		<cfset var key = joinTypeKey(argumentCollection=arguments) />
		<cfset var stEntry = "" />

		<cfif structKeyExists(session,"fc") and structKeyExists(session.fc,"arrayuploadJoins") and structKeyExists(session.fc.arrayuploadJoins,key)>
			<cfset stEntry = session.fc.arrayuploadJoins[key] />

			<cfif isStruct(stEntry) and structKeyExists(stEntry,"objectid") and structKeyExists(stEntry,"ftJoin")
					and compareNoCase(stEntry.objectid,arguments.objectid) eq 0>
				<cfreturn stEntry.ftJoin />
			</cfif>
		</cfif>

		<cfreturn "" />
	</cffunction>

	<cffunction name="editMessage" access="private" output="false" returntype="string" hint="Wraps a message for the edit branch, whose response is handed to fc.openModal. That parses its argument as markup, so a bare sentence is read as a selector rather than shown.">
		<cfargument name="message" required="true" type="string" />

		<cfreturn '<div class="fc-arrayupload-message">' & encodeForHTML(arguments.message) & '</div>' />
	</cffunction>

	<cffunction name="fieldTokenKey" access="private" output="false" returntype="string" hint="The key this field's request token is held under. Built from context the server resolves at both ends - the render and the ajax request - so the client carries the token and never the key. Stable for a given field on a given record, so repeated renders refresh one entry rather than adding one per render as a form name does.">
		<cfargument name="typename" required="true" type="string" />
		<cfargument name="property" required="true" type="string" />
		<cfargument name="objectid" required="true" type="string" />

		<cfreturn lcase("arrayupload_#arguments.typename#_#arguments.property#_#arguments.objectid#") />
	</cffunction>

	<cffunction name="checkFormToken" access="private" output="false" returntype="boolean" hint="True when the request carries this field's token, or when the site has form tokens turned off. The token is the field's own rather than the enclosing form's: these actions write a different record than the form they are launched from, and the form is not always an ft:form - a wizard renders its own form tag and emits no token at all.">
		<cfargument name="typename" required="true" type="string" />
		<cfargument name="property" required="true" type="string" />
		<cfargument name="objectid" required="true" type="string" />

		<cfif not application.fapi.getConfig("security", "bCSRFTokens", true)>
			<cfreturn true />
		</cfif>

		<cfif not structKeyExists(form,"FarcryFormToken") or not len(form.FarcryFormToken)>
			<cfreturn false />
		</cfif>

		<cftry>
			<cfreturn csrfVerifyToken(form.FarcryFormToken, fieldTokenKey(argumentCollection=arguments)) />

			<cfcatch type="any">
				<!--- a token that cannot be read is a token that does not verify --->
				<cfreturn false />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="checkItemPermission" access="private" output="false" returntype="boolean" hint="The permission for an operation this field performs on an already joined record: the named permission on the joined type - Edit to read or write one, Delete to remove one - plus the parent's own authority, which is Edit on the parent type when the parent exists and Create on it when the parent is new or session only. Type scoped throughout, the same semantics the upload branches use.">
		<cfargument name="typename" required="true" type="string" hint="the parent's type" />
		<cfargument name="objectid" required="true" type="string" hint="the parent record" />
		<cfargument name="joinTypename" required="true" type="string" hint="the joined type the operation acts on" />
		<cfargument name="permission" required="true" type="string" hint="the permission the operation needs on the joined type" />

		<cfif not len(arguments.typename) or not len(arguments.joinTypename)>
			<cfreturn false />
		</cfif>

		<cfif not application.security.checkPermission(permission=arguments.permission, type=arguments.joinTypename)>
			<cfreturn false />
		</cfif>

		<cfif isPersistedItem(typename=arguments.typename, objectid=arguments.objectid)>
			<cfreturn application.security.checkPermission(permission="Edit", type=arguments.typename) />
		</cfif>

		<cfreturn application.security.checkPermission(permission="Create", type=arguments.typename) />
	</cffunction>

	<cffunction name="isPersistedItem" access="private" output="false" returntype="boolean" hint="True when the id names a record of this type in the database. isPersistedObject bypasses the session temp store and the object broker, so a session only id reports false.">
		<cfargument name="typename" required="true" type="string" />
		<cfargument name="objectid" required="true" type="string" />

		<cfif not len(trim(arguments.objectid)) or not structKeyExists(application.stCOAPI,arguments.typename)>
			<cfreturn false />
		</cfif>

		<cftry>
			<cfreturn application.fapi.getContentType(arguments.typename).isPersistedObject(objectid=arguments.objectid) />

			<cfcatch type="any">
				<!--- a malformed id names nothing --->
				<cfreturn false />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="isJoinItem" access="private" output="false" returntype="boolean" hint="True when the item is one this parent's relationship holds. Membership only: whether the record still exists is a separate question, asked by the branches whose behaviour depends on the answer. A relationship can outlive the record it points at, and such a row has to stay removable.">
		<cfargument name="itemid" required="true" type="string" />
		<cfargument name="items" required="true" type="string" hint="what this field is holding for this parent, from currentJoinItems(); the caller resolves it once per request" />

		<cfif not len(trim(arguments.itemid))>
			<cfreturn false />
		</cfif>

		<cfreturn listFindNoCase(arguments.items, trim(arguments.itemid)) gt 0 />
	</cffunction>

	<cffunction name="persistedJoinItems" access="private" output="false" returntype="string" hint="The ids this parent's property holds according to the database. Read here rather than from stObject: the ajax facade merges posted properties into the loaded object before dispatch, so that copy of the relationship follows the request. bArraysAsStructs is what makes fourq skip the session temp store and the object broker; an extended array returns its elements as structs, so the id comes from the data column.">
		<cfargument name="typename" required="true" type="string" />
		<cfargument name="property" required="true" type="string" />
		<cfargument name="objectid" required="true" type="string" />

		<cfset var stParent = "" />
		<cfset var value = "" />
		<cfset var items = "" />
		<cfset var i = 0 />

		<cfif not structKeyExists(application.stCOAPI,arguments.typename)>
			<cfreturn "" />
		</cfif>

		<cftry>
			<!--- bArraysAsStructs must be numeric for fourq to honour it --->
			<cfset stParent = application.fapi.getContentType(arguments.typename).getData(objectid=arguments.objectid, bUseInstanceCache=false, bArraysAsStructs=1) />

			<cfcatch type="any">
				<cfreturn "" />
			</cfcatch>
		</cftry>

		<cfif not structKeyExists(stParent,arguments.property)>
			<cfreturn "" />
		</cfif>

		<cfreturn normaliseJoinValue(stParent[arguments.property]) />
	</cffunction>

	<cffunction name="normaliseJoinValue" access="private" output="false" returntype="string" hint="A relationship property reduced to a list of ids, whichever shape it arrives in: an array of ids, an array of structs for an extended array (the id is the data column), or a list on a non-array property.">
		<cfargument name="value" required="true" type="any" />

		<cfset var items = "" />
		<cfset var i = 0 />

		<cfif isArray(arguments.value)>
			<cfloop from="1" to="#arraylen(arguments.value)#" index="i">
				<cfif isStruct(arguments.value[i])>
					<cfif structKeyExists(arguments.value[i],"data") and isSimpleValue(arguments.value[i].data)>
						<cfset items = listappend(items, trim(arguments.value[i].data)) />
					</cfif>
				<cfelseif isSimpleValue(arguments.value[i])>
					<cfset items = listappend(items, trim(arguments.value[i])) />
				</cfif>
			</cfloop>
			<cfreturn items />
		</cfif>

		<cfif isSimpleValue(arguments.value)>
			<cfreturn arguments.value />
		</cfif>

		<cfreturn "" />
	</cffunction>

	<cffunction name="currentJoinItems" access="private" output="false" returntype="string" hint="The ids this field is currently holding for this parent. Normally that is the relationship in the database, but while a wizard is editing the record it is the wizard's working copy - the field renders from that copy, so it is what the field's own actions have to be judged against. Both are server held state written by a form submit, so neither is more authoritative than the other; taking the union means an item counts as attached if either says so.">
		<cfargument name="typename" required="true" type="string" hint="the parent's type" />
		<cfargument name="property" required="true" type="string" />
		<cfargument name="objectid" required="true" type="string" hint="the parent record" />

		<cfset var persisted = persistedJoinItems(argumentCollection=arguments) />
		<cfset var inwizard = wizardJoinItems(argumentCollection=arguments) />

		<cfif not len(persisted)>
			<cfreturn inwizard />
		</cfif>
		<cfif not len(inwizard)>
			<cfreturn persisted />
		</cfif>

		<cfreturn persisted & "," & inwizard />
	</cffunction>

	<cffunction name="wizardJoinItems" access="private" output="false" returntype="string" hint="The ids this parent's property holds in an open wizard belonging to the current user, or an empty string when there is none. A wizard calls setData once, on the first submit for an object, and from then until it completes it keeps the object in dmWizard.Data and writes only that - so a step change persists the relationship to the wizard and not to the join table. Deliberately does not use dmWizard.Read(), which creates a wizard when it finds none: an authorization check must not have side effects.">
		<cfargument name="typename" required="true" type="string" />
		<cfargument name="property" required="true" type="string" />
		<cfargument name="objectid" required="true" type="string" />

		<cfset var qWizard = "" />
		<cfset var stData = "" />
		<cfset var items = "" />
		<cfset var userlogin = "" />

		<cfif not len(trim(arguments.objectid)) or not application.security.isLoggedIn()>
			<cfreturn "" />
		</cfif>

		<cfset userlogin = application.security.getCurrentUserID() />

		<cftry>
			<!--- the user's own wizards only. PrimaryObjectID covers both ways a wizard starts:
			      Create() sets it from ReferenceID, which is the objectid for an existing record
			      and the freshly minted one for a new record. A record a wizard edits as a
			      secondary object is not found this way and falls back to the relationship in
			      the database, which is the behaviour this change exists to correct - so if that
			      shape ever appears, it presents as an item that will not edit or delete --->
			<cfquery datasource="#application.dsn#" name="qWizard">
				select		data
				from		dmWizard
				where		UserLogin = <cfqueryparam cfsqltype="cf_sql_varchar" value="#userlogin#" />
				and			PrimaryObjectID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
			</cfquery>

			<cfloop query="qWizard">
				<cfif isWDDX(qWizard.data)>
					<cfwddx action="WDDX2CFML" input="#qWizard.data#" output="stData" />

					<cfif isStruct(stData) and structKeyExists(stData,arguments.objectid)
							and structKeyExists(stData[arguments.objectid],arguments.property)>
						<cfset items = listappend(items, normaliseJoinValue(stData[arguments.objectid][arguments.property])) />
					</cfif>
				</cfif>
			</cfloop>

			<cfcatch type="any">
				<!--- an unreadable wizard describes no relationship --->
				<cfreturn "" />
			</cfcatch>
		</cftry>

		<cfreturn items />
	</cffunction>

	<cffunction name="directUploadBind" access="private" output="false" returntype="struct" hint="The facts an arrayupload direct upload is authorised against. Built identically at sign and at finalize, so a finalize presenting a different parent object, joined type or file property is refused.">
		<cfargument name="typename" required="true" type="string" />
		<cfargument name="stObject" required="true" type="struct" />
		<cfargument name="stMetadata" required="true" type="struct" />
		<cfargument name="location" required="true" type="string" />

		<cfreturn {
			"surface" = "arrayupload",
			"location" = arguments.location,
			"typename" = arguments.typename,
			"property" = arguments.stMetadata.name,
			"objectid" = arguments.stObject.objectid,
			"formtool" = structKeyExists(url,"formtool") ? url.formtool : "",
			"ftjoin" = arguments.stMetadata.ftJoin,
			"ftfileproperty" = arguments.stMetadata.ftFileProperty
		} />
	</cffunction>
	
	<cffunction name="resolveJoinUploadLocation" access="private" output="false" returntype="string" hint="Resolves the CDN location of the joined file property for uploads. An explicit ftLocation override always wins; an image defaults to images (ftSecure is a file-only concept); a secure file uses privatefiles; a non-secure file is status-aware (mirrors the file formtool read path), so a new unapproved item uploads to privatefiles until approval promotes it and an already-public item uploads to publicfiles.">
		<cfargument name="stMetadata" required="true" type="struct" />

		<cfset var stProp = application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata />
		<cfset var propType = structKeyExists(stProp,"ftType") ? stProp.ftType : "image" />
		<cfset var propLocation = structKeyExists(stProp,"ftLocation") ? stProp.ftLocation : "" />
		<cfset var propSecure = structKeyExists(stProp,"ftSecure") ? stProp.ftSecure : false />
		<cfset var stNewJoin = "" />
		<cfset var joinStatus = "" />
		<cfset var joinAnonView = false />

		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />

		<!--- An explicit ftLocation override always wins, regardless of type. --->
		<cfif len(propLocation)>
			<cfreturn propLocation />
		</cfif>
		<!--- file: ftSecure forces privatefiles. Otherwise status-aware, mirroring the
		      file formtool's read path (isSecured): a joined item is created unapproved
		      and no location move fires at create time, so the key signs to privatefiles
		      until approval (onApproved then promotes it); only an already-public target
		      signs to publicfiles. (ftSecure does not apply to images.) --->
		<cfif propType eq "file">
			<cfif isBoolean(propSecure) and propSecure>
				<cfreturn "privatefiles" />
			</cfif>
			<cfset stNewJoin = application.fapi.getNewContentObject(typename=arguments.stMetadata.ftJoin) />
			<cfset joinStatus = structKeyExists(stNewJoin,"status") ? stNewJoin.status : "" />
			<sec:CheckPermission objectid="#stNewJoin.objectid#" type="#arguments.stMetadata.ftJoin#" permission="View" roles="Anonymous" result="joinAnonView" />
			<cfif (joinStatus eq "" or joinStatus eq "approved") and joinAnonView>
				<cfreturn "publicfiles" />
			</cfif>
			<cfreturn "privatefiles" />
		</cfif>
		<!--- image: always defaults to images. --->
		<cfreturn "images" />
	</cffunction>

	<cffunction name="resolveJoinUploadRestrictions" access="private" output="false" returntype="struct" hint="Resolves the upload extension list + size limit from the joined file property, reading its ftType-appropriate formtool attributes (image: ftAllowedExtensions/ftSizeLimit; file: ftAllowedFileExtensions/ftMaxSize). COAPI merges each formtool's defaults into the property metadata, so an unset attribute resolves to the formtool default.">
		<cfargument name="stMetadata" required="true" type="struct" />

		<cfset var stProp = application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata />
		<cfset var propType = structKeyExists(stProp,"ftType") ? stProp.ftType : "image" />
		<cfset var stResult = { "extensions" = "", "sizeLimit" = 0 } />

		<cfif propType eq "file">
			<cfset stResult.extensions = structKeyExists(stProp,"ftAllowedFileExtensions") ? stProp.ftAllowedFileExtensions : "" />
			<cfset stResult.sizeLimit  = (structKeyExists(stProp,"ftMaxSize")  and isNumeric(stProp.ftMaxSize))  ? stProp.ftMaxSize  : 0 />
		<cfelse>
			<cfset stResult.extensions = structKeyExists(stProp,"ftAllowedExtensions") ? stProp.ftAllowedExtensions : "" />
			<cfset stResult.sizeLimit  = (structKeyExists(stProp,"ftSizeLimit") and isNumeric(stProp.ftSizeLimit)) ? stProp.ftSizeLimit : 0 />
		</cfif>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="handleFilePost" access="public" output="false" returntype="struct" hint="Handles image post and returns standard formtool result struct">
		<cfargument name="objectid" type="uuid" required="true" hint="The objectid of the edited object" />
		<cfargument name="uploadfield" type="string" required="true" hint="Traditional form saves will use <PREFIX><PROPERTY>NEW, ajax posts will use <PROPERTY>NEW ... so the caller needs to say which it is" />
		<cfargument name="destination" type="string" required="true" hint="Destination of file" />
		<cfargument name="location" type="string" required="true" hint="Destination of file" />
		<cfargument name="allowedExtensions" type="string" required="true" hint="The acceptable extensions" />
		<cfargument name="sizeLimit" type="string" required="false" default="0" hint="Maximum file size accepted" />
		<cfargument name="stFieldPost" type="struct" required="false" default="#structnew()#" hint="The supplementary data" />
		
		<cfset var uploadFileName = "" />
		<cfset var archivedFile = "" />
		<cfset var stResult = application.formtools.field.oFactory.passed("") />
		<cfset var stFile = structnew() />
		
		<cfparam name="stFieldPost.UPLOAD" default="" />
		
		<cfset stResult.bChanged = false />
		
		<!--- If developer has entered an ftDestination, make sure it starts with a slash --->
		<cfif len(arguments.destination) AND left(arguments.destination,1) NEQ "/">
			<cfset arguments.destination = "/#arguments.destination#" />
		</cfif>
		
	  	<cfif structkeyexists(form,arguments.uploadfield) and len(form[arguments.uploadfield])>
	  		
			<cftry>
				<cfset uploadFileName = application.fc.lib.cdn.ioUploadFile(location=arguments.location,destination=arguments.destination,acceptextensions=arguments.allowedExtensions,field=arguments.uploadfield,sizeLimit=arguments.sizeLimit,nameconflict="makeunique") />
				<cfset stResult = application.formtools.field.oFactory.passed(uploadFileName) />
				
				<cfcatch type="uploaderror">
					<cfset stResult = application.formtools.field.oFactory.failed(value=arguments.existingfile,message=cfcatch.message) />
				</cfcatch>
			</cftry>
			
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="ObjectID" required="true" type="UUID" hint="The objectid of the object that this field is part of.">
		<cfargument name="Typename" required="true" type="string" hint="the typename of the objectid.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var aField = ArrayNew(1) />
		<cfset var stResult = structNew()>	
		<cfset var i = "" />
			
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = "">
		<cfset stResult.stError = StructNew()>
		
		<cfif listLen(stFieldPost.value)>
			<cfloop list="#stFieldPost.value#" index="i">
				<cfset ArrayAppend(aField, i) />
			</cfloop>
		</cfif>
		
		<cfset stResult.value = aField>
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var html = "" />
		<cfset var i = 0 />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfsavecontent variable="html">	\
			<cfoutput><ul id="join-#stObject.objectid#-#arguments.stMetadata.name#" class="arrayDetailView" style="list-style-type:none;border:1px solid ##ebebeb;border-width:1px 1px 0px 1px;margin:0px;"></cfoutput>
			
			<cfloop from="1" to="#arraylen(joinItems)#" index="i"><cfoutput>
				<li id="join-item-#arguments.stMetadata.name#-#joinItems[i]#" class="" style="clear:both;border:1px solid ##ebebeb;padding:5px;zoom:1;">
					<skin:view objectid="#joinItems[i]#" typename="#arguments.stMetadata.ftJoin#" webskin="#arguments.stMetadata.ftLibrarySelectedWebskin#" r_html="htmlLabel" alternateHTML="OBJECT NO LONGER EXISTS" />
				</li>
			</cfoutput></cfloop>
		</cfsavecontent>
		
		
		<cfreturn html />
	</cffunction>	
	
	<!------------------ 
	FILTERING FUNCTIONS
	 ------------------>	
	<cffunction name="getFilterUIOptions">
		
		<cfreturn "related to" />
	</cffunction>
	
	<cffunction name="displayFilterUI">
		<cfargument name="filterType" />
		<cfargument name="stFilterProps" />
		
		<cfset var resultHTML = "" />
		<cfset var i = "" />
		<cfset var labelHTML = "" />
		

		<cfswitch expression="#arguments.filterType#">
			<cfcase value="related to">
				<cfparam name="arguments.stFilterProps.aRelated" default="#arrayNew(1)#" />
				<cfif arrayLen(arguments.stFilterProps.aRelated)>
					<cfloop from="1" to="#arrayLen(arguments.stFilterProps.aRelated)#" index="i">
						<skin:view objectid="#arguments.stFilterProps.aRelated[i]#" webskin="displayLabel" r_html="labelHTML" />
						<cfset resultHTML = listAppend(resultHTML, "#labelHTML#") />
					</cfloop>		
				</cfif>		
			</cfcase>		
		</cfswitch>
		<cfreturn resultHTML />
	</cffunction>
	
	<cffunction name="getFilterSQL">
		
		<cfargument name="filterTypename" />
		<cfargument name="filterProperty" />
		<cfargument name="filterType" default="relatedto" />
		<cfargument name="stFilterProps" />
		
		<cfset var resultHTML = "" />
		<cfset var stArrayPropMetadata = application.fapi.getPropertyMetadata(arguments.filterTypename, arguments.filterProperty) />
		
		<cfsavecontent variable="resultHTML">
			
			<cfswitch expression="#arguments.filterType#">
				
				<cfcase value="related to">
					<cfparam name="arguments.stFilterProps.aRelated" default="#arrayNew(1)#" />
					<cfif arrayLen(arguments.stFilterProps.aRelated)>

						<cfif stArrayPropMetadata.type EQ "array">
						
							<cfoutput>
								objectid IN (
									
									SELECT parentID
									FROM #arguments.filterTypename#_#arguments.filterProperty#
									WHERE data IN (#ListQualify(arrayToList(arguments.stFilterProps.aRelated),"'",",","ALL")#)
																						
								)
							</cfoutput>
						<cfelse>
							<cfoutput>#arguments.filterProperty# IN (#ListQualify(arrayToList(arguments.stFilterProps.aRelated),"'",",","ALL")#)</cfoutput>
						</cfif>
					</cfif>
				</cfcase>
				
			
			</cfswitch>
			
		</cfsavecontent>
		
		<cfreturn resultHTML />
	</cffunction>


</cfcomponent>