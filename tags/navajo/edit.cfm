<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/edit.cfm,v 1.14 2003/07/15 07:32:10 paul Exp $
$Author: paul $
$Date: 2003/07/15 07:32:10 $
$Name: b131 $
$Revision: 1.14 $

|| DESCRIPTION || 
$Description: $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: url.Objectid$
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<!--- First check permissions --->
<cfscript>
	bHasPermission = request.dmsec.oAuthorisation.checkInheritedPermission(permissionName='edit',objectid=URL.objectid);
</cfscript>
<cfif NOT bHasPermission GTE 0>
	<h1>You do not have permission to edit this object</h1>
	<cfabort>
</cfif>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">

<!--- delete underlying draft --->
<cfif isDefined("URL.deleteDraftObjectID")>
	<!--- delete instance --->
	<cf_deleteObjects typename="dmHTML" lObjectIDs="#URL.deleteDraftObjectID#">
	<!--- get parent for update tree --->
	<cf_getNavigation objectId="#url.ObjectId#" bInclusive="1" r_stObject="stNav" r_ObjectId="navIdSrcPerm">
	<!--- update tree --->
	<cf_updateTree objectId="#navIdSrcPerm#" complete=0>
	<!--- reload overview page --->
	<cfoutput>
		<script language="JavaScript">
			parent['editFrame'].location.href = '#application.url.farcry#/edittabOverview.cfm?objectid=#url.ObjectID#';
		</script>
	</cfoutput>
</cfif>

<!--- work out package epath --->
<cfif application.types['#url.type#'].bCustomType>
	<cfset packagepath = application.custompackagepath>
<cfelse>
	<cfset packagepath = application.packagepath>
</cfif>

<!--- get details --->
<q4:contentobjectget typename="#packagepath#.types.#url.type#" objectid="#url.objectID#" r_stobject="stObj">

<!--- See if we can edit this object --->
<cfif structKeyExists(stObj,"versionID") AND structKeyExists(stObj,"status")>
	<cfinvoke component="#packagepath#.farcry.versioning" method="getVersioningRules" objectID="#url.objectID#" returnvariable="stRules">

	<cfinvoke component="#packagepath#.farcry.versioning" method="checkEdit" stRules="#stRules#" stObj="#stObj#">
</cfif>

<cfif structCount(stObj)>
	<!--- check if object locked --->
	
	<cfinvoke component="#application.packagepath#.farcry.locking" method="checkForLock" returnvariable="checkForLockRet">
		<cfinvokeargument name="objectId" value="#url.objectID#"/>
	</cfinvoke>
			
	<cfif checkForLockRet.bSuccess>
		<!--- available for edit so lock object --->
		<cfinvoke component="#application.packagepath#.farcry.locking" method="lock" returnvariable="lockRet">
			<cfinvokeargument name="objectId" value="#url.objectID#"/>
			<cfinvokeargument name="typename" value="#url.type#"/>
		</cfinvoke>
			
		<cfif lockRet.bSuccess>
			<!--- now edit --->
			<q4:contentobject typename="#packagepath#.types.#url.type#" method="edit" objectID="#url.objectID#">
		<cfelse>
			<!--- throw error --->
			<cfdump var="#packagepath#"><cfabort>
			<cfdump var="#lockRet#"><cfabort>
		</cfif>
	<cfelseif not checkForLockRet.bSuccess and checkForLockRet.lockedBy eq "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#">
		<!--- locked by current user so available for edit, no need to lock again --->	

		<q4:contentobject typename="#packagepath#.types.#url.type#" method="edit" objectID="#url.objectID#">

	<cfelse>
		<!--- object is locked, throw error message --->
		<cfoutput>#checkForLockRet.message#</cfoutput>
		<cfabort>
	</cfif>
	
<cfelse>
	<cfoutput><script>window.close();</script></cfoutput>
</cfif>	  
	  
<admin:footer>

<cfsetting enablecfoutputonly="No">