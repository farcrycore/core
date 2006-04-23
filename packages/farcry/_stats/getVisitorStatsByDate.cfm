<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getVisitorStatsByDate.cfm,v 1.3 2003/09/10 12:21:48 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 12:21:48 $
$Name: b201 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: get visitor stats $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- get page log entries --->

<cfswitch expression="#application.dbtype#">
	<cfcase value="ora">
		<cfquery name="qGetPageStats" datasource="#arguments.dsn#">
		select to_char(logdatetime,'yyyy-mm-dd') as viewday,count(distinct sessionId) as count_Ip
		from #application.dbowner#stats
		where 1=1 
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
	<cfcase value="mysql">
		<cfquery name="qGetPageStats" datasource="#arguments.dsn#">
		select replace(left(logdatetime, 10),"-",".") as viewday, count(distinct sessionId) as count_Ip
		from #application.dbowner#stats
		where 1=1 
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
		select convert(varchar,logdatetime,102) as viewday, count(distinct sessionId) as count_Ip
		from #application.dbowner#stats
		where 1=1 
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
	select max(count_Ip) as maxcount
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
