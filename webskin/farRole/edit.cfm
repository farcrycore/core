
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/wizard/" prefix="wiz" />
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />


<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<!--- @@description:
IMPORTANT: 
This is a bit of a mish-mash of a edit webskin. It uses both wizard and session object to manage different parts of the role.
Permissions are managed by a session object whereas all other fields are managed by the wizard.
 --->



<cfset setLock(stObj=stObj,locked=true) />




<!-------------------------------- 
PREPARE SITE PERMISSIONS
--------------------------------->
<cfif isWDDX(stobj.sitePermissions)>
	<cfwddx action="wddx2cfml" input="#stobj.sitePermissions#" output="request.stSitePermissions" />
<cfelse>
	<cfset request.stSitePermissions = structNew() />
</cfif>

<cfif structKeyExists(form, "sitePermissionsSubmitted")>
	<cfloop collection="#form#" item="iField">
		<cfif left(iField,14) EQ "barnacleValue-">
			<cfset request.stSitePermissions['#form.permissionID#'][ right(iField, 35) ] = form[iField] />
		</cfif>
	</cfloop>
	
	<cfwddx action="cfml2wddx" input="#request.stSitePermissions#" output="wddxSitePermissions" />
	<cfset application.fapi.setData(typename="farRole",
									objectid="#stobj.objectid#",
									sitePermissions="#wddxSitePermissions#", 
									bSessionOnly="true")>
</cfif>





<!-------------------------------- 
PREPARE WEBTOP PERMISSIONS
--------------------------------->
<cfif isWDDX(stobj.webtopPermissions)>
	<cfwddx action="wddx2cfml" input="#stobj.webtopPermissions#" output="request.stWebtopPermissions" />
<cfelse>
	<cfset request.stWebtopPermissions = structNew() />
</cfif>

<cfif structKeyExists(form, "webtopPermissionsSubmitted")>
	<cfloop collection="#form#" item="iField">
		<cfif left(iField,14) EQ "barnacleValue-">
			<cfset request.stWebtopPermissions['#form.permissionID#'][ mid(iField,15, len(iField)-14) ] = form[iField] />
		</cfif>
	</cfloop>
	
	<cfwddx action="cfml2wddx" input="#request.stWebtopPermissions#" output="wddxWebtopPermissions" />
	<cfset application.fapi.setData(typename="farRole",
									objectid="#stobj.objectid#",
									webtopPermissions="#wddxWebtopPermissions#", 
									bSessionOnly="true")>
</cfif>



<!-------------------------------- 
PREPARE TYPE PERMISSIONS
--------------------------------->

<cfset request.lTypePermissions = application.security.factory.permission.getAllPermissions('farCoapi') />


<cfif isWDDX(stobj.typePermissions)>
	<cfwddx action="wddx2cfml" input="#stobj.typePermissions#" output="request.stTypePermissions" />
<cfelse>
	<cfparam name="request.stTypePermissions" default="#structNew()#" />
	

	<cfquery datasource="#application.dsn#" name="qBarnacles">
	SELECT *
	FROM farBarnacle
	WHERE objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="farCoapi">
	AND roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stobj.objectid#">
	AND permissionID IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#request.lTypePermissions#">)
	</cfquery>
	
	<cfloop query="qBarnacles">
		<cfparam name="request.stTypePermissions['#qBarnacles.permissionID#']" default="#structNew()#" />
		<cfset request.stTypePermissions['#qBarnacles.permissionID#']['#qBarnacles.referenceID#'] = qBarnacles.barnaclevalue >
	</cfloop>
	
	
	<cfwddx action="cfml2wddx" input="#request.stTypePermissions#" output="wddxTypePermissions" />
	<cfset application.fapi.setData(typename="farRole",
									objectid="#stobj.objectid#",
									typePermissions="#wddxTypePermissions#", 
									bSessionOnly="true")>
									
</cfif>



<!--- Always save wizard WDDX data --->
<wiz:processwizard excludeAction="Cancel">

	<!--- Save the Primary wizard Object --->
	<wiz:processwizardObjects typename="#stobj.typename#">
		
	</wiz:processwizardObjects>	
		
</wiz:processwizard>

<wiz:processwizard action="Save" Savewizard="true" Exit="true"><!--- Save wizard Data to Database and remove wizard --->
	
	
	<!--- Need to update the aPermissions field with the one from the session because it is the session object that we are managing permissions with. --->
	<cfset stwizard.data[stobj.objectid].aPermissions = stobj.aPermissions />
	


	<cfset oBarnacle = application.fapi.getContentType("farBarnacle") />
	
	
	<!-------------------------------- 
	SAVE SITE PERMISSIONS TO DB 
	--------------------------------->	
	
	<cfloop list="#structKeyList(request.stSitePermissions)#" index="iPermission">
		<cfquery datasource="#application.dsn#" name="qPermissionBarnacles">
		SELECT *
		FROM farBarnacle
		WHERE objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="dmNavigation">
		AND farBarnacle.roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stobj.objectid#">
		AND farBarnacle.permissionid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#iPermission#">
		</cfquery>
		
		<cfloop collection="#request.stSitePermissions['#iPermission#']#" item="iReferenceID">
			<cfquery dbtype="query" name="qBarnacleExists">
			SELECT *
			FROM qPermissionBarnacles
			WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#iReferenceID#">
			</cfquery>
			
			<cfset newBarnacleValue = request.stSitePermissions[iPermission][iReferenceID] />
			
			<cfif qBarnacleExists.recordCount>
				<cfif newBarnacleValue EQ 0>
					<cfset oBarnacle.delete(qBarnacleExists.objectid)>
				<cfelse>
					<cfif qBarnacleExists.barnaclevalue NEQ newBarnacleValue>
						<cfset application.fapi.setData(typename="farBarnacle", objectID="#qBarnacleExists.objectid#", referenceID="#iReferenceID#", objecttype="#qBarnacleExists.objecttype#", barnaclevalue="#newBarnacleValue#") />
					</cfif>
				</cfif>
				
			<cfelse>
				<cfif newBarnacleValue NEQ 0>
					<cfset application.fapi.setData(
						typename="farBarnacle", 
						objectID="#application.fapi.getUUID()#", 
						roleid="#stobj.objectid#",
						permissionID="#iPermission#",
						referenceid="#iReferenceID#",
						objecttype="dmNavigation",
						barnaclevalue="#newBarnacleValue#"
						) />
				</cfif>
			</cfif>
		</cfloop>
	</cfloop>
	
	
	
	<!--- 
	SAVE WEBTOP PERMISSIONS TO DB
	 --->
	
	
	<cfloop list="#structKeyList(request.stWebtopPermissions)#" index="iPermission">
		<cfquery datasource="#application.dsn#" name="qPermissionBarnacles">
		SELECT *
		FROM farBarnacle
		WHERE objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="webtop">
		AND farBarnacle.roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stobj.objectid#">
		AND farBarnacle.permissionid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#iPermission#">
		</cfquery>
		
		<cfloop collection="#request.stWebtopPermissions['#iPermission#']#" item="iReferenceID">
			
			<cfquery dbtype="query" name="qBarnacleExists">
			SELECT *
			FROM qPermissionBarnacles
			WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#iReferenceID#">
			</cfquery>
			
			<cfset newBarnacleValue = request.stWebtopPermissions[iPermission][iReferenceID] />
			
			<cfif qBarnacleExists.recordCount>
				<cfif newBarnacleValue EQ 0>
					<cfset oBarnacle.delete(qBarnacleExists.objectid)>
				<cfelse>
					<cfif qBarnacleExists.barnaclevalue NEQ newBarnacleValue>
						<cfset stResult =  application.fapi.setData(typename="farBarnacle", objectID="#qBarnacleExists.objectid#", referenceID="#iReferenceID#", objecttype="#qBarnacleExists.objecttype#", barnaclevalue="#newBarnacleValue#") />
					</cfif>
				</cfif>
				
			<cfelse>
				<cfif newBarnacleValue NEQ 0>
					<cfset stResult = application.fapi.setData(
						typename="farBarnacle", 
						objectID="#application.fapi.getUUID()#", 
						roleid="#stobj.objectid#",
						permissionID="#iPermission#",
						referenceid="#iReferenceID#",
						objecttype="webtop",
						barnaclevalue="#newBarnacleValue#"
						) />
				</cfif>
			</cfif>
		</cfloop>
	</cfloop>
	
	
	
	<!--- 
	SAVE TYPE PERMISSIONS TO DB
	 --->
	
	
	<cfloop list="#structKeyList(request.stTypePermissions)#" index="iPermission">
		<cfquery datasource="#application.dsn#" name="qPermissionBarnacles">
		SELECT *
		FROM farBarnacle
		WHERE objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="farCoapi">
		AND farBarnacle.roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stobj.objectid#">
		AND farBarnacle.permissionid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#iPermission#">
		</cfquery>
		
		<cfloop collection="#request.stTypePermissions['#iPermission#']#" item="iReferenceID">
			<cfquery dbtype="query" name="qBarnacleExists">
			SELECT *
			FROM qPermissionBarnacles
			WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#iReferenceID#">
			</cfquery>
			
			<cfset newBarnacleValue = request.stTypePermissions[iPermission][iReferenceID] />
			
			<cfif qBarnacleExists.recordCount>
				<cfif newBarnacleValue EQ 0>
					<cfset oBarnacle.delete(qBarnacleExists.objectid)>
				<cfelse>
					<cfif qBarnacleExists.barnaclevalue NEQ newBarnacleValue>
						<cfset application.fapi.setData(typename="farBarnacle", objectID="#qBarnacleExists.objectid#", referenceID="#iReferenceID#", objecttype="#qBarnacleExists.objecttype#", barnaclevalue="#newBarnacleValue#") />
					</cfif>
				</cfif>
				
			<cfelse>
				<cfif newBarnacleValue NEQ 0>
					<cfset stResult = application.fapi.setData(
						typename="farBarnacle", 
						objectID="#application.fapi.getUUID()#", 
						roleid="#stobj.objectid#",
						permissionID="#iPermission#",
						referenceid="#iReferenceID#",
						objecttype="farCoapi",
						barnaclevalue="#newBarnacleValue#"
						) />
				</cfif>
			</cfif>
		</cfloop>
	</cfloop>
	
	
	<cfset structDelete(Session.TempObjectStore, stobj.objectid)>
</wiz:processwizard>
<wiz:processwizard action="Cancel" Removewizard="true" Exit="true" ><!--- remove wizard --->
	<cfset structDelete(Session.TempObjectStore, stobj.objectid)>
</wiz:processwizard>


<skin:htmlHead>
<cfoutput>
<style type="text/css">
.inherit {opacity:0.4;}

.ui-button.small.barnacleBox {
	width: 50px;
	height: 16px;
	float:right;
	margin:0px 0px 0px 5px;
}

.ui-button.small.barnacleBox .ui-icon {
	margin-top: -8px;
	margin-left: -8px;
}

##permissionTree li {
	font-size:10px;
}

.permButton.ui-button {
	padding:0px 0px 5px 0px;	
	width: 50px;
	height: 16px;
	float:right;
}
</style>
</cfoutput>
</skin:htmlHead>



<wiz:wizard ReferenceID="#stobj.objectid#">


					
		<wiz:step name="General">
			
			<wiz:object typename="#stobj.typename#" ObjectID="#stobj.objectID#" lfields="title,isdefault,aGroups" format="edit" intable="false" />
			
		</wiz:step>

					
		<wiz:step name="Site Permissions">
			
			<skin:view typename="farRole" objectid="#stobj.objectid#" webskin="editSitePermissions" />
			
		</wiz:step>

					
		<wiz:step name="Webtop Visibility">
			
			<skin:view typename="farRole" objectid="#stobj.objectid#" webskin="editWebtopPermissions" />
			
		</wiz:step>

					
		<wiz:step name="Content Type Security">
			
			<skin:view typename="farRole" objectid="#stobj.objectid#" webskin="editTypePermissions" />
			
		</wiz:step>
	
		<wiz:step name="General Permissions">
			
			
			<cfquery datasource="#application.dsn#" name="qPermissions">
			SELECT *
			FROM farPermission
			WHERE bSystem <> 1
			ORDER BY title
			</cfquery>
			
			<cfoutput>
			<table class="objectAdmin" style="table-layout:fixed;width:100%;">
			<colgroup>
				<col style="width:200px;">
				<col style="width:60px;">
				<col>
			</colgroup>
			<thead>
			<tr>
				<th>Permission</th>
				<th>Access</th>
				<th>Hint</th>
			</tr>
			</thead>
			
			<tbody>
			
			<cfloop query="qPermissions">

				<tr>
					<cfif application.fapi.arrayFind(stobj.aPermissions, qPermissions.objectid)>
						<cfset allowAccess = 1>
					<cfelse>
						<cfset allowAccess = -1>
					</cfif>
					
					<cfif allowAccess EQ 1>
						<cfset priority = "ui-priority-primary">
						<cfset icon = "ui-icon-check">
					<cfelse>
						<cfset priority = "ui-priority-secondary">
						<cfset icon = "ui-icon-close">
					</cfif>
					
					<cfoutput>
					<td>#qPermissions.shortcut#</td>
					<td>
						<button id="perm-#qPermissions.objectid#" class="permButton small barnacleBox #priority# #icon#" fticon="#icon#" value="#allowAccess#" type="button" ftpermissionid="#qPermissions.objectid#" ftbarnaclevalue="#numberformat(allowAccess)#"></button>
					</td>	
					<td>#qPermissions.hint#</td>
					</cfoutput>
					
				</tr>
			
			
				
			</cfloop>
			</tbody>
			</table>
			</cfoutput>
			<skin:onReady>
			<cfoutput>
				
			$j('.permButton').each(function (i) {
			
				
				$j(this).button({
			        text: false,
					icons: {
			            primary: $j(this).attr('fticon')
			        }
			     });
		   });

			$j('.permButton').click(function() {
				var el = $j(this);
				var permission = $j(this).attr('ftpermissionid');
				var permitted = $j(this).attr('ftbarnaclevalue');
				
					
					
					if(permitted == 1) {
						$j(this).attr('ftbarnaclevalue', '-1');
						$j(this).removeClass('ui-priority-primary').addClass('ui-priority-secondary');
						$j(this).find('.ui-icon').removeClass('ui-icon-check').addClass('ui-icon-close');
						
					} else {
						$j(this).attr('ftbarnaclevalue', '1');
						$j(this).removeClass('ui-priority-secondary').addClass('ui-priority-primary');
						$j(this).find('.ui-icon').removeClass('ui-icon-close').addClass('ui-icon-check');
					};
					
					var permitted = $j(this).attr('ftbarnaclevalue');
				   
				   
				   
				
					$j.ajax({
					   type: "POST",
					   url: '/index.cfm?ajaxmode=1&type=farRole&objectid=#stobj.objectid#&view=editAjaxSaveGenericPermission',
					   dataType: "html",
					   cache: false,
					   context: $j(this),
					   timeout: 15000,
					   data: {
							permissionid: $j(this).attr('ftpermissionid'),
							barnaclevalue: $j(this).attr('ftbarnaclevalue')
						},
					   success: function(msg){
					   		$j(this).find('.ui-icon').removeClass('ui-icon-bullet');
					   },
					   error: function(data){	
							alert('change unsuccessful. The page will be refreshed.');
							location=location;
						},
						complete: function(){
							
						}
					 });
						 
					 
			});</cfoutput>
			</skin:onReady>
			
			
			<!--- <wiz:object typename="#stobj.typename#" ObjectID="#stobj.objectID#" lfields="aPermissions" format="edit" intable="false" /> --->
			
		</wiz:step>

	
		<wiz:step name="Webskin">
		
			<wiz:object typename="#stobj.typename#" ObjectID="#stobj.objectID#" lfields="webskins" format="edit" intable="false" r_stPrefix="prefix" />
			
			
			<ft:buttonPanel>
				<ft:button value="Show Permissions Below" type="button" priority="secondary" class="small" style="float:left;" onClick="$fc.wizardSubmission( $j(this).closest('form').attr('id'),'Show Permissions');" />
			</ft:buttonPanel>
			
			<ft:processForm action="Show Permissions">
				<cfset roleWebskins = stwizard.data[stobj.objectid].webskins>
	
	<!--- 
				<cfoutput>
				<p><ft:button value="Refresh Webskin Permissions" onClick="$fc.refreshWebskinPermissions();" renderType="link" confirmText="Are you sure you want to " /></p>
				</cfoutput> --->
				<skin:onReady>
					<cfoutput>
					var accordion = $j("##webskin-permissions");
					accordion.accordion({
						autoHeight: false,
						collapsible:true,
						animated:false
					});
					</cfoutput>
				</skin:onReady>
	
				<grid:div id="webskin-permissions">
					<cfset lTypesAndRules = structKeyList(application.stCoapi) />
					
					<cfloop list="#lTypesAndRules#" index="i">
	
						<cfoutput><h3><a href="##">#i# (#application.stCoapi[i].displayName#)</a></h3></cfoutput>
						
						<grid:div id="wrap-#i#" style="">
						<cfset qWebskins = application.stCoapi[i].qWebskins>
						<cfloop query="qWebskins">
							<cfset bPermitted = false />		
							<cfloop list="#roleWebskins#" index="filter" delimiters="#chr(10)##chr(13)#,">
								<cfif (not find(".",filter) or listfirst(filter,".") eq "*" or listfirst(filter,".") eq i or reFindNoCase(replace(listFirst(filter,"."),"*",".*","ALL"),i)) 
										and reFindNoCase(replace(listlast(filter,"."),"*",".*","ALL"),application.stCoapi[i].qWebskins.name)>
									<cfset bPermitted = true />
								</cfif>
							
							</cfloop>
												
							<cfoutput>
							
								<cfif bPermitted EQ true>
									<span style="color:green;">#application.stCoapi[i].qWebskins.name#</span><br />
								<cfelse>
									<span style="color:red;">#application.stCoapi[i].qWebskins.name#</span><br />
								</cfif>
							
							</cfoutput>
						</cfloop>
						</grid:div>
					</cfloop>
				</grid:div>
			</ft:processForm>
		</wiz:step>



		
</wiz:wizard>	
