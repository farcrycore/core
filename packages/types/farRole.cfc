<cfcomponent displayname="Role" hint="Used to group permission settings and associate them with user groups" extends="types" output="false" description="Categorises a set of permissions as being necessary for a particular role. This role can then be assigned to a group of users.">
	<cfproperty name="title" type="string" default="" hint="The name of the role" bLabel="true" ftSeq="1" ftWizardStep="Groups" ftLabel="Title" ftType="string" />
	<cfproperty name="isdefault" type="boolean" default="0" hint="True if this is a default role. Every user will be assigned these permissions." ftSeq="2" ftWizardStep="Groups" ftLabel="Default role" ftType="boolean" />
	<cfproperty name="groups" type="array" default="" hint="The user directory groups that this role has been assigned to" ftSeq="3" ftWizardStep="Groups" ftLabel="Groups" ftType="array" ftJoin="farRole" ftRenderType="list" ftLibraryData="getGroups" ftShowLibraryLink="false" />
	<cfproperty name="permissions" type="array" hint="The simple permissions that are granted as part of this role" ftSeq="11" ftWizardStep="Permissions" ftLabel="Permissions" ftJoin="farPermission" />
	<cfproperty name="webskins" type="longchar" default="" hint="A list of wildcard items that match the webkins this role can access" ftSeq="21" ftWizardStep="Webskins" ftLabel="Webskins" ftType="webskinfilter" />
	
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
		
		<cfset var result = "" />
		<cfset var group = "" />
		
		<cfloop list="#arguments.groups#" index="group">
			<cfquery datasource="#application.dsn#" name="qRoles">
				select	*
				from	#application.dbowner#farRole_groups
				where	lower(data)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(group)#" />
			</cfquery>
			
			<cfset result = application.factory.oUtils.listMerge(result,valuelist(qRoles.parentid)) />		
		</cfloop>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getRight" access="public" output="false" returntype="numeric" hint="Returns the right for the specfied permission">
		<cfargument name="role" type="string" required="true" hint="The roles to check" />
		<cfargument name="permission" type="string" required="false" default="" hint="The permission to retrieve" />
		<cfargument name="forcerefresh" type="boolean" required="false" default="false" hint="Should the cache be forcably refreshed" />
		
		<cfset thisrole = "" />
		<cfset result = 0 />
		<cfset thisresult = -1 />
		<cfset qRole = "" />
		
		<cfloop list="#arguments.role#" index="thisrole">
			<!--- If possible use the cache, otherwise update cache --->
			<cfif not arguments.forcerefresh and application.security.isCached(role=thisrole,permission=arguments.permission)>
				<cfset thisresult = application.security.getCache(role=thisrole,permission=arguments.permission) />
			<cfelse>
				<cfquery datasource="#application.dsn#" name="qRole" result="stResult">
					select	*
					from	#application.dbowner#farRole_permissions
					where	parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#thisrole#" />
							and data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permission#" />
				</cfquery>
				
				<cfset thisresult = application.security.setCache(role=thisrole,permission=arguments.permission,right=qRole.recordcount) />
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
	
	<cffunction name="checkWebskin" access="public" output="false" returntype="boolean" hint="Returns true if this role grants access the the webskin">
		<cfargument name="role" type="string" required="true" hint="The roles to check" />
		<cfargument name="type" type="string" required="true" hint="The type to check" />
		<cfargument name="webskin" type="string" required="true" hint="The webskin to check" />
		<cfargument name="forcerefresh" type="boolean" required="false" default="false" hint="Should the cache be forcably refreshed" />
		
		<cfset var thisrole = "" />
		<cfset var stRole = structnew() />
		<cfset var filter = "" />
		
		<cfloop list="#arguments.role#" index="thisrole">
			<cfif not arguments.forcerefresh and application.security.isCached(role=thisrole,webskin="#arguments.type#.#arguments.webskin#")>
				<cfif application.security.getCache(role=thisrole,webskin="#arguments.type#.#arguments.webskin#")>
					<cfreturn true />
				</cfif>
			<cfelse>
				<cfset stRole = getData(thisrole) />
				<cfloop list="#stRole.webskins#" index="filter" delimiters="#chr(10)##chr(13)#,">
					<cfif (not find(".",filter) or listfirst(filter,".") eq "*" or listfirst(filter,".") eq arguments.type) and refind(replace(listlast(filter,"."),"*",".*","ALL"),arguments.webskin)>
						<cfreturn application.security.setCache(role=thisrole,webskin="#arguments.type#.#arguments.webskin#", right=1) />
					<cfelse>
						<cfset application.security.setCache(role=thisrole,webskin="#arguments.type#.#arguments.webskin#", right=0) />
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfreturn false />
	</cffunction>
	
	<cffunction name="getID" access="public" output="false" returntype="uuid" hint="Returns the objectid for the specified object">
		<cfargument name="name" type="string" required="true" hint="Pass in a role name and the objectid will be returned" />
		
		<cfset var qRoles = "" />
		
		<cfif not application.security.hasLookup(role=arguments.name)>
			<cfquery datasource="#application.dsn#" name="qRoles">
				select	objectid,label
				from	#application.dbOwner#farRole
			</cfquery>
			
			<cfreturn application.security.setLookup(role=arguments.role,objectid=qRoles.objectid[1]) />
		<cfelse>
			<cfreturn application.security.getLookup(role=arguments.name) />
		</cfif>
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
			<cfset arguments.objectid = getID(arguments.role) />
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
			where	role=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>
		
		<!--- Create copies of the barnacles for the new role --->
		<cfloop query="qBarnacles">
			<cfset stBarnacle = application.security.factory.barnacle.getData(qBarnacles.objectid[currentrow]) />
			<cfset stBarnacle.objectid = createuuid() />
			<cfset stBarnacle.role = stObj.objectid />
			<cfset application.security.factory.barnacle.createData(stBarnacle) />
		</cfloop>
		
		<cfreturn stObj />
	</cffunction>
		
	<cffunction name="afterSave" access="public" output="false" returntype="struct" hint="Processes new type content">
		<cfargument name="stProperties" type="struct" required="true" hint="The properties that have been saved" />
		
		<cfset var i = 0 />
		
		<!--- Clear the permission cache --->
		<cfset application.security.deleteCache(role=arguments.stProperties.objectid) />
		
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
		
		<cfreturn super.delete(objectid=arguments.objectid,user=arguments.user,audittype=arguments.audittype) />
	</cffunction>

</cfcomponent>