
<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>


<cfparam name="attributes.permissionName">
<cfparam name="attributes.reference" default="">
<cfparam name="attributes.objectID" default="#attributes.reference#">
<cfparam name="attributes.lPolicyGroupIDs" default="">
		


<cfif thistag.ExecutionMode EQ "Start">
	
	<cfset permitted = 0>
	
	<cfloop list="#attributes.PermissionName#" index="i">
		<cfif application.security.checkPermission(permission=i,object=attributes.objectid) EQ 1>
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





