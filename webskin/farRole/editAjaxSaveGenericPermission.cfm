<cfparam name="form.permissionID" default="">
<cfparam name="form.barnaclevalue" default="">

<cfif len(form.permissionID) AND len(form.barnaclevalue)>
	
	<cfif form.barnaclevalue EQ -1>
		<cfset aNewPermissions = application.fapi.arrayRemove(stobj.aPermissions, form.permissionID)>
		
		<cfset application.fapi.setData(typename="farRole",
								objectid="#stobj.objectid#",
								aPermissions="#aNewPermissions#",
								bSessionOnly="true")>
		
	<cfelse>
		<cfif NOT application.fapi.arrayFind(stobj.aPermissions, form.permissionID)>
			<cfset arrayAppend(stobj.aPermissions, form.permissionID)>
			
			<cfset application.fapi.setData(typename="farRole",
									objectid="#stobj.objectid#",
									aPermissions="#stobj.aPermissions#",
									bSessionOnly="true")>
		</cfif>	
	</cfif>

	<cfcontent 	
		reset="true"
		type="application/json"
		variable="#toBinary( toBase64( serializeJSON( application.fapi.success('permission set to #form.barnaclevalue#') ) ) )#"
		/>
	
<cfelse>

	<cfcontent 	
		reset="true"
		type="application/json"
		variable="#toBinary( toBase64( serializeJSON( application.fapi.fail('permission not set to #form.barnaclevalue#') ) ) )#"
		/>
		
</cfif>