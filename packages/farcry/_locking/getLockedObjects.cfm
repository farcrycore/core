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
