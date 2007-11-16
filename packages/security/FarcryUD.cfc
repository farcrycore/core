<cfcomponent displayname="Farcry User Directory" hint="Provides the interface for the FarCry user directory" extends="UserDirectory" output="false">

	<cfset this.title = "Farcry User Directory" />
	<cfset this.key = "CLIENTUD" />
	
	<cfset this.encrypted = false />

	<!--- ====================
	  UD Interface functions
	===================== --->
	<cffunction name="getLoginForm" access="public" output="false" returntype="component" hint="Returns the form component to use for login">
		
		<cfreturn application.factory.oUtils.getPath("forms","FarcryUDLogin") />
	</cffunction>
	
	<cffunction name="authenticate" access="public" output="false" returntype="struct" hint="Attempts to process a user. Runs every time the login form is loaded.">
		<cfset var stResult = structnew() />
		<cfset var qUser = "" />
		
		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
		
		<cfif isdefined("Application.dmSec.UserDirectory.CLIENTUD.bEncrypted")>
			<cfset this.encrypted = Application.dmSec.UserDirectory.CLIENTUD.bEncrypted />
		</cfif>
		
		<!--- For backward compatability, check for userlogin and password in form. This should be removed once we're willing to not support pre 4.1 login templates --->
		<cfif structkeyexists(form,"userlogin") and structkeyexists(form,"password")>
			<!--- If password encryption is enabled, hash the password --->
			<cfif this.encrypted>
				<cfset form.password = hash(form.password) />
			</cfif>
			
			<!--- Find the user --->
			<cfquery datasource="#application.dsn#" name="qUser">
				select	*
				from	#application.dbowner#farUser
				where	userid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.userlogin#" />
						and password=<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.password#" />
			</cfquery>
		<cfelse>
			<ft:processform>
				<ft:processformObjects typename="FarcryUDLogin" r_stObject="stLogin">
					<!--- If password encryption is enabled, hash the password --->
					<cfif this.encrypted>
						<cfset stLogin.password = hash(stLogin.password) />
					</cfif>
					
					<!--- Find the user --->
					<cfquery datasource="#application.dsn#" name="qUser">
						select	*
						from	#application.dbowner#farUser
						where	userid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stLogin.userlogin#" />
								and password=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stLogin.password#" />
					</cfquery>
				</ft:processformObjects>
			</ft:processform>
		</cfif>
		
		<!--- If (somehow) a login was submitted, process the result --->
		<cfif isquery(qUser)>
					
			<!--- Set the result --->
			<cfif qUser.recordcount and qUser.userstatus eq "active">
				<!--- User successfully logged in --->
				<cfset stResult.authenticated = true />
				<cfset stResult.userid = qUser.userid />
			<cfelseif qUser.recordcount>
				<!--- User's account is disabled --->
				<cfset stResult.authenticated = false />
				<cfset stResult.errormessage = "Your account is diabled" />
			<cfelse>
				<!--- User login or password is incorrect --->
				<cfset stResult.authenticated = false />
				<cfset stResult.errormessage = "The username or password was incorrect">
			</cfif>
		
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="getUserGroups" access="public" output="false" returntype="string" hint="Returns the groups that the specified user is a member of">
		<cfargument name="UserID" type="string" required="true" hint="The user being queried" />
		
		<cfset var qUser = "" />
		
		<cfquery datasource="#application.dsn#" name="qGroups">
			select	g.title
			from	(
						#application.dbowner#farUser u
						inner join
						#application.dbowner#farUser_Groups ug
						on u.objectid=ug.parentid
					)
					inner join
					#application.dbowner#farGroup g
					on ug.data=g.objectid
			where	userid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userid#" />
		</cfquery>
		
		<cfreturn valuelist(qGroups.title) />
	</cffunction>
	
	<cffunction name="getAllGroups" access="public" output="false" returntype="string" hint="Returns all the groups that this user directory supports">
		<cfset var qGroups = "" />
		<cfset var result = "" />
		
		<cfquery datasource="#application.dsn#" name="qGroups">
			select		*
			from		#application.dbowner#farGroup
			order by	title
		</cfquery>

		<cfreturn valuelist(qGroups.title) />
	</cffunction>
	
	<cffunction name="getGroupUsers" access="public" output="false" returntype="string" hint="Returns all the users in a specified group">
		<cfargument name="group" type="string" required="true" hint="The group to query" />
		
		<cfset var qUsers = "" />
		
		<cfquery datasource="#application.dsn#" name="qUsers">
			select	userid
			from	(
						#application.dbowner#farUser u
						inner join
						#application.dbowner#farUser_Groups ug
						on u.objectid=ug.parentid
					)
					inner join
					#application.dbowner#farGroup g
					on ug.data=g.objectid
			where	g.title=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.group#" />
		</cfquery>
		
		<cfreturn valuelist(qUsers.userid) />
	</cffunction>
	
	<!--- =============================
	  Pre 4.1 data migration functions
	============================== --->
	
	<cffunction name="migratePermissions" access="private" output="false" returntype="struct" hint="Migrates the permission data, and returns a struct mapping the old ids to the new objectids">
		<cfset var stResult = structnew() />
		<cfset var qPermissions = "" />
		<cfset var oPermission = createObject("component", application.stcoapi["farPermission"].packagePath) />
		<cfset var stObj = structnew() />
		
		<!--- Get data --->
		<cfquery datasource="#application.dsn#" name="qPermissions">
			select	*
			from	#application.dbowner#dmPermission
		</cfquery>
		
		<!--- Add data --->
		<cfloop query="qPermissions">
			<cfset stObj = structnew() />
			<cfset stObj.objectid = createuuid() />
			<cfset stObj.title = permissionname />
			<cfset stObj.shortcut = permissionname />
			<cfset stObj.label = permissionname />
			<cfif permissiontype neq "PolicyGroup">
				<cfparam name="stObj.relatedtypes" default="#arraynew(1)#" />
				<cfset arrayappend(stObj.relatedtypes,permissiontype) />
			</cfif>
			
			<cfset oPermission.createData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
			
			<cfset stResult[permissionid] = stObj.objectid />
		</cfloop>		
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="migrateRoles" access="private" output="false" returntype="struct" hint="Migrates the roles (policy groups previously) and returns a struct mapping the old ids to the new objectids">
		<cfset var stResult = structnew() />
		<cfset var qPolicyGroups = "" />
		<cfset var oRole = createObject("component", application.stcoapi["farRole"].packagePath) />
		<cfset var stObj = structnew() />
		
		<!--- Get data --->
		<cfquery datasource="#application.dsn#" name="qPolicyGroups">
			select	*
			from	#application.dbowner#dmPolicyGroup
		</cfquery>
		
		<!--- Add data --->
		<cfloop query="qPolicyGroups">
			<cfset stObj = structnew() />
			<cfset stObj.objectid = createuuid() />
			<cfset stObj.title = policygroupname />
			<cfset stObj.label = policygroupname />
			<cfif policygroupname eq "Anonymous">
				<cfset stObj.isdefault = true />
			</cfif>
			
			<cfswitch expression="#policygroupname#">
				<cfcase value="anonymous">
					<cfset stObj.webskins = "display*" />
				</cfcase>
				<cfcase value="Contributors,Publishers,SiteAdmin,SysAdmin" delimiters=",">
					<cfset stObj.webskins = "*" />
				</cfcase>
				<cfdefaultcase>
					<cfset stObj.webskins = "" />
				</cfdefaultcase>
			</cfswitch>
			
			<cfset oRole.createData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
			
			<cfset stResult[policygroupid] = stObj.objectid />
		</cfloop>		
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="migrateGroups" access="private" output="false" returntype="struct" hint="Migrates the user directory groups and returns a struct mapping the old ids to the new objectids">
		<cfset var stResult = structnew() />
		<cfset var qGroups = "" />
		<cfset var oGroup = createObject("component", application.stcoapi["farGroup"].packagePath) />
		<cfset var stObj = structnew() />
		
		<!--- Get data --->
		<cfquery datasource="#application.dsn#" name="qGroups">
			select	*
			from	#application.dbowner#dmGroup
		</cfquery>
		
		<!--- Add data --->
		<cfloop query="qGroups">
			<cfset stObj = structnew() />
			<cfset stObj.objectid = createuuid() />
			<cfset stObj.title = groupname />
			<cfset stObj.label = groupname />
			
			<cfset oGroup.createData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
			
			<cfset stResult[groupid] = stObj.objectid />
			<cfset stResult[groupname] = stObj.objectid />
		</cfloop>		
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="migrateUsers" access="private" output="false" returntype="struct" hint="Migrates the user directory users and returns a struct mapping the old ids to the new objectids">
		<cfset var stResult = structnew() />
		<cfset var qUsers = "" />
		<cfset var oUser = createObject("component", application.stcoapi["farUser"].packagePath) />
		<cfset var stObj = structnew() />
		
		<!--- Get data --->
		<cfquery datasource="#application.dsn#" name="qUsers">
			select	*
			from	#application.dbowner#dmUser
		</cfquery>
		
		<!--- Add data --->
		<cfloop query="qUsers">
			<cfset stObj = structnew() />
			<cfset stObj.objectid = createuuid() />
			<cfset stObj.userid = userlogin />
			<cfset stObj.password = userpassword />
			<cfset stObj.label = userlogin />
			<cfif userstatus eq 4>
				<cfset stObj.userstatus = "active" />
			<cfelse>
				<cfset stObj.userstatus = "disabled" />
			</cfif>
			
			<cfset oUser.createData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
			
			<cfset stResult[userid] = stObj.objectid />
		</cfloop>		
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="migrateUserGroups" access="private" output="false" returntype="numeric" hint="Migrates the user directory groups">
		<cfargument name="users" type="struct" required="true" hint="Maps old user ids to new objectids" />
		<cfargument name="groups" type="struct" required="true" hint="Maps old gruop ids to new objectids" />
		
		<cfset var result = 0 />
		<cfset var qUserGroups = "" />
		<cfset var oUser = createObject("component", application.stcoapi["farUser"].packagePath) />
		<cfset var stObj = structnew() />
		
		<!--- Get data --->
		<cfquery datasource="#application.dsn#" name="qUserGroups">
			select		*
			from		#application.dbowner#dmUserToGroup
			order by	userid
		</cfquery>
		
		<!--- Add data --->
		<cfoutput query="qUserGroups" group="userid">
			<cfset stObj = oUser.getData(objectid=arguments.users[userid]) />
			<cfparam name="stObj.groups" default="#arraynew(1)#" />
			
			<cfoutput>
				<cfset arrayappend(stObj.groups,arguments.groups[groupid]) />
				<cfset result = result + 1 />
			</cfoutput>
			
			<cfset oUser.setData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
		</cfoutput>
		
		<cfreturn result />
	</cffunction>

	<cffunction name="migrateMappings" access="private" output="false" returntype="numeric" hint="Migrates the mappings between the user directory groups and the Farcry roles">
		<cfargument name="groups" type="struct" required="true" hint="Maps old group ids to new objectids" />
		<cfargument name="roles" type="struct" required="true" hint="Maps old role ids to new objectids" />
		
		<cfset var result = 0 />
		<cfset var qMappings = "" />
		<cfset var oRole = createObject("component", application.stcoapi["farRole"].packagePath) />
		<cfset var stObj = structnew() />
		
		<!--- Get data --->
		<cfquery datasource="#application.dsn#" name="qMappings">
			select		*
			from		#application.dbowner#dmExternalGroupToPolicyGroup
			order by	PolicyGroupId
		</cfquery>
		
		<!--- Add data --->
		<cfoutput query="qMappings" group="PolicyGroupId">
			<cfset stObj = oRole.getData(objectid=arguments.roles[PolicyGroupId]) />
			<cfparam name="stObj.groups" default="#arraynew(1)#" />
			
			<cfoutput>
				<cfset arrayappend(stObj.groups,"#externalgroupname#_#this.key#") />
				<cfset result = result + 1 />
			</cfoutput>
			
			<cfset oRole.setData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
		</cfoutput>
		
		<cfreturn result />
	</cffunction>	
	
	<cffunction name="migrateBarnacles" access="private" output="false" returntype="numeric" hint="Migrates the role permissions">
		<cfargument name="permissions" type="struct" required="true" hint="Maps old permission ids to new objectids" />
		<cfargument name="roles" type="struct" required="true" hint="Maps old role ids to new objectids" />
		
		<cfset var result = 0 />
		<cfset var qBarnacles = "" />
		<cfset var qRoleBarnacles = "" />
		<cfset var oRole = createObject("component", application.stcoapi["farRole"].packagePath) />
		<cfset var oBarnacle = createObject("component", application.stcoapi["farBarnacle"].packagePath) />
		<cfset var stRole = structnew() />
		<cfset var stBarnacles = structnew() />
		<cfset var objectid = "" />
		
		<!--- Get data --->
		<cfquery datasource="#application.dsn#" name="qBarnacles">
			select		*
			from		#application.dbowner#dmPermissionBarnacle
			where		status = 1
			order by	PolicyGroupId
		</cfquery>
		
		<!--- Add data --->
		<cfoutput query="qBarnacles" group="PolicyGroupId">
			<cfset stRole = oRole.getData(objectid=arguments.roles[PolicyGroupId]) />
			<cfparam name="stRole.permissions" default="#arraynew(1)#" />
			
			<cfoutput>
				<cfif structkeyexists(arguments.permissions,permissionid)>
					<cfif len(reference1) and isvalid("uuid",reference1)>
						<!--- If this barnacle is related to a particular item, the new barnacle structure (which refers to items in an array) has already been created --->
						<cfset oBarnacle.updateRight(role=stRole.objectid,permission=arguments.permissions[permissionid],object=reference1,right=status)>
					<cfelseif reference1 eq "PolicyGroup">
						<!--- If this barnacle isn't related to a particular item, add it as a generic permission to this role --->
						<cfset arrayappend(stRole.permissions,arguments.permissions[permissionid]) />
					</cfif>
					
					<cfset result = result + 1 />
				</cfif>
			</cfoutput>
			
			<cfloop collection="#stBarnacles#" item="objectid">
				<cfset oBarnacle.setData(stBarnacles[objectid]) />
			</cfloop>
			
			<cfset oRole.setData(stProperties=stRole,user="migratescript",auditNote="Data migrated from pre 4.1") />
		</cfoutput>
		
		<cfreturn result />
	</cffunction>
		
	<cffunction name="migrate" access="public" output="true" returntype="string" hint="Migrates data from the previous DB structure and returns the results">
		<cfset var result = "" />
		
		<!--- Migrate basic data --->
		<cfset var stPermissions = migratePermissions() />
		<cfset var stRoles = migrateRoles() />
		<cfset var stGroups = migrateGroups() />
		<cfset var stUsers = migrateUsers() />
		
		<!--- Process relational data and build result string --->
		<cfset result = result & "Permissions: #structcount(stPermissions)#<br/>" />
		<cfset result = result & "Roles: #structcount(stRoles)#<br/>" />
		<cfset result = result & "Groups: #structcount(stGroups)#<br/>" />
		<cfset result = result & "Users: #structcount(stUsers)#<br/>" />
		<cfset result = result & "User group membership: #migrateUserGroups(stUsers,stGroups)#<br/>" />
		<cfset result = result & "Role-group mappings: #migrateMappings(stGroups,stRoles)#<br/>" />
		<cfset result = result & "Barnacles: #migrateBarnacles(stPermissions,stRoles)#<br/>" />
		
		<cfreturn result />
	</cffunction>

</cfcomponent>