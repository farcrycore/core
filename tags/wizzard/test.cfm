<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en">
	<head>
		
		
	<META HTTP-EQUIV="Expires" CONTENT="Tue, 01 Jan 1985 00:00:01 GMT">
	<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
	<META HTTP-EQUIV="cache-control" CONTENT="no-cache, no-store, must-revalidate">
	
		<meta content="text/html; charset=UTF-8" http-equiv="content-type">
		<title>Breathe Creativity Extranet :: Administration</title>
		<script src="/farcry/js/tabs.js" type="text/javascript"></script>

		
		<script src="/farcry/includes/lib/DataRequestor.js"></script>
		
		<script src="/farcry/includes/lib/json.js"></script>
		<style type="text/css" title="default" media="screen">@import url(/farcry/css/main.css);</style>
		<style type="text/css" title="default" media="screen">@import url(/farcry/css/tabs.css);</style>
		<script type="text/javascript" src="/farcry/js/tables.js"></script>
		<script type="text/javascript" src="/farcry/js/showhide.js"></script>

		<script type="text/javascript" src="/farcry/js/fade.js"></script>
		


	<script type="text/javascript">
		//browser testing;
		var ns6 = document.getElementById && ! document.all;
		var ie5up = document.getElementById && document.all;  //ie5 ++
		
		function reloadTreeFrame(){
			// reload tree if not -- quick zoom -- option
			if (document.zoom.QuickZoom.options[document.zoom.QuickZoom.options.selectedIndex].value != '0') {
				window.frames.treeFrame.location.href = document.zoom.QuickZoom.options[document.zoom.QuickZoom.options.selectedIndex].value;
				return false;
			}
		}
	</script>
	
	
	<!--// load the qForm JavaScript API //-->
	<script type="text/javascript" src="/farcry/includes/lib/qforms.js"></script>
	<!--// you do not need the code below if you plan on just
		   using the core qForm API methods. //-->
	<!--// [start] initialize all default extension libraries  //-->
	<script type="text/javascript">
	<!--//
	// specify the path where the "/qforms/" subfolder is located
	qFormAPI.setLibraryPath("/farcry/includes/lib/");
	// loads all default libraries
	qFormAPI.include("*");
	//-->
	</script>

	<!--// [ end ] initialize all default extension libraries  //-->

	
	<style type="text/css">
	
		table {border-collapse:collapse;border:none;background:none;margin: .none;font-size:86%;border-bottom: none;border-left: none;}
		form.f-wrap-1 table {font-size:92%}
		table table {font-size:100%}
		caption {text-align:left;font: bold 145% arial;padding: 5px 10px;background:none}
		th {vertical-align:top;color: #48618A;border-top: none;border-right: none;text-align: left;padding: 5px;background: none;font-size: 110%}
		th.order-asc {background-position: 100% -100px;padding-right:25px}
		th.order-desc {background-position: 100% -200px;padding-right:25px}
		th a:link, th a:visited, th a:hover, th a:active {color:#fff}
		th.alt a:link, th.alt a:visited {color:#E17000}
		th.alt a:hover, th.alt a:active {color:#fff}
		th img {display:block;float:right;margin:0;padding: 10px;}
		td {vertical-align:top;border:none;padding: 50px;margin:10px;}
		th.nobg {border:none;background:none}
		tr.alt {background: none} 
		tr.ruled {background: none} 
		tr {background:none}
		

/* =FORMS */
form.f-wrap-1 {margin: 0 0 1.5em}
input {font-family: arial,tahoma,verdana,sans-serif;margin: 2px 0}
fieldset {border: none}
label {display:block;padding: 5px 0;width:150px;}
label br {clear:left}
input.f-submit {padding: 1px 3px;background:#666;color:#fff;font-weight:bold;font-size:96%}

	/* f-wrap-1 - simple form, headings on left, form.f-wrap-1 elements on right */
	form.f-wrap-1 {width:100%;padding: .5em 0;background: #f6f6f6 url("images/featurebox_bg.gif") no-repeat 100% 100%;border-top: 1px solid #d7d7d7;position:relative}
		form.f-wrap-1 fieldset {width:auto;margin: 0 1em}
		form.f-wrap-1 h3 {margin:0 0 .6em;font: bold 155% arial;color:#c00}
		form.f-wrap-1 label {clear:left;float:left;width:auto;border:0px;}
		
		/* hide from IE mac \*/
		form.f-wrap-1 label {float:none}
		/* end hiding from IE5 mac */
	
		form.f-wrap-1 label input, form.f-wrap-1 label textarea, form.f-wrap-1 label select {width:15em;float:left;margin-left:10px}
		
		form.f-wrap-1 label b {float:left;width:8em;line-height: 1.7;display:block;position:relative}
		form.f-wrap-1 label b .req {color:#c00;font-size:150%;font-weight:normal;position:absolute;top:-.1em;line-height:1;left:-.4em;width:.3em;height:.3em}
		form.f-wrap-1 div.req {color:#666;font-size:96%;font-weight:normal;position:absolute;top:.4em;right:.4em;left:auto;width:13em;text-align:right}
		form.f-wrap-1 div.req b {color:#c00;font-size:140%}
		form.f-wrap-1 label select {width: 15.5em}
		form.f-wrap-1 label textarea.f-comments {width: 20em}
		form.f-wrap-1 div.f-submit-wrap {padding: 5px 0 5px 8em}
		form.f-wrap-1 input.f-submit {margin: 0 0 0 10px}
		
		form.f-wrap-1 fieldset.f-checkbox-wrap, form.f-wrap-1 fieldset.f-radio-wrap {float:left;width:32em;border:none;margin:0;padding-bottom:.7em}
		form.f-wrap-1 fieldset.f-checkbox-wrap b, form.f-wrap-1 fieldset.f-radio-wrap b {float:left;width:8em;line-height: 1.7;display:block;position:relative;padding-top:.3em}
		form.f-wrap-1 fieldset.f-checkbox-wrap fieldset, form.f-wrap-1 fieldset.f-radio-wrap fieldset {float:left;width:13em;margin: 3px 0 0 10px}
		form.f-wrap-1 fieldset.f-checkbox-wrap label, form.f-wrap-1 fieldset.f-radio-wrap label {float:left;width:13em;border:none;margin:0;padding:2px 0;margin-right:-3px}
		form.f-wrap-1 label input.f-checkbox, form.f-wrap-1 label input.f-radio {width:auto;float:none;margin:0;padding:0}
		
		form.f-wrap-1 label span.errormsg {position:absolute;top:0;right:-10em;left:auto;display:block;width:16em;background: transparent url(images/errormsg_bg.gif) no-repeat 0 0}
		
	</style>
	
	
	
</head>
<body class="iframed-content">

		<div id="plp-wrap">			
			<div class="pagination">
				<ul><li class="li-next"><a href=" javascript:document.forms.editform.plpAction.value='next';document.forms.editform.buttonSubmit.click();">Next</a></li></ul>
			</div>

			<h1><img src="/farcry/images/icons/HTML.png" alt="HTML" />Breathe Creativity - Welcome</h1>			
			<div id="plp-nav">
				<ul>
		<li><a href=" javascript:document.forms.editform.plpAction.value='step:1';document.forms.editform.buttonSubmit.click();"><strong>start</strong></a></li><li><a href=" javascript:document.forms.editform.plpAction.value='step:2';document.forms.editform.buttonSubmit.click();">body</a></li><li><a href=" javascript:document.forms.editform.plpAction.value='step:3';document.forms.editform.buttonSubmit.click();">related</a></li><li><a href=" javascript:document.forms.editform.plpAction.value='step:4';document.forms.editform.buttonSubmit.click();">categories</a></li><li class="li-complete"><a href=" javascript:document.forms.editform.plpAction.value='step:5';document.forms.editform.buttonSubmit.click();">Save</a></li><li class="li-cancel"><a href=" javascript:document.forms.editform.plpAction.value='cancel';document.forms.editform.submit();" onclick="return fPLPCancelConfirm();">Cancel</a></li>
				</ul>
			</div>

			<div id="plp-content">
		
	<script type="text/javascript">
		function fPLPCancelConfirm(){
			return window.confirm("Changes made will not be saved.\nDo you still wish to Cancel?");
		}
	</script>

<form action="/farcry/edittabEdit.cfm?objectid=A43034AD-EBF1-84EB-056F4D76CED61419" class="f-wrap-1 wider f-bg-short" name="editform" method="post">	
	<fieldset>
		<div class="req"><b>*</b>Required</div>
<h3>General Info: <span class="highlight">Breathe Creativity - Welcome</span></h3>

	<label for="title"><b>Title:<span class="req">*</span></b>
		<input type="text" name="title" id="title" value="Breathe Creativity - Welcome" maxlength="255" size="45" /><br />
	</label>

	<label for="metakeywords"><b>Keywords:</b>
		<input type="text" name="metakeywords" id="metakeywords" value="" maxlength="255" size="45" /><br />
	</label>
	<label for="extendedmetadata"><b>Extended Metadata</b>

		<a href="javascript:void(0);" onclick="doToggle('extendedmetadata','bHasMetaData');"><img src="/farcry/images/no.gif" id="tglextendedmetadata_image" border="0" alt="Extended Metadata"></a>
		<span id="tglextendedmetadata" style="display:none;">
		<fieldset>
			<textarea name="extendedmetadata" id="extendedmetadata" wrap="soft" cols="35" rows="5"></textarea>
			<br />
			* typically this will be inserted unaltered into the HEAD section of your templates
		</fieldset>
		</span>
		<input type="hidden" id="bHasMetaData" name="bHasMetaData" value="0">

		<br />
	</label>

	
<span class="f-multiselect-wrap" style="position:relative;padding-bottom: 2em;margin-bottom: 1em">
	<b>Review Date:</b>
	
		<div id="pretext_Review" style="position:absolute; bottom:2em;left:135px;font-weight: bold"></div>
		<a href="#" style="position:absolute; bottom:0;left:135px;" onclick="return doToggleReview();"><div id="linkText_Review">Remove Review date</div></a>
	
	<span id="tglReview">

	<select name="ReviewDay" id="ReviewDay">
		<option value="1">1</option>
		<option value="2">2</option>
		<option value="3">3</option>
		<option value="4">4</option>
		<option value="5">5</option>

		<option value="6">6</option>
		<option value="7">7</option>
		<option value="8">8</option>
		<option value="9">9</option>
		<option value="10" selected="selected">10</option>
		<option value="11">11</option>

		<option value="12">12</option>
		<option value="13">13</option>
		<option value="14">14</option>
		<option value="15">15</option>
		<option value="16">16</option>
		<option value="17">17</option>

		<option value="18">18</option>
		<option value="19">19</option>
		<option value="20">20</option>
		<option value="21">21</option>
		<option value="22">22</option>
		<option value="23">23</option>

		<option value="24">24</option>
		<option value="25">25</option>
		<option value="26">26</option>
		<option value="27">27</option>
		<option value="28">28</option>
		<option value="29">29</option>

		<option value="30">30</option>
		<option value="31">31</option>
	</select>	

	<select name="ReviewMonth" id="ReviewMonth">
		<option value="1">January</option>
		<option value="2">February</option>
		<option value="3">March</option>

		<option value="4" selected="selected">April</option>
		<option value="5">May</option>
		<option value="6">June</option>
		<option value="7">July</option>
		<option value="8">August</option>
		<option value="9">September</option>

		<option value="10">October</option>
		<option value="11">November</option>
		<option value="12">December</option>
	</select>

	<select name="ReviewYear" id="ReviewYear">
		<option value="2003">2003</option>

		<option value="2004">2004</option>
		<option value="2005">2005</option>
		<option value="2006" selected="selected">2006</option>
		<option value="2007">2007</option>
		<option value="2008">2008</option>
		<option value="2009">2009</option>

	</select><br />
	
	</span>
</span>
	
<input type="hidden" id="noReview" name="noReview" value="0">
<script type="text/javascript">
function doToggleReview(){
	objTgl = document.getElementById('tglReview');
	objHidden = document.getElementById("noReview");
	d = document.getElementById('linkText_Review');
	e = document.getElementById('pretext_Review');

	objYear = document.getElementById('ReviewYear');
	objMonth = document.getElementById('ReviewMonth');
	objDay = document.getElementById('ReviewDay');

	if(objTgl.style.visibility == "hidden"){
		objTgl.style.visibility = "visible";
		d.innerHTML = "Remove Review date";
	 	e.innerHTML = "";
		objHidden.value = 0;

		// default the expiry year
		for(i=0; i<objYear.length; i++){
			if(objYear[i].value == 2006){
				objYear[i].selected = true;
				break;
			}
		}

		// default the expiry month
		for(i=0; i<objMonth.length; i++){
			if(objMonth[i].value == 5){
				objMonth[i].selected = true;
				break;
			}
		}
		
		// default the expiry day
		for(i=0; i<objDay.length; i++){
			if(objDay[i].value == 20){
				objDay[i].selected = true;
				break;
			}
		}
	}
	else {
		objTgl.style.visibility = "hidden";
		d.innerHTML = "Set an Review date";
		e.innerHTML = "No Review date set |";
		objHidden.value = 1;
	}
	return false;
}
</script>
	


	
	
	


  
  
  	
	
	
  
	

	
	
 
 
	
	
 	
	
	

 	

 	





 
 

	





	

	
		
	
	
	
	
	

	
	
		
	
	
	
	

	
	
	
	
	
	
	
	
	

	
	

	



	
	

	

	
	
	

	 
	





	
	

	
	
	
	
	
	
	
	
	

	
	
	
	
	
	

	
		
	
	
	
	
	

	
	

	

	

	
	
	

	
		
		

		
    
    

    

    
	
	

	

<label for="ownedBy"><b>Content Owner:</b>

	<select name="ownedBy" id="ownedBy">
		<option value="8009C7A3-C120-C9DB-D0DB62D1A0DBAF48" selected="selected">jacqueline

</option>
		<option value="70ABFF16-ECF6-2530-2976B1008111A918">Bryant, Matthew
</option>
	</select><br />	
</label> 
	<label for="DisplayMethod"><b>Display Method:</b>
		
		 
			<select name="DisplayMethod" size="1">
			<option value="displaypagetypePopup"> type-Popup </option>
			<option value="displaypagetypeA"> type-a </option>

			<option value="displaypagetypeB"> type-b </option>
			<option value="displaypagetypeC" selected="selected"> type-c </option>
			<option value="displaypagetypeD"> type-d </option>
			<option value="displaypagetypeE"> type-e </option>
			<option value="displaypagetypeF"> type-e </option>

			
			</select>
		
		<br />
	</label>

</fieldset>

<input type="hidden" name="plpAction" value="" />
<input style="display:none;" type="submit" name="buttonSubmit" value="submit" />
</form>

<script type="text/javascript">
<!--//
function doToggle(prefix,bHiddenFieldName){
	objTgl = document.getElementById('tgl' + prefix);
	objTglImage = document.getElementById('tgl' + prefix + '_image');

	if(bHiddenFieldName)
		objTglHiddenValue = document.getElementById(bHiddenFieldName);

	if(objTgl.style.display == "none"){
		objTgl.style.display = "inline";
		objTglImage.src = "/farcry/images/yes.gif";
		objTglImage.alt = "No extended metadata";

		if(bHiddenFieldName)
			objTglHiddenValue.value = 1;
	}else {
		objTgl.style.display = "none";
		objTglImage.src = "/farcry/images/no.gif";
		objTglImage.alt = "Extended Metadata";
		
		if(bHiddenFieldName)
			objTglHiddenValue.value = 0;
	}	
}
//-->
</script>

<script type="text/javascript">
<!--//
// initialize the qForm object
objForm = new qForm("editform");
qFormAPI.errorColor="#cc6633";
// make these fields required
//objForm.required("title");

// check whether has a title field or name field or label field, as they are used place of each other
if(objForm.title)
	objTitle = objForm.title
else if(objForm.name)
	objTitle = objForm.name
else if(objForm.label)
	objTitle = objForm.label

if(objTitle){
	objTitle.validateNotNull("Please enter a title");
	objTitle.validateNotEmpty("Please enter a title");
}

//-->

</script> 
			</div>
			
			<hr class="clear hidden" />
			
			<div class="pagination pg-bot">
				<ul><li class="li-next"><a href=" javascript:document.forms.editform.plpAction.value='next';document.forms.editform.buttonSubmit.click();">Next</a></li></ul>
			</div>
		
		</div>
		
	<script type="text/javascript">
		function fPLPCancelConfirm(){
			return window.confirm("Changes made will not be saved.\nDo you still wish to Cancel?");
		}
	</script>

</body>
</html>
