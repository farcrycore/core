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
$Header: /cvs/farcry/core/packages/farcry/_workflow/getObjectApprovers.cfm,v 1.18 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.18 $

|| DESCRIPTION || 
$DESCRIPTION: Gets a list of approvers for a navigatio node$
 

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in:$ 
$out:$
--->

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">

<cfset lApprovePGs = "">

<!--- check if object is an underlying draft object --->
<q4:contentobjectget objectID="#arguments.objectID#" r_stobject="stObj">

<cfif isdefined("stObj.versionID") and len(stObj.versionID)>
	<cfset objectTest = stObj.versionID>
<cfelse>
	<cfset objectTest = arguments.objectID>
</cfif>

		
<!--- get navigation parent for permission checks --->
<nj:treeGetRelations 
	typename="#stObj.typename#"
	objectId="#objectTest#"
	get="parents"
	r_lObjectIds="ParentID"
	bInclusive="1">

<!--- Get the roles that have permission to approve objects --->
<cfset approverroles = "" />
<cfloop list="#application.security.factory.role.getAllRoles()#" index="thisrole">
	<cfif application.security.checkPermission(role=thisrole,permission="Approve",object=stObj.objectid)>
		<cfset approverroles = listappend(approverroles,thisrole) />
	</cfif>
</cfloop>
<cfset aUsers = application.security.getGroupUsers(groups=application.security.factory.role.rolesToGroups(roles=approverroles)) />

<!--- build struct of dmProfile objects for each user --->
<cfset stApprovers = structNew()>

<cfloop index="i" from="1" to="#arrayLen(aUsers)#">
    <cfscript>
    o_profile = createObject("component", application.types.dmProfile.typePath);
    stProfile = o_profile.getProfile(aUsers[i]);
	if (not structIsEmpty(stProfile) AND stProfile.bActive) stApprovers[aUsers[i]] = stProfile;
    </cfscript>
</cfloop>
