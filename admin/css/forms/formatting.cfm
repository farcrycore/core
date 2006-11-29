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

/* start legacy formtool css  */
form.formtool {font-size: 100%;}
form.formtool fieldset {font-size: 100%;}
form.formtool fieldset legend {font-size: 150%; font-weight: normal; color: #hexPrimaryDark#;}

form.formtool label u {font-style: normal; text-decoration: underline;}
input, select, textarea {font-family: Tahoma, Arial, sans-serif; font-size: 100%; color: ##000000;}
form fieldset div.notes {color: ##666666; font-size: 88%;}
form fieldset div.notes h4 {color: ##666666; font-size: 120%;}
form fieldset div.notes p {color: ##666666;}
form div fieldset legend {font-size: 100%;}
form div.required fieldset legend {font-weight: bold;}
form.formtool label {text-align: right;}
form.formtool div.optional label, form.formtool label.optional {font-weight: normal;}
form.formtool div.required label, form.formtool label.required {font-weight: bold;}
form.formtool label.labelCheckbox, form.formtool label.labelRadio {text-align: left;}
p.error {color: ##ffffff;}
form div.error {color: ##666666;}
form div.error p.error {font-size: 80%; font-weight: bold; color: ##ff0000;}
form div.submit div {text-align: left;}
form div input.inputSubmit, form div input.inputButton, input.inputSubmit, input.inputButton {color: ##000000;}
form div small {font-size: 88%;}

form fieldset legend {line-height: 150%;}
form.formtool label.labelCheckbox, form.formtool label.labelRadio, form.formtool label.labelCheckbox, form.formtool label.labelRadio {text-indent: -18px; line-height: 120%;}
form.formtool label.compact {text-indent: 0px;}
form div.notes p, form div small {line-height: 125%;}

<!--- form.formtool ##wizard-content select {font-size: 90%; line-height: normal;} --->
<!--- form.formtool ##wizard-content select option {font-size:inherit; line-height:inherit;} --->
/* end legacy formtool css  */

/* start new formtool formatting styles */
	/* formtool form layout styles */
	form.formtool label {font: normal 120%/1.0 "Trebuchet MS",arial,helvetica,sans-serif; color: ##324e7c; letter-spacing: 0.0em; background-color: inherit;}

/* formtool form components */
	/* formtool input : formButton layout styles */	
	form.formtool input.formButton {font-size: 90%; color: ##30326F; background-color: inherit;}
	/* formtool select layout styles */
	form.formtool select {font-size: 100%; color: ##324e7c; line-height: normal; background-color: inherit;}

/* formtool html button formatting styles */
	/* formtool default html button formatting styles */
	form.formtool div.buttonStandard a {font-size: 80%;}
	form.formtool div.buttonStandard a {color: ##30326F; background-color: inherit; text-decoration: none;}

	/* array component : detail view formatting styles */
	ul.arrayDetailView li {line-height: normal;}
		ul.arrayDetailView li div.buttonGripper p {font-size: 0%; line-height: normal;}
		ul.arrayDetailView li div.arrayDetail p {color: ##30326F; font-size: 100%; background-color: inherit;}

	/* array component : thumbnail view formatting styles */
	ul.arrayThumbnailView li div.buttonGripper p {font-size: 0%; line-height: normal;}

/* start new formtool formatting styles */
</cfoutput>
<!--- end css output --->

</style>
<!--- end enable tag insight  --->

<cfsetting enablecfoutputonly="no" />
<!--- end allow output only from cfoutput tags --->