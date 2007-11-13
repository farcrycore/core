<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/security/authentication.cfc,v 1.40.2.7 2006/03/08 01:55:51 geoff Exp $
$Author: geoff $
$Date: 2006/03/08 01:55:51 $
$Name: milestone_3-0-1 $
$Revision: 1.40.2.7 $

|| DESCRIPTION || 
$Description: authentication cfc $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $
--->

<cfcomponent displayName="Authentication" hint="Security authentication functions">
	<cfinclude template="/farcry/core/admin/includes/cfFunctionWrappers.cfm">
	<cfinclude template="/farcry/core/admin/includes/utilityFunctions.cfm">
	<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
	
	<cffunction name="addUserToGroup" hint="Adds a user to a given group in the preffered userdirectory" output="No">
		<cfargument name="userlogin" required="true">
		<cfargument name="groupname" required="true">
		<cfargument name="userdirectory" required="true">
			
		<cfset var stResult = structNew() />
		
		<farcry:deprecated message="authentication.addUserToGroup() should be replaced by calls to farUser.addGroup()" />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.message="User added to group successfully" />

		<cfset createObject("component", application.stcoapi["farUser"].packagePath).addGroup(arguments.userlogin,arguments.groupname)>
		
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="createGroup" hint="Creates a new user Group" returntype="struct" output="No">
		<cfargument name="groupName" required="true">
		<cfargument name="userDirectory" required="true">
		<cfargument name="groupNotes" required="false">
		
		<cfset var stGroup = structnew() />
		
		<farcry:deprecated message="authentication.createGroup() should be replaced by calls to farGroup.createData()" />
		
		<cfset stGroup.objectid = createuuid() />
		<cfset stGroup.title = arguments.groupname />
		
		<cfset stGroup = createObject("component", application.stcoapi["farGroup"].packagePath).createData(stProperties=stGroup) />
		
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="createUser" hint="Adds a new user to the datastore" returntype="struct" output="No">
		<cfargument name="userlogin" required="true">
		<cfargument name="userDirectory" required="true">
		<cfargument name="userStatus" required="true">
		<cfargument name="userNotes" required="false" default="">
		<cfargument name="userPassword" required="true">
		
		<cfset var stUser = structnew() />
		<cfset var stResult = structnew() />
		
		<farcry:deprecated message="authentication.createUser() should be replaced by calls to farUser.createData()" />
		
		<cfset stUser.objectid = createuuid() />
		<cfset stUser.userid = arguments.userlogin />
		<cfif stUser.userstatus eq 4>
			<cfset stUser.userstatus = "active" />
		<cfelse>
			<cfset stUser.userstatus = "disabled" />
		</cfif>
		<cfset stuser.password = arguments.userpassword />
		<cfset stUser.password = hash(stUser.password) />
		<cfset stUser = createObject("component", application.stcoapi["farUser"].packagePath).createData(stProperties=stUser) />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.message = "User has been successfully added" />
		
		<cfreturn stResult>
	</cffunction>
			
	<cffunction name="deleteGroup" hint="Deletes a group from the datastore" output="No">
		<cfargument name="userdirectory">
		<cfargument name="groupname">
		
		<cfset var oGroup = createObject("component", application.stcoapi["farGroup"].packagePath) />
		
		<farcry:deprecated message="authentication.deleteGroup() should be replaced by calls to farGroup.delete()" />
		
		<cfset oGroup.delete(objectid=oGroup.getID(arguments.groupname)) />
	</cffunction>
	
	<cffunction name="deleteUser" hint="Deletes a user from the datastore" returntype="struct" output="No">
		<cfargument name="userid" required="true" hint="Unique userid of user to delete">
		<cfargument name="userdirectory" required="true" hint="user directory user belongs to" default="clientud">
		<cfargument name="dsn" required="true">

		<cfset var oUser = createObject("component", application.stcoapi["farUser"].packagePath) />
		<cfset var stResult = structnew() />

		<farcry:deprecated message="authentication.deleteUser() should be replaced by calls to farUser.delete()" />
		
		<cfif findnocase(arguments.userdirectory,arguments.userid)>
			<cfset arguments.userid = listfirst(arguments.userid,"_") />
		</cfif>
		
		<cfset oUser.delete(objectid=oUser.getByUserID(arguments.userid)) />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.message = "User deleted successfully" />
		
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="getGroup" returntype="struct" hint="Returns group data" output="No">
		<cfargument name="userdirectory">
		<cfargument name="groupName" >
		<cfargument name="groupId" >

		<cfset var oGroup = createObject("component", application.stcoapi["farGroup"].packagePath) />
		<cfset var stGroup = structnew() />
		<cfset var stResult = structnew() />

		<farcry:deprecated message="authentication.getGroup() should be replaced by calls to farGroup.getData()" />
		
		<cfif not isvalid('uuid',arguments.groupid)>
			<cfif findnocase(arguments.userdirectory,arguments.groupname)>
				<cfset arguments.groupname = listfirst(arguments.groupname,"_") />
			</cfif>
			<cfset arguments.groupid = oGroup.getID(arguments.groupname) />
		</cfif>

		<cfset stGroup = oGroup.getData(objectid=arguments.groupid) />
		
		<cfset stResult.groupName = stGroup.title />
		<cfset stResult.groupNotes = "" />
		
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="getMultipleUsers" hint="Gets all users for userlogin. Can be filtered to specific user directories otherwise is all user directories." output="No">
		<cfargument name="userid" required="false">
		<cfargument name="userlogin" required="false">
		<cfargument name="fragment" required="false">
		<cfargument name="lUserDirectories" required="false">

		<farcry:deprecated message="authentication.getMultipleUsers() is not supported by the 4.1 security structure" />
		
		<cfthrow message="authentication.getMultipleUsers() is not supported by the 4.1 security structure" />
	</cffunction>
	
	<cffunction name="getMultipleGroups" hint="Gets array of groups, filtered by userlogin, userdirectory." output="false" returntype="array">
		<cfargument name="userlogin" >
		<cfargument name="userdirectory" required="true">
		<cfargument name="bInvert" required="false" default="0" hint="Flag to get groups userlogin is not a member of. (CRACK! GB)">
		
		<cfset var group = "" />
		<cfset var oGroup = createObject("component", application.stcoapi["farGroup"].packagePath) />
		<cfset var stGroup = structnew() />
		<cfset var usergroups = "" />
		<cfset var stResult = structnew() />
		<cfset var aResult = arraynew(1) />
		
		<farcry:deprecated message="authentication.getMultipleGroups() should be replaced by application.security.userdirectories[ud].getUserGroups()" />
		
		<cfif findnocase(arguments.userdirectory,arguments.userlogin)>
			<cfset arguments.userlogin = listfirst(arguments.userlogin,"_") />
		</cfif>
		
		<cfset usergroups = application.security.userdirectories.CLIENTUD.getUserGroups(arguments.userlogin) />
		
		<cfloop list="#application.security.userdirectories.CLIENTUD.getAllGroups()#" index="group">
			<cfif arguments.bInvert xor listcontains(usergroups,group)>
				<cfset stGroup = oGroup.getData(oGroup.getID(group)) />
				<cfset stResult = structnew() />
				<cfset stResult.groupName = stGroup.title />
				<cfset stResult.groupNotes = "" />
				<cfset arrayappend(aResult,stResult) />
			</cfif>
		</cfloop>
		
		<cfreturn aResult />
	</cffunction> 
	
	<cffunction name="getUserAuthenticationData" access="public"  hint="If logged in, returns a structur of the users specific session information " returntype="struct" output="No">
		
		<cfset var stUser = structNew()>
		
		<farcry:deprecated message="authentication.getUserAuthenticationData() should be replaced by ???" />
		
		<cfscript>
			stUser.bLoggedIn = 0;
			if (isDefined("session.dmsec.authentication"))
			{	stUser = duplicate(session.dmsec.authentication);
				stUser.bLoggedin = 1;
			}
		</cfscript>
		
		<cfreturn stUser>
	</cffunction>
	
	<cffunction name="getUser" hint="Retreives user info from the datastore" returntype="struct" output="true">
		<cfargument name="userDirectory" required="true" type="string" hint="Datasource name for userdirectory.">
		<cfargument name="userlogin" required="false">
		<cfargument name="userid" required="false">
				
		<cfset var stUser = structNew() />
		<cfset var stResult = structnew() />
		<cfset var oUser = createObject("component", application.stcoapi["farUser"].packagePath) />
		
		<farcry:deprecated message="authentication.getUser() should be replaced by farUser.getData()" />
		
		<cfif not isvalid("uudi",arguments.userid)>
			<cfif findnocase(arguments.userdirectory,arguments.userlogin)>
				<cfset arguments.userlogin = listfirst(arguments.userlogin,"_") />
			</cfif>
			<cfset stUser = oUser.getByUserID(arguments.userlogin) />
		<cfelse>
			<cfset stUser = oUser.getData(objectid=arguments.userid) />
		</cfif>

		<cfset stResult.userid = stUser.objectid />
		<cfset stResult.userLogin = stUser.userid />
		<cfset stResult.userPassword = stUser.password />
		<cfif stUser.userstatus eq "active">
			<cfset stResult.userStatus = 4 />
		<cfelse>
			<cfset stResult.userStatus = 2 />
		</cfif>
		<cfset stResult.userNotes = "" />
		<cfset stResult.userDirectory = "CLIENTUD" />
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="getUserDirectory" hint="Gets all the userdirectories filtered by type and returns them as a structure." output="false" returntype="struct">
		<cfargument name="lFilterTypes" required="false" hint="List of user directory types to filter on." type="string" />
		<cfargument name="UDScope" required="false" default="#Application.dmSec.UserDirectory#" type="struct" hint="Structure of userdirectories. Defaults to aplication.dmsec.userdirectory" />

		<farcry:deprecated message="authentication.getUserDirectory() is not supported by the 4.1 security structure" />
		
		<cfthrow message="authentication.getUserDirectory() is not supported by the 4.1 security structure" />
				
		<cfreturn structnew() />
	</cffunction>
	
	<cffunction name="login" hint="Logs in the user using userlogin and password, optionally limited to userdirectory." returntype="boolean">
		<cfargument name="bAudit" required="false" default="0" hint="Log this login?">
		<cfargument name="userLogin" required="true" hint="The users login name">
		<cfargument name="userPassword" required="true" hint="The users password">
		<cfargument name="userdirectory" required="false">
		
		<cfset var auditNote = "" />
		<cfset var ud = "" />
		<cfset var stResult = structnew() />
		<cfset var oUser = createObject("component", application.stcoapi["farUser"].packagePath) />
		<cfset var oRole = createObject("component", application.stcoapi["farRole"].packagePath) />
		<cfset var oPermission = createObject("component", application.stcoapi["farPermission"].packagePath) />
		<cfset var groups = "" />
		<cfset var group = "" />
		
		<farcry:deprecated message="authentication.login() has been deprectated in favor of UserDirectory.authenticate()" />
		
		<!--- Clear session details --->
		<cfset logout() />
		
		<!--- Clean arguments --->
		<cfset arguments.userlogin = trim(arguments.userlogin) />
		<cfset arguments.userpassword = trim(arguments.userpassword) />
		
		<cfloop collection="#application.security.userdirectories#" item="ud">
			<!--- Authenticate user --->
			<cfset stResult = application.security.userdirectories[ud].authenticate() />
			
			<cfif structkeyexists(stResult,"authenticated")>
				<cfif not stResult.authenticated>
					<cfset application.factory.oAudit.logActivity(auditType="dmSec.loginfailed", username=arguments.userlogin, location=cgi.remote_host, note="password incorrect,") />
					<cfreturn false />
				</cfif>
				
				<!--- Get user groups and convert them to Farcry roles --->
				<cfloop list="#application.security.userdirectories[ud].getUserGroups(stResult.userid)#" index="group">
					<cfset groups = listappend(groups,"#group#_#ud#") />
				</cfloop>
				<cfset session.dmSec.authentication.lPolicyGroupIds = oRole.groupsToRoles(groups) />
				
				<!--- New structure --->
				<cfset session.security.userid = "#stResult.userid#_#ud#" />
				<cfset session.security.roles = oRole.groupsToRoles(groups) />
				
				<!--- Retrieve user info --->
				<cfset session.dmSec.authentication = oUser.getByUserID(stResult.userid) />
				<cfif structkeyexists(session.dmSec.authentication,"password")>
					<cfset structdelete(session.dmSec.authentication,"password") />
				</cfif>
				<cfset session.dmSec.authentication.userlogin = stResult.userid />
				<cfset session.dmSec.authentication.canonicalname = "#stResult.userid#_#ud#" />
				<cfset session.dmSec.authentication.userdirectory = ud />
				<cfparam name="session.sessionid" default="#createuuid()#" />
				
				<!--- Admin flag --->
				<cfset session.dmSec.authentication.bAdmin = application.security.checkPermission(permission=oPermission.getID("Admin")) />
				
				<!--- First login flag --->
				<cfif application.factory.oAudit.getAuditLog(username=session.security.userid,auditType="dmSec.login").recordcount eq 0>
					<cfset session.firstLogin = false />
				<cfelse>
					<cfset session.firstlogin = true />
				</cfif>
				
				<!--- Log the result --->
				<cfif arguments.bAudit>
					<cfif session.firstLogin>
						<cfset application.factory.oAudit.logActivity(auditType="dmSec.login", username=session.dmSec.authentication.canonicalname, location=cgi.remote_host, note="userDirectory: #ud# **First Login**") />
					<cfelse>
						<cfset application.factory.oAudit.logActivity(auditType="dmSec.login", username=session.dmSec.authentication.canonicalname, location=cgi.remote_host, note="userDirectory: #ud#") />
					</cfif>
				</cfif>
				
				<!--- Return 'success' --->
				<cfreturn true />
			</cfif>
		</cfloop>
		
		<!--- If login failed, log that --->
		<cfset application.factory.oAudit.logActivity(auditType="dmSec.loginfailed", username=arguments.userlogin, location=cgi.remote_host, note="user unknown") />
		<cfreturn false />
	</cffunction>
	
	<cffunction name="initDMSECSessionVars" returntype="boolean">
		<cfargument name="userlogin" required="Yes" hint="This user structure can be returned from getUser()">
		<cfargument name="userdirectory" required="Yes" hint="Daemon,ADSI">		
		
		<farcry:deprecated message="authentication.initDMSECSessionVars() is not supported by the 4.1 security structure" />
		
		<cfthrow message="authentication.initDMSECSessionVars() is not supported by the 4.1 security structure" />
				
		<cfreturn false />
	</cffunction>
	
	<cffunction name="logout" access="public" hint="Logs the user out of the system" output="No">
		<cfargument name="bAudit" type="boolean" required="false" default="false" >
		<cfargument name="note" type="string" required="false" default="REFERRER #CGI.HTTP_REFERER#">
		
		<farcry:deprecated message="authentication.logout() has been deprectated in favor of ????" />
		
		<cfset structdelete(session,"security") />
	</cffunction>
	
	<cffunction name="removeUserFromGroup" output="No">
		<cfargument name="userLogin" required="true">
		<cfargument name="groupName" required="true">
		<cfargument name="userDirectory" required="true">
		
		<cfset var oUser = createObject("component", application.stcoapi["farUser"].packagePath) />
		
		<farcry:deprecated message="authentication.removeUserFromGroup() has been deprectated in favor of farUser.removeGroup()" />
		
		<cfif findnocase(arguments.userdirectory,arguments.userlogin)>
			<cfset arguments.userlogin = listfirst(arguments.userlogin,"_") />
		</cfif>
		<cfif findnocase(arguments.userdirectory,arguments.groupName)>
			<cfset arguments.groupName = listfirst(arguments.groupName,"_") />
		</cfif>

		<cfset oUser.removeGroup(user=arguments.userlogin,gorup=arguments.groupname) />
	</cffunction>
	
	<cffunction name="updateGroup" hint="Updates group data" returntype="struct" output="No">
		<cfargument name="groupID" required="true">
		<cfargument name="groupName" required="true">
		<cfargument name="groupNotes" required="false">
		
		<cfset var stGroup = structnew() />
		<cfset var oGroup = createObject("component", application.stcoapi["farGroup"].packagePath) />
		<cfset var stResult = structnew() />
		
		<farcry:deprecated message="authentication.updateGroup() has been deprectated in favor of farGroup.setData()" />
		
		<cfset stGroup = oGroup.getData(objectid=arguments.groupid) />
		<cfset stGroup.title = arguments.groupName />
		<cfset oGroup.setData(stProperties=stGroup) />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.message = "Group '#arguments.groupname#' has been successfully updated" />
		
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="updateUser" hint="Updates users login data" output="No">
		<cfargument name="userid" required="true">
		<cfargument name="userlogin" required="true">
		<cfargument name="userDirectory" required="true">
		<cfargument name="userStatus" required="true">
		<cfargument name="userNotes" required="false" default="">
		<cfargument name="userPassword" required="true">
		
		<cfset var stResult = structnew() />
		<cfset var stUser = structnew() />
		<cfset var oUser = createObject("component", application.stcoapi["farUser"].packagePath) />
		
		<farcry:deprecated message="authentication.updateUser() has been deprectated in favor of farUser.setData()" />
		
		<cfset stUser = oUser.getData(objectid=arguments.userid) />
		<cfset stUser.userid = arguments.userlogin />
		<cfif arguments.userstatus eq 4>
			<cfset stUser.userstatus = "active" />
		<cfelse>
			<cfset stUser.userstatus = "disabled" />
		</cfif>
		<cfset stUser.password = arguments.userPassword />
		<cfset oUser.setData(stProperties=stUser) />
			
		<cfset stResult.bSuccess = true />
		<cfset stResult.message = "User has been successfully added" />
			
		<cfreturn stResult>
	</cffunction>
	
</cfcomponent>