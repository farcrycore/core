<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_workflow/getObjectsPendingApproval.cfm,v 1.16 2003/09/11 06:57:57 paul Exp $
$Author: paul $
$Date: 2003/09/11 06:57:57 $
$Name: b201 $
$Revision: 1.16 $

|| DESCRIPTION || 
$Description: get obejcts pending approval$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- initialize structure --->
<cfset stPendingObjects = structNew()>

<!--- Get all objects types that have status option --->
<cfloop collection="#application.types#" item="i">
	<cfif structkeyexists(application.types[i].stProps,"status") and i neq "dmNews">
	
		<!--- Get all objects that have status of pending --->
		<!--- TODO - need to dynamically get versioned object types --->
		<cfif i is "dmHTML">
			<cfset sql = "SELECT objectID, title, createdby, datetimelastUpdated,versionID FROM #application.dbowner##i# WHERE status = 'pending'">
		<cfelse>
			<cfset sql = "SELECT objectID, title, createdby, datetimelastUpdated FROM #application.dbowner##i# WHERE status = 'pending'">	
		</cfif>	

		<cftry>
			<cfquery name="qGetObjects" datasource="#application.dsn#">#preserveSingleQuotes(sql)#</cfquery>
			
			<cfif qGetObjects.recordcount gt 0>
				<!--- Check parent --->
				<cfloop query="qGetObjects">
					<cfset policyGroups = "">
				
					<!--- get parent object type --->
	                <cfif i eq "dmNavigation">
	    				<cfquery name="qGetParent" datasource="#application.dsn#">
		    			SELECT parentID as objectid FROM #application.dbowner#nested_tree_objects
	                    WHERE objectID = '#objectid#'
					    </cfquery>
	                    <cfset parentID = qGetParent.objectID>
					 <cfelseif i is "dmHTML">
	    				<cfquery name="qGetParent" datasource="#application.dsn#">
		    			SELECT objectid FROM #application.dbowner#dmNavigation_aObjectIDs
						<cfif len(qGetObjects.versionID) GT 0>
							WHERE data = '#versionid#'
						<cfelse>
		                    WHERE data = '#objectid#'
						</cfif>
					    </cfquery>
	                    <cfset parentID = qGetParent.objectID>	
	                <cfelse>
	    				<cfquery name="qGetParent" datasource="#application.dsn#">
		    			SELECT objectid FROM #application.dbowner#dmNavigation_aObjectIDs
			        	WHERE data = '#objectId#'	
					    </cfquery>
	                    <cfset parentID = qGetParent.objectID>
	                    <cfif parentID eq ""><cfset parentID = objectID></cfif>
	                </cfif>
												
	       			<!--- Get policy groups for that object --->
					<cfscript>
						stObjectPermissions = request.dmsec.oAuthorisation.collateObjectPermissions(objectid=parentid);
					</cfscript>
	
	        		<!--- Check policy groups can approve --->
	        		<cfloop collection="#stObjectPermissions#" item="policyGroupID">
			        	<cfif stObjectPermissions[policyGroupID][application.permission.dmNavigation.Approve.permissionID].T eq 1>
					        <!--- add to list of policy groups allowed to approve pending object if not already entered --->
	        				<cfif listFind(policyGroups, policyGroupID) eq 0>
			        			<cfset policyGroups = listAppend(policyGroups, policyGroupID)>
					        </cfif>
	        			</cfif>	
			        </cfloop>
	
	                <cfset bCanApprove = "false">
	                <cfloop list="#session.dmSec.authentication.lPolicyGroupIDs#" index="pgID">
	                    <cfif listFindNoCase(policyGroups, pgID)>
	                        <cfset bCanApprove = "true">
	                        <cfbreak>
	                    </cfif>
	                </cfloop>
	
					<!--- Create structure for object details to be outputted later --->
					<cfif bCanApprove>
	                    <cfscript>
	                    o_profile = createObject("component", "#application.packagepath#.types.dmProfile");
	                    stProfile = o_profile.getProfile(userName=qGetObjects.createdBy);
	
						stPendingObjects[qGetObjects.objectID] = structNew();
						stPendingObjects[qGetObjects.objectID]["objectTitle"] = qGetObjects.title;
						stPendingObjects[qGetObjects.objectID]["parentObject"] = qGetParent.objectID;
						stPendingObjects[qGetObjects.objectID]["objectCreatedBy"] = qGetObjects.createdBy;
						stPendingObjects[qGetObjects.objectID]["objectCreatedByEmail"] = stProfile.emailAddress;
						stPendingObjects[qGetObjects.objectID]["objectLastUpdate"] = qGetObjects.dateTimeLastUpdated;
	                    </cfscript>
	
						<cfif i is "dmHTML">
							<!--- We check for drafts --->
							<cfquery name="qCheckDraft" datasource="#application.dsn#">
							SELECT * FROM #application.dbowner##i# WHERE versionID = '#qGetObjects.objectID#'
							</cfquery>
							<cfif qCheckDraft.recordcount eq 1>
								<cfscript>
								stPendingObjects[qCheckDraft.objectID] = structNew();
							 	stPendingObjects[qCheckDraft.objectID]["objectTitle"] = qCheckDraft.title;
								stPendingObjects[qCheckDraft.objectID]["parentObject"] = qGetParent.objectID; 
								stPendingObjects[qCheckDraft.objectID]["objectCreatedBy"] = qGetObjects.createdBy;
								stPendingObjects[qCheckDraft.objectID]["objectCreatedByEmail"] = stProfile.emailAddress;
								stPendingObjects[qCheckDraft.objectID]["objectLastUpdate"] = qGetObjects.dateTimeLastUpdated;
								</cfscript>
							</cfif>
						</cfif>
	
					</cfif>
				</cfloop>
			</cfif>
			<cfcatch>
				<!--- <cfdump var="#cfcatch#"> --->
			</cfcatch>
		</cftry>
	</cfif>
</cfloop>