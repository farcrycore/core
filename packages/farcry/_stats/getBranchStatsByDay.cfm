<cfscript>
//get descendants over object
	oTree = createObject("component", "#application.packagepath#.farcry.tree");
	qDescendants = oTree.getDescendants(stArgs.navId);
</cfscript>

<!--- run the query to get counts of user activity by hour --->
<cfswitch expression="#application.dbtype#">
<cfcase value="ora">
	<cfquery datasource="#stArgs.dsn#" name="qGetPageStatsByDay">
		select distinct hour, TO_CHAR(fq.logdatetime,'hh') as loginhour, count(fq.logId) as count_views
		from #application.dbowner#statsHours
		left join (
				select * from stats
				where 1 = 1
				<cfif not stArgs.showAll>
					AND navid IN (<cfif qDescendants.recordcount>#QuotedValueList(qDescendants.objectid)#,</cfif>'#stArgs.navid#')
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
			`LOGDATETIME` DATETIME NOT NULL
			)
	</cfquery>
	<cfquery datasource="#stArgs.dsn#" name="temp3">
		INSERT INTO tblTemp1 (LOGID,LOGDATETIME) 
			SELECT LOGID, LOGDATETIME FROM #application.dbowner#Stats 
			WHERE 1 = 1 
			<CfIF not stArgs.showAll>
				AND navid IN (<cfif qDescendants.recordcount>#QuotedValueList(qDescendants.objectid)#,</cfif>'#stArgs.navid#')
			</CFIF>
	</cfquery>
	<!--- do main query --->
	<cfquery datasource="#stArgs.dsn#" name="qGetPageStatsByDay">
		select distinct hour, HOUR(fq.logdatetime) as loginhour, count(fq.logId) as count_views
		from #application.dbowner#statsHours
		left join tblTemp1 fq on HOUR(fq.logdatetime) = statsHours.hour
		and DAYOFMONTH(fq.logdatetime) = #DatePart("d", stArgs.day)# and MONTH(fq.logdatetime) = #DatePart("m", stArgs.day)# and YEAR(fq.logdatetime) = #DatePart("yyyy", stArgs.day)#
		group by hour, loginhour
		order by 1 
	</cfquery>
</cfcase>

<cfdefaultcase>
	<cfquery datasource="#stArgs.dsn#" name="qGetPageStatsByDay">
		select distinct hour, datepart(hh, fq.logdatetime) as loginhour, count(fq.logId) as count_views
		from #application.dbowner#statsHours
		left join (
				select * from stats
				where 1 = 1
				<cfif not stArgs.showAll>
					AND navid IN (<cfif qDescendants.recordcount>#QuotedValueList(qDescendants.objectid)#,</cfif>'#stArgs.navid#')
				</cfif>
		)fq on datepart(hh, fq.logdatetime) = statsHours.hour
		and datepart(dd, fq.logdatetime) = #DatePart("d", stArgs.day)# and datepart(mm, fq.logdatetime) = #DatePart("m", stArgs.day)# and datepart(yyyy, fq.logdatetime) = #DatePart("yyyy", stArgs.day)#
		group by hour, datepart(hh, fq.logdatetime)
		order by 1 ;
	</cfquery>
</cfdefaultcase>
</cfswitch>