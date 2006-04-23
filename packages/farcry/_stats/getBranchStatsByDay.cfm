<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getBranchStatsByDay.cfm,v 1.9 2003/12/08 05:39:55 paul Exp $
$Author: paul $
$Date: 2003/12/08 05:39:55 $
$Name: milestone_2-1-2 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: get stats for entire branch $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfscript>
	// get descendants over object
	qDescendants = request.factory.oTree.getDescendants(arguments.navId);
</cfscript>

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
					AND navid IN (<cfif qDescendants.recordcount>#QuotedValueList(qDescendants.objectid)#,</cfif>'#arguments.navid#')
				</cfif>
		)fq on TO_CHAR(fq.logdatetime,'hh') = statsHours.hour
		and TO_CHAR(fq.logdatetime,'dd' ) = #DatePart("d", arguments.day)# and TO_CHAR(fq.logdatetime,'mm') = #DatePart("m", arguments.day)# and TO_CHAR(fq.logdatetime,'yyyy') = #DatePart("yyyy", arguments.day)#
		group by hour, TO_CHAR(fq.logdatetime,'hh')
		order by 1 
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
				AND navid IN (<cfif qDescendants.recordcount>#QuotedValueList(qDescendants.objectid)#,</cfif>'#arguments.navid#')
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
					AND navid IN (<cfif qDescendants.recordcount>#QuotedValueList(qDescendants.objectid)#,</cfif>'#arguments.navid#')
				</cfif>
		)fq on datepart(hh, fq.logdatetime) = statsHours.hour
		and datepart(dd, fq.logdatetime) = #DatePart("d", arguments.day)# and datepart(mm, fq.logdatetime) = #DatePart("m", arguments.day)# and datepart(yyyy, fq.logdatetime) = #DatePart("yyyy", arguments.day)#
		group by hour, datepart(hh, fq.logdatetime)
		order by 1 ;
	</cfquery>
</cfdefaultcase>
</cfswitch>