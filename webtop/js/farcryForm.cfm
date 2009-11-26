<cfoutput>
	//==================================================================================
	// ftWatch JavaScript
	// These three functions provide ajax update functionality for fields.
	//==================================================================================
	function getInputValue(name) {
		var objs = $j("[name="+name+"]");
		var result = "";
		
		// input doesn't exist
		if (!objs.length) {
			return "";
		}
		// checkbox
		else if (objs.get(0).tagName=="INPUT" && objs.get(0).type == 'checkbox') {
			result = [];
			objs.each(function(el){
				if (el.checked) result.push(el.value);
			});
			return result.join();
		}
		// radio
		else if (objs.get(0).tagName=="INPUT" && objs.get(0).type == 'radio') {
			objs = $j("[name="+name+"][type=radio]");
			if (objs.length)
				return objs.get(0).value;
			else
				return "";
		}
		// select
		else if (objs.get(0).tagName=="SELECT") {
			result = [];
			for (var i=0;i<objs.get(0).options.length;i++)
				if (objs.get(0).options[i].selected) result.push(objs.get(0).options[i].value);
			return result;
		}
		// everything else: text, password, hidden, etc
		else {
			result = [];
			objs.each(function(el){
				result.push(el.value);
			});
			return result.join();
		}
	};
	
	function addWatch(prefix,property,opts) {
		watchedfields[prefix] = watchedfields[prefix] || {};
		watchingfields[prefix] = watchingfields[prefix] || {};
		
		if (!watchedfields[prefix][property]) { // if the property doesn't have a watch attached already, do so
			$j("select[name="+prefix+property+"], input[name="+prefix+property+"][type=text], input[name="+prefix+property+"][type=password]").bind("change",{ prefix:prefix, property: property },ajaxUpdate);
			$j("input[name="+prefix+property+"][type=checkbox], input[name="+prefix+property+"][type=radio]").bind("click",{ prefix:prefix, property: property },ajaxUpdate);
			$j("input[name="+prefix+property+"][type=hidden]").each(function(el){
				var lastvalue = el.value;
				setInterval(function(){
					if (el.value !== lastvalue) {
						lastvalue = el.value;
						var ev = { data:{ prefix:prefix, property: property } };
						el.call(ajaxUpdate,ev);
					}
				},100);
			});
		}
		
		watchedfields[prefix][property] = watchedfields[prefix][property] || [];
		watchedfields[prefix][property].push(opts);
		
		watchingfields[prefix][opts.property] = watchingfields[prefix][opts.property] || [];
		watchingfields[prefix][opts.property].push(opts);
	};
	
	function ajaxUpdate(event) {
		var values = {};
		
		// for each watcher
		for (var i=0; i<watchedfields[event.data.prefix][event.data.property].length; i++) {
			watcher = watchedfields[event.data.prefix][event.data.property][i];
			
			// include the watcher in the form post
			values[watcher.property] = "";
			
			// find out what each one is watching
			for (var j=0; j<watchingfields[event.data.prefix][watcher.property].length; j++)
				// add these properties to the form post
				values[watchingfields[event.data.prefix][watcher.property][j].watchedproperty] = "";
		}
		
		// get the post values
		for (var property in values)
			values[property] = getInputValue(event.data.prefix+property);
		
		// for each watcher
		for (var i=0; i<watchedfields[event.data.prefix][event.data.property].length; i++) {
			(function(watcher){
				// post the AJAX request
				$j("##"+watcher.prefix+watcher.property+"ajaxdiv").html(watcher.ftLoaderHTML).load('#application.url.farcry#/facade/ftajax.cfm?ajaxmode=1&formtool='+watcher.formtool+'&typename='+watcher.typename+'&fieldname='+watcher.fieldname+'&property='+watcher.property+'&objectid='+watcher.objectid,
					values,
					function(response){
						$j("##"+watcher.fieldname+"ajaxdiv").html(response.responseText);
						
						// if the updated field is also being watched, reattach the events
						if (watchedfields[watcher.prefix] && watchedfields[watcher.prefix][watcher.property] && watchedfields[watcher.prefix][watcher.property].length){
							$j("select[name="+watcher.prefix+watcher.property+"], input[name="+watcher.prefix+event.data.property+"][type=text], input[name="+watcher.prefix+watcher.property+"][type=password]").bind("change",{ prefix: watcher.prefix, property: watcher.property },ajaxUpdate);
							$j("input[name="+watcher.prefix+watcher.property+"][type=checkbox], input[name="+watcher.prefix+watcher.property+"][type=radio]").bind("click",{ prefix: watcher.prefix, property: watcher.property },ajaxUpdate);
						}
					}
				);
			})(watchedfields[event.data.prefix][event.data.property][i]);
		}
	};
				
				function farcryButtonURL(id,url,target) {
					if (target == 'undefined' || target == '_self'){
						location.href=url;			
						return false;
					} else {
						win = window.open('',target);	
						win.location=url;	
						win.focus;			
						return false;
					}
				}						
							
				function selectObjectID(objectid) {
					$j('.fc-selected-object-id').attr('value',objectid);
					<!--- for(var i=0; i<f.length; i++){
						f[i].value=objectid;
					} --->
				}	
							
				function openLibrary(target,ftJoin,url) {
					win=window.open(url + '&ftJoin=' + ftJoin, target);
					win.focus();
				}
				
				function openLibraryEditWindow(primaryID,primaryTypename,dataID,ftLibraryEditWebskin,primaryFieldName,primaryFormFieldName,LibraryType) {

					url = '#application.url.webtop#/facade/libraryEdit.cfm?primaryID=' + primaryID + '&primaryTypename=' + primaryTypename + '&dataID=' + dataID + '&ftLibraryEditWebskin=' + ftLibraryEditWebskin + '&primaryFieldName=' + primaryFieldName + '&primaryFormFieldName=' + primaryFormFieldName + '&LibraryType=' + LibraryType;
					openLibrary('_blank', '', url);
					return true;
				}
				function editLibrarySelected (aSelected,primaryID,primaryTypename,ftLibraryEditWebskin,primaryFieldName,primaryFormFieldName,LibraryType) {
					for (i=0; i<aSelected.length; i++) {
						if (aSelected[i].checked) {

							openLibraryEditWindow(primaryID,primaryTypename,aSelected[i].value,ftLibraryEditWebskin,primaryFieldName,primaryFormFieldName,LibraryType);

							//only edit first selected item
							return true;
						}
					}
						
					alert('Please select an item to edit');
					return false;
				}
				
						function libraryCallbackArray(fieldname,action,ids,virtualDir,callingWindow){
												
							if(virtualDir===null){virtualDir="";}
							$j('##' + fieldname).attr('value',ids);					
							var objParams = eval('obj' + fieldname);
							var sURLParams = "LibraryType=Array&Action=" + action + '&DataObjectID=' + encodeURIComponent($j('##' + fieldname).attr('value'));
							for (i in objParams){
								sURLParams+= "&" + i + "=" + objParams[i];							
							}
														
							$j('##' + fieldname + '-libraryCallback').html('PLEASE WAIT... CURRENTLY UPDATING');
								
							$j.ajax({
							   type: "POST",
							   url: "#application.url.webtop#/facade/library.cfc?method=ajaxUpdateArray&ajaxmode=1",
							   data: sURLParams,
							   cache: false,
							   success: function(msg){
									$j('##' + fieldname + '-libraryCallback').html(msg);
									initArrayField(fieldname,virtualDir);
									$j('##' + fieldname).attr('value',ids);		
									
									if($j('##' + fieldname).attr('value').length){
										$j('##' + fieldname + '-librarySummary').show();
									} else {
										$j('##' + fieldname + '-librarySummary').hide();
									}
									if(callingWindow!=null){callingWindow.close();}								     	
							   }
							 });

							
		
							<!--- new Ajax.Updater(fieldname + '-libraryCallback', '#application.url.webtop#/facade/library.cfc?method=ajaxUpdateArray&ajaxmode=1&noCache=' + Math.random(), {
									//onLoading:function(request){Element.show('indicator')},
									onComplete:function(request){
										// <![CDATA[
											Sortable.create(fieldname + '_list',
										  	{ghosting:false,constraint:false,hoverclass:'over',handle:fieldname + '_listhandle',
										    onChange:function(element){
										    	$(fieldname).value = Sortable.sequence(fieldname + '_list');
										    },
											    onUpdate:function(element){
										   			libraryCallbackArray(fieldname,'sort',$(fieldname).value,virtualDir);
											    }
											  });
											$(fieldname).value = Sortable.sequence(fieldname + '_list');
											if($(fieldname).value.length){
												Element.show(fieldname + '-librarySummary')
											} else {
												Element.hide(fieldname + '-librarySummary')
											}
											if(callingWindow!=null){callingWindow.close();}	
										// ]]>
									},
									
									parameters:sURLParams, evalScripts:true, asynchronous:true
							}) --->
											
						}
								
				

				function initArrayField(fieldname,virtualDir) {
						
					 if(virtualDir===null){virtualDir="";}
					 
					 var listID = '##' + fieldname + '_list';
					 $j(function() {
						$j(listID).sortable({
							update: function(event,ui){
								$j('##' + fieldname).attr("value",$j(listID).sortable('toArray',{'attribute':'serialize'}));
								libraryCallbackArray(fieldname, 'sort', $j('##' + fieldname).attr("value"),virtualDir);
							}
						});
						$j(listID).disableSelection();
						
					});
						
<!---
							 Sortable.create(fieldname + '_list',
							  	{ghosting:false,constraint:false,hoverclass:'over',handle:fieldname + '_listhandle',
							    onChange:function(element){
							    	$(fieldname).value = Sortable.sequence(fieldname + '_list');
							    },
							    onUpdate:function(element){
							    	libraryCallbackArray(fieldname, 'sort', $(fieldname).value,virtualDir);
							    }
							  });
						 --->

				}
						
							function toggleOnArrayField(fieldname) {
								$j("##" + fieldname + "_list input").attr('checked',true);
<!--- 								aInputs = $$("##" + fieldname + "_list input");
								aInputs.each(function(child) {
									child.checked = true;
								}); --->
							}
							function toggleOffArrayField(fieldname) {
								$j("##" + fieldname + "_list input").attr('checked',false);
								<!--- aInputs = $$("##" + fieldname + "_list input");
								aInputs.each(function(child) {
									child.checked = false;
								}); --->
							}
							
							function deleteSelectedFromArrayField(fieldname,virtualDir){
								if(virtualDir===null){virtualDir="";}	
								var listID = '##' + fieldname + '_list';
								var newList = '';								
								
								$j("##" + fieldname + "_list input").each(function() {
									if(!this.checked){
										newList = ListAppend(newList,this.value);
									}									
								});
								$j('##' + fieldname).attr('value',newList);										

								libraryCallbackArray(fieldname,'sort',$j('##' + fieldname).attr("value"),virtualDir);
								
							}
						
						function ListAppend(l, v, d){
							l += ""; // cheap way to convert to a string
							if(!d){d = ",";}
							var r = "";
							if (this.ListLen(l)){
								r = l + d + v;
							} else {
								r = v;
							}
							return r;
						}

						function ListLen(l,d){
							l += ""; // cheap way to convert to a string
							if(!d){d = ",";}
							if(l.length){return l.split(d).length;}
							return 0;
						}
							
				
				function initUUIDField(fieldname,virtualDir) {
						// <![CDATA[
							 if(virtualDir==null){virtualDir="";}
							  Sortable.create(fieldname + '_list',
							  	{ghosting:false,constraint:false,hoverclass:'over',handle:fieldname + '_listhandle',
							    onChange:function(element){
							    	$(fieldname).value = Sortable.sequence(fieldname + '_list');
							    },
							    onUpdate:function(element){
							    	libraryCallbackUUID(fieldname, 'sort', $(fieldname).value,virtualDir);
							    }
							  });
						// ]]>

				}
									
					function deleteSelectedFromUUIDField(fieldname){
						
						aInputs = $$("##" + fieldname + "_list input");
						aInputs.each(function(child) {
							if(child.checked == true){
								Element.remove(fieldname + '_' + child.value);
							}
						});
						
						$(fieldname).value = Sortable.sequence(fieldname + '_list');
						libraryCallbackUUID(fieldname,'remove',$(fieldname).value);
					}
					
					function libraryCallbackUUID(fieldname,action,ids,virtualDir,callingWindow){
						if(virtualDir==null){virtualDir="";}	
						$(fieldname).value = ids;	
						var objParams = eval('obj' + fieldname);										
						var sURLParams = "LibraryType=UUID&Action=" + action + '&DataObjectID=' + encodeURIComponent($(fieldname).value);
						for (i in objParams){
							sURLParams+= "&" + i + "=" + objParams[i];							
						}
						
						
						
						new Ajax.Updater(fieldname + '-libraryCallback', '#application.url.webtop#/facade/library.cfc?method=ajaxUpdateArray&ajaxmode=1&noCache=' + Math.random(), {
							//onLoading:function(request){Element.show('indicator')},
							parameters:sURLParams, evalScripts:true, asynchronous:true,
							onComplete:function(request){
								if($(fieldname).value.length){
									Element.show(fieldname + '-librarySummary')
								} else {
									Element.hide(fieldname + '-librarySummary')
								}
								if(callingWindow!=null){callingWindow.close();}	
							}
						})
						
												
					}
					
					
function createFormtoolTree(fieldname,rootID,dataURL,rootNodeText,selectedIDs,iconCls){
	// shorthand
    var Tree = Ext.tree;
    var checkRoot = false;
    
    tree = new Tree.TreePanel({
        animate:true, 
        loader: new Tree.TreeLoader({
            dataUrl:dataURL,
            baseAttrs: {checked:false,iconCls:'categoryIconCls'},
            baseParams: {selectedObjectIDs:selectedIDs}
        }),
        enableDD:true,
        containerScroll: true,
        border:false
    });

	tree.on('checkchange', function(n,c) {
		var newList = "";
		var currentTreeList = Ext.getDom(fieldname).value;
		if(c){ 
			if(currentTreeList.length){
		  		currentTreeList = currentTreeList + ','
		  	}
			Ext.getDom(fieldname).value = currentTreeList + n.id
		} else {
			var valueArray = currentTreeList.split(",");
			for(var i=0; i < valueArray.length; i++){
			  //do something by accessing valueArray[i];
			  if(n.id != valueArray[i]){
			  	if(newList.length){
			  		newList = newList + ',';
			  	}
			  	newList = newList + valueArray[i]
			  }
			}
			Ext.getDom(fieldname).value = newList;
		}	

	});
	
	if(selectedIDs.match(rootID)){
		checkRoot = true;
	}
	
    // set the root node
    var root = new Tree.AsyncTreeNode({
        text: rootNodeText,
        draggable:false,
        id:rootID,
        iconCls:iconCls,
        checked:checkRoot
    });
    tree.setRootNode(root);

    // render the tree
    tree.render(fieldname + '-tree-div');
    root.expand();
    
}

				
				
	function selectedObjectID(objectid) {
		$j('.fc-selected-object-id').attr('value',objectid);
		<!--- f = Ext.query('.fc-selected-object-id');
		for(var i=0; i<f.length; i++){
			f[i].value=objectid;
		} --->
	}	
	
	
function validateBtnClick(formName) {
	var btnValidation = new Validation(formName, {onSubmit:false});
	if(btnValidation.validate()) {return true} else {return false};
}
	
function btnURL(url,target) {
	if (target == 'undefined' || target == '_self'){
		location.href=url;			
		return false;
	} else {
		win = window.open('',target);	
		win.location=url;	
		win.focus;			
		return false;
	}
}		

	
function btnClick(formName,value) {
	$j('.fc-button-clicked').attr('value',value);
<!---    	f = Ext.query('.fc-button-clicked');
   	for(var i=0; i<f.length; i++){
		f[i].value = value;
	} --->
}

function btnTurnOnServerSideValidation() {
	$j('.fc-server-side-validation').attr('value',1);
	<!--- f = Ext.query('.fc-server-side-validation');
   	for(var i=0; i<f.length; i++){
		f[i].value = 0;
	} --->
}function btnTurnOffServerSideValidation() {
	$j('.fc-server-side-validation').attr('value',0);
	<!--- f = Ext.query('.fc-server-side-validation');
   	for(var i=0; i<f.length; i++){
		f[i].value = 0;
	} --->
}
	
		
function btnSubmit(formName,value) {
   	btnClick(formName,value);
	if (formName != '') {
		$j('##' + formName).submit();	
		<!--- Ext.get(formName).dom.submit(); --->
	}
}
		
function farcryForm_ajaxSubmission(formname,action,maskMsg,maskCls,ajaxTimeout){
	var a = action ? action : $j('##' + formname).attr('action');
	if (maskMsg == undefined){var maskMsg = 'Form Submitting, please wait...'};
	if (maskCls == undefined){var maskCls = 'mask-ajax-submission'};
	if (ajaxTimeout == undefined){var ajaxTimeout = 30}; // the number of seconds to wait
	
	if (ajaxTimeout > 0) {
		ajaxTimeout = ajaxTimeout * 1000; // convert to milliseconds
	}
	
	$j("##" + formname).mask(maskMsg);
	$j.ajax({
	   type: "POST",
	   url: a,
	   data: $j("##" + formname).serialize(),
	   cache: false,
	   timeout: ajaxTimeout,
	   success: function(msg){
	   		$j("##" + formname + 'formwrap').unmask();
			$j('##' + formname + 'formwrap').html(msg);						     	
	   }
	 });
}

<!--- A function to check all checkboxes on a form --->
function checkUncheckAll(theElement) {
	var theForm = theElement.form, z = 0;
	for(z=0; z<theForm.length;z++) {
		if(theForm[z].type == 'checkbox' && theForm[z].name != 'checkall') {
			theForm[z].checked = theElement.checked;
			setRowBackground(theForm[z]);
		}
	}
}




function setRowBackground (childCheckbox) {
	var row = childCheckbox.parentNode;
	while (row && row.tagName.toLowerCase() != 'tr') {
		row = row.parentNode;
	}
	if (row && row.style) {
		if (childCheckbox.checked) {
			row.style.backgroundColor = '##F9E6D4';
		}
		else {
			row.style.backgroundColor = '';
		}
	}
}		

</cfoutput>					