<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_workflow/getObjectsPendingApproval.cfm,v 1.25.2.6 2006/04/14 06:50:41 geoff Exp $
$Author: geoff $
$Date: 2006/04/14 06:50:41 $
$Name: p300_b113 $
$Revision: 1.25.2.6 $

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
		<!--- 	todo: 
				bad hack.. to get around content types using status as a property but not flagging it as string
				hack allows you to set metadata in the content type of bSystem="true" to exclude it from being addressed here
				need to just rip out this cancer along with farcry.workflow GB 20060414
		 --->	
		<cfif NOT structKeyExists(application.types[stLocal.iType],"bSystem")>
				<cfset application.types[stLocal.iType].bSystem="false">
		</cfif>
	    <cfif StructKeyExists(application.types[stLocal.iType].stProps,"status") AND NOT application.types[stLocal.iType].bSystem>
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
					<cfset stLocal.parentid = application.factory.oTree.getParentID(objectid=stLocal.qList.objectid,dsn=application.dsn).parentID>
				</cfcase>

				<cfdefaultcase>
					<cfif Len(stLocal.qList.versionid) EQ 35>
						<cfset stLocal.qParent = stLocal.oNav.getParent(objectid=stLocal.qList.versionid,dsn=application.dsn)>
					<cfelse>
						<cfset stLocal.qParent = stLocal.oNav.getParent(objectid=stLocal.qList.objectid,dsn=application.dsn)>					
					</cfif>
					
					<cfif stLocal.qParent.recordCount GT 0>
						<cfset stLocal.parentid = stLocal.qParent.parentid>
					<cfelse>
						<cfset stLocal.parentid = stLocal.qList.objectid>
					</cfif>
				</cfdefaultcase>
			</cfswitch>

			<!--- check permissions --->
			<cfif structkeyexists(application.types[stLocal.qList.typename],"bUseInTree") AND application.types[stLocal.qList.typename].bUseInTree>
				<!--- if trre item eg.dmhtml --->
				<cfset stLocal.bCanApprove = application.security.checkPermission(permission="approve",object=stLocal.parentid) />
			<cfelse>
				<!--- check non tree item (BUT standard farcry items) --->
				<cfset stLocal.permissionName = "#stLocal.qList.typename#Approve">
				<cfset stLocal.permissionName = Right(stLocal.permissionName,Len(stLocal.permissionName)-2)>
				<cfif StructKeyExists(application.permission.policyGroup,stLocal.permissionName)>
					<cfset stLocal.bCanApprove = application.security.checkPermission(permission=stLocal.permissionName)>				
				<cfelse>
					<!--- Try again minus the assumption were trimming to chars --->
					<cfset stLocal.permissionName = "#stLocal.qList.typename#Approve">
					<cfif StructKeyExists(application.permission.policyGroup,stLocal.permissionName)>
						<cfset stLocal.bCanApprove = application.security.checkPermission(permission=stLocal.permissionName)>				
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

