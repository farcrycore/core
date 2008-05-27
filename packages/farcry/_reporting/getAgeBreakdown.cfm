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
$Header: /cvs/farcry/core/packages/farcry/_reporting/getAgeBreakdown.cfm,v 1.5 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: gets object age breakdown $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- initialise last segment for everything greater than last segment --->
<cfset arguments.breakdown = listAppend(arguments.breakdown, (">" & listLast(arguments.breakdown)))>

<!--- initialize structure --->
<cfset stAge = structNew()>

<cfloop list="#arguments.breakdown#" index="segment">
	<cfset stAge[segment] = 0>
</cfloop>

<!--- Get all objects types that have dateTimeLastUpdated option --->
<cfloop collection="#application.types#" item="i">
	<cfif structkeyexists(application.types[i].stProps,"dateTimeLastUpdated")>
	
		<cfset previousSegment = "">
		<!--- loop over each segment to get count of objects --->
		<cfloop list="#arguments.breakdown#" index="segment">
			<cftry>
				<!--- Get all objects that between dates --->
				<cfquery name="qGetObjects" datasource="#application.dsn#">
					select count(objectID) as objectCount
					From #application.dbowner##i#
					WHERE
						<!--- check if last segment ie > last defined segment --->
						<cfif not isnumeric(segment) and segment eq listLast(segment)>
							dateTimeLastUpdated < #createodbcdatetime(dateadd("d",-previousSegment,now()))#
						<cfelse>
							dateTimeLastUpdated >= #createodbcdatetime(dateadd("d",-segment,now()))#
							<!--- if not the first item, compare between two dates --->
							<cfif previousSegment neq "">
								and dateTimeLastUpdated <= #createodbcdatetime(dateadd("d",-previousSegment,now()))#
							</cfif>
						</cfif>
				</cfquery>
				
				<!--- Add count to the list --->
				<cfif qGetObjects.recordcount gt 0>
					<cfset stAge[segment] = stAge[segment] + qGetObjects.objectCount>
				</cfif>
				<cfcatch></cfcatch>
			</cftry>
			<cfset previousSegment = segment>
		</cfloop>
	</cfif>
</cfloop>