<cfprocessingDirective pageencoding="utf-8">

<Cfset stPolicyGroup = structNew()>
<cfset stPolicyGroup.policygroupname="SysAdmin">

<cfscript>
	oAuthorisation = request.dmsec.oAuthorisation;
</cfscript>
<cftry>
<cfscript>
	oAutorisation.createPolicyGroup(policyGroupName=stPolicyGroup.policygroupname);
</cfscript>
<cfcatch type="Any">
</cfcatch>
</cftry>

<cfscript>
	oAuthorisation.createPermissionBarnacle(PermissionName="Admin",	PermissionType="PolicyGroup",PolicyGroupName="SysAdmin",status="1",	Reference="PolicyGroup");
	oAuthorisation.createPermissionBarnacle(PermissionName="SecurityManagement",PermissionType="PolicyGroup",PolicyGroupName="SysAdmin",status="1",	Reference="PolicyGroup");
	oAuthorisation.createPermissionBarnacle(PermissionName="ModifyPermissions",PermissionType="PolicyGroup",PolicyGroupName="SysAdmin",status="1",	Reference="PolicyGroup");
	oAuthorisation.updateObjectPermissionCache(reference="policyGroup");
</cfscript>

