<!-- Revision: 2005-05-25 // Friedrich Dimmel
	changes: PostgreSQL queries corrected.
 	1) D instead of dy
	2) swapped signs <= and >= to work correctly
	3) moved sql-date functions out and into separate variables myDate / nextWeek	
 --->

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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_stats/getBranchStatsByWeek.cfm,v 1.10 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: gets stats for entire branch $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

	<!--- run the query to get counts of user activity by week --->

<!--- Determine list of nav ids to search by --->
<cfif qDescendants.recordcount>
	<cfset lNavIDs = ValueList(qDescendants.objectid) />
	<cfset lNavIDs = listAppend(lNavIDs, arguments.navid) />
<cfelse>
	<cfset lNavIDs = arguments.navid />
</cfif>

<cfswitch expression="#application.dbtype#"	>
<cfcase value="ora">
	<!--- THIS QUERY IS NOT COMPLETE - TODO --->
	<cfquery datasource="#arguments.dsn#" name="qGetPageStatsByWeek">
		select distinct day, statsDays.name,TO_CHAR(fq.logdatetime,'dy') as loginday, count(fq.logId) as count_logins
		from #application.dbowner#statsDays
		left join (
			select * from stats
				where 1 = 1
				<cfif not arguments.showAll>
					AND navid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lNavIDs#" />)
				</cfif>
		)fq on UPPER(TO_CHAR(fq.logdatetime,'dy')) = UPPER(SUBSTR(statsDays.day,1,3))
		 and (fq.logdatetime - TO_DATE('#arguments.day#','dd/mon/yy') <=0) and (TO_DATE('#dateadd('d','7',arguments.day)#','dd/mon/yy') - fq.logdatetime >=0))
		group by day, statsDays.name, TO_CHAR(fq.logdatetime,'dy')
		order by 1 
	</cfquery>
</cfcase>

<cfcase value="postgresql">
<!---
	adapted by Friedrich Dimmel (friedrich.dimmel@siemens.com)
--->
 	<cfset thisWeek = DateFormat(arguments.day, "yyyy-mm-dd")>
	<cfset nextWeek = DateFormat(DateAdd('d', '7', thisWeek), "yyyy-mm-dd")>
 	<cfquery datasource="#arguments.dsn#" name="qGetPageStatsByWeek">
		SELECT DISTINCT day, statsDays.name, TO_CHAR(fq.logdatetime, 'D') AS loginday, COUNT(fq.logId) AS count_logins
		FROM #application.dbowner#statsDays
		LEFT JOIN (
			SELECT * FROM stats
			WHERE 1 = 1
			<cfif not arguments.showAll>
				AND navid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lNavIDs#" />)
			</cfif>
		) fq ON (UPPER(TO_CHAR(fq.logdatetime, 'D')) = UPPER(SUBSTR(statsDays.day, 1, 3)))
		AND (fq.logdatetime >= '#thisWeek#') AND ('#nextWeek#' >= fq.logdatetime)
		GROUP BY day, statsDays.name, TO_CHAR(fq.logdatetime, 'D')
		ORDER BY 1
	</cfquery>
</cfcase>

<cfcase value="mysql,mysql5">
	<!--- create temp table --->
	<cfquery datasource="#arguments.dsn#" name="temp">
		DROP TABLE IF EXISTS tblTemp1
	</cfquery>
	<cfquery datasource="#arguments.dsn#" name="temp2">
		create temporary table `tblTemp1`
			(
			`LOGID`  VARCHAR(255) NOT NULL ,
			`LOGDATETIME` DATETIME NOT NULL
			)
	</cfquery>
	<cfquery datasource="#arguments.dsn#" name="temp3">
		INSERT INTO tblTemp1 (LOGID,LOGDATETIME) 
			SELECT LOGID, LOGDATETIME FROM #application.dbowner#stats 
			WHERE 1 = 1 
			<CfIF not arguments.showAll>
				AND navid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lNavIDs#" />)
			</CFIF>
	</cfquery>
	<!--- do main query --->
	<cfquery datasource="#arguments.dsn#" name="qGetPageStatsByWeek">
		select distinct day, statsDays.name,DAYOFWEEK(fq.logdatetime) as loginday, count(fq.logId) as count_logins
		from #application.dbowner#statsDays
		left join tblTemp1 fq on DAYOFWEEK(fq.logdatetime) = statsDays.day
		and fq.logdatetime - DATE_ADD(#arguments.day#, INTERVAL 0 DAY) >=0  and DATE_ADD(#arguments.day#, INTERVAL 7 DAY) - fq.logdatetime >=0
		group by day, statsDays.name, DAYOFWEEK(fq.logdatetime)
		order by 1 
	</cfquery>
</cfcase>

<cfdefaultcase>
	<cfquery datasource="#arguments.dsn#" name="qGetPageStatsByWeek">
	-- now join our days table to the fqaudit table, to get the set we want. Note the query requires a day, month and year to be specified, for
	-- which we return the logins by day (nulls are returned if no logins during the day )
	select distinct day, statsDays.name,datepart(dw, fq.logdatetime) as loginday, count(fq.logId) as count_logins
	from #application.dbowner#statsDays
	left join (
			select * from stats
				where 1 = 1
				<cfif not arguments.showAll>
					AND navid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lNavIDs#" />)
				</cfif>
	)fq on datepart(dw, fq.logdatetime) = statsDays.day
	 and datediff(day,fq.logdatetime,#createodbcdate(arguments.day)#) <=0 and datediff(day,fq.logdatetime,#createodbcdate(arguments.day+7)#) >=0
	group by day, statsDays.name, datepart(dw, fq.logdatetime)
	order by 1 
	</cfquery>
</cfdefaultcase>
</cfswitch>