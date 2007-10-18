
<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>

<cfparam name="attributes.PermissionName" default="">
<cfparam name="attributes.UserName" default="">


<cfif thistag.ExecutionMode EQ "Start">

	<cfset permitted = 0>
	
	<cfloop list="#attributes.PermissionName#" index="i">
		<cfif request.dmsec.oAuthorisation.checkPermission(permissionName="#i#",reference="policyGroup") EQ 1>
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





