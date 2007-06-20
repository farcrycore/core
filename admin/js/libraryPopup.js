						
						
							
				function openLibrary(target,ftJoin,url) {
					win=window.open(url + '&ftJoin=' + ftJoin, target);
					win.focus();
				}
				
				
				function initArrayField(fieldname) {
						// <![CDATA[
							  Sortable.create(fieldname + '_list',
							  	{ghosting:false,constraint:false,hoverclass:'over',handle:fieldname + '_listhandle',
							    onChange:function(element){
							    	$(fieldname).value = Sortable.sequence(fieldname + '_list');
							    },
							    onUpdate:function(element){
							    	libraryCallbackArray(fieldname, 'sort', $(fieldname).value);
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
							
							function deleteSelectedFromArrayField(fieldname){								
								aInputs = $$("#" + fieldname + "_list input");
								aInputs.each(function(child) {
									if(child.checked == true){
										Element.remove(fieldname + '_' + child.value);
									}
								});
								
								libraryCallbackArray(fieldname,'sort',Sortable.sequence(fieldname + '_list'));
								
							}
									
						function libraryCallbackArray(fieldname,action,ids){
							$(fieldname).value = ids;							
												
							var objParams = eval('obj' + fieldname);
							var sURLParams = "LibraryType=Array&Action=" + action + '&DataObjectID=' + encodeURIComponent($(fieldname).value);
							for (i in objParams){
								sURLParams+= "&" + i + "=" + objParams[i];							
							}
														
							
							new Ajax.Updater(fieldname + '-libraryCallback', '/farcry/facade/library.cfc?method=ajaxUpdateArray&noCache=' + Math.random(), {
									//onLoading:function(request){Element.show('indicator')},
									onComplete:function(request){
										// <![CDATA[
											Sortable.create(fieldname + '_list',
										  	{ghosting:false,constraint:false,hoverclass:'over',handle:fieldname + '_listhandle',
										    onChange:function(element){
										    	$(fieldname).value = Sortable.sequence(fieldname + '_list');
										    },
											    onUpdate:function(element){
										   			libraryCallbackArray(fieldname,'sort',$(fieldname).value);
											    }
											  });
											$(fieldname).value = Sortable.sequence(fieldname + '_list');
										// ]]>
									},
									
									parameters:sURLParams, evalScripts:true, asynchronous:true
							})
											
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
					
					function libraryCallbackUUID(fieldname,action,ids){
						$(fieldname).value = ids;	
						var objParams = eval('obj' + fieldname);										
						var sURLParams = "LibraryType=UUID&Action=" + action + '&DataObjectID=' + encodeURIComponent($(fieldname).value);
						for (i in objParams){
							sURLParams+= "&" + i + "=" + objParams[i];							
						}
						
						
						
						new Ajax.Updater(fieldname + '-libraryCallback', '/farcry/facade/library.cfc?method=ajaxUpdateArray&noCache=' + Math.random(), {
							//onLoading:function(request){Element.show('indicator')},
							parameters:sURLParams, evalScripts:true, asynchronous:true
						})
						
												
					}
					
				