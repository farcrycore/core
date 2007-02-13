<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="fatalErrorMessage" default=""> <!--- fatal [ie something wrong with the db and page cant render] --->
<cfparam name="errorMessage" default=""> <!--- normal error [ie server side validation] --->
<cfparam name="selectedPolicyGroupID" default="0">
<cfparam name="displayPolicyGroupName" default="PolicyGroup">
<cfparam name="completionMessage" default="">
<cfparam name="reference1" default="PolicyGroup">
<cfset oAuthorisation = request.dmsec.oAuthorisation>
<cfset oAuthentication = request.dmsec.oAuthentication>
<cfif isDefined("form.Submit")>
	<cfset completionMessage = completionMessage & application.adminBundle[session.dmProfile.locale].updatePermission>
	<cfloop index="field" list="#form.fieldnames#">
		<cfif field contains "|" AND field contains "_">
			<cfset PolicyGroupId = Mid(ListGetAt( field, 1, "|" ),2,len(ListGetAt( field, 1, "|" ))-1 )>
			<cfset PermissionId = ListGetAt( field, 2, "|" )>
			<cfset state = trim(form[field])>

			<cfif state EQ "Yes">
				<cfset state = 1>
			<cfelseif state EQ "No">
				<cfset state = -1>
			<cfelse>
				<cfset state = 0>
			</cfif>

			<cfif isDefined("objectID")>
				<cfset request.dmSec.oAuthorisation.createPermissionBarnacle(PolicyGroupId=PolicyGroupId,PermissionId=PermissionId,Reference=objectId,status=state)>
			<cfelse>
				<cfset request.dmSec.oAuthorisation.createPermissionBarnacle(PolicyGroupId=PolicyGroupId,PermissionId=PermissionId,Reference=reference1,status=state)>
			</cfif>
		</cfif>

	</cfloop>

	<!--- rewrite the permissions cache file, I think this really can take a long time on huge systems --->	
	<cflock timeout="45" throwontimeout="No" type="READONLY" scope="SERVER">
	<cfif isDefined("server.dmsec.#application.applicationname#.dmSecSCache")>
		<cfwddx action="CFML2WDDX" input="#server.dmsec[application.applicationname].dmSecSCache#" output="temp" usetimezoneinfo="No">
	<cfelse>
		<cfset temp="">
	</cfif>
	</cflock>
	<cffile action="WRITE" file="#application.path.project#/permissionCache.wddx" output="#temp#">
	<cfset completionMessage = completionMessage & application.adminBundle[session.dmProfile.locale].reallyComplete>
	<cfset application.factory.oaudit.logActivity(auditType="dmsec.UpdateSecurityPolicy", username=session.dmprofile.username, location=cgi.remote_host, note="Policy Group [#displayPolicyGroupName#] Permissions Updated")>
</cfif>

<cfif isDefined("url.objectId")>
	<q4:contentobjectGet objectId="#url.objectId#" r_stObject="stobj">
	<cfset typename = stObj.typename>
	<cfif NOT isstruct(stobj) OR StructIsEmpty(stobj)>
		<cfset fatalErrorMessage = application.adminBundle[session.dmProfile.locale].objNotExists>
	<cfelse>
		<cfset stObjectPermissions = oAuthorisation.collateObjectPermissions(objectid=url.objectid,bUseCache=0)>
	</cfif>
<cfelse>
	<cfset typeName=reference1>
	<cfset stObj.label=reference1>
	<cfset stObjectPermissions = oAuthorisation.getObjectPermission(reference=reference1,bUseCache=0)>	
</cfif>

<!--- set up the permissions translation table ---> 
<cfset aPermissions = oAuthorisation.getAllPermissions(permissionType=typename)>
<cfset stPermissions=StructNew()>
<cfloop index="i" from="1" to="#arrayLen(aPermissions)#">
	<cfset stPermissions[aPermissions[i].permissionId]=aPermissions[i].permissionName>
</cfloop>
<cfset lPermissionIds = oAuthorisation.arrayKeyToList(key="permissionID",array=aPermissions)>

<!--- set up the permissions translation table ---> 
<cfset aPermissions = oAuthorisation.getAllPermissions(permissionType=typename)>
<cfset stPermissions = StructNew()>
<cfloop from="1" to="#arrayLen(aPermissions)#" index="i">
	<cfset stPermissions[aPermissions[i].permissionId] = aPermissions[i].permissionName>
</cfloop>
<cfset lPermissionIds = oAuthorisation.arrayKeyToList(key="permissionID",array=aPermissions)>
<cfset aPolicyGroups = oAuthorisation.getAllPolicyGroups()>
<cfset lPolicyGroupIds = oAuthentication.arrayKeyToList(array=aPolicyGroups,key='policyGroupId')>

<!--- check permissions --->
<cfset iState = oAuthorisation.checkPermission(permissionName="ModifyPermissions",reference="PolicyGroup")>
<cfif iState neq 1>
	<cfset fatalErrorMessage = application.adminBundle[session.dmProfile.locale].noManagePermission>
</cfif>

<!--- set the default selected category when first enter page --->
<cfif selectedPolicyGroupID EQ 0>
	<cfset selectedPolicyGroupID = aPolicyGroups[1].policyGroupID>
</cfif>

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
<cfoutput>
<script type="text/javascript">
var lpolicyGroupID = "#lPolicyGroupIds#";
var aPolicyGroupID = lpolicyGroupID.split(",");

function tglPermissions(objSelect){
	pgid = objSelect.options[objSelect.selectedIndex].value;
	for(i=0;i<aPolicyGroupID.length;i++){
		objTgl = document.getElementById("tglpermission_" + aPolicyGroupID[i]);
		
		if(pgid == aPolicyGroupID[i])
			objTgl.style.display = "inline";				
		else
			objTgl.style.display = "none";
	}
}

function updateStateValue(changeValue)
{
	objItem = document.getElementById("_" + changeValue);
	objItemDisplay = document.getElementById("_" + changeValue + "_display");

	if(objItem.value == "Yes"){
		objItem.value = "No";
		objItemDisplay.className = "error";
	}
	else {
		objItem.value = "Yes";
		objItemDisplay.className = "success";
	}

	objItemDisplay.innerHTML = objItem.value;

	return false;
}

</script>
<cfif fatalErrorMessage NEQ "">
		<span class="error">#fatalErrorMessage#</span>
<cfelse>
	<cfif errorMessage NEQ "">
		<span class="error">#errorMessage#</span>
	<cfelseif completionMessage	NEQ "">
		#completionMessage#
	</cfif>
	<form name="frm" method="post" class="f-wrap-1 f-bg-short wider" action="#cgi.script_name#">	
		<fieldset>		
			<h3>#application.adminBundle[session.dmProfile.locale].permissionsOn# #stObj.label# <small class="highlight">(#typename#)</small></h3>
			<label for="selectedPolicyGroupID">
			<b>Switch policy groups:</b>
			<select id="selectedPolicyGroupID" name="selectedPolicyGroupID" onchange="tglPermissions(this);"><cfloop index="i" from="1" to="#ArrayLen(aPolicyGroups)#">
				<option value="#aPolicyGroups[i].policyGroupID#"<cfif selectedPolicyGroupID EQ aPolicyGroups[i].policyGroupID> selected="selected"</cfif>>#aPolicyGroups[i].policyGroupname#</option></cfloop>
			</select>
			<br />
			</label>

			<div class="f-submit-wrap">
			<input type="submit" name="Submit" value="Update" class="f-submit" />
			</div>		
		
				<cfloop index="policyGroupId" list="#lPolicyGroupIds#"><cfset iCounter = 0>
		<cfif NOT structKeyExists(stObjectPermissions, policyGroupId )><cfset stObjectPermissions[policyGroupId] = structnew()></cfif>
			<table class="table-4" cellspacing="0" id="tglpermission_#policyGroupId#" style="display:<cfif policyGroupId EQ selectedPolicyGroupID>block;<cfelse>none;</cfif>">
				<tr>
				<th scope="col">#application.adminBundle[session.dmProfile.locale].permission#</th>	
				<th scope="col">#application.adminBundle[session.dmProfile.locale].state#</th><cfif isDefined("url.objectId")>
				<th scope="col">#application.adminBundle[session.dmProfile.locale].inherited#</th></cfif>
				</tr><cfloop index="permissionId" list="#lPermissionIds#"><cfset iCounter = iCounter + 1>
		<cfif NOT structKeyExists(stObjectPermissions[policyGroupId], permissionId)>
			<cfset stObjectPermissions[PolicyGroupId][permissionId]=structnew()>
			<cfset stObjectPermissions[PolicyGroupId][permissionId].A = 0 >
			<cfset stObjectPermissions[PolicyGroupId][permissionId].I = 0 >
			<cfset stObjectPermissions[PolicyGroupId][permissionId].T = 0 >
		</cfif>
				<tr<cfif iCounter MOD 2> class="alt"</cfif>>
				<th scope="row" class="alt">#stPermissions[PermissionId]#</th>
				<td><span class="switch">(<a href="##" onclick="return updateStateValue('#policyGroupId#|#permissionId#');">change</a>)</span>
				<span class="<cfif stObjectPermissions[PolicyGroupId][PermissionId].A EQ 1>success<cfelse>error</cfif>" id="_#policyGroupId#|#permissionId#_display">#returnDisplayState(stObjectPermissions[PolicyGroupId][PermissionId].A)#</span>
				</td><cfif isDefined("url.objectId")>
				<td>#returnDisplayState(stObjectPermissions[PolicyGroupId][PermissionId].I)#</td></cfif>
				</tr>
				<input type="hidden" id="_#policyGroupId#|#permissionId#" name="_#policyGroupId#|#permissionId#" value="#returnDisplayState(stObjectPermissions[PolicyGroupId][PermissionId].A)#" />
				</cfloop>
			</table></cfloop>
			
		<input type="hidden" name="reference1" value="#reference1#" />
	
		</fieldset>
	</form>
</cfif></cfoutput>

<cffunction name="returnDisplayState" returntype="string">
	<cfargument name="stateValue" type="numeric" required="true">
	
	<cfset returnValue = "Yes">
	<cfif arguments.stateValue EQ -1>
		<cfset returnValue = "No">
	<cfelseif arguments.stateValue EQ 0 AND isDefined("url.objectId")>
		<cfset returnValue = "Inherit">
	<cfelseif arguments.stateValue EQ 0 AND NOT isDefined("url.objectId")>
		<cfset returnValue = "No">
	</cfif>

	<cfreturn returnValue>
</cffunction>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="false">