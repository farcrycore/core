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
$Header: /cvs/farcry/core/packages/farcry/_workflow/getStatusBreakdown.cfm,v 1.6 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: gets object status breakdown for site $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- initialize structure --->
<cfset stStatus = structNew()>
<cfset stStatus["Draft"] = 0>
<cfset stStatus["Pending"] = 0>
<cfset stStatus["Approved"] = 0>

<cfset statusList = "draft,Pending,approved">

<!--- Get all objects types that have status option --->
<cfloop collection="#application.types#" item="i">
	<cfif structkeyexists(application.types[i].stProps,"status")>
		
		<cfloop list="#statusList#"	index="status">
			<cftry>			
				<!--- Get all objects that have status --->
				<cfquery name="qGetObjects" datasource="#application.dsn#">
					select count(objectID) as objectCount
					From #application.dbowner##i#
					WHERE status = '#status#'
				</cfquery>
			
				<!--- Add count to the list --->
				<cfif qGetObjects.recordcount gt 0>
					<cfset stStatus[status] = stStatus[status] + qGetObjects.objectCount>
				</cfif>
				<cfcatch></cfcatch>
			</cftry>
		</cfloop>
	</cfif>
</cfloop>