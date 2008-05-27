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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_workflow/getUserDraftObjects.cfm,v 1.10 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: gets draft objects for user $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- initialize query --->
<cfset qDraftObjects = queryNew("objectId,objectTitle,createdBy,objectLastUpdated,objectType,objectParent")>
<cfset rowCounter = 0>

<!--- Get all objects types that have status option --->
<cfloop list="#arguments.objectTypes#" index="i">
		<!--- check if type has versioning --->
		<cfif structKeyExists(application.types[i].stProps, "versionID")>
		   <cfset sql = "SELECT objectID, title, versionID, datetimelastUpdated FROM #application.dbowner##i# WHERE status = 'draft' AND (createdby = '#arguments.userLogin#' OR lastupdatedby = '#arguments.userLogin#') ORDER BY datetimelastUpdated DESC">
        <cfelse>
		   <cfset sql = "SELECT objectID, title, '' as versionID, datetimelastUpdated FROM #application.dbowner##i# WHERE status = 'draft' AND (createdby = '#arguments.userLogin#' OR lastupdatedby = '#arguments.userLogin#') ORDER BY datetimelastUpdated DESC">
        </cfif>

        <cfquery name="qGetObjects" datasource="#application.dsn#">#preserveSingleQuotes(sql)#</cfquery>
				
		<!--- Create structure for object details to be outputted later --->
		<cfif qGetObjects.recordcount gt 0>
			<cfset newRows = QueryAddRow(qDraftObjects,qGetObjects.recordcount)>
			<cfloop query="qGetObjects">
				<cfset rowCounter = rowCounter + 1>
								
				<cfset querySetCell(qDraftObjects,"ObjectId", objectId,rowCounter)>
				<cfif title neq "">
					<cfset querySetCell(qDraftObjects,"objectTitle", title,rowCounter)>
				<cfelse>
					<cfset querySetCell(qDraftObjects,"objectTitle", "<em>undefined</em>",rowCounter)>
				</cfif>
				<cfset querySetCell(qDraftObjects,"objectLastUpdated", datetimelastUpdated,rowCounter)>
				<cfset querySetCell(qDraftObjects,"objectType", I,rowCounter)>
				
				<!--- check if object is used in tree --->
				<cfif structKeyExists(application.types[i],"bUseInTree") and application.types[i].bUseInTree>
					<!--- get object parent --->
					<cfquery name="qGetParent" datasource="#application.dsn#">
					SELECT parentid FROM #application.dbowner#dmNavigation_aObjectIDs
					WHERE data = 
						<!--- check for versioning --->
						<cfif len(qGetObjects.versionId)>
							'#qGetObjects.versionId#'
						<cfelse>
							'#qGetObjects.objectID#'
						</cfif>
					</cfquery>
					<cfset querySetCell(qDraftObjects,"objectParent", qGetParent.objectid,rowCounter)>
				<cfelse>
					<cfset querySetCell(qDraftObjects,"objectParent", 0,rowCounter)>
				</cfif>
			</cfloop>
		</cfif>
</cfloop>

<cfquery name="qDraftObjects2" dbtype="query">
SELECT * FROM qDraftObjects
ORDER BY objectLastUpdated DESC
</cfquery>
