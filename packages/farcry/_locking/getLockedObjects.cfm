<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_locking/getLockedObjects.cfm,v 1.6 2004/01/11 21:56:13 brendan Exp $
$Author: brendan $
$Date: 2004/01/11 21:56:13 $
$Name: milestone_2-1-2 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: returns all locked objects $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- initialize query --->
<cfset qLockedObjects = queryNew("objectId,objectTitle,createdBy,objectLastUpdated,objectType,objectParent")>
<cfset rowCounter = 0>

<!--- Loop through all objects that are locked by specified user --->
<cfloop list="#arguments.types#" index="i">
		
	<cfset sql = "select distinct objectID,label, datetimelastUpdated From #application.dbowner##i# WHERE locked = 1 and lockedby = '#arguments.userlogin#' order by datetimelastUpdated desc">
	
	<cftry>
		<cfquery name="qGetObjects" datasource="#application.dsn#">
			#preserveSingleQuotes(sql)#
		</cfquery>		
				
		<!--- Create structure for object details to be outputted later --->
		<cfif qGetObjects.recordcount gt 0>
			<cfset newRows = QueryAddRow(qLockedObjects,qGetObjects.recordcount)>
			<cfloop query="qGetObjects">
				<cfset rowCounter = rowCounter + 1>
								
				<cfset temp = querySetCell(qLockedObjects,"ObjectId", objectId,rowCounter)>
				<cfif label neq "">
					<cfset temp = querySetCell(qLockedObjects,"objectTitle", label,rowCounter)>
				<cfelse>
					<cfset temp = querySetCell(qLockedObjects,"objectTitle", "<em>undefined</em>",rowCounter)>
				</cfif>
				<cfset temp = querySetCell(qLockedObjects,"objectLastUpdated", datetimelastUpdated,rowCounter)>
				<cfset temp = querySetCell(qLockedObjects,"objectType", I,rowCounter)>
				
				<cfif structKeyExists(application.types[i], "bUseInTree") and application.types[i].bUseInTree>
					<!--- get object parent --->
					<cfquery name="qGetParent" datasource="#application.dsn#">
						SELECT objectid FROM #application.dbowner#dmNavigation_aObjectIDs 
						WHERE data = '#objectId#'	
					</cfquery>
					<cfset temp = querySetCell(qLockedObjects,"objectParent", qGetParent.objectid,rowCounter)>
				<cfelse>
					<cfset temp = querySetCell(qLockedObjects,"objectParent", 0,rowCounter)>
				</cfif>
			</cfloop>
		</cfif>
		<cfcatch></cfcatch>
	</cftry>
</cfloop>

<cfquery name="qLockedObjects2" dbtype="query">
	select * 
	from qLockedObjects
	order by objectLastUpdated desc
</cfquery>
