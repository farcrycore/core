<cfset policyGroups = "">

<!--- get parent object type --->
<cfset searchList = "dmNavigation,dmHTML">
<cfset loop = true>
<cfset listIndex = 1>
<cfset objectTest = stArgs.objectid>
<!--- loop until found parent/searched all tables in searchlist --->
<cfloop condition="loop">
		
	<cfquery name="qGetParent" datasource="#application.dsn#">
		SELECT * FROM #listGetAt(searchlist,listIndex)#_aObjectIds 
		WHERE data = '#objectTest#'	
	</cfquery>
						
	<cfif qGetParent.recordCount GT 0>
		<cfset loop = false>
	</cfif>
	<cfif listIndex IS listLen(searchList)>
		<cfset loop = false>
	</cfif> 
	
	<!--- check parent object type --->
	<cfinvoke component="farcry.packages.types.types" method="findType" returnvariable="parentType">
		<cfinvokeargument name="objectid" value="#qGetParent.objectid#"/>
	</cfinvoke>
	
	<!--- check parent type is a nav node --->
	<cfif parentType eq 'dmNavigation'>
		<cfset loop = false>
		<cfset parentObject = qGetParent.objectid>
							
		<!--- Get policy groups for that object --->
		<cf_dmSec2_ObjectPermissionCollate objectid="#parentObject#" r_stObjectPermissions="stObjectPermissions">
		
		<!--- Check policy groups can approve (T=1) --->
		<cfloop collection="#stObjectPermissions#" item="policyGroupId">
			<cfloop collection="#stObjectPermissions[policyGroupId]#" item="permissionName">
				<cfif stObjectPermissions[policyGroupId][permissionName].T eq 1>
													
					<!--- add to list of policyGroups allowed to approve pending object if not already entered --->
					<cfif listfind(policyGroups,policyGroupId) eq 0>			
						<cfset policyGroups = listappend(policyGroups,policyGroupId)>
					</cfif>
									
				</cfif>	
			</cfloop>
		</cfloop>
		
	<cfelse>
		<!--- move one level up tree looking for nav parent --->
		<cfset objectTest = qGetParent.objectID>
	</cfif>
	<cfset listIndex = listIndex + 1>
</cfloop>

<!--- Get all groups mapped to policy groups --->
<cfquery name="qGetGroups" datasource="#application.dsn#">
	SELECT distinct(dmGroup.groupId)
	FROM dmExternalGroupToPolicyGroup, dmGroup
	WHERE dmExternalGroupToPolicyGroup.policyGroupId in (#policyGroups#)
		and dmGroup.groupName = dmExternalGroupToPolicyGroup.ExternalGroupName
</cfquery>

<!--- Check if logged-in user is in groups that can approve --->
<cfquery name="qGetUsers" datasource="#application.dsn#">
	SELECT dmUser.userid,dmUser.userlogin, dmUser.userEmail
	FROM dmUserToGroup, dmUser
	WHERE dmUserToGroup.GroupId in (#quotedvaluelist(qGetGroups.groupId)#)
		and dmUserToGroup.UserID = dmUser.UserId
	order by userlogin
</cfquery>