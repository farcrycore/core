<cfcomponent displayname="Array Upload" hint="A cross between the array and image formtools" extends="farcry.core.packages.formtools.field" output="false">

	<cfproperty name="ftJoin" required="true" default="" options="comma seperated list of types" hint="A single related content type e.g 'dmImage'"/>
	<cfproperty name="ftAllowSelect" required="false" default="true" options="true,false" hint="Allows user to select existing records within the library picker"/>
	<cfproperty name="ftAllowCreate" required="false" default="true" options="true,false" hint="Allows user create new record within the library picker"/>
	<cfproperty name="ftAllowEdit" required="false" default="false" options="true,false" hint="Allows user edit new record within the library picker"/>
	<cfproperty name="ftAllowRemoveAll" required="false" default="false" options="true,false" hint="Allows user to remove all items at once"/>
	<cfproperty name="ftRemoveType" required="false" default="remove" options="delete,detach" hint="detach will only remove from the join, delete will remove from the database"/><!--- detach or delete --->
	
	<cfproperty name="ftFileProperty" required="false" default="" hint="The property on the related type that the file is uploaded against. This defaults to sourceImage for dmImage and filename for dmFile. Other relationships must have an explicit value.">
	<cfproperty name="ftAllowedFileExtensions" required="false" default="" hint="The list of file extensions allowed. The default is to borrow the attribute on the related file property." />
	<cfproperty name="ftSizeLimit" required="false" default="" hint="The upload size limit. The default is to borrow the attribute on the related file property." />
	<cfproperty name="ftSimUploadLimit" required="false" default="3" hint="The maximum number of simultaneous uploads." />
	<cfproperty name="ftEditableProperties" required="false" default="" hint="If ftAllowEdit is enabled, this property restricts which properties are ediable. Note that using this value will switch the default edit dialog to a minimalist one suitable for front end use.">
	
	<cfproperty name="ftlibrarydatasqlwhere" required="false" default="" hint="A simple where clause filter for the library data result set. Must be in the form PROPERTY OPERATOR VALUE. For example, status = 'approved'"/><!--- detach or delete --->
	<cfproperty name="ftlibrarydatasqlorderby" required="false" default="datetimelastupdated desc" hint="Nominate a specific property to order library results by."/><!--- detach or delete --->
	
	<cfproperty name="ftView" default="list" type="string" options="tiled,list" hint="Allows the formtool to be switched between the traditional list view of normal array fields and a tiled view appropriate for images." />
	<cfproperty name="ftTileWidth" default="100" type="numeric" hint="Width of item tile" />
	<cfproperty name="ftTileHeight" default="100" type="numeric" hint="Height of item tile">
	
	<cfproperty name="ftListWebskin" default="librarySelected" type="string" hint="The webskin to use for items displayed in the form" />
	<cfproperty name="ftLibrarySelectedWebskin" default="librarySelected" type="string" hint="The webskin to use for items displayed in the library picker" />
	<cfproperty name="ftLibraryListItemWidth" default="" type="string" hint="???" />
	<cfproperty name="ftLibraryListItemHeight" default="" type="string" hint="???"/>
	<cfproperty name="ftFirstListLabel" default="-- SELECT --" hint="Used with ftRenderType, this is the value of the first element in the list"/>
	<cfproperty name="ftLibraryData" default="" hint="Name of a function to return the library data. By default will look for ./webskin/typename/librarySelected.cfm"/><!--- Name of a function to return the library data --->
	<cfproperty name="ftLibraryDataTypename" default="" hint="Typename containing the function defined in ftLibraryData"/><!--- Typename containing the function defined in ftLibraryData --->	
	
	
	
	<cffunction name="init" access="public" returntype="any" output="false" hint="Returns a copy of this initialised object">
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="This is going to called from ft:object and will always be passed 'typename,stobj,stMetadata,fieldname'.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="stPackage" required="true" type="struct" hint="Contains the metadata for the all fields for the current typename.">
				
		<cfset var htmlLabel = "" />
		<cfset var joinItems = "" />
		<cfset var i = "" />
		<cfset var counter = "" />
		<cfset var returnHTML = "" />
		<cfset var qArrayField = "" />
	    <cfset var prefix = left(arguments.fieldname,len(arguments.fieldname)-len(arguments.stMetadata.name)) />
	    
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
	    <cfif not len(arguments.stMetadata.ftAllowedFileExtensions) and isdefined("application.stCOAPI.#arguments.stMetadata.ftJoin#.stProps.#arguments.stMetadata.ftFileProperty#.metadata.ftAllowedFileExtensions") and len(application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftAllowedFileExtensions)>
			<cfset arguments.stMetadata.ftAllowedFileExtensions = application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftAllowedFileExtensions />
		<cfelseif not len(arguments.stMetadata.ftAllowedFileExtensions) and isdefined("application.stCOAPI.#arguments.stMetadata.ftJoin#.stProps.#arguments.stMetadata.ftFileProperty#.metadata.ftAllowedExtensions") and len(application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftAllowedExtensions)>
			<cfset arguments.stMetadata.ftAllowedFileExtensions = application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftAllowedExtensions />
		</cfif>
	    <cfif not len(arguments.stMetadata.ftSizeLimit) and isdefined("application.stCOAPI.#arguments.stMetadata.ftJoin#.stProps.#arguments.stMetadata.ftFileProperty#.metadata.ftSizeLimit") and len(application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftSizeLimit)>
			<cfset arguments.stMetadata.ftSizeLimit = application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftSizeLimit />
		<cfelse>
			<cfset arguments.stMetadata.ftSizeLimit = -1 />
		</cfif>
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
		<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
		
		
		<!--- SETUP stActions --->
		<cfset stActions.ftAllowSelect = arguments.stMetadata.ftAllowSelect />
		<cfset stActions.ftAllowCreate = arguments.stMetadata.ftAllowCreate />
		<cfset stActions.ftAllowEdit = arguments.stMetadata.ftAllowEdit />
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
		
		
		<skin:loadJS id="jquery" />
		<skin:loadJS id="jquery-ui" />
		<skin:loadCSS id="jquery-ui" />
	    <skin:loadJS id="jquery-uploadify" />
	    <skin:loadCSS id="jquery-uploadify" />
	    
		<skin:loadJS id="array-upload"><script type="text/javascript"><cfoutput>
		<!--- <skin:htmlHead id="array-upload-js"><cfoutput><script type="text/javascript"> --->
			// minimalist lightbox
			(function(fc,$){
				fc.openLB = function startOverlay(html,width,height,backgroundclose) {
					var newContent = $(html);
					width = width || 425;
					height = height || 355;
					
					//add the elements to the dom
					$("body")
						.append('<div class="fc-overlay" style="height:'+$(document).height()+'px;'+(backgroundclose>0?'cursor:pointer;':'')+'"></div>')
						.append('<div class="fc-overlaycontainer"></div>')
						.css({"overflow-y":"hidden"});
				
					//animate the semitransparant layer
					var overlay = $(".fc-overlay").animate({"opacity":"0.6"}, 400, "linear");
					if (backgroundclose>0) overlay.bind("click",function(){ fc.closeLB(); });
				
					//add the lightbox image to the DOM
					$(".fc-overlaycontainer")
						.html(html)
						.css({
							"top":        $(document).scrollTop()+$(window).height()/2,
							"left":       "50%",				
							"width":      width,
							"height":     height
						})
						.css({
							"margin-top": -($(".fc-overlaycontainer").height()/2),
							"margin-left": -($(".fc-overlaycontainer").width()/2) //to position it in the middle
						})
						.animate({"opacity":"1"}, 400, "linear")
						.find(".closeLB").bind("click",function(){ fc.closeLB();return false; });
					fc.lbContainer = $(".fc-overlaycontainer");
				};
				
				fc.closeLB = function removeOverlay() {
					// allow users to be able to close the lightbox
					$(".fc-overlaycontainer, .fc-overlay").animate({"opacity":"0"}, 200, "linear", function(){
						$(".fc-overlaycontainer, .fc-overlay").remove();
						$("body").css({"overflow-y":""});
					});
				};
				
				fc.updateLB = function(html){
					$(".fc-overlaycontainer").html(html);
				};
			})($fc,jQuery);
			
			(function($){
				if (!fcForm.arrayuploadwrapped){
					fcForm.arrayuploadwrapped = true;
					fcForm.editing = "";
					
					fcForm.traditionalOpenLibrarySelect = fcForm.openLibrarySelect;
					fcForm.openLibrarySelect = function(typename,objectid,property,id,urlparameters) {
						if (fcForm.arrayuploadfields[id]) fcForm.arrayuploadfields[id].beginSelect();
						fcForm.traditionalOpenLibrarySelect(typename,objectid,property,id,urlparameters);
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
		    			
		    			function getBytesOutput(bytes){
							var byteSize = Math.round(bytes / 1024 * 100) * .01;
							var suffix = 'KB';
							if (byteSize > 1000) {
								byteSize = Math.round(byteSize *.001 * 100) * .01;
								suffix = 'MB';
							};
							var sizeParts = byteSize.toString().split('.');
							if (sizeParts.length > 1) {
								byteSize = sizeParts[0] + '.' + sizeParts[1].substr(0,2);
							} else {
								byteSize = sizeParts[0];
							}
							return byteSize.toString() + suffix;
		    			};
		    			
		    			function getFilenameOutput(filename){
							if (filename.length > 20) return filename.substr(0,20) + '...';
							return filename;
		    			};
		    			
		    			this.init = function initArrayUploadFormtool(typename,objectid,url,filetypes,sizeLimit,uploadLimit,allowEdit,removeType,quickEdit,view,tilewidth,tileheight){
		    				var fieldname = prefix + property;
							arrayuploadformtool.displaylist = $("##join-"+objectid+"-"+property);
							arrayuploadformtool.uploadify = $("##"+fieldname+"UPLOAD");
							arrayuploadformtool.typename = typename;
							arrayuploadformtool.objectid = objectid;
							arrayuploadformtool.url = url;
							arrayuploadformtool.filetypes = filetypes;
							arrayuploadformtool.sizeLimit = sizeLimit;
							arrayuploadformtool.allowEdit = allowEdit;
							arrayuploadformtool.removeType = removeType;
							arrayuploadformtool.beforeSelect = [];
							arrayuploadformtool.quickEdit = quickEdit;
		    				
		    				if (view=="tiled")
								arrayuploadformtool.displaylist.sortable({ items:'li.sort', forceHelperSize:true, forcePlaceholderSize:true, tolerance:"pointer" });
		    				else
								arrayuploadformtool.displaylist.sortable({ items:'li.sort', axis:"y" });
							
							fcForm.arrayuploadfields = fcForm.arrayuploadfields || {};
							fcForm.arrayuploadfields[prefix+property] = arrayuploadformtool;
							
				    		arrayuploadformtool.uploadify.uploadify({
					    		'buttonText'	: 'Select File',
								'uploader'  	: '#application.url.webtop#/thirdparty/jquery.uploadify-v2.1.4/uploadify.swf',
								'script'    	: url+"/upload/1",
								'checkScript'	: url+"/check/1",
								'cancelImg' 	: '#application.url.webtop#/thirdparty/jquery.uploadify-v2.1.4/cancel.png',
								'hideButton'	: true,
								'wmode'			: "transparent",
								'auto'      	: true,
								'fileExt'		: filetypes,
								'multi'			: true,
								'queueID'		: 'join-'+objectid+'-'+property,
								'simUploadLimit': uploadLimit,
								'removeCompleted' : false,
								'fileDataName'	: property+"UPLOAD",
								'method'		: "POST",
								'scriptData'	: {},
								'sizeLimit'		: sizeLimit,
								'onSelect'		: function(event,ID,fileObj){
									arrayuploadformtool.displaylist.append(arrayuploadformtool.getHTML("uploaditem",{
										index 		: ($("> li",arrayuploadformtool.displaylist).size() + 1).toString(),
										ID 			: ID,
										filename	: getFilenameOutput(fileObj.name),
										filesize	: getBytesOutput(fileObj.size)
									}));
									arrayuploadformtool.displaylist.sortable("refresh");
									// attached related fields to uploadify post
									arrayuploadformtool.uploadify.uploadifySettings("scriptData",arrayuploadformtool.getPostValues());
									arrayuploadformtool.uploadify.uploadifyUpload();
									return false;
								},
								'onProgress'	: function(event,ID,fileObj,data){
									if (data.percentage<100)
										$("##"+fieldname+ID+"ProgressBar").animate({'width': data.percentage + '%'},250);	
									else
										$("##join-item-"+ID+" .uploadifyFeedback",arrayuploadformtool.displaylist).html("<span style='color:##0099FF;font-weight:bold;'>processing image...</span");
								},
								'onCancel'		: function(event,ID,fileObj,data){
									$("##join-item-"+ID,arrayuploadformtool.displaylist).remove();
								},
								'onComplete'	: function(event, ID, fileObj, response, data){
									var results = $.parseJSON(response);
									
									if (results.error && results.error.length){
										errorloc = $("##join-item-"+ID+" .uploadifyFeedback",arrayuploadformtool.displaylist).html("<span style='color:##FF0000;font-weight:bold;'>Server error: "+results.error+"</span>");
									}
									else {console.log(results);
										$("##join-item-"+ID,arrayuploadformtool.displaylist).replaceWith(arrayuploadformtool.getHTML("newitem",{
											itemid		: results.objectid,
											displayhtml : results.html
										}));
									};
								},
								'onError'		: function(event, ID, fileObj, errorObj){
									var errorloc = $("##fileupload-"+ID+" .uploadifyFeedback",arrayuploadformtool.displaylist);
									if (errorObj.type === "HTTP")
										errorloc.html("<span style='color:##FF0000;font-weight:bold;'>HTTP error: "+errorObj.status+"</span>");
									else if (errorObj.type ==="File Size")
										errorloc.html("<span style='color:##FF0000;font-weight:bold;'>File size: File is not within the file size limit of "+Math.round(sizeLimit/1048576).toString()+"MB</span>");
									else
										errorloc.html("<span style='color:##FF0000;font-weight:bold;'>"+errorObj.type+": "+errorObj.text+"</span>");
								},
								'onSWFReady'	: function(){
									var uploadaction = $("##uploadaction");
									$("###arguments.fieldname#-library-wrapper object").css({
										width			: uploadaction.width(),
										height			: uploadaction.height(),
										position		: "relative",
										left			: uploadaction.width()+5,
										top				: 4
									});
								}
							});
							
							$("> li",arrayuploadformtool.displaylist).live("mouseover",function(e){
								$(this).addClass("fc-grabbable");
							}).live("mouseout",function(e){
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
		    			
		    			this.getHTML = function(templateid,tempvars){
		    				var html = $.trim($("##"+templateid+"-"+prefix+property+", ##"+templateid).html());
		    				
		    				$.extend(tempvars,{
		    					typename 		: arrayuploadformtool.typename,
		    					objectid 		: arrayuploadformtool.objectid,
		    					url 			: arrayuploadformtool.url,
		    					prefix 			: prefix,
		    					property 		: property,
		    					fieldname 		: prefix+property,
								allowedit		: arrayuploadformtool.allowEdit,
								allowremove		: arrayuploadformtool.removeType=="remove",
								allowdelete		: arrayuploadformtool.removeType=="delete",
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
		    					html = html.replace(regexes[k],tempvars[k]);
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
									for (var i=0;i<data.length;i++)
										arrayuploadformtool.displaylist.append(arrayuploadformtool.getHTML("newitem",{
											itemid		: data[i].objectid,
											displayhtml : data[i].html
										}));
									arrayuploadformtool.displaylist.sortable("refresh");
								}
							});
		    			};
		    			
		    			this.removeItems = function(objectids){
		    				if (arrayuploadformtool.removeType=="delete"){
								$j.ajax({
									cache: false,
									type: "POST",
						 			url: arrayuploadformtool.url+"/delete/1",
									data: { 
										items:objectids.join(",")
									},
									dataType: "html",
									success: function(data){
										for (var i=0;i<objectids.length;i++) $("##join-item-"+objectids[i],arrayuploadformtool.displaylist).remove();
										arrayuploadformtool.displaylist.sortable("refresh");
									}
								});
		    				}
		    				else {
		    					for (var i=0;i<objectids.length;i++) {
		    						$("##join-item-"+objectids[i],arrayuploadformtool.displaylist).remove();
		    					}
		    					arrayuploadformtool.displaylist.sortable("refresh");
		    				};
		    			};
		    			
		    			this.removeAllItems = function(){
		    				arrayuploadformtool.removeItems(arrayuploadformtool.getSelected());
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
									dataType: "html",
									success: function(data){
										for (var i=0;i<data.length;i++)
											$("##join-item-"+data[i].objectid,arrayuploadformtool.displaylist).replaceWith(arrayuploadformtool.getHTML("newitem",{
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
		    				$("##join-item-"+objectid+" .fc-edit").html("<img src='#application.url.webtop#/images/indicator.gif' />");
							$.ajax({
								cache: false,
								type: "POST",
					 			url: arrayuploadformtool.url+"/edit/1",
								data: { 
									item:objectid
								},
								dataType: "html",
								success: function(data){
		    						$("##join-item-"+objectid+" .fc-edit").html("<span class='ui-icon ui-icon-pencil'></span>");
									$fc.openLB(data,"auto","auto",true);
								}
							});
		    			};
		    			
		    			this.saveItem = function(objectid,values){
		    				$(".buttonHolder",$fc.lbContainer).html("<img src='#application.url.webtop#/images/indicator.gif' />");
		    				var d = { "_objectid":objectid,"startindex":0 };
		    				for (var k in values) d["_"+k] = values[k];
							$.ajax({
								cache: false,
								type: "POST",
					 			url: arrayuploadformtool.url+"/update/1",
								data: d,
								dataType: "json",
								success: function(data){
									$("##join-item-"+data.objectid,arrayuploadformtool.displaylist).replaceWith(arrayuploadformtool.getHTML("newitem",{
										itemid		: data.objectid,
										displayhtml : data.html
									}));
									arrayuploadformtool.displaylist.sortable("refresh");
									$fc.closeLB();
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
		    				arrayuploadformtool.beforeSelect = arrayuploadformtool.getSelected();
		    				$("##"+prefix+property).val(arrayuploadformtool.beforeSelect.join(","));
		    			};
		    			
		    			this.finishSelect = function finishSelect(editid){
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
		    					if ($("##join-item-"+afterSelect[i],arrayuploadformtool.displaylist).size()==0) aAdd.push(afterSelect[i]);	
		    				}
		    				if (aAdd.length) arrayuploadformtool.addItems(aAdd);
		    				if (editid.length) arrayuploadformtool.refreshItems([ editid ]);
		    				$("##"+prefix+property).val("");
		    			}
		    			
		    		};		
		    		
		    		if (!this[prefix+property]) this[prefix+property] = new ArrayUploadFormtool(prefix,property);
		    		return this[prefix+property];
		    	};
			})(jQuery);
		</cfoutput></script></skin:loadJS>
		<!--- </script></cfoutput></skin:htmlHead> --->
		<skin:loadCSS id="array-upload"><style type="text/css"><cfoutput>
			.fc-overlay { position:absolute; top:0px; left:0px; height:100%; width:100%; background:##FFF; opacity:0; filter:alpha(opacity=0); z-index:150; }
			.fc-overlaycontainer { position:absolute; opacity:0; filter:alpha(opacity=0); left:-9999em; z-index:151; }
			
			.fc-arrayupload-item { zoom:1; }
				.fc-arrayupload-item a, .fc-arrayupload-item a:link, .fc-arrayupload-item a:visited, .fc-arrayupload-item a:hover, .fc-arrayupload-item a:active { background:##FFFFFF; }
				.uploadifyProgress { background-color:##E5E5E5;margin-top:10px; }
					.uploadifyProgressBar { background-color:##0099FF; height:3px; width:1px; }
				.fc-list-view { clear:both; padding:5px; }
					.fc-list-view-container { background-color:##FFF; cursor:pointer; width:100%; }
					.fc-list-view-table { width:100%; }
					.fc-list-view .uploadifyFeedback { width:50%; float:right; }
					.fc-list-view .fc-grabbar { width:10px; }
						.fc-grabbable.fc-list-view .fc-grabbar { background:url('#application.url.webtop#/images/draggable.gif') repeat-y; }
				.fc-tile-view { float:left; }
					.fc-tile-view .fc-tile-view-container { padding:10px; text-align:center; overflow:hidden; background-color:##FFF; cursor:pointer; }
						.fc-tile-view .fc-arrayupload-actions { float:right; }
					.fc-tile-view .fc-grabbar { float:left; display:none; margin-left:-8px; background:url('#application.url.webtop#/images/draggable.gif') repeat-y; width:8px; height:100%; }
						.fc-grabbable.fc-tile-view .fc-grabbar { display:block; }
		</cfoutput></style></skin:loadCSS>
	
		<cfsavecontent variable="returnHTML">	
			<grid:div class="multiField">
			
				<cfoutput><ul id="join-#stObject.objectid#-#arguments.stMetadata.name#" class="arrayDetailView" style="list-style-type:none;border:1px solid ##ebebeb;border-width:1px 1px 0px 1px;margin:0px;overflow:auto;"></cfoutput>
				
				<cfloop from="1" to="#arraylen(joinItems)#" index="i">
					<cfif arguments.stMetadata.ftView eq 'tiled'>
						<cfoutput>
							<li id="join-item-#joinItems[i]#" class="sort arrayupload-item fc-tile-view">
								<div class="fc-tile-view-container" style="width:#arguments.stMetadata.ftTileWidth#px;height:#arguments.stMetadata.ftTileHeight#px;">
									<div class="fc-grabbar">&nbsp;</div>
									<div class="fc-arrayupload-actions">
										<cfif stActions.ftAllowEdit>
											<a href="##" class="fc-edit" onclick="<cfif len(arguments.stMetadata.ftEditableProperties)>$fc.arrayuploadformtool('#prefix#','#arguments.stMetadata.name#').editItem('#joinItems[i]#');<cfelse>fcForm.openLibraryEdit('#arguments.typename#','#arguments.stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#','#joinItems[i]#');</cfif>return false;" title="Edit"><span class="ui-icon ui-icon-pencil"></span></a>
										</cfif>
										<cfif stActions.ftRemoveType EQ "delete">
											<a href="##" class="fc-remove" onclick="if (confirm('Are you sure you want to delete this item? Doing so will immediately remove this item from the database.')) $fc.arrayuploadformtool('#prefix#','#arguments.stMetadata.name#').removeItems([ '#joinItems[i]#' ]);return false;" title="Remove"><span class="ui-icon ui-icon-closethick"></span></a>
										<cfelseif stActions.ftRemoveType EQ "remove">
											<a href="##" class="fc-remove" onclick="if (confirm('Are you sure you want to remove this item? Doing so will only unlink this content item. The content will remain in the database.')) $fc.arrayuploadformtool('#prefix#','#arguments.stMetadata.name#').removeItems([ '#joinItems[i]#' ]);return false;" title="Remove"><span class="ui-icon ui-icon-closethick"></span></a>
										</cfif>
									</div>
									<input type="hidden" name="#arguments.fieldname#" value="#joinItems[i]#" />
									<skin:view objectid="#joinItems[i]#" typename="#arguments.stMetadata.ftJoin#" webskin="#arguments.stMetadata.ftListWebskin#" alternateHTML="OBJECT NO LONGER EXISTS" />
								</div>
							</li>
						</cfoutput>
					<cfelse>
						<cfoutput>
							<li id="join-item-#joinItems[i]#" class="sort fc-arrayupload-item fc-list-view">
								<div class="fc-list-view-container">
									<table class="fc-list-view-table">
										<tr>
											<td class="fc-grabbar">&nbsp;&nbsp;</td>
											<td class="" style="width:100%;padding:3px;"><input type="hidden" name="#arguments.fieldname#" value="#joinItems[i]#" />
												<skin:view objectid="#joinItems[i]#" typename="#arguments.stMetadata.ftJoin#" webskin="#arguments.stMetadata.ftListWebskin#" alternateHTML="OBJECT NO LONGER EXISTS" />
											</td>
											<td class="" style="padding:3px;white-space:nowrap;">
												<cfif stActions.ftAllowEdit>
													<a href="##" class="fc-edit" onclick="<cfif len(arguments.stMetadata.ftEditableProperties)>$fc.arrayuploadformtool('#prefix#','#arguments.stMetadata.name#').editItem('#joinItems[i]#');<cfelse>fcForm.openLibraryEdit('#arguments.typename#','#arguments.stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#','#joinItems[i]#');</cfif>return false;" title="Edit"><span class="ui-icon ui-icon-pencil"></span></a>
												</cfif>
												<cfif stActions.ftRemoveType EQ "delete">
													<a href="##" class="fc-remove" onclick="if (confirm('Are you sure you want to delete this item? Doing so will immediately remove this item from the database.')) $fc.arrayuploadformtool('#prefix#','#arguments.stMetadata.name#').removeItems([ '#joinItems[i]#' ]);return false;" title="Remove"><span class="ui-icon ui-icon-closethick"></span></a>
												<cfelseif stActions.ftRemoveType EQ "remove">
													<a href="##" class="fc-remove" onclick="if (confirm('Are you sure you want to remove this item? Doing so will only unlink this content item. The content will remain in the database.')) $fc.arrayuploadformtool('#prefix#','#arguments.stMetadata.name#').removeItems([ '#joinItems[i]#' ]);return false;" title="Remove"><span class="ui-icon ui-icon-closethick"></span></a>
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
				
				<ft:buttonPanel><cfoutput>
					<input type="file" name="#arguments.fieldname#UPLOAD" id="#arguments.fieldname#UPLOAD" />
					
					<ft:button	Type="button"
								renderType="button"
								class="ui-state-default ui-corner-all uploadaction"
								value="Upload"
								text="upload"
								id="uploadaction" />
					
				
					<cfif stActions.ftAllowSelect>
						<ft:button	Type="button" 
									renderType="button"
									class="ui-state-default ui-corner-all"
									value="select" 
									onClick="fcForm.openLibrarySelect('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#');return false;" />
						
					</cfif>
					
					<cfif arguments.stMetadata.ftAllowRemoveAll>
						<cfif stActions.ftRemoveType EQ "delete">
							<ft:button	Type="button" 
										renderType="button"
										class="ui-state-default ui-corner-all"
										value="Remove All" 
										text="remove all" 
										confirmText="Are you sure you want to delete the attached items? Doing so will immediately remove them from the database."
										onClick="$fc.arrayuploadformtool('#prefix#','#arguments.stMetadata.name#').removeAllItems();return false;" />
						<cfelseif stActions.ftRemoveType EQ "remove">
							<ft:button	Type="button" 
										renderType="button"
										class="ui-state-default ui-corner-all"
										value="Remove All" 
										text="remove all" 
										confirmText="Are you sure you want to remove the attached items? Doing so will only unlink them. The content will remain in the database."
										onClick="$fc.arrayuploadformtool('#prefix#','#arguments.stMetadata.name#').removeAllItems();return false;" />
							
						</cfif>
					</cfif>
					
				</cfoutput>	</ft:buttonPanel>
				
				<cfoutput><script type="text/javascript">$fc.arrayuploadformtool('#prefix#','#arguments.stMetadata.name#').init('#arguments.typename#','#arguments.stObject.objectid#','#application.formtools.field.oFactory.getAjaxURL(typename=arguments.typename,stObject=arguments.stObject,stMetadata=arguments.stMetadata,fieldname=arguments.fieldname,combined=true)#','#replace(rereplace(arguments.stMetadata.ftAllowedFileExtensions,"(^|,)(\w+)","\1*.\2","ALL"),",",";","ALL")#',#arguments.stMetadata.ftSizeLimit#,#arguments.stMetadata.ftSimUploadLimit#,#stActions.ftAllowEdit#,'#stActions.ftRemoveType#','#len(arguments.stMetadata.ftEditableProperties) gt 0#','#arguments.stMetadata.ftView#',#arguments.stMetadata.ftTileWidth#,#arguments.stMetadata.ftTileHeight#);</script></cfoutput>
				<cfif arguments.stMetadata.ftView eq 'tiled'>
					<cfoutput>
						<script type="text/template" id="uploaditem-#arguments.fieldname#">
							<li id="join-item-{{ID}}" class="sort fc-arrayupload-item fc-tile-view">
								<div class="fc-tile-view-container" style="width:#arguments.stMetadata.ftTileWidth#px;height:#arguments.stMetadata.ftTileHeight#px;">
									<div class="fc-grabbar">&nbsp;</div>
									<div class="fc-arrayupload-actions">
										<a href="javascript:$('##{{fieldname}}UPLOAD').uploadifyCancel('{{ID}}')" title="Cancel Upload">
											<span class="ui-icon ui-icon-closethick"></span>
										</a>
									</div>
									{{filename}} ({{filesize}})
									<div class="uploadifyFeedback">
										<div class="uploadifyProgress">
											<div id="{{fieldname}}{{ID}}ProgressBar" class="uploadifyProgressBar"><!--Progress Bar--></div>
										</div>
									</div>
								</div>
							</li>
						</script>
						<script type="text/template" id="newitem-#arguments.fieldname#">
							<li id="join-item-{{itemid}}" class="sort fc-arrayupload-item fc-tile-view">
								<div class="fc-tile-view-container" style="width:#arguments.stMetadata.ftTileWidth#px;height:#arguments.stMetadata.ftTileHeight#px;">
									<div class="fc-grabbar">&nbsp;</div>
									<div class="fc-arrayupload-actions">
										{{if-allowedit}}<a href="##" class="fc-edit" onclick="{{if-quickedit}}$fc.arrayuploadformtool('{{prefix}}','{{property}}').editItem('{{itemid}}');{{if-quickedit}}{{ifnot-quickedit}}fcForm.openLibraryEdit('{{typename}}','{{objectid}}','{{property}}','{{fieldname}}','{{itemid}}');{{ifnot-quickedit}}return false;" title="Edit"><span class="ui-icon ui-icon-pencil"></span></a>{{if-allowedit}}
										{{if-allowdelete}}<a href="##" class="fc-remove" onclick="if (confirm('Are you sure you want to delete this item? Doing so will immediately remove this item from the database.')) $fc.arrayuploadformtool('{{prefix}}','{{property}}').removeItems([ '{{itemid}}' ]);return false;" title="Remove"><span class="ui-icon ui-icon-closethick"></span></a>{{if-allowdelete}}
										{{if-allowremove}}<a href="##" class="fc-remove" onclick="if (confirm('Are you sure you want to remove this item? Doing so will only unlink this content item. The content will remain in the database.')) $fc.arrayuploadformtool('{{prefix}}','{{property}}').removeItems([ '{{itemid}}' ]);return false;" title="Remove"><span class="ui-icon ui-icon-closethick"></span></a>{{if-allowremove}}
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
							<li id="join-item-{{ID}}" class="sort fc-arrayupload-item fc-list-view">
								<div class="fc-list-view-container">
									<table class="fc-list-view-table">
										<tr>
											<td class="fc-grabbar">&nbsp;&nbsp;</td>
											<td class="" style="width:100%;padding:3px;">
												{{filename}} ({{filesize}})
												<div class="uploadifyFeedback">
													<div class="uploadifyProgress">
														<div id="{{fieldname}}{{ID}}ProgressBar" class="uploadifyProgressBar"><!--Progress Bar--></div>
													</div>
												</div>
											</td>
											<td class="" style="padding:3px;white-space:nowrap;">
												<a href="javascript:$('##{{fieldname}}UPLOAD').uploadifyCancel('{{ID}}')" title="Cancel Upload">
													<span class="ui-icon ui-icon-closethick"></span>
												</a>
											</td>
										</tr>
									</table>
								</div>
							</li>
						</script>
						<script type="text/template" id="newitem-#arguments.fieldname#">
							<li id="join-item-{{itemid}}" class="sort fc-arrayupload-item fc-list-view">
								<div class="fc-list-view-container">
									<table class="fc-list-view-table">
										<tr>
											<td class="fc-grabbar">&nbsp;&nbsp;</td>
											<td class="" style="width:100%;padding:3px;"><input type="hidden" name="{{fieldname}}" value="{{itemid}}" />{{displayhtml}}</td>
											<td class="" style="padding:3px;white-space:nowrap;">
												{{if-allowedit}}<a href="##" class="fc-edit" onclick="{{if-quickedit}}$fc.arrayuploadformtool('{{prefix}}','{{property}}').editItem('{{itemid}}');{{if-quickedit}}{{ifnot-quickedit}}fcForm.openLibraryEdit('{{typename}}','{{objectid}}','{{property}}','{{fieldname}}','{{itemid}}');{{ifnot-quickedit}}return false;" title="Edit"><span class="ui-icon ui-icon-pencil"></span></a>{{if-allowedit}}
												{{if-allowdelete}}<a href="##" class="fc-remove" onclick="if (confirm('Are you sure you want to delete this item? Doing so will immediately remove this item from the database.')) $fc.arrayuploadformtool('{{prefix}}','{{property}}').removeItems([ '{{itemid}}' ]);return false;" title="Remove"><span class="ui-icon ui-icon-closethick"></span></a>{{if-allowdelete}}
												{{if-allowremove}}<a href="##" class="fc-remove" onclick="if (confirm('Are you sure you want to remove this item? Doing so will only unlink this content item. The content will remain in the database.')) $fc.arrayuploadformtool('{{prefix}}','{{property}}').removeItems([ '{{itemid}}' ]);return false;" title="Remove"><span class="ui-icon ui-icon-closethick"></span></a>{{if-allowremove}}
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
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
		
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
	    <cfif not len(arguments.stMetadata.ftAllowedFileExtensions) and isdefined("application.stCOAPI.#arguments.stMetadata.ftJoin#.stProps.#arguments.stMetadata.ftFileProperty#.metadata.ftAllowedFileExtensions") and len(application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftAllowedFileExtensions)>
			<cfset arguments.stMetadata.ftAllowedFileExtensions = application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftAllowedFileExtensions />
		<cfelseif not len(arguments.stMetadata.ftAllowedFileExtensions) and isdefined("application.stCOAPI.#arguments.stMetadata.ftJoin#.stProps.#arguments.stMetadata.ftFileProperty#.metadata.ftAllowedExtensions") and len(application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftAllowedExtensions)>
			<cfset arguments.stMetadata.ftAllowedFileExtensions = application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftAllowedExtensions />
		</cfif>
	    <cfif not len(arguments.stMetadata.ftSizeLimit) and isdefined("application.stCOAPI.#arguments.stMetadata.ftJoin#.stProps.#arguments.stMetadata.ftFileProperty#.metadata.ftSizeLimit") and len(application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftSizeLimit)>
			<cfset arguments.stMetadata.ftSizeLimit = application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftSizeLimit />
		<cfelse>
			<cfset arguments.stMetadata.ftSizeLimit = -1 />
		</cfif>
		
		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
		
		<cfif structkeyexists(url,"check")>
			<cfreturn "[]" />
		</cfif>
		
		<cfif structkeyexists(url,"add")>
			<cfif not isdefined("form.items") or not len(form.items)>
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
			<cfif not isdefined("form.item") or not len(form.item)>
				<cfreturn "No item specified" />
			</cfif>
			
			<cfset request.mode.ajax = true />
			<cfsavecontent variable="html"><cfoutput>
				<div style="border: 1px solid ##c8c8c8\9;background-color:##FFFFFF;padding:15px;-webkit-box-shadow: 0 0 8px rgba(128,128,128,0.75);-moz-box-shadow: 0 0 8px rgba(128,128,128,0.75);box-shadow: 0 0 8px rgba(128,128,128,0.75);">
					<ft:form>
						<ft:object objectid="#form.item#" lFields="#arguments.stMetadata.ftEditableProperties#" r_stPrefix="editprefix" />
						<ft:buttonPanel>
							<a href="##" class="closeLB">cancel</a>&nbsp;<ft:button value="Save" onclick="var base={};var props='#arguments.stMetadata.ftEditableProperties#'.split(',');for (var i in props) base[props[i]]='';$fc.arrayuploadformtool('#prefix#','#arguments.stMetadata.name#').saveItem('#form.item#',getValueData(base,'#editprefix#'));return false;" />
						</ft:buttonPanel>
					</ft:form>
				</div>
			</cfoutput></cfsavecontent>
			
			<cfreturn html />
		</cfif>
		
		<cfif structkeyexists(url,"update")><!--- Update an array item --->
			<cfif not isdefined("form._objectid") or not len(form._objectid)>
				<cfreturn "No data specified" />
			</cfif>
			
			<!--- SETUP stActions --->
			<cfset stActions.ftAllowEdit = arguments.stMetadata.ftAllowEdit />
			<cfset stActions.ftRemoveType = arguments.stMetadata.ftRemoveType />
			
			<cfif arguments.stMetadata.ftRemoveType EQ "detach">
				<cfset stActions.ftRemoveType = "remove" />
			</cfif>
			
			<cfset stSource = structnew() />
			<cfset stSource.objectid = form["_objectid"] />
			<cfset stSource.typename = arguments.stMetadata.ftJoin />
			<cfloop list="#arguments.stMetadata.ftEditableProperties#" index="thisfield">
				<cfset stSource[thisfield] = form["_#thisfield#"] />
			</cfloop>
			<cfset application.fapi.setData(stProperties=stSource) />
			
			<cfset stJSON = structnew() />
			<cfset stJSON["objectid"] = stSource.objectid />
			<skin:view objectid="#stSource.objectid#" typename="#arguments.stMetadata.ftJoin#" webskin="#arguments.stMetadata.ftListWebskin#" alternateHTML="OBJECT NO LONGER EXISTS" r_html="html" />
			<cfset stJSON["html"] = html />
			
			<cfreturn serializeJSON(stJSON) />
		</cfif>
		
		<cfif structkeyexists(url,"delete")>
			<cfif not isdefined("form.items") or not len(form.items)>
				<cfreturn "[]" />
			</cfif>
			
			<cfset aItems = listtoarray(form.items) />
			<cfif arguments.stMetadata.ftRemoveType eq "delete">
				<cfset source = application.fapi.getContentType(arguments.stMetadata.ftJoin) />
				<cfloop from="1" to="#arraylen(aItems)#" index="i">
					<cfset source.deleteData(aItems[i]) />
				</cfloop>
			</cfif>
			
			<cfreturn serializeJSON(aItems) />
		</cfif>
		
		<cfif structkeyexists(url,"upload")><!--- Edit an array item --->
			<cfif application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftType eq "file">
				
				<cfset stResult = handleFilePost(
					objectid=arguments.stObject.objectid,
					uploadfield="#arguments.stMetadata.name#UPLOAD",
					relativeDestination=application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftDestination,
					absoluteDestination=application.path.defaultfilepath & application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftDestination,
					allowedExtensions=arguments.stMetadata.ftAllowedFileExtensions,
					stFieldPost=arguments.stFieldPost.stSupporting,
					sizeLimit=arguments.stMetadata.ftSizeLimit) />
				
			<cfelse><!--- File property is an image formtool --->
				
				<cfset stResult = handleFilePost(
					objectid=arguments.stObject.objectid,
					uploadfield="#arguments.stMetadata.name#UPLOAD",
					relativeDestination=application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftDestination,
					absoluteDestination=application.path.imageroot & application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftDestination,
					allowedExtensions=arguments.stMetadata.ftAllowedFileExtensions,
					stFieldPost=arguments.stFieldPost.stSupporting,
					sizeLimit=arguments.stMetadata.ftSizeLimit) />
					
			</cfif>
			
			<cfif isdefined("stResult.stError.message") and len(stResult.stError.message)>
				<cfset stJSON = structnew() />
				<cfset stJSON["error"] = stResult.stError.message />
				<cfset stJSON["value"] = stResult.value />
				<cfreturn serializeJSON(stJSON) />
			</cfif>
			
			<cfif stResult.bChanged and isdefined("stResult.value") and len(stResult.value)>
					
				<cfif application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata.ftType eq "file">
				
					<cfset stFile = getFileInfo(application.path.defaultfilepath & stResult.value) />
					
					<cfset stNewObject = application.fapi.getNewContentObject(typename=arguments.stMetadata.ftJoin) />
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
					<cfset stJSON["fullpath"] = application.path.fileroot & getDirectoryFromPath(stResult.value) & urlencodedformat(getFileFromPath(stResult.value)) />
					<cfset stJSON["size"] = round(stFile.size/1024) />
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
						<cfset stFixed = application.formtools.image.oFactory.fixImage("#application.path.imageroot##stResult.value#",application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata,arguments.stFieldPost.stSupporting.ResizeMethod,arguments.stFieldPost.stSupporting.Quality) />
						
						<cfset stJSON = structnew() />
						<cfset stNewObject = application.fapi.getNewContentObject(typename=arguments.stMetadata.ftJoin) />
						<cfset stNewObject.label = listfirst(listlast(stResult.value,"/"),".") />
						<cfif structkeyexists(application.stCOAPI[arguments.stMetadata.ftJoin].stProps,"title")>
							<cfset stNewObject.title = stNewObject.label />
						</cfif>
						<cfif structkeyexists(application.stCOAPI[arguments.stMetadata.ftJoin].stProps,"name")>
							<cfset stNewObject.name = stNewObject.label />
						</cfif>
						<cfset stNewObject[arguments.stMetadata.ftFileProperty] = stResult.value />
						<cfloop collection="#application.stCOAPI[arguments.stMetadata.ftJoin].stProps#" item="thisfield">
							<cfif isdefined("application.stCOAPI.#arguments.stMetadata.ftJoin#.stProps.#thisfield#.metadata.ftType") 
								and application.stCOAPI[arguments.stMetadata.ftJoin].stProps[thisfield].metadata.ftType eq "image"
								and isdefined("application.stCOAPI.#arguments.stMetadata.ftJoin#.stProps.#thisfield#.metadata.ftSourceField")
								and listfirst(application.stCOAPI[arguments.stMetadata.ftJoin].stProps[thisfield].metadata.ftSourceField,":") eq arguments.stMetadata.ftFileProperty>
								
								<cfset stFP[thisfield] = structnew() />
								
							</cfif>
						</cfloop>
						<cfset stNewObject = application.formtools.image.oFactory.ImageAutoGenerateBeforeSave(typename=stNewObject.typename,stProperties=stNewObject,stFields=application.stCOAPI[arguments.stMetadata.ftJoin].stProps,stFormPost=stFP) />
						<cfset application.fapi.setData(stProperties=stNewObject) />
						
						<cfif structkeyexists(application.formtools.image.oFactory,"onFileChange")>
							<cfset application.formtools.image.oFactory.onFileChange(typename=arguments.stMetadata.ftJoin,objectid=stNewObject.objectid,stMetadata=application.stCOAPI[arguments.stMetadata.ftJoin].stProps[arguments.stMetadata.ftFileProperty].metadata,value=stResult.value) />
						</cfif>
						
						<cfset stFile = getFileInfo(application.path.imageroot & stResult.value) />
						
						<cfimage action="info" source="#application.path.imageroot##stResult.value#" structName="stImage" />
						<cfset stJSON["objectid"] = stNewObject.objectid />
						<cfset stJSON["value"] = stResult.value />
						<cfset stJSON["filename"] = listlast(stResult.value,'/') />
						<cfset stJSON["fullpath"] = application.url.imageroot & getDirectoryFromPath(stResult.value) & urlencodedformat(getFileFromPath(stResult.value)) />
						<cfset stJSON["size"] = round(stFile.size/1024) />
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
		
		<cfreturn "{}" />
	</cffunction>
	
	<cffunction name="handleFilePost" access="public" output="false" returntype="struct" hint="Handles image post and returns standard formtool result struct">
		<cfargument name="objectid" type="uuid" required="true" hint="The objectid of the edited object" />
		<cfargument name="uploadfield" type="string" required="true" hint="Traditional form saves will use <PREFIX><PROPERTY>NEW, ajax posts will use <PROPERTY>NEW ... so the caller needs to say which it is" />
		<cfargument name="relativeDestination" type="string" required="true" hint="Destination of file" />
		<cfargument name="absoluteDestination" type="string" required="true" hint="Destination of file" />
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
		<cfif len(arguments.relativeDestination) AND left(arguments.relativeDestination,1) NEQ "/">
			<cfset arguments.relativeDestination = "/#arguments.relativeDestination#" />
		</cfif>
		
		<cfif NOT DirectoryExists(arguments.absoluteDestination)>
			<cfdirectory action="create" directory="#arguments.absoluteDestination#" mode="777" />
		</cfif>
		
	  	<cfif structkeyexists(form,arguments.uploadfield) and len(form[arguments.uploadfield])>
	  	
			<cffile action="upload" filefield="#arguments.uploadfield#" destination="#arguments.absoluteDestination#" nameconflict="MakeUnique" mode="664" result="stFile" />
			
			<cfif arguments.sizeLimit and arguments.sizeLimit lt stFile.fileSize>
				<cffile action="delete" file="#arguments.absoluteDestination#/#stFile.ServerFile#" />
				<cfset stResult = application.formtools.field.oFactory.failed(value="",message="#stFile.serverfile# is not within the file size limit of #round(arguments.sizeLimit/1048576)#MB") />
			<cfelseif listFindNoCase(arguments.allowedExtensions,stFile.serverFileExt)>
				<cfset stResult = application.formtools.field.oFactory.passed("#arguments.relativeDestination#/#stFile.ServerFile#") />
	    		<cfset stResult.bChanged = true />
			<cfelse>
				<cffile action="delete" file="#arguments.absoluteDestination#/#stFile.ServerFile#" />
				<cfset stResult = application.formtools.field.oFactory.failed(value="",message="Files must have one of these extensions: #arguments.allowedExtensions#") />
			</cfif>
			
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
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfsavecontent variable="html">	\
			<cfoutput><ul id="join-#stObject.objectid#-#arguments.stMetadata.name#" class="arrayDetailView" style="list-style-type:none;border:1px solid ##ebebeb;border-width:1px 1px 0px 1px;margin:0px;"></cfoutput>
			
			<cfloop from="1" to="#arraylen(joinItems)#" index="i"><cfoutput>
				<li id="join-item-#joinItems[i]#" class="" style="clear:both;border:1px solid ##ebebeb;padding:5px;zoom:1;">
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