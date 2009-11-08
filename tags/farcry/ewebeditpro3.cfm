<!--- 
 // DEPRECATED
	farcry:ewebeditpro3 is no longer in use and will be removed from the code base. 
	You should be using formtools sub-system instead.
--------------------------------------------------------------------------------------------------->
<!--- @@bDeprecated: true --->
<cfset application.fapi.deprecated("farcry:ewebeditpro3 is no longer in use and will be removed from the code base. You should be using formtools sub-system instead.") />


<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/farcry/ewebeditpro3.cfm,v 1.3 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: Displays an editor for long text input. Based on config settings unless in toggle mode which will display a basic html text area$


|| DEVELOPER ||
$Developer: Tom Cornilliac (tomc@co.deschutes.or.us) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfparam name="Attributes.Path" default="/ewebeditpro3/">
<cfparam name="Attributes.MaxContentSize" default="undefined">
<cfparam name="Attributes.Name" default="undefined">
<cfparam name="Attributes.EditorName" default="undefined"> <!--- alternative to Name --->
<cfparam name="Attributes.Width" default="100%">
<cfparam name="Attributes.Height" default="100%">
<cfparam name="Attributes.Value" default="">
<cfparam name="Attributes.License" default="undefined">
<cfparam name="Attributes.Locale" default="undefined">
<cfparam name="Attributes.Config" default="undefined">
<cfparam name="Attributes.StyleSheet" default="undefined">
<cfparam name="Attributes.BodyStyle" default="undefined">
<cfparam name="Attributes.HideAboutButton" default="undefined">
<cfparam name="Attributes.WDDX" default="undefined"> <!--- for compatibility with version 1.8 --->
<cfparam name="Attributes.onDblClickElement" default="undefined">
<cfparam name="Attributes.onExecCommand" default="undefined">
<cfparam name="Attributes.onFocus" default="undefined">
<cfparam name="Attributes.onBlur" default="undefined">
<cfsetting enablecfoutputonly="No">

<cfif Attributes.EditorName neq "undefined">
<cfset Attributes.Name=Attributes.EditorName>
</cfif>

<cfoutput>

<script language="JavaScript1.2" src="#Attributes.Path#ewebeditpro.js"></script>

<cfif Attributes.WDDX neq "undefined">
<!-- eWebEditPro WDDX data -->
<input type="hidden" name="#Attributes.Name#WDDX" value="#HTMLEditFormat(Attributes.WDDX)#"> 
</cfif>

<!-- eWebEditPro content -->
<input type="hidden" name="#Attributes.Name#" value="#HTMLEditFormat(Attributes.Value)#">

<script language="JavaScript1.2">
<!--
	<cfif Attributes.MaxContentSize neq "undefined">
eWebEditPro.parameters.maxContentSize = #Attributes.MaxContentSize#;
	</cfif>
	<cfif Attributes.License neq "undefined">
eWebEditPro.parameters.license = "#Attributes.License#";
	</cfif>
	<cfif Attributes.Locale neq "undefined">
eWebEditPro.parameters.locale = "#Attributes.Locale#";
	</cfif>
	<cfif Attributes.Config neq "undefined">
eWebEditPro.parameters.config = "#Attributes.Config#";
	</cfif>
	<cfif Attributes.StyleSheet neq "undefined">
eWebEditPro.parameters.styleSheet = "#Attributes.StyleSheet#";
	</cfif>
	<cfif Attributes.BodyStyle neq "undefined">
eWebEditPro.parameters.bodyStyle = "#Attributes.BodyStyle#";
	</cfif>
	<cfif Attributes.HideAboutButton neq "undefined">
eWebEditPro.parameters.hideAboutButton = "#Attributes.HideAboutButton#";
	</cfif>
	<cfif Attributes.WDDX neq "undefined">
	var elemWDDX = findElement("#Attributes.Name#WDDX");
	if (elemWDDX)
	{
eWebEditPro.parameters.wddx = elemWDDX.value;
	}
	else
	{
eWebEditPro.parameters.wddx = "";
		alert('Unable to find WDDX element: "#Attributes.Name#WDDX"');
	}
	</cfif>

	<cfif Attributes.onDblClickElement neq "undefined">
eWebEditPro.parameters.ondblclickelement = "#Attributes.onDblClickElement#";
	</cfif>
	<cfif Attributes.onExecCommand neq "undefined">
eWebEditPro.parameters.onexeccommand = "#Attributes.onExecCommand#";
	</cfif>
	<cfif Attributes.onFocus neq "undefined">
eWebEditPro.parameters.onfocus = "#Attributes.onFocus#";
	</cfif>
	<cfif Attributes.onBlur neq "undefined">
eWebEditPro.parameters.onblur = "#Attributes.onBlur#";
	</cfif>

eWebEditPro.create("#Attributes.Name#", "#Attributes.Width#", "#Attributes.Height#");

eWebEditPro.parameters.reset();
//-->
</script>

</cfoutput>
