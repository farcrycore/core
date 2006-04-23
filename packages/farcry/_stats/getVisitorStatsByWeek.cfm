	<!--- run the query to get counts of user activity by week --->

<cfswitch expression="#application.dbtype#"	>
<cfcase value="ora">
	<!--- THIS QUERY IS NOT COMPLETE - TODO --->
	<cfquery datasource="#stArgs.dsn#" name="qGetPageStatsByWeek">
		select distinct day, statsDays.name,TO_CHAR(fq.logdatetime,'dy') as loginday, count(distinct sessionId) as count_Ip
		from #application.dbowner#statsDays
		left join (
			select * from stats
				
		)fq on UPPER(TO_CHAR(fq.logdatetime,'dy')) = UPPER(SUBSTR(statsDays.day,1,3))
		 and (fq.logdatetime - TO_DATE('#stArgs.day#','dd/mon/yy') <=0) and (TO_DATE('#dateadd('d','7',stArgs.day)#','dd/mon/yy') - fq.logdatetime >=0))
		group by day, statsDays.name, TO_CHAR(fq.logdatetime,'dy')
		order by 1 
	</cfquery>
</cfcase>

<cfcase value="mysql">
	<!--- create temp table --->
	<cfquery datasource="#stArgs.dsn#" name="temp">
		DROP TABLE IF EXISTS tblTemp1
	</cfquery>
	<cfquery datasource="#stArgs.dsn#" name="temp2">
		create temporary table `tblTemp1`
			(
			`LOGID`  VARCHAR(255) NOT NULL ,
			`SESSIONID`  VARCHAR(255) NOT NULL ,
			`LOGDATETIME` DATETIME NOT NULL
			)
	</cfquery>
	<cfquery datasource="#stArgs.dsn#" name="temp3">
		INSERT INTO tblTemp1 (LOGID,LOGDATETIME,SESSIONID) 
			SELECT LOGID, LOGDATETIME, SESSIONID FROM #application.dbowner#Stats 
	</cfquery>
	<!--- do main query --->
	<cfquery datasource="#stArgs.dsn#" name="qGetPageStatsByWeek">
		select distinct day, statsDays.name,DAYOFWEEK(fq.logdatetime) as loginday, count(distinct sessionId) as count_Ip
		from #application.dbowner#statsDays
		left join tblTemp1 fq on DAYOFWEEK(fq.logdatetime) = statsDays.day
		and fq.logdatetime - DATE_ADD(#stArgs.day#, INTERVAL 0 DAY) >=0  and DATE_ADD(#stArgs.day#, INTERVAL 7 DAY) - fq.logdatetime >=0
		group by day, statsDays.name, DAYOFWEEK(fq.logdatetime)
		order by 1 
	</cfquery>
</cfcase>

<cfdefaultcase>
	<cfquery datasource="#stArgs.dsn#" name="qGetPageStatsByWeek">
	-- now join our days table to the fqaudit table, to get the set we want. Note the query requires a day, month and year to be specified, for
	-- which we return the logins by day (nulls are returned if no logins during the day )
	select distinct day, statsDays.name,datepart(dw, fq.logdatetime) as loginday, count(distinct sessionId) as count_Ip
	from #application.dbowner#statsDays
	left join (
			select * from stats
				
	)fq on datepart(dw, fq.logdatetime) = statsDays.day
	 and datediff(day,fq.logdatetime,#createodbcdatetime(stArgs.day)#) <=0 and datediff(day,fq.logdatetime,#createodbcdatetime(stArgs.day+7)#) >=0
	group by day, statsDays.name, datepart(dw, fq.logdatetime)
	order by 1 
	</cfquery>
</cfdefaultcase>
</cfswitch>