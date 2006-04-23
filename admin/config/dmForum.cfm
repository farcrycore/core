<cfscript>
	aPolicyGroup = request.dmsec.oAuthorisation.getAllPolicyGroups();
</cfscript>

<cfif isDefined("form.submit")>
	<cfparam name="form.lPolicyGroupIds" default="1"> <!--- Sysadmin should always be able to administer forums --->
	<cfscript>
		st = structNew();
		st.lPolicyGroupIds = form.lPolicyGroupIds;
		application.config.Forum.lPolicyGroupIds = form.lPolicyGroupIds;
	</cfscript>
	<cfoutput>
		<strong>Update complete</strong><br/>
	</cfoutput>
<cfelse>
	<cfoutput>
	<form action="" method="post">
	<table>
		<tr>
			<td valign="top">
			Forum Administrators :
			</td>
			<td>
			<select name="lPolicyGroupIds" size="3" multiple>
			<cfloop index="i" from="1" to="#arrayLen(aPolicyGroup)#">
				<option value="#aPolicyGroup[i].policyGroupId#" <cfif listFindNoCase(application.config.Forum.lPolicyGroupIds,aPolicyGroup[i].policyGroupId)>selected</cfif>>#aPolicyGroup[i].policyGroupName#</option>
			</cfloop>
			</select>
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center">
				<input type="Submit" name="submit" value="update">
			</td>
		</tr>
	</table>	
	</form>
	</cfoutput>
</cfif>
