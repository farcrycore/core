<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/authorisation.cfc,v 1.41.2.3 2005/05/09 06:27:46 guy Exp $
$Author: guy $
$Date: 2005/05/09 06:27:46 $
$Name: milestone_2-3-2 $
$Revision: 1.41.2.3 $

|| DESCRIPTION || 
$Description: authorisation cfc $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->


<cfcomponent displayName="Authorisation" hint="User authorisation">
	<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">
	<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">
	<cfimport taglib="/farcry/fourq/tags" prefix="q4">
	<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">
	
	<cffunction name="collateObjectPermissions" output="No">
		<cfargument name="objectid" required="true">
		<cfargument name="typename" required="false" default="dmNavigation">
			<cfscript>
				if (NOT structKeyExists(request,'factory')) {				
					return;
				}
				if (NOT structKeyExists(request.factory,'oTree')) {
					return;
				}
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
	
	
	<cffunction name="createPermissionBarnacle" hint="Creates a permission for a daemon security user context.Only unique permissions will be accepted." output="No">
		<cfargument name="reference" required="true">
		<cfargument name="status" required="true">
		<cfargument name="policygroupID">
		<cfargument name="permissionID" required="false">
		<cfargument name="permissionName" required="false">
		<cfargument name="permissionType" required="false">
		
		<cfscript>
			if(not isDefined('arguments.permissionID') AND isDefined("arguments.PermissionName") AND isDefined("arguments.PermissionType"))
			{
				stPermission = getPermission(permissionName=arguments.permissionName,permissionType=arguments.permissionType);
				thePermissionID = stPermission.permissionID;
			}	
			else {
				thePermissionID = arguments.permissionid;
			}
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




	
	<cffunction name="createPermission" hint="Creates a new permission in the datastore" output="No">
		<cfargument name="permissionID" required="false" default="-1" hint="Note that permissionID is only handed in during installtation of farcry">
		<cfargument name="permissionName" required="true">
		<cfargument name="permissionType" required="true">
		<cfargument name="permissionNotes" required="false" default="">
		
		<cfscript>
			stPolicyStore = getPolicyStore();
			stPermission = getPermission(permissionName=arguments.permissionName,permissionType=arguments.permissionType);
			stResult=structNew();
			
			if (not structIsEmpty(stPermission))
			{
				stResult.bSuccess = false;
				stResult.message = "Permission already exists";
			}
			else
			{
				switch (application.dbType)
				{
					case "ora":
					{
						sql = "
						INSERT INTO #application.dbowner##stPolicyStore.permissionTable# ( permissionid,permissionName,permissionNotes,permissionType";
						sql = sql & ")";
						if (arguments.permissionId neq -1)
							sql = sql & " VALUES (#arguments.permissionId#,'#arguments.permissionName#','#arguments.permissionNotes#','#arguments.permissionType#'";
						else 
							sql = sql & " VALUES (DMPERMISSION_SEQ.nextval,'#arguments.permissionName#','#arguments.permissionNotes#','#arguments.permissionType#'";
						sql = sql & ")";
						break;	
					}
					case "postgresql":
					{
						sql = "
						INSERT INTO #stPolicyStore.permissionTable# ( permissionName,permissionNotes,permissionType";
						if (arguments.permissionID NEQ -1)
							sql = sql & ",permissionId)";
						else
							sql = sql & ")";
						sql = sql & " VALUES ('#arguments.permissionName#','#arguments.permissionNotes#','#arguments.permissionType#'";
						if (arguments.permissionId neq -1)
							sql = sql & ",#arguments.permissionId#)";
						else
							sql = sql & ")";
						break;	
					} 
					case "mysql":
					{
						sql = "
						INSERT INTO #stPolicyStore.permissionTable# ( permissionName,permissionNotes,permissionType";
						if (arguments.permissionID NEQ -1)
							sql = sql & ",permissionId)";
						else
							sql = sql & ")";
						sql = sql & " VALUES ('#arguments.permissionName#','#arguments.permissionNotes#','#arguments.permissionType#'";
						if (arguments.permissionId neq -1)
							sql = sql & ",#arguments.permissionId#)";
						else
							sql = sql & ")";
						break;
					}
					default:
					{
						sql = "
						INSERT INTO #stPolicyStore.permissionTable# ( permissionName,permissionNotes,permissionType";
						if (arguments.permissionID NEQ -1)
							sql = sql & ",permissionId)";
						else
							sql = sql & ")";
						sql = sql & " VALUES ('#arguments.permissionName#','#arguments.permissionNotes#','#arguments.permissionType#'";
						if (arguments.permissionId neq -1)
							sql = sql & ",#arguments.permissionId#)";
						else
							sql = sql & ")";
					}
				}
				query(sql=sql,dsn=stPolicyStore.datasource);
				stResult.bSuccess = true;
				stResult.message = "Permission successfully added";
				oAuthentication = createObject("component","#application.securitypackagepath#.authentication");
				oAudit = createObject("component","#application.packagepath#.farcry.audit");
				stuser = oAuthentication.getUserAuthenticationData();
					if(stUser.bLoggedIn)
						oaudit.logActivity(auditType="dmSec.createPermission", username=Stuser.userlogin, location=cgi.remote_host, note="permission #arguments.permissionname# of type #arguments.permissiontype# created");	
			}
						
		</cfscript>
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="createPolicyGroup" hint="Creates a new policy group in the datastore" returntype="struct" output="No">
		<cfargument name="policyGroupName" required="true">
		<cfargument name="policyGroupNotes" required="false" default="">
		<cfargument name="policyGroupID">
		<cfscript>
			stPolicyGroup = getPolicyGroup(policyGroupName=arguments.policyGroupName);
			stPolicyStore = getPolicyStore();
			stResult = structNew();
			if (NOT structIsEmpty(stPolicyGroup))
			{
				stResult.bSuccess = false;
				stResult.message = "Policy Group already exists";
			}
			else
			{
				switch (application.dbType)
				{
					case "ora":
					{
						sql = "
							INSERT INTO #application.dbowner##stPolicyStore.PolicyGroupTable# (policyGroupID, policyGroupName,policyGroupNotes )
							VALUES
							(DMPOLICYGROUP_SEQ.nextval,'#arguments.PolicyGroupName#','#arguments.PolicyGroupNotes#')";
						break;	
					}
					case "postgresql":
					{
						sql = "
							INSERT INTO #application.dbowner##stPolicyStore.PolicyGroupTable# ( policyGroupName,policyGroupNotes )
							VALUES
							('#arguments.PolicyGroupName#','#arguments.PolicyGroupNotes#')";
						break;	
					}
					case "mysql":
					{
						sql = "
						INSERT INTO #application.dbowner##stPolicyStore.PolicyGroupTable# ( policyGroupName,policyGroupNotes ";
						if (isDefined("arguments.policyGroupId"))
							sql = sql & ",policyGroupId";
						sql = sql & ")	
						VALUES
						('#arguments.PolicyGroupName#' ,'#arguments.PolicyGroupNotes#'";
						if (isDefined("arguments.policyGroupId"))
							sql = sql & ",#arguments.policyGroupId#";
						sql = sql & ")";	
						break;	
					}
					
					default:
					{
						sql = "
						INSERT INTO #application.dbowner##stPolicyStore.PolicyGroupTable# ( policyGroupName,policyGroupNotes ";
						if (isDefined("arguments.policyGroupId"))
							sql = sql & ",policyGroupId";
						sql = sql & ")	
						VALUES
						('#arguments.PolicyGroupName#' ,'#arguments.PolicyGroupNotes#'";
						if (isDefined("arguments.policyGroupId"))
							sql = sql & ",#arguments.policyGroupId#";
						sql = sql & ")";	
					}
				}

				query(sql=sql,dsn=stPolicyStore.datasource);
				stResult.bSuccess = true;
				stResult.message = "Policy group successfully added";
				oAuthentication = createObject("component","#application.securitypackagepath#.authentication");
				oAudit = createObject("component","#application.packagepath#.farcry.audit");
				stuser = oAuthentication.getUserAuthenticationData();
					if(stUser.bLoggedIn)
						oaudit.logActivity(auditType="dmSec.createPolicyGroup", username=Stuser.userlogin, location=cgi.remote_host, note="policy group #arguments.policygroupname# created");	

			}
				
		</cfscript>
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="checkInheritedPermission" hint="checks whether you have inherited permission to perform an action on an object." output="yes">
		<cfargument name="permissionName" required="true">
		<cfargument name="objectid" required="false">
		<cfargument name="reference" required="false">
		<cfargument name="lPolicyGroupIDs" required="false">

		<cfscript>
			
			oAuthentication = request.dmsec.oAuthentication;
			if(not isDefined('arguments.lPolicyGroupIds'))
			{
				stLoggedInUser = oAuthentication.getUserAuthenticationData();
				if (structKeyExists(stLoggedInUser,"lPolicyGroupIds"))
					arguments.lPolicyGroupIds = stLoggedInUser.lPolicyGroupIDs;
					
			}
			
			if (len(arguments.objectid))
			
			{
				stObjectPermissions = collateObjectPermissions(objectid=arguments.objectid);
				//Dont need this - if we are pasing in an objcetid - then it will always be a tree based permission, therefore permissiontype = 'dmnavigation'
				//stObj = contentObjectGet(objectid=arguments.objectID);
				permissionType = 'dmNavigation';
			}	
			else
			{
				stObjectPermissions = getObjectPermission(reference=arguments.reference);
				permissionType = arguments.reference;
			}
			
			stPermission = getPermission(permissionname=arguments.permissionName,permissionType=permissionType);
			bHasPermission = 0; 
			if( not StructIsEmpty(stPermission) )
			{	
				for( i=1; i lte listlen(arguments.lpolicyGroupIds); i=i+1 )
				{
					policyGroupId = listGetAt( arguments.lpolicyGroupIds, i );
					perm=0;
					
					if( StructKeyExists(stObjectPermissions,policyGroupId) AND StructKeyExists(stObjectPermissions[policyGroupId],stPermission.permissionId))
					{
						perm=stObjectPermissions[policyGroupId][stPermission.permissionId].T;
					}
					
					if( bhasPermission eq 0 )
					{	
						bhasPermission=perm;
					}
					else if (bhasPermission eq -1 AND perm eq 1)
					{
						bhasPermission=perm;
					}
				}
			}
			
			
		</cfscript>
		<cfreturn bHasPermission>
	</cffunction> 
	
	<cffunction name="createPolicyGroupMapping" hint="Creates a new policy group mapping"  returntype="struct" output="No">
		<cfargument name="groupname" required="true">
		<cfargument name="userdirectory" required="true">
		<cfargument name="policyGroupId" required="true">
		
		<cfscript>
			stResult = structNew();
			stResult.bSuccess = true;
			stResult.message = "Policy group successfully created";
			stPolicyStore=getPolicyStore();
			oAuthentication = createObject("component","#application.securitypackagepath#.authentication");
			stGroup = oAuthentication.getGroup(groupName="#arguments.groupName#", userdirectory="#arguments.userDirectory#");
			stPolicyGroup = getPolicyGroup(policyGroupId="#policyGroupId#");
			sql="
				SELECT * FROM #application.dbowner##stPolicyStore.ExternalGroupToPolicyGroupTable#
				WHERE policyGroupId=#arguments.policyGroupId#
				AND upper(ExternalGroupUserDirectory)='#ucase(arguments.userdirectory)#'
			  	AND upper(ExternalGroupName)='#ucase(arguments.groupName)#'";
			qCheckMapping = query(sql=sql,dsn=stPolicyStore.datasource);	
			if (qCheckMapping.recordCount){
				stResult.bSuccess = false;
				stResult.message = "Policy group already exists";
			}	
			else
			{
				sql="
					INSERT INTO #application.dbowner##stPolicyStore.ExternalGroupToPolicyGroupTable#
					( policyGroupId, ExternalGroupUserDirectory, ExternalGroupName )
					VALUES	(#arguments.policyGroupId#,'#arguments.userdirectory#','#arguments.groupName#')";
				query(sql=sql,dsn=stPolicyStore.datasource);
				oAuthentication = createObject("component","#application.securitypackagepath#.authentication");
				oAudit = createObject("component","#application.packagepath#.farcry.audit");
				stuser = oAuthentication.getUserAuthenticationData();
					if(stUser.bLoggedIn)
						oAudit.logActivity(auditType="dmSec.createPolicyGroupMapping", username=Stuser.userlogin, location=cgi.remote_host, note="group #arguments.groupname# mapped to #stPolicyGroup.policyGroupName#");	
			}
		</cfscript>

	<cfreturn stResult>

	</cffunction>
	
	<cffunction name="deletePermission" hint="Delets a permission from the datastore" returntype="struct" output="No">
		<cfargument name="permissionID" required="true">
		
		<cfscript>
			stPermission = getPermission(permissionID=arguments.permissionid);
			stPolicyStore = getPolicyStore();
			sql = "
				DELETE FROM #application.dbowner##stPolicyStore.permissionTable#
				WHERE permissionId='#arguments.permissionId#'";
			query(sql=sql,dsn=stPolicyStore.datasource);
			stResult = structNew();
			stResult.bSuccess = true;
			stResult.message = "Permission successfully deleted";	
			oAuthentication = createObject("component","#application.securitypackagepath#.authentication");
			oAudit = createObject("component","#application.packagepath#.farcry.audit");
			stuser = oAuthentication.getUserAuthenticationData();
				if(stUser.bLoggedIn)
					oAudit.logActivity(auditType="dmSec.deletepermission", username=Stuser.userlogin, location=cgi.remote_host, note="#stPermission.permissionName# deleted");	
		</cfscript>
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="deletePolicyGroup" hint="Deletes a policy group from the data store." output="No">
		<cfargument name="PolicyGroupName">
		<cfargument name="PolicyGroupID">
		
		<cfscript>
			stPolicyStore=getPolicyStore();
			if(isDefined("arguments.policyGroupName"))
				stPolicyGroup = getPolicyGroup(PolicyGroupName="#PolicyGroupName#");
			else
			{
				stPolicyGroup.policyGroupId = arguments.PolicyGroupId;
					
			}	
			sql="
				DELETE FROM #application.dbowner##stPolicyStore.policyGroupTable# WHERE
				PolicyGroupId='#stPolicyGroup.policyGroupId#'";
			query(sql=sql,dsn=stPolicyStore.datasource);
			sql="
				DELETE FROM #application.dbowner##stPolicyStore.externalGroupToPolicyGroupTable#
				WHERE policyGroupId=#stPolicyGroup.policyGroupId#";
			query(sql=sql,dsn=stPolicyStore.datasource);	
			oAuthentication = createObject("component","#application.securitypackagepath#.authentication");
			oAudit = createObject("component","#application.packagepath#.farcry.audit");
			stuser = oAuthentication.getUserAuthenticationData();
				if(stUser.bLoggedIn)
					oAudit.logActivity(auditType="dmSec.deletePolicyGroup", username=Stuser.userlogin, location=cgi.remote_host, note="#stPolicyGroup.policyGroupID# deleted");	
					
		</cfscript>

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
		
	<cffunction name="deletePolicyGroupMapping" output="No">
		<cfargument name="groupname" required="true">
		<cfargument name="userdirectory" required="true">
		<cfargument name="policyGroupID" required="true">

		<cfscript>
			stPolicyStore = getPolicyStore();
			stPolicyGroup = getPolicyGroup(policygroupid=arguments.policygroupid);

			sql="
				DELETE FROM #application.dbowner##stPolicyStore.ExternalGroupToPolicyGroupTable#
				WHERE policyGroupId=#policyGroupId#
				AND upper(ExternalGroupUserDirectory)='#ucase(arguments.userdirectory)#'
				AND upper(ExternalGroupName)='#ucase(arguments.groupName)#'";
			query(sql=sql,dsn=stPolicyStore.datasource);
			oAuthentication = createObject("component","#application.securitypackagepath#.authentication");	
			oAudit = createObject("component","#application.packagepath#.farcry.audit");
			stuser = oAuthentication.getUserAuthenticationData();
				if(stUser.bLoggedIn)
					oAudit.logActivity(auditType="dmSec.deletePolicyGroupMapping", username=Stuser.userlogin, location=cgi.remote_host, note="removed #arguments.groupname# mapping from #stPolicyGroup.policyGroupName#");	
		</cfscript>
	</cffunction>
	
	
	<cffunction name="getPermission" access="public" output="No">
		<cfargument name="permissionID" required="false">
		<cfargument name="permissionName" type="string">
		<cfargument name="permissionType" type="string" required="false">
		
		<cfscript>
			stPolicyStore = getPolicyStore();
			sql = "SELECT * FROM #application.dbowner##stPolicyStore.permissionTable# WHERE ";
			if (isDefined("arguments.permissionName") AND isDefined("arguments.permissionType"))
				sql = sql & "upper(permissionName) = '#ucase(arguments.permissionName)#' AND upper(permissiontype) = '#ucase(arguments.permissionType)#'";
			else
				sql = sql & "permissionid = '#arguments.permissionID#'";
			q = query(sql=sql,dsn=stPolicyStore.datasource);
			if(q.recordCount)
				stPermission = queryToStructure(q); 	
			else
				stPermission = structNew();	
			
		</cfscript>
		
		<cfreturn stPermission>
	</cffunction>	
	
	<cffunction name="getPolicyGroupMappings" output="No">
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
		<cfargument name="policyGroupName" required="false">
		<cfargument name="policyGroupID" required="false">
		
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
	
	<cffunction name="getAllPolicyGroups" hint="Gets all policy groups." returntype="array" output="No">
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
								CROSS JOIN dmPermission p WHERE upper(p.PermissionType)='#ucase(permissionType)#' ) s
								
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
	
		<cfscript>
			stResult = structNew();
			stPolicyStore = getPolicyStore();
			sql = "select distinct(reference1) AS Objectid from dmPermissionBarnacle where upper(reference1) <> 'POLICYGROUP'";
			qReferences = query(sql=sql,dsn=stPolicyStore.datasource);
			//update all the nav permissions
			for (index=1;index LTE qReferences.recordCount;index=index+1)
			{ 
				
				updateObjectPermissionCache(objectid=qReferences.objectid[index],bUseCache=0);
			}
			//update policy group permissions		
			updateObjectPermissionCache(reference="policygroup");
			stResult.bSuccess = true;
			stResult.message = "Permissions cache has been successfully updated";
		</cfscript>
		<cfreturn stResult>
	
	</cffunction>

	<cffunction name="updatePermission" output="No"	>
		<cfargument name="permissionID" required="true">
		<cfargument name="permissionName" required="true">
		<cfargument name="permissionType" required="true">
		<cfargument name="permissionNotes" required="false" default="">
		
		<cfscript>
			stPolicyStore = getPolicyStore();
			sql = "
			UPDATE #application.dbowner##stPolicyStore.permissionTable# SET
			permissionName='#arguments.permissionName#',
			permissionNotes='#arguments.permissionNotes#',
			permissionType='#arguments.permissionType#'
			WHERE permissionId=#arguments.permissionId#";
			query(sql=sql,dsn=stPolicyStore.datasource);
			stResult = structNew();
			stResult.bSuccess = true;
			stResult.message = "Permission successfully added";
			oAuthentication = createObject("component","#application.securitypackagepath#.authentication");
			oAudit = createObject("component","#application.packagepath#.farcry.audit");
			stuser = oAuthentication.getUserAuthenticationData();
				if(stUser.bLoggedIn)
					oAudit.logActivity(auditType="dmSec.updatePermission", username=StUser.userlogin, location=cgi.remote_host, note="#arguments.permissionName# updated");	
		</cfscript>
		<cfreturn stResult>
	</cffunction>	
	
	<cffunction name="updatePolicyGroup" returntype="struct" output="No">
		<cfargument name="policyGroupID" required="true">
		<cfargument name="PolicyGroupName" required="true">
		<cfargument name="PolicyGroupNotes" required="false" default="">
		
		<cfscript>
			stPolicyStore = getPolicyStore();
			sql = "
			UPDATE #application.dbowner##stPolicyStore.PolicyGroupTable# SET
			PolicyGroupName='#arguments.PolicyGroupName#',
			PolicyGroupNotes='#arguments.PolicyGroupNotes#'
			WHERE PolicyGroupId=#arguments.PolicyGroupId#";
			query(sql=sql,dsn=stPolicyStore.datasource);
			stResult = structNew();
			stResult.bSuccess = true;
			stResult.message = "Policy group successfully updated";
			oAuthentication = createObject("component","#application.securitypackagepath#.authentication");
			oAudit = createObject("component","#application.packagepath#.farcry.audit");
			stuser = oAuthentication.getUserAuthenticationData();
				if(stUser.bLoggedIn)
					oAudit.logActivity(auditType="dmSec.updatePolicyGroup", username=StUser.userlogin, location=cgi.remote_host, note="#arguments.policyGroupName# updated");	
		</cfscript>
		<cfreturn stResult>
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
		
		
	
</cfcomponent>