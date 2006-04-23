<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_workflow/getUserDraftObjects.cfm,v 1.6 2003/09/10 12:21:48 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 12:21:48 $
$Name: b201 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: gets draft objects for user $
$TODO: $

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
		<cfif i eq "dmHTML">
		   <cfset sql = "SELECT objectID, title, versionID, datetimelastUpdated FROM #application.dbowner##i# WHERE status = 'draft' AND rtrim(versionID) = '' AND (createdby = '#arguments.userLogin#' OR lastupdatedby = '#arguments.userLogin#') ORDER BY datetimelastUpdated DESC">
        <cfelse>
		   <cfset sql = "SELECT objectID, title, '' as versionID, datetimelastUpdated FROM #application.dbowner##i# WHERE status = 'draft' AND (createdby = '#arguments.userLogin#' OR lastupdatedby = '#arguments.userLogin#') ORDER BY datetimelastUpdated DESC">
        </cfif>

        <cfquery name="qGetObjects" datasource="#application.dsn#">#preserveSingleQuotes(sql)#</cfquery>
				
		<!--- Create structure for object details to be outputted later --->
		<cfif qGetObjects.recordcount gt 0>
			<cfset newRows = QueryAddRow(qDraftObjects,qGetObjects.recordcount)>
			<cfloop query="qGetObjects">
				<cfset rowCounter = rowCounter + 1>
								
				<cfset temp = querySetCell(qDraftObjects,"ObjectId", objectId,rowCounter)>
				<cfif title neq "">
					<cfset temp = querySetCell(qDraftObjects,"objectTitle", title,rowCounter)>
				<cfelse>
					<cfset temp = querySetCell(qDraftObjects,"objectTitle", "<em>undefined</em>",rowCounter)>
				</cfif>
				<cfset temp = querySetCell(qDraftObjects,"objectLastUpdated", datetimelastUpdated,rowCounter)>
				<cfset temp = querySetCell(qDraftObjects,"objectType", I,rowCounter)>
				
				<cfif i eq "dmHTML">
					<!--- get object parent --->
					<cfquery name="qGetParent" datasource="#application.dsn#">
					SELECT objectID FROM #application.dbowner#dmNavigation_aObjectIDs
					WHERE data = '#objectID#'
					</cfquery>
					<cfset temp = querySetCell(qDraftObjects,"objectParent", qGetParent.objectid,rowCounter)>
				<cfelse>
					<cfset temp = querySetCell(qDraftObjects,"objectParent", 0,rowCounter)>
				</cfif>
			</cfloop>
		</cfif>
</cfloop>

<cfquery name="qDraftObjects2" dbtype="query">
SELECT * FROM qDraftObjects
ORDER BY objectLastUpdated DESC
</cfquery>
