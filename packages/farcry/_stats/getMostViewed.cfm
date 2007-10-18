<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_stats/getMostViewed.cfm,v 1.9 2005/10/28 03:41:17 paul Exp $
$Author: paul $
$Date: 2005/10/28 03:41:17 $
$Name: milestone_3-0-1 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: Shows most viewed objects$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- get downloads from stats --->
<cfquery datasource="#arguments.dsn#" name="qStats">
	SELECT pageid, count(logId) as count_downloads, typename
	FROM #arguments.dbowner#stats stats, #arguments.dbowner#refObjects ref
	WHERE stats.pageid = ref.objectid
	<cfif arguments.dateRange neq "all">
		 AND logDateTime > #dateAdd("#arguments.dateRange#",-1,now())#
	</cfif>
	<cfif isdefined("arguments.typeName") and arguments.typeName neq "all">
		AND ref.typename = '#arguments.typeName#'
	</cfif>
	GROUP By pageid, typename
	ORDER BY count_downloads DESC
</cfquery>

<!--- create query --->
<cfset qGetMostViewed = queryNew("title,objectid,downloads,typename")>

<!--- initiate counter --->
<cfset counter = 0>

<!--- create navigation object --->
<cfset oNav = createObject("component",application.types.dmNavigation.typepath)>

<!--- loop over stats and get details --->
<cfloop query="qStats">
		
	<cftry>
		<!--- get object title --->
		<cfquery datasource="#arguments.dsn#" name="qTitle">
			select title
			from  #arguments.dbowner##qStats.typename#
			where objectid = '#qStats.pageid#'
		</cfquery>
			
		<cfif qTitle.recordcount>
			<!--- see if object is in tree --->
			<cfset qParent = oNav.getParent(qStats.pageid)>
			
			<cfif qParent.recordcount>
				<!--- clear title variable --->
				<cfset title = "">
				
				<!--- get ancestors --->
				<cfset qAncestors = request.factory.oTree.getAncestors(qParent.parentID)>
				
				<!--- build breadcrumb --->
				<cfloop query="qAncestors">
					<!--- don't include root and home --->
					<cfif qAncestors.nlevel gt 1>
						<cfif len(title)>
							<cfset title = title & " &raquo; ">
						</cfif>
						<cfset title = title & qAncestors.objectName>
					</cfif>
				</cfloop>
				
				<!--- append object title to breadcrumb --->
				<cfif len(title)>
					<cfset title = title & " &raquo; ">
				</cfif>
				<cfset title = title & qTitle.title>			
			<cfelse>
				<!--- no breadcrumb --->
				<cfset title = qTitle.title>
			</cfif>
		
			<!--- add row to query --->
			<cfset temp = queryAddRow(qGetMostViewed, 1)>
			<cfset temp = querySetCell(qGetMostViewed, "title", title)>
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