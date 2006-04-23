<!--- get page log entries --->
<cfquery name="qGetPageStats" datasource="#stArgs.dsn#">
	select * 
	from #application.dbowner#stats
	where 1 = 1
	<cfif isDefined("stArgs.before")>
	AND logdatetime < #stArgs.before#
	</cfif>
	<cfif isDefined("stArgs.after")>
	AND logdatetime > #stArgs.after#
	</cfif>
	order by logdatetime desc
</cfquery>

