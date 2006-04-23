<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_locking/getLockedObjects.cfm,v 1.7 2004/03/24 22:37:27 brendan Exp $
$Author: brendan $
$Date: 2004/03/24 22:37:27 $
$Name: milestone_2-2-1 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: returns all locked objects $
$TODO: $

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
			select distinct objectID,label, datetimelastUpdated 
			From #application.dbowner##i# 
			WHERE locked = 1 and lockedby = '#arguments.userlogin#' order by datetimelastUpdated desc
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
						SELECT objectid FROM #application.dbowner#dmNavigation_aObjectIDs 
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
