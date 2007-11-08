<cfcomponent displayname="Role" hint="Used to group permission settings and associate them with user groups" extends="types" output="false" description="Categorises a set of permissions as being necessary for a particular role. This role can then be assigned to a group of users.">
	<cfproperty name="title" type="string" default="" hint="The name of the role" bLabel="true" ftSeq="1" ftFieldset="" ftLabel="Title" ftType="string" />
	<cfproperty name="isdefault" type="boolean" default="0" hint="True if this is a default role. Every user will be assigned these permissions." ftSeq="2" ftFieldset="" ftLabel="Default role" ftType="boolean" />
	<cfproperty name="permissions" type="array" hint="The simple permissions that are granted as part of this role" ftSeq="3" ftFieldset="" ftLabel="Permissions" ftJoin="farPermission" />
	<cfproperty name="webskins" type="longchar" default="" hint="A list of wildcard items that match the webkins this role can access" ftSeq="4" ftFieldset="" ftLabel="Webskins" ftType="string" />
	<cfproperty name="groups" type="array" default="" hint="The user directory groups that this role has been assigned to" ftSeq="5" ftFieldset="" ftLabel="Groups" ftType="array" ftJoin="farRole" ftRenderType="list" ftLibraryData="getGroups" ftShowLibraryLink="false" />
	
	<cffunction name="getGroups" access="public" output="false" returntype="query" hint="Returns a query of UD groups">
		<cfset var qResult = querynew("objectid,label","varchar,varchar") />
		<cfset var ud = "" />
		<cfset var group = "" />
		
		<cfif structkeyexists(application,"security") and structkeyexists(application.security,"userdirectories")>
			<cfloop collection="#application.security.userdirectories#" item="ud">
				<cfloop list="#application.security.userdirectories[ud].getAllGroups()#" index="group">
					<cfset queryaddrow(qResult) />
					<cfset querysetcell(qResult,"objectid","#group#_#ud#") />
					<cfset querysetcell(qResult,"label","#group# (#application.security.userdirectories[ud].title#)")>
				</cfloop>
			</cfloop>
		</cfif>
		
		<cfreturn qResult />
	</cffunction>
	
	<cffunction name="groupsToRoles" access="public" output="false" returntype="string" hint="Converts a list of user directory groups to their equivilent Farcry roles">
		<cfargument name="groups" type="string" required="true" hint="The groups to convert" />
		
		<cfset var result = getDefaultRoles() />
		<cfset var group = "" />
		
		<cfloop list="#arguments.groups#" index="group">
			<cfif not isdefined("application.security.cache.groups") or not structkeyexists(application.security.cache.groups,group)>
				<cfquery datasource="#application.dsn#" name="qRoles">
					select	*
					from	#application.dbowner#farRole_groups
					where	data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#group#" />
				</cfquery>
				
				<cfparam name="application.security.cache.groups" default="#structnew()#" />
				<cfif not structkeyexists(application.security.cache.groups,group)>
					<cfset application.security.cache.groups[group] = structnew() />
				</cfif>
				<cfif qRoles.recordcount>
					<cfset application.security.cache.groups[group].roles = valuelist(qRoles.parentid) />
				<cfelse>
					<cfset application.security.cache.groups[group].roles = "" />
				</cfif>
			</cfif>
			
			<cfset result = application.factory.oUtils.listMerge(result,application.security.cache.groups[group].roles) />
		</cfloop>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="setCache" access="private" output="false" returntype="boolean" hint="Sets up the cache structure">
		<cfargument name="role" type="uuid" required="true" hint="The role the barnacle is attached to" />
		<cfargument name="permission" type="uuid" required="true" hint="The permission the barnacle is based on" />
		<cfargument name="right" type="numeric" required="true" hint="The right value to cache" />
		
		<cfif not isdefined("application.security.cache")>
			<cfset application.security.cache = structnew() />
		</cfif>
		<cfif not structkeyexists(application.security.cache,arguments.role)>
			<cfset application.security.cache[arguments.role] = structnew() />
		</cfif>
		<cfif not structkeyexists(application.security.cache[arguments.role],"permissions")>
			<cfset application.security.cache[arguments.role].permissions = structnew() />
		</cfif>
		<cfset application.security.cache[arguments.role].permissions[arguments.permission] = arguments.right />
		
		<cfreturn arguments.right />
	</cffunction>

	<cffunction name="isCached" access="private" output="false" returntype="boolean" hint="Returns true if the right is cached">
		<cfargument name="role" type="uuid" required="true" hint="The role the barnacle is attached to" />
		<cfargument name="permission" type="uuid" required="true" hint="The permission the barnacle is based on" />
		
		<cfreturn structkeyexists(application.security.cache,arguments.role) and structkeyexists(application.security.cache[arguments.role],"permissions") and structkeyexists(application.security.cache[arguments.role].permissions,arguments.permission) />
	</cffunction>
	
	<cffunction name="getCache" access="private" output="false" returntype="boolean" hint="Returns the cached right. Doesn't error check.">
		<cfargument name="role" type="uuid" required="true" hint="The role the barnacle is attached to" />
		<cfargument name="permission" type="uuid" required="true" hint="The permission the barnacle is based on" />
		
		<cfreturn application.security.cache[arguments.role].permissions[arguments.permission] />
	</cffunction>
	
	<cffunction name="getRight" access="public" output="false" returntype="numeric" hint="Returns the right for the specfied permission">
		<cfargument name="role" type="string" required="false" default="" hint="The role the barnacle is attached to" />
		<cfargument name="permission" type="string" required="false" default="" hint="The permission the barnacle is based on" />
		<cfargument name="forcerefresh" type="boolean" required="false" default="false" hint="Should the cache be forcably refreshed" />
		
		<cfset thisrole = "" />
		<cfset result = 0 />
		<cfset thisresult = -1 />
		<cfset qRole = "" />
		
		<cfif not len(arguments.role)>
			<cfset arguments.role = getRoles() />
		</cfif>
			
		<cfloop list="#arguments.role#" index="thisrole">
			<!--- If possible use the cache, otherwise update cache --->
			<cfif not arguments.forcerefresh and isCached(thisrole,arguments.permission)>
				<cfset thisresult = getCache(thisrole,arguments.permission) />
			<cfelse>
				<cfquery datasource="#application.dsn#" name="qRole" result="stResult">
					select	*
					from	#application.dbowner#farRole_permissions
					where	parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#thisrole#" />
							and data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permission#" />
				</cfquery>
				
				<cfset thisresult = setCache(thisrole,arguments.permission,qRole.recordcount) />
			</cfif>
			
			<!--- Result is the most permissable right granted. 1 is the most permissable, so if that is returned we don't need to check any more --->
			<cfif thisresult eq 1>
				<cfreturn 1 />
			<cfelseif thisresult gt result>
				<cfset result = thisresult />
			</cfif>
		</cfloop>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="checkPermission" access="public" output="false" returntype="boolean" hint="Checks the permission on an object">
		<cfargument name="object" type="string" required="false" default="" hint="If specified, will check barnacle" />
		<cfargument name="permission" type="string" required="true" hint="The permission to check" />
		<cfargument name="role" type="string" required="false" default="" hint="List of roles to check" />
		
		<cfif not isvalid("uuid",arguments.permission)>
			<cfset arguments.permission = createObject("component", application.stcoapi["farPermission"].packagePath).getID(arguments.permission) />
		</cfif>
		
		<cfif len(arguments.object)>
			<cfreturn createObject("component", application.stcoapi["farBarnacle"].packagePath).checkPermission(object=arguments.object,permission=arguments.permission,role=arguments.role) />
		<cfelse>
			<cfreturn getRight(role=arguments.role,permission=arguments.permission) />
		</cfif>
	</cffunction>
	
	<cffunction name="getID" access="public" output="false" returntype="uuid" hint="Returns the objectid for the specified object">
		<cfargument name="name" type="string" required="true" hint="Pass in a role name and the objectid will be returned" />
		
		<cfset var qRoles = "" />
		
		<cfif not isdefined("application.security.rolelookup") or not structkeyexists(application.security.rolelookup,arguments.name)>
			<cfquery datasource="#application.dsn#" name="qRoles">
				select	objectid,label
				from	#application.dbOwner#farRole
			</cfquery>
			
			<cfparam name="application.security" default="#structnew()#" />
			<cfparam name="application.security.rolelookup" default="#structnew()#" />
			<cfloop query="qRoles">
				<cfset application.security.rolelookup[label] = objectid />
			</cfloop>
		</cfif>
		
		<cfif not structkeyexists(application.security.rolelookup,arguments.name)>
			<cfreturn createuuid() />
		</cfif>
		
		<cfreturn application.security.rolelookup[arguments.name] />
	</cffunction>

	<cffunction name="getLabel" access="public" output="false" returntype="uuid" hint="Returns the label for the specified object">
		<cfargument name="objectid" type="uuid" required="true" hint="Pass in a role name and the objectid will be returned" />
		
		<cfset var qRoles = "" />
		
		<cfif not isdefined("application.security.roles") or not structkeyexists(application.security.roles,arguments.name)>
			<cfquery datasource="#application.dsn#" name="qRoles">
				select	objectid,label
				from	#application.dbOwner#farRole
			</cfquery>
			
			<cfparam name="application.security" default="#structnew()#" />
			<cfparam name="application.security.roles" default="#structnew()#" />
			<cfloop query="qRoles">
				<cfset application.security.roles[objectid] = label />
			</cfloop>
		</cfif>
		
		<cfreturn application.security.roles[objectid].label />
	</cffunction>

	<cffunction name="getDefaultRoles" access="public" output="false" returntype="string" hint="Returns a list of the default roles">
		<cfset var qRoles = "" />
		
		<cfif not isdefined("application.security.defaultroles")>
			<cfquery datasource="#application.dsn#" name="qRoles">
				select	objectid
				from	#application.dbowner#farRole
				where	isdefault=1
			</cfquery>
			
			<cfparam name="application.security" default="#structnew()#" />
			<cfset application.security.defaultroles = valuelist(qRoles.objectid) />
		</cfif>
		
		<cfreturn application.security.defaultroles />
	</cffunction>
	
	<cffunction name="getRoles" access="public" output="false" returntype="string" hint="Returns a list of the roles the current user has">
		
		<cfif isdefined("session.security.roles")>
			<cfreturn session.security.roles />
		<cfelse>
			<cfreturn getDefaultRoles() />
		</cfif>
		
	</cffunction>
	
	<cffunction name="getAllRoles" access="public" output="false" returntype="string" hint="Returns list of all role objectids">
		<cfset var qRoles = "" />

		<cfquery datasource="#application.dsn#" name="qRoles">
			select	objectid
			from	#application.dbowner#farRole
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
			<cfset arguments.objectid = getID(arguments.role) />
		</cfif>
		
		<!--- Get data --->
		<cfset stRole = getData(objectid=arguments.role) />
		
		<!--- If the name of the permission was passed in, get the objectid --->
		<cfif not isvalid("uuid",arguments.permission)>
			<cfset arguments.permission = createObject("component", application.stcoapi["farPermission"].packagePath).getID(arguments.permission) />
		</cfif>
		
		<!--- Get the relevant permission --->
		<cfquery datasource="#application.dsn#" name="qPermissions">
			select	*
			from	#application.dbowner#farRole_permissions
			where	parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.role#" />
					and data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permission#" />
		</cfquery>
		
		<!--- Update the permission --->
		<cfif arguments.has and not qPermissions.recordcount>
			<!--- Add the permission --->
			<cfset arrayappend(stRole.permissions,arguments.permission) />
			<cfset setData(stProperties=stRole) />
		</cfif>
		<cfif not arguments.has and qPermissions.recordcount>
			<!--- Remove the permission --->
			<cfset arraydeleteat(stRole.permissions,qPermissions.seq) />
			<cfset setData(stProperties=stRole) />
		</cfif>
		
	</cffunction>

	<cffunction name="updateBarnacle" access="public" output="false" returntype="void" hint="Adds or removes an item permission">
		<cfargument name="role" type="uuid" required="true" hint="The role to update" />
		<cfargument name="permission" type="string" required="true" hint="The permission to add / remove" />
		<cfargument name="item" type="uuid" required="true" hint="The item to update the permission for" />
		<cfargument name="right" type="numeric" required="true" hint="Deny: -1, Inherit: 0, Grant: 1" />
		
		<cfset createObject("component", application.stcoapi["farBarnacle"].packagePath).updateRight(role=arguments.role,permission=arguments.permission,object=arguments.item,right=arguments.right) />
		
	</cffunction>
	
	<cffunction name="copyRole" access="public" output="false" returntype="struct" hint="Copies a role and gives it a new name">
		<cfargument name="objectid" type="uuid" required="true" hint="The role to copy" />
		<cfargument name="title" type="string" required="true" hint="The title of the new role" />
		
		<cfset var stObj = getData(arguments.objectid) />
		<cfset var qBarnacles = "" />
		<cfset var oBarnacle = createObject("component", application.stcoapi["farBarnacle"].packagePath) />
		<cfset var stBarnacle = structnew() />
		
		<!--- Update and save --->
		<cfset stObj.objectid = createuuid() />
		<cfset stObj.title = arguments.title />
		<cfset createData(stProperties=stObj) />
		
		<!--- Get the barnacles for the role --->
		<cfquery datasource="#application.dsn#" name="qBarnacles">
			select	objectid
			from	#application.dbowner#farBarnacle
			where	role=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>
		
		<!--- Create copies of the barnacles for the new role --->
		<cfloop query="qBarnacles">
			<cfset stBarnacle = oBarnacle.getData(qBarnacles.objectid[currentrow]) />
			<cfset stBarnacle.objectid = createuuid() />
			<cfset stBarnacle.role = stObj.objectid />
			<cfset oBarnacle.createData(stBarnacle) />
		</cfloop>
		
		<cfreturn stObj />
	</cffunction>
		
	<cffunction name="afterSave" access="public" output="false" returntype="struct" hint="Processes new type content">
		<cfargument name="stProperties" type="struct" required="true" hint="The properties that have been saved" />
		
		<cfset var i = 0 />
		
		<!--- Update general permission cache --->
		<cfif not isdefined("application.security.cache") or not structkeyexists(application.security.cache,arguments.stProperties.objectid)>
			<cfset application.security.cache[arguments.stProperties.objectid] = structnew() />
		</cfif>
		<cfset application.security.cache[arguments.stProperties.objectid].permissions = structnew() />
		<cfloop from="1" to="#arraylen(arguments.stProperties.permissions)#" index="i">
			<cfset application.security.cache[arguments.stProperties.objectid].permissions[arguments.stProperties.permissions[i]] = true />
		</cfloop>
		
		<!--- Update webskin permission cache --->
		<cfset application.security.cache[arguments.stProperties.objectid].webskinfilter = arguments.stProperties.webskins />
		<cfset application.security.cache[arguments.stProperties.objectid].webskins = structnew() />
		
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
			where	role=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>
		
		<!--- Remove from cache --->
		<cfif structkeyexists(application.security.cache,arguments.objectid)>
			<cfset structdelete(application.security.cache,arguments.objectid) />
		</cfif>
		
		<cfreturn super.delete(objectid=arguments.objectid,user=arguments.user,audittype=arguments.audittype) />
	</cffunction>

</cfcomponent>