
<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>


<cfparam name="attributes.permissionName">
<cfparam name="attributes.reference" default="policyGroup">
<cfparam name="attributes.objectID" default="">
<cfparam name="attributes.lPolicyGroupIDs" default="">
		


<cfif thistag.ExecutionMode EQ "Start">

	<cfif not len(attributes.lPolicyGroupIDs)>
		<cfset stLoggedInUser = request.dmsec.oAuthentication.getUserAuthenticationData() />
		<cfif stLoggedInUser.bLoggedIn>
			<cfset attributes.lPolicyGroupIds = stLoggedInUser.lPolicyGroupIDs />
		<cfelse>
			<cfset attributes.lPolicyGroupIds = application.dmsec.ldefaultpolicygroups />
		</cfif>
	</cfif>
	
	<cfset permitted = 0>
	
	<cfloop list="#attributes.PermissionName#" index="i">
		<cfif request.dmsec.oAuthorisation.checkInheritedPermission(permissionName="#i#",reference="#attributes.reference#", objectid="#attributes.objectid#", lPolicyGroupIds="#attributes.lPolicyGroupIds#") EQ 1>
			<cfset permitted = 1>
		</cfif>
	</cfloop>	

	<cfif permitted NEQ "1">
		<cfexit>
	</cfif>
</cfif>

<cfif thistag.ExecutionMode EQ "End">
	
	<!--- Do nothing. --->

</cfif>





