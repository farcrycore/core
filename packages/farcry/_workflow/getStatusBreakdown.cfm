<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_workflow/getStatusBreakdown.cfm,v 1.6 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-0 $
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