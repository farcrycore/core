<cfcomponent displayName="Security Scope" hint="Encapsulates the generic higher-level security functions and variables" output="false" scopelocation="application.security">

	<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
	
	
	<cffunction name="init" access="public" output="false" returntype="any" hint="Initialises and returns the security scope component">
		<cfset var permission = "" /><!--- Used in deprecated code --->
		<cfset var stPermission = structnew() /><!--- Used in deprecated code --->
		<cfset var i = 0 /><!--- Used in deprecated code --->
		
		<cfset initCache() />
		
		<cfreturn this />
	</cffunction>

	<cffunction name="initCache" access="public" output="false" returntype="void" hint="Initialises the security cache">
		<cfset var comp = "" />
		<cfset var ud = "" />
		
		<!--- Cache --->
		<cfset this.stPermissions = structNew() />
		<cfset this.cache = structnew() />
		<cfset this.cache.roles = structnew() />
		<cfset this.cache.permissionlookup = structnew() />
		<cfset this.cache.rolelookup = structnew() />
		
		<!--- Factory --->
		<cfset this.factory.role = createObject("component", application.factory.oUtils.getPath("types","farRole")) />
		<cfset this.factory.permission = createObject("component", application.factory.oUtils.getPath("types","farPermission")) />
		<cfset this.factory.barnacle = createObject("component", application.factory.oUtils.getPath("types","farBarnacle")) />
		
		<cfset this.cryptlib = createObject("component", application.factory.oUtils.getPath("security","cryptLib")).init() />
		
		<!--- User directories --->
		<cfset this.userdirectories = structnew() />
		<cfset this.userdirectoryorder = "" />
		
		<cfloop list="#application.factory.oUtils.getComponents('security')#" index="comp">
			<cfif comp neq "UserDirectory" and application.factory.oUtils.extends(application.factory.oUtils.getPath("security",comp),"farcry.core.packages.security.UserDirectory")>
				<cfset ud = createobject("component",application.factory.oUtils.getPath("security",comp)).init() />
				<cfset this.userdirectories[ud.key] = ud />
				<cfset this.userdirectoryorder = listappend(this.userdirectoryorder,ud.key) />
			</cfif>
		</cfloop>
		
		<cfset this.cache.defaultroles = this.factory.role.getDefaultRoles() />
	</cffunction>

	<cffunction name="onRequestStart" access="public" output="false" returntype="void" hint="This function should be executed on page request start">

	</cffunction>


	<!--- Current user queries --->
	<cffunction name="getCurrentUserID" access="public" output="false" returntype="string" hint="Returns the id of the current user" bDocument="true">
		<cfif isdefined("session.security.userid")>
			<cfreturn session.security.userid />
		<cfelse>
			<cfreturn "" />
		</cfif>
	</cffunction>


	<!--- Current user queries --->
	<cffunction name="isLoggedIn" access="public" output="false" returntype="boolean" hint="Returns true if a user has logged in." bDocument="true">
		<cfif len(getCurrentUserID())>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="checkPermission" access="public" output="false" returntype="boolean" hint="Returns true if a user has the specified permission" bDocument="true">
		<cfargument name="permission" type="string" required="false" default="" hint="The permission to check" />
		<cfargument name="object" type="string" required="false" default="" hint="If specified, will check barnacle" />
		<cfargument name="role" type="string" required="false" default="" hint="List of roles to check" />
		<cfargument name="type" type="string" required="false" default="" hint="The type for the webskin to check" />
		<cfargument name="webskin" type="string" required="false" default="" hint="The webskin or permission set to check" />
				
		<cfset var hashKey = "" />
		<cfset var result = -1 />
		<cfset var oType = "" />
		<cfset var navID = "" />
		<cfset var bPermitted = 0 />
		<cfset var barnacleID = "">
		<cfset var iRole = "">
		<cfset var bRight = "">
		<cfset var genericPermissionID = "">
		
		<!--- If the role was left empty, use current user's roles --->
		<cfif not len(arguments.role)>
			<cfset arguments.role = getCurrentRoles() />
		</cfif>
		
			
		<!--- RETURN THE CACHE IF ALREADY PROCESSED. --->
		<cfset hashKey = hash("#arguments.permission#-#arguments.object#-#arguments.role#-#arguments.type#-#arguments.webskin#") />
		<cfif structKeyExists(this.stPermissions, "#hashKey#")>
			<cfreturn this.stPermissions[hashKey] />
		</cfif>
		
		<!--------------------------------------------------------------------------------------------------- 
		IF WE MAKE IT TO HERE, WE NEED TO DETERMINE THE PERMISSION AND THEN STORE IT IN THE APPLICATION CACHE.
		 --------------------------------------------------------------------------------------------------->
		
		<cfif len(arguments.type) and len(arguments.webskin)>
		
			<cfset result = this.factory.role.checkWebskin(role=arguments.role,type=arguments.type,webskin=arguments.webskin) />
			
		<cfelseif NOT len(arguments.object) AND len(arguments.type) and len(arguments.permission)>
			
			<cfset genericPermissionID = application.security.factory.permission.getID(name="generic#arguments.permission#")>
			
			<cfif len(genericPermissionID)>
				
				<cfset barnacleID = application.fapi.getContentType("farCoapi").getCoapiObjectID(arguments.type)>
				
				<cfloop list="#arguments.role#" index="iRole">
					<cfset bRight = this.factory.barnacle.getRight(role="#iRole#", permission="#genericPermissionID#", object="#barnacleID#", objecttype="farCoapi")>
					
					<cfif bRight eq 0>
						<cfset bRight = this.factory.role.getRight(role="#iRole#", permission="#genericPermissionID#") />
						
						<cfif bRight eq 1>
							<cfset result = true />
							<cfbreak>
						<cfelseif result eq -1>
							<cfset result = false />
						</cfif>
					<cfelseif bRight EQ 1>
						<cfset result = true />
						<cfbreak>
					<cfelseif bRight eq -1 and result eq -1>
						<cfset result = false />
					</cfif>
				</cfloop>
				
			<cfelse>
			
				<!--- This should only happen for checks to object permissions that don't have corresponding type permissions --->
				<cfset result = 1 />
				
			</cfif>
		
		<cfelseif len(arguments.permission)>
		
			<!--- If the permission was specified by name, retrieve the objectid --->
			<cfif not isvalid("uuid",arguments.permission)>
				<cfset arguments.permission = this.factory.permission.getID(arguments.permission) />
				<cfif not len(arguments.permission)>
					<cfset result = 0 />
				</cfif>
			</cfif>
			
			<cfif result LT 0>
				<!--- If an object was provided check the barnacle for that object, otherwise check the basic permission --->
				<cfif len(arguments.object)>
				
					
					<cfif len(arguments.object) AND not len(arguments.type)>
						<cfset arguments.type = application.fapi.findType(arguments.object) />
					</cfif>
					
					<cfif arguments.type EQ "dmNavigation">
						<cfset result = 1 /><!--- permission check on dmNavigation is handled below. --->
					<cfelse>
						<cfset result = this.factory.barnacle.checkPermission(object=arguments.object, objecttype="#arguments.type#", permission=arguments.permission,role=arguments.role) />
					</cfif>
					
					<!--- Also check the permission on the parent nav node --->
					<cfif len(arguments.type) AND structKeyExists(application.stCOAPI, arguments.type) AND structKeyExists(application.stCOAPI[arguments.type], "bUseInTree") AND application.stCOAPI[arguments.type].bUseInTree>
						<cfset oType = application.fapi.getContentType(arguments.type) />
						<cfset navID = oType.getNavID(objectid=arguments.object,typename=arguments.type) />	
						<cfset result = result and (not len(navID) or this.factory.barnacle.checkPermission(object=navID,permission=arguments.permission,role=arguments.role)) />
					</cfif>
					
				<cfelse>
					<cfset result = this.factory.role.getRight(role=arguments.role,permission=arguments.permission) />
				</cfif>
			</cfif>
		<cfelse>
		
			<cfthrow message="Either a webskin or a permission are required for checkPermission" />
			
		</cfif>
		
		<cfset this.stPermissions[hashKey] = result />
		
		<cfreturn this.stPermissions[hashKey] />
		
	</cffunction>

	<cffunction name="getCurrentRoles" access="public" output="false" returntype="string" hint="Returns the roles of the current logged in user" bDocument="true">
		<cfif not isdefined("this.cache.defaultroles")>
			<cfset this.cache.defaultroles = this.factory.role.getDefaultRoles() />
		</cfif>
		<cfif isdefined("session.security.roles")>
			<cfreturn application.factory.oUtils.listMerge(this.cache.defaultroles,session.security.roles) />
		<cfelse>
			<cfreturn this.cache.defaultroles />
		</cfif>
	</cffunction>

	<cffunction name="getCurrentUD" access="public" output="false" returntype="string" hint="Returns the UD of the current user" bDocument="true">
		<cfif isdefined("session.security.userid")>
			<cfreturn listlast(session.security.userid,"_") />
		<cfelse>
			<cfreturn "" />
		</cfif>		
	</cffunction>
	
	<cffunction name="hasRole" returntype="boolean" output="false" access="public" hint="Returns true if the current user has the specified role">
		<cfargument name="role" type="string" required="false" default="" hint="Roles to check" />
		
		<cfif isvalid("uuid",arguments.role)>
			<cfreturn listcontainsnocase(getCurrentRoles(),arguments.role) />
		<cfelse>
			<cfreturn listcontainsnocase(getCurrentRoles(),this.factory.role.getID(arguments.role)) />
		</cfif>
	</cffunction>
	

	<!--- User Directory functions --->
	<cffunction name="getAllUD" access="public" output="false" returntype="string" hint="Returns a list of the user directories this application supports">
		<cfset var lUD = "" />
		<cfset var thisUD = "" />
		
		<cfloop list="#this.userdirectoryorder#" index="thisud">
			<cfif this.userdirectories[thisud].isEnabled()>
				<cfset lUD = listappend(lUD,thisud) />
			</cfif>
		</cfloop>
		
		<cfreturn lUD />
	</cffunction>
	
	<cffunction name="getDefaultUD" access="public" output="false" returntype="string" hint="Returns the default user directory for this application">
		<cfset var result = "" />
		
		<cfif structKeyExists(url, "ud")>
			<cfset result = url.ud />
		<cfelse>			
			<cfif len(application.fapi.getConfig("security","defaultUserDirectory",""))>
				<cfset result = application.fapi.getConfig("security","defaultUserDirectory") />
			<cfelseif len(application.fapi.getConfig("general","defaultUserDirectory",""))>
				<cfset result = application.fapi.getConfig("general","defaultUserDirectory") />
			<cfelse>
				<cfset result = listfirst(getAllUD()) />
			</cfif>
		</cfif>

		<cfreturn result />
		
	</cffunction>
	
	<cffunction name="getGroupUsers" access="public" returntype="array" description="Returns an array of the members of the specified groups" output="false" bDocument="true">
		<cfargument name="groups" type="any" required="true" hint="The list or array of groups" />
		
		<cfset var i = 0 />
		<cfset var j = 0 />
		<cfset var aResult = arraynew(1) />
		<cfset var ud = "" />
		<cfset var group = "" />
		<cfset var aUsers = arraynew(1) />
		<cfset var user = "" />
		
		<cfif not isarray(arguments.groups)>
			<cfset arguments.groups = listtoarray(arguments.groups) />
		</cfif>
		
		<cfif arraylen(arguments.groups)>
			<cfloop from="1" to="#arraylen(arguments.groups)#" index="i">
				<cfset ud = listlast(arguments.groups[i],"_") />
				<cfset group = listfirst(arguments.groups[i],"_") />
				<cfif structkeyexists(this.userdirectories,ud)>
					<cfset aUsers = this.userdirectories[ud].getGroupUsers(group=group) />
					<cfif arraylen(aUsers)>
						<cfloop from="1" to="#arraylen(aUsers)#" index="j">
							<cfset arrayappend(aResult,"#aUsers[j]#_#ud#") />
						</cfloop>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn aResult />
	</cffunction>
	
	<cffunction name="getLoginForm" access="public" output="false" returntype="string" hint="Returns the name of the login form component for the specified user directory">
		<cfargument name="ud" type="string" required="true" hint="The user directory to query" />
		
		<cfreturn this.userdirectories[arguments.ud].getLoginForm() />
	</cffunction>

	<cffunction name="processLogin" access="public" output="false" returntype="struct" hint="Attempts to authenticate a login and if unsuccessful, sets up any subsequent login forms for the page. Returns a struct containing all the nessesary information for a user directories login form.">

		<!--- Attempt to Authenticate the current form post if one has been submitted. --->
		<cfset var stResult = authenticate() />
		
		<!--- Setup Default return structure --->
		<cfparam name="stResult.authenticated" default="false" /><!--- Did the user successfully login --->
		<cfparam name="stResult.message" default="" /><!--- Any message that the user directory may have returned --->
		<cfparam name="stResult.loginReturnURL" default="#session.loginReturnURL#" /><!--- The return url after a successful login --->
		
		<!--- WHICH USERDIRECTORY SHOULD WE BE RENDERING THE FORM FOR --->
		<cfset stResult.ud = getDefaultUD() />
		
		<!--- Allow for custom message --->
		<cfif structKeyExists(session.fc, "loginMessage") AND len(session.fc.loginMessage) AND NOT len(stResult.message)>
			<cfset stResult.message = session.fc.loginMessage />
			<cfset structDelete(session.fc, "loginMessage") />
		</cfif>
		
		<!--- DETERMINE THE FORM TYPENAME FOR THE CURRENT USER DIRECTORY SELECTED ABOVE --->
		<cfset stResult.loginTypename = application.security.getLoginForm(stResult.ud) />
		<cfset stResult.loginWebskin = "displayLogin" /><!--- Default login webskin to displayLogin --->
		
		<cfif findNoCase(application.url.webtop, stResult.loginReturnURL)>
			<!--- LOGGING INTO THE WEBTOP --->
			<cfif application.fapi.hasWebskin(stResult.loginTypename,"displayPageLoginWebtop")>
				<cfset stResult.loginWebskin = "displayPageLoginWebtop" />
			</cfif>
		<cfelse>
			<!--- LOGGING INTO THE PROJECTS SITE --->
			<cfif application.fapi.hasWebskin(stResult.loginTypename,"displayPageLoginProject")>
				<cfset stResult.loginWebskin = "displayPageLoginProject" />
			</cfif>
		</cfif>	
		
		<!--- IF WE ARE NOT AUTHENTICATED --->
		<cfif not stResult.authenticated>

			<!--- LOOK FOR ANY FRAMEWORK SPECIFIC ERROR LOGIC --->
			<cfif structKeyExists(url, "error") and not len(stResult.message)>
				<cfif url.error eq "draft">
					<!--- TODO: i18n --->
					<cfset stResult.authenticated = false />
				    <cfset stResult.message = "This page is in draft. You are required to login." />
				</cfif>
				<cfif url.error eq "restricted">
					<!--- TODO: i18n --->
					<cfset stResult.authenticated = false />
				    <cfset stResult.message = "You have attempted to access a restricted area of the site that you do not have permission to view. You are required to login." />
				</cfif>
			</cfif>
			
			<!--- ARE WE LOGGING IN BECAUSE WE JUST LOGGED OUT? --->
			<cfif session.loginReturnURL contains "logout=1">
				<cfset application.security.logout() />
				<cfset stResult.authenticated = false />
			    <cfset stResult.message = "You have successfully logged out." />
			</cfif>		
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	

	<cffunction name="authenticate" access="public" output="false" returntype="struct" hint="Attempts to authenticate a user using each directory, and returns true if successful">
		<cfset var ud = "" />
		<cfset var stResult = structnew() />
		<cfset var udlist = structsort(this.userdirectories,"numeric","asc","seq") />
		
		<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />
		
		<cfif isArray(udlist)>
			<cfset udlist = arrayToList(udlist) />
		</cfif>
		
		<cfloop list="#udlist#" index="ud">
			<!--- Authenticate user --->
			<cfset stResult = this.userdirectories[ud].authenticate(argumentCollection="#arguments#") />
			
			<cfif structkeyexists(stResult,"authenticated")>
				<!--- This allows your userdirectory check multiple user directories and pass back the successfull one. --->
				<cfparam name="stResult.UD" default="#ud#" />
				
				<cfif not stResult.authenticated>
					<farcry:logevent type="security" event="loginfailed" userid="#stResult.userid#_#stResult.UD#" notes="#stResult.message#" />
					<cfbreak />
				</cfif>
				
				<!--- SUCCESS - log in user --->
				<cfset login(userid=stResult.userid,ud=stResult.UD) />
				
				<!--- Return 'success' --->
				<cfbreak />
			</cfif>
		</cfloop>
		
		<!--- Returning an empty struct indicates that no authentication attempt was detected --->
		<cfreturn stResult />
	</cffunction>

	<cffunction name="login" access="public" returntype="void" description="Logs in the specified user" output="false">
		<cfargument name="userid" type="string" required="true" hint="The UD specific user id" />
		<cfargument name="ud" type="string" required="true" hint="The user directory" />
		
		<cfset var groups = "" />
		<cfset var aUserGroups = arraynew(1) />
		<cfset var i = 0 />
		<cfset var oProfile = createObject("component", application.stcoapi["dmProfile"].packagePath) />
		<cfset var stDefaultProfile = structnew() />
		
		<!--- Get user groups and convert them to Farcry roles --->
		<cfset aUserGroups = this.userdirectories[arguments.ud].getUserGroups(arguments.userid) />
		<cfloop from="1" to="#arraylen(aUserGroups)#" index="i">
			<cfset groups = listappend(groups,"#aUserGroups[i]#_#arguments.ud#") />
		</cfloop>
		
		<!--- New structure --->
		<cfset session.security.userid = "#arguments.userid#_#arguments.ud#" />
		<cfset session.security.roles = this.factory.role.groupsToRoles(groups) />
		
		<!--- Get users profile --->
		<cfset session.dmProfile = oProfile.getProfile(userName=arguments.userid,ud=arguments.ud) />
		<cfset session.dmProfile.lastLogin = now() />
		<cfset stDefaultProfile = this.userdirectories[arguments.ud].getProfile(arguments.userid,duplicate(session.dmProfile)) />
		<cfparam name="stDefaultProfile.override" default="false" />
		<cfif not session.dmProfile.bInDB>
			<cfset structappend(session.dmProfile,stDefaultProfile,stDefaultProfile.override) />

			<cfset session.dmProfile.userdirectory = arguments.ud />
			<cfset session.dmProfile.username = "#arguments.userid#_#arguments.ud#" />
			<cfset session.dmprofile = oProfile.createProfile(session.dmprofile) />
			
			<!--- Go and get it again now its in the db --->
			<cfset stDefaultProfile = this.userdirectories[arguments.ud].getProfile(userid=arguments.userid,stCurrentProfile=session.dmProfile) />
			<cfparam name="stDefaultProfile.override" default="false" />
			<cfset structappend(session.dmProfile,stDefaultProfile,stDefaultProfile.override) />
		<cfelseif stDefaultProfile.override>
			<cfset structappend(session.dmProfile,stDefaultProfile,true) />
		</cfif>
		<cfif not structKeyExists(session, "impersonator")>
			<cfset oProfile.setData(stProperties=session.dmProfile, bAudit=false) />
		</cfif>
	
		<!--- i18n: find out this locale's writing system direction using our special psychic powers --->
        <cfif application.i18nUtils.isBIDI(session.dmProfile.locale)>
            <cfset session.writingDir = "rtl" />
        <cfelse>
            <cfset session.writingDir = "ltr" />
        </cfif>
		
        <!--- i18n: final bit, grab user language from locale, tarts up html tag --->
        <cfset session.userLanguage = left(session.dmProfile.locale,2) />
		
		<!--- Admin flag --->
		<cfset session.fc.mode.bAdmin = checkPermission(permission="Admin") />
		
		<!--- /DEPRECATED --->
		
		<!--- First login flag --->
		<cfif not structKeyExists(session, "impersonator") and (
				(structkeyexists(session.dmProfile,"bDefaultObject") and session.dmProfile.bDefaultObject) 
				or (structkeyexists(session.dmProfile,"bInDB") and not session.dmProfile.bInDB) 
				or session.dmProfile.datetimeCreated eq session.dmProfile.datetimeLastUpdated
			)>
			
			<cfset session.security.firstlogin = true />
			
			<!--- DEPRECATED --->
			<cfset session.firstlogin = true />
		<cfelse>
			<cfset session.security.firstlogin = false />
			
			<!--- DEPRECATED --->
			<cfset session.firstLogin = false />
		</cfif>
		
		<!--- Log the result --->
		<cfif structKeyExists(session, "impersonator")>
			<farcry:logevent type="security" event="impersonatedby" userid="#session.security.userid#" notes="#session.impersonator#" />
		<cfelseif session.firstLogin>
			<farcry:logevent type="security" event="login" userid="#session.security.userid#" notes="First login" />
		<cfelse>
			<farcry:logevent type="security" event="login" userid="#session.security.userid#" />
		</cfif>
	</cffunction>

	<cffunction name="logout" access="public" output="false" returntype="void" hint="" bDocument="true">
		<cfset structdelete(session,"security") />
		<cfset structdelete(session,"dmProfile") />
		<cfset structdelete(session.fc,"mode") />
		
		<!--- DEPRECIATED VARIABLE --->
		<cfset structdelete(session,"dmSec") />
		
		<!--- Security has changed so we need to re-initialise our request.mode struct --->
		<cfset initRequestMode() />
	</cffunction>
	
	


	<!--- CACHE FUNCTIONS - SHOULD ONLY BE ACCESSED BY CORE CODE --->
	<cffunction name="setCache" access="public" output="false" returntype="boolean" hint="Sets up the ermission cache structure">
		<cfargument name="role" type="uuid" required="true" hint="The role to cache" />
		<cfargument name="permission" type="uuid" required="false" hint="The permission to cache" />
		<cfargument name="object" type="string" required="false" default="" hint="The object to cache" />
		<cfargument name="webskin" type="string" required="false" default="" hint="The webskin to cache" />
		<cfargument name="right" type="numeric" required="true" hint="The right value to cache" />
		
		<cfif not structkeyexists(this.cache.roles,arguments.role)>
			<cfset this.cache.roles[arguments.role] = structnew() />
		</cfif>
		<cfif not structkeyexists(this.cache.roles[arguments.role],"permissions")>
			<cfset this.cache.roles[arguments.role].permissions = structnew() />
		</cfif>
		<cfif not structkeyexists(this.cache.roles[arguments.role],"barnacles")>
			<cfset this.cache.roles[arguments.role].barnacles = structnew() />
		</cfif>
		<cfif not structkeyexists(this.cache.roles[arguments.role],"webskins")>
			<cfset this.cache.roles[arguments.role].webskins = structnew() />
		</cfif>
		
		<cfif isvalid("uuid",arguments.object) and isvalid("uuid",arguments.permission)>
			<cfset this.cache.roles[arguments.role].barnacles[arguments.object][arguments.permission] = arguments.right />
		<cfelseif len(arguments.webskin)>
			<cfset this.cache.roles[arguments.role].webskins[arguments.webskin] = arguments.right />
		<cfelseif isvalid("uuid",arguments.permission)>
			<cfset this.cache.roles[arguments.role].permissions[arguments.permission] = arguments.right />
		<cfelse>
			<cfthrow message="setCache requires the permission or webskin argument" />
		</cfif>
		
		<cfreturn arguments.right />
	</cffunction>

	<cffunction name="isCached" access="public" output="false" returntype="boolean" hint="Returns true if the right is cached">
		<cfargument name="role" type="uuid" required="true" hint="The role to find" />
		<cfargument name="permission" type="uuid" required="false" hint="The permission to find" />
		<cfargument name="object" type="string" required="false" default="" hint="The object to find" />
		<cfargument name="webskin" type="string" required="false" default="" hint="The webskin to cache" />
		
		<cfif isvalid("uuid",arguments.object) and isvalid("uuid",arguments.permission)>
			<cfreturn structkeyexists(this.cache.roles,arguments.role) and structkeyexists(this.cache.roles[arguments.role],"barnacles") and structkeyexists(this.cache.roles[arguments.role].barnacles,arguments.object) and structkeyexists(this.cache.roles[arguments.role].barnacles[arguments.object],arguments.permission) />
		<cfelseif len(arguments.webskin)>
			<cfreturn structkeyexists(this.cache.roles,arguments.role) and structkeyexists(this.cache.roles[arguments.role],"webskins") and structkeyexists(this.cache.roles[arguments.role].webskins,arguments.webskin) />
		<cfelseif isvalid("uuid",arguments.permission)>
			<cfreturn structkeyexists(this.cache.roles,arguments.role) and structkeyexists(this.cache.roles[arguments.role],"permissions") and structkeyexists(this.cache.roles[arguments.role].permissions,arguments.permission) />
		<cfelse>
			<cfthrow message="isCached requires the permission or webskin argument" />
		</cfif>
	</cffunction>
	
	<cffunction name="getCache" access="public" output="false" returntype="boolean" hint="Returns the cached right. Doesn't error check.">
		<cfargument name="role" type="uuid" required="true" hint="The role to retrieve" />
		<cfargument name="permission" type="uuid" required="false" hint="The permission to retrieve" />
		<cfargument name="object" type="string" required="false" default="" hint="The object to retrieve" />
		<cfargument name="webskin" type="string" required="false" default="" hint="The webskin to cache" />
		
		<cfif isvalid("uuid",arguments.object) and isvalid("uuid",arguments.permission)>
			<cfreturn this.cache.roles[arguments.role].barnacles[arguments.object][arguments.permission] />
		<cfelseif len(arguments.webskin)>
			<cfreturn this.cache.roles[arguments.role].webskins[arguments.webskin] />
		<cfelseif isvalid("uuid",arguments.permission)>
			<cfreturn this.cache.roles[arguments.role].permissions[arguments.permission] />
		<cfelse>
			<cfthrow message="getCache requires the permission or webskin argument" />
		</cfif>
	</cffunction>
	
	<cffunction name="deleteCache" access="public" output="false" returntype="void" hint="Deletes the specified cache. Doesn't error check.">
		<cfargument name="role" type="uuid" required="true" hint="The role to find" />
		<cfargument name="permission" type="string" required="false" default="" hint="The permission to find" />
		<cfargument name="object" type="string" required="false" default="" hint="The object to find" />
		<cfargument name="webskin" type="string" required="false" default="" hint="The webskin to cache" />
		
		<cfif not structkeyexists(this.cache.roles,arguments.role)>
			<cfset this.cache.roles[arguments.role] = structnew() />
			<cfset this.cache.roles[arguments.role].barnacles = structnew() />
			<cfset this.cache.roles[arguments.role].permissions = structnew() />
			<cfset this.cache.roles[arguments.role].webskins = structnew() />
		</cfif>
		
		<cfif isvalid("uuid",arguments.object) and isvalid("uuid",arguments.permission)>
			<!--- Remove barnacle --->
			<cfset structdelete(this.cache.roles[arguments.role].barnacles[arguments.object],arguments.permission) />
		<cfelseif isvalid("uuid",arguments.object)>
			<!--- Remove object --->
			<cfset structdelete(this.cache.roles[arguments.role].barnacles,arguments.object) />
		<cfelseif isvalid("uuid",arguments.permission)>
			<!--- Remove permission --->
			<cfif structkeyexistse(this.cache.roles[arguments.role].permissions,arguments.permission)>
				<!--- Remove permission from general permissions --->
				<cfset structdelete(this.cache.roles[arguments.role].permissions,arguments.permission) />
			<cfelse>
				<!--- Remove permission from all objects --->
				<cfloop collection="#this.cache.roles[arguments.role].barnacles#" item="arguments.object">
					<cfif structkeyexists(this.cache.roles[arguments.role].barnacles[arguments.object],arguments.permission)>
						<cfset structdelete(this.cache.roles[arguments.role].barnacles[arguments.object],arguments.permission) />
					</cfif>
				</cfloop>
			</cfif>
		<cfelseif len(arguments.webskin)>
			<!--- Remove webskin --->
			<cfset structdelete(this.cache.roles[arguments.role].webskins,arguments.webskin) />
		<cfelse>
			<!--- If only the role was provided, clear the entire role --->
			<cfset structclear(this.cache.roles[arguments.role].barnacles) />
			<cfset structclear(this.cache.roles[arguments.role].permissions) />
			<cfset structclear(this.cache.roles[arguments.role].webskins) />
		</cfif>
	</cffunction>
	
	
	<cffunction name="getLookup" access="public" output="false" returntype="string" hint="Returns the objectid for a specified label">
		<cfargument name="role" type="string" required="false" default="" hint="The title of the role to lookup" />
		<cfargument name="permission" type="string" required="false" default="" hint="The title of the permission to lookup" />
		
		<cfif len(arguments.role) and structkeyexists(this.cache.rolelookup,arguments.role)>
			<cfreturn this.cache.rolelookup[arguments.role] />
		<cfelseif len(arguments.permission) and structkeyexists(this.cache.permissionlookup,arguments.permission)>
			<cfreturn this.cache.permissionlookup[arguments.permission] />
		</cfif>
		
		<cfreturn "" />
	</cffunction>
	
	<cffunction name="hasLookup" access="public" output="false" returntype="boolean" hint="Returns true if the lookup is cached">
		<cfargument name="role" type="string" required="false" default="" hint="The title of the role to lookup" />
		<cfargument name="permission" type="string" required="false" default="" hint="The title of the permission to lookup" />
		
		<cfif len(arguments.role)>
			<cfreturn structkeyexists(this.cache.rolelookup,arguments.role) />
		<cfelseif len(arguments.permission)>
			<cfreturn structkeyexists(this.cache.permissionlookup,arguments.permission) />
		</cfif>
		
		<cfreturn false />
	</cffunction>
	
	<cffunction name="setLookup" access="public" output="false" returntype="uuid" hint="Stores an objectid for a specified label">
		<cfargument name="role" type="string" required="false" default="" hint="The title of the role to lookup" />
		<cfargument name="permission" type="string" required="false" default="" hint="The title of the permission to lookup" />
		<cfargument name="objectid" type="uuid" required="true" hint="The objectid of the item to store" />
		
		<cfif len(arguments.role)>
			<cfset this.cache.rolelookup[arguments.role] = arguments.objectid />
		<cfelse>
			<cfset this.cache.permissionlookup[arguments.permission] = arguments.objectid />
		</cfif>
		
		<cfreturn arguments.objectid />
	</cffunction>
	
	<cffunction name="removeLookup" access="public" output="false" returntype="void" hint="Removes the specified objectid or label">
		<cfargument name="role" type="string" required="false" default="" hint="The title of the role to lookup" />
		<cfargument name="permission" type="string" required="false" default="" hint="The title of the permission to lookup" />
		
		<cfset var i = 0 />
		
		<cfif len(arguments.role)>
			<cfif isvalid("uuid",arguments.role)>
				<cfloop collection="#this.cache.rolelookup#" item="i">
					<cfif this.cache.rolelookup[i] eq arguments.role>
						<cfset structdelete(this.cache.rolelookup,i) />
						<cfbreak />
					</cfif>
				</cfloop>
			<cfelse>
				<cfset this.cache.rolelookup[arguments.role] = arguments.objectid />
			</cfif>
		<cfelse>
			<cfif isvalid("uuid",arguments.permission)>
				<cfloop collection="#this.cache.permissionlookup#" item="i">
					<cfif this.cache.permissionlookup[i] eq arguments.permission>
						<cfset structdelete(this.cache.permissionlookup,i) />
						<cfbreak />
					</cfif>
				</cfloop>
			<cfelse>
				<cfset this.cache.permissionlookup[arguments.permission] = arguments.objectid />
			</cfif>
		</cfif>
	</cffunction>
	
	
	<!--- THESE FUNCTIONS ARE DEPRECIATED --->
	<cffunction name="getUsers" access="public" output="false" returntype="string" hint="Returns a list of the users that have this permission">
		<cfargument name="permission" type="uuid" required="true" hint="The permission to query" />
	
		<cfset var qRoles = "" />
		<cfset var qGroups = "" />
		<cfset var group = "" />
		<cfset var result = "" />
	
		<farcry:deprecated message="security.getUsers() is deprecated" />
		
		<!--- Get roles with that permission --->
		<cfquery datasource="#application.dsn#" name="qRoles">
			select	parentid
			from	#application.dbowner#farRole_aPermissions
			where	data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permission#" />
		</cfquery>
		
		<cfif qRoles.recorcount>
			<!--- Get the groups for those roles --->
			<cfquery datasource="#application.dsn#" name="qGroups">
				select	data
				from	#appliation.dbowner#farRole_aGroups
				where	parentid in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#valuelist(qRoles.parentid)#" />)
			</cfquery>
			
			<!--- Get the users for those groups --->
			<cfloop query="qGroups">
				<cfif structkeyexist(this.userdirectories,listlast(data,"_"))>
					<cfloop list="#this.userdirectories['CLIENTUD'].getGroupUsers(listfirst(data,'_'))#" index="group">
						<cfset result = application.factory.oUtils.listMerge(result,"#group#_#listlast(data,'_')#") />
					</cfloop>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn result />
	</cffunction>

	<cffunction name="defaultRequestMode" access="public" output="false" hint="Default the request.mode struct">

		<!--- init request.mode with defaults --->
		<cfset request.mode = {
			debug			= 0,
			livecombine		= 0,
			design 			= 0,
			flushcache 		= 0,
			rebuild 		= "auto",
			showdraft 		= 0,
			ajax 			= 0,
			tracewebskins 	= 0,
			profile 		= 0,
			bDeveloper 		= 0,
			showcontainers 	= 0,
			showtables 		= 0,
			showerror 		= 0,
			showdebugoutput	= 0,
			bAdmin 			= 0,
			lValidStatus	= "approved"
		} />

	</cffunction>

	<cffunction name="initRequestMode" access="public" output="false" returntype="struct" hint="Sets up the request.mode struct and other request settings based on the current users security permissions">
		<cfargument name="stURL" type="struct" required="true" default="#url#" hint="Reference to the URL struct" />
		
		<cfset var thisvar = "" />
		<cfset var urlvar = "" />
		<cfset var sessionmodes = "bAdmin,designmode:design,flushcache,showdraft,debug,livecombine" />
		<cfset var requestmodes = "profile,tracewebskins,bShowTray" />
		
		<cfset request.fc.bShowTray = true />
		<cfset request.fc.okToCache = true />
		
		<cfif isdefined("session")>
			<!--- init session.fc.mode with defaults --->
			<cfparam name="session.fc" default="#structnew()#" />
		</cfif>
		
		<!--- normalize bdebug --->
		<cfif structkeyexists(arguments.stURL,"bDebug")>
			<cfset arguments.stURL.debug = arguments.stURL.bDebug />
		</cfif>
		
		<cfif isdefined("session")>
			<!--- session modes --->
			<cfloop list="#sessionmodes#" index="thisvar">
				<cfset urlvar = listfirst(thisvar,":") />
				<cfset thisvar = listlast(thisvar,":") />
				
				<cfparam name="session.fc.mode.#thisvar#" default="0" />
				
				<cfif structkeyexists(arguments.stURL,urlvar) and arguments.stURL[urlvar] eq 0>
					<cfset request.mode[thisvar] = 0 />
					<cfset session.fc.mode[thisvar] = 0 />
				<cfelseif structkeyexists(arguments.stURL,urlvar) and ((arguments.stURL[urlvar] eq application.updateappkey AND application.updateappkey neq 1) or (request.mode.bAdmin and arguments.stURL[urlvar] eq 1))>
					<cfset request.mode[thisvar] = 1 />
					<cfset session.fc.mode[thisvar] = 1 />
				<cfelseif isdefined("session.fc.mode.#thisvar#")>
					<cfset request.mode[thisvar] = session.fc.mode[thisvar] />
				</cfif>
			</cfloop>
		</cfif>
		
		<!--- request only modes --->
		<cfloop list="#requestmodes#" index="thisvar">
			<cfset urlvar = listfirst(thisvar,":") />
			<cfset thisvar = listlast(thisvar,":") />
			
			<cfif structkeyexists(arguments.stURL,urlvar)>
				<cfif arguments.stURL[thisvar] eq 0>
					<cfset request.mode[thisvar] = 0 />
				<cfelseif (arguments.stURL[urlvar] eq application.updateappkey AND application.updateappkey neq 1) or (request.mode.bAdmin and arguments.stURL[urlvar] eq 1)>
					<cfset request.mode[thisvar] = 1 />
				</cfif>
			</cfif>
		</cfloop>
		
		<!--- rebuild options --->
		<cfif structkeyexists(arguments.stURL,"rebuild")>
			<cfif arguments.stURL.rebuild eq "page" or arguments.stURL.rebuild eq "page-#application.updateappkey#">
				<cfset request.mode.rebuild = "page" />
				<cfset request.mode.flushcache = 1 />
			<cfelseif arguments.stURL.rebuild eq "all" or arguments.stURL.rebuild eq "all-#application.updateappkey#">
				<cfset request.mode.rebuild = "all" />
				<cfset application.fc.lib.objectbroker.init(bFlush=true) />
			</cfif>
		</cfif>
		
		<!--- set valid status for content --->
		<cfif request.mode.showdraft>
			<cfset request.mode.lValidStatus = "draft,pending,approved" />
		</cfif>
		<cfset request.lValidStatus = request.mode.lValidStatus />
		
		<!--- ajax mode --->
		<cfif (structKeyExists(arguments.stURL,"ajaxmode") and listlast(arguments.stURL.ajaxmode)) or (isdefined("form.ajaxmode") and listlast(form.ajaxmode))>
			<cfset request.mode.ajax = 1 />
		</cfif>
		
		<cfreturn application.fapi.success() />
	</cffunction>
	
</cfcomponent>