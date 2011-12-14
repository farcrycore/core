
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />




<skin:loadJS id="jquery" />
<skin:loadJS id="jquery-ui" />
<skin:loadCSS id="jquery-ui" />



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


<cfset stTree = structNew() />

<ft:form>
	
	
		
		<cfset oCoapi = application.fapi.getContentType("farCoapi")>
		<cfset stPermissionLabels = structNew()>
		<cfloop list="#request.lTypePermissions#" index="iPermission">
			<cfset stPermissionLabels[iPermission] = replaceNoCase(application.security.factory.permission.getLabel(iPermission) , "generic", "", "all") />
		</cfloop>
		
		<cfoutput>
		
		<table class="objectAdmin" style="table-layout:fixed;width:99%;">
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
						<cfset icon = "ui-icon-check">
					<cfelse>
						<cfset priority = "ui-priority-secondary">
						<cfset icon = "ui-icon-close">
					</cfif>
				
					
				
					<th title="#stPermissionLabels[iPermission]#">
						<button id="generic#iPermission#" class="permButton genericPermission #priority# #icon# <cfif stobj.title EQ 'SysAdmin'>sysadmin</cfif>" fticon="#icon#" value="#currentBarnacleValue#" type="button" ftpermissionid="#iPermission#" ftbarnaclevalue="#numberformat(currentBarnacleValue)#"></button>
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
								<cfset priority = "ui-priority-primary">
								<cfset icon = "ui-icon-check">
								<cfset class="" />
							<cfelseif currentBarnacleValue EQ -1>
								<cfset priority = "ui-priority-secondary">
								<cfset icon = "ui-icon-close">
								<cfset class="" />
							<cfelse>
								<cfset class="inherit" />
								
								<cfif inheritbarnaclevalue EQ 1>
									<cfset priority = "ui-priority-primary">
									<cfset icon = "ui-icon-check">
								<cfelse>
									<cfset priority = "ui-priority-secondary">
									<cfset icon = "ui-icon-close">
								</cfif>
								
							</cfif>
						
							
						
							<td title="#stPermissionLabels[iPermission]#">
								<button id="#hash(stCoapiType.objectid)##iPermission#" class="permButton coapiPermission barnacleBox #priority# #iPermission# #icon# #class#" fticon="#icon#" value="#currentBarnacleValue#" type="button" ftobjecttype="farCoapi" ftreferenceid="#barnacleID#" ftpermissionid="#iPermission#" ftbarnaclevalue="#numberformat(currentBarnacleValue)#" ftinheritbarnaclevalue="#numberformat(inheritbarnaclevalue)#"></button>
							</td>
						
							
						</cfloop>
						
					</tr>
				</cfif>
			</cfloop>
		</tbody>
		</table>
		
		</cfoutput>
	

	
	
		<cfoutput>
		<input type="hidden" name="typePermissionsSubmitted" value="true">
		</cfoutput>
		
	
	</ft:form>
	


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

	
	$j('.genericPermission').click(function() {
		var el = $j(this);
		var permission = $j(this).attr('ftpermissionid');
		var permitted = $j(this).attr('ftbarnaclevalue');
		
		if (permitted == 1 && $j(this).hasClass('sysadmin')) {
		
			alert('You can not change the SysAdmin generic permissions. SysAdmin can do everything.')
		
		} else {
		
			
			
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
			
			
			// Loop over all the copai permissions for this generic permission
			$j('.' + permission).each(function (i) {
			
				$j(this).attr('ftinheritbarnaclevalue', permitted);
				
				
				var barnacleValue = $j(this).attr('ftbarnaclevalue');
				
				
				
				if(barnacleValue == 0) {
			
					if(permitted == 1) {
						$j(this).removeClass('ui-priority-secondary').addClass('ui-priority-primary');
						$j(this).find('.ui-icon').removeClass('ui-icon-close').addClass('ui-icon-check');
						
					} else {
						$j(this).removeClass('ui-priority-primary').addClass('ui-priority-secondary');
						$j(this).find('.ui-icon').removeClass('ui-icon-check').addClass('ui-icon-close');
								
					};
					
					$j(this).addClass('inherit');
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
			   		$j(this).find('.ui-icon').removeClass('ui-icon-bullet');
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
				
				$j(this).removeClass('ui-priority-primary').addClass('ui-priority-secondary');
				$j(this).find('.ui-icon').removeClass('ui-icon-check').addClass('ui-icon-close');
				$j(this).removeClass('inherit');
			} else {
				$j(this).attr('ftbarnaclevalue', '0');
				
				$j(this).removeClass('ui-priority-primary').addClass('ui-priority-secondary');
				$j(this).find('.ui-icon').removeClass('ui-icon-check').addClass('ui-icon-close');
				$j(this).addClass('inherit');
			}
		} else if (barnacleValue == -1) {
		
			
			if(inheritBarnacleValue == 1) {
				$j(this).attr('ftbarnaclevalue', '0');
				$j(this).removeClass('ui-priority-secondary').addClass('ui-priority-primary');
				$j(this).find('.ui-icon').removeClass('ui-icon-close').addClass('ui-icon-check');
				$j(this).addClass('inherit');
			} else {
				$j(this).attr('ftbarnaclevalue', '1');
				$j(this).removeClass('ui-priority-secondary').addClass('ui-priority-primary');
				$j(this).find('.ui-icon').removeClass('ui-icon-close').addClass('ui-icon-check');
				$j(this).removeClass('inherit');
			}	
		} else {
			
			if(inheritBarnacleValue == 1) {
				$j(this).attr('ftbarnaclevalue', '-1');
				$j(this).removeClass('ui-priority-primary').addClass('ui-priority-secondary');
				$j(this).find('.ui-icon').removeClass('ui-icon-check').addClass('ui-icon-close');
				$j(this).removeClass('inherit');
			} else {
				$j(this).attr('ftbarnaclevalue', '1');
				$j(this).removeClass('ui-priority-secondary').addClass('ui-priority-primary');
				$j(this).find('.ui-icon').removeClass('ui-icon-close').addClass('ui-icon-check');
				$j(this).removeClass('inherit');
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
		   		$j(this).find('.ui-icon').removeClass('ui-icon-bullet');  	
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


			