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
$Header: /cvs/farcry/core/packages/farcry/_stats/getBranchStatsByDate.cfm,v 1.6 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: gets stats for entire branch $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfscript>
	// get descendants over object
	qDescendants = application.factory.oTree.getDescendants(arguments.navId);
</cfscript>

<!--- Determine list of nav ids to search by --->
<cfif qDescendants.recordcount>
	<cfset lNavIDs = ValueList(qDescendants.objectid) />
	<cfset lNavIDs = listAppend(lNavIDs, arguments.navid) />
<cfelse>
	<cfset lNavIDs = arguments.navid />
</cfif>

<!--- get page log entries --->
<cfswitch expression="#application.dbtype#">
	<cfcase value="ora">
		<cfquery name="qGetPageStats" datasource="#arguments.dsn#">
		select to_char(logdatetime,'yyyy-mm-dd') as viewday,count(logId) as count_views
		from #application.dbowner#stats
		where 1=1 
		AND navid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lNavIDs#" />)
		<cfif isDefined("arguments.before")>
		AND logdatetime < #arguments.before#
		</cfif>
		<cfif isDefined("arguments.after")>
		AND logdatetime > #arguments.after#
		</cfif>
		group by to_char(logdatetime,'yyyy-mm-dd')
		order by to_char(logdatetime,'yyyy-mm-dd')
		</cfquery>
	</cfcase>
	<cfcase value="postgresql">
		<cfquery name="qGetPageStats" datasource="#arguments.dsn#">
		select to_char(logdatetime,'yyyy-mm-dd') as viewday,count(logId) as count_views
		from #application.dbowner#stats
		where 1=1 
		AND navid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lNavIDs#" />)
		<cfif isDefined("arguments.before")>
		AND logdatetime < #arguments.before#
		</cfif>
		<cfif isDefined("arguments.after")>
		AND logdatetime > #arguments.after#
		</cfif>
		group by to_char(logdatetime,'yyyy-mm-dd')
		order by to_char(logdatetime,'yyyy-mm-dd')
		</cfquery>
	</cfcase>
	<cfcase value="mysql,mysql5">
		<cfquery name="qGetPageStats" datasource="#arguments.dsn#">
		select replace(left(logdatetime, 10),"-",".") as viewday, 
				count(logId) as count_views 
		from #application.dbowner#stats
		where 1=1 
		AND navid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lNavIDs#" />)
		<cfif isDefined("arguments.before")>
		AND logdatetime < #arguments.before#
		</cfif>
		<cfif isDefined("arguments.after")>
		AND logdatetime > #arguments.after#
		</cfif>
		group by viewday
		order by viewday
		</cfquery>
		
		<!--- viewday comes out of the query as binary, so convert it back to being a string --->
		<cfloop query="qGetPageStats">
			<cfset qGetPageStats.viewday = tostring(qGetPageStats.viewday)>
		</cfloop>				
	</cfcase>
	<cfdefaultcase>
		<cfquery name="qGetPageStats" datasource="#arguments.dsn#">
		select convert(varchar,logdatetime,102) as viewday,count(logId) as count_views
		from #application.dbowner#stats
		where 1=1 
		AND navid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lNavIDs#" />)
		<cfif isDefined("arguments.before")>
		AND logdatetime < #arguments.before#
		</cfif>
		<cfif isDefined("arguments.after")>
		AND logdatetime > #arguments.after#
		</cfif>
		group by convert(varchar,logdatetime,102)
		order by convert(varchar,logdatetime,102)
		</cfquery>
	</cfdefaultcase>
</cfswitch>	

<!--- get max, min, sum, and avg (max is used for y axis of grid in <cfchart>) --->
<cfquery name="math" dbtype="query">
	SELECT
		max(count_views) as maxCount,
		min(count_views) as minCount,
		sum(count_views) as sumCount,
		avg(count_views) as avgCount
	FROM
		qGetPageStats
</cfquery>

<!--- Create structure to return --->
<cfset stReturn = structNew() />
<cfset stReturn.qGetPageStats = qGetPageStats />

<!--- Add some quick info to the struct (max, min, avg, and sum --->
<cfloop index="i" list="max,min,avg,sum">
	<cfif len("math.#i#Count") gt 0>
		<cfset "stReturn.#i#" = "#evaluate("math.#i#Count")#" />
	<cfelse>
		<cfset "stReturn.#i# = 0" />
	</cfif>
</cfloop>