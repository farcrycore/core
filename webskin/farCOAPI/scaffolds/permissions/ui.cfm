<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />

<cfset permissionscreated = "" />
<cfloop list="#application.security.factory.permission.getAllPermissions()#" index="permission">
	<cfif findnocase(url.scaffoldtypename,application.security.factory.permission.getLabel(permission))>
		<cfset permissionscreated = listappend(permissionscreated,application.security.factory.permission.getLabel(permission)) />
	</cfif>
</cfloop>
<cfset permissionspossible = "#url.scaffoldtypename#Approve,#url.scaffoldtypename#CanApproveOwnContent,#url.scaffoldtypename#Create,#url.scaffoldtypename#Delete,#url.scaffoldtypename#Edit,#url.scaffoldtypename#RequestApproval" />

<cfoutput>
	<p>Generates the set of generic permissions for your type. For convenience, it also simplifies the process of associating them with roles. Note: if you wish to set up item specific permissions, you will need to do it through the standard security interface.</p>
	<br/>
	<table width="100%">
		<tr><th>Create Permissions</th><th>Manage Permissions</th></tr>
		<tr>
			<td>
				<table>
					<cfloop list="#permissionspossible#" index="permission">
						<tr>
							<td align="right">
								<cfif listcontains(permissionscreated,permission)>
									<label for="generate#permission#"><strong>(#mid(permission,len(url.scaffoldtypename)+1,1)#)</strong></label>
								<cfelse>
									<input type="checkbox" value="true" name="generatePermission#permission#" id="generate#permission#" value="true" />
								</cfif>
							</td>
							<td><label for="generate#permission#">#mid(permission,len(url.scaffoldtypename)+1,len(permission))#</label></td>
						</tr>
					</cfloop>
				</table>
			</td>
			<cfif listlen(permissionscreated)>
				<td>
					<table>
						<tr>
							<td></td>
							<cfloop list="#permissionspossible#" index="permission">
								<cfif listcontains(permissionscreated,permission)>
									<th>#mid(permission,len(url.scaffoldtypename)+1,2)#</th>
								</cfif>
							</cfloop>
						</tr>
						<cfloop list="#application.security.factory.role.getAllRoles()#" index="role">
							<tr>
								<th>#application.security.factory.role.getLabel(role)#</th>
								<cfloop list="#permissionscreated#" index="permission">
									<cfif listcontains(permissionscreated,permission)>
										<td>
											<input type="checkbox" name="#role#_#application.security.factory.permission.getID(permission)#" value="true"<cfif application.security.checkPermission(role=role,permission=permission)> checked</cfif> />
										</td>
									</cfif>
								</cfloop>
							</tr>
						</cfloop>
					</table>
				</td>
			</cfif>
		</tr>
	</table>
</cfoutput>

<cfsetting enablecfoutputonly="false" />