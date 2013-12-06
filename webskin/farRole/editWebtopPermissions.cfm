
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />



<!--- 
ENVIRONMENT VARIABLES
 --->
<cfset form.selectPermission = application.security.factory.permission.getID(name="viewWebtopItem") />

<cfparam name="request.stWebtopPermissions['#form.selectPermission#']" default="#structNew()#" />


<skin:loadJS id="fc-jquery" />
<skin:loadJS id="fc-jquery-ui" />
<skin:loadCSS id="jquery-ui" />

<skin:htmlHead><cfoutput>
	<style type="text/css">
		##webtopTree a.permission-explicit:hover, ##webtopTree a.permission-inherit:hover { text-decoration:none; }
		##webtopTree a.permission-explicit .fa-check-circle { color:##006600; }
		##webtopTree a.permission-inherit .fa-check-circle { color:##8bd68b; }
		##webtopTree a.permission-explicit .fa-times-circle { color:##FF0000; }
		##webtopTree a.permission-inherit .fa-times-circle { color:##FF8080; }
		##webtopTree a.permButton, ##webtopTree a.permButton:hover, ##bAllowAccess, ##bAllowAccess:hover { cursor:pointer; text-decoration:none;font-size:14px;}
		##bAllowAccess .fa-check-circle { color:##006600; }
		##bAllowAccess .fa-times-circle { color:##FF0000; }
		##bAllowAccess .fa { font-size: 16px; margin-top: 5px;}
		##webtopTree .fa { position:relative; font-size: 16px; line-height: 14px; top: -2px; }
		##webtopTree .nodelabel { font-size: 13px; line-height: 14px; color: inherit; }
	</style>
</cfoutput></skin:htmlHead>

		
<!--- WEBTOP PERMISSIONS --->
<cfset stCurrentPermissionSet = request.stWebtopPermissions['#form.selectPermission#']>



<cfset stWebtop = application.factory.oWebtop.getItem(honoursecurity="false") />
<cfset barnacleID = hash(stWebtop.rbKey)>

<cfquery datasource="#application.dsn#" name="qBarnacles">
	SELECT 	farBarnacle.referenceID, farBarnacle.barnacleValue, farBarnacle.roleid, farBarnacle.permissionID
	FROM 	farBarnacle
	WHERE 	objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="webtop">
			AND farBarnacle.roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stobj.objectid#">
			AND farBarnacle.permissionid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.selectPermission#">
</cfquery>

<cfoutput>
<div style="float:left; width:100%">
</cfoutput>

<ft:field label="Webtop Access">
	<cfset accessPermissionID = application.fapi.getContentType("farPermission").getID('admin')>
	<cfif application.fapi.arrayFind(stobj.aPermissions, accessPermissionID)>
		<cfset allowAccess = 1>
	<cfelse>
		<cfset allowAccess = -1>
	</cfif>
	
	<cfif allowAccess EQ 1>
		<cfset icon = "fa-check-circle">
	<cfelse>
		<cfset icon = "fa-times-circle">
	</cfif>
	
	<cfoutput><a id="bAllowAccess" class="permButton" value="#allowAccess#" ftpermissionid="#accessPermissionID#" ftbarnaclevalue="#numberformat(allowAccess)#"><i class="fa #icon# fa-fw"></i></a></cfoutput>
	
	<ft:fieldHint><cfoutput>Should this role be allowed to access the webtop?</cfoutput></ft:fieldHint>
</ft:field>

<ft:field label="Access Permissions" bMultiField="true">
	<cfoutput>
	<div id="webtopTreeWrap" <cfif allowAccess EQ -1>style="display:none;"</cfif>>
		<input type="hidden" name="permissionID" value="#form.selectPermission#" />
		<ul id="webtopTree">
			<li>
	</cfoutput>
	
	<cfif structKeyExists(stCurrentPermissionSet, barnacleID)>
		<cfset currentBarnacleValue = stCurrentPermissionSet[barnacleID] >
	<cfelse>
		<cfquery dbtype="query" name="qNodeBarnacle">
		SELECT *
		FROM qBarnacles
		WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
		</cfquery>
		
		<cfif qNodeBarnacle.recordCount>
			<cfset currentBarnacleValue = numberFormat(qNodeBarnacle.barnacleValue) />
		<cfelse>
			<cfset currentBarnacleValue = -1 />
		</cfif>
	</cfif>
	
	<cfset currentWebtopValue = currentBarnacleValue />
	
	<!--- We always have webtop permission as checked --->
	<cfoutput>
		<a id="webtopRoot" class="permButton permission-explicit" onClick="alert('Use the webtop access permission above to turn off access to the webtop.');return false;"><i class="fa fa-check-circle fa-fw"></i></a>
		<input type="hidden" class="barnacleValue" id="barnacleValue-#barnacleID#" name="barnacleValue-#barnacleID#" value="1">
		<input type="hidden" class="inheritBarnacleValue" id="inheritBarnacleValue-#barnacleID#" value="1">
		<span class="nodelabel">Webtop</span>
	</cfoutput>
	
	
	<cfif listLen(stWebtop.CHILDORDER)>
		<cfoutput><ul></cfoutput>
	</cfif>
	
	<cfloop list="#stWebtop.CHILDORDER#" index="i">
		
		<cfset stLevel1 = stWebtop.children[i] />
		<cfset barnacleID = hash(stLevel1.rbKey)>
		
		<cfoutput><li class="closed"></cfoutput>
		
		<cfif structKeyExists(stCurrentPermissionSet, barnacleID)>
			<cfset currentBarnacleValue = stCurrentPermissionSet[barnacleID] >
		<cfelse>
			<cfquery dbtype="query" name="qNodeBarnacle">
			SELECT *
			FROM qBarnacles
			WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
			</cfquery>
			
			<cfif qNodeBarnacle.recordCount>
				<cfset currentBarnacleValue = numberFormat(qNodeBarnacle.barnacleValue) />
			<cfelse>
				<cfset currentBarnacleValue = 0 />
			</cfif>
		</cfif>
		
		<cfif currentBarnacleValue eq 0>
			<cfset priority = "permission-inherit">
			<cfset currentSectionValue = currentWebtopValue />
		<cfelse>
			<cfset priority = "permission-explicit">
			<cfset currentSectionValue = currentBarnacleValue />
		</cfif>
		
		<cfif currentSectionValue EQ 1>
			<cfset icon = "fa-check-circle">
		<cfelseif currentSectionValue EQ -1>
			<cfset icon = "fa-times-circle">
		</cfif>
		
		<cfoutput>
			<a class="permButton #priority#"><i class="fa #icon# fa-fw"></i></a>
			<input type="hidden" class="barnacleValue" id="barnacleValue-#barnacleID#" name="barnacleValue-#barnacleID#" value="#currentBarnacleValue#">
			<input type="hidden" class="inheritBarnacleValue" id="inheritBarnacleValue-#barnacleID#" value="#currentWebtopValue#">
			<span class="nodelabel">#stLevel1.label#</span>
		</cfoutput>
		
		
		<cfif listLen(stLevel1.CHILDORDER)>
			<cfoutput><ul></cfoutput>
			
			<cfloop list="#stLevel1.CHILDORDER#" index="j">
			
				<cfset stLevel2 = stLevel1.children[j] />
				<cfset barnacleID = hash(stLevel2.rbKey)>
			
				<cfoutput><li></cfoutput>
					
				<cfif structKeyExists(stCurrentPermissionSet, barnacleID)>
					<cfset currentBarnacleValue = stCurrentPermissionSet[barnacleID] >
				<cfelse>
					<cfquery dbtype="query" name="qNodeBarnacle">
					SELECT *
					FROM qBarnacles
					WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
					</cfquery>
					
					<cfif qNodeBarnacle.recordCount>
						<cfset currentBarnacleValue = numberFormat(qNodeBarnacle.barnacleValue) />
					<cfelse>
						<cfset currentBarnacleValue = 0 />
					</cfif>
				</cfif>
				
				<cfif currentBarnacleValue eq 0>
					<cfset priority = "permission-inherit">
					<cfset currentSubsectionValue = currentSectionValue />
				<cfelse>
					<cfset priority = "permission-explicit">
					<cfset currentSubsectionValue = currentBarnacleValue />
				</cfif>
				
				<cfif currentSubsectionValue EQ 1>
					<cfset icon = "fa-check-circle">
				<cfelseif currentSubsectionValue EQ -1>
					<cfset icon = "fa-times-circle">
				</cfif>
				
				<cfoutput>
					<a class="permButton #priority#"><i class="fa #icon# fa-fw"></i></a>
					<input type="hidden" class="barnacleValue" id="barnacleValue-#barnacleID#" name="barnacleValue-#barnacleID#" value="#currentBarnacleValue#">
					<input type="hidden" class="inheritBarnacleValue" id="inheritBarnacleValue-#barnacleID#" value="#currentSectionValue#">
					<span class="nodelabel">#stLevel2.label#</span>
				</cfoutput>
				
				
				<cfif listLen(stLevel2.CHILDORDER)>
					<cfoutput><ul></cfoutput>
					
					<cfloop list="#stLevel2.CHILDORDER#" index="k">
					
						<cfset stLevel3 = stLevel2.children[k] />
						<cfset barnacleID = hash(stLevel3.rbKey)>
						
						<cfoutput><li></cfoutput>
						
						<cfif structKeyExists(stCurrentPermissionSet, barnacleID)>
							<cfset currentBarnacleValue = stCurrentPermissionSet[barnacleID] >
						<cfelse>
							<cfquery dbtype="query" name="qNodeBarnacle">
							SELECT *
							FROM qBarnacles
							WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
							</cfquery>
							
							<cfif qNodeBarnacle.recordCount>
								<cfset currentBarnacleValue = numberFormat(qNodeBarnacle.barnacleValue) />
							<cfelse>
								<cfset currentBarnacleValue = 0 />
							</cfif>
						</cfif>
						
						<cfif currentBarnacleValue eq 0>
							<cfset priority = "permission-inherit">
							<cfset currentMenuValue = currentSubsectionValue />
						<cfelse>
							<cfset priority = "permission-explicit">
							<cfset currentMenuValue = currentBarnacleValue />
						</cfif>
						
						<cfif currentMenuValue EQ 1>
							<cfset icon = "fa-check-circle">
						<cfelseif currentMenuValue EQ -1>
							<cfset icon = "fa-times-circle">
						</cfif>
						
						<cfoutput>
							<a class="permButton #priority#"><i class="fa #icon# fa-fw"></i></a>
							<input type="hidden" class="barnacleValue" id="barnacleValue-#barnacleID#" name="barnacleValue-#barnacleID#" value="#currentBarnacleValue#">
							<input type="hidden" class="inheritBarnacleValue" id="inheritBarnacleValue-#barnacleID#" value="#currentSubsectionValue#" />
							<span class="nodelabel">#stLevel3.label#</span>
						</cfoutput>
						
						<cfif listLen(stLevel3.CHILDORDER)>
							<cfoutput><ul></cfoutput>
							
							<cfloop list="#stLevel3.CHILDORDER#" index="l">
							
								<cfset stLevel4 = stLevel3.children[l] />
								<cfset barnacleID = hash(stLevel4.rbKey)>
								
								
								<cfoutput><li></cfoutput>
									

								<cfif structKeyExists(stCurrentPermissionSet, barnacleID)>
									<cfset currentBarnacleValue = stCurrentPermissionSet[barnacleID] >
								<cfelse>
									<cfquery dbtype="query" name="qNodeBarnacle">
									SELECT *
									FROM qBarnacles
									WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
									</cfquery>
									
									<cfif qNodeBarnacle.recordCount>
										<cfset currentBarnacleValue = numberFormat(qNodeBarnacle.barnacleValue) />
									<cfelse>
										<cfset currentBarnacleValue = 0 />
									</cfif>
								</cfif>
								
								<cfif currentBarnacleValue eq 0>
									<cfset priority = "permission-inherit">
									<cfset currentMenuItemValue = currentMenuValue />
								<cfelse>
									<cfset priority = "permission-explicit">
									<cfset currentMenuItemValue = currentBarnacleValue />
								</cfif>
								
								<cfif currentMenuItemValue EQ 1>
									<cfset icon = "fa-check-circle">
								<cfelseif currentMenuItemValue EQ -1>
									<cfset icon = "fa-times-circle">
								</cfif>
								
								<cfoutput>
										<a class="permButton #priority#"><i class="fa #icon# fa-fw"></i></a>
										<input type="hidden" class="barnacleValue" id="barnacleValue-#barnacleID#" name="barnacleValue-#barnacleID#" value="#currentBarnacleValue#">
										<input type="hidden" class="inheritBarnacleValue" id="inheritBarnacleValue-#barnacleID#" value="#currentMenuValue#">
										<span class="nodelabel">#stLevel4.label#</span>
									</li>
								</cfoutput>
								
							</cfloop>
							
							<cfoutput></ul></cfoutput>
						</cfif>
						
						<cfoutput></li></cfoutput>
						
					</cfloop>
					
					<cfoutput></ul></cfoutput>
				</cfif>
				
				<cfoutput></li></cfoutput>
			
			</cfloop>
			
			<cfoutput></ul></cfoutput>
		</cfif>
		
		<cfoutput></li></cfoutput>
	
	</cfloop>
	
	<cfif listLen(stWebtop.CHILDORDER)>
		<cfoutput></ul></cfoutput>
	</cfif>
	
	<cfoutput>
			</li>
		</ul>
		<input type="hidden" name="webtopPermissionsSubmitted" value="true">
	</div>
	</cfoutput>
</ft:field>

<cfoutput>
</div>
</cfoutput>


<skin:onReady><cfoutput>
	$j('##webtopTree .permButton').click(function() {
		var el = $j(this);
		var barnacleValue = parseInt(el.siblings( '.barnacleValue' ).val());
		var inheritBarnacleValue = parseInt(el.siblings( '.inheritBarnacleValue' ).val());
		var newValue = 0;
		
		if (el.attr('id') == 'webtopRoot'){
			return false;
		}
		
		if (barnacleValue===0)
			newValue = inheritBarnacleValue===1 ? -1 : 1;
		else
			newValue = 0;
		
		$j(this).siblings(".barnacleValue").val(newValue);
		
		switch( newValue ) {
			case -1:
				el.removeClass("permission-inherit").addClass("permission-explicit")
					.find(".fa-check-circle").removeClass("fa-check-circle").addClass("fa-times-circle");
				break;
			case 0:
				el.removeClass("permission-explicit").addClass("permission-inherit");
				
				if (inheritBarnacleValue===1)
					el.find(".fa-times-circle").removeClass("fa-times-circle").addClass("fa-check-circle");
				else
					el.find(".fa-check-circle").removeClass("fa-check-circle").addClass("fa-times-circle");
				
				break;
			case 1:
				el.removeClass("permission-inherit").addClass("permission-explicit")
					.find(".fa-times-circle").removeClass("fa-times-circle").addClass("fa-check-circle");
				break;
		}
		
		$fc.fixDescendants(el,false);
	});
	
		
	$fc.fixDescendants ( $j('##webtopRoot'), true );
		
	$j("##webtopTree input.barnacleValue[value='1'],##webtopTree input.barnacleValue[value='-1']").each(function (i) {
		$j(this).parent('li').parents('li').removeClass("closed").addClass("open");
	});
	
	$j("##webtopTree").treeview({
		animated: "fast",
		collapsed: true
	});
	
	
	
	$j('##bAllowAccess').click(function() {
		var el = $j(this);
		var permission = $j(this).attr('ftpermissionid');
		var barnacleValue = $j(this).attr('ftbarnaclevalue');
		
		if(barnacleValue == 1) {
			
			$j(this).attr('ftbarnaclevalue', '-1');
			$j(this).find('i').removeClass('fa-check-circle').addClass('fa-times-circle');
			
			$j('##webtopTreeWrap').hide('fast');
		
		} else {
			
			$j(this).attr('ftbarnaclevalue', '1');
			$j(this).find('i').removeClass('fa-times-circle').addClass('fa-check-circle');
			
			$j('##webtopTreeWrap').show('fast');
		};
		
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
		   		$j(this).find('i').removeClass('icon-caret-right');
		   },
		   error: function(data){	
				alert('change unsuccessful. The page will be refreshed.');
				location=location;
			},
			complete: function(){
				
			}
		 });
		
	});
</cfoutput></skin:onReady>
