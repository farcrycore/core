<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getVisitors.cfm,v 1.3 2003/04/29 00:47:26 brendan Exp $
$Author: brendan $
$Date: 2003/04/29 00:47:26 $
$Name: b131 $
$Revision: 1.3 $

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

<cfif stArgs.maxRows neq "all">

	<cfswitch expression="#application.dbtype#">
		<cfcase value="ora">
			<cfquery name="qVisitors" datasource="#stArgs.dsn#" maxrows="#stArgs.maxRows#">
				select remoteip, sessionid, count(pageId) as views, min(logDateTime) as startDate
				from #application.dbowner#stats
				WHERE 1=1
				<cfif stArgs.dateRange neq "all">
					AND logDateTime > #dateAdd("#stArgs.dateRange#",-1,now())#
				</cfif>
				<cfif isdefined("stArgs.remoteIp") and stArgs.remoteIP neq "all">
					AND remoteIP = '#stArgs.remoteIp#'
				</cfif>
				AND navid <> pageId
				group by sessionid, remoteIp
				ORDER BY min(logDateTime) desc
			</cfquery>
		</cfcase>
		
		<cfcase value="mysql">
			<cfquery name="qVisitors" datasource="#stArgs.dsn#" maxrows="#stArgs.maxRows#">
				select sessionid, remoteip, count(pageId) as views, min(logDateTime) as startDate
				from #application.dbowner#stats
				WHERE 1=1
				<cfif stArgs.dateRange neq "all">
					AND logDateTime > #dateAdd("#stArgs.dateRange#",-1,now())#
				</cfif>
				<cfif isdefined("stArgs.remoteIp") and stArgs.remoteIP neq "all">
					AND remoteIP = '#stArgs.remoteIp#'
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
			<cfquery name="qVisitors" datasource="#stArgs.dsn#" maxrows="#stArgs.maxRows#">
				select remoteip, sessionid, count(pageId) as views, min(logDateTime) as startDate
				from #application.dbowner#stats
				WHERE 1=1
				<cfif stArgs.dateRange neq "all">
					AND logDateTime > #dateAdd("#stArgs.dateRange#",-1,now())#
				</cfif>
				<cfif isdefined("stArgs.remoteIp") and stArgs.remoteIP neq "all">
					AND remoteIP = '#stArgs.remoteIp#'
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
			<cfquery name="qVisitors" datasource="#stArgs.dsn#">
				select remoteip, sessionid, count(pageId) as views, min(logDateTime) as startDate
				from #application.dbowner#stats
				WHERE 1=1
				<cfif stArgs.dateRange neq "all">
					AND logDateTime > #dateAdd("#stArgs.dateRange#",-1,now())#
				</cfif>
				<cfif isdefined("stArgs.remoteIp") and stArgs.remoteIP neq "all">
					AND remoteIP = '#stArgs.remoteIp#'
				</cfif>
				AND navid <> pageId
				group by sessionid, remoteIp
				ORDER BY min(logDateTime) desc
			</cfquery>
		</cfcase>
		
		<cfcase value="mysql">
			<cfquery name="qVisitors" datasource="#stArgs.dsn#">
				select sessionid, remoteip, count(pageId) as views, min(logDateTime) as startDate
				from #application.dbowner#stats
				WHERE 1=1
				<cfif stArgs.dateRange neq "all">
					AND logDateTime > #dateAdd("#stArgs.dateRange#",-1,now())#
				</cfif>
				<cfif isdefined("stArgs.remoteIp") and stArgs.remoteIP neq "all">
					AND remoteIP = '#stArgs.remoteIp#'
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
			<cfquery name="qVisitors" datasource="#stArgs.dsn#">
				select remoteip, sessionid, count(pageId) as views, min(logDateTime) as startDate
				from #application.dbowner#stats
				WHERE 1=1
				<cfif stArgs.dateRange neq "all">
					AND logDateTime > #dateAdd("#stArgs.dateRange#",-1,now())#
				</cfif>
				<cfif isdefined("stArgs.remoteIp") and stArgs.remoteIP neq "all">
					AND remoteIP = '#stArgs.remoteIp#'
				</cfif>
				AND navid <> pageId
				group by sessionid, remoteIp
				ORDER BY min(logDateTime) desc
			</cfquery>
		</cfdefaultcase>
	</cfswitch>
	
</cfif>
	
