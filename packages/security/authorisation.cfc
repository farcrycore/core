<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/security/authorisation.cfc,v 1.52.2.2 2006/04/20 07:40:00 jason Exp $
$Author: jason $
$Date: 2006/04/20 07:40:00 $
$Name: p300_b113 $
$Revision: 1.52.2.2 $

|| DESCRIPTION || 
$Description: authorisation cfc $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayName="Authorisation" hint="User authorisation">
	<cfinclude template="/farcry/core/admin/includes/cfFunctionWrappers.cfm">
	<cfinclude template="/farcry/core/admin/includes/utilityFunctions.cfm">
	<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
	<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">
	
	<cffunction name="collateObjectPermissions" output="No">
		<cfargument name="objectid" required="true">
		<cfargument name="typename" required="false" default="dmNavigation">
			<cfscript>
								
				qAncestors = request.factory.oTree.getAncestors(objectid=arguments.objectid,typename=arguments.typename);
				lObjectIds = valueList(qAncestors.objectID);
				
				aObjectIds=arrayReverse(ListToArray(lObjectIds));
				//including self
				if (arrayLen(aObjectIds))
			        arrayInsertAt(aObjectIds,1,arguments.objectID);
				else {
				 	aObjectIds = arrayNew(1);
					aObjectIds[1] = arguments.objectID;
				}
				
				lUncachedPermissions="";
				for( i=1; i lte arrayLen(aObjectIds); i=i+1 )
				{
					if( not StructKeyExists(server.dmSec[application.applicationname].dmSecSCache, aObjectIds[i]) )
            			lUncachedPermissions = listAppend(lUncachedPermissions, aObjectIds[i]);
				}
				
				if (len(lUncachedPermissions))
					getObjectPermission(lrefs=lUncachedPermissions); //this updates the cache - TODO split getting server cache and update of server cache		

				structCollated = structNew();

				for( i=1; i lte ArrayLen(aObjectIds); i=i+1 )
				{
					stObjectPermissions = server.dmSec[application.applicationname].dmSecSCache[aObjectIds[i]];
					
					if( StructIsEmpty(structCollated) )
					{
						
						structCollated=duplicate(stObjectPermissions);
					}
					else
					{
						// --- generated the inherited keys ---
						for( policyGroupName in stObjectPermissions )
						{
							stPolicyGroup = stObjectPermissions[policyGroupName];
								
							for( permissionName in stPolicyGroup )
							{
								
								// --- check to see if this permission exists in the objects single permissions struct --->
								if( structKeyExists(structCollated,policyGroupName)
									AND structKeyExists(structCollated[policyGroupName],permissionName) )
								{
									stPerNext = structCollated[policyGroupName][permissionName];
									
									if(stPerNext.I eq 0)
									stPerNext.I = stObjectPermissions[policyGroupName][permissionName].A;
									
									if(stPerNext.A neq 0) stPerNext.T = stPerNext.A;
										else stPerNext.T = stPerNext.I;
									
								} else {
									structinsert(structget("structCollated.#policyGroupName#"), permissionName, duplicate(stObjectPermissions[policyGroupName][permissionName]));
								}
							}
							
						}
						
					}
				}
			</cfscript>
			<cfreturn structCollated>
	</cffunction>
	
	
	<cffunction name="createPermissionBarnacle" hint="Creates a permission for a daemon security user context.Only unique permissions will be accepted." output="true" returntype="void">
		<cfargument name="reference" required="true">
		<cfargument name="status" required="true">
		<cfargument name="policygroupID">
		<cfargument name="permissionID" required="false">
		<cfargument name="permissionName" required="false">
		<cfargument name="permissionType" required="false">
		
		<cfset var thePermissionID="" />
		<cfset var stPermission=structNew() />
		
		<cfif (not isDefined('arguments.permissionID') AND isDefined("arguments.PermissionName") AND isDefined("arguments.PermissionType"))>
			<cfset stPermission = getPermission(permissionName=arguments.permissionName,permissionType=arguments.permissionType) />
			<cfif structkeyexists(stpermission, "permissionid")>
				<cfset thePermissionID = stPermission.permissionID />
			<cfelse>
				<cfthrow type="security.authorisation" message="createPermissionBarnacle failed." detail="createPermissionBarnacle failed: no permissionid could be found." />
			</cfif>
		<cfelse>
			<cfset thePermissionID = arguments.permissionid />
		</cfif>
		
		<cfscript>
			if (isDefined("arguments.PolicyGroupName") AND not isDefined('arguments.policygroupid'))
			{
				stPolicyGroup = getPolicyGroup(PolicyGroupName=arguments.PolicyGroupName);
				arguments.PolicyGroupId = stPolicyGroup.PolicyGroupId;
			}
			
			stPolicyStore = getPolicyStore();	
			sql = "
			DELETE FROM #application.dbowner##stPolicyStore.permissionBarnacleTable#
				WHERE permissionId = '#thePermissionId#' 
				AND Reference1 = '#arguments.Reference#'
				AND PolicyGroupId = #arguments.policyGroupId#";
			query(sql=sql,dsn=stPolicyStore.dataSource);	
			
			if(arguments.status NEQ 0)
			{
				sql = "
				INSERT INTO #application.dbowner##stPolicyStore.permissionBarnacleTable# ( permissionId, Reference1, PolicyGroupId, Status )
				VALUES
				('#thePermissionId#','#arguments.reference#','#arguments.PolicyGroupId#','#arguments.status#')";
				query(sql=sql,dsn=stPolicyStore.dataSource);
			}	
		</cfscript>
		
	</cffunction>
	
	<cffunction name="deletePermissionBarnacle" hint="Deletes a permission for a daemon security user context" output="No">
		<cfargument name="objectid" type="UUID" required="true">
		
		<cfscript>
			stPolicyStore = getPolicyStore();	
			
			sql = "
			DELETE FROM #application.dbowner##stPolicyStore.permissionBarnacleTable#
				WHERE Reference1 = '#arguments.objectid#'";
			query(sql=sql,dsn=stPolicyStore.dataSource);	
		</cfscript>
		
	</cffunction>
	
	<cffunction name="checkPermission" hint="Checks whether you have permission to perform an action on an object. Note: A positive permission from one group overides a negative permission from another group, i.e. they are permissive(heh!)." output="No">
		<cfargument name="permissionName" required="true">
		<cfargument name="reference">
		<cfargument name="objectID">
		<cfargument name="lPolicyGroupIDs">
				
		<cfscript>
			//oAuthentication = createObject("component","#application.securitypackagepath#.authentication");
			oAuthentication =request.dmsec.oAuthentication;
			if (not isDefined("arguments.lPolicyGroupIds"))
			{
				stLoggedInUser = oAuthentication.getUserAuthenticationData();
				if(stLoggedInUser.bLoggedIn)
					arguments.lPolicyGroupIds = stLoggedInUser.lPolicyGroupIDs;
				else
					arguments.lPolicyGroupIds = application.dmsec.ldefaultpolicygroups;	
			}
			
			if (isDefined("arguments.objectid"))
			{
				stObjectPermissions = collateObjectPermissions(objectid=arguments.objectid); //need to write this
				//stObj = contentObjectGet(objectid=arguments.objectid);
				permissionType = 'dmNavigation';//stObj.typename;
			}
			else
			{
				stObjectPermissions = getObjectPermission(reference=arguments.reference);
				permissionType = arguments.reference;
			}
			
			stPermission = getPermission(permissionName=arguments.permissionName,permissionType=permissionType);
			bHasPermission = 0;
			
			if (not StructIsEmpty(stPermission))
			{
				aPolicyGroupIDs = listToArray(arguments.lPolicyGroupIds);
				for(i=1;i LTE arrayLen(aPolicyGroupIds);i=i+1)
				{
					perm = 0;
					if (StructKeyExists(stObjectPermissions,aPolicyGroupIds[i]) AND StructKeyExists(stObjectPermissions[aPolicyGroupIds[i]],stPermission.permissionId))
						perm = stObjectPermissions[aPolicyGroupIds[i]][stPermission.permissionId].T;
					if (bHasPermission EQ 0 OR (bHasPermission eq -1 AND perm eq 1))
						bHasPermission = perm;
				}	
			}							
					
		</cfscript>
		
		<cfreturn bHasPermission>	
			
	</cffunction>
	
	
	
	<cffunction name="createPermission" hint="Creates a new permission in the datastore" output="True">
		<cfargument name="permissionID" required="false" default="-1" hint="Note that permissionID is only handed in during installtation of farcry">
		<cfargument name="permissionName" required="true">
		<cfargument name="permissionType" required="true">
		<cfargument name="permissionNotes" required="false" default="">
		
		<cfset var stPolicyStore = getPolicyStore()>
		<cfset var stLocal = StructNew()>
		<cfset stLocal.streturn = StructNew()>
		<cfset stLocal.streturn.returncode = 1>
		<cfset stLocal.streturn.returnmessage = "">
		
		<cfset stLocal.stPermission = getPermission(permissionName=arguments.permissionName,permissionType=arguments.permissionType)>
		<cfif NOT StructIsEmpty(stLocal.stPermission)>
			<cfset stLocal.streturn.returncode = 0>
			<cfset stLocal.streturn.returnmessage = "Sorry Permission [#arguments.permissionName# - #arguments.permissionType#] already exists">
		<cfelse>
			<cfswitch expression="#application.dbType#">
				<cfcase value="ora">
					<cfsavecontent variable="stLocal.sql"><cfoutput>
					INSERT INTO #application.dbowner##stPolicyStore.permissionTable# (permissionid,permissionName,permissionNotes,permissionType)
					VALUES (<cfif arguments.permissionId NEQ -1>#arguments.permissionId#<cfelse>DMPERMISSION_SEQ.nextval</cfif>,'#arguments.permissionName#','#arguments.permissionNotes#','#arguments.permissionType#')
					</cfoutput></cfsavecontent>
				</cfcase>

				<cfcase value="postgresql">
					<cfsavecontent variable="stLocal.sql"><cfoutput>
					INSERT INTO #application.dbowner##stPolicyStore.permissionTable# (permissionName,permissionNotes,permissionType<cfif arguments.permissionId NEQ -1>,permissionid</cfif>)
					VALUES ('#arguments.permissionName#','#arguments.permissionNotes#','#arguments.permissionType#'<cfif arguments.permissionId NEQ -1>,#arguments.permissionId#</cfif>)
					</cfoutput></cfsavecontent>
				</cfcase>

				<cfcase value="mysql,mysql5">
					<cfsavecontent variable="stLocal.sql"><cfoutput>
					INSERT INTO #application.dbowner##stPolicyStore.permissionTable# (permissionName,permissionNotes,permissionType<cfif arguments.permissionId NEQ -1>,permissionid</cfif>)
					VALUES ('#arguments.permissionName#','#arguments.permissionNotes#','#arguments.permissionType#'<cfif arguments.permissionId NEQ -1>,#arguments.permissionId#</cfif>)
					</cfoutput></cfsavecontent>
				</cfcase>

				<cfdefaultcase>
					<cfsavecontent variable="stLocal.sql"><cfoutput>
					INSERT INTO #application.dbowner##stPolicyStore.permissionTable# (permissionName,permissionNotes,permissionType<cfif arguments.permissionId NEQ -1>,permissionid</cfif>)
					VALUES ('#arguments.permissionName#','#arguments.permissionNotes#','#arguments.permissionType#'<cfif arguments.permissionId NEQ -1>,#arguments.permissionId#</cfif>)
					</cfoutput></cfsavecontent>
				</cfdefaultcase>
			</cfswitch>
		
			<cftry>
				<cfset query(sql=stLocal.sql,dsn=stPolicyStore.datasource)>
				<cfset stLocal.oAuthentication = createObject("component","#application.securitypackagepath#.authentication")>
				<cfset stLocal.oAudit = createObject("component","#application.packagepath#.farcry.audit")>
				<cfset stLocal.stuser = stLocal.oAuthentication.getUserAuthenticationData()>
				<cfif stLocal.stUser.bLoggedIn>
					<cfset stLocal.oAudit.logActivity(auditType="dmSec.createPermission", username=stLocal.Stuser.userlogin, location=cgi.remote_host, note="permission #arguments.permissionname# of type #arguments.permissiontype# created")>
				</cfif>
	
				<cfcatch type="any">
					<cfset stLocal.streturn.returncode = 0>
					<cfset stLocal.streturn.returnmessage = "Sorry an error has occured while inserting the permissions.">
				</cfcatch>
			</cftry>
		</cfif>

		<cfreturn stLocal.streturn>
	</cffunction>
	
	<cffunction name="createPolicyGroup" hint="Creates a new policy group in the datastore" returntype="any" output="No">
		<cfargument name="policyGroupName" required="true" type="string">
		<cfargument name="policyGroupNotes" required="false" default="" type="string">
		<cfargument name="policyGroupID" required="false" type="numeric">

		<cfset var stPolicyGroup = getPolicyGroup(policyGroupName=arguments.policyGroupName)>
		<cfset var stPolicyStore = getPolicyStore()>
		<cfset var stLocal = StructNew()>
		<cfset stLocal.streturn = StructNew()>
		<cfset stLocal.streturn.returncode = 1>
		<cfset stLocal.streturn.returnmessage = "">

		<cfif NOT StructIsEmpty(stPolicyGroup)>
			<cfset stLocal.streturn.returncode = 0>
			<cfset stLocal.streturn.returnmessage = "Sorry Policy Group [#arguments.policyGroupName#] already exists">
		<cfelse>
			<cfswitch expression="#application.dbType#">
				<cfcase value="ora">
					<cfset stLocal.sql = "INSERT INTO #application.dbowner##stPolicyStore.PolicyGroupTable# (policyGroupID, policyGroupName,policyGroupNotes ) VALUES (DMPOLICYGROUP_SEQ.nextval,'#arguments.PolicyGroupName#','#arguments.PolicyGroupNotes#')">
				</cfcase>

				<cfcase value="postgresql">
					<cfset stLocal.sql = "INSERT INTO #application.dbowner##stPolicyStore.PolicyGroupTable# ( policyGroupName,policyGroupNotes ) VALUES ('#arguments.PolicyGroupName#','#arguments.PolicyGroupNotes#')">
				</cfcase>

				<cfcase value="mysql,mysql5">
 					<cfif isDefined("arguments.policyGroupID")> <!--- during import may want to insert specific policy group id --->
						<cfset stLocal.sql = "INSERT INTO #application.dbowner##stPolicyStore.PolicyGroupTable# (policyGroupID, policyGroupName,policyGroupNotes ) VALUES (#arguments.PolicyGroupID#, '#arguments.PolicyGroupName#','#arguments.PolicyGroupNotes#')">
					<cfelse>
						<cfset stLocal.sql = "INSERT INTO #application.dbowner##stPolicyStore.PolicyGroupTable# (policyGroupName,policyGroupNotes ) VALUES ('#arguments.PolicyGroupName#','#arguments.PolicyGroupNotes#')">
					</cfif>
				</cfcase>

				<cfdefaultcase>
					<cfset stLocal.sql = "INSERT INTO #application.dbowner##stPolicyStore.PolicyGroupTable# ( policyGroupName,policyGroupNotes ">
					<cfif isDefined("arguments.policyGroupId")>
						<cfset stLocal.sql = stLocal.sql & ",policyGroupId">
					</cfif>
					<cfset stLocal.sql = stLocal.sql & ") VALUES ('#arguments.PolicyGroupName#' ,'#arguments.PolicyGroupNotes#'">
					<cfif isDefined("arguments.policyGroupId")>
						<cfset stLocal.sql = stLocal.sql & ",#arguments.policyGroupId#">
					</cfif>
					<cfset stLocal.sql = stLocal.sql & ")">
				</cfdefaultcase>
			</cfswitch>

			<cftry>
				<cfset query(sql=stLocal.sql,dsn=stPolicyStore.datasource)>
				<cfset stLocal.oAuthentication = createObject("component","#application.securitypackagepath#.authentication")>
				<cfset stLocal.oAudit = createObject("component","#application.packagepath#.farcry.audit")>
				<cfset stLocal.stuser = stLocal.oAuthentication.getUserAuthenticationData()>
				<cfif stLocal.stUser.bLoggedIn>
					<cfset stLocal.oAudit.logActivity(auditType="dmSec.createPolicyGroup", username=stLocal.Stuser.userlogin, location=cgi.remote_host, note="policy group #arguments.policygroupname# created")>
				</cfif>

				<cfcatch type="any">
					<cfset stLocal.streturn.returncode = 0>
					<cfset stLocal.streturn.returnmessage = "Sorry an error has occured while inserting the policy group.">
				</cfcatch>
			</cftry>
		</cfif>
		<cfreturn stLocal.streturn>
	</cffunction>

	<cffunction name="copyPolicyGroup" hint="Copys an existing policy group in the datastore" returntype="struct" output="no">
		<cfargument name="stForm" required="true" type="struct">
		<cfset var stLocal = StructNew()>
		<cfset stLocal.streturn = StructNew()>
		<cfset stLocal.streturn.returncode = 1>
		<cfset stLocal.streturn.returnmessage = "">

		<cfset stLocal.returnstruct = createPolicyGroup(policyGroupName=arguments.stform.name,policyGroupNotes=arguments.stform.notes)>
		<!--- check create policy group done suceesfully --->
		<cfif stLocal.returnstruct.returncode EQ 1>
			<cfset stLocal.returnstruct = getPolicyGroup(policyGroupName=arguments.stform.name)>
			<cfset stLocal.desinationPolicyGroupID = stLocal.returnstruct.policyGroupID>
			<cfset stLocal.stObjectPermissions = getObjectPermission(reference='policyGroup')>
			<cfset stLocal.stPolicyGroupPermissions = stLocal.stObjectPermissions[arguments.stform.sourcePolicyGroupID]>
			<cfloop collection="#stLocal.stPolicyGroupPermissions#" item="stLocal.key">
				<cfset createPermissionBarnacle(PolicyGroupId=stLocal.desinationPolicyGroupID, PermissionId=stLocal.key,Reference="PolicyGroup", status=stLocal.stPolicyGroupPermissions[stLocal.key].A)>
			</cfloop>
		<cfelse> <!--- else return an error message --->
			<cfset stLocal.streturn.returncode = 0>
			<cfset stLocal.streturn.returnmessage = stLocal.returnstruct.returnmessage>
		</cfif>
		<cfreturn stLocal.streturn>		
	</cffunction>

	<cffunction name="checkInheritedPermission" hint="checks whether you have inherited permission to perform an action on an object." output="no">
		<cfargument name="permissionName" required="true">
		<cfargument name="objectid" required="false">
		<cfargument name="reference" required="false">
		<cfargument name="lPolicyGroupIDs" required="false">

		<cfset oAuthentication = request.dmsec.oAuthentication>
		<cfif NOT isDefined("arguments.lPolicyGroupIds")>
			<cfset stLoggedInUser = oAuthentication.getUserAuthenticationData()>
			<cfif structKeyExists(stLoggedInUser,"lPolicyGroupIds")>
				<cfset arguments.lPolicyGroupIds = stLoggedInUser.lPolicyGroupIDs>
			</cfif>
		</cfif>
		
				
		<cfset permissionType = "">
		<cfif Len(arguments.objectid)>
			<cfset stObjectPermissions = collateObjectPermissions(objectid=arguments.objectid)>
			<!--- Dont need this - if we are pasing in an objcetid - then it will always be a tree based permission, therefore permissiontype = 'dmnavigation' --->
			<!--- stObj = contentObjectGet(objectid=arguments.objectID) --->
			<cfset permissionType = "dmNavigation">
		<cfelseif IsDefined("arguments.reference")>
			<cfset stObjectPermissions = getObjectPermission(reference=arguments.reference)>
			<cfset permissionType = arguments.reference>
		</cfif>
		
		
		<cfset bHasPermission = 0>
		<cfif permissionType NEQ "">
			<cfset stPermission = getPermission(permissionname=arguments.permissionName,permissionType=permissionType)>
			
			<cfif NOT StructIsEmpty(stPermission)>
				<cfloop index="policyGroupId" list="#arguments.lpolicyGroupIds#">
					<cfset perm = 0>
					<cfif StructKeyExists(stObjectPermissions,policyGroupId) AND StructKeyExists(stObjectPermissions[policyGroupId],stPermission.permissionId)>
						<cfset perm = stObjectPermissions[policyGroupId][stPermission.permissionId].T>
					</cfif>
					
					<cfif bhasPermission EQ 0>
						<cfset bhasPermission = perm>
					<cfelseif bhasPermission EQ -1 AND perm EQ 1>
						<cfset bhasPermission = perm>
					</cfif>
				</cfloop>			
			</cfif>
		</cfif>

		<cfreturn bHasPermission>
	</cffunction> 
	
	<cffunction name="createPolicyGroupMapping" hint="Creates a new policy group mapping"  returntype="struct" output="No">
		<cfargument name="groupname" required="true">
		<cfargument name="userdirectory" required="true">
		<cfargument name="policyGroupId" required="true">

		<cfset var stLocal = StructNew()>
		<cfset stLocal.streturn = StructNew()>
		<cfset stLocal.streturn.returncode = 1>
		<cfif isDefined("application.adminBundle") AND StructKeyExists(application.adminBundle,session.dmProfile.locale)>
			<cfset stLocal.streturn.returnmessage = "#application.adminBundle[session.dmProfile.locale].policyGroupMappingAdded#">
		<cfelse>
			<cfset stLocal.streturn.returnmessage = "Policy Group Added.">
		</cfif>				
		<cfset stLocal.stPolicyStore = getPolicyStore()>
		<cfset stLocal.oAuthentication = createObject("component","#application.securitypackagepath#.authentication")>
		<cfset stLocal.stGroup = stLocal.oAuthentication.getGroup(groupName="#arguments.groupName#", userdirectory="#arguments.userDirectory#")>
		<cfset stLocal.stPolicyGroup = getPolicyGroup(policyGroupId="#arguments.policyGroupId#")>
		<cfset stLocal.sql = "SELECT * FROM #application.dbowner##stLocal.stPolicyStore.ExternalGroupToPolicyGroupTable# WHERE policyGroupId=#arguments.policyGroupId# AND upper(ExternalGroupUserDirectory)='#ucase(arguments.userdirectory)#' AND upper(ExternalGroupName)='#ucase(arguments.groupName)#'">
		<cfset stLocal.qCheckMapping = query(sql=stLocal.sql,dsn=stLocal.stPolicyStore.datasource)>
		<cfif stLocal.qCheckMapping.recordCount>
			<cfset stLocal.streturn.returncode = 0>
			<cfset stLocal.streturn.returnmessage = "#application.adminBundle[session.dmProfile.locale].policyGroupMappingExists#">
		<cfelse>
			<cfset stLocal.sql = "INSERT INTO #application.dbowner##stPolicyStore.ExternalGroupToPolicyGroupTable# (policyGroupId, ExternalGroupUserDirectory, ExternalGroupName) VALUES (#arguments.policyGroupId#,'#arguments.userdirectory#','#arguments.groupName#')">
			<cfset query(sql=stLocal.sql,dsn=stLocal.stPolicyStore.datasource)>
			<cfset stLocal.oAuthentication = createObject("component","#application.securitypackagepath#.authentication")>
			<cfset stLocal.oAudit = createObject("component","#application.packagepath#.farcry.audit")>
			<cfset stLocal.stuser = stLocal.oAuthentication.getUserAuthenticationData()>
			<cfif stLocal.stUser.bLoggedIn>
				<cfset stLocal.oAudit.logActivity(auditType="dmSec.createPolicyGroupMapping", username=stLocal.Stuser.userlogin, location=cgi.remote_host, note="group #arguments.groupname# mapped to #stPolicyGroup.policyGroupName#")>
			</cfif>
		</cfif>

	<cfreturn stLocal.streturn>

	</cffunction>
	
	<cffunction name="deletePermission" hint="Delets a permission from the datastore" returntype="struct" output="no">
		<cfargument name="permissionID" required="true">
		
		<cfset var stPolicyStore = getPolicyStore()>
		<cfset var stLocal = StructNew()>
		<cfset stLocal.stReturn = StructNew()>
		<cfset stLocal.streturn.returncode = 1>
		<cfset stLocal.streturn.returnmessage = "">
		
		<cftry>
			<cfset stLocal.stPermission = getPermission(permissionID=arguments.permissionid)>
			<cfset stLocal.sql = "DELETE FROM #application.dbowner##stPolicyStore.permissionTable# WHERE permissionId=#arguments.permissionId#">
			<cfset query(sql=stLocal.sql,dsn=stPolicyStore.datasource)>
			<cfset stLocal.oAuthentication = createObject("component","#application.securitypackagepath#.authentication")>
			<cfset stLocal.oAudit = createObject("component","#application.packagepath#.farcry.audit")>
			<cfset stLocal.stuser = stLocal.oAuthentication.getUserAuthenticationData()>
			<cfif stLocal.stUser.bLoggedIn>
				<cfset stLocal.oAudit.logActivity(auditType="dmSec.deletepermission", username=stLocal.stUser.userlogin, location=cgi.remote_host, note="#stlocal.stPermission.permissionName# deleted")>
			</cfif>

			<cfcatch type="any">
				<cfset stLocal.streturn.returncode = 0>
				<cfset stLocal.streturn.returnmessage = "Sorry an error has occured while deleting the Permission.<br />">			
			</cfcatch>
		</cftry>
		
		<cfreturn stLocal.streturn>
	</cffunction>
	
	<cffunction name="deletePolicyGroup" hint="Deletes a policy group from the data store." output="No" returntype="struct">
		<cfargument name="PolicyGroupName" required="false" type="string" default="">
		<cfargument name="PolicyGroupID" required="false" type="numeric" default="0">
		
		<cfset var stPolicyStore = getPolicyStore()>
		<cfset var stLocal = StructNew()>
		<cfset stLocal.stReturn = StructNew()>
		<cfset stLocal.streturn.returncode = 1>
		<cfset stLocal.streturn.returnmessage = "">
				
		<cftry>			
			<cfif arguments.policyGroupName NEQ "">
				<cfset stPolicyGroup = getPolicyGroup(PolicyGroupName="#PolicyGroupName#")>
			<cfelse>
				<cfset stPolicyGroup.policyGroupId = arguments.policyGroupId>
			</cfif>
			
			<cfset stLocal.sql = "DELETE FROM #application.dbowner##stPolicyStore.policyGroupTable# WHERE PolicyGroupId='#stPolicyGroup.policyGroupId#'">
			<cfset query(sql=stLocal.sql,dsn=stPolicyStore.datasource)>

			<cfset stLocal.sql = "DELETE FROM #application.dbowner##stPolicyStore.externalGroupToPolicyGroupTable# WHERE policyGroupId=#stPolicyGroup.policyGroupId#">
			<cfset query(sql=stLocal.sql,dsn=stPolicyStore.datasource)>
			
			<cfset stLocal.oAuthentication = createObject("component","#application.securitypackagepath#.authentication")>
			<cfset stLocal.oAudit = createObject("component","#application.packagepath#.farcry.audit")>
			<cfset stLocal.stuser = stLocal.oAuthentication.getUserAuthenticationData()>
			<cfif stLocal.stUser.bLoggedIn>
				<cfset stLocal.oAudit.logActivity(auditType="dmSec.deletePolicyGroup", username=stlocal.Stuser.userlogin, location=cgi.remote_host, note="#stPolicyGroup.policyGroupID# deleted")>
			</cfif>

			<cfcatch type="any">
				<cfset stLocal.streturn.returncode = 0>
				<cfset stLocal.streturn.returnmessage = "Sorry an error has occured while deleteing the policy group.">
			</cfcatch>
		</cftry>

		<cfreturn stLocal.streturn>
	</cffunction>
	
	
	<cffunction name="deletePolicyStore" hint="Hmmm this does the same thing as delete policyGroup" returntype="struct" output="No">
		<cfargument name="policyGroupID" required="true">
		<cfscript>
			stPolicyGroup = getPolicyGroup(policygroupid=arguments.policygroupid);
			stPolicyStore = getPolicyStore();
			sql = "
				DELETE FROM #application.dbowner##stPolicyStore.policyGroupTable# WHERE
				PolicyGroupId='#arguments.policyGroupId#'";
			query(sql=sql,dsn=stPolicyStore.datasource);
			sql = "
				DELETE FROM #application.dbowner##stPolicyStore.externalGroupToPolicyGroupTable#
				WHERE policyGroupId=#policyGroupId#";
			query(sql=sql,dsn=stPolicyStore.datasource);
			
			stResult = structNew();
			stResult.bSuccess = true;
			stResult.message = "Policy Group successfully deleted";	
			oAuthentication = createObject("component","#application.securitypackagepath#.authentication");
			oAudit = createObject("component","#application.packagepath#.farcry.audit");
			stuser = oAuthentication.getUserAuthenticationData();
				if(stUser.bLoggedIn)
					oAudit.logActivity(auditType="dmSec.deletePolicyGroup", username=Stuser.userlogin, location=cgi.remote_host, note="#stPolicyGroup.policyGroupName# deleted");	
		</cfscript>
	</cffunction>
	
	<cffunction name="deletePolicyGroupMapping" returntype="struct" output="false">
		<cfargument name="groupname" required="true">
		<cfargument name="userdirectory" required="true">
		<cfargument name="policyGroupID" required="true">

		<cfset var stLocal = StructNew()>
		<cfset stLocal.streturn = StructNew()>
		<cfset stLocal.streturn.returncode = 1>
		<cfset stLocal.streturn.returnmessage = "">
		
		<cftry>
			<cfset stLocal.stPolicyStore = getPolicyStore()>
			<cfset stLocal.stPolicyGroup = getPolicyGroup(policygroupid=arguments.policygroupid)>
			<cfset stLocal.sql = "DELETE FROM #application.dbowner##stPolicyStore.ExternalGroupToPolicyGroupTable# WHERE policyGroupId=#policyGroupId# AND upper(ExternalGroupUserDirectory)='#ucase(arguments.userdirectory)#' AND upper(ExternalGroupName)='#ucase(arguments.groupName)#'">
			<cfset query(sql=stLocal.sql,dsn=stLocal.stPolicyStore.datasource)>
			<cfset stLocal.oAuthentication = createObject("component","#application.securitypackagepath#.authentication")>
			<cfset stLocal.oAudit = createObject("component","#application.packagepath#.farcry.audit")>
			<cfset stLocal.stuser = stLocal.oAuthentication.getUserAuthenticationData()>
			<cfif stLocal.stUser.bLoggedIn>
				<cfset stLocal.oAudit.logActivity(auditType="dmSec.deletePolicyGroupMapping", username=stLocal.stUser.userlogin, location=cgi.remote_host, note="removed #arguments.groupname# mapping from #stPolicyGroup.policyGroupName#")>
			</cfif>

			<cfcatch type="any">
				<cfset stLocal.streturn.returncode = 0>
				<cfset stLocal.streturn.returnmessage = "Sorry an error has occured while deleting the Policy Group Mapping.<br />">
			</cfcatch>
		</cftry>

		<cfreturn stLocal.streturn>
	</cffunction>
	
	
	<cffunction name="getPermission" access="public" output="false" returntype="struct">
		<cfargument name="permissionID" required="false">
		<cfargument name="permissionName" type="string">
		<cfargument name="permissionType" type="string" required="false">
		
		<cfset var stPolicyStore = getPolicyStore() />
		<cfset var q=queryNew("blah") />
		<cfset var stPermission=structNew() />
		
		<cfquery datasource="#stPolicyStore.datasource#" name="q">
		SELECT * 
		FROM #application.dbowner##stPolicyStore.permissionTable# 
		WHERE 
			<cfif (isDefined("arguments.permissionName") AND isDefined("arguments.permissionType"))>
				upper(permissionName) = '#ucase(arguments.permissionName)#' AND upper(permissiontype) = '#ucase(arguments.permissionType)#'
			<cfelse>
				permissionid = '#arguments.permissionID#'
			</cfif>
		</cfquery>

		<cfif q.recordCount>
			<cfset stPermission = queryToStructure(q) />
		</cfif>		
		
		<cfreturn stPermission />
	</cffunction>	

	<cffunction name="getPolicyGroupMappings" output="yes">
		<cfargument name="lGroupNames" required="true">
		<cfargument name="userDirectory" required="true">
		
		<cfscript>
			userdirectory = trim(arguments.userdirectory);
			//get the policy store structure 
			stPolicyStore = getPolicyStore();
			PolicyGroupIds = '';
			if (len(arguments.lGroupNames))
			{
				aGroupNames = listToArray(lGroupNames);
				for (i=1;i LTE arrayLen(aGroupNames);i=i+1)
				{
					sql ="
					SELECT * FROM  #application.dbowner##stPolicyStore.ExternalGroupToPolicyGroupTable#
					WHERE upper(ExternalGroupUserDirectory)='#ucase(userdirectory)#' AND  upper(ExternalGroupName)='#ucase(aGroupNames[i])#'";
					qMappings = query(sql=sql,dsn=stPolicyStore.datasource);
					for (index = 1; index LTE qMappings.recordCount;index=index+1)
					{
						if (listFindNoCase(policyGroupIds,qMappings.policyGroupId) eq 0)
							policyGroupIds = listAppend(policyGroupIds,qMappings.policyGroupId[index]);
					}		
				}	
			}	
		</cfscript>
		
		<cfreturn policyGroupIds>
		
	</cffunction>
	
		
	<cffunction name="getPolicyStore" output="No">
		<cfscript>
			if (not isDefined( "request.policyStore" ))
				request.policyStore = duplicate( Application.dmSec.PolicyStore );
	    </cfscript>
	
		<cfreturn request.policyStore>
	</cffunction>
	
	<cffunction name="getMultiplePolicyGroupMappings" hint="Retrieves all group mappings in the form of an array of groupName+userdirectory structures. Filtered by lUserdirectory,policygroupname/policygroupid." output="No">
		<cfargument name="userdirectory" default="" required="false">
		<cfargument name="lGroupNames" default="" required="false">
		<cfargument name="policyGroupId" required="false" default="-1">
		 <cfset var theArray = arrayNew(1)>
		 
		<cfscript>
			
			stPolicyStore = getPolicyStore();
			if (len(arguments.lGroupNames))
			{
				aGroupNames = listToArray(arguments.lGroupNames);
				for (index = 1;index LTE arrayLen(aGroupNames);index=index+1)
				{
					sql = 
					"SELECT * FROM  #application.dbowner##stPolicyStore.ExternalGroupToPolicyGroupTable# e,  #stPolicyStore.PolicyGroupTable# p
					WHERE e.policyGroupId=p.policyGroupId ";
					if (len(arguments.userDirectory))
						sql = sql & "AND upper(e.ExternalGroupUserDirectory) = '#ucase(arguments.Userdirectory)#' ";
					if (len(agroupNames[index]))
						sql = sql & " AND upper(e.ExternalGroupName) = '#ucase(aGroupNames[index])#' ";
					if (arguments.policyGroupID NEQ -1)
						sql = sql & "AND e.policyGroupId = '#attributes.policyGroupId#' ";	
					sql = sql & " ORDER BY p.policyGroupName, e.ExternalGroupUserDirectory, e.ExternalGroupName";
					qGetmapping = query(sql=sql,dsn=stPolicyStore.datasource);
					theArray = QueryToArrayOfStructures(qGetMapping,theArray);						
				}	
			}
			else
			{	
				sql = "
				SELECT * FROM  #application.dbowner##stPolicyStore.ExternalGroupToPolicyGroupTable# e,  #stPolicyStore.PolicyGroupTable# p
				WHERE e.policyGroupId=p.policyGroupId ";
				
				if (len(arguments.Userdirectory))
					sql = sql & " AND upper(e.ExternalGroupUserDirectory) = '#ucase(arguments.Userdirectory)#' ";
				if (arguments.policyGroupID NEQ -1)
					sql = sql & " AND e.policyGroupId = '#arguments.policyGroupId#' ";	
				sql = sql & "ORDER BY p.policyGroupName, e.ExternalGroupUserDirectory, e.ExternalGroupName";
				qGetMapping = query(sql=sql,dsn=stPolicyStore.datasource);
				theArray = queryToArrayOfStructures(qGetMapping,theArray);
			}			
				
		</cfscript>	
		
		<cfreturn theArray>
	</cffunction>
	
	
	<cffunction name="getPolicyGroupUsers" hint="Retrieve list of usernames that are members of a specified Policy Group" output="No">
		<cfargument name="lPolicyGroupIds" required="false" default="">
		
		<cfscript>
			//set up array of users to return
			aUsers = arrayNew(1);
			//set up structure to hold group information
			stGroups = structNew();
			
			if(listLen(arguments.lPolicyGroupIds)) {
	            aPolicyGroupIDs = listToArray(lPolicyGroupIds);
				//loop over policy groups
	            for (index=1; index LTE arrayLen(aPolicyGroupIds); index=index+1) {
					//get mappings for policy group
	                aMapGroups = getMultiplePolicyGroupMappings(policyGroupID=aPolicyGroupIDs[index]);
					//loop over mappings
	                for (i=1; i LTE arrayLen(aMapGroups); i=i+1) {
						//check if already in group
	                    if (not structKeyExists(stGroups, aMapGroups[i].externalgroupName)) {
	                        stGroups[aMapGroups[i].externalgroupName] = aMapGroups[i].externalgroupuserDirectory;
						} else {
							//if already in group add user directory to list
							stGroups[aMapGroups[i].externalgroupName] = stGroups[aMapGroups[i].externalgroupName] & "," & aMapGroups[i].externalgroupuserDirectory;
						}
				
	                }		
	            }
	        }	
		</cfscript>
		
		<cfif listLen(arguments.lPolicyGroupIds)>
			<!--- loop over groups --->
			<cfloop collection="#stGroups#" item="groupName">
				<!--- loop over user directories for each group --->
				<cfloop list="#stGroups[groupName]#" index="groupUD">
					<cfscript>
					//get user directory details based on user directory type
					if (structKeyExists(application.dmSec.userDirectory, groupUD))
						stUD=application.dmSec.userDirectory[groupUD]; //TODO - this must be authorisation specific
					else
						stUD.type="unknown"; //means UD was available when mapping was set but access has been removed GB050321
					switch(stUD.type) {
						case "unknown" : {
						break; //means UD was available when mapping was set but access has been removed GB050321
						} case "ADSI" : {
		                    o_NTsec = createObject("component", "#application.packagepath#.security.NTsecurity");
					        aADUsers = o_NTsec.getGroupUsers(groupName=groupName, domain=stUD.domain);
		
							for (i = 1; i LTE arrayLen(aADUsers); i=i+1) {
		                        user = aADUsers[i];
								if (not listFindNoCase(arrayToList(aUsers), user)) arrayAppend(aUsers, user);
							}
							break;
						} default : {
							//select users in group
							sql = "
		                    SELECT c.userLogin FROM #application.dbowner#dmGroup a, dmUserToGroup b, dmUser c
							WHERE upper(a.groupName) = '#ucase(groupName)#'
							AND a.groupID = b.groupID
							AND b.userID = c.userID
							ORDER BY c.userLogin ASC";
							
							//run query with user directory datasource
							qGetGroupUsers = query(sql=sql,dsn=stUD.datasource);
							
							//loop over results and only add user once to returning array
		                    for(index=1; index LTE qGetGroupUsers.recordcount; index=index+1) {   
		                        if (not listFindNoCase(arrayToList(aUsers), qGetGroupUsers.userLogin[index]))
		                            arrayAppend(aUsers, qGetGroupUsers.userLogin[index]);
							}		
						}
					}	
					</cfscript>
				</cfloop>
			</cfloop>
		</cfif>
		<cfreturn aUsers>
	</cffunction>	
		
	
	<cffunction name="getAllPermissions" output="No">
		<cfargument name="permissionType" required="false" default=""> 

		<cfscript>
			stPolicyStore = getPolicyStore();
			sql = "SELECT * FROM #application.dbowner##stPolicyStore.permissionTable# ";
			if (len(arguments.permissionType))
				sql = sql & " WHERE upper(PermissionType) = '#ucase(arguments.permissionType)#'";
			sql = sql & " ORDER BY PermissionType, PermissionName";
			qGetPermissions = query(sql=sql,dsn=stPolicyStore.datasource);
		</cfscript>
		<cfreturn QueryToArrayOfStructures(qGetPermissions)>
	</cffunction>
	
	
	<cffunction name="getPolicyGroup" returntype="struct" output="No">
		<cfargument name="policyGroupName" required="false" type="string">
		<cfargument name="policyGroupID" required="false" type="numeric">
		
		<cfscript>
			stPolicyStore = getPolicyStore();
			sql = "SELECT * FROM #application.dbowner#dmPolicyGroup WHERE ";
			if (isDefined('arguments.policyGroupName'))
				sql = sql & " upper(PolicyGroupName)='#ucase(arguments.PolicyGroupName)#'";
			else if (isDefined('arguments.policyGroupID'))
				sql = sql & " PolicyGroupID=#PolicyGroupId#";
			qGetPolicyGroup = query(sql=sql,dsn=stPolicyStore.datasource);
			if(qGetPolicyGroup.recordCount)	
				stPolicyGroup = queryToStructure (qGetPolicyGroup);	
			else
				stPolicyGroup = structNew();	
		</cfscript>
		
		<cfreturn stPolicyGroup>
	</cffunction>
	
	<cffunction name="getAllPolicyGroups" hint="Gets all policy groups." returntype="array" output="Yes">
		<cfscript>
			stPolicyStore = getPolicyStore();
			sql = 
			"SELECT * FROM #application.dbowner##stPolicyStore.PolicyGroupTable#
			ORDER BY PolicyGroupName";
			qGetPolicyGroups = query(sql=sql,dsn=stPolicyStore.datasource);
	
		</cfscript>
		<cfreturn QueryToArrayOfStructures(qGetPolicyGroups)>
	</cffunction>

	
	<cffunction name="getObjectPermission" output="No">
		<cfargument name="reference">
		<cfargument name="objectID" required="false" default="">
		<cfargument name="lrefs">
		<cfargument name="bUseCache" required="false" default="1">
		
		<cfscript>
			if( not isDefined( "arguments.reference" ))
				arguments.reference=arguments.objectId;
			if (not isDefined("arguments.lRefs"))
				arguments.lrefs = arguments.reference;
		</cfscript>		

		<cfloop index="arguments.reference" list="#arguments.lrefs#">

		<cfscript>
			stObjectPermissions = StructNew();
	
			// check that the permissions aren't already cached 
			if (arguments.bUseCache)
			{
				if (isDefined("server.dmSec") AND StructKeyExists(server.dmSec,application.applicationname) AND isStruct(server.dmSec[application.applicationname]) AND StructKeyExists(server.dmSec[application.applicationname],"dmSecSCache") AND isStruct(server.dmSec[application.applicationname].dmSecSCache) AND StructKeyExists(server.dmSec[application.applicationname].dmSecSCache, arguments.Reference))
					stObjectPermissions = duplicate(server.dmSec[application.applicationname].dmSecSCache[arguments.Reference]);
			}

	
			// if we didn't get the permission out of the cache 
			if (StructIsEmpty(stObjectPermissions))
			{
				// get the dmSec policy settings 
				if (not isDefined("Request.stPolicyStore"))
					stPolicyStore = getPolicyStore();
				else	
					stPolicyStore=Request.stPolicyStore;
	
		
				if (len(arguments.ObjectId))
				{	
					stObj =	contentobjectget(objectid="#arguments.objectid#");
					permissionType=stobj.typename;
				}
				else
					// permissions on non-object 
					permissionType = arguments.reference;
					
					switch (application.dbType)
					{
						case "ora":
						{
							sql = "
							SELECT s.policyGroupId, s.permissionId, b.status FROM
								(SELECT g.policyGroupId, p.permissionId FROM #application.dbowner##stPolicyStore.policyGroupTable# g
								CROSS JOIN dmPermission p WHERE upper(p.PermissionType)='#ucase(permissionType)#' ) s
								
								LEFT OUTER JOIN #application.dbowner##stPolicyStore.permissionBarnacleTable# b
									ON s.permissionId = b.permissionID
									AND s.policyGroupId = b.policyGroupId
									AND upper(b.Reference1)='#ucase(arguments.reference)#'";
							break;	
						}
						case "postgresql":
						{
							sql = "
							SELECT s.policyGroupId, s.permissionId, b.status FROM
								(SELECT g.policyGroupId, p.permissionId FROM #application.dbowner##stPolicyStore.policyGroupTable# g
								CROSS JOIN dmPermission p WHERE upper(p.PermissionType)='#ucase(permissionType)#' ) s
								
								LEFT OUTER JOIN #application.dbowner##stPolicyStore.permissionBarnacleTable# b
									ON s.permissionId = b.permissionID
									AND s.policyGroupId = b.policyGroupId
									AND upper(b.Reference1)='#ucase(arguments.reference)#'";
							break;	
						}
						case "mysql":
						{
							tempDropSQL = "DROP TABLE IF EXISTS tblTemp1";
							tempDrop = query(sql=tempDropSQL,dsn=stPolicyStore.datasource);
							
							// create temp table
							temp1SQL = "create temporary table `tblTemp1`
										(
										`POLICYGROUPID`  VARCHAR (255) NOT NULL ,
										`PERMISSIONID` VARCHAR (255) NOT NULL
										)
									";
							temp1 = query(sql=temp1SQL,dsn=stPolicyStore.datasource);
							
							// insert values		
							temp2SQL = "INSERT INTO tblTemp1 (POLICYGROUPID,PERMISSIONID) SELECT g.policyGroupId, p.permissionId FROM #application.dbowner##stPolicyStore.policyGroupTable# g,
								 	dmPermission p WHERE upper(p.PermissionType)='#ucase(permissionType)#' 	
									";
							temp2 = query(sql=temp2SQL,dsn=stPolicyStore.datasource);
									
							sql = "
							SELECT s.policyGroupId, s.permissionId, b.status FROM
								tblTemp1 s LEFT OUTER JOIN #application.dbowner##stPolicyStore.permissionBarnacleTable# b
									ON s.permissionId = b.permissionID
									AND s.policyGroupId = b.policyGroupId
									AND upper(b.Reference1)='#ucase(arguments.reference)#'";
							break;	
						}
						
						default :
						{
							sql = "
							SELECT s.policyGroupId, s.permissionId, b.status FROM
								(SELECT g.policyGroupId, p.permissionId FROM #application.dbowner##stPolicyStore.policyGroupTable# g
								CROSS JOIN #application.dbowner#dmPermission p WHERE upper(p.PermissionType)='#ucase(permissionType)#' ) s
								
								LEFT OUTER JOIN #application.dbowner##stPolicyStore.permissionBarnacleTable# b
									ON s.permissionId = b.permissionID
									AND s.policyGroupId = b.policyGroupId
									AND upper(b.Reference1)='#ucase(arguments.reference)#'";
						}
						
					}

				qPermissionBarnacle = query(sql=sql,dsn=stPolicyStore.datasource);
				for(row = 1; row LTE qPermissionBarnacle.recordcount; row = row + 1)
				{
					pg = qPermissionBarnacle['PolicyGroupId'][row];
					pid = qPermissionBarnacle['PermissionId'][row];
					val = qPermissionBarnacle['status'][row];
					if(val eq "") val="0";
					
					if( not StructKeyExists( stObjectPermissions, pg ) ) { stObjectPermissions[ pg ] = StructNew(); }
		
					stPermission = StructNew();
					stObjectPermissions[pg][pid] = stPermission;
					stPermission.A = val;
					stPermission.T = val; // t stuck in for permission collate
					stPermission.I = 0; // t stuck in for permission collate
				}
		
			
				//cache the permission 
				if (NOT isDefined("server.dmSec") OR NOT StructKeyExists(server.dmSec,application.applicationname) OR NOT isStruct(server.dmSec[application.applicationname]) OR NOT StructKeyExists(server.dmSec[application.applicationname], "dmSecSCache"))
					server.dmSec[application.applicationname].dmSecSCache = StructNew();

			 	server.dmSec[application.applicationname].dmSecSCache[arguments.Reference]=duplicate(stObjectPermissions);	
			}
		</cfscript>
		</cfloop>

		<cfreturn stObjectPermissions>
		
	</cffunction>		
	
	<cffunction name="reInitPermissionsCache" hint="Refreshes server permissions cache from existing database permissions" returntype="struct" output="No">

		<cfset var stPolicyStore = getPolicyStore()>
		<cfset var stLocal = StructNew()>
		<cfset stLocal.stReturn = StructNew()>
		<cfset stLocal.streturn.returncode = 1>
		<cfset stLocal.streturn.returnmessage = "Permissions cache has been successfully updated">
			
		<cftry>
			<cfset stLocal.sql = "SELECT DISTINCT(reference1) AS Objectid from #application.dbowner#dmPermissionBarnacle where upper(reference1) <> 'POLICYGROUP'">
			<cfset stLocal.qReferences = query(sql=stLocal.sql,dsn=stPolicyStore.datasource)>
			<cfloop query="stLocal.qReferences">
				<cfset updateObjectPermissionCache(objectid=stLocal.qReferences.objectid,bUseCache=0)>
			</cfloop>

			<cfcatch type="any">
				<cfset stLocal.streturn.returncode = 0>
				<cfset stLocal.streturn.returnmessage = "Sorry an error has occured rebuilding Permissions.<br />">
			</cfcatch>
		</cftry>

		<cfreturn stLocal.streturn>
	</cffunction>

	<cffunction name="updatePermission" output="No" returntype="struct">
		<cfargument name="permissionID" required="true">
		<cfargument name="permissionName" required="true">
		<cfargument name="permissionType" required="true">
		<cfargument name="permissionNotes" required="false" default="">
		
		<cfset var stPolicyStore = getPolicyStore()>
		<cfset var stLocal = StructNew()>
		<cfset stLocal.stReturn = StructNew()>
		<cfset stLocal.streturn.returncode = 1>
		<cfset stLocal.streturn.returnmessage = "">		

		<cftry>
			<cfset stLocal.sql = "SELECT permissionID FROM #application.dbowner##stPolicyStore.permissionTable# WHERE permissionName='#arguments.permissionName#' AND permissionType='#arguments.permissionType#' AND permissionId <> #arguments.permissionId#">
			<cfset stLocal.qCheck = query(sql=stLocal.sql,dsn=stPolicyStore.datasource)>
			<cfif stLocal.qCheck.recordcount EQ 0>
				<cfset stLocal.sql = "UPDATE #application.dbowner##stPolicyStore.permissionTable# SET permissionName='#arguments.permissionName#', permissionNotes='#arguments.permissionNotes#', permissionType='#arguments.permissionType#' WHERE permissionId=#arguments.permissionId#">
				<cfset query(sql=stLocal.sql,dsn=stPolicyStore.datasource)>
				<cfset stLocal.oAuthentication = createObject("component","#application.securitypackagepath#.authentication")>
				<cfset stLocal.oAudit = createObject("component","#application.packagepath#.farcry.audit")>
				<cfset stLocal.stuser = stLocal.oAuthentication.getUserAuthenticationData()>
				<cfif stLocal.stUser.bLoggedIn>
					<cfset stLocal.oAudit.logActivity(auditType="dmSec.updatePermission", username=stLocal.StUser.userlogin, location=cgi.remote_host, note="#arguments.permissionName# updated")>
				</cfif>
			<cfelse>
				<cfset stLocal.streturn.returncode = 0>
				<cfset stLocal.streturn.returnmessage = "Sorry a policy Permission with the name [#arguments.permissionName#] and Type [#arguments.permissionType#] already exists.">
			</cfif>

			<cfcatch type="any">
				<cfset stLocal.streturn.returncode = 0>
				<cfset stLocal.streturn.returnmessage = "Sorry an error has occured while updating the policy group.">			
			</cfcatch>
		</cftry>

		<cfreturn stLocal.streturn>
	</cffunction>	
	
	<cffunction name="updatePolicyGroup" returntype="struct" output="No">
		<cfargument name="policyGroupID" required="true">
		<cfargument name="PolicyGroupName" required="true">
		<cfargument name="PolicyGroupNotes" required="false" default="">
		
		<cfset var stPolicyStore = getPolicyStore()>
		<cfset var stLocal = StructNew()>
		<cfset stLocal.stReturn = StructNew()>
		<cfset stLocal.streturn.returncode = 1>
		<cfset stLocal.streturn.returnmessage = "">
				
		<cftry>
			<cfset stLocal.sql = "SELECT PolicyGroupId FROM #application.dbowner##stPolicyStore.PolicyGroupTable# WHERE PolicyGroupName='#arguments.PolicyGroupName#' AND PolicyGroupId <> #arguments.PolicyGroupId#">
			<cfset stLocal.qCheck = query(sql=stLocal.sql,dsn=stPolicyStore.datasource)>
			<cfif stLocal.qCheck.recordcount EQ 0>
				<cfset stLocal.sql = "UPDATE #application.dbowner##stPolicyStore.PolicyGroupTable# SET PolicyGroupName='#arguments.PolicyGroupName#', PolicyGroupNotes='#arguments.PolicyGroupNotes#' WHERE PolicyGroupId=#arguments.PolicyGroupId#">
				<cfset query(sql=stLocal.sql,dsn=stPolicyStore.datasource)>
				<cfset stLocal.oAuthentication = createObject("component","#application.securitypackagepath#.authentication")>
				<cfset stLocal.oAudit = createObject("component","#application.packagepath#.farcry.audit")>
				<cfset stLocal.stuser = stLocal.oAuthentication.getUserAuthenticationData()>
				<cfif stLocal.stUser.bLoggedIn>
					<cfset stLocal.oAudit.logActivity(auditType="dmSec.updatePolicyGroup", username=stLocal.StUser.userlogin, location=cgi.remote_host, note="#arguments.policyGroupName# updated")>
				</cfif>
			<cfelse>
				<cfset stLocal.streturn.returncode = 0>
				<cfset stLocal.streturn.returnmessage = "Sorry a policy group with the name [#arguments.PolicyGroupName#] already exists.">
			</cfif>

			<cfcatch type="any">
				<cfset stLocal.streturn.returncode = 0>
				<cfset stLocal.streturn.returnmessage = "Sorry an error has occured while updating the policy group.">
			</cfcatch>			
		</cftry>
		<cfreturn stLocal.streturn>
	</cffunction>	
	
	
	<cffunction name="updateObjectPermissionCache" output="No">
		<cfargument name="objectid">
		<cfargument name="reference">
		<cfargument name="bRevalidateCache" required="false" default="1">
		<cftry>
			<cfscript>
				if (isDefined("arguments.objectid"))
				{
					if (arguments.bRevalidateCache)
						getObjectPermission(objectID=arguments.objectid,bUseCache=0);
					collateObjectPermissions(objectid=arguments.objectid,bUseCache=0);
				}	
				else
					getObjectPermission(reference=arguments.reference,permissionType="PolicyGroup",bUseCache=0);				
			</cfscript>
		<cfcatch></cfcatch>
		</cftry>	
	</cffunction> 

	<cffunction name="importPolicyGroup" access="public" hint="exports the policy group as a wddx file" returntype="struct">
		<cfargument name="stForm" required="true" type="struct" hint="form variables passed form editform">

		<cfset var stPolicyStore = getPolicyStore()>
		<cfset var stLocal = StructNew()>
		<cfset stLocal.streturn = StructNew()>
		<cfset stLocal.streturn.returncode = 1>
		<cfset stLocal.streturn.returnmessage = "">

		<cfreturn  stLocal.streturn>
	</cffunction>
	
	<cffunction name="fListUsersByPermssion" access="public" hint="returns list of user objectids for a particular permission" returntype="struct">
		<cfargument name="permissionName" required="false" default="" type="string">
		<cfargument name="permissionID" required="false" default="0" type="numeric">
		
		<cfset var stLocal = StructNew()>
		<cfset var stReturn = StructNew()>
		<cfset var stPolicyStore = getPolicyStore()>

		<cfset stReturn.bSuccess = true>
		<cfset stReturn.message = "">
		<cfset stReturn.lObjectIDs = "">
		<cftry>
			
		
			<cfquery name="stLocal.qList" datasource="#stPolicyStore.datasource#">
				SELECT     DISTINCT ug.userid 
				FROM         dmpolicygroup p INNER JOIN
				                      dmexternalgrouptopolicygroup e ON p.PolicyGroupName = e.EXTERNALGROUPNAME INNER JOIN
				                      dmgroup g ON g.groupName = p.PolicyGroupName INNER JOIN
				                      dmusertogroup ug ON ug.groupId = g.groupid INNER JOIN
				                      dmpermissionbarnacle pb ON pb.POLICYGROUPID = p.PolicyGroupId INNER JOIN
				                      dmpermission pm ON pm.PermissionId = pb.PERMISSIONID
				WHERE    1=1
				<cfif arguments.permissionID NEQ 0>
					AND pm.PermissionId = <cfqueryparam value="#arguments.permissionID#" cfsqltype="cf_sql_integer">
				<cfelse>
				    AND pm.PermissionName = <cfqueryparam value="#arguments.permissionName#" cfsqltype="cf_sql_varchar">
				</cfif>					
			</cfquery> 
			

			<cfset stReturn.lObjectIDs = ValueList(stLocal.qList.userid)>

			<cfcatch>
				<cfset stReturn.bSuccess = false>
				<cfset stReturn.message = cfcatch.message>						
			</cfcatch>
		</cftry>

		<cfreturn stReturn>
	</cffunction>

	<cffunction name="fCheckXMLPermission" returntype="boolean">
		<cfargument name="xmlAttribute" required="true" type="any">
		<cfset var bPermission = True>
	
		<cfif StructKeyExists(arguments.xmlAttribute,"permission")>
			<cfif checkPermission(permissionName=arguments.xmlAttribute.permission,reference="PolicyGroup") NEQ 1>
				<cfset bPermission = False>
			</cfif>
		</cfif>
		<cfreturn bPermission>
	</cffunction>
</cfcomponent>