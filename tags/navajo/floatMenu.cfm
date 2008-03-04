<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/navajo/floatMenu.cfm,v 1.19 2005/08/28 00:19:41 geoff Exp $
$Author: geoff $
$Date: 2005/08/28 00:19:41 $
$Name: milestone_3-0-1 $
$Revision: 1.19 $

|| DESCRIPTION || 
$Description: FarCry DHTML Float Menu$

|| DEVELOPER ||
$Developer: Stephen 'Spike' Milligan (spike@spike.org.uk)$
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry">

<!--- Design Mode --->
<cfset aItems = arrayNew(1)>
<cfset aItems[arrayLen(aItems)+1] = structNew()>
<cfset aItems[arrayLen(aItems)].icon = "design.gif">
<!--- check current design mode state --->
<cfif isDefined("request.mode.design") and (request.mode.design eq "1")>
	<cfset aItems[arrayLen(aItems)].href = "#application.url.conjurer#?objectID=#url.ObjectID#&designmode=0">
	<cfset aItems[arrayLen(aItems)].text = "#apapplication.rb.getResource("hidedesign")#">
<cfelse>
	<cfset aItems[arrayLen(aItems)].href = "#application.url.conjurer#?objectID=#url.ObjectID#&designmode=1">
	<cfset aItems[arrayLen(aItems)].text = "#apapplication.rb.getResource("showdesign")#">
</cfif>

<!--- Show latest mode --->
<cfset aItems[arrayLen(aItems)+1] = structNew()>
<cfset aItems[arrayLen(aItems)].icon = "cache.gif">
<!--- check current cache state --->
<cfif isDefined("request.mode.flushcache") AND request.mode.flushcache eq 0>
	<cfset aItems[arrayLen(aItems)].href = "#application.url.conjurer#?objectID=#url.ObjectID#&flushcache=1">
	<cfset aItems[arrayLen(aItems)].text = "#apapplication.rb.getResource("showlatest")#">
<cfelse>
	<cfset aItems[arrayLen(aItems)].href = "#application.url.conjurer#?objectID=#url.ObjectID#&flushcache=0">
	<cfset aItems[arrayLen(aItems)].text = "#apapplication.rb.getResource("showcached")#">
</cfif>

<!--- Show Draft mode --->
<cfset aItems[arrayLen(aItems)+1] = structNew()>
<cfset aItems[arrayLen(aItems)].icon = "draft.gif">
<!--- check current state of draft mode --->
<cfif isDefined("request.mode.showdraft") AND request.mode.showdraft eq 0>
	<cfset aItems[arrayLen(aItems)].href = "#application.url.conjurer#?objectID=#url.ObjectID#&flushcache=1&showdraft=1">
	<cfset aItems[arrayLen(aItems)].text = "#apapplication.rb.getResource("showDraft")#">
<cfelse>
	<cfset aItems[arrayLen(aItems)].href = "#application.url.conjurer#?objectID=#url.ObjectID#&flushcache=0&showdraft=0">
	<cfset aItems[arrayLen(aItems)].text = "#apapplication.rb.getResource("hideDraft")#">
</cfif>

<cfset aItems[arrayLen(aItems)+1] = structNew()>
<cfset aItems[arrayLen(aItems)].text = "#apapplication.rb.getResource("adminPage")#">
<cfset aItems[arrayLen(aItems)].href = "#application.url.farcry#/index.cfm">
<cfset aItems[arrayLen(aItems)].icon = "admin.gif">
<cfset aItems[arrayLen(aItems)].target = "farcry_webtop">


<cfset aItems[arrayLen(aItems)+1] = structNew()>
<cfif structKeyExists(request, "stobj") and isDefined("application.stcoapi.#request.stobj.typename#.bUseInTree") AND application.stCoapi[request.stobj.typename].bUseInTree>
	<cfset aItems[arrayLen(aItems)].text = "#apapplication.rb.getResource("editPage")#">
	<cfset aItems[arrayLen(aItems)].target = "farcry_webtop">
	<cfset aItems[arrayLen(aItems)].href = "#application.url.farcry#/index.cfm?sec=site&rootobjectid=#request.navid#">
<cfelse>
	<cfset aItems[arrayLen(aItems)].text = "Edit Content">
	<cfset aItems[arrayLen(aItems)].target = "farcry_webtop_overview">
	<cfset aItems[arrayLen(aItems)].href = "#application.url.farcry#/edittabOverview.cfm?objectid=#request.stobj.objectid#&ref=overview&typename=#request.stobj.typename#">
</cfif>
<cfset aItems[arrayLen(aItems)].icon = "edit.gif">
<cfset aItems[arrayLen(aItems)].target = "farcry_webtop">

<cfset aItems[arrayLen(aItems)+1] = structNew()>
<cfset aItems[arrayLen(aItems)].text = "#apapplication.rb.getResource("logout")#">
<cfset aItems[arrayLen(aItems)].href = "#application.url.conjurer#?objectID=#url.ObjectID#&logout=1">
<cfset aItems[arrayLen(aItems)].icon = "logout.gif">

<cfscript>
	isDeveloper = application.security.checkPermission(permission="developer");
	if (isDeveloper EQ 1)
	{
		 aItems[arrayLen(aItems)+1] = structNew();
		 aItems[arrayLen(aItems)].text = "#apapplication.rb.getResource("refreshAppScope")#";
		 aItems[arrayLen(aItems)].href = "#application.url.conjurer#?objectID=#url.ObjectID#&updateapp=1";
	}	 
</cfscript>

<!--- This include allows advance developers to manipulate the aItems array before rendering the floater menu. --->
<cfif fileexists("#application.path.project#/system/floatMenu/_customItems.cfm")>
	<cfinclude template="/farcry/projects/#application.projectDirectoryName#/system/floatMenu/_customItems.cfm">
</cfif>
<!--- show menu --->
<farcry:floater imagedir="#application.url.farcry#/images/floater/" aItems="#aItems#" prefix="dmfloat" useContextMenu="true">

<cfsetting enablecfoutputonly="No">