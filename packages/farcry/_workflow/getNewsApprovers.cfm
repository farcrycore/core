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
$Header: /cvs/farcry/core/packages/farcry/_workflow/getNewsApprovers.cfm,v 1.8 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: gets users who can approve news $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfset stApprovers = structNew()>

<!--- get list of policy groups with News Approve access --->
<cfquery name="qGetPolicyGroups" datasource="#application.dsn#">
SELECT b.PolicyGroupID FROM #application.dbowner#dmPermission a, #application.dbowner#dmPermissionBarnacle b
WHERE a.PermissionName = 'NewsApprove'
AND a.PermissionID = b.PermissionID
AND b.Status = 1
ORDER BY b.PolicyGroupID ASC
</cfquery>

<!--- put query results into list --->
<cfset lApprovePGs = "">
<cfloop query="qGetPolicyGroups">
    <cfif not listFindNoCase(lApprovePGs, qGetPolicyGroups.PolicyGroupID)>
        <cfset lApprovePGs = listAppend(lApprovePGs, qGetPolicyGroups.PolicyGroupID)>
    </cfif>
</cfloop>


<cfscript>
	aUsers = application.factory.oAuthorisation.getPolicyGroupUsers(lPolicyGroupIDs=lApprovePGs);
</cfscript>


<!--- loop over users --->
<cfloop index="i" from="1" to="#arrayLen(aUsers)#">
    <cfscript>
    o_profile = createObject("component", application.types.dmProfile.typePath);
    stProfile = o_profile.getProfile(aUsers[i]);
	if (not structIsEmpty(stProfile) AND stProfile.bActive) stApprovers[aUsers[i]] = stProfile;
    </cfscript>
</cfloop>
