<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_workflow/getObjectsPendingApproval.cfm,v 1.22 2003/12/08 05:45:57 paul Exp $
$Author: paul $
$Date: 2003/12/08 05:45:57 $
$Name: milestone_2-2-1 $
$Revision: 1.22 $

|| DESCRIPTION || 
$Description: get obejcts pending approval$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfscript>
//pending objects struct
stPendingObjects = structNew();
oNav = createObject("component",application.types.dmNavigation.typePath);
</cfscript>

<!--- Get all objects types that have status option --->
<cfloop collection="#application.types#" item="i">
	<cfif structkeyexists(application.types[i].stProps,"status") AND structKeyExists(application.types[i],"bUseInTree") AND application.types[i].bUseInTree>
		<!--- Get all objects that have status of pending --->
		<cfif structKeyExists(application.types[i].stProps,"VersionID")>
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
					<cfscript>
					switch(i)
					{
						case "dmNavigation" :
						{
							qParent = request.factory.oTree.getParentID(objectid=qGetObjects.objectid,dsn=application.dsn);
							parentid = qParent.parentID;
							break;
						}
						default :
						{
							if (isDefined("qGetObjects.versionID") AND len(qGetObjects.versionID) EQ 35)
								qParent = oNav.getParent(objectid=qGetObjects.versionid,dsn=application.dsn);
							else
								qParent = oNav.getParent(objectid=qGetObjects.objectid,dsn=application.dsn);	
							if(NOT qParent.recordCount)
								parentid = qGetObjects.objectid;
							else
								parentid = qParent.objectid;	
						}	
					}	
						
					</cfscript>
					
	      			<!--- check permissions --->
					<cfscript>
						bCanApprove = request.dmSec.oAuthorisation.checkInheritedPermission(permissionName="approve",objectid=parentid);	
					</cfscript>
					<!--- Create structure for object details to be outputted later - note object must not be in trash either--->
					<cfif bCanApprove EQ 1 AND NOT parentid is application.navid.rubbish>
	                    <cfscript>
	                    o_profile = createObject("component", application.types.dmProfile.typePath);
	                    stProfile = o_profile.getProfile(userName=qGetObjects.createdBy);
	
						stPendingObjects[qGetObjects.objectID] = structNew();
						stPendingObjects[qGetObjects.objectID]["objectTitle"] = qGetObjects.title;
						stPendingObjects[qGetObjects.objectID]["parentObject"] = parentid;
						stPendingObjects[qGetObjects.objectID]["objectCreatedBy"] = qGetObjects.createdBy;
						stPendingObjects[qGetObjects.objectID]["objectCreatedByEmail"] = stProfile.emailAddress;
						stPendingObjects[qGetObjects.objectID]["objectLastUpdate"] = qGetObjects.dateTimeLastUpdated;
	                    </cfscript>
	
						<cfif structKeyExists(application.types[i].stProps,"VersionID")>
							<!--- We check for drafts --->
							<cfquery name="qCheckDraft" datasource="#application.dsn#">
							SELECT * FROM #application.dbowner##i# WHERE versionID = '#qGetObjects.objectID#'
							</cfquery>
							<cfif qCheckDraft.recordcount eq 1>
								<cfscript>
								stPendingObjects[qCheckDraft.objectID] = structNew();
							 	stPendingObjects[qCheckDraft.objectID]["objectTitle"] = qCheckDraft.title;
								stPendingObjects[qCheckDraft.objectID]["parentObject"] = parentid; 
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