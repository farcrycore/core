<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<cfcomponent displayname="Role" extends="types" output="false" hint="Groups can be assigned to any number of Roles.  Roles in turn are collections of permissions that determine what priveleges a specific group of users has within the system." bsystem="true">
<!---------------------------------------------- 
type properties
----------------------------------------------->
	<cfproperty name="title" type="string" default="" hint="The name of the role" bLabel="true" ftSeq="1" ftWizardStep="Groups" ftLabel="Title" ftType="string" />
	<cfproperty name="isdefault" type="boolean" default="0" hint="True if this is a default role. Every user will be assigned these permissions." ftSeq="2" ftWizardStep="Groups" ftLabel="Default role" ftType="boolean" />
	<cfproperty name="aGroups" type="array" default="" hint="The user directory groups that this role has been assigned to" ftSeq="3" ftWizardStep="Groups" ftLabel="Groups" ftType="array" ftJoin="farRole" ftRenderType="list" ftLibraryData="getGroups" ftShowLibraryLink="false" />
	<cfproperty name="aPermissions" type="array" hint="The simple permissions that are granted as part of this role" ftSeq="11" ftWizardStep="Permissions" ftLabel="Permissions" ftJoin="farPermission" />
	<cfproperty name="webskins" type="longchar" default="" hint="A list of wildcard items that match the webkins this role can access" ftSeq="21" ftWizardStep="Webskins" ftLabel="Webskins" ftType="webskinfilter" />

<!---------------------------------------------- 
object methods
----------------------------------------------->
	<cffunction name="getGroups" access="public" output="false" returntype="query" hint="Returns a query of UD groups">
		<cfset var qResult = querynew("objectid,label","varchar,varchar") />
		<cfset var ud = "" />
		<cfset var i = 0 />
		<cfset var aAllGroups = arraynew(1) />
		
		<cfif structkeyexists(application,"security") and structkeyexists(application.security,"userdirectories")>
			<cfloop collection="#application.security.userdirectories#" item="ud">
				<cfset aAllGroups = application.security.userdirectories[ud].getAllGroups() />
				<cfloop from="1" to="#arraylen(aAllGroups)#" index="i">
					<cfset queryaddrow(qResult) />
					<cfset querysetcell(qResult,"objectid","#aAllGroups[i]#_#ud#") />
					<cfset querysetcell(qResult,"label","#aAllGroups[i]# (#application.security.userdirectories[ud].title#)")>
				</cfloop>
			</cfloop>
		</cfif>
		
		<cfreturn qResult />
	</cffunction>
	
	<cffunction name="groupsToRoles" access="public" output="false" returntype="string" hint="Converts a list/array of user directory groups to their equivilent Farcry roles">
		<cfargument name="groups" type="Any" required="true" hint="The groups to convert" />
		
		<cfset var result = "" />
		<cfset var i = "" />
		<cfset var qRoles = querynew("empty") />
		
		<cfif not isarray(arguments.groups)>
			<cfset arguments.groups = listtoarray(arguments.groups) />
		</cfif>
		
		<cfloop from="1" to="#arraylen(arguments.groups)#" index="i">
			<cfquery datasource="#application.dsn#" name="qRoles">
				select	*
				from	#application.dbowner#farRole_aGroups
				where	lower(data)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.groups[i])#" />
			</cfquery>
			
			<cfset result = application.factory.oUtils.listMerge(result,valuelist(qRoles.parentid)) />		
		</cfloop>
		
		<cfreturn result />
	</cffunction>

	<cffunction name="rolesToGroups" access="public" output="false" returntype="string" hint="Converts a list/array of FarCry roles to their equivilent user directory groups">
		<cfargument name="roles" type="Any" required="true" hint="The roles to convert" />
		
		<cfset var result = "" />
		<cfset var role = "" />
		<cfset var qGroups = querynew("empty") />
		
		<cfif isarray(arguments.roles)>
			<cfset arguments.roles = arraytolist(arguments.roles) />
		</cfif>
		
		<cfif len(arguments.roles)>
			<cfquery datasource="#application.dsn#" name="qGroups">
				select	*
				from	#application.dbowner#farRole_aGroups
				where	0=1
				<cfloop list="#arguments.roles#" index="role">
					<cfif isvalid("uuid",role)>
						or parentid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#role#">
					<cfelse>
						or parentid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getID(role)#" />
					</cfif>
				</cfloop>
			</cfquery>
			
			<cfreturn valuelist(qGroups.data) />
		<cfelse>
			<cfreturn "" />
		</cfif>
	</cffunction>

	<cffunction name="getAuthenticatedProfiles" access="public" output="true" returntype="string" hint="Returns an array of the profile ids of users with the specified roles">
		<cfargument name="roles" type="string" required="true" hint="The roles to query" />
		<cfargument name="requireall" type="string" required="false" default="false" hint="Set to true if this function should only return users with ALL specified roles" />
		
		<cfset var role = "" />
		<cfset var group = "" />
		<cfset var started = false />
		<cfset var users = arraynew(1) />
		<cfset var i = 0 />
		<cfset var result = "" />
		<cfset var qProfiles = querynew("empty") />
		<cfset var userlist = "" />
		
		<cfloop list="#arguments.roles#" index="role">
			<cfset arrayappend(users,"") />
			<cfloop list="#rolesToGroups(role)#" index="group">
				<cftry>
				<cfset userlist = arraytolist(application.security.userdirectories[listlast(group,'_')].getGroupUsers(listfirst(group,'_'))) />
				<cfcatch>
					<cftrace type="warning" category="farRole.getAuthenticatedProfiles" text="Could not generate userlist." var="cfcatch.message" />
				</cfcatch>
				</cftry>
				<cfloop list="#userlist#" index="user">
					<cfif not listcontains(users[arraylen(users)],"#user#_#listlast(group,'_')#")>
						<cfset users[arraylen(users)] = listappend(users[arraylen(users)],"#user#_#listlast(group,'_')#") />
					</cfif>
				</cfloop>
			</cfloop>
		</cfloop>
		
		<cfif arraylen(users) eq 0>
			<cfreturn "" />
		<cfelse>
			<cfloop from="1" to="#arraylen(users)#" index="i">
				<cfif arguments.requireall and started>
					<cfset result = application.factory.oUtils.listIntersection(result,users[i]) />
				<cfelse>
					<cfset result = application.factory.oUtils.listMerge(result,users[i]) />
				</cfif>
			</cfloop>
			
			<cfset started = true />
			
			<cfif len(result)>
				<cfquery datasource="#application.dsn#" name="qProfiles">
					select	objectid
					from	#application.dbowner#dmProfile
					where	username in (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" list="true" value="#result#" />) 
				</cfquery>
				
				<cfreturn valuelist(qProfiles.objectid) />
			<cfelse>
				<cfreturn "" />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="getRolesWithPermission" access="public" returntype="string" description="Returns a list of the roles that have the specified permission" output="false">
		<cfargument name="permission" type="string" required="true" hint="The permission to look for" />
		<cfargument name="type" type="string" required="false" default="" hint="The type of related object" />
		<cfargument name="objectid" type="uuid" required="false" default="" hint="The objectid of the related object" />
		
		<cfset var qRoles = querynew("empty") />
		<cfset var result = "" />
		<cfset var haspermission = "" />
		
		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
		
		<cfquery datasource="#application.dsn#" name="qRoles">
			select distinct objectid,title
			from	#application.dbowner#farRole
		</cfquery>
		
		<cfif len(arguments.permission)>
			<cfloop query="qRoles">
				<sec:CheckPermission permission="#arguments.permission#" type="#arguments.type#" objectid="#arguments.objectid#" roles="#qRoles.title#" result="haspermission" />
				<cfif haspermission>
					<cfset result = listappend(result,qRoles.objectid) />
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getRight" access="public" output="false" returntype="numeric" hint="Returns the right for the specfied permission">
		<cfargument name="role" type="string" required="true" hint="The roles to check" />
		<cfargument name="permission" type="string" required="false" default="" hint="The permission to retrieve" />
		
		<cfset thisrole = "" />
		<cfset thisresult = -1 />
		<cfset qRole = "" />
		
		<cfif not isvalid("uuid",arguments.permission)>
			<cfset arguments.permission = application.security.factory.permission.getID(arguments.permission) />
			
			<cfif not len(arguments.permission)>
				<cfreturn 1 />
			</cfif>
		</cfif>
		
		<cfloop list="#arguments.role#" index="thisrole">
			<!--- If the name of the role was passed in, get the objectid --->
			<cfif not isvalid("uuid",thisrole)>
				<cfset thisrole = getID(thisrole) />
			</cfif>
			
			<cfquery datasource="#application.dsn#" name="qRole" result="stResult">
				select	*
				from	#application.dbowner#farRole_aPermissions
				where	parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#thisrole#" />
						and data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permission#" />
			</cfquery>
			
			<cfset thisresult = qRole.recordcount />
			
			<!--- Result is the most permissable right granted. 1 is the most permissable, so if that is returned we don't need to check any more --->
			<cfif thisresult eq 1>
				<cfreturn 1 />
			</cfif>
		</cfloop>
		
		<cfreturn 0 />
	</cffunction>
	
	<cffunction name="checkWebskin" access="public" output="false" returntype="boolean" hint="Returns true if this role grants access the the webskin">
		<cfargument name="role" type="string" required="true" hint="The roles to check" />
		<cfargument name="type" type="string" required="true" hint="The type to check" />
		<cfargument name="webskin" type="string" required="true" hint="The webskin to check" />
		
		<cfset var thisrole = "" />
		<cfset var stRole = structnew() />
		<cfset var filter = "" />
		
		<cfloop list="#arguments.role#" index="thisrole">
			<!--- If the name of the role was passed in, get the objectid --->
			<cfif not isvalid("uuid",thisrole)>
				<cfset thisrole = getID(thisrole) />
			</cfif>
			
			<cfset stRole = getData(thisrole) />
			<cfloop list="#stRole.webskins#" index="filter" delimiters="#chr(10)##chr(13)#,">
				<cfif (not find(".",filter) or listfirst(filter,".") eq "*" or listfirst(filter,".") eq arguments.type) and refind(replace(listlast(filter,"."),"*",".*","ALL"),arguments.webskin)>
					<cfreturn 1 />
				<cfelse>
					<cfset 0 />
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn false />
	</cffunction>
	
	<cffunction name="getID" access="public" output="false" returntype="string" hint="Returns the objectid for the specified object. Will return empty string if the role is not found">
		<cfargument name="name" type="string" required="true" hint="Pass in a role name and the objectid will be returned" />
		
		<cfset var qRoles = "" />
		<cfset var result = "" />
		
		<cfif not application.security.hasLookup(role=arguments.name)>
			<cfquery datasource="#application.dsn#" name="qRoles">
				select	objectid,label
				from	#application.dbOwner#farRole
				where	lower(title)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.name)#" />
			</cfquery>
			
			<cfif qRoles.recordCount>			
				<cfset result = application.security.setLookup(role=arguments.name,objectid=qRoles.objectid[1]) />
			</cfif>
		<cfelse>
			<cfset result = application.security.getLookup(role=arguments.name) />
		</cfif>
		
		<cfreturn result />
		
	</cffunction>

	<cffunction name="getLabel" access="public" output="false" returntype="string" hint="Returns the label for the specified object">
		<cfargument name="objectid" type="uuid" required="true" hint="Pass in a role name and the objectid will be returned" />
		
		<cfset var qRoles = "" />
		
		<cfquery datasource="#application.dsn#" name="qRoles">
			select	label
			from	#application.dbOwner#farRole
			where	objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>
		
		<cfreturn qRoles.label[1] />
	</cffunction>

	<cffunction name="getDefaultRoles" access="public" output="false" returntype="string" hint="Returns a list of the default roles">
		<cfset var qRoles = "" />
		
		<cfquery datasource="#application.dsn#" name="qRoles">
			select	objectid
			from	#application.dbowner#farRole
			where	isdefault=1
		</cfquery>
		
		<cfreturn valuelist(qRoles.objectid) />
	</cffunction>
	
	<cffunction name="getAllRoles" access="public" output="false" returntype="string" hint="Returns list of all role objectids">
		<cfset var qRoles = "" />

		<cfquery datasource="#application.dsn#" name="qRoles">
			select		objectid
			from		#application.dbowner#farRole
			order by	title
		</cfquery>
		
		<cfreturn valuelist(qRoles.objectid) />
	</cffunction>
	
	<cffunction name="updatePermission" access="public" output="false" returntype="void" hint="Adds or removes a permission">
		<cfargument name="role" type="string" required="true" hint="The role to update" />
		<cfargument name="permission" type="string" required="true" hint="The permission to add / remove" />
		<cfargument name="has" type="boolean" required="true" hint="True if the role is to have the permission, false otherwise" />
		
		<cfset var qPermissions = "" />
		<cfset var stRole = structnew() />
		
		<!--- If the name of the role was passed in, get the objectid --->
		<cfif not isvalid("uuid",arguments.role)>
			<cfset arguments.role = getID(arguments.role) />
		</cfif>
		
		<!--- If the name of the permission was passed in, get the objectid --->
		<cfif not isvalid("uuid",arguments.permission)>
			<cfset arguments.permission = createObject("component", application.stcoapi["farPermission"].packagePath).getID(arguments.permission) />
		</cfif>
		
		<!--- Get data --->
		<cfset stRole = getData(objectid=arguments.role) />
		
		<!--- Get the relevant permission --->
		<cfquery datasource="#application.dsn#" name="qPermissions">
			select	*
			from	#application.dbowner#farRole_aPermissions
			where	parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.role#" />
					and data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permission#" />
		</cfquery>
		
		<!--- Update the permission --->
		<cfif arguments.has and not qPermissions.recordcount>
			<!--- Add the permission --->
			<cfset arrayappend(stRole.aPermissions,arguments.permission) />
			<cfset setData(stProperties=stRole) />
		</cfif>
		<cfif not arguments.has and qPermissions.recordcount>
			<!--- Remove the permission --->
			<cfset arraydeleteat(stRole.aPermissions,qPermissions.seq) />
			<cfset setData(stProperties=stRole) />
		</cfif>
	</cffunction>

	<cffunction name="copyRole" access="public" output="false" returntype="struct" hint="Copies a role and gives it a new name">
		<cfargument name="objectid" type="uuid" required="true" hint="The role to copy" />
		<cfargument name="title" type="string" required="true" hint="The title of the new role" />
		
		<cfset var stObj = getData(arguments.objectid) />
		<cfset var qBarnacles = "" />
		<cfset var stBarnacle = structnew() />
		
		<!--- Update and save --->
		<cfset stObj.objectid = createuuid() />
		<cfset stObj.title = arguments.title />
		<cfset createData(stProperties=stObj) />
		
		<!--- Get the barnacles for the role --->
		<cfquery datasource="#application.dsn#" name="qBarnacles">
			select	objectid
			from	#application.dbowner#farBarnacle
			where	roleid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>
		
		<!--- Create copies of the barnacles for the new role --->
		<cfloop query="qBarnacles">
			<cfset stBarnacle = application.security.factory.barnacle.getData(qBarnacles.objectid[currentrow]) />
			<cfset stBarnacle.objectid = createuuid() />
			<cfset stBarnacle.roleid = stObj.objectid />
			<cfset application.security.factory.barnacle.createData(stBarnacle) />
		</cfloop>
		
		<cfreturn stObj />
	</cffunction>
		
	<cffunction name="afterSave" access="public" output="false" returntype="struct" hint="Processes new type content">
		<cfargument name="stProperties" type="struct" required="true" hint="The properties that have been saved" />
		
		<cfset application.security.initCache() />
		
		<cfreturn arguments.stProperties />
	</cffunction>
	
	<cffunction name="delete" access="public" hint="Removes any corresponding entries in farBarnacle" returntype="struct" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="">
		
		<!--- Remove related barnacles --->
		<cfquery datasource="#application.dsn#" name="qBarnacles">
			delete
			from	#application.dbowner#farBarnacle
			where	roleid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>
		
		<cfreturn super.delete(objectid=arguments.objectid,user=arguments.user,auditNote=arguments.audittype) />
	</cffunction>

</cfcomponent>
