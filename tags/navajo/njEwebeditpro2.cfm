<cfsetting enablecfoutputonly="Yes">
<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/Attic/njEwebeditpro2.cfm,v 1.1.1.1 2002/09/27 06:54:04 petera Exp $
$Author: petera $
$Date: 2002/09/27 06:54:04 $
$Name: b100 $
$Revision: 1.1.1.1 $

|| DESCRIPTION || 
Tag to call eWebEditPro Editor.  This tag supercedes the one supplied with Spectra.

(	Ektron, Inc.
	Revision Date: 2001-03-19 )

|| USAGE ||
<cf_njEwebeditpro2
	width="700" 
	height="400" 
	name = "body" 
	value = "#output.body#" 
	form="editform"
	>

|| DEVELOPER ||
Geoff Bowers (modius@daemon.com.au)
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||
-> [Attributes.Path]: relative path to /ewebeditpro/ config directory
-> [Attributes.MaxContentSize]: content limit for editor
-> [Attributes.Name]: name of the editor (required)
-> [Attributes.Width]: width of editor
-> [Attributes.Height]: height of editor
-> [Attributes.Value]: body content of the editor
-> [Attributes.License]: license info (typically left undefined for Spectra)
-> [Attributes.Locale]: region settings
-> [Attributes.Config]: unknown
-> [Attributes.BodyStyle]: The bodyStyle parameter sets any valid CSS style supported by your browser (eg. "background-color: black; font-size: 24pt") - we use Stylesheets instead of this option now 20020318 GB
-> [Attributes.HideAboutButton]: show about ektron button (default to hidden ie. true)
-> [Attributes.onDblClickElement" default="undefined">
-> [Attributes.onExecCommand" default="undefined">
-> [Attributes.onFocus" default="undefined">
-> [Attributes.onBlur" default="undefined">

|| HISTORY ||
$Log: njEwebeditpro2.cfm,v $
Revision 1.1.1.1  2002/09/27 06:54:04  petera
no message

Revision 1.2  2002/09/18 01:03:28  geoff
no message

Revision 1.1  2002/09/03 00:19:21  geoff
no message

Revision 1.5  2002/03/19 00:13:24  geoff
Updated attributes and tidied up. Added CONFIG and STYLESHEET attributes.


|| END FUSEDOC ||
--->

<!--- required parameters --->
<cfparam name="Attributes.Name">

<!--- optional parameters --->
<cfparam name="Attributes.Path" default="#application.url.farcry#/ewebeditpro2/">
<cfparam name="Attributes.MaxContentSize" default="262144">
<cfparam name="Attributes.Width" default="100%">
<cfparam name="Attributes.Height" default="400">
<cfparam name="Attributes.Value" default="">
<cfparam name="Attributes.License" default="undefined">
<cfparam name="Attributes.Locale" default="undefined">
<!--- <cfparam name="Attributes.Config" default="undefined"> --->
<cfparam name="Attributes.BodyStyle" default="undefined">
<cfparam name="Attributes.HideAboutButton" default="true">
<cfparam name="Attributes.onDblClickElement" default="undefined">
<cfparam name="Attributes.onExecCommand" default="undefined">
<cfparam name="Attributes.onFocus" default="undefined">
<cfparam name="Attributes.onBlur" default="undefined">

<cfparam name="Attributes.config" default="#application.url.farcry#/ewebeditpro2/config.xml">
<cfparam name="Attributes.stylesheet" default="#application.url.farcry#/ewebeditpro2/headingStyles.css">

<cfoutput>

<script>
applicationRootUrl = "#application.url.farcry#";
</script>

<script language="JavaScript1.2" src="#application.url.farcry#/ewebeditpro2/ewebeditpro.js"></script>

<!-- eWebEditPro content -->
<input type="hidden" name="#Attributes.Name#" value="#HTMLEditFormat(Attributes.Value)#">

<script language="JavaScript1.2">
<!--
with (eWebEditPro.parameters)
{
// there is a mix of several var assigments and several replications
// should reorganise this for all parameters in a collection loop..
// no time now. 20020318 GB
	<cfif Attributes.MaxContentSize neq "undefined">
maxContentSize = #Attributes.MaxContentSize#;
	</cfif>
	<cfif Attributes.License neq "undefined">
license = "#Attributes.License#";
	</cfif>
	<cfif Attributes.Locale neq "undefined">
locale = "#Attributes.Locale#";
	</cfif>
	<cfif Attributes.Config neq "undefined">
// config = "#Attributes.Config#";
	</cfif>
	<cfif Attributes.BodyStyle neq "undefined">
bodyStyle = "#Attributes.BodyStyle#";
	</cfif>
	<cfif Attributes.HideAboutButton neq "undefined">
hideAboutButton = "#Attributes.HideAboutButton#";
	</cfif>

	<cfif Attributes.onDblClickElement neq "undefined">
ondblclickelement = "#Attributes.onDblClickElement#";
	</cfif>
	<cfif Attributes.onExecCommand neq "undefined">
onexeccommand = "#Attributes.onExecCommand#";
	</cfif>
	<cfif Attributes.onFocus neq "undefined">
onfocus = "#Attributes.onFocus#";
	</cfif>
	<cfif Attributes.onBlur neq "undefined">
onblur = "#Attributes.onBlur#";
	</cfif>
}

// function to set stylesheet when Ektron is loaded
// not sure that this is entirely needed given other options in Ektron
// but for now I assume Matson was up to something 20020318 GB
function setStyleSheet(strEditorName, strCSS) {
    eWebEditPro[strEditorName].setProperty("StyleSheet", strCSS );
}

// loads basic config XML packet for setting up the editor defaults
eWebEditPro.parameters.config="#attributes.config#";

// Define Stylesheet for this instance of the eWebEditPro Editor
// Calls setStyleSheet() when ektron is fully loaded
eWebEditPro.onready = "setStyleSheet(eWebEditPro.event.srcName, '#attributes.stylesheet#')";

// alternative stylesheet loader (why not use this??)
//eWebEditPro.parameters.styleSheet="#application.url.farcry#/ewebeditpro/headingStyles.css";
// bodyStyle is really superceded by Stylesheets
//eWebEditPro.parameters.bodyStyle = "background-color: yellow; font-size: 24pt";

// maxContentSize already defined...
// eWebEditPro.parameters.maxContentSize=262144;

// spawn editor 
eWebEditPro.create("#Attributes.Name#", "#Attributes.Width#", "#Attributes.Height#");

// no idea what this does
eWebEditPro.parameters.reset();

// function to get value out of editor for form submission
function HTMLEditCopyValue()
{
	
	document.all['#Attributes.Name#'].value = eWebEditPro['#Attributes.Name#'].getBodyHTML();
	alert(document.all['#Attributes.Name#'].value);
}
//-->
</script>
</cfoutput>

<cfsetting enablecfoutputonly="No">

