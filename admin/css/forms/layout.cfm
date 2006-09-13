<!--- allow output only from cfoutput tags --->
<cfsetting enablecfoutputonly="yes" />

<!--- set content type of cfm to css to enable output to be parsed as css by all browsers 
<cfcontent type="text/css; charset=UTF-8">--->

<!---
the following style tag enables tag insight in your IDE
and is placed before the cfoutput tag to prevent being output.--->

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
form.content {margin: 0px auto 0px auto; padding: 0px; width: 600px;}
form fieldset {margin: 0px 0px 0px 0px; padding: 10px 10px 10px 10px; clear: both;}
form fieldset legend {margin: 0px 0px 0px 0px; padding: 0px 5px 0px 5px;}
label {}
label u {}
input, select, textarea {}
textarea {overflow: auto;}
div.content form div {margin: 5px 0px 0px 0px; padding: 1px 3px 1px 3px; width: 354px; height: 1%; display: block; clear: left;}
form fieldset div.notes {margin: 0px 0px 10px 10px; padding: 5px 5px 5px 5px; width: 150px; height: auto; float: right;}
form fieldset div.notes h4 {margin: 0px; padding: 3px 0px 3px 0px;}
form fieldset div.notes p {margin: 0em 0em 1.2em 0em;}
form fieldset div.notes p.last {margin: 0em;}
form div fieldset {margin: 0px 0px 0px 142px; padding: 0px 5px 5px 5px; width: 197px; clear: none;}
form div fieldset legend {padding: 0px 3px 0px 9px;}
form div.required fieldset legend {}
form div label {margin: 0px 0px 5px 0px; padding: 3px 5px 3px 5px; width: 130px; display: block; float: left;}
form div.optional label, label.optional {}
form div.required label, label.required {}
form div label.labelCheckbox, form div label.labelRadio {margin: 0px 0px 5px 142px; padding: 0px 0px 0px 0px; width: 200px; height: 1%; display: block; float: none;}
form div fieldset label.labelCheckbox, form div fieldset label.labelRadio {margin: 0px 0px 5px 0px; width: 170px;}
form div img {}
p.error {margin: auto 100px auto 100px; padding: 3px 3px 5px 27px;}
form div.error {}
form div.error p.error {margin: 0px 0px 0px 118px; width: 200px;}
form div input, form div select, form div textarea {margin: 0px 0px 0px 0px; padding: 1px 3px 1px 3px; width: 200px;}
form div input.inputFile {width: 211px;}
form div select.selectOne, form div select.selectMultiple {padding: 1px 3px 1px 3px; width: 211px;}
form div input.inputCheckbox, form div input.inputRadio, input.inputCheckbox, input.inputRadio {margin: 0px 0px 0px 140px; padding: 0px 0px 0px 0px; width: 14px; height: 14px; display: inline;}
form div.submit {padding: 0px 0px 0px 140px; width: 214px;}
form div.submit div {margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px; width: auto; display: inline; float: left;}
form div input.inputSubmit, form div input.inputButton, input.inputSubmit, input.inputButton {margin: 0px 0px 0px 0px; padding: 0px 6px 0px 6px; width: auto;}
form div.submit div input.inputSubmit, form div.submit div input.inputButton {margin: 0px 0px 0px 5px; float: right;}
form div small {margin: 0px 0px 5px 142px; padding: 1px 3px 1px 3px; height: 1%; display: block;}

form fieldset legend {}
form input, form select, form textarea {}
form textarea.expanding {overflow: auto; overflow-x: auto; overflow-y: visible;}
div.optional label:before {content: '';}
div.required label:before {content: '';}
form div label.labelCheckbox, form div label.labelRadio, label.labelCheckbox, label.labelRadio {padding: 4px 0px 0px 18px; width: 190px; height: 1%; display: block;}
form div label.labelCheckbox input.inputCheckbox, form div label.labelRadio input.inputRadio, label.labelCheckbox input.inputCheckbox, label.labelRadio input.inputRadio {margin: 0px 0px 0px 0px;}
form div fieldset input.inputText, form div fieldset input.inputPassword, form div fieldset input.inputFile, form div fieldset textarea.inputTextarea {margin: 0px 0px 0px 18px; width: 160px;}
form div label.compact {margin: 0px 0px 0px 0px; padding: 4px 10px 0px 0px; width: auto; display: inline;}
form div.wide label {display: block; float: none;}
form div label.wide {width: 348px;}
form div.wide input.inputText, form div.wide input.inputPassword, form div.wide input.inputFile, form div.wide select, form div.wide textarea {width: 344px; margin: 0px;}
form div.notes p, form div small {}
form div.wide small {margin: 0px 0px 5px 0px;}

<!--- end css output --->
</cfoutput>

<!--- end enable tag insight --->
</style>

<!--- end allow output only from cfoutput tags --->
<cfsetting enablecfoutputonly="no" />