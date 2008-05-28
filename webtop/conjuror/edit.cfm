<cfsetting enablecfoutputonly="yes">
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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/conjuror/edit.cfm,v 1.1 2005/06/11 07:55:24 geoff Exp $
$Author: geoff $
$Date: 2005/06/11 07:55:24 $
$Name: milestone_3-0-1 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: $
$TODO: This legacy code needs to be revisited 
-- should have a more generic object invocation methodology GB$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: url.Objectid$
$out:$
--->

<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />

<cfprocessingDirective pageencoding="utf-8" />

<cfinclude template="/farcry/core/webtop/includes/utilityFunctions.cfm" />
<cfinclude template="/farcry/core/webtop/includes/cfFunctionWrappers.cfm" />

<!--- Legacy support for old pages referring to URL.type--->
<cfif isDefined("URL.type") AND NOT isDefined("URL.typename")>
	<cfset URL.typename = URL.type />
</cfif>

<!--- enforce some validation --->
<cfparam name="url.objectid" type="uuid" />
<cfparam name="url.typename" default="" type="string" />

<!--- Legacy support for old pages referring to URL.type --->
<cfif structkeyexists(URL,"type")>
	<cfset URL.typename = URL.type />
</cfif>

<!--- auto-type lookup if required --->
<cfif not len(url.typename)>
	<cfset q4 = createObject("component", "farcry.core.packages.fourq.fourq") />
	<cfset url.typename = q4.findType(objectid=url.objectid) />
	
	<!--- its possible that missing objects will kill this so we only want to create object if we actually get a typename result --->
	<cfif not len(url.typename)>
		<cfabort />
	</cfif>
</cfif>

<!--- set up page header --->
<admin:header />

<!--- First check permissions --->
<sec:CheckPermission permission="Edit" type="#url.typename#" objectid="#url.objectid#" error="true" errormessage="You do not have permission to edit this item">

	<!--- work out package epath --->
	<cfset oType = createObject("component", application.types[url.typename].typePath) />
	<cfset stObj = oType.getData(objectid=url.objectid,dsn=application.dsn) />
	
	<!--- delete underlying draft --->
	<cfif structkeyexists(URL,"deleteDraftObjectID")>
		<!--- Delete the copied draft object containers --->
		<cfset oCon = createObject('component','#application.packagepath#.rules.container') />
		<cfset oCon.delete(objectid="#URL.deleteDraftObjectID#") />
		
		<!--- Delete the copied draft object --->
		<cfset oType.deletedata(objectId="#URL.deleteDraftObjectID#") />
		
		<!--- Log this activity against live object --->
		<farcry:logevent object="#url.objectid#" type="coapi" event="delete" notes="Deleted Draft Object (#stObj.label#)" />
		
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
	
	<!--- See if we can edit this object --->
	<cfset oVersioning = createObject("component","#application.packagepath#.farcry.versioning") />
	<cfset oLocking = createObject("component","#application.packagepath#.farcry.locking") />
	
	<cfif structKeyExists(stObj,"versionID") AND structKeyExists(stObj,"status")>
		<cfset stRules = oVersioning.getVersioningRules(objectid=url.objectid) />
		<cfset oVersioning.checkEdit(stRules=stRules,stObj=stObj) />
	</cfif>
	
	
	<cfif structCount(stObj)>
		<cfset checkForLockRet=oLocking.checkForLock(objectid=url.objectid) />
		<cfif checkForLockRet.bSuccess>
			<cfset lockRet = oLocking.lock(objectid=url.objectid,typename=url.typename) />
			<cfif lockRet.bSuccess>
				<cfset oType.edit(objectid=url.objectid) />
			<cfelse>
				<cfdump var="#packagepath#" />
			</cfif>
		<cfelseif not checkForLockRet.bSuccess and checkForLockRet.lockedBy eq "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#">
			<cfset oType.edit(objectid=url.objectid) />
		<cfelse>
			<cfoutput>#checkForLockRet.message#</cfoutput>
		</cfif>
	</cfif>

</sec:CheckPermission>
	  
<admin:footer />

<cfsetting enablecfoutputonly="No">