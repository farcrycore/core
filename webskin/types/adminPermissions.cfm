<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />

<cfset permissiontypes = structnew() />
<cfset permissiontypes["-1"] = application.rb.getResource("forms.labels.deny","Deny") />
<cfset permissiontypes["0"] = application.rb.getResource("forms.labels.inherit","Inherit") />
<cfset permissiontypes["1"] = application.rb.getResource("forms.labels.grant","Grant") />

<sec:CheckPermission error="true" permission="ModifyPermissions">
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
				<cfif stObj.typename eq "dmNavigation">'#application.rb.getResource("forms.labels.inherit","Inherit")#':0,</cfif>
				'#application.rb.getResource("forms.labels.grant","Grant")#':1
			}
			<cfif stObj.typename eq "dmNavigation">
				var nextpermissiontype = { 
					'#application.rb.getResource("forms.labels.deny","Deny")#':'#application.rb.getResource("forms.labels.inherit","Inherit")#',
					'#application.rb.getResource("forms.labels.inherit","Inherit")#':'#application.rb.getResource("forms.labels.grant","Grant")#',  
					'#application.rb.getResource("forms.labels.grant","Grant")#':'#application.rb.getResource("forms.labels.deny","Deny")#'
				}
			<cfelse>
				var nextpermissiontype = { 
					'#application.rb.getResource("forms.labels.inherit","Deny")#':'#application.rb.getResource("forms.labels.grant","Grant")#',  
					'#application.rb.getResource("forms.labels.grant","Grant")#':'#application.rb.getResource("forms.labels.deny","Deny")#'
				}
			</cfif>  
		</script>
		<style>
			table { width: 100%; }
			table, tr, td { background: transparent none;border:0px solid ##e3e3e3; border-bottom: 1px dotted ##e3e3e3; }
			td { padding: 3px;  }
		</style>
		
		<h3>Manage Permissions</h3>
	</cfoutput>

	<ft:form>
	
		<extjs:layout id="roleAccordion" container="Panel" layout="accordion" width="400" height="500" renderTo="roleAccordion" autoScroll="true">
			
			<cfloop list="#application.security.factory.role.getAllRoles()#" index="role">

				<extjs:item  title="#application.security.factory.role.getLabel(role)#" autoScroll="true">
					<cfoutput>
						<table>
					</cfoutput>
					
					<cfloop list="#permissions#" index="permission">
						<cfset right = application.security.factory.barnacle.getRight(role=role,permission=permission,object=stObj.objectid) />
						<cfif stObj.typename neq "dmNavigation" and right eq 0>
							<cfset right = -1 />
						</cfif>
						
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
				</extjs:item>
			</cfloop>
			
		</extjs:layout>
		
		<ft:farcryButtonPanel>
			<ft:farcryButton value="Save" />
		</ft:farcryButtonPanel>
	</ft:form>
</sec:CheckPermission>

<cfsetting enablecfoutputonly="false" />