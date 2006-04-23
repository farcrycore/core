<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getMostViewed.cfm,v 1.6 2003/09/10 12:21:48 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 12:21:48 $
$Name: b201 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: Shows most viewed objects$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfimport taglib="/farcry/fourq/tags" prefix="q4">

<!--- get downloads from stats --->
<cfquery datasource="#arguments.dsn#" name="qStats">
	SELECT pageid, count(logId) as count_downloads, typename
	FROM stats, refObjects
	WHERE stats.pageid = refObjects.objectid
	<cfif arguments.dateRange neq "all">
		 AND logDateTime > #dateAdd("#arguments.dateRange#",-1,now())#
	</cfif>
	<cfif isdefined("arguments.typeName") and arguments.typeName neq "all">
		AND refObjects.typename = '#arguments.typeName#'
	</cfif>
	GROUP By pageid, typename
	ORDER BY count_downloads DESC
</cfquery>

<!--- create query --->
<cfset qGetMostViewed = queryNew("title,objectid,downloads,typename")>

<!--- initiate counter --->
<cfset counter = 0>

<!--- loop over stats and get details --->
<cfloop query="qStats">
		
	<cftry>
		<cfquery datasource="#arguments.dsn#" name="qTitle">
			select title
			from #qStats.typename#
			where objectid = '#qStats.pageid#'
		</cfquery>
		<cfif qTitle.recordcount>
			<!--- add row to query --->
			<cfset temp = queryAddRow(qGetMostViewed, 1)>
			<cfset temp = querySetCell(qGetMostViewed, "title", qTitle.title)>
			<cfset temp = querySetCell(qGetMostViewed, "objectid", qStats.pageid)>
			<cfset temp = querySetCell(qGetMostViewed, "typename", qStats.typename)>
			<cfset temp = querySetCell(qGetMostViewed, "downloads", qStats.count_downloads)>
			
			<!--- update counter --->
			<cfset counter = counter + 1>
			<cfif counter eq arguments.maxRows and arguments.maxRows neq "all">
				<cfbreak>
			</cfif>
		</cfif>
		<!--- check object exists --->
		<cfcatch type="any"></cfcatch>
	</cftry>
</cfloop>