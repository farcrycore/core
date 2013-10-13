<cfcomponent 
	displayname="FarCry Log" 
	hint="Manages FarCry Event logs" 
	extends="types" output="false" 
	bRefObjects="false" fuAlias="fc-log" bObjectBroker="0" bSystem="true"
	icon="icon-list">

	<cfproperty name="object" type="uuid" default="" hint="The associated object" ftSeq="1" ftFieldset="" ftLabel="Object" ftType="string" />
	<cfproperty name="type" type="string" default="" hint="The type of the object or event group (e.g. security, coapi)" ftSeq="2" ftFieldset="" ftLabel="Object type" ftType="string" />
	<cfproperty name="event" type="string" default="" hint="The event this log is associated with" ftSeq="3" ftFieldset="" ftLabel="Event" ftType="string" />
	<cfproperty name="location" type="string" default="" hint="The location of the event if relevant" ftSeq="4" ftFieldset="" ftLabel="Location" ftType="string" />
	<cfproperty name="userid" type="string" default="" hint="The id of the user" ftSeq="5" ftFieldset="" ftLabel="User" ftType="string" />
	<cfproperty name="ipaddress" type="string" default="" hint="IP address of user" ftSeq="6" ftFieldset="" ftLabel="IP address" ftType="string" />
	<cfproperty name="notes" type="longchar" default="" hint="Extra notes" ftSeq="7" ftFieldset="" ftLabel="Notes" ftType="longchar" />

	<cffunction name="createData" access="public" returntype="any" output="false" hint="Creates an instance of an object">
		<cfargument name="stProperties" type="struct" required="true" hint="Structure of properties for the new object instance">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Created">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		<cfargument name="bAudit" type="boolean" required="false" hint="Set to false to disable logging" />
		
		<cfif not structkeyexists(arguments.stProperties,"user") or not len(arguments.stProperties.user)>
			<cfset arguments.stProperties.user = "anonymous" />
		</cfif>
		
		<cfif structkeyexists(arguments.stProperties,"object") and len(arguments.stProperties.object) and (not structkeyexists(arguments.stProperties,"type") or not len(arguments.stProperties.type))>
			<cfset arguments.stProperties.type = findType(arguments.stProperties.object) />
		</cfif>
		
		<cfset arguments.bAudit = false />
		
		<cfreturn super.createData(argumentCollection=arguments) />
	</cffunction>
	
	<cffunction name="getUserList" access="public" output="false" returntype="string" hint="Returns a list of users that can be filtered by">
		<cfset var qUsers = "" />
		
		<cfquery datasource="#application.dsn#" name="qUsers">
			select distinct userid
			from		#application.dbowner#farLog
			order by	userid
		</cfquery>
		
		<cfreturn ":All,#valuelist(qUsers.userid)#" />
	</cffunction>
	
	<cffunction name="getTypeList" access="public" output="false" returntype="string" hint="Returns a list of types that can be filtered by">
		<cfset var qTypes = "" />
		
		<cfquery datasource="#application.dsn#" name="qTypes">
			select distinct type
			from		#application.dbowner#farLog
			order by	type
		</cfquery>
		
		<cfreturn ":All,#valuelist(qTypes.type)#" />
	</cffunction>
	
	<cffunction name="getTypeEventList" access="public" output="false" returntype="string" hint="Returns a list of types and events that can be filtered by">
		<cfset var qTypes = "" />
		<cfswitch expression="#application.dbtype#">
		    <cfcase value="ora">
				<cfquery datasource="#application.dsn#" name="qTypes">
				select distinct CONCAT(CONCAT(type,'.'),event) typeevent
				from #application.dbowner#farLog
				order by typeevent
				</cfquery>
			</cfcase>
			
			<cfdefaultcase>
				<cfquery datasource="#application.dsn#" name="qTypes">
					select distinct type + '.' + event as typeevent
					from		#application.dbowner#farLog
					order by	type + '.' + event
				</cfquery>
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn ":All,#valuelist(qTypes.typeevent)#" />
	</cffunction>
	
	<cffunction name="getEventList_Security" access="public" output="false" returntype="string" hint="Returns a list of events that can be filtered by">
		<cfset var qEvents = "" />
		
		<cfquery datasource="#application.dsn#" name="qEvents">
			select distinct event
			from		#application.dbowner#farLog
			where		type=<cfqueryparam cfsqltype="cf_sql_varchar" value="security">
			order by	event
		</cfquery>
		
		<cfreturn ":All,#valuelist(qEvents.event)#" />
	</cffunction>

	<cffunction name="getUserActivityDaily" hint="Return a query of audit entries for user logins over time." returntype="query">
		<cfargument name="day" required="No" type="date" default="#Now()#" />
		<cfargument name="type" type="string" required="false" hint="Restrict results by log type" />
		<cfargument name="event" type="string" required="false" hint="Restrict results by event" />
		
		<!--- local vars --->
		<cfset var qLog = "" />	
		<cfset var thisDay	= '' />
		<cfset var qDrop	= '' />
		<cfset var qCreate	= '' />
		<cfset var qPopulate	= '' />

		<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />
		
		<cfswitch expression="#application.dbtype#">
		    <cfcase value="ora">
	            <cfquery datasource="#application.dsn#" name="qLog">
		            select distinct hour, TO_CHAR(fq.datetimecreated, 'hh24') as loghour, count(fq.objectid) as total
		   			from 		#application.dbowner#statsHours
					   			left join (
									select	* 
									from 	#application.dbowner#farLog
									where 	1=1
											<cfif structkeyexists(arguments,"type")>and upper(type)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.type)#"></cfif>
											<cfif structkeyexists(arguments,"event")>and upper(event)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.event)#"></cfif>
					   			) fq on TO_CHAR(fq.datetimecreated, 'hh24') =  statsHours.hour
		   						and TO_CHAR(fq.datetimecreated,'mm/dd/yyyy')=<cfqueryparam cfsqltype="CF_SQL_CHAR" value="#dateFormat(arguments.day,'mm/dd/yyyy')#" />
		   			group by 	hour, TO_CHAR(fq.datetimecreated, 'hh24')
		   			order by 	1 
	   			</cfquery>
		    </cfcase>
		    <cfcase value="mysql,mysql5"><!--- no subqueries allowed in mysql, so workaround.... --->
				<cfquery datasource="#application.dsn#" name="qDrop">
					drop table if exists fqTemp			
				</cfquery>
				<cfquery datasource="#application.dsn#" name="qCreate">
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
				<cfquery datasource="#application.dsn#" name="qPopulate">
					insert into fqTemp
					select	objectid as AuditID, object as objectid, datetimecreated as datetimeStamp, userid as username, location, type as auditType, notes as note
					from	farLog
					where 	1=1
							<cfif structkeyexists(arguments,"type")>and upper(type)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.type)#"></cfif>
							<cfif structkeyexists(arguments,"event")>and upper(event)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.event)#"></cfif>
				</cfquery>
				<cfquery datasource="#application.dsn#" name="qLog">
					select distinct hour, hour(fq.datetimestamp) as loghour, count(fq.auditID) as total
					from 		statsHours
								left join 
								fqTemp fq 
								on hour(fq.datetimestamp) = statsHours.hour
								and dayofmonth(fq.datetimestamp)  = #DatePart("d", arguments.day)# 
								and month(fq.datetimestamp) = #DatePart("m", arguments.day)# 
								and year(fq.datetimestamp) = #DatePart("yyyy", arguments.day)#
		   			group by 	hour, hour(fq.datetimestamp) 
					order by 	1 
				</cfquery>
		    </cfcase>
		    
			<cfcase value="postgresql">
				<!---
				adapted by Friedrich Dimmel (friedrich.dimmel@siemens.com)
				--->
				<cfset thisDay = DateFormat(arguments.day, "YYYY-MM-DD")>
				<cfquery datasource="#application.dsn#" name="qLog">
					SELECT DISTINCT hour, TO_CHAR(j.datetimecreated, 'HH24') AS loghour, COUNT(j.objectid) AS total
					FROM 		statsHours
								LEFT JOIN (
									SELECT 	datetimecreated, objectid
									FROM 	#application.dbowner#farLog
									WHERE 	1=1
											<cfif structkeyexists(arguments,"type")>and upper(type)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.type)#"></cfif>
											<cfif structkeyexists(arguments,"event")>and upper(event)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.event)#"></cfif>
									AND 	TO_CHAR(datetimecreated, 'YYYY-MM-DD') = '#thisDay#'
								) j 
								ON TO_CHAR(j.datetimecreated, 'HH24') = statsHours.hour
					GROUP BY 	hour, TO_CHAR(j.datetimecreated, 'HH24')
					ORDER BY 	hour
				</cfquery>
			</cfcase>
	
			<cfdefaultcase>
				<!--- run the query to get counts of user activity by hour --->
				<cfquery datasource="#application.dsn#" name="qLog">
					-- now join our hours table to the fqaudit table, to get the set we want. Note the query requires a day, month and year to be specified, for
					-- which we return the logins by hour (nulls are returned if no logins during the hour )
					select distinct hour, datepart(hh, fq.datetimecreated) as loghour, count(fq.objectid) as total
					from 		statsHours
								left join (
							        select	* 
							        from 	#application.dbowner#farLog
									WHERE 	1=1
											<cfif structkeyexists(arguments,"type")>and upper(type)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.type)#"></cfif>
											<cfif structkeyexists(arguments,"event")>and upper(event)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.event)#"></cfif>
								)fq 
								on datepart(hh, fq.datetimecreated) = statsHours.hour
								and datepart(dd, fq.datetimecreated) = #DatePart("d", arguments.day)# 
								and datepart(mm, fq.datetimecreated) = #DatePart("m", arguments.day)# 
								and datepart(yyyy, fq.datetimecreated) = #DatePart("yyyy", arguments.day)#
					group by 	hour, datepart(hh, fq.datetimecreated)
					order by 	1 
				</cfquery>
		    </cfdefaultcase>
		</cfswitch>
	
		<cfreturn qLog>
	</cffunction> 

	<cffunction name="getUserActivityWeekly" hint="Return a query of audit entries for user logins over time." returntype="query">
		<cfargument name="day" required="No" type="date" default="#Now()#" />
		<cfargument name="type" type="string" required="false" hint="Restrict results by log type" />
		<cfargument name="event" type="string" required="false" hint="Restrict results by event" />
		
		<!--- local vars --->
		<cfset var qLog = "">
		<cfset var thisWeek	= '' />
		<cfset var nextWeek	= '' />
		<cfset var qDrop	= '' />
		<cfset var qCreate	= '' />
		<cfset var qPopulate	= '' />

		<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />
	
		<farcry:deprecated message="getUserActivityWeekly should be replaced with ????" />
		
		<cfswitch expression="#application.dbtype#">
		    <cfcase value="ora">
	            <cfquery datasource="#application.dsn#" name="qLog">
	    			select distinct day, statsDays.name, to_char(fq.datetimecreated,'D') as logday, count(fq.objectid) as total
					from 		#application.dbowner#statsDays
								left join (
				   			        select	*
				   			        from	#application.dbowner#farLog
									where 	1=1
											<cfif structkeyexists(arguments,"type")>and upper(type)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.type)#"></cfif>
											<cfif structkeyexists(arguments,"event")>and upper(event)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.event)#"></cfif>
				   			    ) fq 
				   			    on to_char(fq.datetimecreated,'D') = statsDays.day
								and fq.datetimecreated >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.day#" />     -- newer than the day we were passed
								and fq.datetimecreated <= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.day+7#" /> 	 -- older than the day plus one week
					group by 	day, statsDays.name, to_char(fq.datetimecreated,'D')
					order by 	1 
	            </cfquery>
		    </cfcase>
		    <cfcase value="mysql,mysql5"><!--- no subqueries allowed in mysql, so workaround.... --->
				<cfquery datasource="#application.dsn#" name="qDrop">
					drop table if exists fqTemp			
				</cfquery>
				<cfquery datasource="#application.dsn#" name="qCreate">
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
				<cfquery datasource="#application.dsn#" name="qPopulate">
					insert 	into fqTemp
					select 	* 
					from 	#application.dbowner#farLog
					where 	1=1
							<cfif structkeyexists(arguments,"type")>and upper(type)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.type)#"></cfif>
							<cfif structkeyexists(arguments,"event")>and upper(event)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.event)#"></cfif>
				</cfquery>
				
				<cfquery datasource="#application.dsn#" name="qLog">
					select distinct day, statsDays.name, dayofweek(fq.datetimecreated) as logday, count(fq.objectid) as totalt_logins
					from 		statsDays
								left join 
								fqTemp fq 
								on dayofweek(fq.datetimecreated) = statsDays.day
								and fq.datetimecreated >= #createodbcdatetime(arguments.day)# 	-- newer than the day we were passed
								and fq.datetimecreated <= #createodbcdatetime(arguments.day+7)# 	-- older than the day plus one week
					group by day, statsDays.name, dayofweek(fq.datetimecreated)
					order by 1 
				</cfquery>
		    </cfcase>
	   
			<cfcase value="postgresql">
				<!---
				adapted by Friedrich Dimmel (friedrich.dimmel@siemens.com)
				--->
				<cfset thisWeek = DateFormat(arguments.day, "yyyy-mm-dd")>
				<cfset nextWeek = DateFormat(DateAdd('d', '7', arguments.day), "yyyy-mm-dd")>
				
				<cfquery datasource="#application.dsn#" name="qLog">
					SELECT DISTINCT day, statsDays.name, TO_CHAR(j.datetimecreated, 'D') AS logday, COUNT(j.objectid) AS total
					FROM 		statsDays
								LEFT JOIN (
									SELECT 	datetimecreated, auditID
									FROM 	#application.dbowner#farLog
									WHERE 	TO_CHAR(datetimecreated, 'YYYY-MM-DD') >= '#thisWeek#'
											AND TO_CHAR(datetimecreated, 'YYYY-MM-DD') < '#nextWeek#'
											<cfif structkeyexists(datetimecreated,"type")>and upper(type)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.type)#"></cfif>
											<cfif structkeyexists(datetimecreated,"event")>and upper(event)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.event)#"></cfif>
								) j 
								ON TO_CHAR(j.datetimecreated, 'D') = statsDays.day
					GROUP BY day, statsDays.name, TO_CHAR(j.datetimecreated, 'D')
					ORDER BY day
				</cfquery>
			</cfcase>
	
			<cfdefaultcase>
				<!--- run the query to get counts of user activity by hour --->
				<cfquery datasource="#application.dsn#" name="qLog">
					-- now join our days table to the fqaudit table, to get the set we want. Note the query requires a day, month and year to be specified, for
					-- which we return the logins by day (nulls are returned if no logins during the day )
					select distinct day, statsDays.name,datepart(dw, fq.datetimecreated) as logday, count(fq.objectid) as total
					from 		#application.dbowner#statsDays
								left join (
									select	* 
									from 	#application.dbowner#farLog
									where 	1=1
											<cfif structkeyexists(arguments,"type")>and upper(type)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.type)#"></cfif>
											<cfif structkeyexists(arguments,"event")>and upper(event)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.event)#"></cfif>
								)fq on datepart(dw, fq.datetimecreated) = statsDays.day-1
								and datediff(day,fq.datetimecreated,#createodbcdatetime(arguments.day)#) <=0 and datediff(day,fq.datetimecreated,#createodbcdatetime(arguments.day+7)#) >=0
					group by 	day, statsDays.name, datepart(dw, fq.datetimecreated)
					order by 	1 
				</cfquery>
		    </cfdefaultcase>
		</cfswitch>
				
		<cfreturn qLog>
	</cffunction> 

	<cffunction name="filterLog" hint="Return a query of audit entries based on parameters passed in." returntype="query">
		<cfargument name="objectid" type="string" required="false" hint="Logs for this object" />
		<cfargument name="before" type="date" required="false" hint="Logs before this date" />
		<cfargument name="after" type="date" required="false" hint="Logs after this date" />
		<cfargument name="userid" type="string" required="false" hint="Logs from this user" />
		<cfargument name="location" type="string" required="false" hint="Logs from this location" />
		<cfargument name="type" type="string" required="false" hint="Logs of this type" />
		<cfargument name="event" type="string" required="false" hint="Logs for this event" />
		<cfargument name="maxrows" type="numeric" required="false" default="100" hint="Maximum number of results" />
		<cfargument name="orderby" type="string" required="false" default="datetimecreated desc" hint="Order of results" />
		
		<!--- local vars --->
		<cfset var qLog = "">
	
		<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />
		
		<cfquery datasource="#application.dsn#" name="qLog" maxrows="#arguments.maxrows#">
			SELECT 	object, type, event, userid, location, ipaddress, datetimecreated, notes
			FROM 	#application.dbowner#farLog
			WHERE 	1=1
					<cfif structkeyexists(arguments,"objectid")>AND object = '#arguments.objectid#'</cfif>
					<cfif structkeyexists(arguments,"type") and len(arguments.type) and arguments.type neq "all">AND type in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.type#" />)</cfif>
					<cfif structkeyexists(arguments,"event") and len(arguments.event) and arguments.event neq "all">AND event in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.event#" />)</cfif>
					<cfif structkeyexists(arguments,"userid") and len(arguments.userid) and arguments.userid neq "all">AND userid in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.userid#" />)</cfif>
					<cfif structkeyexists(arguments,"location")>AND location = '#arguments.location#'</cfif>
					<cfif structkeyexists(arguments,"before")>AND datetimecreated < #arguments.before#</cfif>
					<cfif structkeyexists(arguments,"after")>AND datetimecreated > #arguments.after#</cfif>
			ORDER BY #arguments.orderby#
		</cfquery>
		
		<cfreturn qLog>
	</cffunction> 

</cfcomponent>