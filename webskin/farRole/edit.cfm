
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
					elDescendant.find('> .permButton .icon-remove-sign').removeClass('icon-remove-sign').addClass('icon-ok-sign');
				}
				else if (effectiveVal==-1){
					elDescendant.find('> .permButton .icon-ok-sign').removeClass('icon-ok-sign').addClass('icon-remove-sign');
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

<wiz:wizard ReferenceID="#stobj.objectid#" bFocusFirstField="false">
	
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
		
		<skin:view typename="farRole" objectid="#stobj.objectid#" webskin="editGeneralPermissions" />
		
	</wiz:step>


	<wiz:step name="Webskin">
	
		<wiz:object typename="#stobj.typename#" ObjectID="#stobj.objectID#" lfields="webskins" format="edit" intable="false" r_stPrefix="prefix" />
		
	</wiz:step>

</wiz:wizard>	
