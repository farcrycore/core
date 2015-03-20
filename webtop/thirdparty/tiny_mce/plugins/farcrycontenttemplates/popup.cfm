<cfsetting enablecfoutputonly="true" />
<cfsetting showdebugoutput="false" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<skin:loadJS id="fc-jquery" />


<cfoutput>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title></title>
	<script type="text/javascript" src="../../tiny_mce_popup.js"></script>
	<script type="text/javascript" src="../../utils/mctabs.js"></script>
	<script type="text/javascript">
	
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
			
			url = '#application.url.farcry#/facade/tinyMCE.cfc?method=ajaxSetTemplatePreview&ajaxmode=1';
			//alert('<sc'+'ript type="text/javascript" src="#application.url.farcry#/facade/tinyMCE.cfm?objectID=' + farcryobjectid + '&Typename=' + farcrytypename + '&richtextfield=' + farcryrichtextfield + '"></sc'+'ript>');
			
			$j.ajax({
			   type: "POST",
			   url: '#application.url.farcry#/facade/tinyMCE.cfc?method=ajaxSetTemplatePreview&ajaxmode=1',
			   data: 'objectID=' + r_objectid + '&Typename=' + r_typename + '&webskin=' + r_webskin , 
			   dataType: 'html',
			   cache: false,
			   timeout: 2000,
			   success: function(msg){
			   		
					tinyMCE.execCommand('mceInsertContent',false, msg.replace(/^\s*|\s*$/g,""));	//make sure to trim the return value
					tinyMCEPopup.close();					     	
			   }
			 });			
			
						
			
			

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
				$j('##prev' + prev).attr('src', '#application.url.farcry#/facade/tinyMCE.cfc?method=ajaxSetTemplatePreview&objectID=' + objectid + '&Typename=' + typename + '&webskin=' + webskin);
				
				$j('##insert').css("display","");
				
			} else {
				alert('Please select all options');	
			}
		}

		// determine farcryobjectid
		var farcryobjectid = tinyMCEPopup.getParam("farcryobjectid");
		var farcrytypename = tinyMCEPopup.getParam("farcrytypename");
		var farcryrichtextfield = tinyMCEPopup.getParam("farcryrichtextfield");
		if (farcryobjectid != null && farcrytypename != null && farcryrichtextfield != null) {

			// Fix relative	
			$j.ajax({
			   type: "POST",
			   url: '#application.url.farcry#/facade/tinyMCE.cfc?method=ajaxGetTemplateDropdowns',
			   data: 'objectID=' + farcryobjectid + '&Typename=' + farcrytypename + '&richtextfield=' + farcryrichtextfield + '&' + $j('form.uniForm div.multiField input:hidden',(parent || opener).document).serialize() + '&' + $j('##wizardID',(parent || opener).document).serialize(),
			   dataType: 'html',
			   cache: false,
			   timeout: 2000,
			   success: function(msg){
			   		$j('##templatedropdowns').html(msg);
			   }
			 });			
			
		}
	</script>
	

</body> 
</html> 
</cfoutput>

<cfsetting enablecfoutputonly="false" />