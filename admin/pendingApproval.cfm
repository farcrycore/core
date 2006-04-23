<!--- initialize structure --->
<cfset stPendingObjects = structNew()>

<!--- Get all objects types that have status option --->
<cfloop collection="#application.types#" item="i">
	<cfif structkeyexists(application.types[i].stProps,"status")>
	
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
				<cfset searchList = "dmNavigation,dmHTML">
				<cfset loop = true>
				<cfset listIndex = 1>
				<cfset objectTest = objectid>
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
					SELECT dmUser.userid,dmUser.userlogin 
					FROM dmUserToGroup, dmUser
					WHERE dmUserToGroup.GroupId in (#quotedvaluelist(qGetGroups.groupId)#)
						and dmUserToGroup.UserID = dmUser.UserId
						and dmUser.userlogin = '#request.stLoggedInUser.userlogin#'
					order by userlogin
				</cfquery>
				
				<!--- Create structure for object details to be outputted later --->
				<cfif qGetUsers.recordcount gt 0>
					<cfset stPendingObjects[qGetObjects.ObjectId] = structNew()>
					<cfset stPendingObjects[qGetObjects.ObjectId]["objectTitle"] = qGetObjects.title>
					<cfset stPendingObjects[qGetObjects.ObjectId]["parentObject"] = parentObject >
					<cfset stPendingObjects[qGetObjects.ObjectId]["objectCreatedBy"] = qGetObjects.createdBy>
					<cfset stPendingObjects[qGetObjects.ObjectId]["objectCreatedByEmail"] = qGetObjects.userEmail>
					<cfset stPendingObjects[qGetObjects.ObjectId]["objectLastUpdate"] = qGetObjects.dateTimeLastUpdated>
				</cfif>
			</cfloop>
		</cfif>
	</cfif>
</cfloop>

<span class="formTitle">Objects Pending Your Approval</span>
<!--- display pending objects that user has approval rights for --->
<table cellpadding="5" cellspacing="0" border="1" style="margin-left:0px;margin-top:10px">
<tr class="dataheader">
	<td>Object</td>
	<td>Created By</td>
	<td>Last Updated</td>
</tr>
<cfloop collection="#stPendingObjects#" item="i">
	<tr class="#IIF(i MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
		<td><span class="frameMenuBullet">&raquo;</span> <cfoutput><a href="index.cfm?section=site&rootobjectid=#stPendingObjects[i]["parentObject"]#">#stPendingObjects[i]["objectTitle"]#</cfoutput></td>
		<td><cfoutput><cfif stPendingObjects[i]["objectCreatedByEmail"] neq "n/a"><a href="mailto:#stPendingObjects[i]["objectCreatedByEmail"]#"></cfif>#stPendingObjects[i]["objectCreatedBy"]#<cfif stPendingObjects[i]["objectCreatedByEmail"] neq "n/a"></a></cfif></cfoutput></td>
		<td><cfoutput>#dateformat(stPendingObjects[i]["objectLastUpdate"],"dd-mmm-yyyy")#</cfoutput></td>
	</tr>
</cfloop>
</table>