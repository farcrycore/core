<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_workflow/getLockedObjects.cfm,v 1.1 2005/10/24 06:10:13 guy Exp $
$Author: guy $
$Date: 2005/10/24 06:10:13 $
$Name: milestone_3-0-1 $
$Revision: 1.1 $

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
<!--- <cfset stLocal.oNav = createObject("component",application.types.dmNavigation.typePath)> --->
<cfset stLocal.sql = "">
<cfset stLocal.lcontent_type = "">
<!--- <cfif arguments.stForm.lcontent_type EQ "all"> --->
	<cfloop item="stLocal.iType" collection="#application.types#">
		<cfif StructKeyExists(application.types[stLocal.iType].stProps,"lockedby")>
			<cfset stLocal.lcontent_type = ListAppend(stLocal.lcontent_type,stLocal.iType)>
		</cfif>
	</cfloop>
<!--- <cfelse>
	<cfset stLocal.lcontent_type = arguments.stForm.lcontent_type>
</cfif> --->

<!--- Get all objects types that have status option [genrate SQL] --->
<cfset stLocal.iCounter = 0>
<cfloop index="stLocal.type" list="#stLocal.lcontent_type#">
	<cfif structkeyexists(application.types[stLocal.type].stProps,"status")> <!--- AND structKeyExists(application.types[stLocal.type],"bUseInTree") AND application.types[i].bUseInTree --->
		<!--- Get all objects that have status of pending --->
		<cfif stLocal.sql NEQ "">
			<cfset stLocal.sql = stLocal.sql & " UNION ">
		</cfif>
		<cfif structKeyExists(application.types[stLocal.type].stProps,"VersionID")>
			<cfset stLocal.sql = stLocal.sql & "SELECT t_#stLocal.iCounter#.objectID, t_#stLocal.iCounter#.label as title, t_#stLocal.iCounter#.createdby, p_#stLocal.iCounter#.emailAddress as createdby_email, t_#stLocal.iCounter#.datetimelastUpdated, t_#stLocal.iCounter#.versionID, '#stLocal.type#' as typename FROM #application.dbowner##stLocal.type# t_#stLocal.iCounter#, #application.dbowner#dmProfile p_#stLocal.iCounter# WHERE p_#stLocal.iCounter#.userName = t_#stLocal.iCounter#.createdBy AND lower(t_#stLocal.iCounter#.lockedby) = '#LCASE(arguments.lockedby)#'">
		<cfelse>
			<cfset stLocal.sql = stLocal.sql & "SELECT t_#stLocal.iCounter#.objectID, t_#stLocal.iCounter#.label as title, t_#stLocal.iCounter#.createdby, p_#stLocal.iCounter#.emailAddress as createdby_email, t_#stLocal.iCounter#.datetimelastUpdated,'' as versionID, '#stLocal.type#' as typename FROM #application.dbowner##stLocal.type# t_#stLocal.iCounter#, #application.dbowner#dmProfile p_#stLocal.iCounter# WHERE p_#stLocal.iCounter#.userName = t_#stLocal.iCounter#.createdBy AND lower(t_#stLocal.iCounter#.lockedby) = '#LCASE(arguments.lockedby)#'">
		</cfif>	
	</cfif>
	<cfset stLocal.iCounter = stLocal.iCounter + 1>
</cfloop>

<cftry>
	<!--- returns all pending objects --->
	<cfquery name="stLocal.qList_unordered" datasource="#application.dsn#">
	#preserveSingleQuotes(stLocal.sql)#
	</cfquery>

	<cfquery name="stReturn.qList" dbtype="query">
	SELECT	* FROM stLocal.qList_unordered ORDER BY datetimelastUpdated DESC
	</cfquery>

	<!--- check parent permissions --->
	<cfcatch>
		<cfset stReturn.bSuccess = 0>
		<cfset stReturn.message = "#cfcatch.message#: #cfcatch.detail#<br />">
	</cfcatch>
</cftry>
