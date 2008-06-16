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
$Header: /cvs/farcry/core/packages/farcry/_stats/getVisitorPath.cfm,v 1.4 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Shows path taken by visitor in session$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- get pages from stats --->
<cfquery name="qTemp" datasource="#arguments.dsn#">
	SELECT NavId, PageId, logDateTime
	FROM #application.dbowner#stats
	WHERE sessionId = '#arguments.sessionId#'
		AND navid <> pageId
	ORDER BY logDateTime desc
</cfquery>

<!--- create query --->
<cfset qPathWrongOrder = queryNew("navId,objectId,timeSpent,orderNum")>

<!--- loop over query to work out length of time taken at each page --->
<cfloop query="qTemp">
	<!--- if not last page viewed --->
	<cfif currentRow neq 1>
		<cfset viewTime = dateDiff("s",logDateTime,lastView)>
		<!--- work out minutes and seconds --->
		<cfset mins = int(ViewTime/60)>
		<cfset secs = ViewTime - (mins*60)>
		<cfset ViewTime = "00:" & mins & ":" & secs>
	<cfelse>
		<cfset viewTime = "n/a">
	</cfif>
	
	<!--- add time spent to query --->
	<cfset temp = queryAddRow(qPathWrongOrder, 1)>
	<cfset temp = querySetCell(qPathWrongOrder, "navId", NavId)>
	<cfset temp = querySetCell(qPathWrongOrder, "objectid", PageId)>
	<cfset temp = querySetCell(qPathWrongOrder, "orderNum", currentRow)>
	<cfif viewTime neq "n/a">
		<cfset temp = querySetCell(qPathWrongOrder, "timeSpent", timeFormat(viewTime,"mm:ss"))>
	<cfelse>
		<cfset temp = querySetCell(qPathWrongOrder, "timeSpent", viewTime)>
	</cfif>
	<!--- set log date for comparison in next row --->
	<cfset lastView = logDateTime>
	
	<!--- re-order query in correct path order --->
	<cfquery name="qPath" dbtype="query">
		SELECT *
		FROM qPathWrongOrder
		ORDER BY orderNum desc
	</cfquery>
</cfloop>