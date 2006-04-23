<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_workflow/getObjectsPendingApproval.cfm,v 1.25.2.5 2006/02/10 06:11:45 paul Exp $
$Author: paul $
$Date: 2006/02/10 06:11:45 $
$Name: milestone_3-0-1 $
$Revision: 1.25.2.5 $

|| DESCRIPTION || 
$Description: get obejcts pending approval$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- pending objects struct --->
<!--- <cfset stPendingObjects = structNew()> --->
<cfset stLocal.oNav = createObject("component",application.types.dmNavigation.typePath)>
<cfset stLocal.sql = "">
<cfset stLocal.lcontent_type = "">
<cfif arguments.stForm.lcontent_type EQ "all">
	<cfloop item="stLocal.iType" collection="#application.types#">
		<cfif StructKeyExists(application.types[stLocal.iType].stProps,"status")>
			<cfset stLocal.lcontent_type = ListAppend(stLocal.lcontent_type,stLocal.iType)>
		</cfif>
	</cfloop>
<cfelse>
	<cfset stLocal.lcontent_type = arguments.stForm.lcontent_type>
</cfif>


<!--- Get all objects types that have status option [genrate SQL] --->
<cfset stLocal.iCounter = 0>
<cfloop index="stLocal.type" list="#stLocal.lcontent_type#">
	<cfif structkeyexists(application.types[stLocal.type].stProps,"status")> <!--- AND structKeyExists(application.types[stLocal.type],"bUseInTree") AND application.types[i].bUseInTree --->
		<!--- Get all objects that have status of pending --->
		<cfif stLocal.sql NEQ "">
			<cfset stLocal.sql = stLocal.sql & " UNION ">
		</cfif>
		<cfif structKeyExists(application.types[stLocal.type].stProps,"VersionID")>
			<cfset stLocal.sql = stLocal.sql & "SELECT t_#stLocal.iCounter#.objectID, t_#stLocal.iCounter#.label as title, t_#stLocal.iCounter#.createdby,t_#stLocal.iCounter#.lastupdatedby, p_#stLocal.iCounter#.emailAddress as createdby_email, t_#stLocal.iCounter#.datetimelastUpdated, t_#stLocal.iCounter#.versionID, '#stLocal.type#' as typename FROM #application.dbowner##stLocal.type# t_#stLocal.iCounter#, #application.dbowner#dmProfile p_#stLocal.iCounter# WHERE p_#stLocal.iCounter#.userName = t_#stLocal.iCounter#.lastupdatedBy  AND   t_#stLocal.iCounter#.status = '#arguments.stForm.content_status#'">

		<cfelse>
			<cfset stLocal.sql = stLocal.sql & "SELECT t_#stLocal.iCounter#.objectID, t_#stLocal.iCounter#.label as title,t_#stLocal.iCounter#.lastupdatedby, t_#stLocal.iCounter#.createdby, p_#stLocal.iCounter#.emailAddress as createdby_email, t_#stLocal.iCounter#.datetimelastUpdated,'' as versionID, '#stLocal.type#' as typename FROM #application.dbowner##stLocal.type# t_#stLocal.iCounter#, #application.dbowner#dmProfile p_#stLocal.iCounter# WHERE p_#stLocal.iCounter#.userName = t_#stLocal.iCounter#.lastupdatedBy AND  t_#stLocal.iCounter#.status = '#arguments.stForm.content_status#'">
		</cfif>	
	</cfif>
	<cfset stLocal.iCounter = stLocal.iCounter + 1>
</cfloop>


 <cftry> 
	<!--- returns all pending objects --->
	<cfquery name="stLocal.qList_unordered" datasource="#application.dsn#">
	#preserveSingleQuotes(stLocal.sql)#
	</cfquery>
	
	<cfquery name="stLocal.qList" dbtype="query">
	SELECT	* FROM stLocal.qList_unordered
	<cfif  structKeyExists(arguments.stForm,"lastupdatedby")> <!--- If lastupdatedby has been provided in args - we want to filter by lastupdatedby --->
	WHERE lastupdatedby = '#arguments.stForm.lastupdatedby#'	
	</cfif>
	ORDER BY datetimelastUpdated DESC
	</cfquery>
	
	<!--- <cfdump var="#stLocal.qList#"> --->
	
	
	

	<cfset stLocal.lColumns = stLocal.qList.columnList>
	<cfset stReturn.qList = QueryNew("#stLocal.lColumns#")>
	<!--- check parent permissions --->
	<cfset stLocal.iCounter = 0>

	<cfif stLocal.qList.recordcount GT 0>
		<cfloop query="stLocal.qList">
			<!--- only return the desired amount of max records --->
			<cfif IsNumeric(arguments.stForm.maxReturnRecords) AND stLocal.iCounter GTE arguments.stForm.maxReturnRecords>
				<cfbreak>
			</cfif>

			<cfswitch expression="#stLocal.qList.typename#">
				<cfcase value="dmNavigation">
					<cfset stLocal.parentid = request.factory.oTree.getParentID(objectid=stLocal.qList.objectid,dsn=application.dsn).parentID>
				</cfcase>

				<cfdefaultcase>
					<cfif Len(stLocal.qList.versionid) EQ 35>
						<cfset stLocal.qParent = stLocal.oNav.getParent(objectid=stLocal.qList.versionid,dsn=application.dsn)>
					<cfelse>
						<cfset stLocal.qParent = stLocal.oNav.getParent(objectid=stLocal.qList.objectid,dsn=application.dsn)>					
					</cfif>
					
					<cfif stLocal.qParent.recordCount GT 0>
						<cfset stLocal.parentid = stLocal.qParent.objectid>
					<cfelse>
						<cfset stLocal.parentid = stLocal.qList.objectid>
					</cfif>
				</cfdefaultcase>
			</cfswitch>

			<!--- check permissions --->
			<cfif structkeyexists(application.types[stLocal.qList.typename],"bUseInTree") AND application.types[stLocal.qList.typename].bUseInTree>
				<!--- if trre item eg.dmhtml --->
				<cfset stLocal.bCanApprove = request.dmSec.oAuthorisation.checkInheritedPermission(permissionName="approve",objectid=stLocal.parentid)>
			<cfelse>
				<!--- check non tree item (BUT standard farcry items) --->
				<cfset stLocal.permissionName = "#stLocal.qList.typename#Approve">
				<cfset stLocal.permissionName = Right(stLocal.permissionName,Len(stLocal.permissionName)-2)>
				<cfif StructKeyExists(application.permission.policyGroup,stLocal.permissionName)>
					<cfset stLocal.bCanApprove = request.dmSec.oAuthorisation.checkPermission(permissionName=stLocal.permissionName,reference="PolicyGroup")>				
				<cfelse>
					<!--- Try again minus the assumption were trimming to chars --->
					<cfset stLocal.permissionName = "#stLocal.qList.typename#Approve">
					<cfif StructKeyExists(application.permission.policyGroup,stLocal.permissionName)>
						<cfset stLocal.bCanApprove = request.dmSec.oAuthorisation.checkPermission(permissionName=stLocal.permissionName,reference="PolicyGroup")>				
					<cfelse>	
						<cfset stLocal.bCanApprove = 0>
					</cfif>	
				</cfif>
			</cfif>

			<!--- Append content for object details to be outputted later - note object must not be in trash either --->
			<cfif stLocal.bCanApprove EQ 1 AND stLocal.parentid NEQ application.navid.rubbish>
				<cfset QueryAddRow(stReturn.qList)>
				<cfset stLocal.iCounter = stLocal.iCounter + 1>

				<cfloop index="stLocal.columnName" list="#stLocal.lColumns#">
					<cfset QuerySetCell(stReturn.qList,stLocal.columnName,Evaluate("stLocal.qList.#stLocal.columnName#"))>
				</cfloop>

				<cfif structKeyExists(application.types[stLocal.qList.typename].stProps,"VersionID") AND Len(stLocal.qList.versionid) EQ 35>
					<!--- We check for drafts --->
					<cfquery name="stLocal.qDraft" datasource="#application.dsn#">
					SELECT	t.objectID,
							t.label as title,
							t.createdby,
							p.emailAddress as createdby_email,
							t.datetimelastUpdated,
							t.versionID,
							'#stLocal.qList.typename#' as typename
					FROM 	#application.dbowner##stLocal.qList.typename# t, #application.dbowner#dmProfile p 
					WHERE 	p.userName = t.lastupdatedBy
						AND t.status = 'pending'
						AND t.versionID = '#stLocal.qList.objectID#'
					</cfquery>
					<cfif stLocal.qDraft.recordcount EQ 1>
						<cfloop index="stLocal.columnName" list="#stLocal.lColumns#">
							<cfset QuerySetCell(stReturn.qList,stLocal.columnName,Evaluate("stLocal.qList.#stLocal.columnName#"))>
						</cfloop>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
	</cfif>

	<cfcatch>
		<cfset stReturn.bSuccess = 0>
		<cfset stReturn.message = "#cfcatch.message#: #cfcatch.detail#<br />">
	</cfcatch>
</cftry>
