<cfoutput>
				function farcryButtonOnMouseOver(id) {
					$(id + '-outer').addClassName('farcryButtonWrap-outer-hover');
					$(id + '-inner').addClassName('farcryButtonWrap-inner-hover');
				}
				function farcryButtonOnClick(id) {
					$(id + '-outer').addClassName('farcryButtonWrap-outer-click');
					$(id + '-inner').addClassName('farcryButtonWrap-inner-click');
				}
				function farcryButtonOnMouseOut(id) {
					$(id + '-outer').removeClassName('farcryButtonWrap-outer-hover');
					$(id + '-inner').removeClassName('farcryButtonWrap-inner-hover');
					$(id + '-outer').removeClassName('farcryButtonWrap-outer-click');
					$(id + '-inner').removeClassName('farcryButtonWrap-inner-click');
				}
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
					f = $$('.fc-selected-object-id');
					for(var i=0; i<f.length; i++){
						f[i].value=objectid;
					}
				}	
							
				function openLibrary(target,ftJoin,url) {
					win=window.open(url + '&ftJoin=' + ftJoin, target);
					win.focus();
				}
				
				function editLibrarySelected (aSelected,primaryID,primaryTypename,ftLibraryEditWebskin,primaryFieldName,primaryFormFieldName,LibraryType) {
					for (i=0; i<aSelected.length; i++) {
						if (aSelected[i].checked) {

							openLibraryEditWindow(primaryID,primaryTypename,aSelected[i].value,ftLibraryEditWebskin,primaryFieldName,primaryFormFieldName,LibraryType)

							//only edit first selected item
							return true;
						}
					}
						
					alert('Please select an item to edit');
					return false;
				}
				
				function openLibraryEditWindow(primaryID,primaryTypename,dataID,ftLibraryEditWebskin,primaryFieldName,primaryFormFieldName,LibraryType) {

					url = '#application.url.webtop#/facade/libraryEdit.cfm?primaryID=' + primaryID + '&primaryTypename=' + primaryTypename + '&dataID=' + dataID + '&ftLibraryEditWebskin=' + ftLibraryEditWebskin + '&primaryFieldName=' + primaryFieldName + '&primaryFormFieldName=' + primaryFormFieldName + '&LibraryType=' + LibraryType;
					openLibrary('_blank', '', url);
					return true;
				}
				
				function initArrayField(fieldname,virtualDir) {
						// <![CDATA[
							 if(virtualDir==null){virtualDir="";}
							  Sortable.create(fieldname + '_list',
							  	{ghosting:false,constraint:false,hoverclass:'over',handle:fieldname + '_listhandle',
							    onChange:function(element){
							    	$(fieldname).value = Sortable.sequence(fieldname + '_list');
							    },
							    onUpdate:function(element){
							    	libraryCallbackArray(fieldname, 'sort', $(fieldname).value,virtualDir);
							    }
							  });
						// ]]>

				}

						
							function toggleOnArrayField(fieldname) {
								aInputs = $$("##" + fieldname + "_list input");
								aInputs.each(function(child) {
									child.checked = true;
								});
							}
							function toggleOffArrayField(fieldname) {
								aInputs = $$("##" + fieldname + "_list input");
								aInputs.each(function(child) {
									child.checked = false;
								});
							}
							
							function deleteSelectedFromArrayField(fieldname,virtualDir){
								if(virtualDir==null){virtualDir="";}							
								aInputs = $$("##" + fieldname + "_list input");
								aInputs.each(function(child) {
									if(child.checked == true){
										Element.remove(fieldname + '_' + child.value);
									}
								});
								
								libraryCallbackArray(fieldname,'sort',Sortable.sequence(fieldname + '_list'),virtualDir);
								
							}
						
						

									
						function libraryCallbackArray(fieldname,action,ids,virtualDir,callingWindow){
							$(fieldname).value = ids;						
							if(virtualDir==null){virtualDir="";}				
							var objParams = eval('obj' + fieldname);
							var sURLParams = "LibraryType=Array&Action=" + action + '&DataObjectID=' + encodeURIComponent($(fieldname).value);
							for (i in objParams){
								sURLParams+= "&" + i + "=" + objParams[i];							
							}
														
							$(fieldname + '-libraryCallback').innerHTML = 'PLEASE WAIT... CURRENTLY UPDATING';
							new Ajax.Updater(fieldname + '-libraryCallback', '#application.url.webtop#/facade/library.cfc?method=ajaxUpdateArray&ajaxmode=1&noCache=' + Math.random(), {
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
							})
											
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
		f = Ext.query('.fc-selected-object-id');
		for(var i=0; i<f.length; i++){
			f[i].value=objectid;
		}
	}	
			
function newFarcryButton (id,type,size,value,text,icon,overIcon,iconPos,sprite,width,formName,onClick,disabled) {
	var dh = Ext.DomHelper;
	
	var btn = Ext.get(id);
	var btnWrap = Ext.get(id + '-wrap');
	var btnMarkup = btnWrap.dom.innerHTML;
	
	var newBtnMarkup = 	'<table style="width: auto;" id="' + id + '-tbl-wrap" class="f-btn " cellspacing="0">' +
						'<tbody class="f-btn-' + size + ' f-btn-icon-' + size + '-' + iconPos +'">' +
							'<tr>' +
								'<td class="f-btn-tl f-btn-bg"><i>&nbsp;</i></td>' +
								'<td class="f-btn-tc f-btn-bg"></td>' +
								'<td class="f-btn-tr f-btn-bg"><i>&nbsp;</i></td>' +
							'</tr>' +
							'<tr>' +
								'<td class="f-btn-ml f-btn-bg"><i>&nbsp;</i></td>' +
								'<td class="f-btn-mc f-btn-bg" onclick="' + onClick + '"><em class="" unselectable="on">' +
									btnMarkup  +
								'</em></td>' +
								'<td class="f-btn-mr f-btn-bg"><i>&nbsp;</i></td>' +
							'</tr>' +
							'<tr>' +
								'<td class="f-btn-bl f-btn-bg"><i>&nbsp;</i></td>' +
								'<td class="f-btn-bc f-btn-bg"></td>' +
								'<td class="f-btn-br f-btn-bg"><i>&nbsp;</i></td>' +
							'</tr>' +
						'</tbody>' +
					'</table>'
					 
	dh.overwrite(btnWrap,newBtnMarkup);

	var newBtn = Ext.get(id + '-tbl-wrap');
	
	
	<!--- THIS STOPS SUBMIT BUTTONS SUBMITTING. ENABLING JS TO DO ALL THE WORK. --->
	Ext.get(id).on('click', this.onClick, this, {
		preventDefault:true,
		fn: function() { 
		}
	});
	
	
	if (sprite != null && sprite != '') {
		Ext.select('##' + id + '-tbl-wrap .f-btn-bg').applyStyles('background-image:url(' + sprite +');');
	}
	if (icon != null && icon != '') {
		Ext.select('##' + id + '-tbl-wrap button').applyStyles('background-image:url(' + icon +');');
		if (text != null && text != '') {
			newBtn.addClass('f-btn-text-icon');
		} else {
			newBtn.addClass('f-btn-icon');
		}
	} else {
		newBtn.addClass('f-btn-noicon');
	}
	
	if (width != null && width != '') {
		Ext.select('##' + id + '-tbl-wrap .f-btn-mc').applyStyles('width:' + width +';');
	}

	
	if (disabled == 'yes') {
		Ext.select('##' + id + '-tbl-wrap').addClass('f-btn-disabled');
	} else {
	
		Ext.select('##' + id + '-tbl-wrap .f-btn-mc').on('mouseover', this.onClick, this, {
		    fn: function() { 
		    	newBtn.addClass('f-btn-over'); 
				if (overIcon != null && overIcon != '') {
					Ext.select('##' + id + '-tbl-wrap button').applyStyles('background-image:url(' + overIcon +');');	
					
				}		    	
		    }
		});	
		Ext.select('##' + id + '-tbl-wrap .f-btn-mc').on('mouseout', this.onClick, this, {
		    fn: function() { 
		    	newBtn.removeClass('f-btn-over'); 
		    	newBtn.removeClass('f-btn-pressed');
				if (overIcon != null && overIcon != '') {
					Ext.select('##' + id + '-tbl-wrap button').applyStyles('background-image:url(' + icon +');');		
				}		 
		    }
		});
		Ext.select('##' + id + '-tbl-wrap .f-btn-mc').on('mousedown', this.onClick, this, {
		    fn: function() { 
		    	newBtn.addClass('f-btn-pressed'); 
		    }
		});
		Ext.select('##' + id + '-tbl-wrap .f-btn-mc').on('mouseup', this.onClick, this, {
		    fn: function() { 
		    	newBtn.removeClass('f-btn-pressed'); 
		    }
		});
	


	}
		
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
	
function btnSubmit(formName,value) {
   	f = Ext.query('.fc-button-clicked');
   	for(var i=0; i<f.length; i++){
		f[i].value = value;
	}
	if (formName != '') {	
		Ext.get(formName).dom.submit();
	}
}		

</cfoutput>					