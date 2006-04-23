<cfscript>
//get descendants over object
	oTree = createObject("component", "#application.packagepath#.farcry.tree");
	qDescendants = oTree.getDescendants(stArgs.navId);
</cfscript>

<!--- get page log entries --->
<cfswitch expression="#application.dbtype#">
	<cfcase value="ora">
		<cfquery name="qGetPageStats" datasource="#stArgs.dsn#">
		select to_char(logdatetime,'yyyy-mm-dd') as viewday,count(logId) as count_views
		from #application.dbowner#stats
		where 1=1 
		AND navid IN (<cfif qDescendants.recordcount>#QuotedValueList(qDescendants.objectid)#,</cfif>'#stArgs.navid#')
		<cfif isDefined("stArgs.before")>
		AND logdatetime < #stArgs.before#
		</cfif>
		<cfif isDefined("stArgs.after")>
		AND logdatetime > #stArgs.after#
		</cfif>
		group by to_char(logdatetime,'yyyy-mm-dd')
		order by to_char(logdatetime,'yyyy-mm-dd')
		</cfquery>
	</cfcase>
	<cfcase value="mysql">
		<cfquery name="qGetPageStats" datasource="#stArgs.dsn#">
		select replace(left(logdatetime, 10),"-",".") as viewday, 
				count(logId) as count_views 
		from #application.dbowner#stats
		where 1=1 
		AND navid IN (<cfif qDescendants.recordcount>#QuotedValueList(qDescendants.objectid)#,</cfif>'#stArgs.navid#')
		<cfif isDefined("stArgs.before")>
		AND logdatetime < #stArgs.before#
		</cfif>
		<cfif isDefined("stArgs.after")>
		AND logdatetime > #stArgs.after#
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
		<cfquery name="qGetPageStats" datasource="#stArgs.dsn#">
		select convert(varchar,logdatetime,102) as viewday,count(logId) as count_views
		from #application.dbowner#stats
		where 1=1 
		AND navid IN (<cfif qDescendants.recordcount>#QuotedValueList(qDescendants.objectid)#,</cfif>'#stArgs.navid#')
		<cfif isDefined("stArgs.before")>
		AND logdatetime < #stArgs.before#
		</cfif>
		<cfif isDefined("stArgs.after")>
		AND logdatetime > #stArgs.after#
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
