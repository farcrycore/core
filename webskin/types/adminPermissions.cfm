<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
<cfimport taglib="/farcry/core/tags/extjs/" prefix="ext" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />

<cfset permissiontypes = structnew() />
<cfset permissiontypes["-1"] = application.rb.getResource("forms.labels.deny","Deny") />
<cfset permissiontypes["0"] = application.rb.getResource("forms.labels.inherit","Inherit") />
<cfset permissiontypes["1"] = application.rb.getResource("forms.labels.grant","Grant") />

<sec:restricted permission="ModifyPermissions">
	<ft:processform action="Save">
		<cfloop list="#form.fieldnames#" index="field">
			<cfset role = listfirst(field,"_") />
			<cfset permission = listlast(field,"_") />
			
			<cfif isvalid("uuid",role) and isvalid("uuid",permission)>
				<cfset application.security.factory.barnacle.updateRight(role=role,permission=permission,object=stObj.objectid,right=form[field]) />
			</cfif>
		</cfloop>
	</ft:processForm>

	<cfset permissions = application.security.factory.permission.getAllPermissions(stObj.typename) />

	<cfoutput>
		<script type="text/javascript">
			var permissiontypevalue = { 
				'#application.rb.getResource("forms.labels.deny","Deny")#':-1,  
				'#application.rb.getResource("forms.labels.inherit","Inherit")#':0,  
				'#application.rb.getResource("forms.labels.grant","Grant")#':1
			}
			
			var nextpermissiontype = { 
				'#application.rb.getResource("forms.labels.deny","Deny")#':'#application.rb.getResource("forms.labels.inherit","Inherit")#',  
				'#application.rb.getResource("forms.labels.inherit","Inherit")#':'#application.rb.getResource("forms.labels.grant","Grant")#',  
				'#application.rb.getResource("forms.labels.grant","Grant")#':'#application.rb.getResource("forms.labels.deny","Deny")#'
			}
		</script>
		<style>
			table { width: 100%; }
			table, tr, td { background: transparent none; border: 0px none transparent; }
			td { padding: 3px; font-size: larger; }
		</style>
		
		<h3>Manage Permissions</h3>
	</cfoutput>

	<ft:form>
		<ext:accordion>
			<cfloop list="#application.security.factory.role.getAllRoles()#" index="role">
				<ext:accordionPanel title="#application.security.factory.role.getLabel(role)#">
					<cfoutput>
						<table>
					</cfoutput>
					
					<cfloop list="#permissions#" index="permission">
						<cfset right = application.security.factory.barnacle.getRight(role=role,permission=permission,object=stObj.objectid) />
						
						<cfoutput>
							<tr>
								<td>#application.security.factory.permission.getLabel(permission)#</td>
								<td>
									<input type="hidden" name="#role#_#permission#" id="#replace(role,'-','','ALL')#_#replace(permission,'-','','ALL')#" value="#right#" />
									<input type="button" value="#permissiontypes[right]#" onclick="this.value=nextpermissiontype[this.value];document.getElementById('#replace(role,'-','','ALL')#_#replace(permission,'-','','ALL')#').value=permissiontypevalue[this.value];" />
								</td>
							</tr>
						</cfoutput>
					</cfloop>
					
					<cfoutput>
						</table>
					</cfoutput>
				</ext:accordionPanel>
			</cfloop>
		</ext:accordion>
		
		<ft:farcryButtonPanel>
			<ft:farcryButton value="Save" />
		</ft:farcryButtonPanel>
	</ft:form>
</sec:restricted>

<cfsetting enablecfoutputonly="false" />