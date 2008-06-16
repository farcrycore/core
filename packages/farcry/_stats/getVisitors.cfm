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
$Header: /cvs/farcry/core/packages/farcry/_stats/getVisitors.cfm,v 1.6 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: Shows recent visitors$


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
		
		<cfcase value="postgresql">
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
		
		<cfcase value="mysql,mysql5">
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
		
		<cfcase value="mysql,mysql5">
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
	
