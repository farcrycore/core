<!-- Revision: 2005-05-25 // Friedrich Dimmel
	changes: PostgreSQL queries corrected.
	1) HH24 instead of hh
	2) DateFormat(arguments.day, "mm") etc. instead of DatePart("m", arguments.day) -> so we'll get the leading zero
	3) on comparison of TO_CHAR(bla) = DateFormat(bla) use Single Quotes at CFMX expression. 
		Postgres will remove leading zero without.
-->


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
$Header: /cvs/farcry/core/packages/farcry/_stats/getBranchStatsByDay.cfm,v 1.12 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.12 $

|| DESCRIPTION || 
$Description: get stats for entire branch $


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

<!--- run the query to get counts of user activity by hour --->
<cfswitch expression="#application.dbtype#">
<cfcase value="ora">
	<cfquery datasource="#arguments.dsn#" name="qGetPageStatsByDay">
		select distinct hour, TO_CHAR(fq.logdatetime,'hh') as loginhour, count(fq.logId) as count_views
		from #application.dbowner#statsHours
		left join (
				select * from stats
				where 1 = 1
				<cfif not arguments.showAll>
					AND navid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lNavIDs#" />)
				</cfif>
		)fq on TO_CHAR(fq.logdatetime,'hh') = statsHours.hour
		and TO_CHAR(fq.logdatetime,'dd' ) = #DatePart("d", arguments.day)# and TO_CHAR(fq.logdatetime,'mm') = #DatePart("m", arguments.day)# and TO_CHAR(fq.logdatetime,'yyyy') = #DatePart("yyyy", arguments.day)#
		group by hour, TO_CHAR(fq.logdatetime,'hh')
		order by 1 
	</cfquery>	
</cfcase>

<cfcase value="postgresql">
<!---
	adapted by Friedrich Dimmel (friedrich.dimmel@siemens.com)
--->
 	<cfquery datasource="#application.dsn#" name="qGetPageStatsByDay">
		SELECT DISTINCT hour, TO_CHAR(fq.logdatetime,'HH24') as loginhour, count(fq.logId) as count_views
		from #application.dbowner#statsHours
		LEFT JOIN (
				SELECT * FROM stats
				WHERE 1 = 1
				<cfif not arguments.showAll>
					AND navid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lNavIDs#" />)
				</cfif>
		) fq ON TO_CHAR(fq.logdatetime,'HH24') = statsHours.hour
		AND TO_CHAR(fq.logdatetime,'DD' ) = '#DateFormat(arguments.day, "dd")#' AND TO_CHAR(fq.logdatetime, 'MM') = '#DateFormat(arguments.day, "mm")#' AND TO_CHAR(fq.logdatetime,'YYYY') = '#DateFormat(arguments.day, "yyyy")#'
		GROUP BY hour, TO_CHAR(fq.logdatetime,'HH24')
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
	<cfquery datasource="#arguments.dsn#" name="qGetPageStatsByDay">
		select distinct hour, HOUR(fq.logdatetime) as loginhour, count(fq.logId) as count_views
		from #application.dbowner#statsHours
		left join tblTemp1 fq on HOUR(fq.logdatetime) = statsHours.hour
		and DAYOFMONTH(fq.logdatetime) = #DatePart("d", arguments.day)# and MONTH(fq.logdatetime) = #DatePart("m", arguments.day)# and YEAR(fq.logdatetime) = #DatePart("yyyy", arguments.day)#
		group by hour, loginhour
		order by 1 
	</cfquery>
</cfcase>

<cfdefaultcase>
	<cfquery datasource="#arguments.dsn#" name="qGetPageStatsByDay">
		select distinct hour, datepart(hh, fq.logdatetime) as loginhour, count(fq.logId) as count_views
		from #application.dbowner#statsHours
		left join (
				select * from stats
				where 1 = 1
				<cfif not arguments.showAll>
					AND navid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lNavIDs#" />)
				</cfif>
		)fq on datepart(hh, fq.logdatetime) = statsHours.hour
		and datepart(dd, fq.logdatetime) = #DatePart("d", arguments.day)# and datepart(mm, fq.logdatetime) = #DatePart("m", arguments.day)# and datepart(yyyy, fq.logdatetime) = #DatePart("yyyy", arguments.day)#
		group by hour, datepart(hh, fq.logdatetime)
		order by 1 ;
	</cfquery>
</cfdefaultcase>
</cfswitch>