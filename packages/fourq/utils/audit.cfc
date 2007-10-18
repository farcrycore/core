<!------------------------------------------------------------------------
audit.cfc (fourQ COAPI)
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/utils/audit.cfc,v 1.19 2004/05/20 00:23:18 brendan Exp $
$Author: brendan $
$Date: 2004/05/20 00:23:18 $
$Name:  $
$Revision: 1.19 $

Released Under the "Common Public License 1.0"
http://www.opensource.org/licenses/cpl.php

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
Provides a basic audit subsystem to record what actions were taken when 
for the fourQ COAPI
------------------------------------------------------------------------->
<cfcomponent displayname="Audit" hint="Audit SubSystem for FourQ">

<cffunction name="deployAudit" hint="DEPRECATED; Deploy table structure for audit subsystem." returntype="void">
	<cfthrow detail="DEPRECATED; use ./packages/schema/fqaudit.cfc instead." />
</cffunction>

<cffunction name="logActivity" hint="Write log entry to Audit table." returntype="boolean">
	<!--- arguments --->
	<cfargument name="username" type="string" required="Yes">
	<cfargument name="auditType" type="string" required="Yes">
	<cfargument name="objectID" type="string" required="No" default="">
	<cfargument name="location" type="string" required="No" default="">
	<cfargument name="note" type="string" required="No" default="">
	<cfargument name="dsn" default="#application.dsn#" type="variableName" required="No">
	<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
	<!--- local vars --->
	<cfset var datetimestamp = Now()>
	<cfset var bSuccess = true>		
	<cfset var insertLog = queryNew("blah") />
	
	<cfquery datasource="#arguments.dsn#" name="insertLog">
	INSERT INTO #arguments.dbowner#fqAudit
	(AuditID, objectID, datetimeStamp, username, location, auditType, note)
	VALUES
	('#createUUID()#', '#arguments.objectid#', #datetimestamp#, '#arguments.username#', '#arguments.location#', '#arguments.auditType#', '#arguments.note#')
	</cfquery>
	
	<cfreturn bSuccess>
</cffunction>

<!--- 
need a bunch of functions to get audit data here
--->
<cffunction name="getAuditLog" hint="Return a query of audit entries based on parameters passed in." returntype="query">
	<!--- arguments --->
	<cfargument name="objectID" required="No" type="string">
	<cfargument name="before" required="No" type="date">
	<cfargument name="after" required="No" type="date">
	<cfargument name="username" required="No" type="string">
	<cfargument name="location" required="No" type="string">
	<cfargument name="auditType" required="No" type="string">
	<cfargument name="maxRows" required="No" type="numeric" default="100">
	<cfargument name="ordering" required="No" type="string" default="desc">
	<cfargument name="dsn" default="#application.dsn#" type="variableName" required="No">
	<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
	<!--- local vars --->
	<cfset var qLog = "">
	
	<cfquery datasource="#arguments.dsn#" name="qLog" maxrows="#arguments.maxrows#">
	SELECT * FROM #arguments.dbowner#fqAudit
	WHERE 1=1
	<cfif isDefined("arguments.objectid")>
	AND objectid = '#arguments.objectid#'
	</cfif>
	<cfif isDefined("arguments.auditType")>
	AND auditType = '#arguments.auditType#'
	</cfif>
	<cfif isDefined("arguments.username")>
	AND username = '#arguments.username#'
	</cfif>
	<cfif isDefined("arguments.location")>
	AND location = '#arguments.location#'
	</cfif>
	<cfif isDefined("arguments.before")>
	AND datetimestamp < #arguments.before#
	</cfif>
	<cfif isDefined("arguments.after")>
	AND datetimestamp > #arguments.after#
	</cfif>
	
	ORDER BY datetimestamp #arguments.ordering#
	</cfquery>
	
	<cfreturn qLog>
</cffunction> 

<cffunction name="getUserActivityDaily" hint="Return a query of audit entries for user logins over time." returntype="query">
	<!--- arguments --->
	<cfargument name="day" required="No" type="date" default="#Now()#">
	<cfargument name="dsn" default="#application.dsn#" type="variableName" required="No">
	<cfargument name="dbtype" default="#application.dbtype#" type="variableName" required="No">
	<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
	<!--- local vars --->
	<cfset var qLog = "">
	<cfset var qDrop = queryNew("blah") />	
	<cfset var qCreate = queryNew("blah") />	
	<cfset var qPopulate = queryNew("blah") />			
	
	<cfswitch expression="#arguments.dbtype#">
	    <cfcase value="ora">
		<!--- to be written --->
	    </cfcase>
	    <cfcase value="mysql,mysql5"><!--- no subqueries allowed in mysql, so workaround.... --->
			<cfquery datasource="#arguments.dsn#" name="qDrop">
				drop table if exists fqTemp			
			</cfquery>
			<cfquery datasource="#arguments.dsn#" name="qCreate">
				create temporary table fqTemp  (
					AuditID char (50) NOT NULL ,
					objectid char (50) NULL ,
					datetimeStamp datetime NOT NULL ,
					username varchar (255) NOT NULL ,
					location varchar (255) NULL ,
					auditType char (50) NOT NULL ,
					note varchar (255) NULL
				)  
			</cfquery>
			<cfquery datasource="#arguments.dsn#" name="qPopulate">
				insert into fqTemp
				select * from fqAudit
				where auditType = 'dmsec.login'
			</cfquery>
			<cfquery datasource="#arguments.dsn#" name="qLog">
				select distinct 
					hour, 
					hour(fq.datetimestamp) as loginhour, 
					count(fq.auditID) as count_logins
				from statsHours
				left join fqTemp fq on hour(fq.datetimestamp) = statsHours.hour
				and dayofmonth(fq.datetimestamp)  = #DatePart("d", arguments.day)# 
				and month(fq.datetimestamp) = #DatePart("m", arguments.day)# 
				and year(fq.datetimestamp) = #DatePart("yyyy", arguments.day)#
				group by hour, hour(fq.datetimestamp) 
				order by 1 
			</cfquery>
	    </cfcase>    
	    <cfcase value="postgresql">
            <!------------------------------------------------------------------------------
               I have no idea if this will work.. KDS20040212
            ------------------------------------------------------------------------------->
            <cfquery datasource="#arguments.dsn#" name="qLog">
   			select distinct hour, date_part('h', fq.datetimestamp) as loginhour, count(fq.auditID) as count_logins
   			from statsHours
   			left join (
   			        select * from #arguments.dbowner#fqaudit
   			        where auditType = 'dmsec.login'
   			)fq on date_part('h', fq.datetimestamp) = statsHours.hour
   			and date_part('d', fq.datetimestamp) = #DatePart("d", arguments.day)# 
   			and date_part('mon', fq.datetimestamp) = #DatePart("m", arguments.day)# 
   			and date_part('y', fq.datetimestamp) = #DatePart("yyyy", arguments.day)#
   			group by hour, date_part('h', fq.datetimestamp)
   			order by 1 
   			</cfquery>
       </cfcase>
		<cfdefaultcase>
			<!--- run the query to get counts of user activity by hour --->
			<cfquery datasource="#arguments.dsn#" name="qLog">
			-- now join our hours table to the fqaudit table, to get the set we want. Note the query requires a day, month and year to be specified, for
			-- which we return the logins by hour (nulls are returned if no logins during the hour )
			select distinct hour, datepart(hh, fq.datetimestamp) as loginhour, count(fq.auditID) as count_logins
			from statsHours
			left join (
			        select * from #arguments.dbowner#fqaudit
			        where auditType = 'dmsec.login'
			)fq on datepart(hh, fq.datetimestamp) = statsHours.hour
			and datepart(dd, fq.datetimestamp) = #DatePart("d", arguments.day)# 
			and datepart(mm, fq.datetimestamp) = #DatePart("m", arguments.day)# 
			and datepart(yyyy, fq.datetimestamp) = #DatePart("yyyy", arguments.day)#
			group by hour, datepart(hh, fq.datetimestamp)
			order by 1 
			</cfquery>
	    </cfdefaultcase>
</cfswitch>
	<cfreturn qLog>
</cffunction> 

<cffunction name="getUserActivityWeekly" hint="Return a query of audit entries for user logins over time." returntype="query">
	<!--- arguments --->
	<cfargument name="day" required="No" type="date" default="#Now()#">
	<cfargument name="dsn" default="#application.dsn#" type="variableName" required="No">
	<cfargument name="dbtype" default="#application.dbtype#" type="variableName" required="No">
	<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
	<!--- local vars --->
	<cfset var qLog = "">
	<cfset var qDrop = queryNew("blah") />	
	<cfset var qCreate = queryNew("blah") />	
	<cfset var qPopulate = queryNew("blah") />	
	
	<cfswitch expression="#arguments.dbtype#">
	    <cfcase value="ora">
		<!--- to be written --->
	    </cfcase>
	    <cfcase value="mysql,mysql5"><!--- no subqueries allowed in mysql, so workaround.... --->
			<cfquery datasource="#arguments.dsn#" name="qDrop">
				drop table if exists fqTemp			
			</cfquery>
			<cfquery datasource="#arguments.dsn#" name="qCreate">
				create temporary table fqTemp  (
					AuditID char (50) NOT NULL ,
					objectid char (50) NULL ,
					datetimeStamp datetime NOT NULL ,
					username varchar (255) NOT NULL ,
					location varchar (255) NULL ,
					auditType char (50) NOT NULL ,
					note varchar (255) NULL
				)  
			</cfquery>
			<cfquery datasource="#arguments.dsn#" name="qPopulate">
				insert into fqTemp
				select * from fqAudit
				where auditType = 'dmsec.login'
			</cfquery>
			
			<cfquery datasource="#arguments.dsn#" name="qLog">
				select distinct day, statsDays.name, dayofweek(fq.datetimestamp) as loginday, count(fq.auditID) as count_logins
				from statsDays
				left join fqTemp fq on dayofweek(fq.datetimestamp) = statsDays.day
					and fq.datetimestamp >= #createodbcdatetime(arguments.day)# 	-- newer than the day we were passed
					and fq.datetimestamp <= #createodbcdatetime(arguments.day+7)# 	-- older than the day plus one week
				group by day, statsDays.name, dayofweek(fq.datetimestamp)
				order by 1 
			</cfquery>
	    </cfcase> 
		<cfcase value="postgresql">
            <cfquery datasource="#arguments.dsn#" name="qLog">
   			select distinct day, statsDays.name,date_part('dow', fq.datetimestamp) as loginday, count(fq.auditID) as count_logins
   			from statsDays
   			left join (
   			        select * from fqaudit
   			        where auditType = 'dmsec.login'
   			)fq on date_part('dow', fq.datetimestamp) = statsDays.day
   			 and extract('day' from (fq.datetimestamp - '#dateFormat(arguments.day,"mm/dd/yyyy")#')) <=0 and extract('day' from (fq.datetimestamp - '#dateFormat(arguments.day,"mm/dd/yyyy")#')) >=0
   			group by day, statsDays.name, date_part('dow', fq.datetimestamp)
   			order by 1 
   			</cfquery>
        </cfcase> 
	    <cfdefaultcase>
			<!--- run the query to get counts of user activity by hour --->
			<cfquery datasource="#arguments.dsn#" name="qLog">
			-- now join our days table to the fqaudit table, to get the set we want. Note the query requires a day, month and year to be specified, for
			-- which we return the logins by day (nulls are returned if no logins during the day )
			select distinct day, statsDays.name,datepart(dw, fq.datetimestamp) as loginday, count(fq.auditID) as count_logins
			from statsDays
			left join (
			        select * from fqaudit
			        where auditType = 'dmsec.login'
			)fq on datepart(dw, fq.datetimestamp) = statsDays.day
			 and datediff(day,fq.datetimestamp,#createodbcdatetime(arguments.day)#) <=0 and datediff(day,fq.datetimestamp,#createodbcdatetime(arguments.day+7)#) >=0
			group by day, statsDays.name, datepart(dw, fq.datetimestamp)
			order by 1 
			</cfquery>
	    </cfdefaultcase>
	</cfswitch>
			
	<cfreturn qLog>
</cffunction> 
</cfcomponent>
