<cfcomponent displayname="Farcry User Directory" hint="Provides the interface for the FarCry user directory" extends="UserDirectory" output="false" key="CLIENTUD" bEncrypted="false">
	
	<!--- ====================
	  UD Interface functions
	===================== --->
	<cffunction name="getLoginForm" access="public" output="false" returntype="string" hint="Returns the form component to use for login">
		
		<cfreturn "farLogin" />
	</cffunction>
	
	<cffunction name="authenticate" access="public" output="false" returntype="struct" hint="Attempts to process a user. Runs every time the login form is loaded.">
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var qUser = "" />
		
		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
		
		<cfif isdefined("Application.dmSec.UserDirectory.CLIENTUD.bEncrypted")>
			<cfset this.bEncrypted = Application.dmSec.UserDirectory.CLIENTUD.bEncrypted />
		</cfif>
		
		<!--- Return struct --->
		<cfset stResult.userid = "" />
		<cfset stResult.authenticated = false />
		<cfset stResult.message = "" />
		
		<!--- For backward compatability, check for userlogin and password in form. This should be removed once we're willing to not support pre 4.1 login templates --->
		<cfif structkeyexists(form,"userlogin") and structkeyexists(form,"password")>
			<!--- If password encryption is enabled, hash the password --->
			<cfif this.bEncrypted>
				<cfset form.password = hash(form.password) />
			</cfif>
			
			<!--- Find the user --->
			<cfquery datasource="#application.dsn#" name="qUser">
				select	*
				from	#application.dbowner#farUser
				where	userid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.userlogin#" />
						and password=<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.password#" />
			</cfquery>
			
			<cfset stResult.userid = form.userlogin />
		<cfelse>
			<ft:processform>
				<ft:processformObjects typename="#getLoginForm()#">
					<!--- If password encryption is enabled, hash the password --->
					<cfif this.bEncrypted>
						<cfset stProperties.password = hash(stLogin.password) />
					</cfif>
					
					<!--- Find the user --->
					<cfquery datasource="#application.dsn#" name="qUser">
						select	*
						from	#application.dbowner#farUser
						where	userid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stProperties.username#" />
								and password=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stProperties.password#" />
					</cfquery>
					
					<cfset stResult.userid = stProperties.username />
				</ft:processformObjects>
			</ft:processform>
		</cfif>
		
		<!--- If (somehow) a login was submitted, process the result --->
		<cfif isquery(qUser)>
		
	        <cfset dateTolerance = DateAdd("n","-#application.config.general.loginAttemptsTimeOut#",Now()) />
	        
	        <cfquery name="qLogAudit" datasource="#application.dsn#">
		        select		count(a.datetimeStamp) as numberOfLogin, max(a.datetimeStamp) as lastlogindate, a.username
		        from		#application.dbowner#fqAudit a
		        where		a.auditType = 'security.loginfailed'
		            		and a.datetimeStamp >= <cfqueryparam value="#createODBCDateTime(dateTolerance)#" cfsqltype="cf_sql_timestamp" />
		            		and a.username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qUser.userid#_#this.key#" />
		        group by	a.username
	        </cfquery>
					
			<!--- Set the result --->
			<cfif false and qLogAudit.numberOfLogin gte application.config.general.loginAttemptsAllowed>
				<!--- User is locked out due to high number of failed logins recently --->
				<cfset stResult.authenticated = false />
				<cfset stResult.message = "Your account has been locked due to a high number of failed logins. It will be unlocked automatically in #application.config.general.loginAttemptsTimeOut# minutes." />
			<cfelseif qUser.recordcount and qUser.userstatus eq "active">
				<!--- User successfully logged in --->
				<cfset stResult.authenticated = true />
			<cfelseif qUser.recordcount>
				<!--- User's account is disabled --->
				<cfset stResult.authenticated = false />
				<cfset stResult.message = "Your account is diabled" />
			<cfelse>
				<!--- User login or password is incorrect --->
				<cfset stResult.authenticated = false />
				<cfset stResult.message = "The username or password was incorrect">
			</cfif>
		
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="getUserGroups" access="public" output="false" returntype="array" hint="Returns the groups that the specified user is a member of">
		<cfargument name="UserID" type="string" required="true" hint="The user being queried" />
		
		<cfset var qGroups = "" />
		<cfset var aGroups = arraynew(1) />
		
		<cfquery datasource="#application.dsn#" name="qGroups">
			select	g.title
			from	(
						#application.dbowner#farUser u
						inner join
						#application.dbowner#farUser_aGroups ug
						on u.objectid=ug.parentid
					)
					inner join
					#application.dbowner#farGroup g
					on ug.data=g.objectid
			where	userid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userid#" />
		</cfquery>
		
		<cfloop query="qGroups">
			<cfset arrayappend(aGroups,title) />
		</cfloop>
		
		<cfreturn aGroups />
	</cffunction>
	
	<cffunction name="getAllGroups" access="public" output="false" returntype="array" hint="Returns all the groups that this user directory supports">
		<cfset var qGroups = "" />
		<cfset var aGroups = arraynew(1) />
		
		<cfquery datasource="#application.dsn#" name="qGroups">
			select		*
			from		#application.dbowner#farGroup
			order by	title
		</cfquery>
		
		<cfloop query="qGroups">
			<cfset arrayappend(aGroups,title) />
		</cfloop>

		<cfreturn aGroups />
	</cffunction>

	<cffunction name="getGroupUsers" access="public" output="false" returntype="array" hint="Returns all the users in a specified group">
		<cfargument name="group" type="string" required="true" hint="The group to query" />
		
		<cfset var qUsers = "" />
		
		<cfquery datasource="#application.dsn#" name="qUsers">
			select	userid
			from	(
						#application.dbowner#farUser u
						inner join
						#application.dbowner#farUser_aGroups ug
						on u.objectid=ug.parentid
					)
					inner join
					#application.dbowner#farGroup g
					on ug.data=g.objectid
			where	g.title=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.group#" />
		</cfquery>
		
		<cfreturn listtoarray(valuelist(qUsers.userid)) />
	</cffunction>
	
	<!--- =============================
	  Pre 4.1 data migration functions
	============================== --->
	
	<cffunction name="migratePermissions" access="private" output="false" returntype="struct" hint="Migrates the permission data, and returns a struct mapping the old ids to the new objectids">
		<cfset var stResult = structnew() />
		<cfset var qPermissions = "" />
		<cfset var oPermission = createObject("component", application.stcoapi["farPermission"].packagePath) />
		<cfset var stObj = structnew() />
		<cfset var perm = "" />
		
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
				<cfparam name="stObj.aRelatedtypes" default="#arraynew(1)#" />
				<cfset arrayappend(stObj.aRelatedtypes,permissiontype) />
			</cfif>
			
			<cfset oPermission.createData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
			
			<cfset stResult[permissionid] = stObj.objectid />
		</cfloop>
		
		<!--- Add new permisions - the generic permission set --->
		<cfloop list="Approve,Create,Delete,Edit,RequestApproval,CanApproveOwnContent" index="perm">
			<cfset stObj = structnew() />
			<cfset stObj.objectid = createuuid() />
			<cfset stObj.title = "Generic #perm#" />
			<cfset stObj.shortcut = "generic#perm#" />
			<cfset stObj.label = "Generic #perm#" />
			
			<cfset oPermission.createData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
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
					<cfset stObj.webskins = "display*#chr(13)##chr(10)#execute*" />
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
			<cfset stResult[stObj.title] = stObj.objectid />
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
		
		
		<cfswitch expression="#application.dbType#">
		<cfcase value="mssql">
			<!--- Update profiles --->
			<cfquery datasource="#application.dsn#">
				update	#application.dbowner#dmProfile
				set		username=username + '_' + userDirectory
				where	username not like '%[_]%'
			</cfquery>
		</cfcase>
		<cfdefaultcase>
			<!--- Update profiles --->
			<cfquery datasource="#application.dsn#">
				update	#application.dbowner#dmProfile
				set		username=username + '_' + userDirectory
				where	username not like '%_%'
			</cfquery>
		</cfdefaultcase>
		</cfswitch>

		
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
			<!--- Make sure user still exists before migrating --->
			<cfif structKeyExists(arguments.users, qUserGroups.userid)>
				<cfset stObj = oUser.getData(objectid=arguments.users[qUserGroups.userid]) />
				<cfparam name="stObj.aGroups" default="#arraynew(1)#" />
				
				<cfoutput>
					<cfset arrayappend(stObj.aGroups,arguments.groups[qUserGroups.groupid]) />
					<cfset result = result + 1 />
				</cfoutput>
				
				<cfset oUser.setData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
			</cfif>
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
			<cfparam name="stObj.aGroups" default="#arraynew(1)#" />
			
			<cfoutput>
				<cfset arrayappend(stObj.aGroups,"#externalgroupname#_#ucase(externalgroupuserdirectory)#") />
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
		<cfset var oRole = createObject("component", application.stcoapi["farRole"].packagePath) />
		<cfset var oBarnacle = createObject("component", application.stcoapi["farBarnacle"].packagePath) />
		
		<!--- Get data --->
		<cfquery datasource="#application.dsn#" name="qBarnacles">
			select		*
			from		#application.dbowner#dmPermissionBarnacle
			where		status = 1
			order by	PolicyGroupId
		</cfquery>
		
		<!--- Add data --->
		<cfoutput query="qBarnacles" group="PolicyGroupId">
			<cfif structkeyexists(arguments.roles,PolicyGroupId)>
				<cfparam name="stRole.aPermissions" default="#arraynew(1)#" />
				
				<cfoutput>
					<cfif structkeyexists(arguments.permissions,permissionid)>
						<cfif len(reference1) and isvalid("uuid",reference1)>
							<!--- If this barnacle is related to a particular item, the new barnacle structure (which refers to items in an array) has already been created --->
							<cfset oBarnacle.updateRight(role=arguments.roles[PolicyGroupId],permission=arguments.permissions[permissionid],object=reference1,right=status)>
						<cfelseif reference1 eq "PolicyGroup">
							<!--- If this barnacle isn't related to a particular item, add it as a generic permission to this role --->
							<cfset oRole.updatePermission(role=arguments.roles[PolicyGroupId],permission=arguments.permissions[permissionid],has=true) />
						</cfif>
						
						<cfset result = result + 1 />
					</cfif>
				</cfoutput>
			</cfif>
		</cfoutput>
		
		<!--- Attach the new permissions - the generic permission set --->
		<cfset oRole.updatePermission(role=arguments.roles["Contributors"],permission="genericCreate",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["Contributors"],permission="genericEdit",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["Contributors"],permission="genericRequestApproval",has=true) />
		
		<cfset oRole.updatePermission(role=arguments.roles["Publishers"],permission="genericApprove",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["Publishers"],permission="genericCanApproveOwnContent",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["Publishers"],permission="genericCreate",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["Publishers"],permission="genericDelete",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["Publishers"],permission="genericEdit",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["Publishers"],permission="genericRequestApproval",has=true) />
		
		<cfset oRole.updatePermission(role=arguments.roles["SiteAdmin"],permission="genericApprove",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SiteAdmin"],permission="genericCanApproveOwnContent",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SiteAdmin"],permission="genericCreate",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SiteAdmin"],permission="genericDelete",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SiteAdmin"],permission="genericEdit",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SiteAdmin"],permission="genericRequestApproval",has=true) />
		
		<cfset oRole.updatePermission(role=arguments.roles["SysAdmin"],permission="genericApprove",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SysAdmin"],permission="genericCanApproveOwnContent",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SysAdmin"],permission="genericCreate",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SysAdmin"],permission="genericDelete",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SysAdmin"],permission="genericEdit",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SysAdmin"],permission="genericRequestApproval",has=true) />
		
		<cfset result = result + 21 />
		
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