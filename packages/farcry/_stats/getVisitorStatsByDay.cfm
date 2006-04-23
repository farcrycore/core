<!--- run the query to get counts of user activity by hour --->
<cfswitch expression="#application.dbtype#">
<cfcase value="ora">
	<cfquery datasource="#stArgs.dsn#" name="qGetPageStatsByDay">
		select distinct hour, TO_CHAR(fq.logdatetime,'hh') as loginhour, count(distinct sessionId) as count_Ip
		from #application.dbowner#statsHours
		left join (
				select * from stats
				where 1 = 1
				<cfif not stArgs.showAll>
					and pageid = '#stArgs.pageId#'
				</cfif>
		)fq on TO_CHAR(fq.logdatetime,'hh') = statsHours.hour
		and TO_CHAR(fq.logdatetime,'dd' ) = #DatePart("d", stArgs.day)# and TO_CHAR(fq.logdatetime,'mm') = #DatePart("m", stArgs.day)# and TO_CHAR(fq.logdatetime,'yyyy') = #DatePart("yyyy", stArgs.day)#
		group by hour, TO_CHAR(fq.logdatetime,'hh')
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
	<cfquery datasource="#stArgs.dsn#" name="qGetPageStatsByDay">
		select distinct hour, HOUR(fq.logdatetime) as loginhour, count(distinct sessionId) as count_Ip
		from #application.dbowner#statsHours
		left join tblTemp1 fq on HOUR(fq.logdatetime) = statsHours.hour
		and DAYOFMONTH(fq.logdatetime) = #DatePart("d", stArgs.day)# and MONTH(fq.logdatetime) = #DatePart("m", stArgs.day)# and YEAR(fq.logdatetime) = #DatePart("yyyy", stArgs.day)#
		group by hour, loginhour
		order by 1 
	</cfquery>
</cfcase>

<cfdefaultcase>
	<cfquery datasource="#stArgs.dsn#" name="qGetPageStatsByDay">
		select distinct hour, count(distinct sessionId) as count_Ip, datepart(hh, fq.logdatetime) as loginhour
		from #application.dbowner#statsHours
		left join (
				select * from stats
		)fq on datepart(hh, fq.logdatetime) = statsHours.hour
		and datepart(dd, fq.logdatetime) = #DatePart("d", stArgs.day)# and datepart(mm, fq.logdatetime) = #DatePart("m", stArgs.day)# and datepart(yyyy, fq.logdatetime) = #DatePart("yyyy", stArgs.day)#
		group by hour, datepart(hh, fq.logdatetime)
		order by 1 ;
	</cfquery>
</cfdefaultcase>
</cfswitch>