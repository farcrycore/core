<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/navajo/container_index.cfm,v 1.13 2005/10/31 04:10:52 guy Exp $
$Author: guy $
$Date: 2005/10/31 04:10:52 $
$Name: milestone_3-0-1 $
$Revision: 1.13 $

|| DESCRIPTION || 
$Description: Edit widget for containers $


|| DEVELOPER ||
$Developer: Guy Phanvongsa (guy@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="true">
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">
<cfparam name="containerid" default="">
<cfparam name="section" default="">
<cfparam name="displayContainerTitle" default="Unknown">
<!--- <cfparam name="reflectionid" default=""> --->

<!--- TODO: shift this baby out so can be used by other pages --->
<cffunction name="IsCFUUID" displayname="checks if the string is a valid coldfusion uuid">
	<cfargument name="str" required="true">
	<cfreturn REFindNoCase("^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$", str)>
</cffunction>

<!--- create rules|container objects --->
<cfset oRules = createObject("component","#application.packagepath#.rules.rules")>
<cfset oCon = createObject("component","#application.packagepath#.rules.container")>


<cfset bDisplaySkins = false>
<cfif directoryExists("#application.path.project#/webskin/container")>
	<nj:listTemplates typename="container" prefix="" r_qMethods="qContainerSkins">
	<cfif qContainerSkins.recordCount>
		<cfset bDisplaySkins = true>
	</cfif>
</cfif>

<cfset stObj = oCon.getData(objectid=containerID)>
<cfif NOT StructIsEmpty(stObj)>
	<cfif Len(stobj.label) GT 36>
		<cfset displayContainerTitle = RemoveChars(stobj.label, 1, 36)>
	<cfelse>
		<cfset displayContainerTitle = ReplaceNoCase(stobj.label,"_"," ","all")>
	</cfif>
	<!--- <cfset reflectionid = stObj.mirrorid> --->
<cfelse>
	<cfset errormessage = errormessage & "Invalid Container ID: [#containerID#]">
</cfif>

<cfif stObj.mirrorid NEQ ""> <!--- contianer has a reflection .: show reflection editform --->
	<cfset section = "container_reflections">
<cfelseif ArrayLen(stObj.aRules) EQ 0>
	<cfset section = "container_rules">
</cfif>

<cfif not len(section)>
	<cfif ArrayLen(stObj.aRules) GT 0>
		<cfset section = "container_contents">
	<cfelse>
		<cfset section = "container_rules">
	</cfif>
</cfif>

<!---
<cfelseif ArrayLen(stObj.aRules) EQ 0 AND section EQ "container_contents"> <!--- container has no rules so go to configure rule page --->
	<cfset section = "container_rules">
<cfelseif ArrayLen(stObj.aRules) GT 0>
	<cfset section = "container_contents">
</cfif> --->

<cfif not len(section) or section EQ "container_rules"> <!--- delete the current rule id in the session as we are out of the rules management section --->
	<cfset StructDelete(session,"ruleid")>
	<cfset StructDelete(session,"ruleTypeName")>
<cfelseif section EQ "container_contents">
	<cfif StructKeyExists(form,"ruleID")>
		<cfset session.ruleid = ruleid>
		<cfset session.ruleTypeName = oCon.findType(objectid=ruleid)>
	<cfelseif NOT StructKeyExists(session,"ruleid")>
		<cfset session.ruleid = stObj.aRules[1]>
		<cfset session.ruleTypeName = oCon.findType(objectid=session.ruleid)>
	</cfif>
</cfif>

<cfparam name="reflectionid" default="#stObj.mirrorid#">

<!--- Make sure we include the prototype library --->
<cfset request.inHead.Prototype = 1 />

<cfset query_string = "containerid=#containerid#">
<cfsetting enablecfoutputonly="false">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>FarCry: Container Rules</title><cfoutput>
	<style type="text/css" title="default" media="screen">@import url(#application.url.farcry#/css/main.css);</style>
	<style type="text/css" title="default" media="screen">@import url(#application.url.farcry#/css/tabs.css);</style>
	<script type="text/javascript" src="#application.url.farcry#/js/fade.js"></script>
	<script type="text/javascript" src="#application.url.farcry#/js/formutilities.js"></script></cfoutput>
</head>
<body class="popup container-management">
<h1><cfoutput>#displayContainerTitle#</cfoutput></h1>
<div class="tab-container">
	<ul class="tabs"><cfoutput><cfif reflectionid EQ "">
	<li id="tab1"<cfif section NEQ "container_rules"> class="tab-disabled"</cfif>><a href="<cfif section EQ 'container_rules'>##<cfelse>#cgi.script_name#?#query_string#&section=container_rules</cfif>">Configure Rules</a></li>
	<li id="tab2"<cfif section NEQ "container_contents"> class="tab-disabled"</cfif>><a href="<cfif section EQ 'container_contents'>##<cfelse>#cgi.script_name#?#query_string#&section=container_contents</cfif>">Container Content</a></li></cfif>
	<li id="tab3"<cfif section NEQ "container_reflections"> class="tab-disabled"</cfif>><a href="<cfif section EQ 'container_reflections'>##<cfelse>#cgi.script_name#?#query_string#&section=container_reflections</cfif>">Reflections</a></li>
	<cfif bDisplaySkins>
	<li id="tab4"<cfif section NEQ "container_skins"> class="tab-disabled"</cfif>><a href="<cfif section EQ 'container_skins'>##<cfelse>#cgi.script_name#?#query_string#&section=container_skins</cfif>">Skin</a></li>
	</cfif>
	</cfoutput>
	</ul>
	<div class="tab-panes">
	<cfinclude template="#section#.cfm">
	<!--- Rule hint will be dynamically populated here --->
	<p id="rulehint" class="highlight"></p>
	</div>
</div>
</body>
</html>