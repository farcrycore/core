<cfsetting enablecfoutputonly="Yes">
<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">
<cfscript>
	oAuthorisation = request.dmsec.oAuthorisation;
	oAuthentication = request.dmsec.oAuthentication;
</cfscript>

<cfif isDefined("form.submit")>
	<cfscript>
		//create the new Policy Group
		writeoutput("Creating new Policy Group...");
		flush();
		typeName = "PolicyGroup";
		stResult=oAuthorisation.createPolicyGroup(policyGroupName=form.policyGroupName,policyGroupNotes=form.policyGroupNotes);
		if (stResult.bSuccess){
			writeoutput("<span style='color:green;'>done</span><br>");
			writeoutput("Copying Permissions Barnacle from source Policy Group...");
			flush();
			stObj = oAuthorisation.getPolicyGroup(policyGroupName=form.PolicyGroupName);
			//copy the permissions from the source Policy Group into the new Policy Group
			stObjectPermissions = oAuthorisation.getObjectPermission(reference='policyGroup');
			stPolicyGroupPermissions = stObjectPermissions[form.selectGroup];
			for(iPermissionId in stPolicyGroupPermissions){
				oAuthorisation.createPermissionBarnacle(PolicyGroupId=stObj.policyGroupId,PermissionId=iPermissionId,Reference=typeName,status=stPolicyGroupPermissions[iPermissionId].A);				
			}
			writeoutput("<span style='color:green;'>done</span><br>");
			flush();
			writeoutput("Updating Permissions Cache...");
			oAuthorisation.updateObjectPermissionCache(reference=typeName);
			flush();
			writeoutput("<span style='color:green;'>done</span><br>");
			flush();
		}
		else{
			writeoutput("<span style='color:red;'>Error:</span> " & stResult.message & "<p></p>");
			flush();
		}
	</cfscript>
	<cfif stResult.bSuccess>
		<cfoutput>Rebuilding Permissions cache file...</cfoutput><cfflush>
		<cflock timeout="45" throwontimeout="No" type="READONLY" scope="SERVER">
			<cfif isDefined("server.dmsec.#application.applicationname#.dmSecSCache")>
				<cfwddx action="CFML2WDDX" input="#server.dmsec[application.applicationname].dmSecSCache#" output="temp" usetimezoneinfo="No">
			<cfelse>
				<cfset temp="">
			</cfif>
		</cflock>
		<cffile action="WRITE" file="#application.path.project#/permissionCache.wddx" output="#temp#">
		<cfoutput><span style="color:green;">done</span><br></cfoutput>
		<cfoutput>** Complete! **<p></p></cfoutput><cfflush>
	</cfif>
</cfif>


<cfscript>
	aPolicyGroups = oAuthorisation.getAllPolicyGroups();
	lPolicyGroupIds = oAuthentication.arrayKeyToList(array=aPolicyGroups,key='policyGroupId');
</cfscript>

<!--- <cfdump var="#stObjectPermissions#"> --->

<cfoutput><span class="formtitle">COPY POLICY GROUP</span><p></p></cfoutput>
<cfoutput>
<form action="" method="POST">
	<table class="formtable">
		<tr>
			<td rowspan="10">&nbsp;</td>
		</tr>
		<tr>
        	<td>
				<span class="formlabel">Source Policy Group:&nbsp;</span>
				<select name="selectGroup"></cfoutput>
				<cfloop index="PolicyGroupId" list="#lPolicyGroupIds#">
					<cfscript>
						stPG=oAuthorisation.getPolicyGroup(policyGroupId=policyGroupId);
					</cfscript>
					<cfoutput><option value="#PolicyGroupId#">#stPG.policyGroupName# </cfoutput>
				</cfloop>
				<cfoutput></select>
        	</td>
        </tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>
				<span class="formlabel">New Policy Group Name:</span><br>
				<input type="text" size="32" maxsize="32" name="PolicyGroupName" value="">	
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>
				<span class="formlabel">New Policy Group Notes:</span><br>
				<Textarea name="PolicyGroupNotes" cols="40" rows="4"></textarea>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>
				<input type="submit" name="Submit" value="Copy Policy Group"><br>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
	</table>
	
</form>

</cfoutput>
<cfsetting enablecfoutputonly="No">
