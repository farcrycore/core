<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
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
<cfcomponent 
	displayname="Role" 
	extends="types" output="false" 
	hint="Groups can be assigned to any number of Roles.  Roles in turn are collections of permissions that determine what priveleges a specific group of users has within the system." 
	bsystem="true" bArchive="true"
	icon="fa-group">

<!---------------------------------------------- 
type properties
----------------------------------------------->
	<cfproperty name="title" type="string" default="" hint="The name of the role" bLabel="true" ftSeq="1" ftWizardStep="Groups" ftLabel="Title" ftType="string" />
	<cfproperty name="isdefault" type="boolean" default="0" hint="True if this is a default role. Every user will be assigned these permissions." ftSeq="2" ftWizardStep="Groups" ftLabel="Default Role" ftType="boolean" />
	<cfproperty name="aGroups" type="array" default="" hint="The user directory groups that this role has been assigned to" ftSeq="3" ftWizardStep="Groups" ftLabel="Groups" ftType="array" ftJoin="farRole" ftRenderType="list" ftLibraryData="getGroups" ftShowLibraryLink="false" />
	<cfproperty name="aPermissions" type="array" hint="The simple permissions that are granted as part of this role" ftSeq="11" ftWizardStep="Permissions" ftLabel="Permissions" ftJoin="farPermission" />
	<cfproperty name="webskins" type="longchar" default="" hint="A list of wildcard items that match the webkins this role can access" ftSeq="21" ftWizardStep="Webskins" ftLabel="Webskins" ftType="longchar" ftHint="Filters should be in the form: [type.][prefix*|webskin]<br />e.g. display* grants access to all webskins prefixed with display<br />dmNews.stats grants access to the stats dmNews webskin<br />dmEvent.* grants access to all event webskins" />
	
	<!--- System Properties --->
	<cfproperty name="sitePermissions" type="longchar" default="" hint="wddx of site permissions for this role" ftLabel="Site Permissions" bSave="false" />
	<cfproperty name="webtopPermissions" type="longchar" default="" hint="wddx of webtop permissions for this role" ftLabel="Webtop Permissions" bSave="false" />
	<cfproperty name="typePermissions" type="longchar" default="" hint="wddx of type permissions for this role" ftLabel="type Permissions" bSave="false" />


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
		<cfset var thisuser = "" />
		<cfset var user	= '' />
		
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
					<cfif not listcontains(users[arraylen(users)],"#user#_#listlast(group,'_')#") and listlen(users[arraylen(users)]) lte 200>
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
		<cfargument name="objectid" type="string" required="false" default="" hint="The objectid of the related object" />
		
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
				<sec:CheckPermission permission="#arguments.permission#" type="#arguments.type#" objectid="#arguments.objectid#" roles="#qRoles.objectid#" result="haspermission" />
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
		
		
		<cfset var thisrole = "" />
		<cfset var thisresult = -1 />
		<cfset var qRole = "" />
		<cfset var stResult	= '' />
		
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
	
	<cffunction name="matchWebskin" access="private" output="false" returntype="any" hint="Returns true if the given webskin is granted by the specified filters">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="webskin" type="string" required="true" />
		<cfargument name="filters" type="string" required="true" />
		<cfargument name="debug" type="boolean" required="false" default="false" />
		
		<cfset var searchstring = "#arguments.typename#.#arguments.webskin#" />
		<cfset var result = false />
		<cfset var stResult = structnew() />
		<cfset var filter = "" />
		<cfset var reFilter = "" />
		<cfset var match = true />
		<cfset var allFilters = "" />
		
		<cfset stResult["result"] = false />
		<cfset stResult["reason"] = "no match" />
		
		<cfloop list="#arguments.filters#" index="filter" delimiters="#chr(10)##chr(13)#,">
			<cfif left(filter,1) eq "!">
				<cfset match = false />
				<cfset filter = mid(filter,2,len(filter)) />
			<cfelse>
				<cfset match = true />
			</cfif>
			
			<cfif not find(".",filter)>
				<cfset reFilter = "^.*\." & replace(filter,"*",".*","ALL") & "$" />
			<cfelse>
				<cfset reFilter = "^" & replace(replace(filter,".","\."),"*",".*","ALL") & "$" />
			</cfif>
			
			<cfif refindnocase(reFilter,searchstring)>
				<cfif arguments.debug>
					<cfset stResult["result"] = match />
					<cfset stResult["reason"] = "matches #filter#" />
					<cfif match eq false><!--- On exception match, return immediately --->
						<cfreturn stResult />
					</cfif>
				<cfelse>
					<cfset result = match />
					<cfif match eq false><!--- On exception match, return immediately --->
						<cfreturn result />
					</cfif>
				</cfif>
			<cfelseif arguments.debug>
				<cfset allFilters = listappend(allFilters,reFilter) />
			</cfif>
		</cfloop>
		
		<cfif arguments.debug>
			<cfreturn stResult />
		<cfelse>
			<cfreturn result />
		</cfif>
	</cffunction>
	
	<cffunction name="checkWebskin" access="public" output="false" returntype="boolean" hint="Returns true if this role grants access the the webskin">
		<cfargument name="role" type="string" required="true" hint="The roles to check" />
		<cfargument name="type" type="string" required="true" hint="The type to check" />
		<cfargument name="webskin" type="string" required="true" hint="The webskin to check" />
		
		<cfset var thisrole = "" />
		<cfset var stRole = structnew() />
		<cfset var filter = "" />
		<cfset var result = 0 />
		
		<cfloop list="#arguments.role#" index="thisrole">
			<!--- If the name of the role was passed in, get the objectid --->
			<cfif not isvalid("uuid",thisrole)>
				<cfset thisrole = getID(thisrole) />
			</cfif>
			
			<cfset stRole = getData(thisrole) />
			
			<cfset result = result or matchWebskin(arguments.type,arguments.webskin,stRole.webskins) />
		</cfloop>
		
		<cfreturn result />
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
		
		<cfif not structKeyExists(variables, "lDefaultRoles")>

			<cfquery datasource="#application.dsn#" name="qRoles">
				select	objectid
				from	#application.dbowner#farRole
				where	isdefault=1
			</cfquery>
			
			<cfset variables.lDefaultRoles = valuelist(qRoles.objectid) />
			
		</cfif>
		
		<cfreturn variables.lDefaultRoles />
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
		<cfset var typepermissiontype = "" />
		<cfset var stO = structnew() />
		<cfset var qObjects = "" />
		
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
			
			<!--- Notify objects of permission change --->
			<cfset typepermissiontype = application.security.factory.permission.getTypePermissionType(objectid=arguments.permission) />
			<cfif len(typepermissiontype)>
				<cfquery datasource="#application.dsn#" name="qObjects">
					select		objectid
					from		#application.dbowner##typepermissiontype#
				</cfquery>
				
				<cfparam name="stO.#typepermissiontype#" default="#application.fapi.getContentType(typename=typepermissiontype)#" />
				<cfset stO[typepermissiontype].onSecurityChange(changetype="type",objectid=qObjects.objectid,typename=typepermissiontype,farRoleID=arguments.role,farPermissionID=arguments.permission,oldright=0,newright=1) />
			</cfif>
		</cfif>
		<cfif not arguments.has and qPermissions.recordcount>
			<!--- Remove the permission --->
			<cfset arraydeleteat(stRole.aPermissions,qPermissions.seq) />
			<cfset setData(stProperties=stRole) />
			
			<!--- Notify objects of permission change --->
			<cfset typepermissiontype = application.security.factory.permission.getTypePermissionType(objectid=stObj.aPermissions[qPermissions.seq]) />
			<cfif len(typepermissiontype)>
				<cfquery datasource="#application.dsn#" name="qObjects">
					select		objectid
					from		#application.dbowner##typepermissiontype#
				</cfquery>
				
				<cfparam name="stO.#typepermissiontype#" default="#application.fapi.getContentType(typename=typepermissiontype)#" />
				<cfset stO[typepermissiontype].onSecurityChange(changetype="type",objectid=qObjects.objectid,typename=typepermissiontype,farRoleID=arguments.role,farPermissionID=arguments.permission,oldright=1,newright=0) />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="copyRole" access="public" output="false" returntype="struct" hint="Copies a role and gives it a new name">
		<cfargument name="objectid" type="uuid" required="true" hint="The role to copy" />
		<cfargument name="title" type="string" required="true" hint="The title of the new role" />
		
		<cfset var stObj = getData(arguments.objectid) />
		<cfset var qBarnacles = "" />
		<cfset var stBarnacle = structnew() />
		
		<!--- Update and save --->
		<cfset stObj.objectid = application.fc.utils.createJavaUUID() />
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
			<cfset stBarnacle.objectid = application.fc.utils.createJavaUUID() />
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
		
		<cfset var qBarnacles = "" />
		<cfset var stObj = getData(objectid=arguments.objectid) />
		<cfset var typepermission = "" />
		<cfset var i = 0 />
		<cfset var qObjects = "" />
		<cfset var stO = structnew() />
		<cfset var typepermissiontype	= '' />
		
		<!--- Remove related barnacles --->
		<cfquery datasource="#application.dsn#" name="qBarnacles">
			select	objectid
			from	#application.dbowner#farBarnacle
			where	roleid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>
		
		<cfloop query="qBarnacles">
			<cfset application.security.factory.barnacle.delete(objectid=qBarnacles.objectid) />
		</cfloop>
		
		<!--- Notify objects of permission change --->
		<cfloop from="1" to="#arraylen(stObj.aPermissions)#" index="i">
			<cfset typepermissiontype = application.security.factory.permission.getTypePermissionType(objectid=stObj.aPermissions[i]) />
			<cfif len(typepermissiontype)>
				<cfquery datasource="#application.dsn#" name="qObjects">
					select		objectid
					from		#application.dbowner##typepermissiontype#
				</cfquery>
				
				<cfparam name="stO.#typepermissiontype#" default="#application.fapi.getContentType(typename=typepermissiontype)#" />
				<cfset stO[typepermissiontype].onSecurityChange(changetype="type",objectid=qObjects.objectid,typename=typepermissiontype,farRoleID=arguments.objectid,farPermissionID=stObj.aPermissions[i],oldright=1,newright=0) />
			</cfif>
		</cfloop>
		
		<cfreturn super.delete(objectid=arguments.objectid,user=arguments.user,auditNote=arguments.auditNote) />
	</cffunction>

	<cffunction name="setData" access="public" output="true" hint="Update the record for an objectID including array properties.  Pass in a structure of property values; arrays should be passed as an array.">
		<cfargument name="stProperties" required="true">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Updated">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		<cfargument name="bSessionOnly" type="boolean" required="false" default="false"><!--- This property allows you to save the changes to the Temporary Object Store for the life of the current session. ---> 
		<cfargument name="bAfterSave" type="boolean" required="false" default="true" hint="This allows the developer to skip running the types afterSave function.">	
		
		<cfset var stOld = getData(objectid=arguments.stProperties.objectid) />
		<cfset var thisperm = "" />
		<cfset var typepermissiontype = "" />
		<cfset var qObjects = "" />
		<cfset var stO = structnew() />
		<cfset var i = 0 />
		
		<cfif not arguments.bSessionOnly>
			<cfif structkeyexists(arguments.stProperties,"aPermissions")>
				<!--- If this setData happened because of the library there may be :seq values in the array data --->
				<cfloop from="1" to="#arraylen(arguments.stProperties.aPermissions)#" index="i">
					<cfif refind(":[\d\.]+$",arguments.stProperties.aPermissions[i])>
						<cfset arguments.stProperties.aPermissions[i] = listfirst(arguments.stProperties.aPermissions[i],":") />
					</cfif>
				</cfloop>
				
				<!--- Removed permissions --->
				<cfloop list="#application.fapi.listDiff(arraytolist(arguments.stProperties.aPermissions),arraytolist(stOld.aPermissions))#" index="thisperm">
					<!--- Notify objects of permission change --->
					<cfset typepermissiontype = application.security.factory.permission.getTypePermissionType(objectid=thisperm) />
					<cfif len(typepermissiontype)>
						<cfquery datasource="#application.dsn#" name="qObjects">
							select		objectid
							from		#application.dbowner##typepermissiontype#
						</cfquery>
						
						<cfparam name="stO.#typepermissiontype#" default="#application.fapi.getContentType(typename=typepermissiontype)#" />
						<cfloop query="qObjects">
							<cfset stO[typepermissiontype].onSecurityChange(changetype="type",objectid=qObjects.objectid,typename=typepermissiontype,farRoleID=arguments.stProperties.objectid,farPermissionID=thisperm,oldright=1,newright=0) />
						</cfloop>
					</cfif>
				</cfloop>
				
				<!--- Added permissions --->
				<cfloop list="#application.fapi.listDiff(arraytolist(stOld.aPermissions),arraytolist(arguments.stProperties.aPermissions))#" index="thisperm">
					<!--- Notify objects of permission change --->
					<cfset typepermissiontype = application.security.factory.permission.getTypePermissionType(objectid=thisperm) />
					<cfif len(typepermissiontype)>
						<cfquery datasource="#application.dsn#" name="qObjects">
							select		objectid
							from		#application.dbowner##typepermissiontype#
						</cfquery>
						
						<cfparam name="stO.#typepermissiontype#" default="#application.fapi.getContentType(typename=typepermissiontype)#" />
						<cfloop query="qObjects">
							<cfset stO[typepermissiontype].onSecurityChange(changetype="type",objectid=qObjects.objectid,typename=typepermissiontype,farRoleID=arguments.stProperties.objectid,farPermissionID=thisperm,oldright=0,newright=1) />
						</cfloop>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		
		<cfreturn super.setData(argumentCollection=arguments) />
	</cffunction>
	
	
	<cffunction name="ftEditWebskins" access="public" returntype="string" description="This will return a string of formatted HTML text to enable the editing of the property" output="false">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var html = "" />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<skin:loadJS id="fc-jquery" />
		
		<cfsavecontent variable="html"><cfoutput>
			<div class="multiField">
				<div class="blockLabel">
					<textarea name="#arguments.fieldname#" id="#arguments.fieldname#" class="textareaInput #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#">#arguments.stMetadata.value#</textarea>
					<p><a href="##" id="testfilters">Test Filters</a></p>
					<div id="testfiltersresult"></div>
				</div>
			</div>
			<script type="text/javascript">
				function arrayToSelect(id,data){
					var select = [ "<select id='", id, "'>", "<option value=''>-- all --</option>" ];
					
					for (var i=0; i<data.length; i++){
						select.push("<option>");
						select.push(data[i]);
						select.push("</option>");
					}
					select.push("</select>");
					
					return select.join("");
				};
				
				function getTypes(data){
					var values = {}, result = [];
					
					for (var type in data) values[type] = true;
					for (var value in values) result.push(value);
					
					result.sort();
					
					return result;
				};
				
				function getWebskins(data){
					var values = {}, result = [];
					
					for (var type in data) {
						for (var webskin in data[type])
							values[webskin] = true;
					}
					for (var value in values) result.push(value);
					
					result.sort();
					
					return result;
				};
				
				$j("##selectfilterstype,##selectfilterswebskin").on("change",function(){
					var type = $j("##selectfilterstype").val();
					var webskin = $j("##selectfilterswebskin").val();
					$j("##filterresult tbody tr").hide();
					$j("##filterresult tbody tr" + (type.length ? ":has(.typename_"+type+")" : "") + (webskin.length ? ":has(.webskin_"+webskin+")" : "")).show();
				});
				$j("##testfilters").bind("click",function(){
					var selectedtype = $j("##selectfilterstype").val();
					var selectedwebskin = $j("##selectfilterswebskin").val();
					$j("##testfiltersresult").html("<div style='text-align:center;'><img src='#application.url.webtop#/images/loading.gif' alt='Loading...'></p>");
					$j.post(
						'#application.formtools.longchar.oFactory.getAjaxURL(argumentCollection=arguments)#',
						{ '#arguments.stMetadata.name#':$j("###arguments.fieldname#").val() },
						function(data){
							if (data.error){
								html = [ "<h2>ERROR: ", data.error, "</h2>", "<table>" ];
								
								for (var i=0; i<data.trace.length; i++){
									html.push("<tr><td>");
									html.push(data.trace[i].TEMPLATE);
									html.push("</td><td>");
									html.push(data.trace[i].LINE);
									html.push("</td></tr>");
								}
								
								html.push("</table>");
								
								$j("##testfiltersresult").html(html.join(""));
							}
							else{
								var types = getTypes(data), type="", webskins = getWebskins(data), webskin="";
								
								var html = [ "<table id='filterresult'>", "<thead>", "<tr>", "<td>", arrayToSelect("selectfilterstype",getTypes(data)), "</td>", "<td>", arrayToSelect("selectfilterswebskin",getWebskins(data)), "</td>", "<td>", "</td>", "</tr>", "</thead>", "<tbody>" ];
								for (var i=0; i<types.length; i++){
									type = types[i];
									
									for (var j=0; j<webskins.length; j++){
										webskin = webskins[j];
										
										if (data[type][webskin]){
											html.push("<tr");
											if (data[type][webskin].result)
												html.push(" style='color:##009900;'");
											else
												html.push(" style='color:##FF0000;'");
											html.push("><td class='typename typename_");
											html.push(type);
											html.push("'>");
											html.push(type);
											html.push("</td><td class='webskin webskin_");
											html.push(webskin);
											html.push("'>");
											html.push(webskin);
											html.push("</td><td class='reason'>");
											html.push(data[type][webskin].reason);
											html.push("</td></tr>");
										}
									}
								}
								html.push("</tbody>");
								html.push("</table>");
								
								$j("##testfiltersresult").html(html.join(""));
								
								$j("##selectfilterstype").val(selectedtype);
								$j("##selectfilterswebskin").val(selectedwebskin).trigger("change");
							}
						},
						"json"
					);
				});
			</script>
		</cfoutput></cfsavecontent>
		
		<cfreturn html />
	</cffunction>
	
	<cffunction name="ftAjaxWebskins" output="false" returntype="string" hint="Response to ajax requests for this formtool">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var thistype = "" />
		<cfset var stWebskins = structnew() />
		<cfset var methodname = "" />
		<cfset var types = "" />
		<cfset var webskin = "" />
		<cfset var webskinsendback	= '' />
		
		<cfimport taglib="/farcry/core/tags/misc" prefix="misc" />
		
		<cftry>
			<!--- Generate result set --->
			<misc:map values="#application.stCOAPI#" index="thistype" value="metadata" result="stWebskins" resulttype="struct" sendback="typesendback">
				<misc:map values="#metadata.qWebskins#" index="currentrow" value="webskin" result="typesendback.#thistype#" resulttype="struct" sendback="webskinsendback">
					<cfif len(webskin.methodname) and webskin.methodname neq "deniedaccess">
						<cfset webskinsendback[webskin.methodname] = matchWebskin(thistype,webskin.methodname,arguments.stMetadata.value,true) />
					</cfif>
				</misc:map>
			</misc:map>
			
			<cfcatch>
				<cfset stWebskins = structnew() />
				<cfset stWebskins["error"] = cfcatch.message />
				<cfset stWebskins["trace"] = cfcatch.TagContext />
			</cfcatch>
		</cftry>
		
		<cfreturn serializeJSON(stWebskins) />
	</cffunction>

	<cffunction name="upgradeV62" access="public" output="false" returntype="struct" hint="Upgrades Role and Permissions">
		<cfargument name="force" type="boolean" required="false" default="false" />

		<cfset var q = "">
		<cfset var schemaPermission = application.fc.lib.db.getTableMetadata("farPermission")>
		<cfset var schemaRole = application.fc.lib.db.getTableMetadata("farRole")>
		<cfset var aRelatedTypes = arrayNew(1) />	
		<cfset var aChanges = arrayNew(1)>
		<cfset var aResults = arrayNew(1)>
		<cfset var qAllRoles = "">
		<cfset var oPermission = application.fapi.getContentType("farPermission")>	
		<cfset var oRole = application.fapi.getContentType("farRole")>	
		<cfset var oCoapi = application.fapi.getContentType("farCoapi")>
		<cfset var stPermissionMetadata = application.fc.lib.db.getGateway(dsn=application.dsn).introspectType("farPermission")>
		<cfset var stRoleMetadata = application.fc.lib.db.getGateway(dsn=application.dsn).introspectType("farRole")>
		<cfset var qGenericPermissions = "">
		<cfset var stGenericPermission = "">
		<cfset var qCoapiPermissions = "">
		<cfset var stPermission = "">
		<cfset var stCoapiPermission = "">
		<cfset var lTypes = "" />
		<cfset var qCheckBarnacleExists = "">
		<cfset var stWebtop = "">
		<cfset var i = 0 />
		<cfset var j = 0 />
		<cfset var k = 0 />
		<cfset var c = 0 />
		<cfset var bDoUpgrade = NOT structKeyExists(stPermissionMetadata.fields, "bDisabled") />
		<cfset var stCoapiType	= '' />
		<cfset var stRole	= '' />
		<cfset var viewWebtopItemID	= '' />
		<cfset var tempID	= '' />
		<cfset var stLevel1	= '' />
		<cfset var barnacleID	= '' />
		<cfset var securityPermissionID	= '' />
		<cfset var stLevel2	= '' />
		<cfset var stLevel3	= '' />
		<cfset var stLevel4	= '' />
		<cfset var iType	= '' />
		<cfset var l	= '' />

		<cfif not bDoUpgrade>
			<cfquery datasource="#application.dsn#" name="q">select distinct bDisabled from farPermission</cfquery>
			<cfset bDoUpgrade = (q.recordcount eq 1) />
		</cfif>
		
		<cfif bDoUpgrade or arguments.force>
		
			<cfset application.fapi.addRequestLog("Running 6.2 upgrade") />
			
			<cfquery datasource="#application.dsn#" name="qAllRoles">
			select * from farRole
			</cfquery>
			
			
			<!--- Deploy bSystem Property --->
			<cfif NOT structKeyExists(stPermissionMetadata.fields, "bSystem")>
				<cfset arrayappend(aChanges, application.fc.lib.db.createChange(action="addColumn", schema="#schemaPermission#", propertyname='bSystem') ) />
			</cfif>
			<cfif NOT structKeyExists(stPermissionMetadata.fields, "hint")>
				<cfset arrayappend(aChanges, application.fc.lib.db.createChange(action="addColumn", schema="#schemaPermission#", propertyname='hint') ) />
			</cfif>
			<cfif NOT structKeyExists(stPermissionMetadata.fields, "bDisabled")>
				<cfset arrayappend(aChanges, application.fc.lib.db.createChange(action="addColumn", schema="#schemaPermission#", propertyname='bDisabled') ) />
			</cfif>
			<cfif NOT structKeyExists(stRoleMetadata.fields, "sitePermissions")>
				<cfset arrayappend(aChanges, application.fc.lib.db.createChange(action="addColumn", schema="#schemaRole#", propertyname='sitePermissions') ) />
			</cfif>
			<cfif NOT structKeyExists(stRoleMetadata.fields, "webtopPermissions")>
				<cfset arrayappend(aChanges, application.fc.lib.db.createChange(action="addColumn", schema="#schemaRole#", propertyname='webtopPermissions') ) />
			</cfif>
			<cfif NOT structKeyExists(stRoleMetadata.fields, "typePermissions")>
				<cfset arrayappend(aChanges, application.fc.lib.db.createChange(action="addColumn", schema="#schemaRole#", propertyname='typePermissions') ) />
			</cfif>
			<cfset aResults = application.fc.lib.db.deployChanges(aChanges,application.dsn) />
			
			<cfquery datasource="#application.dsn#">
				delete from farPermission_aRelatedtypes where data in ('farCoapi','webtop')
			</cfquery>
			<cfset application.fapi.addRequestLog("Removed pre-existing farCOAPI / webtop permissions") />
			
			
			<!--- Site Tree Permissions --->
			<cfquery datasource="#application.dsn#" name="q">
			select objectid from farPermission
			where ObjectID in (
				select parentid from farPermission_aRelatedtypes
			)
			</cfquery>
			
			<cfloop query="q">
				<cfquery datasource="#application.dsn#">
					update farPermission set bSystem=1 where objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#q.objectid#" />
				</cfquery>
			</cfloop>
			<cfset application.fapi.addRequestLog("Updated #q.recordcount# object permissions") />
			
			
			<!--- Type Permissions --->
			<cfset lTypes = structKeyList(application.types) />
				
			<cfquery datasource="#application.dsn#" name="qGenericPermissions">
			select objectid 
			from farPermission
			WHERE shortcut like 'generic%'
			</cfquery>

			<cfloop query="qGenericPermissions">
				<cfset stGenericPermission = oPermission.getData(objectid=qGenericPermissions.objectid,typename="farPermission") />
				<cfquery datasource="#application.dsn#">
					update farPermission set bSystem=1 where objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGenericPermissions.objectid#" />
				</cfquery>
				<cfquery datasource="#application.dsn#">
					insert into farPermission_aRelatedtypes (parentid,seq,data,typename) values (
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGenericPermissions.objectid#" />, 
						<cfqueryparam cfsqltype="cf_sql_varchar" value="100" />, 
						<cfqueryparam cfsqltype="cf_sql_varchar" value="farCoapi" />, 
						<cfqueryparam cfsqltype="cf_sql_varchar" value="" />
					)
				</cfquery>
				
				
				<!--- Update all the type specific permissions --->
				<cfloop list="#lTypes#" index="iType">
					<cfset stCoapiType = oCoapi.getCoapiObject("#iType#") />
				
					<cfquery datasource="#application.dsn#" name="qCoapiPermissions">
					select objectid from farPermission
					WHERE lower(shortcut) = '#lcase(replaceNoCase(stGenericPermission.shortcut,"generic","#iType#") )#'
					OR lower(shortcut) = '#lcase(replaceNoCase(stGenericPermission.shortcut,"generic","#application.fapi.getContentTypeMetadata('#iType#', 'displayname')#") )#'
					</cfquery>

					
					<cfif qCoapiPermissions.recordCount>
						<cfset stCoapiPermission = oPermission.getData(objectid=qCoapiPermissions.objectid,typename="farPermission") />
						<cfquery datasource="#application.dsn#">
							update farPermission set bSystem=1, bDisabled=1 where objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qCoapiPermissions.objectid#" />
						</cfquery>
						
						
						<cfloop query="qAllRoles">
							<cfset stRole = oRole.getData(qAllRoles.objectid)>
							<cfif application.fapi.arrayFind(stRole.aPermissions, stCoapiPermission.objectid)>
								
								<cfquery datasource="#application.dsn#" name="qCheckBarnacleExists">
								SELECT objectid
								FROM farBarnacle
								WHERE roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stRole.objectid#">
								AND permissionID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stGenericPermission.objectid#">
								AND referenceid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stCoapiType.objectid#">
								AND objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="farCoapi">
								</cfquery>
								
								<cfif not qCheckBarnacleExists.recordCount>
									<cfquery datasource="#application.dsn#">
										 INSERT INTO farBarnacle ( 
											createdby, datetimecreated, datetimelastupdated, label, lastupdatedby, locked, lockedBy, ObjectID, ownedby,
											roleid, permissionID, referenceID, objecttype, barnaclevalue
										) VALUES ( 
											'6.2 upgrade', <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, '', '6.2 upgrade', 0, '', '#application.fapi.getUUID()#', '',
											'#stRole.objectid#', '#stGenericPermission.objectid#', '#stCoapiType.objectid#', 'farCoapi', 1
										)
									</cfquery>
								</cfif>
							</cfif>	
							
							
						</cfloop>
						
					</cfif>
					
				</cfloop>
				
			</cfloop>
			<cfset application.fapi.addRequestLog("Updated #qGenericPermissions.recordcount * listlen(lTypes)# type permissions") />
			
			
			<!--- KNOWN SYSTEM PERMISSIONS --->
			<cfquery datasource="#application.dsn#" name="q">
			select objectid from farPermission
			where shortcut IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="Admin,AdminSearchTab,EventApprove,EventCanApproveOwnContent,EventCreate,EventDelete,EventEdit,EventRequestApproval,FactApprove,FactCanApproveOwnContent,FactCreate,FactDelete,FactEdit,FactRequestApproval,MainNavReportingTab,MainNavSecurityTab">)
			</cfquery>
			<cfloop query="q">
				<cfquery datasource="#application.dsn#">
					update farPermission set bSystem=1, bDisabled=1 where objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#q.objectid#" />
				</cfquery>
			</cfloop>
			<cfset application.fapi.addRequestLog("Updated #q.recordcount# system permissions") />
			
			
			<!--- Webtop Permissions --->
			<cfset viewWebtopItemID = oPermission.getID("viewWebtopItem")>
			
			<cfif len(viewWebtopItemID)>
				<cfquery datasource="#application.dsn#">
					update farPermission set bSystem=1 where objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#viewWebtopItemID#" />
				</cfquery>
				<cfquery datasource="#application.dsn#">
					insert into farPermission_aRelatedtypes (parentid,seq,data,typename) values (
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#viewWebtopItemID#" />, 
						<cfqueryparam cfsqltype="cf_sql_varchar" value="101" />, 
						<cfqueryparam cfsqltype="cf_sql_varchar" value="webtop" />, 
						<cfqueryparam cfsqltype="cf_sql_varchar" value="" />
					)
				</cfquery>
			<cfelse>
				<cfset tempID = application.fapi.getUUID() />
				<cfquery datasource="#application.dsn#">
					 INSERT INTO farPermission ( 
						createdby, datetimecreated, datetimelastupdated, label, lastupdatedby, locked, lockedBy, ObjectID, ownedby,
						title, shortcut, bSystem
					) VALUES ( 
						'6.2 upgrade', <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, 'viewWebtopItem', '6.2 upgrade', 0, '', '#tempID#', '',
						'viewWebtopItem', 'viewWebtopItem', 1
					)
				</cfquery>
				<cfquery datasource="#application.dsn#">
					insert into farPermission_aRelatedtypes (parentid,seq,data,typename) values (
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#tempID#" />, 
						<cfqueryparam cfsqltype="cf_sql_varchar" value="101" />, 
						<cfqueryparam cfsqltype="cf_sql_varchar" value="webtop" />, 
						<cfqueryparam cfsqltype="cf_sql_varchar" value="" />
					)
				</cfquery>
			</cfif>
			<cfset application.fapi.addRequestLog("Added webtop to viewWebtopItem") />
			
			<cfset viewWebtopItemID = oPermission.getID("viewWebtopItem")>
			
			
			<cfset stWebtop = application.factory.oWebtop.getItem(honoursecurity="false") />
			<cfloop list="#stWebtop.CHILDORDER#" index="i">
				
				<cfset stLevel1 = stWebtop.children[i] />
				<cfset barnacleID = hash(stLevel1.rbKey)>
				
				<cfloop query="qAllRoles">
			
					<cfset stRole = oRole.getData(qAllRoles.objectid)>
					<cfif structKeyExists(stLevel1, "permission") AND len(stLevel1.permission)>
						<cfset securityPermissionID = oPermission.getID("#stLevel1.permission#")>
						
						<cfif len(securityPermissionID)>
							<cfquery datasource="#application.dsn#">
								update farPermission set bSystem=1 where objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#securityPermissionID#" />
							</cfquery>
						
							<cfif application.fapi.arrayFind(stRole.aPermissions, securityPermissionID)>
						
								<cfquery datasource="#application.dsn#" name="qCheckBarnacleExists">
								SELECT objectid
								FROM farBarnacle
								WHERE roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stRole.objectid#">
								AND permissionID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#viewWebtopItemID#">
								AND referenceid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
								AND objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="webtop">
								</cfquery>
								
								<cfif qCheckBarnacleExists.recordCount>
									<cfquery datasource="#application.dsn#">
										update farBarnacle set barnaclevalue=1 where objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qCheckBarnacleExists.objectid#" />
									</cfquery>
								<cfelse>
									<cfquery datasource="#application.dsn#">
										 INSERT INTO farBarnacle ( 
											createdby, datetimecreated, datetimelastupdated, label, lastupdatedby, locked, lockedBy, ObjectID, ownedby,
											roleid, permissionID, referenceID, objecttype, barnaclevalue
										) VALUES ( 
											'6.2 upgrade', <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, '', '6.2 upgrade', 0, '', '#application.fapi.getUUID()#', '',
											'#stRole.objectid#', '#viewWebtopItemID#', '#barnacleID#', 'webtop', 1
										)
									</cfquery>
								</cfif>
							<cfelse>
						
								<cfquery datasource="#application.dsn#" name="qCheckBarnacleExists">
								SELECT objectid
								FROM farBarnacle
								WHERE roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stRole.objectid#">
								AND permissionID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#viewWebtopItemID#">
								AND referenceid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
								AND objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="webtop">
								</cfquery>
								
								<cfif qCheckBarnacleExists.recordCount>
									<cfquery datasource="#application.dsn#">
										update farBarnacle set barnaclevalue=-1 where objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qCheckBarnacleExists.objectid#" />
									</cfquery>
								<cfelse>
									<cfquery datasource="#application.dsn#">
										 INSERT INTO farBarnacle ( 
											createdby, datetimecreated, datetimelastupdated, label, lastupdatedby, locked, lockedBy, ObjectID, ownedby,
											roleid, permissionID, referenceID, objecttype, barnaclevalue
										) VALUES ( 
											'6.2 upgrade', <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, '', '6.2 upgrade', 0, '', '#application.fapi.getUUID()#', '',
											'#stRole.objectid#', '#viewWebtopItemID#', '#barnacleID#', 'webtop', -1
										)
									</cfquery>
								</cfif>
							</cfif>
						</cfif>
					</cfif>
				</cfloop>
				<cfset c = c + qAllRoles.recordcount />
				
				<cfif listLen(stLevel1.CHILDORDER)>
						
					<cfloop list="#stLevel1.CHILDORDER#" index="j">
					
						<cfset stLevel2 = stLevel1.children[j] />
						<cfset barnacleID = hash(stLevel2.rbKey)>
				
						<cfloop query="qAllRoles">
					
							<cfset stRole = oRole.getData(qAllRoles.objectid)>
							<cfif structKeyExists(stLevel2, "permission") AND len(stLevel2.permission)>
								<cfset securityPermissionID = oPermission.getID("#stLevel2.permission#")>
						
								<cfif len(securityPermissionID)>
									<cfquery datasource="#application.dsn#">
										update farPermission set bSystem=1 where objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#securityPermissionID#" />
									</cfquery>
									
									<cfif application.fapi.arrayFind(stRole.aPermissions, securityPermissionID)>
						
										<cfquery datasource="#application.dsn#" name="qCheckBarnacleExists">
										SELECT objectid
										FROM farBarnacle
										WHERE roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stRole.objectid#">
										AND permissionID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#viewWebtopItemID#">
										AND referenceid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
										AND objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="webtop">
										</cfquery>
										
										<cfif qCheckBarnacleExists.recordCount>
											<cfquery datasource="#application.dsn#">
												update farBarnacle set barnaclevalue=1 where objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qCheckBarnacleExists.objectid#" />
											</cfquery>
										<cfelse>
											<cfquery datasource="#application.dsn#">
												 INSERT INTO farBarnacle ( 
													createdby, datetimecreated, datetimelastupdated, label, lastupdatedby, locked, lockedBy, ObjectID, ownedby,
													roleid, permissionID, referenceID, objecttype, barnaclevalue
												) VALUES ( 
													'6.2 upgrade', <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, '', '6.2 upgrade', 0, '', '#application.fapi.getUUID()#', '',
													'#stRole.objectid#', '#viewWebtopItemID#', '#barnacleID#', 'webtop', 1
												)
											</cfquery>
										</cfif>
									<cfelse>
								
										<cfquery datasource="#application.dsn#" name="qCheckBarnacleExists">
										SELECT objectid
										FROM farBarnacle
										WHERE roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stRole.objectid#">
										AND permissionID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#viewWebtopItemID#">
										AND referenceid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
										AND objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="webtop">
										</cfquery>
										
										<cfif qCheckBarnacleExists.recordCount>
											<cfquery datasource="#application.dsn#">
												update farBarnacle set barnaclevalue=-1 where objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qCheckBarnacleExists.objectid#" />
											</cfquery>
										<cfelse>
											<cfquery datasource="#application.dsn#">
												 INSERT INTO farBarnacle ( 
													createdby, datetimecreated, datetimelastupdated, label, lastupdatedby, locked, lockedBy, ObjectID, ownedby,
													roleid, permissionID, referenceID, objecttype, barnaclevalue
												) VALUES ( 
													'6.2 upgrade', <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, '', '6.2 upgrade', 0, '', '#application.fapi.getUUID()#', '',
													'#stRole.objectid#', '#viewWebtopItemID#', '#barnacleID#', 'webtop', -1
												)
											</cfquery>
										</cfif>
									</cfif>
								</cfif>
							</cfif>
						</cfloop>
						<cfset c = c + qAllRoles.recordcount />
			
						<cfif listLen(stLevel2.CHILDORDER)>
								
							<cfloop list="#stLevel2.CHILDORDER#" index="k">
							
								<cfset stLevel3 = stLevel2.children[k] />
								<cfset barnacleID = hash(stLevel3.rbKey)>
				
								<cfloop query="qAllRoles">
							
									<cfset stRole = oRole.getData(qAllRoles.objectid)>
									<cfif structKeyExists(stLevel3, "permission") AND len(stLevel3.permission)>
										<cfset securityPermissionID = oPermission.getID("#stLevel3.permission#")>
						
										<cfif len(securityPermissionID)>
											<cfquery datasource="#application.dsn#">
												update farPermission set bSystem=1 where objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#securityPermissionID#" />
											</cfquery>
										
											<cfif application.fapi.arrayFind(stRole.aPermissions, securityPermissionID)>
										
												<cfquery datasource="#application.dsn#" name="qCheckBarnacleExists">
												SELECT objectid
												FROM farBarnacle
												WHERE roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stRole.objectid#">
												AND permissionID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#viewWebtopItemID#">
												AND referenceid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
												AND objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="webtop">
												</cfquery>
												
												<cfif qCheckBarnacleExists.recordCount>
													<cfquery datasource="#application.dsn#">
														update farBarnacle set barnaclevalue=1 where objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qCheckBarnacleExists.objectid#" />
													</cfquery>
												<cfelse>
													<cfquery datasource="#application.dsn#">
														 INSERT INTO farBarnacle ( 
															createdby, datetimecreated, datetimelastupdated, label, lastupdatedby, locked, lockedBy, ObjectID, ownedby,
															roleid, permissionID, referenceID, objecttype, barnaclevalue
														) VALUES ( 
															'6.2 upgrade', <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, '', '6.2 upgrade', 0, '', '#application.fapi.getUUID()#', '',
															'#stRole.objectid#', '#viewWebtopItemID#', '#barnacleID#', 'webtop', 1
														)
													</cfquery>
												</cfif>
											<cfelse>
										
												<cfquery datasource="#application.dsn#" name="qCheckBarnacleExists">
												SELECT objectid
												FROM farBarnacle
												WHERE roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stRole.objectid#">
												AND permissionID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#viewWebtopItemID#">
												AND referenceid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
												AND objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="webtop">
												</cfquery>
												
												<cfif qCheckBarnacleExists.recordCount>
													<cfquery datasource="#application.dsn#">
														update farBarnacle set barnaclevalue=-1 where objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qCheckBarnacleExists.objectid#" />
													</cfquery>
												<cfelse>
													<cfquery datasource="#application.dsn#">
														 INSERT INTO farBarnacle ( 
															createdby, datetimecreated, datetimelastupdated, label, lastupdatedby, locked, lockedBy, ObjectID, ownedby,
															roleid, permissionID, referenceID, objecttype, barnaclevalue
														) VALUES ( 
															'6.2 upgrade', <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, '', '6.2 upgrade', 0, '', '#application.fapi.getUUID()#', '',
															'#stRole.objectid#', '#viewWebtopItemID#', '#barnacleID#', 'webtop', -1
														)
													</cfquery>
												</cfif>
											</cfif>
										</cfif>
									</cfif>
								</cfloop>
								<cfset c = c + qAllRoles.recordcount />
								
								<cfif listLen(stLevel3.CHILDORDER)>
									
									<cfloop list="#stLevel3.CHILDORDER#" index="l">
									
										<cfset stLevel4 = stLevel3.children[l] />
										<cfset barnacleID = hash(stLevel4.rbKey)>
				
										<cfloop query="qAllRoles">
									
											<cfset stRole = oRole.getData(qAllRoles.objectid)>
											<cfif structKeyExists(stLevel4, "permission") AND len(stLevel4.permission)>
												<cfset securityPermissionID = oPermission.getID("#stLevel4.permission#")>
						
												<cfif len(securityPermissionID)>
													<cfquery datasource="#application.dsn#">
														update farPermission set bSystem=1 where objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#securityPermissionID#" />
													</cfquery>
												
													<cfif application.fapi.arrayFind(stRole.aPermissions, securityPermissionID)>
												
														<cfquery datasource="#application.dsn#" name="qCheckBarnacleExists">
														SELECT objectid
														FROM farBarnacle
														WHERE roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stRole.objectid#">
														AND permissionID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#viewWebtopItemID#">
														AND referenceid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
														AND objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="webtop">
														</cfquery>
														
														<cfif qCheckBarnacleExists.recordCount>
															<cfquery datasource="#application.dsn#">
																update farBarnacle set barnaclevalue=1 where objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qCheckBarnacleExists.objectid#" />
															</cfquery>
														<cfelse>
															<cfquery datasource="#application.dsn#">
																 INSERT INTO farBarnacle ( 
																	createdby, datetimecreated, datetimelastupdated, label, lastupdatedby, locked, lockedBy, ObjectID, ownedby,
																	roleid, permissionID, referenceID, objecttype, barnaclevalue
																) VALUES ( 
																	'6.2 upgrade', <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, '', '6.2 upgrade', 0, '', '#application.fapi.getUUID()#', '',
																	'#stRole.objectid#', '#viewWebtopItemID#', '#barnacleID#', 'webtop', 1
																)
															</cfquery>
														</cfif>
													<cfelse>
												
														<cfquery datasource="#application.dsn#" name="qCheckBarnacleExists">
														SELECT objectid
														FROM farBarnacle
														WHERE roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stRole.objectid#">
														AND permissionID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#viewWebtopItemID#">
														AND referenceid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
														AND objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="webtop">
														</cfquery>
														
														<cfif qCheckBarnacleExists.recordCount>
															<cfquery datasource="#application.dsn#">
																update farBarnacle set barnaclevalue=-1 where objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qCheckBarnacleExists.objectid#" />
															</cfquery>
														<cfelse>
															<cfquery datasource="#application.dsn#">
																 INSERT INTO farBarnacle ( 
																	createdby, datetimecreated, datetimelastupdated, label, lastupdatedby, locked, lockedBy, ObjectID, ownedby,
																	roleid, permissionID, referenceID, objecttype, barnaclevalue
																) VALUES ( 
																	'6.2 upgrade', <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, '', '6.2 upgrade', 0, '', '#application.fapi.getUUID()#', '',
																	'#stRole.objectid#', '#viewWebtopItemID#', '#barnacleID#', 'webtop', -1
																)
															</cfquery>
														</cfif>
													</cfif>
												</cfif>
											</cfif>
										</cfloop>
										
										
									</cfloop>
									<cfset c = c + qAllRoles.recordcount />
									
								</cfif>
							</cfloop>
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
			<cfset application.fapi.addRequestLog("Updated #c# webtop barnacles") />
		</cfif>
		
		<cfset application.fapi.addRequestLog("Finished 6.2 update") />
		<cfreturn application.fapi.success("upgraded successfully.") />
		
	</cffunction>
	
</cfcomponent>