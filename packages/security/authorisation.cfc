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

	<cffunction name="collateObjectPermissions" output="No" returntype="struct" hint="Returns a struct containing the actual, inherited, and tranformed rights for a each role on a given object">
		<cfargument name="objectid" required="true" type="uuid" hint="The object to query" />
		<cfargument name="typename" required="false" default="dmNavigation" hint="Depreciated. Type is now retrieved via findType.">
		
		<cfset var stResult = structnew() />
		<cfset var qPermissions = "" />
		<cfset var qRoles = "" />
		<cfset var stTemp = structnew() />
		
		<farcry:deprecated message="authorisation.collateObjectPermissions() should be replaced by calls to farBarnacle" />
		
		<cfquery datasource="#application.dsn#" name="qPermissions">
			select	p.objectid,p.label
			from	#application.dbowner#farPermission p
					inner join
					#application.dbowner#farPermission_relatedtypes pt
					on p.objectid=pt.parentid
			where	data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.security.factory.barnacle.findType(arguments.objectid)#" />
		</cfquery>
		
		<cfquery datasource="#application.dsn#" name="qRoles">
			select	objectid,label
			from	#application.dbowner#farRole
		</cfquery>
		
		<!--- Get the right for each permission in each role --->
		<cfloop query="qRoles">
			<cfset stResult[qRoles.label[qRoles.currentrow]] = structnew() />
		
			<cfloop query="qPermissions">
				<cfset stResult[qRoles.label[qRoles.currentrow]][qPermissions.label[qPermissions.currentrow]] = structnew() />
				<cfset stTemp = stResult[qRoles.label[qRoles.currentrow]][qPermissions.label[qPermissions.currentrow]] />
				
				<!--- Actual right set for this item --->
				<cfset stTemp.A = application.security.factory.barnacle.getRight(role=qRoles.objectid[qRoles.currentrow],permission=qPermissions.objectid[qPermissions.currentrow],object=arguments.objectid) />
				
				<!--- IF this permission was inherited, what would it inherit --->
				<cfset stTemp.I = application.security.factory.barnacle.getInheritedRight(role=qRoles.objectid[qRoles.currentrow],permission=qPermissions.objectid[qPermissions.currentrow],object=arguments.objectid) />
				
				<!--- What value should it actually use (transformed?) - use inherited if actual says inherit --->
				<cfif stTemp.A>
					<cfset stTemp.T = stTemp.A />
				<cfelse>
					<cfset stTemp.T = stTemp.I />
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="createPermissionBarnacle" hint="Creates a permission for a daemon security user context.Only unique permissions will be accepted." output="true" returntype="void">
		<cfargument name="reference" required="true">
		<cfargument name="status" required="true">
		<cfargument name="policygroupID">
		<cfargument name="policygroupname">
		<cfargument name="permissionID" required="false">
		<cfargument name="permissionName" required="false">
		<cfargument name="permissionType" required="false">
		
		<farcry:deprecated message="authorisation.createPermissionBarnacle() should be replaced with a call to farBarnacle.createData()" />
		
		<!--- If permission id was not provided, figure it out --->
		<cfif not isvalid("uuid",arguments.permissionid) and len(arguments.permissionname)>
			<cfset arguments.permissionid = application.security.factory.permission.getID(arguments.permissionname) />
		<cfelseif not isvalid("uuid",arguments.permissionid) and not len(arguments.permissionname)>
			<!--- Either the id or the name must be provided --->
			<cfthrow message="Create permission barnacle requires the permission id or name" />
		</cfif>
		
		<!--- If policy id was not provided, figure it out --->
		<cfif not isvalid("uuid",arguments.policygroupid) and len(arguments.policygroupname)>
			<cfset arguments.policygroupid = application.security.factory.role.getID(arguments.policygroupname) />
		<cfelseif not isvalid("uuid",arguments.policygroupid) and not len(arguments.policygroupname)>
			<!--- Either the id or the name must be provided --->
			<cfthrow message="Create permission barnacle requires the policy id or name" />
		</cfif>
		
		<cfif isvalid("uuid",arguments.reference)>
			<cfset application.security.factory.barnacle.updateRight(role=arguments.policygroupid,permission=arguments.permissionid,object=arguments.reference,right=arguments.status) />
		<cfelse>
			<cfset application.security.factory.role.updatePermission(role=arguments.policygroupid,permission=arguments.permissionid,has=(arguments.status eq 1)) />
		</cfif>		
	</cffunction>
	
	<cffunction name="deletePermissionBarnacle" hint="Deletes a permission for a daemon security user context" output="No">
		<cfargument name="objectid" type="UUID" required="true">
		
		<farcry:deprecated message="authorisation.deletePermissionBarnacle() should be replaced with a call to farBarnacle.deleteObjectBarnacles()" />
		
		<cfset application.security.factory.barnacle.deleteObjectBarnacles(arguments.objectid) />
	</cffunction>
	
	<cffunction name="checkPermission" hint="Checks whether you have permission to perform an action on an object. Note: A positive permission from one group overides a negative permission from another group, i.e. they are permissive(heh!)." output="No">
		<cfargument name="permissionName" required="true" />
		<cfargument name="reference" required="false" default="" />
		<cfargument name="objectID" required="false" default="" />
		<cfargument name="lPolicyGroupIDs" required="false" default="" />
		
		<farcry:deprecated message="authorisation.checkPermission() should be replaced by call to farRole.checkPermission()" />
		
		<cfif isvalid("uuid",arguments.reference)>
			<cfset arguments.objectid = arguments.reference />
		</cfif>
		
		<cfif len(arguments.objectid)>
			<cfreturn application.security.checkPermission(role=arguments.lPolicyGroupIDs,permission=arguments.permissionname,objectid=arguments.objectid) />
		<cfelse>
			<cfreturn application.security.checkPermission(role=arguments.lPolicyGroupIDs,permission=arguments.permissionname) />
		</cfif>
	</cffunction>
	
	<cffunction name="createPermission" hint="Creates a new permission in the datastore" output="True">
		<cfargument name="permissionID" required="false" default="-1" hint="Note that permissionID is only handed in during installtation of farcry">
		<cfargument name="permissionName" required="true">
		<cfargument name="permissionType" required="true">
		<cfargument name="permissionNotes" required="false" default="">
		
		<cfset var stObj = structnew()>
		<cfset var stResult = StructNew()>
		<cfset stResult.returncode = 1>
		<cfset stResult.returnmessage = "">
		
		<farcry:deprecated message="authorisation.createPermission() should be replaced by call to farPermission.createData()" />
		
		<!--- Create and add permission --->
		<cfset stObj.title = arguments.permissionname />
		<cfset stObj.relatedtypes = arraynew(1) />
		<cfset stObj.relatedtypes[1] = arguments.permissiontype />
		<cfset application.security.factory.permission.createdata(stProperties=stObj) />

		<cfreturn stLocal.streturn>
	</cffunction>
	
	<cffunction name="createPolicyGroup" hint="Creates a new policy group in the datastore" returntype="any" output="No">
		<cfargument name="policyGroupName" required="true" type="string">
		<cfargument name="policyGroupNotes" required="false" default="" type="string">
		<cfargument name="policyGroupID" required="false" type="numeric">
		
		<cfset var stObj = structnew() />
		<cfset var stReturn = StructNew() />
		<cfset stReturn.returncode = 1 />
		<cfset stReturn.returnmessage = "" />
		
		<farcry:deprecated message="authorisation.createPolicyGroup() should be replaced by call to farRole.createData()" />
		
		<!--- Create and add role --->
		<cfset stObj.title = arguments.policyGroupName />
		<cfset stObj.groups = arraynew(1) />
		<cfset stObj.permissions = arraynew(1) />
		<cfset application.security.factory.role.createData(stProperties=stObj) />

		<cfreturn stReturn />
	</cffunction>

	<cffunction name="copyPolicyGroup" hint="Copys an existing policy group in the datastore" returntype="struct" output="no">
		<cfargument name="stForm" required="true" type="struct" hint="Contains a sourcePolicyGroupID and a name value" />
		
		<cfset var stReturn = StructNew() />
		<cfset stReturn.returncode = 1 />
		<cfset stReturn.returnmessage = "" />
		
		<farcry:deprecated message="authorisation.createPolicyGroup() should be replaced by call to farRole.createData()" />

		<cfset application.security.factory.role.copyRole(arguments.stForm.sourcePolicyGroupID,arguments.stForm.name) />

		<cfreturn stReturn />		
	</cffunction>

	<cffunction name="checkInheritedPermission" hint="DEPRICATED... USE checkPermission instead." output="no">
		
		<farcry:deprecated message="authorisation.checkInheritedPermission() should be replaced by call to farRole.checkPermission()" />
		
		<cfreturn checkPermission(argumentCollection=arguments) />
		<!--- TODO: log depricated --->
	</cffunction> 
	
	<cffunction name="createPolicyGroupMapping" hint="Creates a new policy group mapping"  returntype="struct" output="No">
		<cfargument name="groupname" type="string" required="true" />
		<cfargument name="userdirectory" type="string" required="true" />
		<cfargument name="policyGroupId" type="uuid" required="true" />

		<cfset var stReturn = StructNew() />
		<cfset var stRole = application.security.factory.role.getData(arguments.policyGroupId) />
		<cfset var i = 0 />
		
		<farcry:deprecated message="authorisation.createPolicyGroupMapping() should be replaced by call to farRole.setData()" />
		
		<cfset stReturn.returncode = 1 />
		<cfset stReturn.returnmessage = application.rb.getResource('forms.message.policygroupadded','Policy Group Added') />
		
		<cfparam name="stRole.groups" default="#arraynew(1)#" />
		<cfloop from="1" to="#arraylen(stRole.groups)#" index="i">
			<cfif stRole.groups[i] eq "#arguments.groupname#_#arguments.userdirectory#">
				<!--- Already there --->
				<cfreturn stReturn />
			</cfif>
		</cfloop>
		
		<cfset arrayappend(stRole.groups,"#arguments.groupname#_#arguments.userdirectory#") />
		<cfset application.security.factory.role.setData(stProperties=stRole) />
		
		<!--- Return message --->
		<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="deletePermission" hint="Delets a permission from the datastore" returntype="struct" output="no">
		<cfargument name="permissionID" type="uuid" required="true" />
		
		<cfset var stReturn = StructNew()>
		
		<cfset stReturn.returncode = 1>
		<cfset stReturn.returnmessage = "">
		
		<farcry:deprecated message="authorisation.deletePermission() should be replaced by call to farPermission.delete()" />
		
		<cfset application.security.factory.permission.delete(arguments.permissionID) />
		
		<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="deletePolicyGroup" hint="Deletes a policy group from the data store." output="No" returntype="struct">
		<cfargument name="PolicyGroupName" required="false" type="string" default="">
		<cfargument name="PolicyGroupID" required="false" type="string" default="">
		
		<cfset var stReturn = StructNew() />
		
		<cfset stReturn.returncode = 1 />
		<cfset stReturn.returnmessage = "" />
		
		<farcry:deprecated message="authorisation.deletePolicyGroup() should be replaced by call to farRole.delete()" />
		
		<cfif not isvalid("uuid",arguments.policygroupid)>
			<cfset arguments.policygroupid = application.security.factory.role.getID(arguments.policygroupname) />
		</cfif>
		<cfset application.security.factory.role.delete(arguments.policygroupid) />

		<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="deletePolicyStore" hint="Hmmm this does the same thing as delete policyGroup" returntype="struct" output="No">
		<cfargument name="policyGroupID" required="true">
		
		<farcry:deprecated message="authorisation.deletePolicyStore() should be replaced by call to farRole.delete()" />
		
		<cfreturn deletePolicyGroup(argumentCollection=arguments) />
	</cffunction>
	
	<cffunction name="deletePolicyGroupMapping" returntype="struct" output="false">
		<cfargument name="groupname" required="true" type="string" hint="The user directory group" />
		<cfargument name="userdirectory" required="true" type="string" hint="The user directory the group is from" />
		<cfargument name="policyGroupID" required="true" type="uuid" hint="The policy to update" />
		
		<cfset var stReturn = StructNew() />
		<cfset var stRole = application.security.factory.role.getData(arguments.policyGroupID) />
		
		<farcry:deprecated message="authorisation.deletePolicyGroupMapping() should be replaced by call to farRole.setData()" />
		
		<cfset stReturn.returncode = 1 />
		<cfset stReturn.returnmessage = "" />
		
		<cfparam name="stRole.groups" default="#arraynew(1)#" />
		<cfloop from="#arraylen(stRole.groups)#" to="1" index="i" step="-1">
			<cfif stRole.groups[i] eq "#arguments.groupname#_#arguments.userdirectory#">
				<cfset arraydeleteat(stRole.groups,i) />
			</cfif>
		</cfloop>
		<cfset application.security.factory.role.setData(stProperties=stRole) />

		<cfreturn stReturn>
	</cffunction>
	
	<cffunction name="getPermission" access="public" output="false" returntype="struct">
		<cfargument name="permissionID" required="false">
		<cfargument name="permissionName" type="string">
		<cfargument name="permissionType" type="string" required="false">
		
		<cfset var stPermission = structnew() />
		<cfset var stResult = structnew() />
		
		<farcry:deprecated message="authorisation.getPermission() should be replaced by call to farPermission.getData()" />
		
		<cfif not isvalid("uuid",arguments.permissionID)>
			<cfset arguments.permissionID = application.security.factory.permission.getID(arguments.permissionName) />
		</cfif>
		<cfset stPermission = application.security.factory.permission.getData(arguments.permissionID) />
		
		<cfset stResult.permissionID = stPermission.objectid />
		<cfset stResult.permissionName = stPermission.title />
		<cfset stResult.permissionNotes = "" />
		<cfif arraylen(stResult.relatedtypes)>
			<cfset stResult.permissionType = arraytolist(stResult.relatedtypes) />
		<cfelse>
			<cfset stResult.permissionType = "PolicyGroup" />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>	

	<cffunction name="getPolicyGroupMappings" output="yes">
		<cfargument name="lGroupNames" required="true" type="string" hint="List of groups to get mappings for" />
		<cfargument name="userDirectory" required="true" type="string" hint="User directory the groups are part of" />
		
 		<cfset var qMappings = "" />
		<cfset var thisgroup = "" />
		<cfset var groups = "" />
		
		<farcry:deprecated message="authorisation.getPolicyGroupMappings() should be replaced by queries on farRole_groups table" />
		
		<!--- Convert group names --->
		<cfloop list="#arguments.lGroupNames#" index="thisgroup">
			<cfset groups = listappend(groups,"#thisgroup#_#arguments.userdirectory#") />
		</cfloop>
		
		<cfquery datasource="#application.dsn#" name="qMappings">
			select distinct parentid
			from	#application.dbowner#farRole_groups
			where	data in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#groups#" />)
		</cfquery>
		
		<cfreturn valuelist(qMappings.parentid) />
	</cffunction>
	
	<cffunction name="getPolicyStore" output="No">
		
		<farcry:deprecated message="authorisation.getPolicyStore() should no longer be used" />
	
		<cfreturn structnew() />
	</cffunction>
	
	<cffunction name="getMultiplePolicyGroupMappings" hint="Retrieves all group mappings in the form of an array of groupName+userdirectory structures. Filtered by lUserdirectory,policygroupname/policygroupid." output="No">
		<cfargument name="userdirectory" default="" required="false">
		<cfargument name="lGroupNames" default="" required="false">
		<cfargument name="policyGroupId" required="false" type="string" default="">
		
		<cfset var aResult = arrayNew(1) />
		<cfset var stnew = structnew() />
		<cfset var qMappings = "" />
		
		<farcry:deprecated message="authorisation.getMultiplePolicyGroupMappings() should be replaced by queries to farRole_groups" />
		
		<cfquery datasource="#application.dsn#" name="qMappings">
			select	r.objectid, r.title, tg.data
			from	#application.dbowner#farRole r
					inner join
					#application.dbowner#farRole_groups rg
					on r.objectid = rg.parentid
			<cfif len(arguments.policyGroupId)>
				where	parentid in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.policyGroupId#" />)
			</cfif>
		</cfquery>
		
		<cfloop query="qMappings">
			<cfif (not len(arguments.userdirectory) or listcontains(arguments.userdirectory,listlast(data,'_'))) and (not (len(arguments.lGroupNames) or listcontains(arguments.lGroupNames,listfirst(data,'_'))))>
				<cfset stNew = structnew() />
				<cfset stNew.PolicyGroupID = objectid />
				<cfset stNew.PolicyGroupName = title />
				<cfset stNew.ExternalGroupUserDirectory = listlast(data,'_') />
				<cfset stNew.ExternalGroupName = listfirst(data,'_') />
				<cfset arrayappend(aResult,stNew) />
			</cfif>
		</cfloop>
		
		<cfreturn aResult />
	</cffunction>
	
	<cffunction name="getPolicyGroupUsers" hint="Retrieve list of usernames that are members of a specified Policy Group" output="No">
		<cfargument name="lPolicyGroupIds" required="false" default="">
		
		<cfset var aUsers = arraynew(1) />
		<cfset var ud = "" />
		<cfset var user = "" />
		
		<farcry:deprecated message="authorisation.getPolicyGroupUsers() should be replaced by farRole" />
		
		<cfquery datasource="#application.dsn#" name="qGroups">
			select distinct data
			from	farRole_groups
			where	parentid in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.lPolicyGroupIds#">)
		</cfquery>
		
		<cfloop query="qGroups">
			<cfloop list="#application.security.userdirectories['CLIENTUD'].getGroupUsers(listfirst(data,'_'))#" index="user">
				<cfset arrayappend(aUsers,"#user#_#listlast(data,'_')#") />
			</cfloop>
		</cfloop>
		
		<cfreturn aUsers>
	</cffunction>	
	
	<cffunction name="getAllPermissions" output="No" returntype="array" hint="Returns an array of property structs">
		<cfargument name="permissionType" required="false" default=""> 

		<cfset var qPermissions = "" />
		<cfset var aResult = arraynew(1) />
		<cfset var stPermission = structnew() />

		<farcry:deprecated message="authorisation.getAllPermissions() should be replaced by a query on farPermission" />
		
		<cfif len(arguments.permissionType) and arguments.permissionType neq "PolicyGroup">
			<cfquery datasource="#application.dsn#" name="qPermissions">
				select	objectid, title
				from	#application.dbowner#farPermission p
						inner join
						#application.dbowner#farPermission_relatedtypes pt
						on p.objectid=pt.parentid
				where	pt.data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permissionType#" />
			</cfquery>
			
			<cfloop query="qPermissions">
				<cfset stPermission = structnew() />
				<cfset stPermission.permissionId = objectid />
				<cfset stPermission.permissionName = title />
				<cfset stPermission.permissionNote = "" />
				<cfset stPermission.permissionType = arguments.permissionType />
				<cfset arrayappend(aResult, stPermission) />
			</cfloop>
		<cfelse>
			<cfquery datasource="#application.dsn#" name="qPermissions">
				select	objectid, title
				from	#application.dbowner#farPermission
				where	objectid not in (
							select distinct parentid
							from	farPermission_relatedtypes
						)
			</cfquery>
			
			<cfloop query="qPermissions">
				<cfset stPermission = structnew() />
				<cfset stPermission.permissionId = objectid />
				<cfset stPermission.permissionName = title />
				<cfset stPermission.permissionNote = "" />
				<cfset stPermission.permissionType = "PolicyGroup" />
				<cfset arrayappend(aResult, stPermission) />
			</cfloop>
		</cfif>
		
		<cfreturn aResult />
	</cffunction>
	
	<cffunction name="getPolicyGroup" returntype="struct" output="No">
		<cfargument name="policyGroupName" required="false" default="" type="string">
		<cfargument name="policyGroupID" required="false" default="" type="string">
		
		<cfset var stResult = structnew() />
		<cfset var stRole = structnew() />
		
		<farcry:deprecated message="authorisation.getPolicyGroup() should be replaced by farRole.getData()" />
		
		<!--- If the id wasn't provided, get it --->
		<cfif not isvalid("uuid",arguments.policygroupid)>
			<cfset arguments.policygroupid = application.security.factory.role.getID(arguments.policyGroupName) />
		</cfif>
		
		<cfset stRole = application.security.factory.role.getData(arguments.policyGroupId) />
		
		<cfset stResult.PolicyGroupId = stRole.objectid />
		<cfset stResult.PolicyGroupName = stRole.title />
		<cfset stResult.PolicyGroupNotes = "" />
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="getAllPolicyGroups" hint="Gets all policy groups." returntype="array" output="Yes">
		
		<cfset var aResult = arraynew(1) />
		<cfset var qRoles = "" />
		
		<farcry:deprecated message="authorisation.getAllPolicyGroups() should be replaced by a query on farRole" />
		
		<cfquery datasource="#application.dsn#" name="qRoles">
			select	objectid
			from	farRole
		</cfquery>
		
		<cfloop query="qRoles">
			<cfset arrayappend(aResult,getPolicyGroup(objectid)) />
		</cfloop>
		
		<cfreturn aResult />
	</cffunction>
	
	<cffunction name="getObjectPermission" output="No">
		<cfargument name="reference" required="false" default="" />
		<cfargument name="objectID" required="false" default="" />
		<cfargument name="lrefs" required="false" default="" />
		<cfargument name="bUseCache" required="false" default="1" />
		
		<cfset var role = "" />
		<cfset var permission = "" />
		<cfset var stResult = structnew() />
		
		<farcry:deprecated message="authorisation.getObjectPermission() should be replaced by farBarnacle.getRight()" />
		
		<!--- Reference, objectid and lrefs are equivilent --->
		<cfif not len(arguments.reference)>
			<cfset argument.reference = arguments.object />
		</cfif>
		<cfif not len(arguments.lRefs)>
			<cfset arguments.lrefs = arguments.reference />
		</cfif>

		<!--- Only the last item is actually returned --->
		<cfset arguments.objectid = listlast(arguments.lrefs) />
		
		<cfloop list="#application.security.factory.role.getAllRoles()#" index="role">
			<cfset stResult[role] = structnew() />
			
			<cfloop list="#application.security.factory.permission.getAllPermissions(application.security.factory.permission.findType(arguments.objectid))#" index="permission">
				<cfset stResult[role][permission] = structnew() />
				
				<cfif isvalid("uuid",arguments.objectid)>
					<cfset stResult[role][permission].A = application.security.factory.barnacle.getRight(role=role,permission=permission,object=arguments.objectid,forcerefresh=(not arguments.bUseCache)) />
					<cfset stResult[role][permission].I = application.security.factory.barnacle.getInheritedRight(role=role,permission=permission,object=arguments.objectid,forcerefresh=(not arguments.bUseCache)) />
					
					<cfif stResult[role][permission].A eq 0>
						<cfset stResult[role][permission].T = stResult[role][permission].I />
					<cfelse>
						<cfset stResult[role][permission].T = stResult[role][permission].A />
					</cfif>
				<cfelse>
					<cfset stResult[role][permission].A = application.security.factory.role.getRight(role=role,permission=permission,forcerefresh=(not arguments.bUseCache)) />
					<cfset stResult[role][permission].I = stResult[role][permission].A />
					<cfset stResult[role][permission].T = stResult[role][permission].A />
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn stResult />
	</cffunction>		
	
	<cffunction name="reInitPermissionsCache" hint="Refreshes server permissions cache from existing database permissions" returntype="struct" output="No">

		<cfset var stReturn = StructNew()>
		
		<cfset stReturn.returncode = 1>
		<cfset stReturn.returnmessage = "Permissions cache has been successfully updated">
		
		<farcry:deprecated message="authorisation.reInitPermissionsCache() should be replaced with application.security.initCache()" />
		
		<cfset application.security.initCache() />

		<cfreturn stReturn />
	</cffunction>

	<cffunction name="updatePermission" output="No" returntype="struct">
		<cfargument name="permissionID" required="true" />
		<cfargument name="permissionName" required="true" />
		<cfargument name="permissionType" required="true" />
		<cfargument name="permissionNotes" required="false" default="" />
		
		<cfset var stReturn = StructNew() />
		<cfset var stPermission = structnew() />
		
		<farcry:deprecated message="authorisation.updatePermission() should be replaced by farPermission.setData()" />
		
		<cfset stReturn.returncode = 1>
		<cfset stReturn.returnmessage = "">		

		<cfset stPermission = application.security.factory.permission.getData(arguments.permissionID) />
		
		<cfset stPermission.title = arguments.permissionName />
		<cfset stPermission.relatedtypes = arraynew(1) />
		<cfif len(arguments.permissionType)>
			<cfset stPermission.relatedtypes[1] = arguments.permissionType />
		</cfif>
		
		<cfset application.security.factory.permission.setData(stProperties=stPermission) />

		<cfreturn stReturn />
	</cffunction>	
	
	<cffunction name="updatePolicyGroup" returntype="struct" output="No">
		<cfargument name="policyGroupID" required="true">
		<cfargument name="PolicyGroupName" required="true">
		<cfargument name="PolicyGroupNotes" required="false" default="">
		
		<cfset var stReturn = StructNew() />
		<cfset var stRole = structnew() />
		
		<farcry:deprecated message="authorisation.updatePolicyGroup() should be replaced by farRole.setData()" />
		
		<cfset stReturn.returncode = 1>
		<cfset stReturn.returnmessage = "">		

		<cfset stRole = application.security.factory.role.getData(arguments.policygroupid) />
		
		<cfset stRole.title = arguments.PolicyGroupName />
		
		<cfset application.security.factory.permission.setData(stProperties=stPermission) />

		<cfreturn stReturn />
	</cffunction>	
	
	<cffunction name="updateObjectPermissionCache" output="No">
		<cfargument name="objectid">
		<cfargument name="reference">
		<cfargument name="bRevalidateCache" required="false" default="1">
		
		<cfset var role = "" />
		<cfset var permission = "" />
		<cfset var permissions = application.security.factory.permission.getAllPermissions(arguments.objectid) />
		<cfset var roles = application.security.factory.role.getAllRoles() />
		
		<farcry:deprecated message="authorisation.updateObjectPermissionCache() should be replaced by clearing application.security.cache struct or calling farBarnacle.getRight with forcerefresh=true" />
		
		<cfloop list="#roles#" index="role">
			<cfloop list="#permissions#" index="permission">
				<cfset application.security.factory.barnacle.getRight(role=role,permission=permission,object=arguments.objectid,forcerefresh=true) />
			</cfloop>
		</cfloop>
	</cffunction> 

	<cffunction name="importPolicyGroup" access="public" hint="exports the policy group as a wddx file" returntype="struct">
		<cfargument name="stForm" required="true" type="struct" hint="form variables passed form editform">
		
		<cfset var stLocal = StructNew()>
		<cfset stLocal.streturn = StructNew()>
		<cfset stLocal.streturn.returncode = 1>
		<cfset stLocal.streturn.returnmessage = "">

		<farcry:deprecated message="authorisation.importPolicyGroup() doesn't do anything - why are you using it?" />
		
		<cfreturn  stLocal.streturn>
	</cffunction>
	
	<cffunction name="fListUsersByPermssion" access="public" hint="returns list of user objectids for a particular permission" returntype="struct">
		<cfargument name="permissionName" required="false" default="" type="string">
		<cfargument name="permissionID" required="false" default="" type="string">
		
		<cfset var stReturn = StructNew() />
		<cfset var qRoles = "" />
		<cfset var qGroups = "" />

		<farcry:deprecated message="authorisation.fListUsersByPermssion() should be replaced by farPermission.getUsers()" />
		
		<!--- If Id wasn't provided, get it --->
		<cfif not isvalid("uuid",arguments.permissionid)>
			<cfset arguments.permissionid = application.security.factory.permission.getID(arguments.permissionname) />
		</cfif>
		
		<cfset stReturn.lObjectIDs = application.security.factory.permission.getUsers(arguments.permissionid) />
		<cfset stReturn.bSuccess = true />
		<cfset stResurn.message = "" />

		<cfreturn stReturn />
	</cffunction>

</cfcomponent>