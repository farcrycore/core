

<cfparam name="form.referenceid" default="">
<cfparam name="form.permissionID" default="">
<cfparam name="form.objecttype" default="">
<cfparam name="form.barnaclevalue" default="">

<cfif len(form.referenceid) AND  len(form.permissionID) AND  len(form.objecttype) AND  len(form.barnaclevalue)>
	
	<cfif isWDDX(stobj.typePermissions)>
		<cfwddx action="wddx2cfml" input="#stobj.typePermissions#" output="stTypePermissions" />
	<cfelse>
		<cfset stTypePermissions = structNew() />
	</cfif>
	
	<cfparam name="stTypePermissions['#form.permissionID#']" default="#structNew()#">
	
	<cfset stTypePermissions['#form.permissionID#']['#form.referenceid#'] = form.barnaclevalue>
	
	
	
	<cfwddx action="cfml2wddx" input="#stTypePermissions#" output="wddxTypePermissions" />
	<cfset application.fapi.setData(typename="farRole",
									objectid="#stobj.objectid#",
									typePermissions="#wddxTypePermissions#",
									bSessionOnly="true")>

	<cfcontent 	
		reset="true"
		type="application/json"
		variable="#toBinary( toBase64( serializeJSON( application.fapi.success('#session.CFToken# - permission set to #form.barnaclevalue#') ) ) )#"
		/>
	
<cfelse>

	<cfcontent 	
		reset="true"
		type="application/json"
		variable="#toBinary( toBase64( serializeJSON( application.fapi.fail('permission not set to #form.barnaclevalue#') ) ) )#"
		/>
		
</cfif>

<!--- 
<cfif len(form.referenceid) AND  len(form.permissionID) AND  len(form.objecttype) AND  len(form.barnaclevalue)>
	<cfparam name="session.fc.stRolePermissions" default="#structNew()#">
	<cfparam name="session.fc.stRolePermissions['#stobj.objectid#']" default="#structNew()#">
	<cfparam name="session.fc.stRolePermissions['#stobj.objectid#']['#form.objecttype#']" default="#structNew()#">
	<cfparam name="session.fc.stRolePermissions['#stobj.objectid#']['#form.objecttype#']['#form.permissionID#']" default="#structNew()#">
	
	<cfset session.fc.stRolePermissions[stobj.objectid][form.objecttype][form.permissionID][form.referenceid] = form.barnaclevalue />
	
	<cfcontent 	
		reset="true"
		type="application/json"
		variable="#toBinary( toBase64( serializeJSON( application.fapi.success('permission set') ) ) )#"
		/>
	
<cfelse>

	<cfcontent 	
		reset="true"
		type="application/json"
		variable="#toBinary( toBase64( serializeJSON( application.fapi.fail('permission not set') ) ) )#"
		/>
		
</cfif> --->