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
						
							
				function openLibrary(target,ftJoin,url) {
					win=window.open(url + '&ftJoin=' + ftJoin, target);
					win.focus();
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
								aInputs = $$("#" + fieldname + "_list input");
								aInputs.each(function(child) {
									child.checked = true;
								});
							}
							function toggleOffArrayField(fieldname) {
								aInputs = $$("#" + fieldname + "_list input");
								aInputs.each(function(child) {
									child.checked = false;
								});
							}
							
							function deleteSelectedFromArrayField(fieldname,virtualDir){
								if(virtualDir==null){virtualDir="";}							
								aInputs = $$("#" + fieldname + "_list input");
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
							new Ajax.Updater(fieldname + '-libraryCallback', virtualDir+'/webtop/facade/library.cfc?method=ajaxUpdateArray&noCache=' + Math.random(), {
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
						
						aInputs = $$("#" + fieldname + "_list input");
						aInputs.each(function(child) {
							if(child.checked == true){
								Element.remove(fieldname + '_' + child.value);
							}
						});
						
						$(fieldname).value = Sortable.sequence(fieldname + '_list');
						libraryCallbackUUID(fieldname,'remove',$(fieldname).value);
					}
					
					function libraryCallbackUUID(fieldname,action,ids,virtualDir){
						if(virtualDir==null){virtualDir="";}	
						$(fieldname).value = ids;	
						var objParams = eval('obj' + fieldname);										
						var sURLParams = "LibraryType=UUID&Action=" + action + '&DataObjectID=' + encodeURIComponent($(fieldname).value);
						for (i in objParams){
							sURLParams+= "&" + i + "=" + objParams[i];							
						}
						
						
						
						new Ajax.Updater(fieldname + '-libraryCallback', virtualDir+'/webtop/facade/library.cfc?method=ajaxUpdateArray&noCache=' + Math.random(), {
							//onLoading:function(request){Element.show('indicator')},
							parameters:sURLParams, evalScripts:true, asynchronous:true,
							onComplete:function(request){
								if($(fieldname).value.length){
									Element.show(fieldname + '-librarySummary')
								} else {
									Element.hide(fieldname + '-librarySummary')
								}
							}
						})
						
												
					}
					
				