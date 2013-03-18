<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<cfset permissiontypes = structnew() />
<cfset permissiontypes["-1"] = application.rb.getResource("security.constants.deny@label","Deny") />
<cfset permissiontypes["0"] = application.rb.getResource("security.constants.inherit@label","Inherit") />
<cfset permissiontypes["1"] = application.rb.getResource("security.constants.grant@label","Grant") />

<sec:CheckPermission error="true" permission="ModifyPermissions">

	<ft:processform action="Save,Change Role">
		<cfloop list="#form.fieldnames#" index="field">
			<cfset role = listfirst(field,"_") />
			<cfset permission = listlast(field,"_") />
			
			<cfif isvalid("uuid",role) and isvalid("uuid",permission)>
				<cfset application.security.factory.barnacle.updateRight(role=role,permission=permission,object=stObj.objectid,right=form[field]) />
			</cfif>
		</cfloop>
	</ft:processForm>

	<ft:processForm action="Save" url="refresh">
		<cfset application.security.initCache() />
		<skin:bubble title="Your permissions have been saved!" tags="security,update,info" />
	</ft:processForm>
	
	<ft:processForm action="Change Role">
		<skin:location url="#application.fapi.fixURL(addValues='role=#form.selectRole#')#" />
	</ft:processForm>
	
	<cfset permissions = application.security.factory.permission.getAllPermissions(stObj.typename) />

	<admin:header>
	
	<skin:htmlHead><cfoutput>
		<script type="text/javascript">
			var permissiontypevalue = { 
				'#application.rb.getResource("security.constants.deny@label","Deny")#':-1,  
				<cfif stObj.typename eq "dmNavigation">'#application.rb.getResource("security.constants.inherit@label","Inherit")#':0,</cfif>
				'#application.rb.getResource("security.constants.grant@label","Grant")#':1
			}
			<cfif stObj.typename eq "dmNavigation">
				var nextpermissiontype = { 
					'#application.rb.getResource("security.constants.deny@label","Deny")#':'#application.rb.getResource("security.constants.inherit@label","Inherit")#',
					'#application.rb.getResource("security.constants.inherit@label","Inherit")#':'#application.rb.getResource("security.constants.grant@label","Grant")#',  
					'#application.rb.getResource("security.constants.grant@label","Grant")#':'#application.rb.getResource("security.constants.deny@label","Deny")#'
				}
			<cfelse>
				var nextpermissiontype = { 
					'#application.rb.getResource("security.constants.deny@label","Deny")#':'#application.rb.getResource("security.constants.grant@label","Grant")#',  
					'#application.rb.getResource("security.constants.grant@label","Grant")#':'#application.rb.getResource("security.constants.deny@label","Deny")#'
				}
			</cfif>  
			var permissiontypecolor = { 
				'-1':'#application.url.webtop#/css/forms/images/f-btn-red.gif',  
				'0':'#application.url.webtop#/css/forms/images/f-btn-blue.gif',
				'1':'#application.url.webtop#/css/forms/images/f-btn-green.gif'
			}
			
			function changePermission(id, hiddenid,aHash){
				$j("##" + id).val(nextpermissiontype[$j("##" + id).val()]);
				$j("##" + hiddenid).val(permissiontypevalue[$j("##" + id).val()]);
				$j("##" + id).html("<span class='ui-button-text'>" + aHash[$j("##" + id).val()] + "</span>");
				<!--- $j('##' + id + '-tbl-wrap .f-btn-bg').css({'background-image:url(' + permissiontypecolor[$j("##" + hiddenid).val()] + ')'}); --->
			}
		</script>
		<style>
			table.permissions {}
			table.permissions, tr.permissions, td.permissions { background: transparent none;border:0px solid ##e3e3e3; border-bottom: 1px dotted ##e3e3e3; vertical-align:middle;}
			td.permissions { padding: 3px;  }
		</style>
	</cfoutput></skin:htmlHead>

	<ft:form bUniFormHighlight="false">
		
		<cfset lRoles = application.security.factory.role.getAllRoles() />

		<cfif listLen(lRoles)>
			
			<cfparam name="url.role" default="#listFirst(lRoles)#" />	

			<cfoutput>
				<h3>Manage Permissions for
				<select id="selectRole" name="selectRole">
					<cfloop list="#lRoles#" index="i">
						<option value="#i#"  <cfif i EQ url.role>selected="selected"</cfif>>#application.security.factory.role.getLabel(i)#</option>
					</cfloop>
				</select>
				</h3>
			</cfoutput>		
	
			<skin:onReady>
				<cfoutput>
				$j('##selectRole').change(function(){
				    btnSubmit('#request.farcryForm.name#','Change Role');
				 });
				</cfoutput>
			</skin:onReady>
			
			
			<cfoutput>
			<table class="permissions">
			</cfoutput>
			
			<cfloop list="#permissions#" index="permission">
				<cfset right = application.security.factory.barnacle.getRight(role=url.role,permission=permission,object=stObj.objectid) />
				<cfset inheritedRight = application.security.factory.barnacle.getInheritedRight(role=url.role,permission=permission,object=stObj.objectid) />
				<cfif stObj.typename neq "dmNavigation" and right eq 0>
					<cfset right = -1 />
				</cfif>
				
				<cfoutput>
					<tr class="permissions">
						<td class="permissions">#application.security.factory.permission.getLabel(permission)#</td>
						<td class="permissions">
							
							
							
							<cfset hiddenID = "#replace(url.role,'-','','ALL')#_#replace(permission,'-','','ALL')#" />
							<cfset btnID = "btn-#url.role#_#permission#" />
							<cfset btnIDHash = hash(btnID) />
							<cfswitch expression="#right#">
								<cfcase value="1">
									<cfset btnColor="green" />
								</cfcase>
								<cfcase value="-1">
									<cfset btnColor="red" />
								</cfcase>
								<cfdefaultcase>
									<cfset btnColor="blue" />
								</cfdefaultcase>
							</cfswitch>
							<cfswitch expression="#inheritedRight#">
								<cfcase value="1">
									<cfset inheritedRightText="grant" />
								</cfcase>
								<cfdefaultcase>
									<cfset inheritedRightText="deny" />
								</cfdefaultcase>
							</cfswitch>

							<script type="text/javascript">
							<cfif stObj.typename eq "dmNavigation">
								var btnHash#btnIDHash# = { 
									'#application.rb.getResource("security.constants.deny@label","Deny")#':'#application.rb.getResource("security.constants.deny@label","Deny")#',
									'#application.rb.getResource("security.constants.inherit@label","Inherit")#':'#application.rb.getResource("security.constants.inherit@label","Inherit")# (#application.rb.getResource("security.constants.#inheritedRightText#@label",inheritedRightText)#)',
									'#application.rb.getResource("security.constants.grant@label","Grant")#':'#application.rb.getResource("security.constants.grant@label","Grant")#'
								}
							<cfelse>
								var btnHash#btnIDHash# = { 
									'#application.rb.getResource("security.constants.deny@label","Deny")#':'#application.rb.getResource("security.constants.deny@label","Deny")#',  
									'#application.rb.getResource("security.constants.grant@label","Grant")#':'#application.rb.getResource("security.constants.grant@label","Grant")#'
								}
							</cfif> 
							</script>										
							<cfset buttonText = "#permissiontypes[right]#" />
							<cfif right EQ 0>
								<cfset buttonText = "#buttonText# (#inheritedRightText#)" />
							</cfif>
							<input type="hidden" name="#url.role#_#permission#" id="#hiddenID#" value="#right#" />
							<ft:button type="button" id="#btnID#" color="#btnColor#" value="#permissiontypes[right]#" text="#buttonText#" size="small" width="200px" onclick="changePermission('#btnID#', '#hiddenID#', btnHash#btnIDHash#)" />

						</td>
					</tr>
				</cfoutput>
			</cfloop>
			
			<cfoutput>
				</table>
			</cfoutput>
		</cfif>
		
		<ft:buttonPanel indentForLabel="false">
			<cfoutput><skin:buildLink objectid="#stObj.objectid#" view="adminTestPermissions">Test Permissions</skin:buildLink>&nbsp;&nbsp;</cfoutput>
			<ft:button value="Save" color="orange" size="large" width="380px" />
		</ft:buttonPanel>
	</ft:form>
</sec:CheckPermission>

<cfsetting enablecfoutputonly="false" />