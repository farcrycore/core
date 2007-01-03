<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getPageStatsByDate.cfm,v 1.13 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.13 $

|| DESCRIPTION || 
$Description: get object stats $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfswitch expression="#application.dbtype#">
	<cfcase value="ora">
		<cfquery name="qGetPageStats" datasource="#arguments.dsn#">
		select to_char(logdatetime,'yyyy-mm-dd') as viewday,count(logId) as count_views
		from #application.dbowner#stats
		where 1=1 
		<cfif isDefined("arguments.pageID")>
		AND pageid = '#arguments.pageId#'
		</cfif>
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
		<cfif isDefined("arguments.pageID")>
		AND pageid = '#arguments.pageId#'
		</cfif>
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
	<cfcase value="postgresql">
		<!--- This should work, but I'm not sure if this function is even used? KS --->
		<cfquery name="qGetPageStats" datasource="#arguments.dsn#">
		select to_char(logdatetime,'YYYY-MM-DD') as viewday,count(logId) as count_views
		from #application.dbowner#stats
		where 1=1 
		<cfif isDefined("arguments.pageID")>
		AND pageid = '#arguments.pageId#'
		</cfif>
		<cfif isDefined("arguments.before")>
		AND logdatetime < #arguments.before#
		</cfif>
		<cfif isDefined("arguments.after")>
		AND logdatetime > #arguments.after#
		</cfif>
		group by to_char(logdatetime,'YYYY-MM-DD')
		order by to_char(logdatetime,'YYYY-MM-DD')
		</cfquery>
	</cfcase>
	<cfdefaultcase>
		<cfquery name="qGetPageStats" datasource="#arguments.dsn#">
		select convert(varchar,logdatetime,102) as viewday,count(logId) as count_views
		from #application.dbowner#stats
		where 1=1 
		<cfif isDefined("arguments.pageID")>
		AND pageid = '#arguments.pageId#'
		</cfif>
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

<!--- get max record for y axis of grid --->
<cfquery name="max" dbtype="query">
	select max(count_views) as maxcount
	from qGetPageStats
</cfquery>

<!--- create structure to return --->
<cfset stReturn = structNew()>
<cfset stReturn.qGetPageStats = qGetPageStats>
<cfif len(max.maxcount)>
	<cfset stReturn.max = evaluate(max.maxcount+1)>
<cfelse>
	<cfset stReturn.max = 0>
</cfif>

<!--- get max, min, sum, and avg (max is used for y axis of grid in <cfchart>)
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
</cfloop> --->