<cfsetting enablecfoutputonly="Yes" requesttimeout="240">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">


<cfscript>
oAuthorisation = request.dmsec.oAuthorisation;
oAuthentication = request.dmsec.oAuthentication;
iState = oAuthorisation.checkPermission(permissionName="ModifyPermissions",reference="PolicyGroup");	
</cfscript>


<cfif iState neq 1>
	<cfoutput>
		<b>#application.adminBundle[session.dmProfile.locale].noManagePermission#</b>
	</cfoutput>
	<cfabort>
</cfif>

<cfoutput>
<html dir="#session.writingDir#" lang="#session.userLanguage#">
<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">

<body onLoad="window.focus();">

</cfoutput>

<cfif not isDefined("form.submit")>

<cfif isDefined("url.objectId")>
	<q4:contentobjectGet objectId="#url.objectId#" r_stObject="stobj">
	<!--- <cfdump var="#stObj#"> --->
	<cfscript>
		typename = stObj.typename;
	</cfscript>
	
	<cfif not isstruct(stobj) OR StructIsEmpty(stobj)>
	<cfoutput>#application.adminBundle[session.dmProfile.locale].objNotExists#</cfoutput>
	<cfaborT>
	</cfif>
	
	<!--- get the objects type, so we can get it's name --->
	<cfscript>
		stObjectPermissions = oAuthorisation.collateObjectPermissions(objectid=url.objectid);
	</cfscript>
	
<cfelse>
	<cfset typeName=url.reference1>
	<cfset stObj.label=url.reference1>
	<cfscript>
		stObjectPermissions = oAuthorisation.getObjectPermission(reference=url.reference1);
	</cfscript>
	

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

<cfoutput>
<span class="formtitle">#application.adminBundle[session.dmProfile.locale].permissionsOn# #stObj.label#(#typeName#)</span><p>

<cfscript>
// gets all the groups ie siteadmin,sysadmin etc 
aPolicyGroups = oAuthorisation.getAllPolicyGroups();
lPolicyGroupIds = oAuthentication.arrayKeyToList(array=aPolicyGroups,key='policyGroupId');
</cfscript>

<script>
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

	<cfif len(StructKeyList(stObjectPermissions))>
		selectedDiv="#ListGetAt(lPolicyGroupIds,1)#";
	</cfif>
	
	function selectPolicyGroup( policyGroup )
	{

		el = document.getElementById(selectedDiv);
		el.style.display='none';
		
		el = document.getElementById(policyGroup);
		el.style.display="inline";
		
		selectedDiv = policyGroup;
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
	<form action="" method="POST">
	
	<span class="formlabel">#application.adminBundle[session.dmProfile.locale].policyGroupLabel#&nbsp;</span>
	<select name="selectGroup" onChange="selectPolicyGroup(this.options[this.selectedIndex].value)"></cfoutput>
	<cfloop index="PolicyGroupId" list="#lPolicyGroupIds#">
		<cfscript>
			stPG=oAuthorisation.getPolicyGroup(policyGroupId=policyGroupId);
		</cfscript>
		<cfoutput><option value="#PolicyGroupId#">#stPG.policyGroupName# </cfoutput>
	</cfloop>
	<cfoutput></select>
	
	&nbsp;
	
	<input type="Submit" name="Submit" value="#application.adminBundle[session.dmProfile.locale].UpdateLC#">
	<br>
	<br>
	
	<cfset isFirst=1>
	
	<cfloop index="PolicyGroupId" list="#lPolicyGroupIds#">
	
	<div  id="#PolicyGroupId#" style="display: <cfif isFirst>inline<cfelse>none</cfif>;">
	
	<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
	<tr class="dataheader">
		<td>#application.adminBundle[session.dmProfile.locale].permission#</td>
		<td>#application.adminBundle[session.dmProfile.locale].state#</td>
		<cfif isDefined("url.objectId")>
			<td>#application.adminBundle[session.dmProfile.locale].inherited#</td>
		</cfif>
	</tr>
	
<cfloop index="PermissionId" list="#lPermissionIds#">

	<cfif not structKeyExists( stObjectPermissions, PolicyGroupId )><cfset stObjectPermissions[PolicyGroupId]=structnew()></cfif>
	<cfif not structKeyExists( stObjectPermissions[PolicyGroupId], permissionId )>
		
		<cfset stObjectPermissions[PolicyGroupId][permissionId]=structnew()>
		<cfset stObjectPermissions[PolicyGroupId][permissionId].A = 0 >
		<cfset stObjectPermissions[PolicyGroupId][permissionId].I = 0 >
		<cfset stObjectPermissions[PolicyGroupId][permissionId].T = 0 >
	</cfif>
		
	<tr class="#IIF(i MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
		<Td>#stPermissions[PermissionId]#</td>
		<td align="center"><input type="Button" value="#ct(stObjectPermissions[PolicyGroupId][PermissionId].A)#" onclick="t('_#PolicyGroupId#|#PermissionId#',event);"></td>
		<input type="hidden" id="_#PolicyGroupId#|#PermissionId#" name="_#PolicyGroupId#|#PermissionId#" value="#ct(stObjectPermissions[PolicyGroupId][PermissionId].A)#">
		<cfif isDefined("url.objectId")>
			<td>#ct(stObjectPermissions[PolicyGroupId][PermissionId].I)#</td>
		</cfif>
	</tr>
</cfloop>
	
	</table>
	
	</div>

	<cfset isFirst=0>
		
	</cfloop>
	
	</form>

</cfoutput>

<cfelse>
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
	
	<!--- update the cache --->
	<cfoutput><br><br>#application.adminBundle[session.dmProfile.locale].updatingPermissionsCache#</cfoutput>
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
	
	<cfoutput><br><br>#application.adminBundle[session.dmProfile.locale].reallyComplete#</cfoutput><cfflush>
	
	<cfoutput>
		<cfif isDefined("url.objectId")>
			
				<nj:updateTree objectId="#url.objectId#">

		<cfelse>
			<script>
			if( parent && parent.frames['treeFrame'] ) parent.frames['treeFrame'].location.reload();
			
			</script>
		</cfif>
		

	</cfoutput>

</cfif>

<cfoutput>
</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="No">