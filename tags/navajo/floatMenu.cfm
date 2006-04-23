<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/floatMenu.cfm,v 1.15 2003/05/29 03:42:13 paul Exp $
$Author: paul $
$Date: 2003/05/29 03:42:13 $
$Name: b131 $
$Revision: 1.15 $

|| DESCRIPTION || 
$Description: FarCry DHTML Float Menu$
$TODO: $

|| DEVELOPER ||
$Developer: Stephen 'Spike' Milligan (spike@spike.org.uk)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfimport taglib="/farcry/farcry_core/tags/farcry/" prefix="farcry">

<!--- Design Mode --->
<cfset aItems = arrayNew(1)>
<cfset aItems[arrayLen(aItems)+1] = structNew()>
<cfset aItems[arrayLen(aItems)].icon = "design.gif">
<!--- check current design mode state --->
<cfif isDefined("request.mode.design") and (request.mode.design eq "1")>
	<cfset aItems[arrayLen(aItems)].href = "#application.url.conjurer#?objectID=#url.ObjectID#&designmode=0">
	<cfset aItems[arrayLen(aItems)].text = "Hide design">
<cfelse>
	<cfset aItems[arrayLen(aItems)].href = "#application.url.conjurer#?objectID=#url.ObjectID#&designmode=1">
	<cfset aItems[arrayLen(aItems)].text = "Show design">
</cfif>

<!--- Show latest mode --->
<cfset aItems[arrayLen(aItems)+1] = structNew()>
<cfset aItems[arrayLen(aItems)].icon = "cache.gif">
<!--- check current cache state --->
<cfif isDefined("request.mode.flushcache") AND request.mode.flushcache eq 0>
	<cfset aItems[arrayLen(aItems)].href = "#application.url.conjurer#?objectID=#url.ObjectID#&flushcache=1">
	<cfset aItems[arrayLen(aItems)].text = "Show latest">
<cfelse>
	<cfset aItems[arrayLen(aItems)].href = "#application.url.conjurer#?objectID=#url.ObjectID#&flushcache=0">
	<cfset aItems[arrayLen(aItems)].text = "Show cached">
</cfif>

<!--- Show Draft mode --->
<cfset aItems[arrayLen(aItems)+1] = structNew()>
<cfset aItems[arrayLen(aItems)].icon = "draft.gif">
<!--- check current state of draft mode --->
<cfif isDefined("request.mode.showdraft") AND request.mode.showdraft eq 0>
	<cfset aItems[arrayLen(aItems)].href = "#application.url.conjurer#?objectID=#url.ObjectID#&flushcache=1&showdraft=1">
	<cfset aItems[arrayLen(aItems)].text = "Show draft">
<cfelse>
	<cfset aItems[arrayLen(aItems)].href = "#application.url.conjurer#?objectID=#url.ObjectID#&flushcache=0&showdraft=0">
	<cfset aItems[arrayLen(aItems)].text = "Hide draft">
</cfif>

<cfset aItems[arrayLen(aItems)+1] = structNew()>
<cfset aItems[arrayLen(aItems)].text = "Admin Page">
<cfset aItems[arrayLen(aItems)].href = "#application.url.farcry#/index.cfm">
<cfset aItems[arrayLen(aItems)].icon = "admin.gif">
<cfset aItems[arrayLen(aItems)].target = "_blank">

<cfset aItems[arrayLen(aItems)+1] = structNew()>
<cfset aItems[arrayLen(aItems)].text = "Edit Page">
<cfset aItems[arrayLen(aItems)].href = "#application.url.farcry#/index.cfm?section=site&rootobjectid=#request.navid#">
<cfset aItems[arrayLen(aItems)].icon = "edit.gif">
<cfset aItems[arrayLen(aItems)].target = "_blank">


<cfset aItems[arrayLen(aItems)+1] = structNew()>
<cfset aItems[arrayLen(aItems)].text = "Logout">
<cfset aItems[arrayLen(aItems)].href = "#application.url.conjurer#?objectID=#url.ObjectID#&logout=1">
<cfset aItems[arrayLen(aItems)].icon = "logout.gif">

<cfscript>
	oAuth = request.dmsec.oAuthorisation;
	isDeveloper = oAuth.checkPermission(permissionname="developer",reference="policygroup");
	if (isDeveloper EQ 1)
	{
		 aItems[arrayLen(aItems)+1] = structNew();
		 aItems[arrayLen(aItems)].text = "Refresh App Scope";
		 aItems[arrayLen(aItems)].href = "#application.url.conjurer#?objectID=#url.ObjectID#&updateapp=1";
	}	 

		
</cfscript>


<!--- show menu --->
<farcry:floater imagedir="#application.url.farcry#/images/floater/" aItems="#aItems#" prefix="dmfloat" useContextMenu="true">

<cfsetting enablecfoutputonly="No">