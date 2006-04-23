<!--- initialize structure --->
<cfset stPendingObjects = structNew()>

<!--- Get all objects types that have status option --->
<cfloop collection="#application.types#" item="i">
	<cfif structkeyexists(application.types[i].stProps,"status") and i neq "dmNews">
	
		<!--- Get all objects that have status of pending --->
		<cfquery name="qGetObjects" datasource="#application.dsn#">
			select objectID,title, createdby, datetimelastUpdated, userEmail
			From #i#, dmUser
			WHERE status = 'Pending'
				and dmUser.userLogin = createdby
		</cfquery>
		
		<cfif qGetObjects.recordcount gt 0>
			<!--- Check parent --->
			<cfloop query="qGetObjects">
				<cfset policyGroups = "">
			
				<!--- get parent object type --->
				<cfquery name="qGetParent" datasource="#application.dsn#">
					SELECT objectid FROM dmNavigation_aObjectIds 
					WHERE data = '#objectId#'	
				</cfquery>
											
				<!--- Get policy groups for that object --->
				<cf_dmSec2_ObjectPermissionCollate objectid="#qGetParent.objectid#" r_stObjectPermissions="stObjectPermissions">
				
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
				
				<!--- Get all groups mapped to policy groups --->
				<cfquery name="qGetGroups" datasource="#application.dsn#">
					SELECT distinct(dmGroup.groupId)
					FROM dmExternalGroupToPolicyGroup, dmGroup
					WHERE dmExternalGroupToPolicyGroup.policyGroupId in (#policyGroups#)
						and dmGroup.groupName = dmExternalGroupToPolicyGroup.ExternalGroupName
				</cfquery>
				
				<!--- Check if logged-in user is in groups that can approve --->
				<cfquery name="qGetUsers" datasource="#application.dsn#">
					SELECT dmUser.userid,dmUser.userlogin 
					FROM dmUserToGroup, dmUser
					WHERE dmUserToGroup.GroupId in (#quotedvaluelist(qGetGroups.groupId)#)
						and dmUserToGroup.UserID = dmUser.UserId
						and dmUser.userlogin = '#stArgs.userLogin#'
					order by userlogin
				</cfquery>
				
				<!--- Create structure for object details to be outputted later --->
				<cfif qGetUsers.recordcount gt 0>
					<cfset stPendingObjects[qGetObjects.ObjectId] = structNew()>
					<cfset stPendingObjects[qGetObjects.ObjectId]["objectTitle"] = qGetObjects.title>
					<cfset stPendingObjects[qGetObjects.ObjectId]["parentObject"] = qGetParent.objectid >
					<cfset stPendingObjects[qGetObjects.ObjectId]["objectCreatedBy"] = qGetObjects.createdBy>
					<cfset stPendingObjects[qGetObjects.ObjectId]["objectCreatedByEmail"] = qGetObjects.userEmail>
					<cfset stPendingObjects[qGetObjects.ObjectId]["objectLastUpdate"] = qGetObjects.dateTimeLastUpdated>
				</cfif>
			</cfloop>
		</cfif>
	</cfif>
</cfloop>