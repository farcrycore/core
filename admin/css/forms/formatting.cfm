<!--- allow output only from cfoutput tags --->
<cfsetting enablecfoutputonly="yes" />

<!--- assign hex colour strings to component elements --->
<cfscript>
	/* body background */
	bodyAll = "##676767";
	aLink = "##5292c6"; aVisited = "##3c5b87"; aHover = "##94a9c5"; aActive = "##94a9c5";

	/* container backgrounds */
	cHeadH1 = hexPrimary; cBodyH1 = "##787878";

	/* panel backgrounds */
	paHeadH1 = "##d9e7f2"; paBodyH1 = "##989898";

	/* control backgrounds */
	coHeadH1 = "##505050"; coBodyH1 = "##FFFFFF"; coBodyH2 = "##FFFFFF"; coBodyP = "##FFFFFF";

	/* pod backgrounds */
	poHeadH1 = "##CDCDCD"; poBodyH1 = "##787878";
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
formatting.css:
=================================================================================

this stylesheet defines the typographic formatting of page elements - and should be linked third

this stylesheet defines the following page elements:
- colours
- font properties in shorthand
- typographic properties such as transform/align/kerning/leading
- typographic element margins/padding
- list formatting properties
- form formatting properties
*/

/* form formatting styles */
form {font-size: 100%;}
form fieldset {font-size: 100%;}
form fieldset legend {font-size: 150%; font-weight: normal; color: #hexPrimaryDark#;}
label {font-size: 100%;}
label u {font-style: normal; text-decoration: underline;}
input, select, textarea {font-family: Tahoma, Arial, sans-serif; font-size: 100%; color: ##000000;}
textarea {}
form div {}
form fieldset div.notes {color: ##666666; font-size: 88%;}
form fieldset div.notes h4 {color: ##666666; font-size: 120%;}
form fieldset div.notes p {color: ##666666;}
form fieldset div.notes p.last {}
form div fieldset {}
form div fieldset legend {font-size: 100%;}
form div.required fieldset legend {font-weight: bold;}
form div label {text-align: right;}
form div.optional label, label.optional {font-weight: normal;}
form div.required label, label.required {font-weight: bold;}
form div label.labelCheckbox, form div label.labelRadio {text-align: left;}
form div fieldset label.labelCheckbox, form div fieldset label.labelRadio {}
form div img {}
p.error {color: ##ffffff;}
form div.error {color: ##666666;}
form div.error p.error {font-size: 88%; font-weight: bold; color: ##ff0000;}
form div input, form div select, form div textarea {}
form div input.inputFile {}
form div select.selectOne, form div select.selectMultiple {}
form div input.inputCheckbox, form div input.inputRadio, input.inputCheckbox, input.inputRadio {}
form div.submit {}
form div.submit div {text-align: left;}
form div input.inputSubmit, form div input.inputButton, input.inputSubmit, input.inputButton {color: ##000000;}
form div.submit div input.inputSubmit, form div.submit div input.inputButton {}
form div small {font-size: 88%;}

form fieldset legend {line-height: 150%;}
form input, form select, form textarea {}
form textarea.expanding {}
div.optional label:before {content: '';}
div.required label:before {content: '';}
form div label.labelCheckbox, form div label.labelRadio, label.labelCheckbox, label.labelRadio {text-indent: -18px; line-height: 120%;}
form div label.labelCheckbox input.inputCheckbox, form div label.labelRadio input.inputRadio, label.labelCheckbox input.inputCheckbox, label.labelRadio input.inputRadio {}
form div fieldset input.inputText, form div fieldset input.inputPassword, form div fieldset input.inputFile, form div fieldset textarea.inputTextarea {}
form div label.compact {text-indent: 0px;}
form div.wide label {}
form div label.wide {}
form div.wide input.inputText, form div.wide input.inputPassword, form div.wide input.inputFile, form div.wide select, form div.wide textarea {}
form div.notes p, form div small {line-height: 125%;}
form div.wide small {}

<!--- end css output --->
</cfoutput>

<!--- end enable tag insight  --->
</style>

<!--- end allow output only from cfoutput tags --->
<cfsetting enablecfoutputonly="no" />