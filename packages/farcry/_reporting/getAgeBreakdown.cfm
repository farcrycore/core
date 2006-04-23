<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_reporting/getAgeBreakdown.cfm,v 1.4 2003/09/10 12:21:48 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 12:21:48 $
$Name: b201 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: gets object age breakdown $
$TODO: $

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