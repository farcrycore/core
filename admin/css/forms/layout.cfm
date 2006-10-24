<!--- allow output only from cfoutput tags --->
<cfsetting enablecfoutputonly="yes" />

<!--- assign widths to strings for form elements --->
<cfscript>
	/*
	legacy layout variables
	*/

	/* form */
	formWidth = "600px";

	/* left column */
	columnLeftWidth = "140px";

	/* right column */
	columnRightWidth = "150px";

	/* form notes component */
	notesWidth = "150px";

	/* temporary url string pointing to images on skunkworks */
	skunkworks = "http://skunkworks.farcrycms.com/grae/farcry/formtools";


	/*
	new layout variables
	*/

	/* set formtool object */
	request.formtool = structNew();

	/* form width */
	request.formtool.width = "700px";

	/* form width */
	request.formtool.widthMax = "800px";

	/* left column */
	request.formtool.widthLeft = "180px";

	/* right column */
	request.formtool.widthRight = "400px";


</cfscript>

<!---
the following style tag enables tag insight in your IDE
and is placed before the cfoutput tag to prevent being output.
--->
<style>

<!--- output css --->
<cfoutput>
/*
=================================================================================
layout.css:
=================================================================================

this stylesheet defines the layout of page elements - and should be linked first

this stylesheet defines the following page elements:
- margins
- padding
- width/heights
- relative/absolute positions
- top/left/right/bottom positioning
- clears
- floats
- display types

*/

/* form layout styles */
form {margin: 0px; padding: 0px;}
form.formtool {margin: 0px 0px 0px 0px; padding: 0px;}
form.formtool fieldset {margin: 0px 0px 0px 0px; padding: 10px 10px 10px 10px;}
body.library form.formtool {width: auto;}
form.formtool fieldset legend {margin: 10px 0px 10px 0px; padding: 0px 5px 0px 5px;}
textarea.formtool {overflow: auto;}
form.formtool fieldset div.notes {margin: 0px 0px 10px 10px; padding: 5px 5px 5px 5px; width: #notesWidth#; height: auto; float: right;}
form.formtool fieldset div.notes h4 {margin: 0px; padding: 3px 0px 3px 0px;}
form.formtool fieldset div.notes p {margin: 0em 0em 1.2em 0em;}
form.formtool fieldset div.notes p.last {margin: 0em;}
form.formtool fieldset legend {padding: 0px 3px 0px 9px;}
/* formtool form left column layout styles */
form.formtool div.fieldSection {margin: 0px; padding: 0px; display: block; height: auto;}
/* formtool form left column layout styles */
form.formtool label {margin: 0px 0px 5px 0px; padding: 0px 10px 3px 5px; width: #request.formtool.widthLeft#; display: block; float: left; text-align: right;}
/* formtool form right column layout styles */
form.formtool div.fieldAlign {margin: 0px; padding: 0px; width: #request.formtool.widthRight#; display: block; float: left;}

<!--- form.formtool label {margin: 0px 0px 5px 0px; padding: 0px 5px 3px 5px; width: #columnLeftWidth#; display: block; float: left;} --->
<!--- form.formtool .optional label, label.optional {}
form.formtool .required label, label.required {}--->

form.formtool label.labelCheckbox,
	form.formtool label.labelRadio {margin: 0px 0px 5px 142px; padding: 0px 0px 0px 0px; width: 200px; height: 1%; display: block; float: none;}

form.formtool fieldset label.labelCheckbox,
	form.formtool fieldset label.labelRadio {margin: 0px 0px 5px 0px; width: 170px;}

p.error {margin: auto 100px auto 100px; padding: 3px 3px 5px 27px;}
form.formtool .error {}
form.formtool .error p.error {margin: 0px 0px 0px 118px; width: 200px;}

form.formtool input,
	form.formtool select,
	form.formtool textarea {margin: 0px 0px 0px 0px; padding: 1px 3px 1px 3px; width: 200px;}

	form.formtool textarea {height: 8.0em;}
	form.formtool .richtext textarea {height: auto;}
	

form.formtool input.inputFile {width: 211px;}

form.formtool select.selectOne,
	form.formtool select.selectMultiple {padding: 1px 3px 1px 3px; width: 211px;}

form.formtool input.inputCheckbox,
	form.formtool input.inputRadio,
	input.inputCheckbox,
	input.inputRadio {margin: 0px 0px 0px 140px; padding: 0px 0px 0px 0px; width: 14px; height: 14px; display: inline;}

form.formtool .submit {padding: 0px 0px 0px 140px; width: 214px;}
form.formtool .submit {margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px; width: auto; display: inline; float: left;}

form.formtool input.inputSubmit,
	form.formtool input.inputButton,
	input.inputSubmit,
	input.inputButton {margin: 0px 0px 0px 0px; padding: 0px 6px 0px 6px; width: auto;}

form.formtool input[type=checkbox] {width: auto; marging: 0px; padding: 0px;}

form.formtool .submit input.inputSubmit,
	form.formtool .submit input.inputButton {margin: 0px 0px 0px 5px; float: right;}

form.formtool small {margin: 0px 0px 5px 142px; padding: 1px 3px 1px 3px; height: 1%; display: block;}

form.formtool textarea.expanding {overflow: auto; overflow-x: auto; overflow-y: visible;}

form.formtool label.labelCheckbox,
	form div label.labelRadio,
	label.labelCheckbox,
	label.labelRadio {padding: 4px 0px 0px 18px; width: 190px; height: 1%; display: block;}

form.formtool label.labelCheckbox input.inputCheckbox,
	form div label.labelRadio input.inputRadio,
	label.labelCheckbox input.inputCheckbox,
	label.labelRadio input.inputRadio {margin: 0px 0px 0px 0px;}

form.formtool fieldset input.inputText,
	form.formtool fieldset input.inputPassword,
	form.formtool fieldset input.inputFile,
	form.formtool fieldset textarea.inputTextarea {margin: 0px 0px 0px 18px; width: 160px;}

form.formtool label.compact {margin: 0px 0px 0px 0px; padding: 4px 10px 0px 0px; width: auto; display: inline;}
form.formtool .wide label {display: block; float: none;}
form.formtool label.wide {width: 348px;}

form.formtool .wide input.inputText,
	form.formtool .wide input.inputPassword,
	form.formtool .wide input.inputFile,
	form.formtool .wide select,
	form.formtool .wide textarea {width: 344px; margin: 0px;}

form.formtool .notes p, form.formtool small {}
form.formtool .wide small {margin: 0px 0px 5px 0px;}

form.formtool .formSection .fieldAlign {float: left; margin: 0px; padding: 0px;}
form.formtool .passwordlabel {display: none;}

form.formtool .formSection .password .fieldAlign {float: none; margin: 0px 0px 0px #columnLeftWidth#; padding: 0px;}
form.formtool .fieldSection .clearer {clear: both;}

form.formtool .formCheckbox {width: auto; border: none;}
form.formtool .category .fieldwrap input {border: none;}

form.formtool ##wizard-content select {width: auto; margin: 0px; padding: 0px;}
form.formtool ##wizard-content select option {width: auto; margin: 0px; padding: 0px 3px 0px 3px;}

input.validation-failed, textarea.validation-failed {border: 1px solid ##FF3300; color: ##FF3300;}
.validation-advice {margin: 5px 0px 5px 0px; padding: 5px 5px 5px 5px; background-color: ##FF3300; color: ##FFFFFF; font-weight: bold;}
.custom-advice {margin: 5px 0px 5px 0px; padding: 5px 5px 5px 5px; background-color: ##C8AA00; color: ##FFFFFF; font-weight: bold;}

/* formtool form components */
	/* formtool input : formButton layout styles */	
	form.formtool input.formButton {margin: 0px; padding: 0px; height: 18px; vertical-align: top;}
	/* formtool input : formCheckbox layout styles */	
	form.formtool input.formCheckbox {margin: 0px; padding: 0px; width: 12px; height: 12px;}
	/* formtool select layout styles */
	form.formtool select {margin: 0px; padding: 0px; height: 16px; float: left; display: block;}

/* formtool html button layout styles */
	/* formtool default html button group layout styles */
	form.formtool div.buttonGroup {margin: 0px; padding: 0px; display: block; float: right;}
	/* formtool default html button layout styles */
	form.formtool div.buttonStandard {margin: 0px; padding: 0px; height: 16px; width: 100px; display: block; float: left; vertical-align: top;}
		form.formtool div.buttonStandard a {margin: 0px; padding: 1px 4px 0px 4px; width: auto; height: 15px; display: block; text-align: center;}
	/* formtool default html view method button layout styles */
	form.formtool div.buttonViewMethod {margin: 0px; padding: 0px; width: 16px; height: 16px; display: block; float: left; vertical-align: top;}
		form.formtool div.buttonViewMethod a {margin: 0px; padding: 0px; width: 16px; height: 16px; display: block;}
			form.formtool div.buttonViewMethod a img {margin: 0px; padding: 1px 0px 0px 1px; width: 14px; height: 14px; display: block;}

	/* formtool array component layout styles */
	form.formtool div.array div.fieldAlign input.formButton {margin: 0px 5px 5px 0px; width: 70px; float: left; display: block;}
	form.formtool div.array div.fieldAlign input.formCheckbox {width: 10px; height: 10px;}

	form.formtool div.array div.fieldAlign {margin: 0px 0px 30px 0px; padding: 0px;}

	form.formtool div.array div.fieldAlign ul {margin: 0px 0px 5px 0px; padding: 0px;}

	/* array component : detail view layout styles */
	form.formtool div.array div.fieldAlign ul.arrayViewDetail {width: auto; height: auto; display: block;}
		form.formtool div.array div.fieldAlign ul.arrayViewDetail li {margin: 0px; padding: 0px; height: 19px;}
			form.formtool div.array div.fieldAlign ul.arrayViewDetail li div.buttonGripper {margin: 0px; padding: 1px 0px 0px 0px; width: 7px; height: 17px; display: block; float: left;}
				form.formtool div.array div.fieldAlign ul.arrayViewDetail li div.buttonGripper p {margin: 0px; padding: 0px; width: 7px; height: 17px; display: block;}
		 	form.formtool div.array div.fieldAlign ul.arrayViewDetail li input.formCheckbox {margin: 4px 2px 0px 0px; padding: 0px; display: block; float: right; overflow: hidden;}
			form.formtool div.array div.fieldAlign ul.arrayViewDetail li div.arrayDetail {margin: 0px; padding: 0px 0px 0px 10px; display: block;}
				form.formtool div.array div.fieldAlign ul.arrayViewDetail li div.arrayDetail p {margin: 0px 0px 0px 4px; padding: 3px 0px 0px 18px; width: auto; height: 16px; display: block;}
			form.formtool div.array div.fieldAlign ul.arrayViewDetail li div.arrayThumbnail {margin: 0px; padding: 0px; display: none;}

	/* array component : thumbnail view layout styles */
	form.formtool div.array div.fieldAlign ul.arrayViewThumbnail {width: auto; height: 300px; display: block; overflow: auto;}
		form.formtool div.array div.fieldAlign ul.arrayViewThumbnail li {margin: 5px 0px 0px 5px; padding: 0px; width: 52px; height: 62px; display: block; float: left; overflow: hidden;}
			form.formtool div.array div.fieldAlign ul.arrayViewThumbnail li div.buttonGripper {margin: 0px; padding: 0px; width: 40px; height: 9px; display: block; float: left;}
				form.formtool div.array div.fieldAlign ul.arrayViewThumbnail li div.buttonGripper p {margin: 0px; padding: 0px; width: 40px; height: 9px; display: block;}
			form.formtool div.array div.fieldAlign ul.arrayViewThumbnail li input.formCheckbox {margin: 0px; padding: 0px; display: block; float: right; overflow: hidden;}
			form.formtool div.array div.fieldAlign ul.arrayViewThumbnail li div.arrayDetail {margin: 0px; padding: 0px; display: none;}
			form.formtool div.array div.fieldAlign ul.arrayViewThumbnail li div.arrayThumbnail {margin: 0px; padding: 0px;}

<!--- end css output --->
</cfoutput>

<!--- end enable tag insight --->
</style>

<!--- end allow output only from cfoutput tags --->
<cfsetting enablecfoutputonly="no" />