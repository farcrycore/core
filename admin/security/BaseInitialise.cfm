<cfscript>
oAuthorisation = createObject("component", "#application.securitypackagepath#.authorisation");
</cfscript>

<cftry>
    <cfscript>
    oAuthorisation.createPolicyGroup(policyGroupName=stPolicyGroup.policyGroupName);
    </cfscript>
<cfcatch type="Any"></cfcatch>
</cftry>

<cfscript>
oAuthorisation.createPermissionBarnacle(PermissionName="Admin",	PermissionType="PolicyGroup",PolicyGroupName="SysAdmin",status="1",	Reference="PolicyGroup");
oAuthorisation.createPermissionBarnacle(PermissionName="SecurityManagement",PermissionType="PolicyGroup",PolicyGroupName="SysAdmin",status="1",	Reference="PolicyGroup");
oAuthorisation.createPermissionBarnacle(PermissionName="ModifyPermissions",PermissionType="PolicyGroup",PolicyGroupName="SysAdmin",status="1",	Reference="PolicyGroup");
oAuthorisation.updateObjectPermissionCache(reference="policyGroup");
</cfscript>