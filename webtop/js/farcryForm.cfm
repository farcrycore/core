<cfsetting enablecfoutputonly="true">

<cfoutput>
<cfsilent><script></cfsilent><!--- trick editor to highlight syntax --->

	if(typeof($fc) == 'undefined'){
		var $fc = {};
	}
	
	
	//==================================================================================
	// ftWatch JavaScript
	// These three functions provide ajax update functionality for fields.
	//==================================================================================
	
	$fc.watchedfields = {};
	$fc.watchingfields = {};
	$fc.watchingtracker = {};
	$fc.watchloading = 0;
		
	function addWatch(prefix,property,opts) {
		//setup watch tracking objects
		$fc.watchedfields[prefix] = $fc.watchedfields[prefix] || {};
		$fc.watchingfields[prefix] = $fc.watchingfields[prefix] || {};
		$fc.watchingtracker[prefix] = $fc.watchingtracker[prefix] || {};
		$fc.watchingtracker[prefix][property] = $fc.watchingtracker[prefix][property] || {};
		
		//add the watches
		$j("select[name="+prefix+property+"], input[name="+prefix+property+"][type=text], input[name="+prefix+property+"][type=password]").on("change",{ prefix:prefix, property: property },ajaxUpdate);
		$j("input[name="+prefix+property+"][type=checkbox], input[name="+prefix+property+"][type=radio]").on("click",{ prefix:prefix, property: property },ajaxUpdate);
		var el = $j("input[name="+prefix+property+"][type=hidden]");
		if (el.size()){
			var lastvalue = el.val();
			setInterval(function(){
				var el = $j("input[name="+prefix+property+"][type=hidden]");
				if (el.val() !== lastvalue) {
					lastvalue = el.val();
					var ev = { data:{ prefix:prefix, property: property } };
					ajaxUpdate.call(el[0],ev);
				}
			},100);
		};
		
		
		// if the property hasn't had its watch setup already, do so
		if ($fc.watchingtracker[prefix][property][opts.property] === undefined ) { 
				
			//setup property watch tracking arrays
			$fc.watchedfields[prefix][property] = $fc.watchedfields[prefix][property] || [];
			$fc.watchedfields[prefix][property].push(opts);
			
			$fc.watchingfields[prefix][opts.property] = $fc.watchingfields[prefix][opts.property] || [];
			$fc.watchingfields[prefix][opts.property].push(opts);
			
			//setup the tracker so we know which watches have been setup even after an ajax call.
			$fc.watchingtracker[prefix][property][opts.property] = '';
		}
	};
	
	function getFormData(){
		var result = {};

		$j('input,select,textarea').each(function(){
			var self = $j(this), name = self.attr("name");

			result[name] = result[name] || [];

			if ((!(self.is("[type=radio]") || self.is("[type=radio]")) || self.is(":checked")) && self.val()!=="")
				result[name].push(self.val());
		});

		for (var k in result)
			result[k] = result[k].join();

		return result;
	};

	function getValueData(base,prefix){
		var formdata = getFormData();

		base = base || {};
		var property = "";
		
		// get the post values
		for (var property in base) {
			if (formdata[prefix+property])
				base[property] = formdata[prefix+property];
			else
				base[property] = "";
		}
		
		return base;
	};
	
	function ajaxUpdate(event) {
		var values = {};
		var reenable = [];
		
		if ($fc.watchloading==0) {
			// for each watcher
			for (var i=0; i<$fc.watchedfields[event.data.prefix][event.data.property].length; i++) {
				watcher = $fc.watchedfields[event.data.prefix][event.data.property][i];
				
				// include the watcher in the form post
				values[watcher.property] = "";
				
				// find out what each one is watching
				for (var j=0; j<$fc.watchingfields[event.data.prefix][watcher.property].length; j++)
					// add these properties to the form post
					values[$fc.watchingfields[event.data.prefix][watcher.property][j].watchedproperty] = "";
			}
			
			// get the post values
			values = getValueData(values,event.data.prefix);
			
			// for each watcher
			for (var i=0; i<$fc.watchedfields[event.data.prefix][event.data.property].length; i++) {
				$fc.watchloading++;
				(function(watcher){
					// post the AJAX request
					$j("##"+watcher.prefix+watcher.property+"ajaxdiv").html(watcher.ftLoaderHTML).load('#application.url.webtop#/facade/ftajax.cfm?ajaxmode=1&formtool='+watcher.formtool+'&typename='+watcher.typename+'&fieldname='+watcher.fieldname+'&property='+watcher.property+'&objectid='+watcher.objectid,
						values,
						function(response){
							$j("##"+watcher.fieldname+"ajaxdiv").html(response.responseText);
							
							// if the updated field is also being watched, reattach the events
							if ($fc.watchedfields[watcher.prefix] && $fc.watchedfields[watcher.prefix][watcher.property] && $fc.watchedfields[watcher.prefix][watcher.property].length){
								$j("select[name="+watcher.prefix+watcher.property+"], input[name="+watcher.prefix+watcher.property+"][type=text], input[name="+watcher.prefix+watcher.property+"][type=password]").bind("change",{ prefix:watcher.prefix, property: watcher.property },ajaxUpdate);
								$j("input[name="+watcher.prefix+watcher.property+"][type=checkbox], input[name="+watcher.prefix+watcher.property+"][type=radio]").bind("click",{ prefix:watcher.prefix, property: watcher.property },ajaxUpdate);
								reenable.push("select[name="+watcher.prefix+watcher.property+"], input[name="+watcher.prefix+watcher.property+"][type=text], input[name="+watcher.prefix+watcher.property+"][type=password]");
								reenable.push("input[name="+watcher.prefix+watcher.property+"][type=checkbox], input[name="+watcher.prefix+watcher.property+"][type=radio]");
							}
							
							$fc.watchloading--;
							if ($fc.watchloading) $j(reenable.join()).attr("disabled",false);
						}
					);
				})($fc.watchedfields[event.data.prefix][event.data.property][i]);
			}
		}
	};
	
	// note: this should only be used on simple, single object forms
	function ajaxClear() {
		var values = {};
		var prefix = "";
		var property = ""; 
		var thisproperty = "";
		var reenable = $j([]);
		
		for (prefix in $fc.watchedfields);
		for (property in $fc.watchedfields[prefix]);
		
		if ($fc.watchloading==0) {
			// for each watcher
			for (var i=0; i<$fc.watchedfields[prefix][property].length; i++) {
				watcher = $fc.watchedfields[prefix][property][i];
				
				// include the watcher in the form post
				values[watcher.property] = "";
				
				// find out what each one is watching
				for (var j=0; j<$fc.watchingfields[prefix][watcher.property].length; j++)
					// add these properties to the form post
					values[$fc.watchingfields[prefix][watcher.property][j].watchedproperty] = "";
			}
			
			// get the post values
			for (var thisproperty in values) {
				if ($j('##' + prefix+thisproperty).val()) {
					values[thisproperty] = $j('##' + prefix+thisproperty).val();
					if (values[thisproperty].join) values[thisproperty] = values[thisproperty].join();
				}
			}
			
			// for each watcher
			for (var i=0; i<$fc.watchedfields[prefix][property].length; i++) {
				$fc.watchloading++;
				(function(watcher){
					// post the AJAX request
					$j("##"+watcher.prefix+watcher.property+"ajaxdiv").html(watcher.ftLoaderHTML).load('#application.url.farcry#/facade/ftajax.cfm?ajaxmode=1&formtool='+watcher.formtool+'&typename='+watcher.typename+'&fieldname='+watcher.fieldname+'&property='+watcher.property+'&objectid='+watcher.objectid,
						values,
						function(response){
							$j("##"+watcher.fieldname+"ajaxdiv").html(response.responseText);
							
							// if the updated field is also being watched, reattach the events
							if ($fc.watchedfields[watcher.prefix] && $fc.watchedfields[watcher.prefix][watcher.property] && $fc.watchedfields[watcher.prefix][watcher.property].length){
								$j("select[name="+watcher.prefix+watcher.property+"], input[name="+watcher.prefix+watcher.property+"][type=text], input[name="+watcher.prefix+watcher.property+"]:not([type]), input[name="+watcher.prefix+watcher.property+"][type=password]").bind("change",{ prefix: watcher.prefix, property: watcher.property },ajaxUpdate).disable();
								$j("input[name="+watcher.prefix+watcher.property+"][type=checkbox], input[name="+watcher.prefix+watcher.property+"][type=radio]").bind("click",{ prefix: watcher.prefix, property: watcher.property },ajaxUpdate).disable();
							}
							
							$fc.watchloading--;
							//if ($fc.watchloading) reenable.enable();
						}
					);
				})($fc.watchedfields[prefix][property][i]);
			}
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
	}	

	function selectedObjectID(objectid) {
		$j('.fc-selected-object-id').attr('value',objectid);
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
	}

	function btnTurnOnServerSideValidation() {
		$j('.fc-server-side-validation').attr('value',1);
	}

	function btnTurnOffServerSideValidation() {
		$j('.fc-server-side-validation').attr('value',0);
	}
		
			
	function btnSubmit(formName,value) {
	   	btnClick(formName,value);
		if (formName != '') {
			$j('##' + formName).submit();	
		}
	}
			
	function farcryForm_ajaxSubmission(formname,action,maskMsg,maskCls,ajaxTimeout,ajaxTarget){
		var a = action ? action : $j('##' + formname).attr('action');
		if (maskMsg == undefined){var maskMsg = 'Form Submitting, please wait...'};
		if (maskCls == undefined){var maskCls = 'mask-ajax-submission'};
		if (ajaxTimeout == undefined){var ajaxTimeout = 30}; // the number of seconds to wait
		if (ajaxTarget == undefined){var ajaxTarget = "##" + formname + "formwrap"; }; // The ajax update target
		
		if (ajaxTimeout > 0) {
			ajaxTimeout = ajaxTimeout * 1000; // convert to milliseconds
		}
		
		if(maskMsg.length){
			$j("##" + formname).mask(maskMsg);
		}
		$j.ajax({
		   type: "POST",
		   url: a,
		   data: $j("##" + formname).serialize(),
		   dataType: "html",
		   cache: false,
		   timeout: ajaxTimeout,
		   success: function(msg){
		   		if(maskMsg.length){
		   			$j(ajaxTarget).unmask();
				}
				$j(ajaxTarget).html(msg);						     	
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
		$j(childCheckbox).parents("tr").first().toggleClass("selected");
	}		

	function updateSelectedObjectIDs (childCheckbox) {
		var input = $j(childCheckbox).parents("form").find("input[name=SelectedObjectID]"), curvals = input.val().split(",");
		
		if (curvals.indexOf(this.value))
			curvals.splice(curvals.indexOf(this.value),1);
		else
			curvals.push(this.value);
		
		input.val(curvals.join(","));
	}		


	<!--- DIALOGS --->

	$fc.openDialog = function(title,url,width,height,settings) {
		settings = $j.extend({
			title: title,
			url: url
		}, settings);

		return $fc.openBootstrapModal(settings);
	};	

	$fc.openDialogIFrame = function(title,url,width,height,settings) {
		settings = $j.extend({
			title: title,
			url: url
		}, settings);

		return $fc.openBootstrapModal(settings);
	};


	$fc.objectAdminAction = function(title,url,settings) {

		settings = $j.extend({
			title: title,
			url: url
		}, settings);

		return $fc.openBootstrapModal(settings);		
	};


	$fc.objectAdminTrayAction = function(title,url,settings) {

		settings = $j.extend({
			title: title,
			url: url
		}, settings);

		var fcTrayModalTPL = $j("<div class='fc-tray'><div id='fcModal' class='modal hide fc-modal' style='' tabindex='-1' role='dialog' aria-labelledby='fcModalLabel' aria-hidden='true'><div class='modal-header'><button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button><h3 id='fcModalLabel'>Modal</h3></div><div class='modal-body' style='width: auto;min-height: 0px;max-height:900px;height: 455px;position: relative;border: 0;padding: 0;background: 0;-webkit-overflow-scrolling:touch;overflow: auto;zoom: 1;'><iframe style='width: 100%;height: 99%;border-width: 0px;margin: 0;padding: 0;' frameborder='0'></iframe></div></div></div>");
		$j("body").append(fcTrayModalTPL);

		return $fc.openBootstrapModal(settings);		
	};



	$fc.closeBootstrapModal = function(){	
		parent.$j('##fcModal').modal('hide');	
	}	

	$fc.openBootstrapModal = function($settings){

		$settings = $j.extend({
			keyboard: false,
			backdrop: 'static',
			width: $j(window).width() - 40,
			height: $j(window).height() - 40,
			title: 'Administration',
			url: '',
			onShown: function() {
				return true;
			},
			onHidden: function() {
				window.location.href = window.location.href.split('##')[0];
				return true;
			}
		}, $settings);

		var modalLeftPos = 0;
		var fcModalTPL = $j("<div id='fcModal' class='modal hide fade fc-modal' style='' tabindex='-1' role='dialog' aria-labelledby='fcModalLabel' aria-hidden='true'><div class='modal-header'><button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button><h3 id='fcModalLabel'>Modal</h3></div><div class='modal-body' style='width: auto;min-height: 0px;max-height:900px;height: 455px;position: relative;border: 0;padding: 0;background: 0;-webkit-overflow-scrolling:touch;overflow: auto;zoom: 1;'><iframe style='width: 100%;height: 99%;border-width: 0px;margin: 0;padding: 0;' frameborder='0'></iframe></div></div>");

		var $fcModal = $j("##fcModal");

		if($fcModal.length == 0) {
			$j("body").append(fcModalTPL);
		}
		
		$j('##fcModalLabel',$j('##fcModal')).html($settings.title);
		
		
		$j('##fcModal').css('top', '15px');
		$j('##fcModal').css('margin-left', '0px');
		$j('##fcModal').css('max-height', $settings.height);
		
		$j('##fcModal').css('height', $settings.height);
		$j('.modal-body').css('max-height', $settings.height);
		$j('##fcModal').css('width', $settings.width);
		$j('.modal-body').css('max-width', $settings.width);
		
		$j('.modal-body',$j('##fcModal')).css('height', $settings.height - 36);
	
	 	modalLeftPos = ( $j(window).width() - $j('##fcModal').width() ) / 2;
		$j('##fcModal').css('left', modalLeftPos);
	
	
		$j('##fcModal').off("shown").on('shown', function () {
			
			if ( $settings.url.indexOf("?") < 0 ) { $settings.url = $settings.url + '?' };
			$settings.url=$settings.url + '&dialogID=fcModal'
			$j('iframe',$j('##fcModal')).attr('src',$settings.url);
			
			$j("html").css('overflow', 'hidden');
			$settings.onShown();
			
		}).off("hidden").on('hidden', function () {
			$j("html").css('overflow', 'auto');
			$j('iframe',$j('##fcModal')).attr('src','');
			$settings.onHidden();			
		}).modal({
			keyboard: $settings.keyboard,
			backdrop: $settings.backdrop
			
		});
	};
					
	$fc.changeBootstrapModalTitle = function(title){	
		parent.$j('##fcModalLabel').html(title);
	}
	
	<!--- JOINS --->
							
	var fcForm = {};
							
	fcForm.openLibrarySelect = function(typename,objectid,property,id,urlparameters) {
		urlparameters = urlparameters ? urlparameters : '';
		
		$fc.openBootstrapModal({
			title:'Library',
			url: '#application.url.webroot#/index.cfm?type=' + typename + '&objectid=' + objectid + '&view=webtopPageModal&bodyview=displayLibraryTabs' + '&property=' + property + '&fieldname=' + id + '&' + urlparameters,
			onHidden: function () {
				$j('##' + id).trigger('change');
				fcForm.refreshProperty(typename,objectid,property,id);
				return true;
			}
		});
	};
	

	fcForm.openLibraryAdd = function(typename,objectid,property,id) {
		var filterTypename = $j('##' + id + '-add-type').val();
		$fc.openBootstrapModal({
			title:'Add New',
			url: '#application.url.webroot#/index.cfm?type=' + typename + '&objectid=' + objectid + '&view=webtopPageModal&bodyView=displayLibraryAdd' + '&property=' + property + '&filterTypename=' + filterTypename,
			onHidden: function () {
				$j('##' + id).trigger('change');
				fcForm.refreshProperty(typename,objectid,property,id);
				return true;
			}
		});
	};	
	
	fcForm.openLibraryBulkUpload = function(typename,objectid,property,id) {
		var filterTypename = $j('##' + id + '-bulkupload-type').val();
		$fc.openBootstrapModal({
			title:'Bulk Upload',
			url: '#application.url.webtop#/index.cfm?typename='+filterTypename+'&view=webtopPageModal&bodyView=webtopBodyBulkUpload&parentType='+typename+'&parentObjectID='+objectid+'&parentProperty=' + property + '&fieldname=' + id,
			onHidden: function () {
				$j('##' + id).trigger('change');
				fcForm.refreshProperty(typename,objectid,property,id);
				return true;
			}
		});
	};	
	
	fcForm.openLibraryEdit = function(typename,objectid,property,id,editid) {
		//$j("html").css('overflow', 'hidden');	
		//$j("div.ui-dialog", parent.document.body).addClass('nested');	
		$fc.openBootstrapModal({
			title:'Edit',
			url: '#application.url.webroot#/index.cfm?type=' + typename + '&objectid=' + objectid + '&view=webtopPageModal&bodyView=displayLibraryEdit' + '&property=' + property + '&editid=' + editid + '&iframe=1',
			onHidden: function () {
				$j('##' + id).trigger('change');
				fcForm.refreshProperty(typename,objectid,property,id);
				return true;
			}
		});
	};	
	
	fcForm.deleteLibraryItem = function(typename,objectid,property,formfieldname,itemids) {
		$j.ajax({
			cache: false,
			type: "POST",
 			url: '#application.url.webroot#/index.cfm?ajaxmode=1&type=' + typename + '&objectid=' + objectid + '&view=displayAjaxUpdateJoin' + '&property=' + property,
			data: {deleteID: itemids },
			dataType: "html",
			complete: function(data){
				$j('##join-item-' + property + '-' + itemids).hide('blind',{},500);			
				$j('##join-item-' + property + '-' + itemids).remove();	
				$j('##' + formfieldname).attr('value','');	
				var aItems = $j('##' + formfieldname + '-library-wrapper').sortable('toArray',{'attribute':'serialize'});
				if($j.isArray(aItems)) {
					$j('##' + formfieldname).val(aItems.join(","));
				} else {
					$j('##' + formfieldname).val('');
				}
				$j('##' + formfieldname).trigger('change');
				
			}
		});	
	}
	fcForm.deleteAllLibraryItems = function(typename,objectid,property,formfieldname,itemids) {
		$j.ajax({
			cache: false,
			type: "POST",
 			url: '#application.url.webroot#/index.cfm?ajaxmode=1&type=' + typename + '&objectid=' + objectid + '&view=displayAjaxUpdateJoin' + '&property=' + property,
			data: {deleteID: itemids },
			dataType: "html",
			complete: function(data){
				$j('##' + formfieldname).attr('value', '');	
				$j('##' + formfieldname).trigger('change');	
				$j('##join-' + objectid + '-' + property).hide('blind',{},500);		
				$j('##join-' + objectid + '-' + property).remove();								
			}
		});	
	}
	fcForm.detachLibraryItem = function(typename,objectid,property,formfieldname,itemids) {
		$j('##join-item-' + property + '-' + itemids).hide('blind',{},500);			
		$j('##join-item-' + property + '-' + itemids).remove();	
		$j('##' + formfieldname).attr('value','');	
		var aItems = $j('##' + formfieldname + '-library-wrapper').sortable('toArray',{'attribute':'serialize'});
		if($j.isArray(aItems)) {
			$j('##' + formfieldname).val(aItems.join(","));
		} else {
			$j('##' + formfieldname).val('');
		}
		$j('##' + formfieldname).trigger('change');
	}
	fcForm.detachAllLibraryItems = function(typename,objectid,property,formfieldname,itemids) {
		$j('##' + formfieldname).attr('value', '');		
		$j('##' + formfieldname).trigger('change');		
		$j('##join-' + objectid + '-' + property).hide('blind',{},500);		
		$j('##join-' + objectid + '-' + property).remove();	
	}
		
	fcForm.initLibrary = function(typename,objectid,property,urlParams) {
		fcForm.initLibrarySummary(typename,objectid,property,urlParams);	
		
		$j('tr.selector-wrap')
			.has('input:checked')
			.addClass('selected')
			.end()
		.click(function(event) {	
			if (event.target.type !== 'checkbox' && event.target.type !== 'radio') {
				$j('input', this).trigger('click');
			};
		});


		$j("input.checker").click(function(e) {	
			if ($j(this).prop("checked")) {
				$j(this).parents('tr.selector-wrap').addClass('selected');
			}
			else {
				$j(this).parents('tr.selector-wrap').removeClass('selected');
			}
			if(e.target.type == 'radio'){
				$j('tr.selector-wrap').removeClass('selected');
				$j(this).parents('tr.selector-wrap').addClass('selected');
			}
		});
		
		$j("input.checkall").click(function(e) {			
			if($j(e.target).prop('checked')){
				$j("input.checker").prop('checked',true).parents('tr.selector-wrap').addClass('selected');
			} else {
				$j("input.checker").prop('checked',false).parents('tr.selector-wrap').removeClass('selected');
			};
						
		});
	};
	
	fcForm.initLibrarySummary = function(typename,objectid,property,urlParams) {

	}
	
	fcForm.refreshProperty = function(typename,objectid,property,id) {
		var propertydata = { propertyValue: $j('##'+id).val() };
		$j("select[name^="+id+"],input[name^="+id+"]").each(function(){
			if (this.name!=id) propertydata[this.name.slice(id.length)] = $j(this).val();
		});
		var prefix = id.slice(0,id.length-property.length);
		$j.ajax({
			type: "POST",
			cache: false,
 			url: '#application.url.webroot#/index.cfm?ajaxmode=1&type=' + typename + '&objectid=' + objectid + '&view=displayAjaxRefreshJoinProperty' + '&property=' + property + '&prefix=' + prefix,
		 	success: function(msg){
				$j("##" + id + '-library-wrapper').html(msg);
				fcForm.initSortable(typename,objectid,property,id);	
		   	},
			data:propertydata,
			dataType: "html"
		});
	}	
	
	fcForm.initSortable = function(typename,objectid,property,id) {
		$j('##' + id + '-library-wrapper').sortable({
			items: 'li.sort',
			//handle: 'td.buttonGripper',
			axis: 'y',
			update: function(event,ui){
				$j('##'+id).val($j('##' + id + '-library-wrapper').sortable('toArray',{'attribute':'serialize'}).join(","));
			}
		});
		
	}
		

	
	var userselection = [];
	var inputField;
	fcForm.selections = {
		init: function(aTypename,aProperty,aId) {
			
			typename = aTypename;
			property = aProperty;
			id = aId;
			
			inputField = $j('##'+aId, parent.document);

			if(inputField.val().length) {
				userselection = inputField.val().split(',');
			}

			fcForm.selections.statusupdate(property);

			$j("body").on('click', "tr.selector-wrap input[name='selected']", function(e) {
				var el = $j(e.currentTarget);
				if (el.is(':radio')) {
					userselection = [el.val()];
				} else if (el.is(':checked')) {
					fcForm.selections.add(el.val());
				} else {
					fcForm.selections.remove(el.val());
				}
				inputField.val(userselection.toString());
				fcForm.selections.statusupdate(property);
			});
		},
		add: function(objID){
			if($j.inArray(objID, userselection) == -1) {
				userselection.push(objID);
			}
		},
		remove: function(objID){
			var arrPos = $j.inArray(objID, userselection);
			if(arrPos >= 0) {
				userselection.splice(arrPos,1);
			}
		},
		statusupdate: function(property) {
			var nbrSelections = userselection.length;
			var statusText = '<div class="alert alert-success">' + nbrSelections + ' items selected.</div>';
		
			if(nbrSelections == 0) {
				statusText = '<div class="alert alert-info">No items have been selected.</div>';
			}
			
			$j('##librarySummary-' + typename + '-' + property).html(statusText);
		},
		reinitpage: function() {
			$j('tr.selector-wrap').removeClass('selected');
			$j("tr.selector-wrap input[name='selected']").prop('checked',false);
			$j.each(userselection, function(){
				$j("tr.selector-wrap input[value='"+this+"']").prop('checked',true).parents('tr.selector-wrap').addClass('selected');
			});
		}
	};

		
	<!--- 
		Handles the default action when the user hits the enter button. 
		Script from http://greatwebguy.com/programming/dom/default-html-button-submit-on-enter-with-jquery/ 
	--->
	$j(document).on("keypress","form input, form select", function (e) {
		if ($j(this).parents('form').find('.defaultAction').length <= 0)
			return true;
		if ((e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)) {
			$j(this).parents('form').find('.defaultAction').click();
			return false;
		} else {
			return true;
		}
	});	
		
		
	<!--- AUTOSELECT FUNCTIONS --->
	$fc.uuidSelect = function(el,ui) {
		var $wrapper = $j(el).parent('.wrapper');
		var $elValue = $wrapper.find('.value').first();
		var id = ui.item ? ui.item.id : "";
		var label = ui.item ? ui.item.label : "";
			

		
		if(id != ""){		
			el.attr('value',label);	
	       	$elValue.attr('value',id);				
		}
		
		$j.ajax({
			type: "POST",
			cache: false,
			url: '/index.cfm?ajaxmode=1&type=' + $wrapper.attr('ft:typename') + '&objectid=' + $wrapper.attr('ft:objectid') + '&view=ajaxRunMethod', 
			//context: $j(this),
			error: function(data){	
				alert('change unsuccessful. Please refresh the page.');
			},
			complete: function(){
				
			},
			data: {
				method:'updateBOM',
				property: $wrapper.attr('ft:property'),
				value: $elValue.attr('value')
			},
			dataType: "html",
			timeout: 2000
		});						
		
		
		return false;	
	};
	
	
	


	$j(document).ready(function() {	

	
		$j(document).on('click','.edit-uuid', function(event) { 
			
			var libraryObjectID = $j(this).parents('.wrapper').find('input.value').attr('value');
			var $wrapper = $j(this).parent('.wrapper');
			
			 
			return $fc.openBootstrapModal({
				title:'Edit',
				url:'#application.url.webroot#/index.cfm?view=webtopPageStandard&bodyView=edit&objectid=' + libraryObjectID,
				onShown:function(){},
				onHidden:function(){

					$j.ajax({
						type: "POST",
						cache: false,
			 			url: '#application.url.webroot#/index.cfm?ajaxmode=1&type=' + $wrapper.attr('ft:typename') + '&objectid=' + $wrapper.attr('ft:objectid') + '&view=displayAjaxRefreshJoinProperty' + '&property=' + $wrapper.attr('ft:property'),
					 	success: function(msg){
							$wrapper.html(msg);
					   	},
						data:{},
						dataType: "html"
					});
				} 
			});		 
		});

	
		$j(document).on('click','.open-uuid-library', function(event) { 

			var $wrapper = $j(this).parent('.wrapper');
			
			var newDialogDiv = $j("<div id='dialog'><iframe style='width:99%;height:99%;border-width:0px;' frameborder='0'></iframe></div>");
			$j("body").prepend(newDialogDiv);
			$j("html").css('overflow', 'hidden');
			$j("div.ui-dialog", parent.document.body).addClass('nested');
			$j(newDialogDiv).dialog({
				bgiframe: true,
				modal: true,
				title:'Edit',
				draggable:false,
				resizable:false,
				width: '90%',
				height: $j(window).height()-50,
				close: function(event, ui) {
					$j("html").css('overflow', 'auto');
					$j("div.ui-dialog", parent.document.body).removeClass('nested');
					$j(newDialogDiv).dialog( 'destroy' );
					$j(newDialogDiv).remove();
					$j.ajax({
						type: "POST",
						cache: false,
			 			url: '#application.url.webroot#/index.cfm?ajaxmode=1&type=' + $wrapper.attr('ft:typename') + '&objectid=' + $wrapper.attr('ft:objectid') + '&view=displayAjaxRefreshJoinProperty' + '&property=' + $wrapper.attr('ft:property'),
					 	success: function(msg){
							$wrapper.html(msg);
							//fcForm.initSortable(typename,objectid,property,id);	
					   	},
						data:{},
						dataType: "html"
					});
				}
				
			});
			$j(newDialogDiv).dialog('open');
			$j('iframe',$j(newDialogDiv)).attr('src','#application.url.webroot#/index.cfm?type=' + $wrapper.attr('ft:typename') + '&objectid=' + $wrapper.attr('ft:objectid') + '&view=displayLibraryTabs' + '&property=' + $wrapper.attr('ft:property'));
				 
		});	
			
			
		
		$j(document).on("click",".fc-btn, .fc-btn-link", function(e) {
			
			var fcSettings = $j(this).data('fcSettings');

			if (!fcSettings) {
				return true;
			}
			
			if( fcSettings.CLICK ) {
				
				if( fcSettings.TEXTONCLICK ) {
					$j(this).find('.ui-button-text')
						.css('width', $j(this).find('.ui-button-text').width())
						.css('height', $j(this).find('.ui-button-text').height())
						.html( "<img src='/wsimages/ajax-loader.gif' style='width:16px;height:16px;' />");
						//.html( $j(this).attr('fc:textOnClick') );
				};
				
				btnClick( $j(this).closest('form').attr('id') , fcSettings.CLICK );
			};
			
			if( fcSettings.SELECTEDOBJECTID ) {
				selectedObjectID( fcSettings.SELECTEDOBJECTID );
			};
					
						
			if( fcSettings.TURNOFFSERVERSIDEVALIDATION ) {
				btnTurnOffServerSideValidation();
			};
			
			if( fcSettings.TURNONSERVERSIDEVALIDATION ) {
				btnTurnOnServerSideValidation();
			};
			
			
			if( fcSettings.TURNOFFCLIENTSIDEVALIDATION ) {
				$j(this).closest('form').attr('fc:validate',false);
			};				
			
			
			if( fcSettings.CONFIRMTEXT ) {
				if( !confirm( fcSettings.CONFIRMTEXT ) ) {
					return false;
				}
			};				
			
			if( fcSettings.URL ) {
				btnURL( fcSettings.URL , fcSettings.TARGET )
			};
			
			if( fcSettings.TEXTONCLICK ) {
				$j(this).find('.ui-button-text')
					.css('width', $j(this).find('.ui-button-text').width())
					.css('height', $j(this).find('.ui-button-text').height())
					.html( fcSettings.TEXTONCLICK );
			};
			
			if( fcSettings.ONCLICK ) {
				eval("var fn = function(){ "+fcSettings.ONCLICK+" }");
				if (fn.call(this,e)===false) return false;
			};
			
			
			if( fcSettings.SUBMIT ) {
			
				
				if( fcSettings.TEXTONSUBMIT ) {
					$j(this).find('.ui-button-text')
						.css('width', $j(this).find('.ui-button-text').width())
						.css('height', $j(this).find('.ui-button-text').height())
						.html( fcSettings.TEXTONSUBMIT );
				};
				
				
				btnSubmit( $j(this).closest('form').attr('id') , fcSettings.SUBMIT );
			};
			return false;
		});	
	});		
	
	$fc.refreshProperty = function(propertyWrap,focusFieldID) {

		$j(propertyWrap).mask('');
		var $wrap = $j(propertyWrap);
		
		var refreshPropertyURL = '/index.cfm?ajaxmode=1&type=' + $wrap.attr('ft:type') + '&objectid=' + $wrap.attr('ft:objectid') + '&format=' + $wrap.attr('ft:format') + '&property=' + $wrap.attr('ft:property') + '&prefix=' + $wrap.attr('ft:prefix') + '&view=displayAjaxRefreshAutoSaveProperty';
		
		if (typeof($wrap) == 'undefined'){
			// ignore
		} else {
			//if ($wrap.attr('ft:refreshPropertyOnAutoSave') == 'Yes'){
				$j.ajaxq('AutoSave',{
				    url: refreshPropertyURL,
				    cache: false,
				    success: function(html)
				    {
				    	$wrap.html(html);
				    }
				});
			//}
		}
		
		//$wrap.load(refreshPropertyURL, 
		//	function(data){
		//		$j('##' + focusFieldID).focus();
		//	});

		$j(propertyWrap).unmask('');			
	};	



	$fc.reloadWebskinWrap = function($webskinWrap,focusFieldID) {
		
		focusFieldID = focusFieldID ? focusFieldID : '';
		
		
		var $webskinTypename = $webskinWrap.attr('ft:typename');
		var $webskinObjectID = $webskinWrap.attr('ft:objectid');
		var $webskinView = $webskinWrap.attr('ft:webskin');
		
		$j( $webskinWrap ).mask('&nbsp;');
		$j( $webskinWrap ).load('/index.cfm?ajaxmode=1&type=' + $webskinTypename + '&objectid=' + $webskinObjectID + '&view=' + $webskinView, function(){
			$j( $webskinWrap ).unmask('');
			if (focusFieldID.length){ $j('##' + focusFieldID).focus(); }
		});
	}
	
	$j(document).on('change', '.wrap-save-on-change input:not(.helper),.wrap-save-on-change textarea:not(.helper),.wrap-save-on-change select:not(.helper)', function() {	
		
		
		var $propertyWrap = $j(this).closest('.propertyRefreshWrap');
		var propertyPrefix = $propertyWrap.attr('ft:prefix');
		var propertyType = $propertyWrap.attr('ft:type');
		var propertyObjectID = $propertyWrap.attr('ft:objectid');
		var propertyName = $propertyWrap.attr('ft:property');
		var propertyWatchingFields = $propertyWrap.attr('ft:watchingFields');
		var reloadOnAutoSave = $propertyWrap.attr('ft:reloadOnAutoSave');
		var autoSaveToSessionOnly = $j(this).closest('form').hasClass('autoSaveToSessionOnly');
		
		var $webskinWrap = $j(this).closest('.webskin-wrap');
		var webskinType = $webskinWrap.attr('ft:typename');
		var webskinObjectID = $webskinWrap.attr('ft:objectid');
		var webskinView = $webskinWrap.attr('ft:webskin');
		
		lData = $propertyWrap.find("input,textarea,select").serialize();
		lData = lData.replace(new RegExp( propertyPrefix, "gi" ),"");
		
		$j.ajaxq('AutoSave',{
		
			type: "POST",
			cache: false,
			url: '/index.cfm?ajaxmode=1&type=' + propertyType + '&objectid=' + propertyObjectID + '&view=ajaxSaveProperty&bSessionOnly=' + autoSaveToSessionOnly + '&propertyName=' + propertyName, 
			context: $j(this),
			success: function(data){
				
				$j('.webskin-wrap').each(function(index) {
					var $currentWebskinWrap = $j(this);
					
					var $webskinWatchFields = $j(this).attr("ft:watchFields");
					
					if ($webskinWatchFields.length){
						var valueArray = $webskinWatchFields.split(",");
																
						for(var i=0; i<valueArray.length; i++){
							if (valueArray[i] == (propertyPrefix + propertyName) ){
								// refresh the webskin wrap
								$fc.reloadWebskinWrap( $currentWebskinWrap );	
							} else if(valueArray[i] == (propertyName) ){
								// refresh the webskin wrap
								$fc.reloadWebskinWrap( $currentWebskinWrap );	
							}
						}
								
					}						
				});
				
				var $propertyRefreshWrap = $j(this).closest('.propertyRefreshWrap');

				if(data['BSUCCESS'] == 1) {
					var focusFieldID = '';
					if ($webskinWrap.length) {
						var focusFieldID = $(':focus').attr('id');
						$fc.reloadWebskinWrap($webskinWrap, focusFieldID);
						
					} else {
						
						if (reloadOnAutoSave == 'Yes'){
							location=location;
						} else {
							
							if ($propertyRefreshWrap.attr('ft:refreshPropertyOnAutoSave') == 'Yes'){
								$fc.refreshProperty( $propertyRefreshWrap );
							}
							
							if (propertyWatchingFields.length){
								var valueArray = propertyWatchingFields.split(",");
																		
								for(var i=0; i<valueArray.length; i++){
									if (valueArray[i].indexOf('.') !== -1) {
										// refresh all properties regardless of object
										var elSelector = "span.propertyRefreshWrap[ft\\:watchFieldname='" + valueArray[i] + "']";
										
										$j(elSelector).each(function(index) {
											$fc.refreshProperty( $j(this) );
										});
												
									} else {			
										// only refresh the current objects property
										if ($j('##' + propertyPrefix + valueArray[i]).is(":focus")){
											focusFieldID = $j('##' + propertyPrefix + valueArray[i]).attr('id');
										}
										
										$fc.refreshProperty( $j('##wrap-' + propertyPrefix + valueArray[i]), focusFieldID );
									}
								}
							}
						}
					}
				} else {
					$fc.refreshProperty( $propertyRefreshWrap );
					if (data['MESSAGE'].length){
						alert(data['MESSAGE']);
					} else {
						alert('Field [' + propertyName + '] was not saved');
					}
				}
				
			}, 
			error: function(data){	
			},
			complete: function(){
			},
			data: lData,
			
			timeout: 15000
		});
					
								
	});
<cfsilent></script></cfsilent><!--- /trick editor to highlight syntax --->
</cfoutput>

<cfsetting enablecfoutputonly="false">