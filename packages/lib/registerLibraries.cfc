<cfcomponent displayname="Third Parth Library Registration" 
	hint="allows for the registration and loading of third party js and css libraries" output="No">



	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="Any">
		
		<cfset registerCoreLibraries() />
		
		<cfreturn this>
	</cffunction>



	<cffunction name="registerCoreLibraries" access="private" returntype="void" output="false" hint="Registers core js and css libraries">
	
		<!--- import tag libraries ---> 
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfset application.fc.stJSLibraries = structNew() />
		<cfset application.fc.stCSSLibraries = structNew() />
		
		<!--- JS LIBRARIES --->
		<skin:registerJS 	id="jquery"
							baseHREF="#application.url.webtop#/thirdparty/jquery/js"
							lFiles="jquery-1.3.2.min.js">
							
							<cfoutput>var $j = jQuery.noConflict();</cfoutput>	
		</skin:registerJS>		
			
		<skin:registerJS 	id="jquery-ui"
							baseHREF="#application.url.webtop#/thirdparty/jquery/js"
							lFiles="ui.core.js,ui.accordion.js,ui.datepicker.js,ui.dialog.js,ui.draggable.js,ui.droppable.js,ui.progressbar.js,ui.resizable.js,ui.selectable.js,ui.slider.js,ui.sortable.js,ui.tabs.js,effects.core.js,effects.blind.js,effects.bounce.js,effects.clip.js,effects.drop.js,effects.explode.js,effects.fold.js,effects.highlight.js,effects.pulsate.js,effects.scale.js,effects.shake.js,effects.slide.js,effects.transfer.js" />

		<skin:registerJS 	id="tinymce"
							baseHREF="#application.url.webtop#/thirdparty/tiny_mce"
							lFiles="tiny_mce_gzip.js"
							bCombine="false" />

		<skin:registerJS 	id="jquery-validate"
							baseHREF="#application.url.webtop#/thirdparty/jquery-validate"
							lFiles="jquery.validate.pack.js" />

		<skin:registerJS 	id="jquery-tools"
							baseHREF="#application.url.webtop#/thirdparty/jquery-tools"
							lFiles="jquery.tools.min.js" />
							
							
		<skin:registerJS 	id="gritter"
							baseHREF="#application.url.webtop#/thirdparty/gritter/js"
							lFiles="jquery.gritter.js" />

		<skin:registerJS 	id="farcry-form"
							baseHREF="#application.url.webtop#"
							lFiles="/js/farcryForm.cfm,/thirdparty/loadmask/jquery.loadmask.min.js,/thirdparty/uni-form/js/uni-form.jquery.js">
							
							<cfoutput>
							var $fc = {};
									
							$fc.openDialog = function(title,url,width,height){
								var fcDialog = $j("<div></div>")
								w = width ? width : 600;
								h = height ? height : $j(window).height()-50;
								$j("body").prepend(fcDialog);
								$j(fcDialog).dialog({
									bgiframe: true,
									modal: true,
									title:title,
									width: w,
									height: h,
									close: function(event, ui) {
										$j(fcDialog).dialog( 'destroy' );
										$j(fcDialog).remove();
									}
									
								});
								$j(fcDialog).dialog('open');
								$j.ajax({
									type: "POST",
									cache: false,
									url: url, 
									complete: function(data){
										$j(fcDialog).html(data.responseText);			
									},
									dataType: "html"
								});
							};	
							
							
							$fc.openDialogIFrame = function(title,url,width,height){
								var fcDialog = $j("<div><iframe style='width:99%;height:99%;border-width:0px;'></iframe></div>")
								w = width ? width : 600;
								h = height ? height : $j(window).height()-50;
								$j("body").prepend(fcDialog);
								$j(fcDialog).dialog({
									bgiframe: true,
									modal: true,
									title:title,
									width: w,
									height: h,
									close: function(event, ui) {
										$j(fcDialog).dialog( 'destroy' );
										$j(fcDialog).remove();
									}
									
								});
								$j(fcDialog).dialog('open');
								$j('iframe',$j(fcDialog)).attr('src',url);
							};		
							
							
							<!--- JOINS --->
							
							var fcForm = {};
							
	fcForm.openLibrarySelect = function(typename,objectid,property,id) {
		
		var newDialogDiv = $j("<div></div>");
		$j("body").prepend(newDialogDiv);
		
		$j(newDialogDiv).dialog({
			bgiframe: true,
			modal: true,
			title:'Library Selector',
			width: $j(window).width()-50,
			height: $j(window).height()-50,
			buttons: {
				Ok: function() {
					$j(this).dialog('close');
				}
			},
			close: function(event, ui) {
				fcForm.refreshProperty(typename,objectid,property,id);
				$j(newDialogDiv).dialog( 'destroy' );
				$j(newDialogDiv).remove();
			}
			
		});
		$j(newDialogDiv).dialog('open');
		$j.ajax({
			type: "POST",
			cache: false,
					url: '/index.cfm?ajaxmode=1&type=' + typename + '&objectid=' + objectid + '&view=displayLibraryTabs' + '&property=' + property, 
			complete: function(data){
				$j(newDialogDiv).html(data.responseText);			
			},
			dataType: "html"
		});
	};
	

	fcForm.openLibraryAdd = function(typename,objectid,property,id) {
		var newDialogDiv = $j("<div id='" + typename + objectid + property + "'><iframe style='width:100%;height:100%;border-width:0px;'></iframe></div>")
		$j("body").prepend(newDialogDiv);
		
		$j(newDialogDiv).dialog({
			bgiframe: true,
			modal: true,
			title:'Add New',
			closeOnEscape: false,
			width: $j(window).width()-50,
			height: $j(window).height()-50,
			close: function(event, ui) {
				fcForm.refreshProperty(typename,objectid,property,id);
				$j(newDialogDiv).dialog( 'destroy' );
				$j(newDialogDiv).remove();
			}
			
		});
		$j(newDialogDiv).dialog('open');
		//OPEN URL IN IFRAME ie. not in ajaxmode
		$j('iframe',$j(newDialogDiv)).attr('src','/index.cfm?type=' + typename + '&objectid=' + objectid + '&view=displayLibraryAdd' + '&property=' + property);
		
	};	
	
	fcForm.openLibraryEdit = function(typename,objectid,property,id,editid) {
		var newDialogDiv = $j("<div id='" + typename + objectid + property + "'><iframe style='width:100%;height:100%;border-width:0px;'></iframe></div>")
		$j("body").prepend(newDialogDiv);
		
		$j(newDialogDiv).dialog({
			bgiframe: true,
			modal: true,
			title:'Edit',
			closeOnEscape: false,
			width: $j(window).width()-50,
			height: $j(window).height()-50,
			close: function(event, ui) {
				fcForm.refreshProperty(typename,objectid,property,id);
				$j(newDialogDiv).dialog( 'destroy' );
				$j(newDialogDiv).remove();
			}
			
		});
		$j(newDialogDiv).dialog('open');
		//OPEN URL IN IFRAME ie. not in ajaxmode
		$j('iframe',$j(newDialogDiv)).attr('src','/index.cfm?type=' + typename + '&objectid=' + objectid + '&view=displayLibraryEdit' + '&property=' + property + '&editid=' + editid);
		
	};	
	
	fcForm.deleteLibraryItem = function(typename,objectid,property,formfieldname,itemids) {
		$j.ajax({
			cache: false,
			type: "POST",
 			url: '/index.cfm?ajaxmode=1&type=' + typename + '&objectid=' + objectid + '&view=displayAjaxUpdateJoin' + '&property=' + property,
			data: {deleteID: itemids },
			dataType: "html",
			complete: function(data){
				$j('##' + formfieldname).attr('value', $j('##' + formfieldname + '-library-wrapper').sortable('toArray',{'attribute':'serialize'}));		
				$j('##join-item-' + itemids).hide('blind',{},500);				
			}
		});	
	}
	fcForm.deleteAllLibraryItems = function(typename,objectid,property,formfieldname,itemids) {
		$j.ajax({
			cache: false,
			type: "POST",
 			url: '/index.cfm?ajaxmode=1&type=' + typename + '&objectid=' + objectid + '&view=displayAjaxUpdateJoin' + '&property=' + property,
			data: {deleteID: itemids },
			dataType: "html",
			complete: function(data){
				$j('##' + formfieldname).attr('value', '');	
				$j('##join-' + objectid + '-' + property).hide('blind',{},500);								
			}
		});	
	}
	fcForm.detachLibraryItem = function(typename,objectid,property,formfieldname,itemids) {
		$j.ajax({
			cache: false,
			type: "POST",
 			url: '/index.cfm?ajaxmode=1&type=' + typename + '&objectid=' + objectid + '&view=displayAjaxUpdateJoin' + '&property=' + property,
			data: {detachID: itemids },
			dataType: "html",
			complete: function(data){		
				$j('##join-item-' + itemids).hide('blind',{},500);			
				$j('##join-item-' + itemids).remove();	
				$j('##' + formfieldname).attr('value','');	
				$j('##' + formfieldname).attr('value', $j('##' + formfieldname + '-library-wrapper').sortable('toArray',{'attribute':'serialize'}));				
			}
		});	
	}
	fcForm.detachAllLibraryItems = function(typename,objectid,property,formfieldname,itemids) {
		$j.ajax({
			cache: false,
			type: "POST",
 			url: '/index.cfm?ajaxmode=1&type=' + typename + '&objectid=' + objectid + '&view=displayAjaxUpdateJoin' + '&property=' + property,
			data: {detachID: itemids },
			dataType: "html",
			complete: function(data){	
				$j('##' + formfieldname).attr('value', '');		
				$j('##join-' + objectid + '-' + property).hide('blind',{},500);		
				$j('##join-' + objectid + '-' + property).remove();	
				$j('##' + formfieldname).attr('value','');			
				$j('##' + formfieldname).attr('value', $j('##' + formfieldname + '-library-wrapper').sortable('toArray',{'attribute':'serialize'}));			
			}
		});	
	}
	
	fcForm.initLibrary = function(typename,objectid,property) {
		fcForm.initLibrarySummary(typename,objectid,property);		
		$j("input.checker").click(function(e) {			
			if($j(e.target).attr('checked')){
				$j.ajax({
					cache: false,
					type: "POST",
		 			url: '/index.cfm?ajaxmode=1&type=' + typename + '&objectid=' + objectid + '&view=displayAjaxUpdateJoin' + '&property=' + property,
					data: {addID: $j(e.target).val() },
					dataType: "html",
					complete: function(data){
						fcForm.initLibrarySummary(typename,objectid,property);
						$j('##librarySummary-' + typename + '-' + property).effect('pulsate',{times:2});
					}
				});		
			} else {
				$j.ajax({
					cache: false,
					type: "POST",
		 			url: '/index.cfm?ajaxmode=1&type=' + typename + '&objectid=' + objectid + '&view=displayAjaxUpdateJoin' + '&property=' + property,
					data: {detachID: $j(e.target).val() },
					dataType: "html",
					complete: function(data){
						fcForm.initLibrarySummary(typename,objectid,property);	
						$j('##logger').append(data.responseText);	
						$j('##librarySummary-' + typename + '-' + property).effect('pulsate',{times:2});						
					}
				});	
			}
						
		});
		
		$j("input.checkall").click(function(e) {			
			if($j(e.target).attr('checked')){
				$j("input.checker").attr('checked','checked');
			} else {
				$j("input.checker").attr('checked','checked');
			}
						
		});
	};
	
	fcForm.initLibrarySummary = function(typename,objectid,property) {
		$j.ajax({
			type: "POST",
			cache: false,
					url: '/index.cfm?ajaxmode=1&type=' + typename + '&objectid=' + objectid + '&view=displayLibrarySummary' + '&property=' + property, 
			complete: function(data){
				$j('##librarySummary-' + typename + '-' + property).html(data.responseText);
					
			},
			dataType: "html"
		});
	}
	
	fcForm.refreshProperty = function(typename,objectid,property,id) {
		$j.ajax({
			type: "POST",
			cache: false,
 			url: '/index.cfm?ajaxmode=1&type=' + typename + '&objectid=' + objectid + '&view=displayAjaxRefreshJoinProperty' + '&property=' + property,
		 	success: function(msg){
				$j("##" + id + '-library-wrapper').html(msg);
				fcForm.initSortable(typename,objectid,property,id);	
		   	},
			dataType: "html"
		});
	}	
	
	fcForm.initSortable = function(typename,objectid,property,id) {
		$j('##' + id + '-library-wrapper').sortable({
			items: 'li.sort',
			update: function(event,ui){
				$j.ajax({
					type: "POST",
					cache: false,
	  				url: '/index.cfm?ajaxmode=1&type=' + typename + '&objectid=' + objectid + '&view=displayAjaxUpdateJoin' + '&property=' + property,
					data: {'sortIDs': $j('##' + id + '-library-wrapper').sortable('toArray',{'attribute':'serialize'}) },
					complete: function(data){},
					dataType: "html"
				});
			}
		});
		$j('##test').disableSelection();
		
	}
		
		
		//dimScreen()
		//by Brandon Goldman
		$j.extend({
		    //dims the screen
		    dimScreen: function(speed, opacity, callback) {
		        if(jQuery('##__dimScreen').size() > 0) return;
		        
		        if(typeof speed == 'function') {
		            callback = speed;
		            speed = null;
		        }
		
		        if(typeof opacity == 'function') {
		            callback = opacity;
		            opacity = null;
		        }
		
		        if(speed < 1) {
		            var placeholder = opacity;
		            opacity = speed;
		            speed = placeholder;
		        }
		        
		        if(opacity >= 1) {
		            var placeholder = speed;
		            speed = opacity;
		            opacity = placeholder;
		        }
		
		        speed = (speed > 0) ? speed : 500;
		        opacity = (opacity > 0) ? opacity : 0.5;
		        return jQuery('<div></div>').attr({
		                id: '__dimScreen'
		                ,fade_opacity: opacity
		                ,speed: speed
		            }).css({
		            background: '##000'
		            ,height: jQuery(document).height() + 'px'
		            ,left: '0px'
		            ,opacity: 0
		            ,position: 'absolute'
		            ,top: '0px'
		            ,width: jQuery(document).width() + 'px'
		            ,zIndex: 999
		        }).appendTo(document.body).fadeTo(speed, opacity, callback);
		    },
			    
		    //stops current dimming of the screen
		    dimScreenStop: function(callback) {
		        var x = jQuery('##__dimScreen');
		        var opacity = x.attr('fade_opacity');
		        var speed = x.attr('speed');
		        x.fadeOut(speed, function() {
		            x.remove();
		            if(typeof callback == 'function') callback();
		        });
		    }
		});		
							
														
							</cfoutput>
							
		</skin:registerJS>

		
		<!--- CSS LIBRARIES --->
		<skin:registerCSS 	id="webtop"
							baseHREF="#application.url.webtop#/css"
							lFiles="reset.css,fonts.css,main.css">
			<cfoutput>
			##webtopOverviewActions button h1,
			##webtopOverviewActions button h2 {
				margin:0px;
			}
			
			##webtopOverviewActions button.primary {
				width:180px;
				height:100px;
			}
			##webtopOverviewActions button.secondary {
				width:180px;
				height:50px;
				margin-top:10px;
			}
			.webtopOverviewStatusBox {
				border:1px solid black;
				padding:10px;
				margin-top:5px;
			}
			.webtopSummarySection {
				border-bottom:2px solid ##DFDFDF;
				padding:0px 5px 15px 5px;
				margin:10px 0px 10px 0px;
			}
			.webtopSummarySection h2 {
				margin:10px 0px 0px 0px;
				font-weight:bold;
			}	
			
			
			ul.object-admin-actions {
				margin:0px;
				padding:0px;
			}
			ul.object-admin-actions li {
				float: left;
				list-style: none;
			}


			ul.object-admin-actions li a,
			ul.object-admin-actions li a:link,
			ul.object-admin-actions li a:visited,
			ul.object-admin-actions li a:hover,
			ul.object-admin-actions li a:active {
				text-decoration:none; 				
				float:left;	
				color:##000;
				padding:2px;	
				line-height:16px;
				display:block;
				text-decoration:none;
				border:1px solid transparent;
			} 
			
			ul.object-admin-actions li a:hover {
				background-color:##ffffff;
				border:1px solid ##B5B5B5;
			} 
			
			
			ul.object-admin-actions li a .ui-icon {
				float:left;
				margin-right:2px;
			}
			
			</cfoutput>
		</skin:registerCSS>
							
		<skin:registerCSS 	id="jquery-ui"
							baseHREF="#application.url.webtop#/thirdparty/jquery/css/base"
							lFiles="ui.core.css,ui.resizable.css,ui.accordion.css,ui.dialog.css,ui.slider.css,ui.tabs.css,ui.datepicker.css,ui.progressbar.css,ui.theme.css">
							
							<cfoutput>
							.ui-widget {font-size:1em;}
							</cfoutput>
		</skin:registerCSS>
				
		<skin:registerCSS 	id="farcry-form"
							baseHREF="#application.url.webtop#/thirdparty"
							lFiles="/loadmask/jquery.loadmask.css,/uni-form/css/uni-form-generic.css,/uni-form/css/uni-form.css" />

							
		<skin:registerCSS 	id="gritter"
							baseHREF="#application.url.webtop#/thirdparty/gritter/css"
							lFiles="gritter.css" />
							
		<skin:registerCSS 	id="farcry-tray"
							baseHREF="#application.url.webtop#/css"
							lFiles="tray.css" />
				
		<skin:registerCSS id="jquery-tools">
			<cfoutput>
			div.tooltip { 
			    background-color:##000; 
			    border:2px solid ##fff;
			    padding:10px; 		
				width:200px;	    
			    font-size:12px;			     
			    color:##fff; 
				text-align:center;
				z-index:999;
			} 
			</cfoutput>
		</skin:registerCSS>				
														
	</cffunction>	
	
</cfcomponent>