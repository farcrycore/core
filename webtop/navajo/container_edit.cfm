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
$Header: /cvs/farcry/core/webtop/navajo/container_edit.cfm,v 1.2 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Edit widget for containers $


|| DEVELOPER ||
$Developer: Guy Phanvongsa (guy@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="true">
<cfparam name="containerid" default="">
<cfparam name="reflectionid" default="">
<cfparam name="section" default="container_rules">
<cfparam name="displayContainerTitle" default="Unknown">

<!--- TODO: shift this baby out so can be used by other pages --->
<cffunction name="IsCFUUID" displayname="checks if the string is a valid coldfusion uuid">
	<cfargument name="str" required="true">
	<cfreturn REFindNoCase("^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$", str)>
</cffunction>

<!--- create rules|container objects --->
<cfset oRules = createObject("component","#application.packagepath#.rules.rules")>
<cfset oCon = createObject("component","#application.packagepath#.rules.container")>

<cfif section EQ "container_rules"> <!--- delete the current rule id in the session as we are out of the rules management section --->
	<cfset StructDelete(session,"ruleid")>
	<cfset StructDelete(session,"ruleTypeName")>
<cfelseif section EQ "container_contents">
	<cfif StructKeyExists(form,"ruleID")>
		<cfset session.ruleid = ruleid>
		<cfset session.ruleTypeName = oCon.findType(objectid=ruleid)>
	</cfif>
</cfif>

<!--- get object data --->
<cfif containerID EQ ""> <!--- containerid not passed in .: create reflection --->
	<cfset stProps = StructNew()>
	<cfset stProps.objectid = CreateUUID()>
	<cfset stProps.bShared = 1>
	<cfset stProps.label = "(Incomplete)">
	<cfset oCon.CreateData(stProperties=stProps)>
	<cfset containerID = stProps.objectid>
</cfif>

<cfset stObj = oCon.getData(objectid=containerID)>
<cfif NOT StructIsEmpty(stObj)>
	<cfset displayContainerTitle = stobj.label>
<cfelse>
	<cfset errormessage = errormessage & "Invalid Container ID: [#containerID#]">
</cfif>
	
<cfparam name="reflectionid" default="#stObj.mirrorid#">
<cfif reflectionid NEQ ""> <!--- contianer has a reflection .: show reflection editform --->
	<cfset section = "container_reflections">
<cfelseif ArrayLen(stObj.aRules) EQ 0 AND section EQ "container_contents"> <!--- container has no rules so go to configure rule page --->
	<cfset section = "container_rules">
</cfif>

<cfset query_string = "containerid=#containerid#">

<cfsetting enablecfoutputonly="false">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>FarCry: Container Rules</title>
<cfoutput>
	<style type="text/css" title="default" media="screen">@import url(#application.url.farcry#/css/main.css);</style>
	<style type="text/css" title="default" media="screen">@import url(#application.url.farcry#/css/tabs.css);</style>
	<script type="text/javascript" src="#application.url.farcry#/js/fade.js"></script>
	<script type="text/javascript" src="#application.url.farcry#/js/formutilities.js"></script>
</cfoutput>
</head>
<body class="popup container-management">
<h1><cfoutput>#displayContainerTitle#</cfoutput></h1>
<div class="tab-container">
	<ul class="tabs"><cfoutput>
	<li id="tab1"<cfif section NEQ "container_rules"> class="tab-disabled"</cfif>><a href="<cfif section EQ 'container_rules'>##<cfelse>#cgi.script_name#?#query_string#&section=container_rules</cfif>">Configure Rules</a></li>
	<li id="tab2"<cfif section NEQ "container_contents"> class="tab-disabled"</cfif>><a href="<cfif section EQ 'container_contents'>##<cfelse>#cgi.script_name#?#query_string#&section=container_contents</cfif>">Container Content</a></li></cfoutput>
	</ul>
	<div class="tab-panes">
	<cfinclude template="#section#.cfm">
	<!--- Rule hint will be dynamically populated here --->
	<p id="rulehint" class="highlight"></p>
	</div>
</div>
</body>
</html>