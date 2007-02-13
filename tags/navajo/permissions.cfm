<cfsetting enablecfoutputonly="Yes" requesttimeout="240">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfparam name="permisssionBarnalceName" default="">

<!--- set up page header --->
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfset oAuthorisation = request.dmsec.oAuthorisation>
<cfset oAuthentication = request.dmsec.oAuthentication>
<cfset isAuthorized = oAuthorisation.checkPermission(permissionName="ModifyPermissions",reference="PolicyGroup")>



<cfif isAuthorized eq 1>

	<!--- Begin handling Form Submit /--->
	<cfif isDefined("form.submit")>
		<cfoutput>#application.adminBundle[session.dmProfile.locale].updatePermission#</cfoutput>
		<cfflush>
		<cfloop index="field" list="#form.fieldnames#">
			<cfif field contains "|">
				<cfset PolicyGroupId = Mid(ListGetAt( field, 1, "|" ),2,len(ListGetAt( field, 1, "|" ))-1 )>
				<cfset PermissionId = ListGetAt( field, 2, "|" )>
				<cfset state = form[field]>
	
				<cfscript>
					if ( state eq "Yes" ) state=1;
					if ( state eq "No" ) state=-1;
					if ( state eq "Inherit" ) state=0;
					if (isDefined("url.objectId"))
						request.dmSec.oAuthorisation.createPermissionBarnacle(PolicyGroupId=PolicyGroupId,PermissionId=PermissionId,Reference=url.objectId,status=state);	
					else
						request.dmSec.oAuthorisation.createPermissionBarnacle(PolicyGroupId=PolicyGroupId,PermissionId=PermissionId,Reference=url.reference1,status=state);	
				</cfscript>
			</cfif>
			
			<cfoutput>.</cfoutput><cfflush>
		</cfloop>
		
		<!--- Put this in the Audit Log --->
		<cfset application.factory.oaudit.logActivity(auditType="dmsec.UpdatePermissionBarnacle", username=session.dmprofile.username, location=cgi.remote_host, note="#permisssionBarnalceName# Permissions Mapping Updated")>
		
		<!--- update the cache --->
		<cfoutput><br>#application.adminBundle[session.dmProfile.locale].updatingPermissionsCache#</cfoutput>
		<cfflush>
		
		<cfscript>
			oAuthorisation = request.dmSec.oAuthorisation;
			if (isDefined("url.objectId"))
				oAuthorisation.updateObjectPermissionCache(objectid=url.objectid);
			else
				oAuthorisation.updateObjectPermissionCache(reference=url.reference1);
		</cfscript>
	
		<!--- rewrite the permissions cache file, I think this really can take a long time on huge systems --->	
		<cflock timeout="45" throwontimeout="No" type="READONLY" scope="SERVER">
			<cfif isDefined("server.dmsec.#application.applicationname#.dmSecSCache")>
				<cfwddx action="CFML2WDDX" input="#server.dmsec[application.applicationname].dmSecSCache#" output="temp" usetimezoneinfo="No">
			<cfelse>
				<cfset temp="">
			</cfif>
		</cflock>
		<cffile action="WRITE" file="#application.path.project#/permissionCache.wddx" output="#temp#">
		
		<cfoutput><br>#application.adminBundle[session.dmProfile.locale].reallyComplete#<br /><br /></cfoutput><cfflush>
		
		<cfif isDefined("url.objectId")>
			<nj:updateTree objectId="#url.objectId#">
		<cfelse>
			<cfoutput>
			<script type="text/javascript" language="javascript">
				if(parent && parent.frames['treeFrame'])
					parent.frames['treeFrame'].location.reload();
			</script>
			</cfoutput>
		</cfif>
	</cfif>
	<!---/ End handling Form Submit --->

	<!--- Begin setup of Permissions UI /--->
	<cfif isDefined("url.objectId")>
		<q4:contentobjectGet objectId="#url.objectId#" r_stObject="stobj">
		<cfset typename = stObj.typename>
		<cfif not isStruct(stobj) OR structIsEmpty(stobj)>
			<cfoutput>#application.adminBundle[session.dmProfile.locale].objNotExists#</cfoutput>
			<cfabort>
		</cfif>
		
		<!--- get the objects type, so we can get it's name --->
		<cfset stObjectPermissions = oAuthorisation.collateObjectPermissions(objectid=url.objectid)>
	<cfelse>
		<cfset typeName = url.reference1>
		<cfset stObj.label = url.reference1>
		<cfset stObjectPermissions = oAuthorisation.getObjectPermission(reference=url.reference1)>
	</cfif>

	<cfscript>
		//set up the permissions translation table 
		aPermissions = oAuthorisation.getAllPermissions(permissionType=typename);
		stPermissions=StructNew();
		for(i=1;i LTE arrayLen(aPermissions);i = i + 1)
		{	
			stPermissions[aPermissions[i].permissionId]=aPermissions[i].permissionName;
		}
		lPermissionIds = oAuthorisation.arrayKeyToList(key="permissionID",array=aPermissions);
	</cfscript>
	
		<!--- Get all the Policy Groups IE siteadmin,sysadmin,contributor etc ---> 
		<cfset aPolicyGroups = oAuthorisation.getAllPolicyGroups()>
		<cfset lPolicyGroupIds = oAuthentication.arrayKeyToList(array=aPolicyGroups,key='policyGroupId')>
		
		<!--- Setup the default Policy Group to display --->
		<cfif isDefined("form.selectGroup") and isNumeric(form.selectGroup)>
			<cfset selectedPolicyGroup = form.selectGroup>
		<cfelse>
			<cfset selectedPolicyGroup = listGetAt(lPolicyGroupIds,1)>
		</cfif>
	<cfoutput>
	<script type="text/javascript">
		var ns6=document.getElementById&&!document.all; //test for ns6
		var ie5=document.getElementById && document.all;//test for ie5
	
		function t(nm,e)
		{   
			var el=ie5?e.srcElement : e.target;
			switch( el.value )
			{
				case "Yes": el.value="No"; break;
				
				<cfif isDefined("url.objectId")>
					case "No": el.value="Inherit"; break;
					case "Inherit": el.value="Yes"; break;
					
				<cfelse>
					case "No": el.value="Yes"; break;
					
				</cfif>
			}
			document.getElementById(nm).value=el.value;
		}
	
		function ct( val )
		{
			
			if ( val==-1 ) return "No";
			<cfif isDefined("url.objectId")>
			if ( val==0 ) return "Inherit";
			<cfelse>
			if ( val==0 ) return "No";
			</cfif>
			if ( val==1 ) return "Yes";
		}
		
		selectedDiv="tglpermission_#selectedPolicyGroup#";
	
		function selectPolicyGroup(policyGroup)
		{
			el = document.getElementById(selectedDiv);
			el.style.display='none';
			
			el = document.getElementById(policyGroup);
			el.style.display='';
			
			selectedDiv = policyGroup;
		}
	
		function doSubmit(objForm)
		{
			objForm.permisssionBarnalceName.value = objForm.selectGroup[objForm.selectGroup.selectedIndex].text + " | #stObj.label#";
			return true;
		}
	</script>
	</cfoutput>
	
	<cfscript>
		function ct( val )
		{
			if ( val eq -1 ) return "No";
			if ( val eq 0 and isDefined("url.objectId")) return "Inherit";
			if ( val eq 0 and not isDefined("url.objectId")) return "No";
			if ( val eq 1 ) return "Yes";
		}
	</cfscript>

	<cfoutput>
	<form action="" name="frm" method="POST" class="f-wrap-1 f-bg-short wider" onsubmit="return doSubmit(document.frm);">
		<fieldset>
			<h3>#application.adminBundle[session.dmProfile.locale].permissionsOn# #stObj.label#(#typeName#)</h3>
			<label for="selectGroup">
				<b>#application.adminBundle[session.dmProfile.locale].policyGroupLabel#&nbsp;</b>
				<select name="selectGroup"  class="formselectlist" onChange="selectPolicyGroup('tglpermission_' + this.options[this.selectedIndex].value)">
				</cfoutput>
				
				<cfloop index="PolicyGroupId" list="#lPolicyGroupIds#">
					<cfscript>
						stPG=oAuthorisation.getPolicyGroup(policyGroupId=policyGroupId);
					</cfscript>
					<cfoutput><option value="#PolicyGroupId#"<cfif PolicyGroupId eq selectedPolicyGroup> selected</cfif>>#stPG.policyGroupName#</option></cfoutput>
				</cfloop>
				
				<cfoutput>
				</select><br />
			</label>
			<input type="hidden" name="permisssionBarnalceName" value="#stObj.label#">
			<div class="f-submit-wrap">
				<input type="Submit" name="Submit" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].UpdateLC#">
			</div>
			</cfoutput>
			
			<cfloop index="PolicyGroupId" list="#lPolicyGroupIds#">
				<cfoutput>
				<table class="table-4" cellspacing="0" id="tglpermission_#policyGroupId#"<cfif PolicyGroupId neq selectedPolicyGroup> style="display: none;"</cfif>>
					<tr>
						<th scope="col">#application.adminBundle[session.dmProfile.locale].permission#</th>
						<th scope="col">#application.adminBundle[session.dmProfile.locale].state#</th>
						</cfoutput>
						<cfif isDefined("url.objectId")>
							<cfoutput><th scope="col">#application.adminBundle[session.dmProfile.locale].inherited#</th></cfoutput>
						</cfif>
						
					<cfoutput>
					</tr>
					</cfoutput>	
					
					<cfloop index="PermissionId" list="#lPermissionIds#">
						<cfif not structKeyExists( stObjectPermissions, PolicyGroupId )>
							<cfset stObjectPermissions[PolicyGroupId]=structnew()>
						</cfif>
						
						<cfif not structKeyExists( stObjectPermissions[PolicyGroupId], permissionId )>
							
							<cfset stObjectPermissions[PolicyGroupId][permissionId]=structnew()>
							<cfset stObjectPermissions[PolicyGroupId][permissionId].A = 0 >
							<cfset stObjectPermissions[PolicyGroupId][permissionId].I = 0 >
							<cfset stObjectPermissions[PolicyGroupId][permissionId].T = 0 >
						</cfif>
	
						<cfoutput>				
						<tr <cfif listFind(lPermissionIds, PermissionId) MOD 2> class="alt"</cfif>>
							<th scope="row" class="alt">#stPermissions[PermissionId]#</th>
							<td align="center">
								<input type="Button" value="#ct(stObjectPermissions[PolicyGroupId][PermissionId].A)#" onclick="t('_#PolicyGroupId#|#PermissionId#',event);">
								<input type="hidden" id="_#PolicyGroupId#|#PermissionId#" name="_#PolicyGroupId#|#PermissionId#" value="#ct(stObjectPermissions[PolicyGroupId][PermissionId].A)#">
							</td>
						</cfoutput>
						
						<cfif isDefined("url.objectId")>
							<cfoutput><td>#ct(stObjectPermissions[PolicyGroupId][PermissionId].I)#</td></cfoutput>
						</cfif>
						
						<cfoutput>
						</tr>
						</cfoutput>
					</cfloop>
		
				<cfoutput>
				</table>
				</cfoutput>
			</cfloop>
	
		<cfoutput>
		</fieldset>
	</form>
	</cfoutput>
<cfelse>
	<!--- Not authorized, display the bad news --->	
	<cfoutput>
		<b>#application.adminBundle[session.dmProfile.locale].noManagePermission#</b>
	</cfoutput>
</cfif>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="false">