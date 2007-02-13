<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_locking/getLockedObjects.cfm,v 1.9 2005/10/06 04:25:21 guy Exp $
$Author: guy $
$Date: 2005/10/06 04:25:21 $
$Name: milestone_3-0-1 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: returns all locked objects $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- Loop through all objects that are locked by specified user --->
<cfloop list="#arguments.types#" index="i">
		
	<cftry>
		<cfquery name="qGetObjects" datasource="#application.dsn#">
		SELECT 	DISTINCT objectID,label, datetimelastUpdated 
		FROM 	#application.dbowner##i#
		WHERE 	locked = 1
			AND lockedby = '#arguments.userlogin#'
		ORDER BY datetimelastUpdated DESC
		</cfquery>		
				
		<!--- Create structure for object details to be outputted later --->
		<cfif qGetObjects.recordcount gt 0>
			<cfloop query="qGetObjects">
				<cfset queryAddRow(qLockedObjects,1)>
				<cfset querySetCell(qLockedObjects,"ObjectId", qGetObjects.objectId)>
				<cfif qGetObjects.label neq "">
					<cfset querySetCell(qLockedObjects,"objectTitle", qGetObjects.label)>
				<cfelse>
					<cfset querySetCell(qLockedObjects,"objectTitle", "<em>undefined</em>")>
				</cfif>
				<cfset querySetCell(qLockedObjects,"objectLastUpdated", qGetObjects.datetimelastUpdated)>
				<cfset querySetCell(qLockedObjects,"objectType", I)>
				
				<cfif structKeyExists(application.types[i], "bUseInTree") and application.types[i].bUseInTree>
					<!--- get object parent --->
					<cfquery name="qGetParent" datasource="#application.dsn#">
						SELECT parentid FROM #application.dbowner#dmNavigation_aObjectIDs 
						WHERE data = '#objectId#'	
					</cfquery>
					<cfset querySetCell(qLockedObjects,"objectParent", qGetParent.objectid)>
				<cfelse>
					<cfset querySetCell(qLockedObjects,"objectParent", 0)>
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
