<!-- Revision: 2005-05-25 // Friedrich Dimmel
	changes: PostgreSQL queries corrected.
	1) HH24 instead of hh
-->

<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getPageStatsByDay.cfm,v 1.17 2005/10/28 03:41:17 paul Exp $
$Author: paul $
$Date: 2005/10/28 03:41:17 $
$Name: p300_b113 $
$Revision: 1.17 $

|| DESCRIPTION || 
$Description: get object stats $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- run the query to get counts of user activity by hour --->
<cfswitch expression="#application.dbtype#">
<cfcase value="ora">
	<cfquery datasource="#arguments.dsn#" name="qGetPageStatsByDay">
		select distinct hour, TO_CHAR(fq.logdatetime,'hh24') as loginhour, count(fq.logId) as count_views
		from #application.dbowner#statsHours
		left join (
				select * from stats
				where 1 = 1 
				<cfif not arguments.showAll>
					and pageid = '#arguments.pageId#'
				</cfif>
		) fq on TO_CHAR(fq.logdatetime,'hh24') = statsHours.hour
		and TO_CHAR(fq.logdatetime,'dd' ) = #DatePart("d", arguments.day)# and TO_CHAR(fq.logdatetime,'mm') = #DatePart("m", arguments.day)# and TO_CHAR(fq.logdatetime,'yyyy') = #DatePart("yyyy", arguments.day)#
		group by hour, TO_CHAR(fq.logdatetime,'hh24')
		order by 1 
	</cfquery>	
</cfcase>

<cfcase value="postgresql">
	<!--- This should work, but I'm not sure if this function is even used? KS --->
<!---
	adapted by Friedrich Dimmel (friedrich.dimmel@siemens.com)
	Didn't work. PostgreSQL uses HH24 instead of hh.
--->
	<cfquery datasource="#arguments.dsn#" name="qGetPageStatsByDay">
		SELECT DISTINCT hour, TO_CHAR(fq.logdatetime,'HH24') as loginhour, count(fq.logId) as count_views
		from #application.dbowner#statsHours
		LEFT JOIN (
				SELECT * FROM stats
				WHERE 1 = 1
				<cfif not arguments.showAll>
					AND pageid = '#arguments.pageId#'
				</cfif>
		) fq ON TO_CHAR(fq.logdatetime,'HH24') = statsHours.hour
		AND TO_CHAR(fq.logdatetime,'DD' ) = '#DateFormat(arguments.day, "dd")#' AND TO_CHAR(fq.logdatetime, 'MM') = '#DateFormat(arguments.day, "mm")#' AND TO_CHAR(fq.logdatetime,'YYYY') = '#DateFormat(arguments.day, "yyyy")#'
		GROUP BY hour, TO_CHAR(fq.logdatetime,'HH24')
		ORDER BY 1 
	</cfquery>	
</cfcase>

<cfcase value="mysql">
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
				and pageid = '#arguments.pageId#'
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
		from #application.dbowner#statsHours statsHours
		left join (
				select * from #application.dbowner#stats
				where 1 = 1
				<cfif not arguments.showAll>
					and pageid = '#arguments.pageId#'
				</cfif>
		)fq on datepart(hh, fq.logdatetime) = statsHours.hour
		and datepart(dd, fq.logdatetime) = #DatePart("d", arguments.day)# and datepart(mm, fq.logdatetime) = #DatePart("m", arguments.day)# and datepart(yyyy, fq.logdatetime) = #DatePart("yyyy", arguments.day)#
		group by hour, datepart(hh, fq.logdatetime)
		order by 1 ;
	</cfquery>
</cfdefaultcase>
</cfswitch>