<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

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
	oAuthorisation = request.dmsec.oAuthorisation;
	aUsers = oAuthorisation.getPolicyGroupUsers(lPolicyGroupIDs=lApprovePGs);
</cfscript>


<!--- loop over users --->
<cfloop index="i" from="1" to="#arrayLen(aUsers)#">
    <cfscript>
    o_profile = createObject("component", application.types.dmProfile.typePath);
    stProfile = o_profile.getProfile(aUsers[i]);
	if (not structIsEmpty(stProfile) AND stProfile.bActive) stApprovers[aUsers[i]] = stProfile;
    </cfscript>
</cfloop>
