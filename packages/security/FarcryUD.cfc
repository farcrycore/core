<cfcomponent displayname="FarCry User Directory" hint="Provides the interface for the FarCry user directory" extends="UserDirectory" output="false"
			key="CLIENTUD" bEncrypted="true" standardHash="none">
	
	<cffunction name="init" access="public" output="true" returntype="any" hint="Does initialisation of user directory">
		
		<cfset super.init() />
		
		<cfif not structKeyExists(this,"standardHash")>
			<cfset this.standardHash = application.security.cryptlib.getDefaultHashName() />
		</cfif>
		
		<cfreturn this />
	</cffunction>

	<cffunction name="getOutputHashName" access="public" returntype="string" output="false" hint="Return the name of the hash used to encoded passwords">

		<cfif application.security.cryptlib.isHashAlgorithmSupported(application.fapi.getConfig("security","passwordHashAlgorithm","na"))>
			<cfreturn application.fapi.getConfig("security","passwordHashAlgorithm") />
		<cfelse>
			<cfreturn this.standardHash />
		</cfif>
	</cffunction>
	
	<cffunction name="passwordIsStale" access="public" output="false" returntype="boolean" hint="Returns true if the password needs to be hashed">
		<cfargument name="hashedPassword" type="string" required="true" hint="Hashed password" />
		<cfargument name="password" type="string" required="true" hint="Source password" />
		
		<cfset var hashName = getOutputHashName() />

		<cfreturn application.security.cryptlib.hashedPasswordIsStale(hashedPassword=arguments.hashedPassword,password=arguments.password,hashname=hashName) />
	</cffunction>

	<cffunction name="queryUserPassword" access="private" output="false" returntype="query" hint="Return a query of farUser rows that match the provided credentials">
		<cfargument name="username" type="string" required="true" />
		<cfargument name="password" type="string" required="true" />
		
		<cfset var qUser = "" />
		<cfset var authenticatedObjectId = "" />
		<cfset var hashName = getOutputHashName() />
		
		<!--- Find the user --->
		<cfquery datasource="#application.dsn#" name="qUser">
			select	objectid,userid,password,userstatus,failedLogins
			from	#application.dbowner#farUser
			where	userid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.username)#" />
		</cfquery>
		
		<!--- Try to match the entered password against the users in the DB --->
		<cfloop query="qUser">
			<cfif application.security.cryptlib.passwordMatchesHash(password=arguments.password,hashedPassword=qUser.password)>
				<cfset authenticatedObjectId = qUser.objectid />
				<cfbreak />
			</cfif>
		</cfloop>
		
		<cfif Len(authenticatedObjectId)>
			<!--- Return the row with the password match --->
			<cfquery dbtype="query" name="qUser">
				select *
				from qUser
				where objectid = '#authenticatedObjectId#'
			</cfquery>

			<!--- Does the hashed password need to be updated? --->
			<cfif passwordIsStale(hashedPassword=qUser.password,password=arguments.password)>
				<cfquery datasource="#application.dsn#">
					update	#application.dbowner#farUser
					set		password=<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.security.cryptlib.encodePassword(password=arguments.password,hashname=hashName)#" />
					where	objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#authenticatedObjectId#" />
				</cfquery>
			</cfif>
		<cfelse>
			<!--- Delete all rows from the query --->
			<cfquery dbtype="query" name="qUser">
				select *
				from qUser
				where 0 = 1
			</cfquery>
		</cfif>
		
		<cfreturn qUser />
	</cffunction>
	
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
		<cfset var failedLogins = arraynew(1) />
		<cfset var i = 0 />
		<cfset var failureCount = 0 />
		<cfset var dateTolerance = 0 />

		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

		<!--- For backward compatability, check for userlogin and password in form. This should be removed once we're willing to not support pre 4.1 login templates --->
		<cfif structkeyexists(form,"userlogin") and structkeyexists(form,"password")>
			<cfset qUser = queryUserPassword(form.userlogin,form.password) />
			<cfset stResult.userid = trim(form.userlogin) />
		<cfelse>
			<ft:processform>
				<ft:processformObjects typename="#getLoginForm()#">
					<cfset qUser = queryUserPassword(stProperties.username,stProperties.password) />
					<cfset stResult.userid = trim(stProperties.username) />
					<!--- discard form object from session --->
					<ft:break>
				</ft:processformObjects>
			</ft:processform>
		</cfif>

		<!--- If (somehow) a login was submitted, process the result --->
		<cfif structKeyExists(stResult, "userid") AND len(stResult.userid)>
			
			<!--- Return struct --->
			<cfset stResult.authenticated = false />
			<cfset stResult.message = "" />
			<cfset stResult.UD = "CLIENTUD" />
			
			<!--- Count failed logins --->
	        <cfset dateTolerance = DateAdd("n","-#application.fapi.getConfig("general","loginAttemptsTimeOut")#",Now()) />
	        <cfif isJSON(qUser.failedLogins)>
		        <cfset failedLogins = deserializeJSON(qUser.failedLogins) />
	        </cfif>
	        <cfloop from="1" to="#arraylen(failedLogins)#" index="i">
	        	<cfif failedLogins[i].timestamp gte dateTolerance>
	        		<cfset failureCount = failureCount + 1 />
	        	</cfif>
	        </cfloop>
			
			<!--- Set the result --->
			<cfif failureCount gte application.fapi.getConfig("general","loginAttemptsAllowed")>
				<!--- User is locked out due to high number of failed logins recently --->
				<cfset stResult.authenticated = false />
				<cfset stResult.message = "Your account has been locked due to a high number of failed logins. It will be unlocked automatically in #application.fapi.getConfig("general","loginAttemptsTimeOut")# minutes." />
				<cfset application.fapi.getContentType("farUser").addLoginFailure(objectid=qUser.objectid,reason="Locked account due to failed logins") />
			<cfelseif qUser.recordcount and qUser.userstatus eq "active">
				<!--- User successfully logged in --->
				<cfset stResult.authenticated = true />

				<cfif qUser.failedLogins neq "[]">
					<cfset application.fapi.getContentType("farUser").resetLoginFailures(objectid=qUser.objectid) />
				</cfif>
			<cfelseif qUser.recordcount>
				<!--- User's account is disabled --->
				<cfset stResult.authenticated = false />
				<cfset stResult.message = "Your account is disabled" />
			<cfelse>
				<!--- User login or password is incorrect --->
				<cfset stResult.authenticated = false />
				<cfset stResult.message = "The username or password was incorrect">
				<cfset application.fapi.getContentType("farUser").addLoginFailure(userid=stResult.userid,reason="Incorrect password") />
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
			from	
						#application.dbowner#farUser u
						inner join
						#application.dbowner#farUser_aGroups ug
						on u.objectid=ug.parentid
					
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
					and u.userstatus=<cfqueryparam cfsqltype="cf_sql_varchar" value="active" />
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
		
		<cfswitch expression="#application.dbtype#">
			<cfcase value="mssql">
				<cfquery datasource="#application.dsn#">
					insert into #application.dbowner#farPermission(createdby,datetimecreated,datetimelastupdated,label,lastupdatedby,locked,lockedBy,objectid,ownedby,shortcut,title)
					(select '' as createdBy, getdate() as datetimecreated, getdate() as datetimelastupdated, permissionname as label, 'upgrade' as lastupdatedby, 0 as locked, '' as lockedBy, left(newid(),23)+right(newid(),12) as objectid, '' as ownedBy, permissionname as shortcut, permissionname as title
					from #application.dbowner#dmPermission)
				</cfquery>
				<cfquery datasource="#application.dsn#">
					insert into #application.dbowner#farPermission_aRelatedTypes(parentid,data,typename,seq)
					(select np.objectid as parentid,op.permissiontype as data,'' as typename,1 as seq
					from #application.dbowner#farPermission np join #application.dbowner#dmPermission op on np.shortcut=op.permissionname
					where op.permissiontype<>'PolicyGroup')
				</cfquery>
				<cfquery datasource="#application.dsn#">
					insert into #application.dbowner#refObjects(objectid,typename)
					(select objectid,'farPermission' as typename
					from #application.dbowner#farPermission)
				</cfquery>
			</cfcase>
			
			<cfdefaultcase>
				<!--- Add data --->
				<cfloop query="qPermissions">
					<cfset stObj = structnew() />
					<cfset stObj.objectid = application.fc.utils.createJavaUUID() />
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
			</cfdefaultcase>
			
		</cfswitch>
		
		<!--- Add new permisions - the generic permission set --->
		<cfloop list="Approve,Create,Delete,Edit,RequestApproval,CanApproveOwnContent" index="perm">
			<cfset stObj = structnew() />
			<cfset stObj.objectid = application.fc.utils.createJavaUUID() />
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
		
		<cfswitch expression="#application.dbtype#">
			<cfcase value="mssql">
				<cfquery datasource="#application.dsn#">
					insert into #application.dbowner#farRole(createdBy,datetimecreated,datetimelastupdated,isdefault,label,lastupdatedby,locked,lockedBy,objectid,ownedby,title,webskins)
					(select 'upgrade' as createdBy, getdate() as datetimecreated, getdate() as datetimelastupdated, 
						case policygroupname when 'Anonymous' then 1 else 0 end as isdefault, policygroupname as label, 
						'upgrade' as lastupdatedby, 0 as locked, '' as lockedBy, left(newid(),23)+right(newid(),12) as objectid,
						'' as ownedby, policygroupname as title, case when policygroupname='Anonymous' then 'display*' + char(13) + char(10) + 'execute*' when policygroupname in ('Contributors','Publishers','SiteAdmin','SysAdmin') then '*' else '' end as webskins
					from #application.dbowner#dmPolicyGroup)
				</cfquery>
				
				<cfquery datasource="#application.dsn#" name="qPolicyGroups">
					select	objectid,title,policygroupid
					from	#application.dbowner#farRole r
							join
							#application.dbowner#dmPolicyGroup pg
							on r.title=pg.policygroupname
				</cfquery>
				<cfloop query="qPolicyGroups">
					<cfset stResult[qPolicyGroups.policygroupid] = qPolicyGroups.objectid />
					<cfset stResult[qPolicyGroups.title] = qPolicyGroups.objectid />
				</cfloop>
			</cfcase>
			
			<cfdefaultcase>
				<!--- Get data --->
				<cfquery datasource="#application.dsn#" name="qPolicyGroups">
					select	*
					from	#application.dbowner#dmPolicyGroup
				</cfquery>
				
				<!--- Add data --->
				<cfloop query="qPolicyGroups">
					<cfset stObj = structnew() />
					<cfset stObj.objectid = application.fc.utils.createJavaUUID() />
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
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="migrateGroups" access="private" output="false" returntype="struct" hint="Migrates the user directory groups and returns a struct mapping the old ids to the new objectids">
		<cfset var stResult = structnew() />
		<cfset var qGroups = "" />
		<cfset var oGroup = createObject("component", application.stcoapi["farGroup"].packagePath) />
		<cfset var stObj = structnew() />
		
		<cfswitch expression="#application.dbtype#">
			<cfcase value="mssql">
				<cfquery datasource="#application.dsn#">
					insert into farGroup(createdby,datetimecreated,datetimelastupdated,label,lastupdatedby,locked,lockedBy,objectid,ownedby,title)
					(select 'upgrade' as createdBy, getdate() as datetimecreated, getdate() as datetimelastupdated,groupname as label,
						'upgrade' as lastupdatedby,0 as locked,'' as lockedBy,left(newid(),23)+right(newid(),12) as objectid,
						'' as ownedby,groupname as title
					from #application.dbowner#dmGroup)
				</cfquery>
				<cfquery datasource="#application.dsn#">
					insert into #application.dbowner#refObjects(objectid,typename)
					(select objectid,'farGroup' as typename
					from #application.dbowner#farGroup)
				</cfquery>
				
				<cfquery datasource="#application.dsn#" name="qGroups">
					select	objectid,title,groupid
					from	#application.dbowner#farGroup ng
							join
							#application.dbowner#dmGroup og
							on ng.title=og.groupname
				</cfquery>
				<cfloop query="qGroups">
					<cfset stResult[qGroups.groupid] = qGroups.objectid />
					<cfset stResult[qGroups.title] = qGroups.objectid />
				</cfloop>
			</cfcase>
			
			<cfdefaultcase>
				<!--- Get data --->
				<cfquery datasource="#application.dsn#" name="qGroups">
					select	*
					from	#application.dbowner#dmGroup
				</cfquery>
				
				<!--- Add data --->
				<cfloop query="qGroups">
					<cfset stObj = structnew() />
					<cfset stObj.objectid = application.fc.utils.createJavaUUID() />
					<cfset stObj.title = groupname />
					<cfset stObj.label = groupname />
					
					<cfset oGroup.createData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
					
					<cfset stResult[groupid] = stObj.objectid />
					<cfset stResult[groupname] = stObj.objectid />
				</cfloop>		
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="migrateUsers" access="private" output="false" returntype="struct" hint="Migrates the user directory users and returns a struct mapping the old ids to the new objectids">
		<cfset var stResult = structnew() />
		<cfset var qUsers = "" />
		<cfset var oUser = createObject("component", application.stcoapi["farUser"].packagePath) />
		<cfset var stObj = structnew() />
		<cfset var typename = "" />
		<cfset var property = "" />
		<cfset var oAlterType = createObject("component", "farcry.core.packages.farcry.alterType") />
		
		<cfswitch expression="#application.dbtype#">
			<cfcase value="mssql">
				<cfquery datasource="#application.dsn#">
					insert into #application.dbowner#farUser(createdby,datetimecreated,datetimelastupdated,label,lastupdatedby,lGroups,locked,lockedBy,objectid,ownedby,password,userid,userstatus)
					(select 'upgrade' as createdby,getdate() as datetimecreated,getdate() as datetimelastupdated,userlogin as label,
						'upgrade' as lastupdatedby, '' as lGroups,0 as locked,'' as lockedBy,left(newid(),23)+right(newid(),12) as objectid,
						'' as ownedby, userpassword as password,userlogin as userid,case userstatus when 4 then 'active' else 'inactive' end as userstatus
					from #application.dbowner#dmUser)
				</cfquery>
				<cfquery datasource="#application.dsn#">
					insert into #application.dbowner#refObjects(objectid,typename)
					(select objectid,'farUser' as typename
					from #application.dbowner#farUser)
				</cfquery>
				
				<cfquery datasource="#application.dsn#" name="qUsers">
					select userid,objectid from farUser
				</cfquery>
				<cfloop query="qUsers">
					<cfset stResult[qUsers.userid] = qUsers.objectid />
				</cfloop>
			</cfcase>
			
			<cfdefaultcase>
				<!--- Get data --->
				<cfquery datasource="#application.dsn#" name="qUsers">
					select	*
					from	#application.dbowner#dmUser
				</cfquery>
				
				<!--- Add data --->
				<cfloop query="qUsers">
					<cfset stObj = structnew() />
					<cfset stObj.objectid = application.fc.utils.createJavaUUID() />
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
			</cfdefaultcase>
		</cfswitch>

		<cfloop collection="#application.types#" item="typename">
			<cfloop list="createdby,lastupdatedby,lockedby" index="property">
				<!--- Update ownedby --->
				<cfif oAlterType.isCFCDeployed(typename=typename) and not find("_",typename)>

					<cfswitch expression="#application.dbType#">
						<cfcase value="mysql,mysql5">
							<!--- Update profiles --->
							<cfquery datasource="#application.dsn#">
							update	#application.dbowner##typename# t inner join 
									#application.dbowner#dmProfile
									on t.#property#=dmProfile.username
							set		t.#property# = concat(dmProfile.username, '_', dmProfile.userDirectory)							
							</cfquery>
						</cfcase>
						<cfcase value="ora">
							<!--- Update profiles --->
							<cfquery datasource="#application.dsn#">
								UPDATE #typename# t
								SET	t.#property# = (
									SELECT u.username || '_' || u.userDirectory
									FROM dmProfile u
									WHERE to_char(t.#property#) = to_char(u.username)
								)
								WHERE EXISTS (
									SELECT u.username || '_' || u.userDirectory
									FROM dmProfile u
									WHERE to_char(t.#property#) = to_char(u.username)
								)
							</cfquery>
						</cfcase>
						<cfdefaultcase>
							<!--- Update profiles --->
							<cfquery datasource="#application.dsn#">
								update	type
								set		#property# = dmProfile.username + '_' + dmProfile.userDirectory
								from	#application.dbowner##typename# type
										inner join 
										#application.dbowner#dmProfile
										on type.#property#=dmProfile.username
							</cfquery>	
						</cfdefaultcase>
					</cfswitch>
										
				</cfif>
				
			</cfloop>
		</cfloop>	
		
		<cfswitch expression="#application.dbType#">
			<cfcase value="mysql,mysql5">
				<!--- Update profiles --->
				<cfquery datasource="#application.dsn#">
					UPDATE	#application.dbowner#dmProfile
					SET		userName = CONCAT(userName, '_', userDirectory)
					WHERE	userName NOT LIKE <cfqueryparam value="%\_%" cfsqltype="cf_sql_varchar" />
				</cfquery>
			</cfcase>
			<cfcase value="mssql,mssql2005">
				<!--- Update profiles --->
				<cfquery datasource="#application.dsn#">
					update	#application.dbowner#dmProfile
					set		username=username + '_' + userDirectory
					where	username not like '%[_]%'
				</cfquery>
			</cfcase>
			<cfcase value="ora">
				<!--- Update profiles --->
				<cfquery datasource="#application.dsn#">
					UPDATE	#application.dbowner#dmProfile
					SET		username=username || '_' || userDirectory
					WHERE	username NOT LIKE '%!_%' ESCAPE '!'
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
		
		<cfswitch expression="#application.dbtype#">
			<cfcase value="mssql">
				<cfquery datasource="#application.dsn#">
					insert into farUser_aGroups(parentid,data,typename,seq)
					(select fu.objectid as parentid,fg.objectid as data,'farGroup' as typename,0 as seq from farUser fu
					join dmUser du on fu.userid=du.userLogin
					join dmUserToGroup dug on du.userid=dug.userid
					join dmGroup dg on dug.groupid=dg.groupid
					join farGroup fg on dg.groupName=fg.title)
				</cfquery>
				
				<cfset result = qUserGroups.recordcount />
			</cfcase>
			
			<cfdefaultcase>
				<!--- Add data --->
				<cfoutput query="qUserGroups" group="userid">
					<!--- Make sure user still exists before migrating --->
					<cfif structKeyExists(arguments.users, qUserGroups.userid)>
						<cfset stObj = oUser.getData(objectid=arguments.users[qUserGroups.userid]) />
						<cfparam name="stObj.aGroups" default="#arraynew(1)#" />
						
						<cfoutput>
							<!--- Make sure group still exists before migrating --->
							<cfif structKeyExists(arguments.groups, qUserGroups.groupid)>
								<cfset arrayappend(stObj.aGroups,arguments.groups[qUserGroups.groupid]) />
								<cfset result = result + 1 />
							</cfif>
						</cfoutput>
						
						<cfset oUser.setData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
					</cfif>
				</cfoutput>
			</cfdefaultcase>
		</cfswitch>
		
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
			<cfif structkeyexists(arguments.roles,PolicyGroupId)>
				<cfset stObj = oRole.getData(objectid=arguments.roles[PolicyGroupId]) />
				<cfparam name="stObj.aGroups" default="#arraynew(1)#" />
				
				<cfoutput>
					<cfset arrayappend(stObj.aGroups,"#externalgroupname#_#ucase(externalgroupuserdirectory)#") />
					<cfset result = result + 1 />
				</cfoutput>
				
				<cfset oRole.setData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
			</cfif>
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
		
		<cfswitch expression="#application.dbtype#">
			<cfcase value="mssql">
				<cfquery datasource="#application.dsn#">
					insert into #application.dbowner#farBarnacle(barnaclevalue,createdby,datetimecreated,datetimelastupdated,label,lastupdatedby,locked,lockedby,objectid,objecttype,ownedby,permissionid,referenceid,roleid)
					(select ob.status as barnaclevalue,'upgrade' as createdby,getdate() as datetimecreated,getdate() as datetimelastupdated,
						'' as label,'upgrade' as lastupdatedby,0 as locked,'' as lockedBy,
						left(newid(),23)+right(newid(),12) as objectid,ref.typename as objecttype,
						'' as ownedby,np.objectid as permissionid,reference1 as referenceid,nr.objectid as roleid
					from #application.dbowner#dmPermissionBarnacle ob
					join #application.dbowner#refObjects ref on ob.reference1=ref.objectid
					join #application.dbowner#dmPermission op on ob.permissionid=op.permissionid
					join #application.dbowner#farPermission np on op.permissionname=np.title
					join #application.dbowner#dmPolicyGroup olr on ob.policygroupid=olr.policygroupid
					join #application.dbowner#farRole nr on olr.policygroupname=nr.title
					where reference1 like '________-____-____-________________' and status=1)
				</cfquery>
				<cfquery datasource="#application.dsn#">
					insert into #application.dbowner#refObjects(objectid,typename)
					(select objectid,'farBarnacle' as typename
					from #application.dbowner#farBarnacle)
				</cfquery>
				<cfquery datasource="#application.dsn#" name="qBarnacles">
					select * from #application.dbowner#dmPermissionBarnacle where reference1 like '________-____-____-________________' and status=1
				</cfquery>
				<cfset result = result + qBarnacles.recordcount />
				
				<cfquery datasource="#application.dsn#">
					ALTER TABLE dbo.farRole_aPermissions ADD [tempseq] int NOT NULL IDENTITY (1, 1)
				</cfquery>
				<cfquery datasource="#application.dsn#">
					insert into farRole_aPermissions(data,parentid,seq,typename)
					(select np.objectid as data, nr.objectid as parentid, 0 as seq, 'farPermission' as typename
					from dmPermissionBarnacle ob
					join dmPermission op on ob.permissionid=op.permissionid
					join farPermission np on op.permissionname=np.title
					join dmPolicyGroup olr on ob.policygroupid=olr.policygroupid
					join farRole nr on olr.policygroupname=nr.title
					where reference1='PolicyGroup' and status=1)
				</cfquery>
				<cfquery datasource="#application.dsn#">
					update farRole_aPermissions set seq=[tempseq]
				</cfquery>
				<cfquery datasource="#application.dsn#">
					ALTER TABLE farRole_aPermissions DROP COLUMN [tempseq]
				</cfquery>
				<cfquery datasource="#application.dsn#" name="qBarnacles">
					select * from #application.dbowner#dmPermissionBarnacle where reference1 like 'PolicyGroup' and status=1
				</cfquery>
				<cfset result = result + qBarnacles.recordcount />
			</cfcase>
			
			<cfdefaultcase>
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
			</cfdefaultcase>
		</cfswitch>
		
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
