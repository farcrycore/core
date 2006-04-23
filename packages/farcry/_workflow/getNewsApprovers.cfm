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
    o_profile = createObject("component", "#application.packagepath#.types.dmProfile");
    stProfile = o_profile.getProfile(aUsers[i]);
	if (not structIsEmpty(stProfile) AND stProfile.bActive) stApprovers[aUsers[i]] = stProfile;
    </cfscript>
</cfloop>
