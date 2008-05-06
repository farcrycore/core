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
		
		<extjs:bubble title="Your permissions have been saved!">
			<cfoutput>You will need to updateApp for your changes to be implemented.</cfoutput>
		</extjs:bubble>
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
			var permissiontypecolor = { 
				'-1':'#application.url.webtop#/css/forms/images/f-btn-red.gif',  
				'0':'#application.url.webtop#/css/forms/images/f-btn-blue.gif',
				'1':'#application.url.webtop#/css/forms/images/f-btn-green.gif'
			}
		</script>
		<style>
			table.permissions { width: 100%; }
			table.permissions, tr.permissions, td.permissions { background: transparent none;border:0px solid ##e3e3e3; border-bottom: 1px dotted ##e3e3e3; vertical-align:middle;}
			td.permissions { padding: 3px;  }
		</style>
		
		<h3>Manage Permissions</h3>
	</cfoutput>

	<ft:form>

		<extjs:layout id="roleAccordion" container="Panel" layout="accordion" width="400" height="550" renderTo="roleAccordion" autoScroll="false">
			
			<cfloop list="#application.security.factory.role.getAllRoles()#" index="role">

				<extjs:item  title="#application.security.factory.role.getLabel(role)#" autoScroll="false">
					<cfoutput>
						<table class="permissions">
					</cfoutput>
					
					<cfloop list="#permissions#" index="permission">
						<cfset right = application.security.factory.barnacle.getRight(role=role,permission=permission,object=stObj.objectid,forcerefresh=true) />
						<cfif stObj.typename neq "dmNavigation" and right eq 0>
							<cfset right = -1 />
						</cfif>
						
						<cfoutput>
							<tr class="permissions">
								<td class="permissions">#application.security.factory.permission.getLabel(permission)#</td>
								<td class="permissions">
									<cfset hiddenID = "#replace(role,'-','','ALL')#_#replace(permission,'-','','ALL')#" />
									<cfset btnID = "btn-#role#_#permission#" />
									<cfswitch expression="#right#">
										<cfcase value="1"><cfset btnColor="green" /></cfcase>
										<cfcase value="-1"><cfset btnColor="red" /></cfcase>
										<cfdefaultcase><cfset btnColor="blue" /></cfdefaultcase>
									</cfswitch>
									<input type="hidden" name="#role#_#permission#" id="#hiddenID#" value="#right#" />
									<ft:button type="button" id="#btnID#" color="#btnColor#" value="#permissiontypes[right]#" size="small" width="200px" 
onclick="Ext.get('#btnID#').dom.value=nextpermissiontype[Ext.get('#btnID#').dom.value];Ext.get('#btnID#').dom.innerHTML=Ext.get('#btnID#').dom.value;Ext.get('#hiddenID#').dom.value=permissiontypevalue[Ext.get('#btnID#').dom.value];Ext.select('###btnID#-tbl-wrap .f-btn-bg').applyStyles('background-image:url(' + permissiontypecolor[Ext.get('#hiddenID#').dom.value] + ')');" />
									<!--- <input type="button" value="#permissiontypes[right]#" onclick="this.value=nextpermissiontype[this.value];document.getElementById('#replace(role,'-','','ALL')#_#replace(permission,'-','','ALL')#').value=permissiontypevalue[this.value];" /> --->
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
		
		<ft:farcryButtonPanel indentForLabel="false">
			<ft:button value="Save" color="orange" size="large" width="380px" />
		</ft:farcryButtonPanel>
	</ft:form>
</sec:CheckPermission>

<cfsetting enablecfoutputonly="false" />