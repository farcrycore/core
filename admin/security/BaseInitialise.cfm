<Cfset stPolicyGroup = structNew()>
<cfset stPolicyGroup.policygroupname="SysAdmin">

<cftry>
<cf_dmSec_PolicyGroup action="create" stPolicyGroup="#stPolicyGroup#">
<cfcatch type="Any">
</cfcatch>
</cftry>

<cf_dmSec_PermissionBarnacleCreate
	PermissionName="Admin"
	PermissionType="PolicyGroup"
	PolicyGroupName="SysAdmin"
	state="1"
	Reference1="PolicyGroup">
	
<cf_dmSec_PermissionBarnacleCreate
	PermissionName="ModifyPermissions"
	PermissionType="PolicyGroup"
	PolicyGroupName="SysAdmin"
	state="1"
	Reference1="PolicyGroup">
	
<cf_dmSec_PermissionBarnacleCreate
	PermissionName="SecurityManagement"
	PermissionType="PolicyGroup"
	PolicyGroupName="SysAdmin"
	state="1"
	Reference1="PolicyGroup">

<cf_dmSec_ObjectPermissionCacheUpdate reference1="PolicyGroup">