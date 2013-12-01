<!--- Create requested permissions --->
<cfset permissionscreated = "" />
<cfloop list="#application.security.factory.permission.getAllPermissions()#" index="permission">
	<cfif findnocase(url.scaffoldtypename,application.security.factory.permission.getLabel(permission))>
		<cfset permissionscreated = listappend(permissionscreated,application.security.factory.permission.getLabel(permission)) />
	</cfif>
</cfloop>
<cfset permissionspossible = "#url.scaffoldtypename#Approve,#url.scaffoldtypename#CanApproveOwnContent,#url.scaffoldtypename#Create,#url.scaffoldtypename#Delete,#url.scaffoldtypename#Edit,#url.scaffoldtypename#RequestApproval" />

<cfloop list="#permissionspossible#" index="permission">
	<cfif structkeyexists(form,"generatePermission#permission#") and form["generatePermission#permission#"]>
		<cfset stPermission = structnew() />
		<cfset stPermission.objectid = application.fc.utils.createJavaUUID() />
		<cfset stPermission.title = "#mid(permission,len(url.scaffoldtypename)+1,len(permission))# #application.stCOAPI[url.scaffoldtypename].displayname#" />
		<cfset stPermission.shortcut = permission />
		<cfset application.security.factory.permission.createData(stProperties=stPermission) />
		
		<cfoutput>
			<p class="success">Created "#mid(permission,len(url.scaffoldtypename)+1,len(permission))#" permission</p>
		</cfoutput>
	</cfif>
</cfloop>

<!--- Assign permissions to roles --->
<cfloop list="#application.security.factory.role.getAllRoles()#" index="role">
	<cfoutput>
		<p class="success">Updated "#application.security.factory.role.getLabel(role)#" role with permission set
	</cfoutput>
	<cfloop list="#permissionscreated#" index="permission">
		<cfif structkeyexists(form,"#role#_#application.security.factory.permission.getID(permission)#")>
			<cfset application.security.factory.role.updatePermission(role=role,permission=permission,has=true) />
			<cfoutput>#mid(permission,len(url.scaffoldtypename)+1,1)#</cfoutput>
		<cfelse>
			<cfset application.security.factory.role.updatePermission(role=role,permission=permission,has=false) />
			<cfoutput>-</cfoutput>
		</cfif>
	</cfloop>
	<cfoutput>
		</p>
	</cfoutput>
</cfloop>