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
$Header: /cvs/farcry/core/packages/farcry/_locking/scheduledUnlock.cfm,v 1.7 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: scheduled task for unlocking objects left locked $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- Loop through all objects that are locked --->
<cfloop list="#arguments.types#" index="i">

	<cfquery name="qLockedObjects1" datasource="#application.dsn#">
		select distinct objectID,label,datetimelastUpdated,lastupdatedby
		From #application.dbowner##i#
		WHERE locked = 1 and datetimelastupdated < #dateadd("d",-arguments.days,now())#
	</cfquery>		
			
	<!--- unlock each object --->
	<cfif qLockedObjects1.recordcount gt 0>
		
		<cfloop query="qLockedObjects1">
			<cfinvoke component="#application.packagepath#.farcry.locking" method="unlock" returnvariable="unlockRet">
				<cfinvokeargument name="objectId" value="#objectid#"/>
				<cfinvokeargument name="typename" value="#i#"/>
			</cfinvoke>
			
			<!--- add to query object --->
			<cfset queryAddRow(qLockedObjects,1)>
			<cfset querySetCell(qLockedObjects,"ObjectId", qLockedObjects1.objectId)>
			<cfset querySetCell(qLockedObjects,"lastupdatedby", qLockedObjects1.lastupdatedby)>
			<cfif qLockedObjects1.label neq "">
				<cfset querySetCell(qLockedObjects,"objectTitle", qLockedObjects1.label)>
			<cfelse>
				<cfset querySetCell(qLockedObjects,"objectTitle", "<em>undefined</em>")>
			</cfif>
			<cfset querySetCell(qLockedObjects,"objectLastUpdated", qLockedObjects1.datetimelastUpdated)>
			<cfset querySetCell(qLockedObjects,"objectType", I)>
		</cfloop>
		
	</cfif>
</cfloop>