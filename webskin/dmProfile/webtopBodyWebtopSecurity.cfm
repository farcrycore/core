

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />



<!--- 
ENVIRONMENT VARIABLES
 --->


<cfset oUD = application.security.userdirectories[stobj.userdirectory] />
<cfset userID = application.factory.oUtils.listSlice(stobj.username,1,-2,"_") />
<cfset aUserGroups = oUD.getUserGroups(userID) />

<cfset groups = "">
<cfloop from="1" to="#arraylen(aUserGroups)#" index="i">
	<cfset groups = listappend(groups,"#aUserGroups[i]#_#stobj.userdirectory#") />
</cfloop>
<cfset lRoleIDs = application.fapi.getContentType("farRole").groupsToRoles(groups) />

<ft:form style="width:100%;">
<cfoutput>
	<h1>
		#encodeForHTML(stobj.firstName)# #encodeForHTML(stobj.lastname)# Webtop Security
		
		<ft:button value="Print" type="button" onClick="window.print();" class="hidden-print" />
	</h1>
</cfoutput>

<cfif len(lRoleIDs)>
	
	<cfset form.selectPermission = application.security.factory.permission.getID(name="viewWebtopItem") />

	<cfparam name="request.stWebtopPermissions" default="#structNew()#">
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
			##webtopTree .fa { position:relative; font-size: 16px; line-height: 14px; top: -2px; }
			##webtopTree .nodelabel { font-size: 13px; line-height: 14px; color: inherit; }
		</style>
		<style type="text/css" media="print">
		  @page { size: landscape; }
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
				AND farBarnacle.roleid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lRoleIDs#">)
				AND farBarnacle.permissionid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.selectPermission#">
	</cfquery>

	<cfquery datasource="#application.dsn#" name="qRoles">
	SELECT *
	FROM farRole
	WHERE objectid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lRoleIDs#">)
	ORDER BY title
	</cfquery>
	
	
	
	<ft:field label="Webtop Access">
		<cfset accessPermissionID = application.fapi.getContentType("farPermission").getID('admin')>
		
		<cfif application.security.checkPermission(permission="admin",role="#lRoleIDs#")>
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
		
	</ft:field>
	
	<cfoutput>
		<input type="hidden" name="permissionID" value="#form.selectPermission#" />
		<div id="webtopTreeWrap" <cfif allowAccess EQ -1>style="display:none;"</cfif>>
	</cfoutput>
	
	<ft:field label="Access Permissions" bMultiField="true">
	
		
		<cfoutput>
		<div>
		<cfloop query="qRoles">
			<div style="float:right;width:100px;text-align:center;">
				<strong>#qRoles.title#</strong>
			</div>
		</cfloop>
		</div>	
		<br style="clear:both;" />
		</cfoutput>	
		
		
		<cfoutput>
			<ul id="webtopTree">
				<li>
		</cfoutput>
		
		<cfif structKeyExists(stCurrentPermissionSet, barnacleID)>
			<cfset currentBarnacleValue = stCurrentPermissionSet[barnacleID] >
		<cfelse>
			<cfquery dbtype="query" name="qNodeBarnacle">
			SELECT max(barnacleValue) as maxBarnacleValue
			FROM qBarnacles
			WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
			AND roleID IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lRoleIDs#">)
			</cfquery>
			
			<cfif isNumeric(qNodeBarnacle.maxBarnacleValue)>
				<cfset currentBarnacleValue = qNodeBarnacle.maxBarnacleValue />
			<cfelse>
				<cfset currentBarnacleValue = -1 />
			</cfif>
		</cfif>
		
		<cfset currentWebtopValue = currentBarnacleValue />
		
		<!--- We always have webtop permission as checked --->
		<cfoutput>
			<a id="webtopRoot" class="permButton permission-explicit"><i class="fa fa-check-circle fa-fw"></i></a>
			<input type="hidden" class="barnacleValue" id="barnacleValue-#barnacleID#" name="barnacleValue-#barnacleID#" value="1">
			<input type="hidden" class="inheritBarnacleValue" id="inheritBarnacleValue-#barnacleID#" value="1">
			<span style="font-size:10px;">&nbsp;Webtop</span>
			
			<cfloop query="qRoles">
				<div style="float:right;width:100px;text-align:center;">
					<cfif application.security.checkPermission(permission="admin",role="#qRoles.objectid#")>
						<i class="fa fa-check-circle fa-fw" style="color:green;font-size:14px" title="#qRoles.title#"></i>
					<cfelse>
						<i class="fa fa-times-circle fa-fw" style="color:red;font-size:14px" title="#qRoles.title#"></i>
					</cfif>
				</div>
			</cfloop>
		
		
		</cfoutput>
		
		<cfif listLen(stWebtop.CHILDORDER)>
			<cfoutput><ul class="zebra"></cfoutput>
		</cfif>
		
		<cfloop list="#stWebtop.CHILDORDER#" index="i">
			
			<cfset stLevel1 = stWebtop.children[i] />
			<cfset barnacleID = hash(stLevel1.rbKey)>
			
			<cfoutput><li class="closed"></cfoutput>
			
			<cfif structKeyExists(stCurrentPermissionSet, barnacleID)>
				<cfset currentBarnacleValue = stCurrentPermissionSet[barnacleID] >
			<cfelse>
			
				<cfset currentBarnacleValue = -1 />
				
				<cfloop list="#lRoleIDs#" index="iRole">
					<cfif application.security.checkPermission(permission="admin",role="#iRole#")>
						<cfquery dbtype="query" name="qNodeBarnacle">
						SELECT max(barnacleValue) as maxBarnacleValue
						FROM qBarnacles
						WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
						AND roleID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#iRole#">
						</cfquery>
						
						<cfif not isNumeric(qNodeBarnacle.maxBarnacleValue) OR qNodeBarnacle.maxBarnacleValue EQ 0><!--- Inherited --->
							<cfset currentBarnacleValue = 0>
						<cfelseif qNodeBarnacle.maxBarnacleValue EQ 1>
							<cfset currentBarnacleValue = 1>
							<cfbreak>
						</cfif>
					</cfif>
				</cfloop>
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
				<span style="font-size:10px;">&nbsp;#stLevel1.label#</span>
				
				#roleListBarnacles(barnacleID=barnacleID)#
				
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
					
						<cfset currentBarnacleValue = -1 />
						
						<cfloop list="#lRoleIDs#" index="iRole">
							<cfif application.security.checkPermission(permission="admin",role="#iRole#")>
								<cfquery dbtype="query" name="qNodeBarnacle">
								SELECT max(barnacleValue) as maxBarnacleValue
								FROM qBarnacles
								WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
								AND roleID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#iRole#">
								</cfquery>
								
								<cfif not isNumeric(qNodeBarnacle.maxBarnacleValue) OR qNodeBarnacle.maxBarnacleValue EQ 0><!--- Inherited --->
									<cfset currentBarnacleValue = 0>
								<cfelseif qNodeBarnacle.maxBarnacleValue EQ 1>
									<cfset currentBarnacleValue = 1>
									<cfbreak>
								</cfif>
							</cfif>
						</cfloop>
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
						<span style="font-size:10px;">&nbsp;#stLevel2.label#</span>
				
						#roleListBarnacles(barnacleID=barnacleID)#
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
							
								<cfset currentBarnacleValue = -1 />
								
								<cfloop list="#lRoleIDs#" index="iRole">
									<cfif application.security.checkPermission(permission="admin",role="#iRole#")>
										<cfquery dbtype="query" name="qNodeBarnacle">
										SELECT max(barnacleValue) as maxBarnacleValue
										FROM qBarnacles
										WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
										AND roleID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#iRole#">
										</cfquery>
										
										<cfif not isNumeric(qNodeBarnacle.maxBarnacleValue) OR qNodeBarnacle.maxBarnacleValue EQ 0><!--- Inherited --->
											<cfset currentBarnacleValue = 0>
										<cfelseif qNodeBarnacle.maxBarnacleValue EQ 1>
											<cfset currentBarnacleValue = 1>
											<cfbreak>
										</cfif>
									</cfif>
								</cfloop>
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
								<span style="font-size:10px;">&nbsp;#stLevel3.label#</span>
				
								#roleListBarnacles(barnacleID=barnacleID)#
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
									
										<cfset currentBarnacleValue = -1 />
										
										<cfloop list="#lRoleIDs#" index="iRole">
											<cfif application.security.checkPermission(permission="admin",role="#iRole#")>
												<cfquery dbtype="query" name="qNodeBarnacle">
												SELECT max(barnacleValue) as maxBarnacleValue
												FROM qBarnacles
												WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
												AND roleID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#iRole#">
												</cfquery>
												
												<cfif not isNumeric(qNodeBarnacle.maxBarnacleValue) OR qNodeBarnacle.maxBarnacleValue EQ 0><!--- Inherited --->
													<cfset currentBarnacleValue = 0>
												<cfelseif qNodeBarnacle.maxBarnacleValue EQ 1>
													<cfset currentBarnacleValue = 1>
													<cfbreak>
												</cfif>
											</cfif>
										</cfloop>
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
											<span style="font-size:10px;">&nbsp;#stLevel4.label#</span>
				
											#roleListBarnacles(barnacleID=barnacleID)#
											
											
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
		</cfoutput>
	</ft:field>
	
	<cfoutput></div></cfoutput>	
	
	
	
<skin:onReady id="fixDescendants"><cfoutput>
	$fc.fixDescendants = function(elParent,clearRedundant) {
		
		elParent = elParent.closest("li");
		clearRedundant = clearRedundant || false;
		
		var thisVal = elParent.find("> .barnacleValue").val(), thisInheritedVal = elParent.find("> .inheritBarnacleValue").val(), effectiveVal = thisVal==0 ? thisInheritedVal : thisVal;
		
		elParent.find("> ul > li").each(function(){ 
			
			var elDescendant = $j(this), descendantValue = elDescendant.find('> .barnacleValue').val();
			
			elDescendant.find("> .inheritBarnacleValue").val(effectiveVal);
			
			if (descendantValue==0){
				if (effectiveVal==1){
					elDescendant.find('> .permButton .fa-times-circle').removeClass('fa-times-circle').addClass('fa-check-circle');
				}
				else if (effectiveVal==-1){
					elDescendant.find('> .permButton .fa-check-circle').removeClass('fa-check-circle').addClass('fa-times-circle');
				}
			}
			else if (descendantValue==effectiveVal && clearRedundant){
				elDescendant.find("> .barnacleValue").val(0);
				elDescendant.find("> .permission-explicit").removeClass('permission-explicit').addClass('permission-inherit');
			}
			
			$fc.fixDescendants(elDescendant);
		});
	};
</cfoutput></skin:onReady>

	
	<skin:onReady><cfoutput>
		
		$fc.fixDescendants ( $j('##webtopRoot'), true );
			
		$j("##webtopTree input.barnacleValue[value='1'],##webtopTree input.barnacleValue[value='-1']").each(function (i) {
			$j(this).parent('li').parents('li').removeClass("closed").addClass("open");
		});
		
		$j("##webtopTree").treeview({
			animated: "fast",
			collapsed: true
		});
		
		
	</cfoutput></skin:onReady>
	
	
	
	

<cfelse>
	<cfoutput><div class="alert alert-error">NO ROLES ASSIGNED TO THIS USER.</div></cfoutput>
</cfif>




</ft:form>



<cffunction name="roleListBarnacles" output="true" returntype="void">
	<cfargument name="barnacleID">


	<cfloop query="qRoles">
		
		<cfoutput>
		<div style="float:right;width:100px;text-align:center;">
			<cfif application.security.checkPermission(permission="admin",role="#qRoles.objectid#")>
						
				<cfquery dbtype="query" name="qNodeBarnacle">
				SELECT *
				FROM qBarnacles
				WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.barnacleID#">
				AND roleID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qRoles.objectid#">
				</cfquery>
				
				<cfif qNodeBarnacle.recordCount>
					<cfif qNodeBarnacle.barnacleValue EQ 1>
						<i class="fa fa-check-circle fa-fw" style="color:green;font-size:14px" title="#qRoles.title#"></i>
					<cfelseif qNodeBarnacle.barnacleValue EQ -1>
						<i class="fa fa-times-circle fa-fw" style="color:red;font-size:14px" title="#qRoles.title#"></i>
					<cfelse>
						&nbsp;
					</cfif>
				<cfelse>
					&nbsp;
				</cfif>
			<cfelse>
				&nbsp;
			</cfif>
		</div>
		</cfoutput>
	</cfloop>
	
	
</cffunction>
