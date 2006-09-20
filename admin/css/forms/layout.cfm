`<!--- allow output only from cfoutput tags --->
<cfsetting enablecfoutputonly="yes" />

<!--- assign widths to strings for form elements --->
<cfscript>
	/* form */
	formWidth = "600px";

	/* left column */
	columnLeftWidth = "130px";

	/* right column */
	columnRightWidth = "150px";

	/* form notes component */
	notesWidth = "150px";
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
p.asdafas {border: 3px solid green;}
form {margin: 0px; padding: 0px;}
form.formtool {margin: 0px 0px 0px 0px; padding: 0px; width: #formWidth#;}
form.formtool fieldset {margin: 0px 0px 0px 0px; padding: 10px 10px 10px 10px;}
<!--- form.formtool #wizard-wrap fieldset {margin: 0px 0px 0px 0px; padding: 10px 10px 10px 10px;}--->
form.formtool fieldset legend {margin: 10px 0px 10px 0px; padding: 0px 5px 0px 5px;}
label {}
label u {}
input, select, textarea {}
textarea.formtool {overflow: auto;}
<!--- div.content form div {margin: 5px 0px 0px 0px; padding: 1px 3px 1px 3px; width: 354px; height: 1%; display: block; clear: left;} --->
form.formtool fieldset div.notes {margin: 0px 0px 10px 10px; padding: 5px 5px 5px 5px; width: #notesWidth#; height: auto; float: right;}
form.formtool fieldset div.notes h4 {margin: 0px; padding: 3px 0px 3px 0px;}
form.formtool fieldset div.notes p {margin: 0em 0em 1.2em 0em;}
form.formtool fieldset div.notes p.last {margin: 0em;}
<!--- form div fieldset {margin: 0px 0px 0px 142px; padding: 0px 5px 5px 5px; width: 197px; clear: none;} --->
form.formtool fieldset legend {padding: 0px 3px 0px 9px;}
<!--- form.formtool .required fieldset legend {} --->
form.formtool label {margin: 0px 0px 5px 0px; padding: 0px 5px 3px 5px; width: #columnLeftWidth#; display: block; float: left;}
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

<!--- form fieldset legend {}
form.formtool input, form.formtool select, form.formtool textarea {} --->
form.formtool textarea.expanding {overflow: auto; overflow-x: auto; overflow-y: visible;}
<!--- div.optional label:before {content: '';}
div.required label:before {content: '';} --->

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

form.formtool .formsection .fieldAlign {float: left; margin: 0px; padding: 0px;}
form.formtool .passwordlabel {display: none;}
<!--- form.formtool .password label label {display: block;} --->

form.formtool .formsection .password .fieldAlign {float: none; margin: 0px 0px 0px #columnLeftWidth#; padding: 0px;}
form.formtool .fieldsection .clearer {clear: both;}

<!--- end css output --->
</cfoutput>

<!--- end enable tag insight --->
</style>

<!--- end allow output only from cfoutput tags --->
<cfsetting enablecfoutputonly="no" />