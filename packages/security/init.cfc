<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Security Initialisation --->
<!--- @@Description: FarCry security intilisation functions. --->
<!--- @@Developer: Geoff Bowers (modius@daemon.com.au) --->
<cfcomponent displayName="Security Initiatlisation" hint="FarCry security intilisation functions">

	<cffunction name="initPolicyGroupsDatabase">
		<cfargument name="datasource" required="true">
		<cfargument name="bClearTable" required="false" default="false">
		<cfargument name="core" required="true">
		<cfargument name="project" required="true" type="string" hint="Absolute path to the project dir" />
		<cfargument name="securitypackagepath" required="false" default="#application.securitypackagepath#">
		<cfargument name="policygroupimport" required="false" default="" type="string" />
		
		<cfif NOT len(arguments.policygroupimport)>
			<!--- if no import provided, resort to legacy location --->
			<cfset arguments.policygroupimport="#arguments.project#/www/install/dmSec_files/policyGroups.wddx" />
		</cfif>
		
		<!--- 		
		TODO:
			this appears to be dbtype specific
			makes reference to absolute file positions
			should throw errors where applicable
			GB 20061022 needs to be sorted out!
 		--->	
		
		
		<cfif arguments.bClearTable>
			<cftry>
			    <cfquery name="qDelete" datasource="#arguments.datasource#">
				DELETE FROM #application.dbowner#dmPolicyGroup
				</cfquery>

				<cfcatch>
					<cflog text="#cfcatch.message# #cfcatch.detail# [SQL: #cfcatch.sql#]" file="coapi" type="error" application="yes">					
				</cfcatch>
			</cftry>
		</cfif>
		
		<cftry>
			<cfquery name="sIdentity" datasource="#arguments.datasource#">SET Identity_Insert dmPolicyGroup ON</cfquery>
			<cfcatch type="Database">
				<cflog text="#cfcatch.message# #cfcatch.detail# [SQL: #cfcatch.sql#]" file="coapi" type="warning" application="yes">
			</cfcatch>
		</cftry>
		
		<!--- #arguments.core#/admin/install/dmSec_files/policyGroups.wddx --->
		<cfif fileexists(arguments.policygroupimport)>
			<cffile action="READ" file="#arguments.policygroupimport#" variable="qPolicyGroupsWDDX" />
		<cfelse>
			<cfthrow type="security.init" message="File not found" detail="#arguments.policygroupimport# does not exist." />
		</cfif>
		<cfwddx action="WDDX2CFML" input="#qPolicyGroupsWDDX#" output="qPolicyGroups">
		<cfset oAuthorisation=createObject("component","#arguments.securitypackagepath#.authorisation")>
		
		<cfloop query="qPolicyGroups">
			<cftry>
				<cfscript>
				stObj = structNew();
				stObj.PolicyGroupID = qPolicyGroups.PolicyGroupID;
				stObj.PolicyGroupName = qPolicyGroups.PolicyGroupName;
				stObj.PolicyGroupNotes = qPolicyGroups.PolicyGroupNotes;
				
				oAuthorisation.createPolicyGroup(policygroupname=qPolicyGroups.PolicyGroupName,policyGroupNotes=qPolicyGroups.PolicyGroupNotes,policyGroupID=qPolicyGroups.PolicyGroupID);
				</cfscript>
	
				<cfcatch>
					<cfdump var="#cfcatch#">
				</cfcatch>
			</cftry>
		</cfloop>

		<cftry>
			<!--- TODO = turn on the oracle triggers again --->
			<cfquery name="sIdentity" datasource="#arguments.datasource#">
			SET Identity_Insert dmPolicyGroup OFF
			</cfquery>

			<cfcatch type="Database">
				<cflog text="#cfcatch.message# #cfcatch.detail# [SQL: #cfcatch.sql#]" file="coapi" type="error" application="yes">					
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="initPermissionsDatabase" hint="Initialise permissions table with a file import." output="false" returntype="void">
		<cfargument name="datasource" required="true">
		<cfargument name="bClearTable" required="false" default="false">
		<cfargument name="core" required="true">
		<cfargument name="project" required="true" type="string" hint="Absolute path to the project dir" />
		<cfargument name="securitypackagepath" required="false" default="#application.securitypackagepath#">
		<cfargument name="permissionsimport" default="" type="string" />

		<cfset var qPermissionsWDDX="" />
		<cfset var oAuthorisation="" />
		<cfset var qPermissions="" />
		<cfset var stObj = structNew() />

		<!--- if permissionsimport not available, resort to legacy location --->
		<cfif NOT len(arguments.permissionsimport)>
			<cfset arguments.permissionsimport="#arguments.project#/www/install/dmSec_files/permissions.wddx" />
		</cfif>
		
		<cfif arguments.bClearTable>
		    <cfquery datasource="#arguments.datasource#">
			    DELETE FROM #application.dbowner#dmPermission
			</cfquery>
		</cfif>

		<cfswitch expression="#application.dbtype#">
			<cfcase value="odbc,mssql">
				<cfquery datasource="#arguments.datasource#">
				SET Identity_Insert dmPermission ON
				</cfquery>
			</cfcase>
		</cfswitch>
		
		<cfif fileexists(arguments.permissionsimport)>
			<cffile action="READ" file="#arguments.permissionsimport#" variable="qPermissionsWDDX" />
		<cfelse>
			<cfthrow type="security.init" message="File not found" detail="#arguments.permissionsimport# does not exist." />		
		</cfif>
		
		<cfwddx action="WDDX2CFML" input="#qPermissionsWDDX#" output="qPermissions" />
		<cfset oAuthorisation=createObject("component","#arguments.securitypackagepath#.authorisation") />

		<cfloop query="qPermissions">
			<cfscript>
			stObj = structNew();
			stObj.PermissionID = qPermissions.PermissionID;
			stObj.PermissionName = qPermissions.PermissionName;
			stObj.PermissionNotes = qPermissions.PermissionNotes;
			stObj.PermissionType = qPermissions.PermissionType;
			oAuthorisation.createPermission(PermissionID = qPermissions.PermissionID,PermissionName = qPermissions.PermissionName,PermissionNotes = qPermissions.PermissionNotes,PermissionType = qPermissions.PermissionType);
			</cfscript>
		</cfloop>
		
		<cfswitch expression="#application.dbtype#">
			<cfcase value="odbc,mssql">	
				<cfquery datasource="#arguments.datasource#">
					SET Identity_Insert dmPermission OFF
				</cfquery>
			</cfcase>
		</cfswitch>	
			
	</cffunction>
	
	
	<cffunction name="initPermissionCache">
		<cfargument name="bForceRefresh" required="false" default="0">
		<cflock timeout="45" throwontimeout="Yes" type="READONLY" scope="SERVER">
			<cfif StructKeyExists(server.dmSec[application.applicationname],"PermissionsCacheInitialised")>
				<cfset bCacheIsInit=server.dmSec[application.applicationname].PermissionsCacheInitialised>
			<cfelse>
				<cfset bCacheIsInit=0>
			</cfif>
		</cflock>
		<cfif arguments.bForceRefresh>
			<cfset bCacheIsInit = 0>
		</cfif>	
		<cfif NOT bCacheIsInit>
			
			<cfscript>
				oAuth = createObject("component","#application.securitypackagepath#.authorisation");
				oAuth.reInitPermissionsCache();
				server.dmSec[application.applicationname].PermissionsCacheInitialised=1;
			</cfscript>
		</cfif>

	</cffunction>
	
	<cffunction name="initServer" access="public" returntype="boolean">
		<cfargument name="clearExistingCache" type="boolean" default="false" required="false">
		<cfset var bSuccess = 1>
		<cftry>
		<cflock timeout="45" throwontimeout="Yes" type="READONLY" scope="SERVER">
			
			<cfscript>
			serverdmSec_def=0;
			
			if(arguments.clearExistingCache) StructDelete(server, "dmSec");
			
			if(isDefined("server.dmSec")) serverdmSec_def=1;
			
			serverdmSecApplication_def=0;
			if(serverdmSec_def AND StructKeyExists(server.dmSec,application.applicationname)) serverdmSecApplication_def=1;
			
			serverdmSecApplicationGroupMembershipCache_def=0;
			if(serverdmSecApplication_def AND StructKeyExists(server.dmSec[application.applicationname],"groupMembershipCache"))
				serverdmSecApplicationGroupMembershipCache_def=1;
				
			serverdmSecApplicationSecCache_def=0;
			if(serverdmSecApplication_def AND StructKeyExists(server.dmSec[application.applicationname],"dmSecSCache"))
				serverdmSecApplicationSecCache_def=1;
			</cfscript>
			
		</cflock>
			
		<cfif not serverdmSec_def
			OR not serverdmSecApplication_def
			OR not serverdmSecApplicationGroupMembershipCache_def
			OR not serverdmSecApplicationSecCache_def>
		
		<cflock timeout="45" throwontimeout="Yes" type="EXCLUSIVE" scope="SERVER">
			
			<cfscript>
			if( not serverdmSec_def ) server.dmSec=StructNew();
			
			if( not serverdmSecApplication_def ) server.dmSec[application.applicationname]=StructNew();
			
			if( not serverdmSecApplicationGroupMembershipCache_def )
				server.dmSec[application.applicationname].groupMembershipCache=StructNew();
			
			if( not serverdmSecApplicationSecCache_def )
				server.dmSec[application.applicationname].dmSecSCache=StructNew();
			
			</cfscript>
		
		</cflock>
		</cfif>
			<cfcatch>
				<cfset bSuccess = 0>	
			</cfcatch>
		</cftry>

		<cfreturn bSuccess>
	</cffunction>
	
	<cffunction name="initSession" access="public" >
	
	<!--- cf_njSessionStructs --->
		<cflock timeout="45" throwontimeout="Yes" type="READONLY" scope="SESSION">
			<Cfset session_def=0>
			
			<cfif isDefined("session.dmSec")>
				<Cfset session_def=1>
			</cfif>
		
			<cfset navajo_def=0>
			
			<cfif isDefined("session.navajo")>
				<Cfset navajo_def=1>
			</cfif>
			
			<cfset navajosdp_def=0>
			
			<cfif navajo_def AND isDefined("session.navajo.bShowDraftPending")>
				<Cfset navajosdp_def=1>
			</cfif>
			
		</cflock>
		
		<cfif not session_def or not navajo_def or not navajosdp_def>
			<cflock timeout="45" throwontimeout="Yes" type="EXCLUSIVE" scope="SESSION">
			
			<cfif not session_def>
				<cfset session.dmSec=StructNew()>
			</cfif>
			
			<cfif not navajo_def>
				<cfset session.navajo = StructNew()>
			</cfif>
			
			<cfif not navajosdp_def>
				<cfset session.navajo.bShowDraftPending=0>
			</cfif>
			
			</cflock>
		</cfif>
			
	</cffunction>
	
	<cffunction name="initAuthenticationDatabase" hint="Creates all the required tables for daemon authentication">
		<cfargument name="datasource" required="true">
		<cfargument name="bTest" required="false" default="0">
		<cfargument name="bDropTables" required="false" default="true">	

		<!--- TODO: 
				errors generated from these table drops etc should be 
				handled the same way.  Seem to have a different approach 
				for every dbtype. 
				20070908 GB 
		--->

		<cfif arguments.bDropTables AND not isDefined("URL.recreate")>
		<cfset URL.recreate = arguments.bDropTables>
		</cfif>
		
		<cfif arguments.bTest eq 0>
			<cfset url.recreate=1>
			<cfif isDefined("url.recreate") and url.recreate eq 1>
			
				<cfswitch expression="#application.dbtype#">
	
				<cfcase value="ora">
					<cftry>
						<cfquery datasource="#application.dsn#">
						DROP TABLE #application.dbowner#DMGROUP
						</cfquery>
						<cfcatch>
							<cfoutput><b style="color:red;font-size:14pt"> #cfcatch.Detail#</b></cfoutput>
						</cfcatch>
					</cftry>
					<cftry>
						<cfquery datasource="#application.dsn#">
						DROP TABLE #application.dbowner#DMUSER
						</cfquery>
						<cfcatch>
							<cfoutput><b style="color:red;font-size:14pt"> #cfcatch.Detail#</b></cfoutput>
						</cfcatch>
					</cftry>
					<cftry>
						<cfquery datasource="#application.dsn#">
						DROP TABLE #application.dbowner#DMUSERTOGROUP
						</cfquery>
						<cfcatch>
							<cfoutput><b style="color:red;font-size:14pt"> #cfcatch.Detail#</b></cfoutput>
						</cfcatch>
					</cftry>
					<cftry>
						<cfquery datasource="#application.dsn#">
						DROP #application.dbowner#SEQUENCE DMGROUP_SEQ
						</cfquery>
						<cfcatch>
							<cfoutput><b style="color:red;font-size:14pt"> #cfcatch.Detail#</b></cfoutput>
						</cfcatch>
					</cftry>
					<cftry>
						<cfquery datasource="#application.dsn#">
						DROP SEQUENCE #application.dbowner#DMUSER_SEQ
						</cfquery>
						<cfcatch>
							<cfoutput><b style="color:red;font-size:14pt"> #cfcatch.Detail#</b></cfoutput>
						</cfcatch>
					</cftry>
				</cfcase> 
	
				<cfcase value="postgresql">
					<cftry>
						<cfquery datasource="#application.dsn#">
						DROP TABLE #application.dbowner#DMGROUP
						</cfquery>
	
						<cfcatch>
							<cflog text="#cfcatch.message# #cfcatch.detail# [SQL: #cfcatch.sql#]" file="coapi" type="warning" application="yes">
						</cfcatch>
					</cftry>
	
					<cftry>
						<cfquery datasource="#application.dsn#">
						DROP TABLE #application.dbowner#DMUSER
						</cfquery>
	
						<cfcatch>
							<cflog text="#cfcatch.message# #cfcatch.detail# [SQL: #cfcatch.sql#]" file="coapi" type="warning" application="yes">
						</cfcatch>
					</cftry>
	
					<cftry>
						<cfquery datasource="#application.dsn#">
						DROP TABLE #application.dbowner#DMUSERTOGROUP
						</cfquery>
						<cfcatch>
							<cflog text="#cfcatch.message# #cfcatch.detail# [SQL: #cfcatch.sql#]" file="coapi" type="warning" application="yes">
						</cfcatch>
					</cftry>
	
					<cftry>				
						<cfquery datasource="#application.dsn#">
						DROP #application.dbowner#SEQUENCE DMGROUP_SEQ
						</cfquery>
						<cfcatch>
							<cflog text="#cfcatch.message# #cfcatch.detail# [SQL: #cfcatch.sql#]" file="coapi" type="warning" application="yes">
						</cfcatch>
					</cftry>
	
					<cftry>
						<cfquery datasource="#application.dsn#">	
						DROP SEQUENCE #application.dbowner#DMUSER_SEQ
						</cfquery> 
						
						<cfcatch>
							<cflog text="#cfcatch.message# #cfcatch.detail# [SQL: #cfcatch.sql#]" file="coapi" type="warning" application="yes">
						</cfcatch>
					</cftry>
					<!--- <cfoutput><b style="color:red;font-size:14pt"> #cfcatch.Detail#</b></cfoutput> --->
				</cfcase>
				<cfcase value="mysql,mysql5">
					<cfquery datasource="#arguments.datasource#">
					DROP TABLE IF EXISTS #application.dbowner#dmGroup
					</cfquery>
					<cfquery datasource="#arguments.datasource#">
					DROP TABLE IF EXISTS #application.dbowner#dmUser
					</cfquery>
					<cfquery datasource="#arguments.datasource#">
					DROP TABLE IF EXISTS #application.dbowner#dmUserToGroup
					</cfquery>
				</cfcase>
				
				<cfdefaultcase>
					<cfquery name="qCreateTables" datasource="#arguments.datasource#" dbtype="ODBC">
					if exists (select * from sysobjects where id = object_id(N'#application.dbowner#dmGroup') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
					drop table #application.dbowner#dmGroup
					
					if exists (select * from sysobjects where id = object_id(N'#application.dbowner#dmUser') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
					drop table #application.dbowner#dmUser
					
					if exists (select * from sysobjects where id = object_id(N'#application.dbowner#dmUserToGroup') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
					drop table #application.dbowner#dmUserToGroup
				
					-- return recordset to stop CF bombing out?!?
					select count(*) as blah from sysobjects
					</cfquery>
				</cfdefaultcase>	
				
				</cfswitch>	

				<cfoutput><span style="color:orange;">Warning:</span>Dropped all Security tables for '#arguments.datasource#'.<br></cfoutput>
			</cfif>
			
			<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery datasource="#arguments.datasource#">
					CREATE TABLE #application.dbowner#dmGroup(
					GROUPID number NOT NULL,
					GROUPNAME VARCHAR2(64) NOT NULL,
					GROUPNOTES VARCHAR2(256) NULL,
					CONSTRAINT PK_DMGROUP PRIMARY KEY (GROUPID))
				</cfquery>
				
				<cftry>
					<cfquery datasource="#arguments.datasource#">	
						CREATE SEQUENCE #application.dbowner#DMGROUP_SEQ
					</cfquery>	
							
					<cfquery datasource="#arguments.datasource#">	
						CREATE SEQUENCE #application.dbowner#DMUSER_SEQ
					</cfquery>
					<cfcatch></cfcatch>
				</cftry>	
				
				<cfquery datasource="#arguments.datasource#">			
					CREATE TABLE #application.dbowner#dmUser(
					USERID NUMBER  NOT NULL ,
					USERLOGIN VARCHAR2(256) NOT NULL ,
					USERNOTES VARCHAR2(256) NULL ,
					USERPASSWORD VARCHAR2(32) NOT NULL ,
					USERSTATUS VARCHAR2(10) NULL,
					CONSTRAINT PK_DMUSER PRIMARY KEY (USERID))
					
				</cfquery>
				
				<cfquery datasource="#arguments.datasource#">
					CREATE TABLE #application.dbowner#DMUSERTOGROUP (
					USERID NUMBER NOT NULL ,
					GROUPID NUMBER NOT NULL 
					)
				</cfquery>
			
			</cfcase>
			
			<cfcase value="postgresql">
				<cfquery datasource="#arguments.datasource#">
					CREATE TABLE #application.dbowner#dmGroup(
					GROUPID bigserial NOT NULL primary key,
					GROUPNAME VARCHAR(64) NOT NULL,
					GROUPNOTES VARCHAR(256) NULL)
				</cfquery>
								
				<cfquery datasource="#arguments.datasource#">			
					CREATE TABLE #application.dbowner#dmUser(
					USERID bigserial  NOT NULL primary key,
					USERLOGIN VARCHAR(256) NOT NULL ,
					USERNOTES VARCHAR(256) NULL ,
					USERPASSWORD VARCHAR(32) NOT NULL ,
					USERSTATUS VARCHAR(10) NULL)
					
				</cfquery>
				
				<cfquery datasource="#arguments.datasource#">
					CREATE TABLE #application.dbowner#DMUSERTOGROUP (
					USERID bigint NOT NULL ,
					GROUPID bigint NOT NULL 
					)
				</cfquery>
			
			</cfcase>
			
			<cfcase value="mysql,mysql5">
				<cfquery name="qCreateTable_dmGroup" datasource="#arguments.datasource#" dbtype="ODBC">
				CREATE TABLE `#application.dbowner#dmGroup` 
					(`groupid` INT (11) UNSIGNED NOT NULL AUTO_INCREMENT, 
					 `groupName` VARCHAR (64) DEFAULT '0' NOT NULL, 
					 `groupNotes` VARCHAR (255) DEFAULT '0', 
					 PRIMARY KEY(`groupid`)) 
				</cfquery>
				<cfquery name="qCreateTable_dmUser" datasource="#arguments.datasource#" dbtype="ODBC">
					CREATE TABLE `#application.dbowner#dmUser` 
					(`userId` INT (11) UNSIGNED NOT NULL AUTO_INCREMENT, 
					 `userLogin` VARCHAR (255) DEFAULT '0' NOT NULL, 
					 `userNotes` VARCHAR (255) DEFAULT '0', 
					 `userPassword` VARCHAR (32) DEFAULT '0' NOT NULL, 
					 `userStatus` TINYINT (3) UNSIGNED DEFAULT '0' NOT NULL, 
					 PRIMARY KEY(`userId`)) 
				</cfquery>
				<cfquery name="qCreateTable_dmUserToGroup" datasource="#arguments.datasource#" dbtype="ODBC">
					CREATE TABLE `#application.dbowner#dmUserToGroup` 
					(`userId` INT (11) NOT NULL ,
					 `groupId` INT (11) NOT NULL,
					 PRIMARY KEY(`userId`,`groupId`))
				</cfquery>
			</cfcase>
			
			<cfdefaultcase>
				<cfquery name="qCreateTables" datasource="#arguments.datasource#" dbtype="ODBC">
				CREATE TABLE #application.dbowner#dmGroup (
					[groupId] [int] IDENTITY (1, 1) NOT NULL ,
					[groupName] [nvarchar] (450) NOT NULL ,
					[groupNotes] [nvarchar] (450) NULL 
				)
				
				CREATE TABLE #application.dbowner#dmUser (
					[userId] [int] IDENTITY (1, 1) NOT NULL ,
					[userLogin] [nvarchar] (450) NOT NULL ,
					[userNotes] [nvarchar] (450) NULL ,
					[userPassword] [nvarchar] (450) NOT NULL ,
					[userStatus] [int] NOT NULL
				)
				
				CREATE TABLE #application.dbowner#dmUserToGroup (
					[userId] [int] NOT NULL ,
					[groupId] [int] NOT NULL 
				)
			
				 CREATE  UNIQUE  INDEX [idx_groupId] ON #application.dbowner#dmGroup([groupId]) ON [PRIMARY]
				 CREATE  UNIQUE  INDEX [idx_groupName] ON #application.dbowner#dmGroup([groupName]) ON [PRIMARY]
				 CREATE  UNIQUE  INDEX [idx_UserId] ON #application.dbowner#dmUser([userId]) ON [PRIMARY]
				 CREATE  UNIQUE  INDEX [idx_UserLogin] ON #application.dbowner#dmUser([userLogin]) ON [PRIMARY]
				 CREATE  UNIQUE  INDEX [idx_userToGroup] ON #application.dbowner#dmUserToGroup([userId], [groupId]) ON [PRIMARY]
				</cfquery>
			</cfdefaultcase>
			</cfswitch>
			
			<cfoutput><span style="color:green;">OK:</span>Created dmUser, dmGroup, dmUserToGroup, and dmGroupToGroup tables in #arguments.datasource#.<br></cfoutput>
			
		
		</cfif>
	</cffunction>
	
	<cffunction name="initAuthorisationDatabase" hint="Creates all the required tables for daemon authorisation.">
		<cfargument name="datasource" required="true">
		<cfargument name="btest" required="false" default="0">
		<cfargument name="bDropTables" required="false" default="false">

		<cfif arguments.bDropTables AND not isDefined("URL.recreate")><cfset URL.recreate = arguments.bDropTables></cfif>

		<cfif arguments.bTest eq 0>
			<cfif isDefined("url.recreate") and url.recreate eq 1>
			<cfswitch expression="#application.dbtype#">

				<cfcase value="ora">
					<cftry>
						<cfquery datasource="#application.dsn#">
						DROP TABLE #application.dbowner#dmExternalGroupToPolicyGroup
						</cfquery>
						<cfcatch type="any">
							<cfoutput><b style="color:red;font-size:14pt"> #cfcatch.Detail#</b></cfoutput> 
						</cfcatch>
					</cftry>
					
					<cftry>
						<cfquery datasource="#application.dsn#">
						DROP TABLE #application.dbowner#dmPolicyGroup
						</cfquery>
						<cfcatch type="any">
							<cfoutput><b style="color:red;font-size:14pt"> #cfcatch.Detail#</b></cfoutput> 
						</cfcatch>
					</cftry>
					
					<cftry>
						<cfquery datasource="#application.dsn#">
						DROP TABLE #application.dbowner#dmPermissionBarnacle
						</cfquery>
						<cfcatch type="any">
							<cfoutput><b style="color:red;font-size:14pt"> #cfcatch.Detail#</b></cfoutput> 
						</cfcatch>
					</cftry>
					
					<cftry>
						<cfquery datasource="#application.dsn#">
						DROP TABLE #application.dbowner#dmPermission
						</cfquery>
						<cfcatch type="any">
							<cfoutput><b style="color:red;font-size:14pt"> #cfcatch.Detail#</b></cfoutput> 
						</cfcatch>
					</cftry>
					
					<cftry>
						<cfquery datasource="#application.dsn#">
						DROP SEQUENCE #application.dbowner#DMPOLICYGROUP_SEQ
						</cfquery>
						<cfcatch type="any">
							<cfoutput><b style="color:red;font-size:14pt"> #cfcatch.Detail#</b></cfoutput> 
						</cfcatch>
					</cftry>
					
					<cftry>
						<cfquery datasource="#application.dsn#">
						DROP SEQUENCE #application.dbowner#DMPERMISSION_SEQ
						</cfquery>
						<cfcatch type="any">
							<cfoutput><b style="color:red;font-size:14pt"> #cfcatch.Detail#</b></cfoutput> 
						</cfcatch>
					</cftry>
				</cfcase>
				
				<cfcase value="postgresql">
					<cftry>
						<cfquery datasource="#application.dsn#">
							DROP TABLE #application.dbowner#dmExternalGroupToPolicyGroup
						</cfquery>
						<cfquery datasource="#application.dsn#">
							DROP TABLE #application.dbowner#dmPolicyGroup
						</cfquery>
						<cfquery datasource="#application.dsn#">
							DROP TABLE #application.dbowner#dmPermissionBarnacle
						</cfquery>
						<cfquery datasource="#application.dsn#">
							DROP TABLE #application.dbowner#dmPermission
						</cfquery>
						<cfcatch>
						
						</cfcatch>
					</cftry>
				</cfcase>
				
				<cfcase value="mysql,mysql5">
					<cftry>
						<cfquery datasource="#application.dsn#">
							DROP TABLE IF EXISTS #application.dbowner#dmExternalGroupToPolicyGroup
						</cfquery>
						<cfquery datasource="#application.dsn#">
							DROP TABLE IF EXISTS #application.dbowner#dmPolicyGroup
						</cfquery>
						<cfquery datasource="#application.dsn#">
							DROP TABLE IF EXISTS #application.dbowner#dmPermissionBarnacle
						</cfquery>
						<cfquery datasource="#application.dsn#">
							DROP TABLE IF EXISTS #application.dbowner#dmPermission
						</cfquery>
						<cfcatch>
						
						</cfcatch>
					</cftry>
				</cfcase>
				
				<cfdefaultcase>
					<cfquery name="qCreateTables" datasource="#arguments.datasource#" dbtype="ODBC">
					if exists (select * from sysobjects where id = object_id(N'#application.dbowner#dmExternalGroupToPolicyGroup') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
					drop table #application.dbowner#dmExternalGroupToPolicyGroup
					
					if exists (select * from sysobjects where id = object_id(N'#application.dbowner#dmPolicyGroup') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
					drop table #application.dbowner#dmPolicyGroup
					
					if exists (select * from sysobjects where id = object_id(N'#application.dbowner#dmPermissionBarnacle') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
					drop table #application.dbowner#dmPermissionBarnacle
					
					if exists (select * from sysobjects where id = object_id(N'#application.dbowner#dmPermission') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
					drop table #application.dbowner#dmPermission
				
					-- return recordset to stop CF bombing out?!?
					select count(*) as blah from sysobjects
					</cfquery>
				</cfdefaultcase>
			</cfswitch>
			
			<cfoutput><span style="color:orange;">Warning:</span>Dropped all Security tables for '#arguments.datasource#'.<br></cfoutput>
		
			</cfif>
			
			<cfswitch expression="#application.dbtype#">
				<cfcase value="ora">
					<cfquery datasource="#application.dsn#">
						CREATE TABLE #application.dbowner#dmExternalGroupToPolicyGroup
						(
							POLICYGROUPID NUMBER NOT NULL ,
							EXTERNALGROUPUSERDIRECTORY VARCHAR2(256) NOT NULL ,
							EXTERNALGROUPNAME VARCHAR2(256) NOT NULL 
						)
					</cfquery>	
					<cfquery datasource="#application.dsn#">
						CREATE TABLE #application.dbowner#dmPolicyGroup
						(
							PolicyGroupId NUMBER NOT NULL ,
							PolicyGroupName VARCHAR2(50) NOT NULL,
							PolicyGroupNotes VARCHAR2(256) NULL,
							CONSTRAINT PK_DMPOLICYGROUP PRIMARY KEY (POLICYGROUPID)
						)
						
					</cfquery>	
					<cfquery datasource="#application.dsn#">				
						CREATE TABLE #application.dbowner#dmPermissionBarnacle
						(
							PERMISSIONID NUMBER NOT NULL ,
							POLICYGROUPID NUMBER NOT NULL ,
							REFERENCE1 VARCHAR2(64) NOT NULL ,
							STATUS NUMBER NOT NULL 
						)
					</cfquery>	
					<cfquery datasource="#application.dsn#">				
						CREATE TABLE #application.dbowner#dmPermission
						(
							PermissionId NUMBER NOT NULL ,
							PermissionName VARCHAR2(64) NOT NULL ,
							PermissionNotes VARCHAR2(256) NULL ,
							PermissionType VARCHAR2(256) NOT NULL,
							CONSTRAINT PK_DMPERMISSION PRIMARY KEY (permissionId)
						)
					</cfquery>	

					<cftry>
						<cfquery datasource="#arguments.datasource#">	
							CREATE SEQUENCE #application.dbowner#DMPERMISSION_SEQ MINVALUE 500
						</cfquery>
						<cfquery datasource="#arguments.datasource#">	
							CREATE SEQUENCE #application.dbowner#DMPOLICYGROUP_SEQ
						</cfquery>
						<cfcatch></cfcatch>
					</cftry>
				</cfcase>
				
				<cfcase value="postgresql">
					<cfquery datasource="#application.dsn#">
						CREATE TABLE #application.dbowner#dmExternalGroupToPolicyGroup
						(
							POLICYGROUPID bigint NOT NULL ,
							EXTERNALGROUPUSERDIRECTORY VARCHAR(256) NOT NULL ,
							EXTERNALGROUPNAME VARCHAR(256) NOT NULL 
						)
					</cfquery>	
					<cfquery datasource="#application.dsn#">
						CREATE TABLE #application.dbowner#dmPolicyGroup
						(
							PolicyGroupId bigserial NOT NULL primary key,
							PolicyGroupName VARCHAR(50) NOT NULL,
							PolicyGroupNotes VARCHAR(256) NULL
						)
						
					</cfquery>	
					<cfquery datasource="#application.dsn#">				
						CREATE TABLE #application.dbowner#dmPermissionBarnacle
						(
							PERMISSIONID bigint NOT NULL ,
							POLICYGROUPID bigint NOT NULL ,
							REFERENCE1 VARCHAR(64) NOT NULL ,
							STATUS bigint NOT NULL 
						)
					</cfquery>	
					<cfquery datasource="#application.dsn#">				
						CREATE TABLE #application.dbowner#dmPermission
						(
							PermissionId bigserial NOT NULL primary key,
							PermissionName VARCHAR(64) NOT NULL ,
							PermissionNotes VARCHAR(256) NULL ,
							PermissionType VARCHAR(256) NOT NULL
						)
					</cfquery>
					<!--- update permission sequence --->	
					<cfquery name="update" datasource="#application.dsn#">
						SELECT setval('#application.dbowner#dmPermission_PermissionId_seq', 500);
					</cfquery>
				</cfcase>
				
				<cfcase value="mysql,mysql5">
				
					<cfquery datasource="#application.dsn#">
						CREATE TABLE `#application.dbowner#dmExternalGroupToPolicyGroup`
						(
							`POLICYGROUPID` INT (11) UNSIGNED DEFAULT '0' NOT NULL,
							`EXTERNALGROUPUSERDIRECTORY` VARCHAR (255) NOT NULL ,
							`EXTERNALGROUPNAME` VARCHAR (255) NOT NULL
						)
					</cfquery>	
					<cfquery datasource="#application.dsn#">
						CREATE TABLE `#application.dbowner#dmPolicyGroup`
						(
							`PolicyGroupId` INT (11) NOT NULL auto_increment,
							`PolicyGroupName` VARCHAR (50) NOT NULL,
							`PolicyGroupNotes` VARCHAR (255) NULL,
							PRIMARY KEY(`POLICYGROUPID`)
						)
						
					</cfquery>	
					<cfquery datasource="#application.dsn#">				
						CREATE TABLE `#application.dbowner#dmPermissionBarnacle`
						(
							`PERMISSIONID` INT (11) NOT NULL ,
							`POLICYGROUPID` INT (11) NOT NULL ,
							`REFERENCE1` VARCHAR (64) NOT NULL ,
							`STATUS` INT (11) NOT NULL 
						)
					</cfquery>	
					<cfquery datasource="#application.dsn#">				
						CREATE TABLE `#application.dbowner#dmPermission`
						(
							`PermissionId` INT (11) NOT NULL auto_increment,
							`PermissionName` VARCHAR (64) NOT NULL ,
							`PermissionNotes` VARCHAR (255) NULL ,
							`PermissionType` VARCHAR (255) NOT NULL,
							PRIMARY KEY(`permissionId`)
						)
					</cfquery>	
				</cfcase>
				
				
				<cfdefaultcase>
					<cfquery name="qCreateTables" datasource="#arguments.datasource#" dbtype="ODBC">
					CREATE TABLE #application.dbowner#dmExternalGroupToPolicyGroup
					(
						[PolicyGroupId] [int] NOT NULL ,
						[ExternalGroupUserDirectory] [varchar] (256) NOT NULL ,
						[ExternalGroupName] [varchar] (256) NOT NULL, 
				
					)
					
					CREATE TABLE #application.dbowner#dmPolicyGroup
					(
						[PolicyGroupId] [int] IDENTITY (1, 1) NOT NULL ,
						[PolicyGroupName] [varchar] (50) NOT NULL,
						[PolicyGroupNotes] [varchar] (256) NULL
						
					)
					
					CREATE TABLE #application.dbowner#dmPermissionBarnacle
					(
						[PermissionId] [int] NOT NULL ,
						[PolicyGroupId] [int] NOT NULL ,
						[Reference1] [varchar] (64) NOT NULL ,
						[Status] [int] NOT NULL 
					)
					
					CREATE TABLE #application.dbowner#dmPermission
					(
						[PermissionId] [int] IDENTITY (1, 1) NOT NULL ,
						[PermissionName] [varchar] (64) NOT NULL ,
						[PermissionNotes] [varchar] (256) NULL ,
						[PermissionType] [varchar] (256) NOT NULL
					)
					
					CREATE UNIQUE INDEX [idx_Permission] ON #application.dbowner#dmPermission([PermissionName], [PermissionType] )
					CREATE UNIQUE INDEX [idx_PermissionId] ON #application.dbowner#dmPermission([PermissionId])
					CREATE UNIQUE INDEX [idx_Barnacle] ON #application.dbowner#dmPermissionBarnacle([PermissionId], [Reference1], [PolicyGroupId])
					CREATE UNIQUE INDEX [idx_ExternalGroupToPolicyGroup] ON #application.dbowner#dmExternalGroupToPolicyGroup([PolicyGroupId], [ExternalGroupUserDirectory], [ExternalGroupName])
					CREATE UNIQUE INDEX [idx_PolicyGroupId] ON #application.dbowner#dmPolicyGroup([PolicyGroupId])
					</cfquery>
				</cfdefaultcase>
			</cfswitch>
			<cfoutput><span style="color:green;">OK:</span>Created dmExternalGroupToPolicyGroup, dmPolicyGroup, dmPermissionBarnacle tables in #arguments.datasource#.<br></cfoutput>
	
								
		</cfif>
			
	
	</cffunction>	
	
	
	
	
</cfcomponent>