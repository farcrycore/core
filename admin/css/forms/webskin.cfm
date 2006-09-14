<!--- allow output only from cfoutput tags --->
<cfsetting enablecfoutputonly="yes" />

<!--- include swatches file --->
<cfinclude template="swatches.cfm"/>

<!--- assign hex colour strings to component elements --->
<cfscript>
	/* body background */
	bgBody=hexWhite;

	/* nav backgrounds */
	bgNav=hexSecondaryDarker;							bgNavHover=hexSecondaryLighter;
	bgNavRollout=hexSecondaryDark;					bgNavRolloutHover=hexSecondaryLighter;
	bgNavActive=hexSecondaryLight;					bgNavActiveHover=hexSecondaryLighter;
	bgNavActiveRollout=hexSecondaryLight;			bgNavActiveRolloutHover=hexSecondaryLighter;

	/* first level nav borders */
	borderNavTop="";								borderNavRight=hexSecondaryDarker;
	borderNavBottom="";								borderNavLeft=hexSecondaryLighter;
	borderNavFirst="";								borderNavLast="";

	/* rollout level nav borders */	
	borderNavRolloutTop=hexSecondaryLighter;			borderNavRolloutRight=hexSecondaryDarker;
	borderNavRolloutBottom=hexSecondaryDarker;		borderNavRolloutLeft=hexSecondaryDarker;
	borderNavRolloutFirst="";						borderNavRolloutLast="";

	/* first level active nav borders */
	borderNavActiveTop="";							borderNavActiveRight=hexSecondaryDarker;
	borderNavActiveBottom="";						borderNavActiveLeft=hexSecondaryLighter;

	/* rollout level active nav borders */
	borderNavActiveRolloutTop=hexSecondaryLighter;	borderNavActiveRolloutRight=hexSecondaryDarker;
	borderNavActiveRolloutBottom=hexSecondaryDarker;borderNavActiveRolloutLeft=hexSecondaryDarker;
	borderNavActiveRolloutFirst="";					borderNavActiveRolloutLast="";


	/* search backgrounds & borders */
	bgSearchHead="transparent";			bgSearchBody=hexPrimaryDark;				bgSearchFoot="transparent";
	borderSearchHead="";				borderSearchBody=hexPrimaryDark;			borderSearchFoot=hexPrimaryDark;

	/* recent backgrounds & borders */
	bgRecentHead="transparent";			bgRecentBody=hexWhite;						bgRecentFoot="transparent";
	borderRecentHead="";				borderRecentBody=hexSecondaryLight;			borderRecentFoot=hexSecondaryLight;

	/* container backgrounds & borders */
	bgContainerHead="transparent";		bgContainerBody=hexSecondaryLightest;		bgContainerFoot="transparent";
	borderContainerHead="";				borderContainerBody=hexSecondaryLighter;	borderContainerFoot=hexSecondaryLighter;

	/* panel-tab backgrounds */
	bgPanelTabHead="transparent";

	/* panel backgrounds & borders */
	bgPanelHead="transparent";			bgPanelBody=hexWhite;						bgPanelFoot="transparent";
	borderPanelHead="";					borderPanelBody=hexPrimaryLighter;			borderPanelFoot=hexPrimaryLighter;

	/* pod-tab backgrounds  & borders */
	bgPodTabHead="transparent";

	/* pod backgrounds & borders */
	bgPodHead="transparent";			bgPodBody=hexWhite;							bgPodFoot="transparent";
	borderPodHead="";					borderPodBody=hexSecondaryDark;				borderPodFoot=hexSecondaryDark;
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
webskin.css:
=================================================================================

this stylesheet defines the skins of page elements - and should be linked second

this stylesheet defines the following page elements:
- background colours / graphics / positions
- border colours / styles / thickness
- sprite graphics / positions

*/

/*
form skin styles
*/

form {}
form.formtool fieldset {border-color: #hexPrimaryLighter#; border-width: 1px 0px 0px 0px; border-style: solid none none none;}
form.formtool fieldset fieldset {border: 1px solid #hexPrimaryLighter#;}
<!--- form.formtool .password .fieldAlign {float: none; margin: 0px 0px 0px #columnLeftWidth#; padding: 0px;} --->
form fieldset legend {}
label {}
label u {}
input, select, textarea {}
textarea {}
form div {}
form fieldset div.notes {border: 1px solid #hexPrimaryLight#; background-color: #hexPrimaryLighter#; color: inherit;}
<!--- /* form fieldset div.notes h4 {background-image: url(/images/icon_info.gif); background-repeat: no-repeat; background-position: top left; border-style: solid; border-color: ##666666;} */ --->
form fieldset div.notes p {}
form fieldset div.notes p.last {}
<!--- form div fieldset {border-width: 1px; border-style: solid; border-color: ##666666;} --->
form div fieldset legend {}
form div.required fieldset legend {}
form div label {}
form div.optional label, label.optional {}
form div.required label, label.required {}
form div label.labelCheckbox, form div label.labelRadio {}
form div fieldset label.labelCheckbox, form div fieldset label.labelRadio {}
p.error {background-color: ##ff0000; background-image: url(/images/icon_error.gif); background-repeat: no-repeat; background-position: 3px 3px; border: 1px solid ##000000; color: inherit; }
form div.error {background-color: ##ffffe1; background-image: url(/images/required_bg.gif); background-repeat: no-repeat; background-position: top left; border: 1px solid ##ff0000; color: inherit;}
form div.error p.error {background-image: url(/images/icon_error.gif); background-position: top left; background-color: transparent; border-style: none;}
form div input, form div select, form div textarea {}
form div input.inputFile {}
form div select.selectOne, form div select.selectMultiple {}
form div input.inputCheckbox, form div input.inputRadio, input.inputCheckbox, input.inputRadio {background-color: transparent; border-width: 0px;}
form div.submit {}
form div.submit div {}
form div input.inputSubmit, form div input.inputButton, input.inputSubmit, input.inputButton {background-color: ##cccccc; color: inherit;}
form div.submit div input.inputSubmit, form div.submit div input.inputButton {}
form div small {}

form fieldset legend {}
form input, form select, form textarea {background-color: #hexWhite#;}
form textarea.expanding {}
div.optional label:before {}
div.required label:before {}
form div label.labelCheckbox, form div label.labelRadio, label.labelCheckbox, label.labelRadio {}
form div label.labelCheckbox input.inputCheckbox, form div label.labelRadio input.inputRadio, label.labelCheckbox input.inputCheckbox, label.labelRadio input.inputRadio {}
form div fieldset input.inputText, form div fieldset input.inputPassword, form div fieldset input.inputFile, form div fieldset textarea.inputTextarea {}
form div label.compact {}
form div.wide label {}
form div label.wide {}
form div.wide input.inputText, form div.wide input.inputPassword, form div.wide input.inputFile, form div.wide select, form div.wide textarea {}
form div.notes p, form div small {}
form div.wide small {}

<!--- end css output --->
</cfoutput>

<!--- end enable tag insight --->
</style>

<!--- end allow output only from cfoutput tags --->
<cfsetting enablecfoutputonly="no" />