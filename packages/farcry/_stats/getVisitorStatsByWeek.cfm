<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getVisitorStatsByWeek.cfm,v 1.6 2004/05/20 04:41:25 brendan Exp $
$Author: brendan $
$Date: 2004/05/20 04:41:25 $
$Name: milestone_2-2-1 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: get visitor stats $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- run the query to get counts of user activity by week --->

<cfswitch expression="#application.dbtype#"	>
<cfcase value="ora">
	<!--- THIS QUERY IS NOT COMPLETE - TODO --->
	<cfquery datasource="#arguments.dsn#" name="qGetPageStatsByWeek">
		select distinct day, statsDays.name,TO_CHAR(fq.logdatetime,'dy') as loginday, count(distinct sessionId) as count_Ip
		from #application.dbowner#statsDays
		left join (
			select * from stats
				
		)fq on UPPER(TO_CHAR(fq.logdatetime,'dy')) = UPPER(SUBSTR(statsDays.day,1,3))
		 and (fq.logdatetime - TO_DATE('#arguments.day#','dd/mon/yy') <=0) and (TO_DATE('#dateadd('d','7',arguments.day)#','dd/mon/yy') - fq.logdatetime >=0))
		group by day, statsDays.name, TO_CHAR(fq.logdatetime,'dy')
		order by 1 
	</cfquery>
</cfcase>

<cfcase value="postgresql">
	<cfquery datasource="#arguments.dsn#" name="qGetPageStatsByWeek">
		select distinct day, statsDays.name,TO_CHAR(fq.logdatetime,'dy') as loginday, count(distinct sessionId) as count_Ip
		from #application.dbowner#statsDays
		left join (
			select * from stats
		)fq on UPPER(TO_CHAR(fq.logdatetime,'dy')) = UPPER(SUBSTR(statsDays.name,1,3))
		 and (fq.logdatetime >= '#dateFormat(arguments.day, 'yyyy-mm-dd')#') 
		 and (fq.logdatetime < '#dateFormat(dateadd('d','7',arguments.day), 'yyyy-mm-dd')#')
		group by day, statsDays.name, TO_CHAR(fq.logdatetime,'dy')
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
			`SESSIONID`  VARCHAR(255) NOT NULL ,
			`LOGDATETIME` DATETIME NOT NULL
			)
	</cfquery>
	<cfquery datasource="#arguments.dsn#" name="temp3">
		INSERT INTO tblTemp1 (LOGID,LOGDATETIME,SESSIONID) 
			SELECT LOGID, LOGDATETIME, SESSIONID FROM #application.dbowner#stats 
	</cfquery>
	<!--- do main query --->
	<cfquery datasource="#arguments.dsn#" name="qGetPageStatsByWeek">
		select distinct day, statsDays.name,DAYOFWEEK(fq.logdatetime) as loginday, count(distinct sessionId) as count_Ip
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
	select distinct day, statsDays.name,datepart(dw, fq.logdatetime) as loginday, count(distinct sessionId) as count_Ip
	from #application.dbowner#statsDays
	left join (
			select * from stats
				
	)fq on datepart(dw, fq.logdatetime) = statsDays.day
	 and datediff(day,fq.logdatetime,#createodbcdatetime(arguments.day)#) <=0 and datediff(day,fq.logdatetime,#createodbcdatetime(arguments.day+7)#) >=0
	group by day, statsDays.name, datepart(dw, fq.logdatetime)
	order by 1 
	</cfquery>
</cfdefaultcase>
</cfswitch>