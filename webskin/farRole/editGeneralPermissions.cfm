<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<skin:htmlHead><cfoutput>
	<style type="text/css">
		.general-permissions a.permButton, .general-permissions a.permButton:hover { cursor:pointer; text-decoration:none; }
		.general-permissions .icon-ok-sign { color:##006600; }
		.general-permissions .icon-remove-sign { color:##FF0000; }
	</style>
</cfoutput></skin:htmlHead>
<skin:onReady><cfoutput>
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
			$j(this).find('.icon-ok-sign').removeClass('icon-ok-sign').addClass('icon-remove-sign');
			
		} else {
			$j(this).attr('ftbarnaclevalue', '1');
			$j(this).removeClass('ui-priority-secondary').addClass('ui-priority-primary');
			$j(this).find('.icon-remove-sign').removeClass('icon-remove-sign').addClass('icon-ok-sign');
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
				//	
			},
			error: function(data){	
				alert('change unsuccessful. The page will be refreshed.');
				location=location;
			},
			complete: function(){
				//
			}
		});
	});
</cfoutput></skin:onReady>

<cfquery datasource="#application.dsn#" name="qPermissions">
	SELECT *
	FROM farPermission
	WHERE bSystem <> 1
	ORDER BY title
</cfquery>

<cfoutput>
	<table class="objectAdmin general-permissions" style="table-layout:fixed;width:95%;">
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
</cfoutput>

<cfloop query="qPermissions">
	<cfif application.fapi.arrayFind(stobj.aPermissions, qPermissions.objectid)>
		<cfset allowAccess = 1>
	<cfelse>
		<cfset allowAccess = -1>
	</cfif>
	
	<cfif allowAccess EQ 1>
		<cfset priority = "ui-priority-primary">
		<cfset icon = "icon-ok-sign">
	<cfelse>
		<cfset priority = "ui-priority-secondary">
		<cfset icon = "icon-remove-sign">
	</cfif>
	
	<cfoutput>
		<tr>
			<td>#qPermissions.shortcut#</td>
			<td>
				<a id="perm-#qPermissions.objectid#" class="permButton small barnacleBox #priority#" value="#allowAccess#" ftpermissionid="#qPermissions.objectid#" ftbarnaclevalue="#numberformat(allowAccess)#"><i class="#icon# icon-large"></i></a>
			</td>	
			<td>#qPermissions.hint#</td>
		</tr>
	</cfoutput>
</cfloop>

<cfoutput>
		</tbody>
	</table>
</cfoutput>
