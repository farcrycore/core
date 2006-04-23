<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/tags/navajo/" prefix="nj">


<cf_dmSec2_PermissionCheck permissionName="ModifyPermissions" reference1="PolicyGroup" r_iState="iState">

<cfif iState neq 1>
	<cfoutput>
		<b>You don't have permission to manage permissions.</b>
	</cfoutput>
	<cfabort>
</cfif>

<cfoutput>
<html>
<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">

<body onLoad="window.focus();">

<!-- <style>
	body { font-size:11px; margin:20 20 20 20;}
	table, input, select, textarea { font-size:11px; }
	body { background-color: ##F0F8FF; }
	a { color: ##000044; text-decoration : none; }
</style> -->
</cfoutput>

<cfif not isDefined("form.submit")>

<cfif isDefined("url.objectId")>
	<q4:contentobjectGet objectId="#url.objectId#" r_stObject="stobj">
	<!--- <cfdump var="#stObj#"> --->
	<cfscript>
		typename = stObj.typename;
	</cfscript>
	
	<cfif not isstruct(stobj) OR StructIsEmpty(stobj)>
	<cfoutput>Object no longer exists</cfoutput>
	<cfaborT>
	</cfif>
	
	<!--- get the objects type, so we can get it's name --->
	
	<cfif isDefined("url.overideType")>
		<cf_dmSec2_ObjectPermissionCollate objectid="#url.objectId#" overideType="#url.overideType#" r_stObjectPermissions="stObjectPermissions">
	<cfelse>
		<cf_dmSec2_ObjectPermissionCollate objectid="#url.objectId#" r_stObjectPermissions="stObjectPermissions">
	</cfif>
<cfelse>
	<cfset typeName=url.reference1>
	<cfset stObj.label=url.reference1>
	
	<cf_dmSec_ObjectPermission reference1="#url.reference1#" r_stObjectPermissions="stObjectPermissions">
</cfif>

<!--- set up the permissions translation table --->
<cf_dmSec_PermissionGetMultiple r_aPermissions="aPermissions" type="#typeName#">

<cfset stPermissions=StructNew()>
<cfloop index="i" from="1" to="#arrayLen(aPermissions)#">
	<cfset stPermissions[aPermissions[i].permissionId]=aPermissions[i].permissionName>
</cfloop>

<cf_dmSec_arrayToList array="#aPermissions#" key="permissionId" r_list="lPermissionIds">

<cfoutput>
<span class="formtitle">Permissions on #stObj.label#(#typeName#)</span><p>

<!--- gets all the groups ie siteadmin,sysadmin etc --->
<cf_dmsec_PolicyGroupGetMultiple r_aPolicyGroups="aPolicyGroups">
<!--- <cfdump var="#aPolicyGroups#"> --->
<cf_dmSec_arrayToList array="#aPolicyGroups#" key="policyGroupId" r_list="lPolicyGroupIds">

<script>

	function t(nm)
	{   
		var el=event.srcElement;
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
		
		document.all[nm].value=el.value;
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
		el.style.display="none";
		
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
	
	<span class="formlabel">Policy Group:&nbsp;</span>
	<select name="selectGroup" onChange="selectPolicyGroup(this.options[this.selectedIndex].value)"></cfoutput>
	<cfloop index="PolicyGroupId" list="#lPolicyGroupIds#">
		<cf_dmSec_PolicyGroupGet policyGroupId="#PolicyGroupId#" r_stPolicyGroup="stPG">
		<cfoutput><option value="#PolicyGroupId#">#stPG.policyGroupName# </cfoutput>
	</cfloop>
	<cfoutput></select>
	
	&nbsp;
	
	<input type="Submit" name="Submit" value="Update">
	<br>
	<br>
	
	<cfset isFirst=1>
	
	<cfloop index="PolicyGroupId" list="#lPolicyGroupIds#">
	
	<div id="#PolicyGroupId#" style="display: <cfif isFirst>inline<cfelse>none</cfif>;">
	<p>

	<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
	<tr class="dataheader">
		<td>Permission</td>
		<td>State</td>
		<cfif isDefined("url.objectId")>
			<td>Inherited</td>
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
		<td align="center"><input type="Button" value="#ct(stObjectPermissions[PolicyGroupId][PermissionId].A)#" onclick="t('_#PolicyGroupId#|#PermissionId#');"></td>
		<input type="hidden" name="_#PolicyGroupId#|#PermissionId#" value="#ct(stObjectPermissions[PolicyGroupId][PermissionId].A)#">
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
	<cfoutput>Update Permissions</cfoutput>
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
			</cfscript>

			<cfif isDefined("url.objectId")>
			
				<cf_dmSec_PermissionBarnacleCreate
					PolicyGroupId="#PolicyGroupId#"
					PermissionId="#PermissionId#"
					Reference1="#url.objectId#"
					state="#State#">
			<cfelse>
				<cf_dmSec_PermissionBarnacleCreate
					PolicyGroupId="#PolicyGroupId#"
					PermissionId="#PermissionId#"
					Reference1="#url.reference1#"
					state="#State#">
				
			</cfif>
					
		</cfif>
		
		<cfoutput>.</cfoutput><cfflush>
	</cfloop>
	
	<!--- update the cache --->
	<cfoutput><br><br>Updating Permission Cache (This may take a moment)</cfoutput>
	<cfflush>
	
	<cfif isDefined("url.objectId")>
		<cf_dmSec_ObjectPermissionCacheUpdate objectId="#url.objectId#">
	<cfelse>
		<cf_dmSec_ObjectPermissionCacheUpdate reference1="#url.reference1#">
	</cfif>
	
	<!--- rewrite the permissions cache file, I think this really can take a long time on huge systems --->	
	<cflock timeout="45" throwontimeout="No" type="READONLY" scope="SERVER">
	<cfif isDefined("server.dmsec.#application.applicationname#.dmSecSCache")>
		<cfwddx action="CFML2WDDX" input="#server.dmsec[application.applicationname].dmSecSCache#" output="temp" usetimezoneinfo="No">
	<cfelse>
		<cfset temp="">
	</cfif>
	</cflock>
	<cffile action="WRITE" file="#application.path.project#/permissionCache.wddx" output="#temp#">
	
	<cfoutput><br><br>** Complete! **</cfoutput><cfflush>
	
	<cfoutput>
		<cfif isDefined("url.objectId")>
			
				<nj:updateTree objectId="#url.objectId#">

		<cfelse>
			<!--- <script>
			if( parent && parent.treeFrame ) parent.treeFrame.location.reload();
				else window.opener.location.reload();
			</script> --->
		</cfif>
		
		<!--- <script>
		if( !(parent && parent.treeFrame) ) window.close();
		</script> --->
	</cfoutput>

</cfif>

<cfoutput>
</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="No">