<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/authentication.cfc,v 1.33.2.1 2005/05/19 01:54:54 gstewart Exp $
$Author: gstewart $
$Date: 2005/05/19 01:54:54 $
$Name: milestone_2-3-2 $
$Revision: 1.33.2.1 $

|| DESCRIPTION || 
$Description: authentication cfc $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayName="Authentication" hint="Security authentication functions">
	<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">
	<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">
	
	<cffunction name="addUserToGroup" hint="Adds a user to a given group in the preffered userdirectory" output="No">
		<cfargument name="userlogin" required="true">
		<cfargument name="groupname" required="true">
		<cfargument name="userdirectory" required="true">
			
		<cfscript>
			stResult = structNew();
			stResult.bSuccess = true;
			stResult.message="User added to group successfully";
			stUser = getUser(userlogin=arguments.userlogin,userdirectory=arguments.userdirectory);
			stGroup = getGroup(groupName=arguments.groupName,userdirectory=arguments.userdirectory);
			stUD = getUserDirectory();
			sql="
				SELECT * FROM #application.dbowner#dmUserToGroup
				WHERE userId = #stUser.userId# AND groupId = #stGroup.groupId#";
			qGroupMemberCheck = query(sql=sql,dsn=stUd[userDirectory].datasource);
			if (qGroupMemberCheck.recordCount eq 0)
			{
				sql=
				"INSERT INTO #application.dbowner#dmUserToGroup ( userId, groupId )
				VALUES ( #stUser.userId#, #stGroup.groupId# )";
				query(sql=sql,dsn=stUd[userDirectory].datasource);
			}
			oAudit = createObject("component","#application.packagepath#.farcry.audit");
			stuser = getUserAuthenticationData();
				if(stUser.bLoggedIn)
					oaudit.logActivity(auditType="dmSec.addUserTogroup", username=StUser.userlogin, location=cgi.remote_host, note="#arguments.userlogin# added to #arguments.groupname#");	
				
		</cfscript>
		
	<cfreturn stResult>
	</cffunction>
	
	
	<cffunction name="createGroup" hint="Creates a new user Group" returntype="struct" output="No">
		<cfargument name="groupName" required="true">
		<cfargument name="userDirectory" required="true">
		<cfargument name="groupNotes" required="false">
		
		<cfscript>
			stResult = structNew();
			//check to see if this group exists
			stGroup = getGroup(groupName=arguments.groupName,userDirectory=arguments.userDirectory);
			if (not structIsEmpty(stGroup))
			{
				stResult.bSuccess = false;
				stResult.message = "User Group already exists";
			}
			else
			{
				switch (application.dbtype)
				{
					case "ora" :
					{	
						sql =
						"INSERT INTO #application.dbowner#dmGroup (groupID, GroupName,GroupNotes )
						VALUES
						(DMGROUP_SEQ.nextval,'#arguments.GroupName#','#arguments.GroupNotes#')";
						query(sql=sql,dsn=stUd[arguments.UserDirectory].datasource);
						break;
					}
					default :
					{
						sql = 
						"INSERT INTO #application.dbowner#dmGroup ( GroupName,GroupNotes )
						VALUES	('#arguments.GroupName#','#replace(arguments.GroupNotes,"'","","ALL")#')";
						query(sql = sql,dsn=stUd[arguments.UserDirectory].datasource);
					}
				}
				stResult.bSuccess = true;
				stResult.message = "New group '#arguments.groupname#' has been successfully added";	
				oAudit = createObject("component","#application.packagepath#.farcry.audit");
				stuser = getUserAuthenticationData();
					if(stUser.bLoggedIn)
						oaudit.logActivity(auditType="dmSec.creategroup", username=StUser.userlogin, location=cgi.remote_host, note="group #arguments.groupname# created");		
				
			}	
		</cfscript>
		
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="createUser" hint="Adds a new user to the datastore" returntype="struct" output="No">
		<cfargument name="userlogin" required="true">
		<cfargument name="userDirectory" required="true">
		<cfargument name="userStatus" required="true">
		<cfargument name="userNotes" required="false" default="">
		<cfargument name="userPassword" required="true">
		
		<cfscript>
			stResult = structNew();
			stResult.bSuccess = true;
			stResult.message = "User has been successfully added";
			stUD = getUserDirectory();	
			aUsers = getMultipleUsers(userLogin=arguments.userlogin);
		</cfscript>	
		<cfif arrayLen(aUsers)>
			<cfscript>
				stResult.bSuccess = false;
				stResult.message = "User already exists";
			</cfscript>	
		<cfelse>
			<!--- check if ud uses password encryption --->
			<cfif structKeyExists(Application.dmSec.UserDirectory[arguments.userDirectory],"bEncrypted") and Application.dmSec.UserDirectory[arguments.userDirectory].bEncrypted>
				<cfset userPassword = hash(arguments.userPassword)>
			<cfelse>
				<cfset userPassword = arguments.userPassword>
			</cfif>
			
			<cflock name="#createUUID()#" timeout="20">
				<cftransaction>
				<cfswitch expression="#application.dbtype#">
					<cfcase value="ora">
						<cfquery datasource="#stUd[Userdirectory].datasource#">
							INSERT INTO #application.dbowner#dmUser (userid, userLogin,userPassword,userNotes,userStatus )
							VALUES (DMUSER_SEQ.nextval,'#arguments.UserLogin#','#userPassword#',<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.userNotes#">,'#arguments.userstatus#')
						</cfquery> 
					</cfcase>
					
					<cfdefaultcase>
						<cfquery datasource="#stUd[Userdirectory].datasource#">
							INSERT INTO #application.dbowner#dmUser ( userLogin,userPassword,userNotes,userStatus )
							VALUES ('#arguments.UserLogin#','#userPassword#',<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.userNotes#">,'#arguments.userstatus#')
						</cfquery> 	
					</cfdefaultcase>
				</cfswitch>
				
				<cfquery datasource="#stUd[Userdirectory].datasource#" name="q">
					select max(userID) as thisUserID FROM #application.dbowner#dmUser
				</cfquery>
				</cftransaction>	
				
				<cfscript>
					oAudit = createObject("component","#application.packagepath#.farcry.audit");
					stuser = getUserAuthenticationData();
						if(stUser.bLoggedIn)
							oaudit.logActivity(auditType="dmSec.createuser", username=StUser.userlogin, location=cgi.remote_host, note="user #arguments.userlogin# created");
				</cfscript>
			</cflock>
			<cfset stResult.userid = q.thisUserID>
		</cfif>			
		
	<cfreturn stResult>
	
	</cffunction>
	
			
	<cffunction name="deleteGroup" hint="Deletes a group from the datastore" output="No">
		<cfargument name="userdirectory">
		<cfargument name="groupname">
		
		<cfscript>
			stGroup = getGroup(userdirectory=arguments.userdirectory,groupName=arguments.groupName);
			groupID = stGroup.groupID;
			stUD = getUserDirectory();
			sql = "
				DELETE FROM #application.dbowner#dmGroup WHERE groupId='#GroupId#'";
			query(sql=sql,dsn=stUd[Userdirectory].datasource);	
			oAudit = createObject("component","#application.packagepath#.farcry.audit");
			stuser = getUserAuthenticationData();
				if(stUser.bLoggedIn)
					oaudit.logActivity(auditType="dmSec.deletegroup", username=Stuser.userlogin, location=cgi.remote_host, note="group #arguments.groupname# deleted");	
		</cfscript>
	</cffunction>
	
	
	
	<cffunction name="deleteUser" hint="Deletes a user from the datastore" returntype="struct" output="No">
		<cfargument name="userid" required="true" hint="Unique userid of user to delete">
		<cfargument name="userdirectory" required="true" hint="user directory user belongs to" default="clientud">
		<cfargument name="dsn" required="true">
		
		
		<!--- get username --->
		<cfset stUser = getUser(userid=arguments.userid,userdirectory=arguments.userdirectory)>
			
		<!--- delete profile --->
		<cfif structKeyExists(stUser,"userLogin")>
			<cfquery name="qProfile" datasource="#stUd[arguments.userdirectory].datasource#">
				select objectid from #application.dbowner#dmProfile 
				where userName = <cfqueryparam value="#stUser.userLogin#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<cfif qProfile.recordcount>
				<cfset oProfile = createObject("component", application.types.dmProfile.typepath)>
				<cfset oProfile.delete(objectid=qProfile.objectid)>
			</cfif>
		</cfif>
		<cfscript>
			//delete user
			sql = "DELETE FROM #application.dbowner#dmUser where userID = #arguments.userid#";
			query(sql=sql,dsn=arguments.dsn);
			sql = "DELETE FROM #application.dbowner#dmUserToGroup where userID = #arguments.userid#";
			query(sql=sql,dsn=arguments.dsn);
			stResult = structNew();
			stResult.bSuccess = true;
			stResult.message = "User deleted successfully";
			oAudit = createObject("component","#application.packagepath#.farcry.audit");
			stuser = getUserAuthenticationData();
				if(stUser.bLoggedIn)
					oaudit.logActivity(auditType="dmSec.deleteuser", username=Stuser.userlogin, location=cgi.remote_host, note="user #arguments.userid# was deleted");
		</cfscript>
			
	<cfreturn stResult>
	</cffunction>
	
	
	<cffunction name="getGroup" returntype="struct" hint="Returns group data" output="No">
		<cfargument name="userdirectory">
		<cfargument name="groupName" >
		<cfargument name="groupId" >

		<cfscript>
			stUD = getUserDirectory();
			switch (stUd[Userdirectory].type)
			{
				case "daemon":
				{
					sql = 
					"SELECT * FROM #application.dbowner#dmGroup g WHERE ";
					if (isDefined("arguments.groupName"))
						sql = sql & " upper(g.groupName)='#ucase(arguments.groupName)#'";
					else if (isDefined("arguments.groupID"))
						sql = sql & " g.groupID=#arguments.groupID#";
					qGetGroup = query(sql=sql,dsn=stUd[Userdirectory].datasource);
					if (qGetGroup.recordCount)
					{
						stGroup = queryToStructure(qGetGroup);
						stGroup.userDirectory=arguments.userdirectory;
					}	
					else
						stGroup = structNew();
					break;	
				}
				
				case "adsi":
				{
					o_NTsec = createObject("component", "#application.packagepath#.security.NTsecurity");
					groupNotes = o_NTsec.getGroupDescription(groupName=groupName, domain=stUd[arguments.Userdirectory].domain);
			
					stGroup = structNew();
					stGroup.groupName = groupName;
					stGroup.groupNotes = groupNotes;
					break;
				}	
			}	
						
		</cfscript>
		<cfreturn stGroup>
	</cffunction>
	
		
	
	<cffunction name="getMultipleUsers" hint="Gets all users for userlogin. Can be filtered to specific user directories otherwise is all user directories." output="No">
		<cfargument name="userid" required="false">
		<cfargument name="userlogin" required="false">
		<cfargument name="fragment" required="false">
		<cfargument name="lUserDirectories" required="false">

		<cfscript>
			aUsers = arrayNew(1);
			stUD = getUserDirectory();
			if (isDefined("arguments.lUserDirectories"))
				lUserDirectories=arguments.lUserdirectories;
			else
				lUserDirectories=StructKeyList(stUd);	
		</cfscript>

		<cfloop index="ud" list="#lUserDirectories#">
			
			<cfswitch expression="#stUd[ud].type#">
			
				<cfcase value="Daemon">
					<!--- search for the user --->
					<cfquery name="qUser" datasource="#stUd[ud].datasource#" >
						SELECT * FROM #application.dbowner#dmUser
							<cfif isDefined("arguments.userLogin")>WHERE upper(UserLogin) = <cfqueryparam value="#ucase(arguments.userLogin)#" cfsqltype="CF_SQL_VARCHAR"></cfif>
							<cfif isDefined("arguments.userId")>WHERE userId = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR"></cfif>
							<cfif isDefined("arguments.fragment")>WHERE UserLogin like <cfqueryparam value="#ucase(arguments.fragment)#" cfsqltype="CF_SQL_VARCHAR"></cfif>
						ORDER BY UserLogin ASC
					</cfquery>
					<cfscript>
						for(i=1;i LTE qUser.recordCount;i = i+1)
						{
							thisRow = structnew();
							thisRow.userId = qUser.userId[i];
							thisRow.userLogin = qUser.userLogin[i];
							thisRow.userPassword = qUser.userPassword[i];
							thisRow.userStatus = qUser.userStatus[i];
							thisRow.userNotes = qUser.userNotes[i];
							thisRow.userDirectory = ud;
							ArrayAppend( aUsers, thisRow );
						}	
						
					</cfscript>
					
				</cfcase>
			</cfswitch>
		</cfloop>

	<cfreturn aUsers>
	</cffunction>
	
	<cffunction name="getMultipleGroups" hint="Gets groups, filtered by userlogin, userdirectory." output="No">
		<cfargument name="userlogin" >
		<cfargument name="userdirectory" required="true">
		<cfargument name="bInvert" required="false" default="0" >
		
				
		<cfscript>
			
			ud = trim(arguments.userDirectory);
			//grab the user directorires object
			stUd = getUserDirectory();
			switch (stUd[ud].type)
			{
				case "Daemon" :
				{
					if(NOT arguments.bInvert)
					{
						sql = "
						SELECT *
						FROM dmGroup g ";
						if (isDefined('arguments.userlogin'))
						{
							sql = sql & ", dmUserToGroup ug, dmUser u
							WHERE g.groupId = ug.groupid
							AND upper(u.userLogin) = '#ucase(arguments.userLogin)#'
							AND u.userId = ug.userId";
						}
						sql = sql & " ORDER BY g.groupName";
					}
					else
					{
						switch (application.dbType)
						{
							case "ora":
							{
								sql = "
								SELECT *
								FROM dmGroup
								WHERE groupId not in (SELECT g.groupId FROM dmGroup g ";
								if (isDefined('arguments.userlogin'))
								{
									sql = sql & "
									, dmUserToGroup ug, dmUser u
									WHERE g.groupId = ug.groupid
									AND upper(u.userLogin) ='#ucase(arguments.userLogin)#'
									AND u.userId = ug.userId";
								}	
								sql = sql & ") ORDER BY groupName";
								break;
							}
							
							case "postgresql":
							{
								sql = "
								SELECT *
								FROM dmGroup
								WHERE groupId not in (SELECT g.groupId FROM dmGroup g ";
								if (isDefined('arguments.userlogin'))
								{
									sql = sql & "
									, dmUserToGroup ug, dmUser u
									WHERE g.groupId = ug.groupid
									AND upper(u.userLogin) ='#ucase(arguments.userLogin)#'
									AND u.userId = ug.userId";
								}	
								sql = sql & ") ORDER BY groupName";
								break;
							}
							
							case "mysql":
							{
								tempSql = "SELECT g.groupId FROM dmGroup g ";
								if (isDefined('arguments.userlogin'))
								{
									tempSql = tempSql & "
									, dmUserToGroup ug, dmUser u
									WHERE g.groupId = ug.groupid
									AND upper(u.userLogin) ='#ucase(arguments.userLogin)#'
									AND u.userId = ug.userId";
								}
								qTemp = query(sql=tempSql,dsn=stUd[ud].datasource);	
								// Need to wrap the WHERE clause into a variable, because if the user being managed, isn't a part of
								// a group yet, MySQL would generated an error
								// Scott Mebberson [Mitousa]					
								sqlAdd = "";                                                                                          
								if (qTemp.recordCount GT 0) sqlAdd = " WHERE groupId not in (" & #valueList(qTemp.groupId)# & ")";
								sql = "
								SELECT *
								FROM dmGroup#sqlAdd# ORDER BY groupName";
								break;
							}
							default: {
								sql = "
								SELECT *
								FROM dmGroup
								WHERE groupId not in (SELECT g.groupId FROM dmGroup g ";
								if (isDefined('arguments.userlogin'))
								{
									sql = sql & "
									, dmUserToGroup ug, dmUser u
									WHERE g.groupId = ug.groupid
									AND upper(u.userLogin) ='#ucase(arguments.userLogin)#'
									AND u.userId = ug.userId";
								}	
								sql = sql & ") ORDER BY groupName";
								break;
							}
						}
					}
					qGetGroup = query(sql=sql,dsn=stUd[ud].datasource);
					aGroups = queryToArrayOfStructures(qGetGroup);
				}	
				break;
				case "ADSI" :
				{
		
					o_NTsec = createObject("component", "#application.packagepath#.security.NTsecurity");
					aGroups = o_NTsec.getDomainGroups(domain=stUd[ud].domain);
					
					if (structKeyExists(stUd[ud], "FILTER"))
						domainFilter = stUd[ud].filter;
					else
						domainFilter = "";
			
					// convert the array to the daemon group array type 
					retGroups = ArrayNew(1);
					for (i=1;i LTE arrayLen(aGroups);i=i+1)
					{
						if (domainFilter eq "" OR findNoCase(domainFilter, aGroups[i]) eq 1)
						{
							groupNotes = o_NTsec.getGroupDescription(groupName=aGroups[i], domain=stUd[ud].domain);
							stGroup = structNew();
							stGroup.groupName = aGroups[i];
							stGroup.groupNotes = groupNotes;
							arrayAppend(retGroups, stGroup);
						}
					}
					agroups = retGroups;
					break;	
				}					
			}//end switch	
					
		</cfscript>
		
		<cfreturn aGroups>
		
	</cffunction> 
	
	
	
	<cffunction name="getUserAuthenticationData" access="public"  hint="If logged in, returns a structur of the users specific session information " returntype="struct" output="No">
		
		<cfset var stUser = structNew()>
		<cfscript>
			stUser.bLoggedIn = 0;
			if (isDefined("session.dmsec.authentication"))
			{	stUser = duplicate(session.dmsec.authentication);
				stUser.bLoggedin = 1;
			}
		</cfscript>		
		<cfreturn stUser>
	</cffunction>
	
	<cffunction name="getUser" hint="Retreives user info from the datastore" returntype="struct" output="No">
		<cfargument name="userDirectory" required="true">
		<cfargument name="userlogin" required="false">
		<cfargument name="userid" required="false">
				
		<cfset stUD = getUserDirectory()>


		<!--- check that we are searching daemon userdirectories only --->
		<cfswitch expression="#stUd[Userdirectory].type#">
			<cfcase value="Daemon">
				<!--- search for the user --->
				<cfquery name="qUser" datasource="#stUd[Userdirectory].datasource#" >
					SELECT * FROM dmUser
						<cfif isDefined("arguments.userLogin")>WHERE upper(UserLogin) = <cfqueryparam value="#ucase(userLogin)#" cfsqltype="CF_SQL_VARCHAR"></cfif>
						<cfif isDefined("arguments.userId")>WHERE userId = <cfqueryparam value="#userId#" cfsqltype="CF_SQL_VARCHAR"></cfif>
					ORDER BY UserLogin ASC
				</cfquery>
				<!--- if we got a user convert it to a struct --->
				<cfscript>
				stUser = structnew();
		
				if( qUser.recordCount gt 0 )
				{
					stUser.userId = qUser.userId;
					stUser.userLogin = qUser.userLogin;
					stUser.userPassword = qUser.userPassword;
					stUser.userStatus = qUser.userStatus;
					stUser.userNotes = qUser.userNotes;
					stUser.userDirectory = Userdirectory;
				}
				</cfscript>
			</cfcase>
			<cfcase value="ADSI">
				<cfscript>
				o_NTsec = createObject("component", "#application.packagepath#.security.NTsecurity");
				userNotes = o_NTsec.getUserDescription(userName=userLogin, domain=stUd[Userdirectory].domain);
		
				stUser = structNew();
				stUser.userID = userLogin;
				stUser.userLogin = userLogin;
				stUser.status = 4;
				stUser.userNotes = userNotes;
				stUser.userDirectory = userDirectory;
				</cfscript>
			</cfcase>
			<cfdefaultcase>
				<cfthrow detail="dmSec_UnknownUDType">
			</cfdefaultcase>
		</cfswitch>
	
		<cfreturn stUser>
	</cffunction>
		
	
	<cffunction name="getUserDirectory" hint="Gets all the userdirectories filtered by type and returns them to caller scope." output="No">
		<cfargument name="lFilterTypes" required="false">
		<cfargument name="UDScope" required="false" default="#Application.dmSec.UserDirectory#"> 
		<cfset localUD = duplicate( arguments.UDScope)>

		<cfif isDefined("arguments.lFilterTypes")>
			<cfloop index="i" list="#StructKeyList(localUD)#">
				<cfif not listFind( arguments.lFilterTypes, localUD[i].type)>
					<cfscript>structdelete( localUD, i );</cfscript>
				</cfif>
			</cfloop>
		</cfif>
				
		<cfreturn localUD>
	
	</cffunction>
	
	<cffunction name="login" hint="Logs in the user using userlogin and password, optionally limited to userdirectory." returntype="boolean">
		<cfargument name="bAudit" required="false" default="0" hint="Log this login?">
		<cfargument name="userLogin" required="true" hint="The users login name">
		<cfargument name="userPassword" required="true" hint="The users password">
		<cfargument name="userdirectory" required="false">
				
		<cfscript>
			oAuthorisation = createObject("component","#application.securitypackagepath#.authorisation");
			oAudit = createObject("component","#application.packagepath#.farcry.audit");
	
			logout(); //Clear out session details
			arguments.userlogin = trim(arguments.userlogin);
			arguments.userpassword = trim(arguments.userpassword);
			//assume user is not logged in
			bHasLoggedIn = 0;
			//grab the user directories (that is ones with relevant dmSec tables)
			stUD = getUserDirectory(lFilterTypes="ADSI,Daemon");
			//get the policy store
			stPolicyStore = oAuthorisation.getPolicyStore();	
		</cfscript> 
					
			<!--- loop through each user directory --->
			<cfloop index="ud" list="#structKeyList(stUD)#">
				<cfswitch expression="#stUD[ud].type#">
					<cfcase value="ADSI">
						<cfset lPolicyGroupIDs = "">
						<cfset validUD = "">
			
						<cfscript>
						domain = stUD[ud].domain;
						userLogin = arguments.userLogin;
						password = arguments.userPassword;
			
						// instantiate NT security object
						o_NTsec = createObject("component", "#application.packagepath#.security.NTsecurity");
						// authenticate user against ActiveDirectory
						bAuth = o_NTsec.authenticateUser(userName=userLogin, password=password, domain=domain);
						</cfscript>
			
						<cfif bAuth>
							<!--- user is valid --->
							<cfset validUD = ud>
							<cfset lPolicyGroupIDs = "">
			
							<cftry>
								<cfset lGroups = o_NTsec.getUserGroups(userName=userLogin, domain=domain)>
			
								<cfif listLen(lGroups) gt 0 AND lGroups neq "false">
									<!--- get the group mappings for this policy group on this user directory --->
									<cfset aGroups = oAuthorisation.getMultiplePolicyGroupMappings(lgroupnames=lgroups,userdirectory=ud)>
	
									<!--- loop through the mapped groups and check if the user is in them --->
									<cfloop index="j" from="1" to="#arrayLen(aGroups)#">
										<!--- if the user is a member of this group then add the policy group to this users valid policy groups --->
										<cfscript>
										stGroup = aGroups[j];
										lPolicyGroupIDs = listAppend(lPolicyGroupIDs, stGroup.policyGroupID);
										</cfscript>
									</cfloop>
								<cfelse>
									<cfthrow>
								</cfif>
							<cfcatch>
								<!--- get the group mappings for this policy group on this user directory --->
								<cfquery name="qUD" datasource="#stPolicyStore.datasource#">
								SELECT PolicyGroupID, ExternalGroupName
								FROM #application.dbowner#dmExternalGroupToPolicyGroup
								WHERE upper(ExternalGroupUserDirectory) = '#ucase(domain)#'
								ORDER BY PolicyGroupID ASC
								</cfquery>
			
								<!--- loop through the mapped groups and check if the user is in them --->
								<cfloop query="qUD">
									<!--- if the user is a member of this group then add the policy group to this users valid policy groups --->
									<cfscript>
									bInGroup = o_NTsec.userInGroup(userName=userLogin, groupName=qUD.ExternalGroupName, domain=domain);
									if (bInGroup) lPolicyGroupIDs = listAppend(lPolicyGroupIDs, qUD.PolicyGroupID);
									</cfscript>
								</cfloop>
							</cfcatch>
							</cftry>
			
							<!--- set the session login information --->
							<cflock timeout="45" throwontimeout="No" type="EXCLUSIVE" scope="SESSION">
							<cfscript>
							//name = o_NTsec.getUserFullName(userName=userLogin, domain=domain);
							//if (name eq "") name = "<not specified>";
							//notes = o_NTsec.getUserDescription(userName=userLogin, domain=domain);
			
							session.dmSec.authentication = structNew();
							session.dmSec.authentication.userID = userLogin;
							session.dmSec.authentication.userLogin = userLogin;
							session.dmSec.authentication.canonicalName = userLogin;
							session.dmSec.authentication.userNotes = "";
							session.dmSec.authentication.lPolicyGroupIDs = lPolicyGroupIDs;
							session.dmSec.authentication.userDirectory = validUD;
			
							bhasLoggedIn = 1;
							</cfscript>
							</cflock>
			
							<cfif listLen(lPolicyGroupIDs) eq 0>
								<cfif arguments.bAudit>
									<cfscript>
										oAudit.logActivity(auditType="dmSec.loginfailed", username=arguments.userlogin, location=cgi.remote_host, note="not admin group member");
									</cfscript>
								</cfif>
								<!--- throw error --->
								
							</cfif>
						<cfelse>
							<!--- takes too long to determine if user is in DOMAIN 
							<cfscript>
							// login failed so determine if user is a member of the domain
							bInDir = o_NTsec.userInDirectory(userName=userLogin, domain=domain);
							</cfscript>
			
							<cfif bInDir>--->
								<cfif arguments.bAudit>
									<cfscript>
										oAudit.logActivity(auditType="dmSec.loginfailed", username=arguments.userlogin, location=cgi.remote_host, note="ADSI login failed on domain #domain#");
									</cfscript>
								</cfif>
								<!--- throw error --->
								<!--- <cf_dmSec_throw errorcode="dmSec_LoginADSIFailed" lextra=""> --->
							<!--- </cfif> --->
						</cfif>
			
					</cfcase>
					<cfdefaultcase>
			
						<!--- search for the user in ud --->
						<cfset stUser = getUser(userlogin=arguments.userlogin,userdirectory=ud)>
						
						<!--- if we found the user --->
						<cfif not StructIsEmpty(stUser)>
			
							<!--- check the password is correct --->
							<cfif isdefined("stUser.userStatus")>
								<cfif stUser.userStatus neq 4>
									<!--- login failed due to user status --->
									<cfif arguments.bAudit>
										<cfscript>
											oAudit.logActivity(auditType="dmSec.loginfailed", username=arguments.userlogin, location=cgi.remote_host, note="userStatus: #stUser.userstatus#, account disabled");
											logged=1;
										</cfscript>
									</cfif>
									<!--- throw error --->
									<cfset bHasLoggedIn = 0>
									<cfbreak>
								</cfif>
							</cfif>
							
							<!--- check if UD has password encryption --->
							<cfif structKeyExists(stUD[ud],"bEncrypted") and stUD[ud].bEncrypted>
								<cfset userPassword = hash(arguments.userPassword)>
							<cfelse>
								<cfset userPassword = arguments.userPassword>
							</cfif>
							
							<cfif trim(stUser.userpassword) IS trim(userPassword)>
								
								<!--- get the users groups --->
								<cfscript>
									aGroups = GetMultipleGroups(userLogin=arguments.userlogin,userDirectory=ud);
									lGroupNames = arrayKeyToList(array=aGroups,key='groupName');
									lPolicyGroupIds = oAuthorisation.getPolicyGroupMappings(userDirectory=ud,lGroupNames=lGroupNames);
								</cfscript>
								
								<!--- map the groups to policy groups --->
														
								<!--- set the session login information --->
								<cflock timeout="45" throwontimeout="No" type="EXCLUSIVE" scope="SESSION">
								<cfscript>
									session.dmSec.authentication = duplicate( stUser );
									if( structKeyExists( session.dmSec.authentication, "userPassword"))
										structDelete( session.dmSec.authentication, "userPassword" );
									session.dmSec.authentication.lPolicyGroupIds=lPolicyGroupIds;
									session.dmSec.authentication.canonicalName = arguments.userlogin;
									bHasLoggedIn = 1;
								</cfscript>
								</cflock>
								
								<!--- login has succeded so stop searching the user directories --->
								<cfif arguments.bAudit>
									<cfscript>
										oAudit.logActivity(auditType="dmSec.login", username=arguments.userlogin, location=cgi.remote_host, note="userDirectory: #session.dmSec.authentication.userdirectory#");
									</cfscript>
								</cfif>
								
			
								<!--- break cfloop, finish template (perhaps this should be <cfexit>?) 20020908 GB --->
								<cfbreak>
							<cfelse>
								<!--- login failed due to incorrect password --->
								<cfif arguments.bAudit>
									<cfscript>
										oAudit.logActivity(auditType="dmSec.loginfailed", username=arguments.userlogin, location=cgi.remote_host, note="password incorrect");
										logged=1;
									</cfscript>
								</cfif>
			
								<!--- throw error --->
								<cfset bHasLoggedIn = 0>
							</cfif>
						</cfif>
			
					</cfdefaultcase>
				</cfswitch>
			</cfloop>
		
			<!--- we've been through all our userdirectories here, so if we haven't logged in throw a spaz --->
			<cfif not bHasLoggedIn and not isdefined("logged")>
				<!--- login failed - user unknown --->
				<cfif arguments.bAudit>
					<cfscript>
						oAudit.logActivity(auditType="dmSec.loginfailed", username=arguments.userlogin, location=cgi.remote_host, note="user unknown");
					</cfscript>
				</cfif>
			
			</cfif>

		<cfreturn bHasLoggedIn>
	</cffunction>
	
	<cffunction name="initDMSECSessionVars" returntype="boolean">
		<cfargument name="userlogin" required="Yes" hint="This user structure can be returned from getUser()">
		<cfargument name="userdirectory" required="Yes" hint="Daemon,ADSI">		
		<cftry>
			<cfscript>
			oAuthorisation = createObject("component","#application.securitypackagepath#.authorisation");
			aGroups = GetMultipleGroups(userLogin=arguments.userlogin,userDirectory=arguments.userdirectory);
			lGroupNames = arrayKeyToList(array=aGroups,key='groupName');
			lPolicyGroupIds = oAuthorisation.getPolicyGroupMappings(userDirectory=arguments.userdirectory,lGroupNames=lGroupNames);
			stUser = getUser(userlogin=arguments.userlogin,userdirectory=arguments.userdirectory);
			session.dmSec.authentication = duplicate( stUser );
			if( structKeyExists( session.dmSec.authentication, "userPassword"))
				structDelete( session.dmSec.authentication, "userPassword" );
			session.dmSec.authentication.lPolicyGroupIds=lPolicyGroupIds;
			session.dmSec.authentication.canonicalName = arguments.userlogin;
			bSuccess = 1;
			</cfscript>
			<cfcatch>
				<cfset bSuccess = 0>
			</cfcatch>
		</cftry>
		<cfreturn bSuccess>
	</cffunction>
	
	
	<cffunction name="logout" access="public" hint="Logs the user out of the system" output="No">
		<cfargument name="bAudit" type="boolean" required="false" default="false" >
		<cfargument name="note" type="string" required="false" default="REFERRER #CGI.HTTP_REFERER#">
		<cflock timeout=20 scope="Session" type="Exclusive">		
		<cfscript>
			bLoggedIn=0;
			if( isDefined("session.dmSec") AND isDefined("session.dmSec.authentication") )
				bLoggedIn=1;
			if (bLoggedin)
			{	username =  session.dmSec.authentication.userlogin;
				structDelete(session.dmSec, "authentication");
				structDelete(session, "dmProfile");
				structDelete(session,"genericadmin");
				if (arguments.bAudit)
				{
					oAudit = createObject("component","#application.packagepath#.farcry.audit");
					oAudit.logActivity(auditType="dmSec.logout", username=username, location=cgi.remote_host, note="#arguments.note#");
				}
			}		
		</cfscript>
		</cflock>
	</cffunction>
	
	<cffunction name="removeUserFromGroup" output="No">
		<cfargument name="userLogin" required="true">
		<cfargument name="groupName" required="true">
		<cfargument name="userDirectory" required="true">
		
		<cfscript>
			oAudit = createObject("component","#application.packagepath#.farcry.audit");
			stuser = getUser(userlogin=arguments.userlogin,userdirectory=arguments.userdirectory);
			stGroup=getGroup(groupname=arguments.groupname,userdirectory=arguments.userdirectory);
			stUD = getUserDirectory();
			
			sql = "
				DELETE FROM #application.dbowner#dmUserToGroup
				WHERE userId = #stUser.userId# AND groupId = #stGroup.groupId#";
			query(sql=sql,dsn=stUd[userDirectory].datasource);	
			stuser = getUserAuthenticationData();
				if(stUser.bLoggedIn)
					oAudit.logActivity(auditType="dmSec.removeUserFromGroup", username=StUser.userlogin, location=cgi.remote_host, note="#arguments.userlogin# removed from #arguments.groupname#");	
		</cfscript>

	</cffunction>
	
	<cffunction name="updateGroup" hint="Updates group data" returntype="struct" output="No">
		<cfargument name="groupID" required="true">
		<cfargument name="groupName" required="true">
		<cfargument name="groupNotes" required="false">
		
		<cfscript>
		stResult = structNew();
		stUD = getUserDirectory();
		sql = "
		UPDATE #application.dbowner#dmGroup SET
				GroupName='#arguments.GroupName#',GroupNotes='#replace(arguments.GroupNotes,"'","","ALL")#'
				WHERE GroupId=#arguments.GroupId#";
		query(sql=sql,dsn=stUd[arguments.UserDirectory].datasource);		
		stResult.bSuccess = true;
		stResult.message = "Group '#arguments.groupname#' has been successfully updated";
		oAudit = createObject("component","#application.packagepath#.farcry.audit");
		stuser = getUserAuthenticationData();
			if(stUser.bLoggedIn)
				oaudit.logActivity(auditType="dmSec.updategroup", username=StUser.userlogin, location=cgi.remote_host, note="group #arguments.groupname# updated");	
		</cfscript>
		
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="updateUser" hint="Updates users login data" output="No">
		<cfargument name="userid" required="true">
		<cfargument name="userlogin" required="true">
		<cfargument name="userDirectory" required="true">
		<cfargument name="userStatus" required="true">
		<cfargument name="userNotes" required="false" default="">
		<cfargument name="userPassword" required="true">
		
	
		<cfscript>
			stResult = structNew();
			stResult.bSuccess = true;
			stResult.message = "User has been successfully added";
			stUD = getUserDirectory();
			stOriginalUser = getuser(userid=arguments.userid,userdirectory=arguments.userdirectory);
			if (NOT stOriginalUser.userLogin IS arguments.userLogin)
			{
				aUsers = getMultipleUsers(userlogin=arguments.userlogin);
				if (arrayLen(aUsers))
				{
					stResult.bSuccess = false;
					stResult.message = "User update has not taken place, userlogin already exists";
				}
			}
		</cfscript>
			
		<cfif stResult.bSuccess>
			<!--- check if ud uses password encryption --->
			<cfif structKeyExists(Application.dmSec.UserDirectory[arguments.userDirectory],"bEncrypted") and Application.dmSec.UserDirectory[arguments.userDirectory].bEncrypted>
				<!--- check if password has changed --->
				<cfif arguments.userPassword neq stOriginalUser.userPassword>
					<cfset userPassword = hash(arguments.userPassword)>
				<cfelse>
					<cfset userPassword = arguments.userPassword>
				</cfif>
			<cfelse>
				<cfset userPassword = arguments.userPassword>
			</cfif>
			
			<cfquery datasource="#stUd[Userdirectory].datasource#">
				UPDATE #application.dbowner#dmUser SET
				userLogin='#arguments.UserLogin#',userPassword='#userPassword#',userNotes=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.usernotes#">,userStatus='#arguments.userStatus#'
				WHERE userId='#arguments.userId#'
			</cfquery> 
			<cfscript>
				oAudit = createObject("component","#application.packagepath#.farcry.audit");
				stuser = getUserAuthenticationData();
				if(stUser.bLoggedIn)
					oaudit.logActivity(auditType="dmSec.updateuser", username=stUser.userlogin, location=cgi.remote_host, note="user #arguments.userlogin# updated");
			</cfscript>
		
		</cfif>			
			
		
		<cfreturn stResult>
	</cffunction>
	
</cfcomponent>