
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />




<skin:loadJS id="fc-jquery" />
<skin:loadJS id="fc-jquery-ui" />
<skin:loadCSS id="jquery-ui" />
<skin:loadCSS id="fc-font-awesome" />


<skin:htmlHead>
<cfoutput>
<style type="text/css">
	##typeTree a.permission-explicit:hover, ##typeTree a.permission-inherit:hover { text-decoration:none; }
	##typeTree a.permission-explicit .fa-check-circle { color:##006600; }
	##typeTree a.permission-inherit .fa-check-circle { color:##8bd68b; }
	##typeTree a.permission-explicit .fa-times-circle { color:##FF0000; }
	##typeTree a.permission-inherit .fa-times-circle { color:##FF8080; }
	##typeTree .fa { font-size: 16px; padding:2px; }
</style>
</cfoutput>
</skin:htmlHead>


<cfset stTree = structNew() />

<cfset oCoapi = application.fapi.getContentType("farCoapi")>
<cfset stPermissionLabels = structNew()>
<cfloop list="#request.lTypePermissions#" index="iPermission">
	<cfset stPermissionLabels[iPermission] = replaceNoCase(application.security.factory.permission.getLabel(iPermission) , "generic", "", "all") />
</cfloop>

<cfoutput>

<table id="typeTree" class="objectAdmin" style="table-layout:fixed;width:95%;">
	<colgroup>
		<col style="width:100px;">
		<col style="width:100px;">
		<cfloop list="#request.lTypePermissions#" index="iPermission">
			<col style="width:28px;">
		</cfloop>
	</colgroup>
	<thead>
		<tr>
			<th>Content Type</th>
			<th>Display Name</th>
			<cfloop list="#request.lTypePermissions#" index="iPermission">
				<th class="nowrap" title="#stPermissionLabels[iPermission]#" style="font-size:9px;text-align:center;">#stPermissionLabels[iPermission]#</th>
			</cfloop>
		</tr>
	</thead>
	
	<tbody>
			
		<tr>
			<th colspan="2" style="text-align:center;"><b>***DEFAULT***</b></th>
			<cfloop list="#request.lTypePermissions#" index="iPermission">
				<cfif application.fapi.arrayFind(stobj.aPermissions, iPermission)>
					<cfset currentBarnacleValue = 1>
				<cfelse>
					<cfset currentBarnacleValue = -1 />
				</cfif>
				<cfif currentBarnacleValue EQ 1>
					<cfset priority = "ui-priority-primary">
					<cfset icon = "fa-check-circle">
				<cfelse>
					<cfset priority = "ui-priority-secondary">
					<cfset icon = "fa-times-circle">
				</cfif>
				
				<th title="#stPermissionLabels[iPermission]#" style="text-align:center;background-color:##ffffff;background-image:none;">
					<a id="generic#iPermission#" class="permButton genericPermission permission-explicit <cfif stobj.title EQ 'SysAdmin'>sysadmin</cfif>" value="#currentBarnacleValue#" ftpermissionid="#iPermission#" ftbarnaclevalue="#numberformat(currentBarnacleValue)#">
						<i class="fa #icon# fa-fw"></i>
					</a>
				</th>
				
			</cfloop>
		</tr>
		<cfset lTypes = structKeyList(application.types) />
		<cfset lTypes = ListSort( lTypes , 'textnocase')>
	
		<cfloop list="#lTypes#" index="iType">
			<cfset stCoapiType = oCoapi.getCoapiObject("#iType#") />
			<cfset stCoapiTypeMD = application.fapi.getContentTypeMetadata(iType)>
			<cfset barnacleID = stCoapiType.objectid>
	
			<cfif NOT structKeyExists(stCoapiTypeMD,"bsystem") OR stCoapiTypeMD.bSystem EQ 0>
				<tr>
					<td><b>#iType#</b></td>
					<td><b>#stCoapiTypeMD.displayName#</b></td>
					
					<cfloop list="#request.lTypePermissions#" index="iPermission">
						<cfif application.fapi.arrayFind(stobj.aPermissions, iPermission)>
							<cfset inheritbarnaclevalue = 1>
						<cfelse>
							<cfset inheritbarnaclevalue = -1 />
						</cfif>
						
						<cfif structKeyExists(request.stTypePermissions, iPermission) AND structKeyExists(request.stTypePermissions['#iPermission#'], barnacleID)>
							<cfset currentBarnacleValue = request.stTypePermissions['#iPermission#'][barnacleID]>
						<cfelse>
							<cfset currentBarnacleValue = 0 />
						</cfif>
						<cfif currentBarnacleValue EQ 1>
							<cfset icon = "fa-check-circle">
							<cfset class="permission-explicit" />
						<cfelseif currentBarnacleValue EQ -1>
							<cfset icon = "fa-check-circle">
							<cfset class="permission-explicit" />
						<cfelse>
							<cfset class="permission-inherit" />
							<cfif inheritbarnaclevalue EQ 1>
								<cfset icon = "fa-check-circle">
							<cfelse>
								<cfset icon = "fa-times-circle">
							</cfif>
							
						</cfif>
						
						<td title="#stPermissionLabels[iPermission]#" style="text-align:center;">
							<a id="#hash(stCoapiType.objectid)##iPermission#" class="permButton coapiPermission barnacleBox #iPermission# #class#" value="#currentBarnacleValue#" ftobjecttype="farCoapi" ftreferenceid="#barnacleID#" ftpermissionid="#iPermission#" ftbarnaclevalue="#numberformat(currentBarnacleValue)#" ftinheritbarnaclevalue="#numberformat(inheritbarnaclevalue)#">
								<i class="fa #icon# fa-fw"></i>
							</a>
						</td>
						
					</cfloop>
					
				</tr>
			</cfif>
		</cfloop>
		</tbody>
	</table>
</cfoutput>

<cfoutput><input type="hidden" name="typePermissionsSubmitted" value="true"></cfoutput>


<skin:onReady><cfoutput>
	$j('.genericPermission').click(function() {
		var el = $j(this);
		var permission = $j(this).attr('ftpermissionid');
		var permitted = $j(this).attr('ftbarnaclevalue');
		
		if (permitted == 1 && $j(this).hasClass('sysadmin')) {
		
			alert('You can not change the SysAdmin generic permissions. SysAdmin can do everything.')
		
		} else {
		
			if(permitted == 1) {
				$j(this).attr('ftbarnaclevalue', '-1');
				$j(this).find('.fa-check-circle').removeClass('fa-check-circle').addClass('fa-times-circle');
				
			} else {
				$j(this).attr('ftbarnaclevalue', '1');
				$j(this).find('.fa-times-circle').removeClass('fa-times-circle').addClass('fa-check-circle');
			};
			
			var permitted = $j(this).attr('ftbarnaclevalue');
			
			// Loop over all the coapi permissions for this generic permission
			$j('.' + permission).each(function (i) {
			
				$j(this).attr('ftinheritbarnaclevalue', permitted);
				
				var barnacleValue = $j(this).attr('ftbarnaclevalue');
				
				if(barnacleValue == 0) {
					if(permitted == 1) {
						$j(this).find('.fa-times-circle').removeClass('fa-times-circle').addClass('fa-check-circle');
						
					} else {
						$j(this).find('.fa-check-circle').removeClass('fa-check-circle').addClass('fa-times-circle');
					};
				};
		   });
		   
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
			   		
			   },
			   error: function(data){	
					alert('change unsuccessful. The page will be refreshed.');
					location=location;
				},
				complete: function(){
					
				}
			 });
				 
		};		 
			 
	});
		
	
	$j('.coapiPermission').click(function() {
		var el = $j(this);
		var permission = $j(this).attr('ftpermissionid');
		var barnacleValue = $j(this).attr('ftbarnaclevalue');
		var inheritBarnacleValue = $j(this).attr('ftinheritbarnaclevalue');
		
		if(barnacleValue == 1) {
			
			if(inheritBarnacleValue == 1) {
				$j(this).attr('ftbarnaclevalue', '-1');
				
				$j(this).find('.fa-check-circle').removeClass('fa-check-circle').addClass('fa-times-circle');
				$j(this).removeClass('permission-inherit').addClass("permission-explicit");
			} else {
				$j(this).attr('ftbarnaclevalue', '0');
				
				$j(this).find('.fa-check-circle').removeClass('fa-check-circle').addClass('fa-times-circle');
				$j(this).removeClass('permission-explicit').addClass("permission-inherit");
			}
		} else if (barnacleValue == -1) {
		
			if(inheritBarnacleValue == 1) {
				$j(this).attr('ftbarnaclevalue', '0');
				$j(this).find('.fa-times-circle').removeClass('fa-times-circle').addClass('fa-check-circle');
				$j(this).removeClass('permission-explicit').addClass("permission-inherit");
			} else {
				$j(this).attr('ftbarnaclevalue', '1');
				$j(this).find('.fa-times-circle').removeClass('fa-times-circle').addClass('fa-check-circle');
				$j(this).removeClass('permission-inherit').addClass("permission-explicit");
			}	
		} else {
			
			if(inheritBarnacleValue == 1) {
				$j(this).attr('ftbarnaclevalue', '-1');
				$j(this).find('.fa-check-circle').removeClass('fa-check-circle').addClass('fa-times-circle');
				$j(this).removeClass('permission-inherit').addClass("permission-explicit");
			} else {
				$j(this).attr('ftbarnaclevalue', '1');
				$j(this).find('.fa-times-circle').removeClass('fa-times-circle').addClass('fa-check-circle');
				$j(this).removeClass('permission-inherit').addClass("permission-explicit");
			}	
		};
		
		$j.ajax({
			type: "POST",
			url: '/index.cfm?ajaxmode=1&type=farRole&objectid=#stobj.objectid#&view=editAjaxSavePermission',
			dataType: "html",
			cache: false,
			context: $j(this),
			timeout: 15000,
			data: {
				referenceid: $j(this).attr('ftreferenceid'),
				permissionid: $j(this).attr('ftpermissionid'),
				objecttype: $j(this).attr('ftobjecttype'),
				barnaclevalue: $j(this).attr('ftbarnaclevalue')
			},
			success: function(msg){
				
			},
			error: function(data){	
				alert('change unsuccessful. The page will be refreshed.');
				location=location;
			},
			complete: function(){
				
			}
		});
		
	});
	
</cfoutput>
</skin:onReady>


			