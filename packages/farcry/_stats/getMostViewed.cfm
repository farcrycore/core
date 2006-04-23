<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getMostViewed.cfm,v 1.2 2003/04/28 01:08:22 brendan Exp $
$Author: brendan $
$Date: 2003/04/28 01:08:22 $
$Name: b131 $
$Revision: 1.2 $

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
<cfquery datasource="#stArgs.dsn#" name="qStats">
	SELECT pageid, count(logId) as count_downloads
	FROM Stats
	<cfif stArgs.dateRange neq "all">
		WHERE logDateTime > #dateAdd("#stArgs.dateRange#",-1,now())#
	</cfif>
	GROUP By pageid
	ORDER BY count_downloads DESC
</cfquery>

<!--- create query --->
<cfset qGetMostViewed = queryNew("title,objectid,downloads,typename")>

<!--- initiate counter --->
<cfset counter = 0>

<!--- loop over stats and get details --->
<cfloop query="qStats">
	<cfset error= false>
	<cftry>
		<q4:contentobjectget objectID="#pageId#" r_stobject="stObject">

		<!--- check object exists --->
		<cfcatch type="any">
			<cfset error = true>
		</cfcatch>
	</cftry>
	<cfif not error>
		<cfif not (isdefined("stArgs.typeName") and stArgs.typeName neq stObject.typename and stArgs.typeName neq "all")>
			<!--- add row to query --->
			<cfset temp = queryAddRow(qGetMostViewed, 1)>
			<cfset temp = querySetCell(qGetMostViewed, "title", stObject.title)>
			<cfset temp = querySetCell(qGetMostViewed, "objectid", stObject.objectid)>
			<cfset temp = querySetCell(qGetMostViewed, "typename", stObject.typename)>
			<cfset temp = querySetCell(qGetMostViewed, "downloads", count_downloads)>
			<!--- update counter --->
			<cfset counter = counter + 1>
			<cfif counter eq stArgs.maxRows and stArgs.maxRows neq "all">
				<cfbreak>
			</cfif>
		</cfif>
	</cfif>
</cfloop>