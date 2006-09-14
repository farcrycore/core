<!------------------------------------------------------------------------
audit.cfc (fourQ COAPI)
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/farcry_core/packages/farcry/audit.cfc,v 1.9 2005/04/11 03:05:53 paul Exp $
$Author: paul $
$Date: 2005/04/11 03:05:53 $
$Name: p300_b113 $
$Revision: 1.9 $

Released Under the "Common Public License 1.0"
http://www.opensource.org/licenses/cpl.php

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
Provides a basic audit subsystem to record what actions were taken when 
for the fourQ COAPI
------------------------------------------------------------------------->
<cfcomponent displayname="Audit" hint="Audit SubSystem for FourQ">

<cffunction name="deployAudit" hint="Deploy table structure for audit subsystem." returntype="struct">
	<!--- arguments --->
	<cfargument name="dsn" default="#application.dsn#" type="variableName" required="No">
	<cfargument name="bDropTable" default="false" type="boolean" required="No">
	<cfargument name="dbtype" default="#application.dbtype#" type="string" required="No">
	<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
	<!--- local vars --->
	<cfset var stStatus = StructNew()>
	
	<!--- check to see table exists --->
	<!--- <cfdump var="#application#"> --->
	<cfswitch expression="#arguments.dbtype#">
		<cfcase value="ora">
			<cfquery datasource="#arguments.dsn#" name="qCheck">
			SELECT count(*) AS tblExists FROM #arguments.dbowner#USER_TABLES WHERE TABLE_NAME = 'FQAUDIT'
			</cfquery>
		</cfcase>
		<cfcase value="mysql,mysql5">
		    <cfquery datasource="#arguments.dsn#" name="qCheck">
		        SHOW TABLES LIKE 'fqAudit'
		    </cfquery>
		
		    <cfset result = ArrayNew(1)>
		
		    <cfif IsDefined("qCheck.RecordCount") AND qCheck.RecordCount eq 1>
		        <cfset result[1] = 1>
		    <cfelse>
		        <cfset QueryNew('qCheck')>
		        <cfset QueryAddRow(qCheck)>
		        <cfset result[1] = 0>
		    </cfif>
		    <cfset temp = QueryAddColumn(qCheck,'tblExists',result)>
		</cfcase> 
		<cfcase value="postgresql">
         <cfquery datasource="#arguments.dsn#" name="qCheck">
            SELECT count(*) AS tblExists
            FROM   PG_TABLES
            WHERE  TABLENAME = 'fqaudit'
            AND    SCHEMANAME = 'public'
         </cfquery>
		</cfcase>
		<cfdefaultcase>
			<cfquery datasource="#arguments.dsn#" name="qCheck">
			SELECT count(*) AS tblExists FROM sysobjects 
			WHERE name = 'fqAudit'
			</cfquery>
		</cfdefaultcase>
	</cfswitch>
	
	<cfif qCheck.tblExists AND NOT bDropTable>
        <cfset stStatus.bSuccess = "false">
		<cfset stStatus.message = "fqAudit already exists in the database.">
		<cfset stStatus.detail = "fqAudit can be dropped and redeployed by setting the bDropTable=true argument. Dropping the table will result in a loss of all data.">
	<cfelse>
		
		<!--- drop the Audit tables --->
		<cfswitch expression="#arguments.dbtype#">
		<cfcase value="ora">
			<cfif qCheck.tblExists>
			<cfquery datasource="#arguments.dsn#" name="qDrop">
				DROP TABLE #arguments.dbowner#fqAudit
			</cfquery>
			</cfif>
			
			<!--- create the audit tables --->
			<cfquery datasource="#arguments.dsn#" name="qCreate">
			CREATE TABLE #arguments.dbowner#FQAUDIT(
				AUDITID VARCHAR2(50) NOT NULL ,
				OBJECTID VARCHAR2(50) NULL,
				DATETIMESTAMP DATE NOT NULL,
				USERNAME VARCHAR2(255) NOT NULL ,
				LOCATION VARCHAR2(255) NULL ,
				AUDITTYPE VARCHAR2(50) NOT NULL ,
				NOTE VARCHAR2(255) NULL ,
				CONSTRAINT PK_FQAUDIT PRIMARY KEY (AUDITID)
			) 
						
			</cfquery>
		
		</cfcase>
		<cfcase value="mysql,mysql5">			
			<cfquery datasource="#arguments.dsn#" name="qDrop">
				DROP TABLE if exists #arguments.dbowner#fqAudit
			</cfquery>
			
			<!--- create the audit tables --->
			<cfquery datasource="#arguments.dsn#" name="qCreate">
				CREATE TABLE #arguments.dbowner#fqAudit (
					AuditID char (50) NOT NULL ,
					objectid char (50) NULL ,
					datetimeStamp datetime NOT NULL ,
					username varchar (255) NOT NULL ,
					location varchar (255) NULL ,
					auditType char (50) NOT NULL ,
					note varchar (255) NULL,
					PRIMARY KEY(AuditID) 
				) 
			</cfquery>
		</cfcase>
		<cfcase value="postgresql">
         <cfif qCheck.tblExists>
			<cfquery datasource="#arguments.dsn#" name="qDrop">
				DROP TABLE fqAudit
			</cfquery>
			</cfif>
			
			<!--- create the audit tables --->
			<cfquery datasource="#arguments.dsn#" name="qCreate">
			CREATE TABLE #arguments.dbowner#FQAUDIT(
				AUDITID VARCHAR(50) NOT NULL PRIMARY KEY,
				OBJECTID VARCHAR(50) NULL,
				DATETIMESTAMP TIMESTAMP NOT NULL,
				USERNAME VARCHAR(255) NOT NULL ,
				LOCATION VARCHAR(255) NULL ,
				AUDITTYPE VARCHAR(50) NOT NULL ,
				NOTE VARCHAR(255) NULL
			) 
						
			</cfquery>
        </cfcase>
		<cfdefaultcase>
			<cfif qCheck.tblExists>
			<cfquery datasource="#arguments.dsn#" name="qDrop">
			if exists (select * from sysobjects where name = '#arguments.dbowner#fqAudit')
			DROP TABLE fqAudit
	
			-- return recordset to stop CF bombing out?!?
			select count(*) as blah from sysobjects
			</cfquery>
			</cfif>
			
			<!--- create the audit tables --->
			<cfquery datasource="#arguments.dsn#" name="qCreate">
			CREATE TABLE #arguments.dbowner#fqAudit (
				[AuditID] [char] (50) NOT NULL ,
				[objectid] [char] (50) NULL ,
				[datetimeStamp] [datetime] NOT NULL ,
				[username] [varchar] (255) NOT NULL ,
				[location] [varchar] (255) NULL ,
				[auditType] [char] (50) NOT NULL ,
				[note] [varchar] (255) NULL 
			) ON [PRIMARY];
			
			ALTER TABLE [dbo].[fqAudit] WITH NOCHECK ADD 
				CONSTRAINT [PK_fqAudit] PRIMARY KEY  NONCLUSTERED 
				(
					[AuditID]
				)  ON [PRIMARY];
			</cfquery>
		</cfdefaultcase>
		</cfswitch>
		<cfset stStatus.message = "fqAudit created.">
		<cfset stStatus.detail = "fqAudit created.">
        <cfset stStatus.bSuccess = "true">
	</cfif>
	
	
	
	<cfreturn stStatus>
</cffunction>

<cffunction name="logActivity" hint="Write log entry to Audit table." returntype="boolean">
	<!--- arguments --->
	<cfargument name="username" type="string" required="Yes">
	<cfargument name="auditType" type="string" required="Yes">
	<cfargument name="objectID" type="string" required="No" default="">
	<cfargument name="location" type="string" required="No" default="">
	<cfargument name="note" type="string" required="No" default="">
	<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
	<cfargument name="dsn" default="#application.dsn#" type="string" required="No">
	<!--- local vars --->
	<cfset var datetimestamp = Now()>
	<cfset var bSuccess = true>
	<!--- check values --->	
	<cfif not len(arguments.username)><cfset arguments.username = "unknown"></cfif>
		
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
	<cfargument name="dsn" default="#application.dsn#" type="string" required="No">
	<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
	<!--- local vars --->
	<cfset var qLog = "">
	
	<cfquery datasource="#arguments.dsn#" name="qLog" maxrows="#arguments.maxrows#">
	SELECT * FROM #arguments.dbowner#fqAudit
	WHERE 1=1
	<cfif isDefined("arguments.objectid")>
	AND objectid = '#arguments.objectid#'
	</cfif>
	<cfif isDefined("arguments.auditType") and arguments.auditType neq "all">
	AND auditType = '#arguments.auditType#'
	</cfif>
	<cfif isDefined("arguments.username") and arguments.username neq "all">
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

<cffunction name="getAuditUsers" hint="Returns a query of users in audit log" returntype="query">
	<cfargument name="dsn" default="#application.dsn#" type="string" required="No">
	<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
	<!--- local vars --->
	<cfset var qLog = "">
	
	<cfquery datasource="#arguments.dsn#" name="qLog" maxrows="#arguments.maxrows#">
	SELECT distinct(username) 
	FROM #arguments.dbowner#fqAudit
	ORDER BY username
	</cfquery>
	
	<cfreturn qLog>
</cffunction> 

<cffunction name="getAuditActivities" hint="Returns a query of activities in audit log" returntype="query">	
	<cfargument name="dsn" default="#application.dsn#" type="string" required="No">
	<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
	<!--- local vars --->
	<cfset var qLog = "">
	
	<cfquery datasource="#arguments.dsn#" name="qLog" maxrows="#arguments.maxrows#">
	SELECT distinct(auditType) 
	FROM #arguments.dbowner#fqAudit
	ORDER BY auditType
	</cfquery>
	
	<cfreturn qLog>
</cffunction> 

<cffunction name="getUserActivityDaily" hint="Return a query of audit entries for user logins over time." returntype="query">
	<!--- arguments --->
	<cfargument name="day" required="No" type="date" default="#Now()#">
	<cfargument name="dsn" default="#application.dsn#" type="string" required="No">
	<cfargument name="dbtype" default="#application.dbtype#" type="string" required="No">
	<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
	<!--- local vars --->
	<cfset var qLog = "">	
	
	<cfswitch expression="#arguments.dbtype#">
	    <cfcase value="ora">
            <cfquery datasource="#arguments.dsn#" name="qLog">
            select distinct hour, TO_CHAR(fq.datetimestamp, 'hh24') as loginhour, count(fq.auditID) as count_logins
   			from #arguments.dbowner#statsHours
   			left join (
   			        select * from #arguments.dbowner#fqaudit
   			        where auditType = 'dmSec.login'
   			) fq on 
			    TO_CHAR(fq.datetimestamp, 'hh24') =  statsHours.hour
   			and TO_CHAR(fq.datetimestamp,'mm/dd/yyyy')   = <cfqueryparam cfsqltype="CF_SQL_CHAR" value="#dateFormat(arguments.day,'mm/dd/yyyy')#" />
   			group by hour, TO_CHAR(fq.datetimestamp, 'hh24')
   			order by 1 
   			</cfquery>
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
	<cfargument name="dsn" default="#application.dsn#" type="string" required="No">
	<cfargument name="dbtype" default="#application.dbtype#" type="string" required="No">
	<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
	<!--- local vars --->
	<cfset var qLog = "">
	
	<cfswitch expression="#arguments.dbtype#">
	    <cfcase value="ora">
            <cfquery datasource="#arguments.dsn#" name="qLog">
    		select distinct day, statsDays.name, to_char(fq.datetimestamp,'D') as loginday, count(fq.auditID) as count_logins
				from #arguments.dbowner#statsDays
				left join (
   			        select * from fqaudit
   			        where auditType = 'dmSec.login'
   			    ) fq on to_char(fq.datetimestamp,'D') = statsDays.day
					and fq.datetimestamp >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.day#" />     -- newer than the day we were passed
					and fq.datetimestamp <= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.day+7#" /> 	 -- older than the day plus one week
				group by day, statsDays.name, to_char(fq.datetimestamp,'D')
				order by 1 
            </cfquery>
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
			from #arguments.dbowner#statsDays
			left join (
			        select * from #arguments.dbowner#fqaudit
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
