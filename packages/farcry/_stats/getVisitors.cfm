<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getVisitors.cfm,v 1.4 2003/09/10 12:21:48 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 12:21:48 $
$Name: b201 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Shows recent visitors$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- get downloads from stats --->

<cfif arguments.maxRows neq "all">

	<cfswitch expression="#application.dbtype#">
		<cfcase value="ora">
			<cfquery name="qVisitors" datasource="#arguments.dsn#" maxrows="#arguments.maxRows#">
				select remoteip, sessionid, count(pageId) as views, min(logDateTime) as startDate
				from #application.dbowner#stats
				WHERE 1=1
				<cfif arguments.dateRange neq "all">
					AND logDateTime > #dateAdd("#arguments.dateRange#",-1,now())#
				</cfif>
				<cfif isdefined("arguments.remoteIp") and arguments.remoteIP neq "all">
					AND remoteIP = '#arguments.remoteIp#'
				</cfif>
				AND navid <> pageId
				group by sessionid, remoteIp
				ORDER BY min(logDateTime) desc
			</cfquery>
		</cfcase>
		
		<cfcase value="mysql">
			<cfquery name="qVisitors" datasource="#arguments.dsn#" maxrows="#arguments.maxRows#">
				select sessionid, remoteip, count(pageId) as views, min(logDateTime) as startDate
				from #application.dbowner#stats
				WHERE 1=1
				<cfif arguments.dateRange neq "all">
					AND logDateTime > #dateAdd("#arguments.dateRange#",-1,now())#
				</cfif>
				<cfif isdefined("arguments.remoteIp") and arguments.remoteIP neq "all">
					AND remoteIP = '#arguments.remoteIp#'
				</cfif>
				AND navid <> pageId
				GROUP BY sessionid, remoteip
				ORDER BY startDate desc
			</cfquery>
			<!--- startDate comes out of the query as binary, so convert it back to being a string --->
			<cfloop query="qVisitors">
				<cfset qVisitors.startDate = tostring(qVisitors.startDate)>
			</cfloop>	
		</cfcase>
		
		<cfdefaultcase>
			<cfquery name="qVisitors" datasource="#arguments.dsn#" maxrows="#arguments.maxRows#">
				select remoteip, sessionid, count(pageId) as views, min(logDateTime) as startDate
				from #application.dbowner#stats
				WHERE 1=1
				<cfif arguments.dateRange neq "all">
					AND logDateTime > #dateAdd("#arguments.dateRange#",-1,now())#
				</cfif>
				<cfif isdefined("arguments.remoteIp") and arguments.remoteIP neq "all">
					AND remoteIP = '#arguments.remoteIp#'
				</cfif>
				AND navid <> pageId
				group by sessionid, remoteIp
				ORDER BY min(logDateTime) desc
			</cfquery>
		</cfdefaultcase>
	</cfswitch>
	
<cfelse>

	<cfswitch expression="#application.dbtype#">
		<cfcase value="ora">
			<cfquery name="qVisitors" datasource="#arguments.dsn#">
				select remoteip, sessionid, count(pageId) as views, min(logDateTime) as startDate
				from #application.dbowner#stats
				WHERE 1=1
				<cfif arguments.dateRange neq "all">
					AND logDateTime > #dateAdd("#arguments.dateRange#",-1,now())#
				</cfif>
				<cfif isdefined("arguments.remoteIp") and arguments.remoteIP neq "all">
					AND remoteIP = '#arguments.remoteIp#'
				</cfif>
				AND navid <> pageId
				group by sessionid, remoteIp
				ORDER BY min(logDateTime) desc
			</cfquery>
		</cfcase>
		
		<cfcase value="mysql">
			<cfquery name="qVisitors" datasource="#arguments.dsn#">
				select sessionid, remoteip, count(pageId) as views, min(logDateTime) as startDate
				from #application.dbowner#stats
				WHERE 1=1
				<cfif arguments.dateRange neq "all">
					AND logDateTime > #dateAdd("#arguments.dateRange#",-1,now())#
				</cfif>
				<cfif isdefined("arguments.remoteIp") and arguments.remoteIP neq "all">
					AND remoteIP = '#arguments.remoteIp#'
				</cfif>
				AND navid <> pageId
				GROUP BY sessionid, remoteip
				ORDER BY startDate desc
			</cfquery>
			<!--- startDate comes out of the query as binary, so convert it back to being a string --->
			<cfloop query="qVisitors">
				<cfset qVisitors.startDate = tostring(qVisitors.startDate)>
			</cfloop>	
		</cfcase>
		
		<cfdefaultcase>
			<cfquery name="qVisitors" datasource="#arguments.dsn#">
				select remoteip, sessionid, count(pageId) as views, min(logDateTime) as startDate
				from #application.dbowner#stats
				WHERE 1=1
				<cfif arguments.dateRange neq "all">
					AND logDateTime > #dateAdd("#arguments.dateRange#",-1,now())#
				</cfif>
				<cfif isdefined("arguments.remoteIp") and arguments.remoteIP neq "all">
					AND remoteIP = '#arguments.remoteIp#'
				</cfif>
				AND navid <> pageId
				group by sessionid, remoteIp
				ORDER BY min(logDateTime) desc
			</cfquery>
		</cfdefaultcase>
	</cfswitch>
	
</cfif>
	
