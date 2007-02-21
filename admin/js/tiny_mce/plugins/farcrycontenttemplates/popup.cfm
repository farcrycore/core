<cfset request.inhead.scriptaculous = true />


<cfoutput>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>{$lang_template_title}</title>
	<script language="javascript" type="text/javascript" src="../../tiny_mce_popup.js"></script>
	<script language="javascript" type="text/javascript" src="../../utils/mctabs.js"></script>
	<script language="javascript" type="text/javascript">
	
		var r_objectid = '';
		var r_typename = '';
		var r_webskin = '';
	
		function init() {
			var inst = tinyMCE.selectedInstance;
			var elm = inst.getFocusElement();
			

			//alert("Got a window argument from plugin: " + tinyMCE.getWindowArg('some_custom_arg'));

			// Set the form item value to the selected node element name
			//document.forms[0].nodename.value = elm.nodeName;
		}

		function insertSomething(typename,prevDIV) {
			// Execute the mceTemplate command without UI this time
			//tinyMCEPopup.execCommand('mceTemplate');
			
			url = '#application.url.farcry#/facade/tinyMCE.cfc?method=ajaxSetTemplatePreview';
			//alert('<sc'+'ript language="javascript" type="text/javascript" src="#application.url.farcry#/facade/tinyMCE.cfm?objectID=' + farcryobjectid + '&Typename=' + farcrytypename + '&richtextfield=' + farcryrichtextfield + '"></sc'+'ript>');
			new Ajax.Updater('prev' + prevDIV + 'div', url, {
				//onLoading:function(request){Element.show('indicator')},
				onComplete:function(request){
					//$('prevDIV').innerHTML = request.responseText;
					//tinyMCE.execCommand('mceInsertContent',false, request.responseText);
					tinyMCE.execCommand('mceInsertContent',false, request.responseText.replace(/^\s*|\s*$/g,""));	//make sure to trim the return value
								
					// Close the dialog
					tinyMCEPopup.close();					
				},
					
				parameters:'objectID=' + r_objectid + '&Typename=' + r_typename + '&webskin=' + r_webskin , 
				evalScripts:false, 
				asynchronous:true
			})
						
			
			

		}
	
	</script>
	<base target="_self" />
</head>
<body onload="tinyMCEPopup.executeOnLoad('init();');"> 
	<form onsubmit="insertSomething();return false;">
		<h3>Related Content</h2>
		<br />
		 
		<!-- Gets filled with the selected elements name -->
<!--- 		<div style="margin-top: 10px; margin-bottom: 10px">
			The selected element name: <input type="text" name="nodename" />
		</div> --->

		<div id="templatedropdowns">&nbsp;</div>
		

				
				

	</form>
	
	
	<script type="text/javascript">
		function setPreview(objectid,typename,webskin,prev){
			
			r_objectid = objectid;
			r_typename = typename;
			r_webskin = webskin;
			
			if(r_objectid != '' && r_typename != '' && r_webskin != ''){
				url = '#application.url.farcry#/facade/tinyMCE.cfc?method=ajaxSetTemplatePreview';
				//alert('<sc'+'ript language="javascript" type="text/javascript" src="#application.url.farcry#/facade/tinyMCE.cfm?objectID=' + farcryobjectid + '&Typename=' + farcrytypename + '&richtextfield=' + farcryrichtextfield + '"></sc'+'ript>');
				<!--- new Ajax.Updater('prev', url, {
					//onLoading:function(request){Element.show('indicator')},
					onComplete:function(request){
						$('prev').innerHTML = request.responseText;
					},
						
					parameters:'objectID=' + objectid + '&Typename=' + typename + '&webskin=' + webskin , 
					evalScripts:false, 
					asynchronous:true
				}) --->
				$('prev' + prev).src = url + '&objectID=' + objectid + '&Typename=' + typename + '&webskin=' + webskin;
				Element.setStyle('insert' + prev, {display:''});
			} else {
				alert('Please select all options');	
			}
		}
		
		// determine farcryobjectid
		var farcryobjectid = tinyMCE.getParam("farcryobjectid");
		var farcrytypename = tinyMCE.getParam("farcrytypename");
		var farcryrichtextfield = tinyMCE.getParam("farcryrichtextfield");
		if (farcryobjectid != null && farcrytypename != null && farcryrichtextfield != null) {
			// Fix relative
			url = '#application.url.farcry#/facade/tinyMCE.cfc?method=ajaxGetTemplateDropdowns';
			//alert('<sc'+'ript language="javascript" type="text/javascript" src="#application.url.farcry#/facade/tinyMCE.cfm?objectID=' + farcryobjectid + '&Typename=' + farcrytypename + '&richtextfield=' + farcryrichtextfield + '"></sc'+'ript>');
			new Ajax.Updater('templatedropdowns', url, {
				//onLoading:function(request){Element.show('indicator')},
				onComplete:function(request){
					$('templatedropdowns').innerHTML = request.responseText;
					//$('insert').
					//Element.setStyle('insert', {display:''} )
				},
					
				parameters:'objectID=' + farcryobjectid + '&Typename=' + farcrytypename + '&richtextfield=' + farcryrichtextfield , 
				evalScripts:false, 
				asynchronous:true
			})
			
		}
	</script>
	

</body> 
</html> 
</cfoutput>