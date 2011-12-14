
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />



<cfset setLock(stObj=stObj,locked=true) />



<!--- 
ENVIRONMENT VARIABLES
 --->
<!--- 
<cfquery datasource="#application.dsn#" name="qGenericPermissions">
select objectid from farPermission
where title like '%Generic%'
order by shortcut
</cfquery>
<cfset permissions = valueList(qGenericPermissions.objectid) />
 --->


<cfset permissions = application.security.factory.permission.getAllPermissions('farCoapi') />


<cfif isWDDX(stobj.typePermissions)>
	<cfwddx action="wddx2cfml" input="#stobj.typePermissions#" output="stTypePermissions" />
<cfelse>
	<cfparam name="stTypePermissions" default="#structNew()#" />
	

	<cfquery datasource="#application.dsn#" name="qBarnacles">
	SELECT *
	FROM farBarnacle
	WHERE objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="farCoapi">
	AND roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stobj.objectid#">
	AND permissionID IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#permissions#">)
	</cfquery>
	
	<cfloop query="qBarnacles">
		<cfparam name="stTypePermissions['#qBarnacles.permissionID#']" default="#structNew()#" />
		<cfset stTypePermissions['#qBarnacles.permissionID#']['#qBarnacles.referenceID#'] = qBarnacles.barnaclevalue >
	</cfloop>
</cfif>



<!--- 


<ft:processForm action="Save,Change Permission">


	<cfloop collection="#form#" item="iField">
		<cfif left(iField,14) EQ "barnacleValue-">
			<cfset session.fc.stRolePermissions['#stobj.objectid#']['#form.permissionID#'][ mid(iField,15, len(iField)-14) ] = form[iField] />
		</cfif>
	</cfloop>
</ft:processForm>

<ft:processForm action="Change Permission">
	<skin:location type='farRole' objectid='#stobj.objectid#' view='editSitePermissions' urlParameters='permission=#form.selectPermission#' />
</ft:processForm>
 --->



<!--- 
<cfparam name="session.fc.stRolePermissions['#stobj.objectid#']['#form.objecttype#']['#form.permissionID#']" default="#structNew()#">
 --->
<ft:processForm action="Save">
	
	<cfwddx action="cfml2wddx" input="#stTypePermissions#" output="wddxTypePermissions" />
	<cfset application.fapi.setData(typename="farRole",
									objectid="#stobj.objectid#",
									typePermissions="#wddxTypePermissions#")>
	
	
	<cfset oBarnacle = application.fapi.getContentType("farBarnacle") />
	
	
	<cfloop list="#structKeyList(stTypePermissions)#" index="iPermission">
		<cfquery datasource="#application.dsn#" name="qPermissionBarnacles">
		SELECT *
		FROM farBarnacle
		WHERE objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="farCoapi">
		AND farBarnacle.roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stobj.objectid#">
		AND farBarnacle.permissionid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#iPermission#">
		</cfquery>
		
		<cfloop collection="#stTypePermissions['#iPermission#']#" item="iReferenceID">
			<cfquery dbtype="query" name="qBarnacleExists">
			SELECT *
			FROM qPermissionBarnacles
			WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#iReferenceID#">
			</cfquery>
			
			<cfset newBarnacleValue = stTypePermissions[iPermission][iReferenceID] />
			
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
	
	
	<!--- SAVE BARNACLES --->
</ft:processForm>

<ft:processForm action="Save,Cancel" Exit="true" url="/webtop/edittabOverview.cfm?typename=farRole&method=edit&ref=iframe&module=customlists/farRole.cfm&objectid=#stobj.objectid#">
	<cfset setLock(objectid=stObj.objectid,locked=false) />
	
	<cfset structDelete(Session.TempObjectStore, stobj.objectid)>

</ft:processForm>



<cfif isWDDX(stobj.typePermissions)>
	<cfwddx action="wddx2cfml" input="#stobj.typePermissions#" output="stTypePermissions" />
<cfelse>
	<cfparam name="stTypePermissions" default="#structNew()#" />
	

	<cfquery datasource="#application.dsn#" name="qBarnacles">
	SELECT *
	FROM farBarnacle
	WHERE objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="farCoapi">
	AND roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stobj.objectid#">
	AND permissionID IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#permissions#">)
	</cfquery>
	
	<cfloop query="qBarnacles">
		<cfparam name="stTypePermissions['#qBarnacles.permissionID#']" default="#structNew()#" />
		<cfset stTypePermissions['#qBarnacles.permissionID#']['#qBarnacles.referenceID#'] = qBarnacles.barnaclevalue >
	</cfloop>
</cfif>


<skin:loadJS id="jquery" />
<skin:loadJS id="jquery-ui" />
<skin:loadCSS id="jquery-ui" />
<!--- 

<cfoutput><h1>CHECK PERMISSION</h1></cfoutput>
<cfset result = 0 />
<cfset typePackagePath = application.fapi.getContentTypeMetadata(typename="dmCron", md="packagePath")>
<cfset lExtends = application.fapi.listExtends(typePackagePath)>
	
<cfloop list="#lExtends#" index="iPath">
	<cfset result = application.fapi.getContentType("farBarnacle").checkPermission(object="#hash(iPath)#", objecttype="package", permission="#listLast(permissions)#",role="anonymous") />
	<cfif result EQ 1>
		<cfoutput><p>application.fapi.getContentType("farBarnacle").checkPermission(object="#hash(iPath)#", objecttype="package", permission="#listLast(permissions)#",role="anonymous") /></p></cfoutput>
		<cfbreak>
	</cfif>
</cfloop>
<cfoutput><p>result: #result#</p></cfoutput> --->

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
<!--- 

<cfloop collection="#application.stCoapi#" item="iType">
	<cfset stPointer = stTree>
	
	<!--- <cfset packagepath = application.fapi.getContentTypeMetadata(typename="#iType#", md="packagepath")>
	<cfset lExtends = application.fapi.listExtends(packagepath)>
	
	
	<cfdump var="#application.stCoapi[iType].aExtends#" label="#iType#">
	<cfoutput>
	arrayLen(application.stCoapi[iType].aExtends): #arrayLen(application.stCoapi[iType].aExtends)#<br />
	lExtends: #lExtends#
	</cfoutput>
	<cfabort>


	<cfloop from="#listLen(lExtends)#" to="1" step="-1" index="i">
		<cfif not structKeyExists(stPointer, application.stCoapi[iType].aExtends[i])>
			<cfset stPointer[application.stCoapi[iType].aExtends[i]] = structNew() />
		</cfif>
		
		<cfset stPointer = stPointer[application.stCoapi[iType].aExtends[i]] />
	</cfloop>
	
	<cfif not structKeyExists(stPointer, iType)>
		<cfset stPointer[iType] = structNew() />
	</cfif>
	
	<cfset stPointer[iType].displayName = application.stCoapi[iType].displayName />
	<cfset stPointer[iType].packagePath = application.stCoapi[iType].packagePath />
	 --->
	
	<cfloop from="#arrayLen(application.stCoapi[iType].aExtends)#" to="1" step="-1" index="i">
		<cfif not structKeyExists(stPointer, application.stCoapi[iType].aExtends[i])>
			<cfset stPointer[application.stCoapi[iType].aExtends[i]] = structNew() />
		</cfif>
		
		<cfset stPointer = stPointer[application.stCoapi[iType].aExtends[i]] />
	</cfloop>
	
	<cfif not structKeyExists(stPointer, iType)>
		<cfset stPointer[iType] = structNew() />
	</cfif>
	
	<cfset stPointer[iType].displayName = application.stCoapi[iType].displayName />
	<cfset stPointer[iType].packagePath = application.stCoapi[iType].packagePath />
</cfloop>

<cfdump var="#stTree#" expand="false">

 --->



<!--- 
TEST 2
 --->

<!--- 
<cfset stTree = structNew() />

<cfloop collection="#application.stCoapi#" item="iType">
	<cfset stPointer = stTree>
	
	<cfset packagepath = application.fapi.getContentTypeMetadata(typename="#iType#", md="packagepath")>
	<cfset lExtends = application.fapi.listExtends(packagepath)>



	<cfloop from="#arrayLen(application.stCoapi[iType].aExtends)#" to="1" step="-1" index="i">
		<cfif not structKeyExists(stPointer, application.stCoapi[iType].aExtends[i])>
			<cfset stPointer[application.stCoapi[iType].aExtends[i]] = structNew() />
		</cfif>
		
		<cfset stPointer = stPointer[application.stCoapi[iType].aExtends[i]] />
	</cfloop>
	
	<cfif not structKeyExists(stPointer, iType)>
		<cfset stPointer[iType] = structNew() />
	</cfif>
	
	<cfset stPointer[iType].displayName = application.stCoapi[iType].displayName />
	<cfset stPointer[iType].packagePath = application.stCoapi[iType].packagePath />
</cfloop>
 --->



<!--- 

<cffunction name="renderNode" output="true">
	<cfargument name="stNode" />
	<cfargument name="treeID" default="" />
	<cfargument name="roleID" default="" />
	
	<cfset var lChildren = "">


	<cfset priority = "secondary">
	<cfset icon = "ui-icon-close">
	<cfset class="inherit" />
	<cfif len(treeID)>
		<cfset priority = "ui-priority-secondary">
		<cfset icon = "ui-icon-check">
		<cfset inherit="" />
		<cfset currentBarnacleValue = -1>
		<cfset currentInheritBarnacleValue = -1>
	<cfelse>
		<cfset priority = "ui-priority-secondary">
		<cfset icon = "ui-icon-check">
		<cfset inherit="inherit" />
		<cfset currentBarnacleValue = 0>
		<cfset currentInheritBarnacleValue = "">
	</cfif>	
	
	<cfif not structIsEmpty(stNode)>
		
		<cfoutput><ul <cfif len(arguments.treeID)>id="#arguments.treeID#"</cfif> ></cfoutput>
		
		<cfset lChildren = ListSort( structKeyList(stNode) , 'textnocase')>
		
		<cfif listFindNoCase(lChildren, "bAbstract")>
			<cfset lChildren = listDeleteAt(lChildren, listFindNoCase(lChildren, "bAbstract"))>
			<cfset lChildren = listDeleteAt(lChildren, listFindNoCase(lChildren, "displayName"))>
			<cfset lChildren = listDeleteAt(lChildren, listFindNoCase(lChildren, "packagepath"))>
		</cfif>
		
		<cfloop list="#lChildren#" index="i">
			<cfif stNode[i].bAbstract EQ 0>
				
				<cfset barnacleID = hash(stNode[i].packagePath) />
				
				<cfoutput>
				<li title="#stNode[i].packagePath#">
					
					<cfloop list="#permissions#" index="iPermission">
						
						<cfif i EQ "fourq">
							<cfif structKeyExists(stTypePermissions['#iPermission#'], barnacleID)>
								<cfset currentBarnacleValue = stTypePermissions['#iPermission#'][barnacleID]>
							<cfelse>
								<cfset currentBarnacleValue = -1 />
							</cfif>
						<cfelse>
							<cfif structKeyExists(stTypePermissions['#iPermission#'], barnacleID)>
								<cfset currentBarnacleValue = stTypePermissions['#iPermission#'][barnacleID]>
							<cfelse>
								<cfset currentBarnacleValue = 0 />
							</cfif>
						</cfif>
						
						<cfset priority = "ui-priority-secondary">
						<cfset icon = "ui-icon-close">
						<cfset inherit="inherit" />
						<cfif currentBarnacleValue EQ 1>
							<cfset priority = "ui-priority-primary">
							<cfset inherit="" />
						<cfelseif currentBarnacleValue EQ -1>
							<cfset priority = "ui-priority-secondary">
							<cfset inherit="" />
						</cfif>
						
						<button id="#hash(stNode[i].packagePath)##iPermission#" class="permButton barnacleBox #priority# #inherit# #iPermission#" value="#currentBarnacleValue#" type="button" ftobjecttype="package" ftreferenceid="#barnacleID#" ftpermissionid="#iPermission#" ftbarnaclevalue="#numberformat(currentBarnacleValue)#" ftinheritbarnaclevalue="#currentInheritBarnacleValue#"></button>
						
						<!--- <input type="hidden" class="barnacleValue #iPermission#" id="barnacleValue-#barnacleID#" name="barnacleValue-#barnacleID#-#iPermission#" value="#currentBarnacleValue#" style="width:10px;">
						<input type="hidden" class="inheritBarnacleValue #iPermission#" id="inheritBarnacleValue-#barnacleID#" value="#currentInheritBarnacleValue#" style="width:10px;"> --->
					</cfloop>
					
						&nbsp;
						#stNode[i].displayName# (#i#)
				</li>
				</cfoutput>
			<cfelse>
				
				<cfset barnacleID = hash(stNode[i].packagePath) />
				
				<cfoutput>
				<li>
					
					<cfloop list="#permissions#" index="iPermission">
						

						<cfif i EQ "fourq">
							<cfif structKeyExists(stTypePermissions['#iPermission#'], barnacleID)>
								<cfset currentBarnacleValue = stTypePermissions['#iPermission#'][barnacleID]>
							<cfelse>
								<cfset currentBarnacleValue = -1 />
							</cfif>
						<cfelse>
							<cfif structKeyExists(stTypePermissions['#iPermission#'], barnacleID)>
								<cfset currentBarnacleValue = stTypePermissions['#iPermission#'][barnacleID]>
							<cfelse>
								<cfset currentBarnacleValue = 0 />
							</cfif>
						</cfif>
						
						<cfset priority = "ui-priority-secondary">
						<cfset icon = "ui-icon-close">
						<cfset inherit="inherit" />
						<cfif currentBarnacleValue EQ 1>
							<cfset priority = "ui-priority-primary">
							<cfset inherit="" />
						<cfelseif currentBarnacleValue EQ -1>
							<cfset priority = "ui-priority-secondary">
							<cfset inherit="" />
						</cfif>
												
						<button  id="#hash(i)##iPermission#" class="permButton barnacleBox #priority# #inherit# #iPermission#" value="#currentBarnacleValue#" type="button" ftobjecttype="package" ftreferenceid="#barnacleID#" ftpermissionid="#iPermission#" ftbarnaclevalue="#numberformat(currentBarnacleValue)#" ftinheritbarnaclevalue="#currentInheritBarnacleValue#"></button>
						
						<!--- 
						<input type="hidden" class="barnacleValue #iPermission#" id="barnacleValue-#barnacleID#" name="barnacleValue-#barnacleID#-#iPermission#" value="#currentBarnacleValue#" style="width:10px;">
						<input type="hidden" class="inheritBarnacleValue #iPermission#" id="inheritBarnacleValue-#barnacleID#" value="#currentInheritBarnacleValue#" style="width:10px;">
						 --->
					</cfloop>	
					
					&nbsp;
					#stNode[i].displayName# (#i#)

					#renderNode(stNode="#stNode[i]#", roleID="#arguments.roleID#" )#
					
				</li>
				</cfoutput>
			</cfif>
				
		</cfloop>
		
		<cfoutput></ul></cfoutput>
	</cfif>
</cffunction>
 --->

<admin:header title="Edit Type Permissions" />			
	<!--- WEBTOP PERMISSIONS --->
	
	
<!--- 	<cfset stWebtop = application.factory.oWebtop.getItem(honoursecurity="false") />
	<cfset barnacleID = hash(stWebtop.rbKey)> --->
	
	<cfoutput><h1>Edit Type Permissions for #stobj.title#</h1></cfoutput>
	<ft:form>
	
	
		
		<cfset oCoapi = application.fapi.getContentType("farCoapi")>
		
		
		<cfoutput>
		
		<table class="objectAdmin" style="table-layout:fixed;width:800px;">
		<colgroup>
			<col style="width:100px;">
			<col style="width:100px;">
			<cfloop list="#permissions#" index="iPermission">
				<col style="width:40px;">
			</cfloop>
		</colgroup>
		<thead>
		<tr>
			<th colspan="2">Content Type</th>
			<cfloop list="#permissions#" index="iPermission">
				<th class="nowrap" style="font-size:9px;text-align:center;">#replaceNoCase(application.security.factory.permission.getLabel(iPermission) , "generic", "", "all")#</th>
			</cfloop>
		</tr>
		</thead>
		
		<tbody>
				
			<tr>
				<td colspan="2">Default</td>

				
				<cfloop list="#permissions#" index="iPermission">
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
				
					
				
					<td>
						<button id="generic#iPermission#" class="permButton genericPermission #priority# #icon# <cfif stobj.title EQ 'SysAdmin'>sysadmin</cfif>" fticon="#icon#" value="#currentBarnacleValue#" type="button" ftpermissionid="#iPermission#" ftbarnaclevalue="#numberformat(currentBarnacleValue)#"></button>
					</td>
				
					
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
						
						<cfloop list="#permissions#" index="iPermission">
							<cfif application.fapi.arrayFind(stobj.aPermissions, iPermission)>
								<cfset inheritbarnaclevalue = 1>
							<cfelse>
								<cfset inheritbarnaclevalue = -1 />
							</cfif>
							
							<cfif structKeyExists(stTypePermissions, iPermission) AND structKeyExists(stTypePermissions['#iPermission#'], barnacleID)>
								<cfset currentBarnacleValue = stTypePermissions['#iPermission#'][barnacleID]>
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
						
							
						
							<td>
								<button id="#hash(stCoapiType.objectid)##iPermission#" class="permButton coapiPermission barnacleBox #priority# #iPermission# #icon# #class#" fticon="#icon#" value="#currentBarnacleValue#" type="button" ftobjecttype="farCoapi" ftreferenceid="#barnacleID#" ftpermissionid="#iPermission#" ftbarnaclevalue="#numberformat(currentBarnacleValue)#" ftinheritbarnaclevalue="#numberformat(inheritbarnaclevalue)#"></button>
							</td>
						
							
						</cfloop>
						
					</tr>
				</cfif>
			</cfloop>
		</tbody>
		</table>
		
		</cfoutput>

	
	<!--- 
	
	<cfoutput>	
	
	<div style="float:left;">
		<table style="width:100%;table-layout:fixed;">
		<tr class="nowrap">
			<td>&nbsp;</td>
			<cfloop list="#permissions#" index="iPermission">
				<td style="width:6px;">&nbsp;</td>
				<td style="width:50px;font-size:9px;text-align:center;" title="#replaceNoCase(application.security.factory.permission.getLabel(iPermission) , "generic", "", "all")#">#replaceNoCase(application.security.factory.permission.getLabel(iPermission) , "generic", "", "all")#</td>
			</cfloop>
		</tr>
		</table>
		</cfoutput>
		
		<cfoutput>
		#renderNode(stNode="#stTree#", treeID="permissionTree", roleID="#stobj.objectid#")#
		</cfoutput>
	</div> --->
	<ft:buttonPanel style="margin-top:20px;">
		<ft:button value="Save" />
		<ft:button value="Cancel" validate="false" />
	</ft:buttonPanel>
	
	</ft:form>
	
<admin:footer />



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
    
	<!--- $fc.fixDescendants = function(elParent) {
		
		var permission = $j(elParent).attr('ftpermissionid');
		
		// loop over all descendants of clicked item and if they are inheriting, adjust inherited value if required
		$j(elParent).closest( 'div,li' ).find( 'button.permButton[ftpermissionid="' + permission + '"]' ).each(function (i) {
			
			elDescendant = $j(this);
			var descendantValue = $j(elDescendant).attr('ftbarnaclevalue');
			
			$j(elDescendant).find('.ui-icon').removeClass('ui-icon-bullet')
			
			if (descendantValue == -1 ){
				$j(elDescendant).find('.ui-icon').addClass('ui-icon-close');
			};
			if (descendantValue == 1 ){
				$j(elDescendant).find('.ui-icon').addClass('ui-icon-check');
			};
			
			if( $j(elDescendant).attr('id') != $j(elParent).attr('id')) {
				
				$j(this).parents( 'div,li' ).children( 'button.permButton[ftpermissionid="' + permission + '"]' ).each(function (i) {
				
					var elDescendantParent = $j(this);
					
					if( $j(elDescendantParent).attr('id') != $j(elDescendant).attr('id')) {
						
						var descendantParentValue = $j(elDescendantParent).attr('ftbarnaclevalue');
						
						
						if (descendantParentValue == 1) {
							$j(elDescendant).attr('ftinheritbarnaclevalue', '1');
							
							if (descendantValue == 0) { //only descendants that inherit
								$j(elDescendant).removeClass('ui-priority-secondary').addClass('ui-priority-primary');
								$j(elDescendant).find('.ui-icon').removeClass('ui-icon-close').addClass('ui-icon-check');
								
							}
							return false;
						};
						if (descendantParentValue == -1) {
							
							$j(elDescendant).attr('ftinheritbarnaclevalue', '-1');
							
							if (descendantValue == 0) { //only descendants that inherit
								$j(elDescendant).removeClass('ui-priority-primary').addClass('ui-priority-secondary');
								$j(elDescendant).find('.ui-icon').removeClass('ui-icon-check').addClass('ui-icon-close');
								
							}
							return false;
						};
					};
				});
			};
		});				
	}; --->
	
	
	
	
	$j('.genericPermission').click(function() {
		var el = $j(this);
		var permission = $j(this).attr('ftpermissionid');
		var permitted = $j(this).attr('ftbarnaclevalue');
		
		if ($j(this).hasClass('sysadmin')) {
		
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
	<!--- 
	<cfloop list="#permissions#" index="iPermission">	
		$fc.fixDescendants ( $j('###hash('fourq')##iPermission#') );
	</cfloop> --->
		
	<!--- $j("##permissionTree button.permButton[ftbarnaclevalue='1'],##permissionTree button.permButton[ftbarnaclevalue='-1']").each(function (i) {
		$j(this).parents('li').removeClass("closed").addClass("open");
	});
	
	$j("##permissionTree").treeview({
		//animated: "fast",
		collapsed: true
	}); --->
	
	<!--- $j( 'button.permButton["ftbarnaclevalue"="1"]' ).live('mouseenter ', function(event) {           
		
		$j(this).closest( 'li' ).css('background-color', '##E8E8E8');
	
     });
	$j( 'button.permButton["ftbarnaclevalue"="-1"]' ).live('mouseleave', function(event) {           
		
		$j(this).closest( 'li' ).css('background-color', 'transparent');
	
     }); --->

	
</cfoutput>
</skin:onReady>


			