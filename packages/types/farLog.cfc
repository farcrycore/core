<cfcomponent 
	displayname="FarCry Log" 
	hint="Manages FarCry Event logs" 
	extends="types" output="false" 
	bRefObjects="false" fuAlias="fc-log" bObjectBroker="0" bSystem="true"
	icon="fa-list">

	<cfproperty name="object" type="uuid" default="" 
		ftSeq="1" ftFieldset="" ftLabel="Object" 
		ftType="string"
		hint="The associated object">

	<cfproperty name="type" type="string" default="" 
		ftSeq="2" ftFieldset="" ftLabel="Object type" 
		ftType="string"
		hint="The type of the object or event group (e.g. security, coapi)">

	<cfproperty name="event" type="string" default="" 
		ftSeq="3" ftFieldset="" ftLabel="Event" 
		ftType="string"
		hint="The event this log is associated with">

	<cfproperty name="location" type="string" default="" 
		ftSeq="4" ftFieldset="" ftLabel="Location" 
		ftType="string"
		hint="The location of the event if relevant">

	<cfproperty name="userid" type="string" default="" 
		ftSeq="5" ftFieldset="" ftLabel="User" 
		ftType="string"
		hint="The id of the user">

	<cfproperty name="ipaddress" type="string" default="" 
		ftSeq="6" ftFieldset="" ftLabel="IP address" 
		ftType="string"
		hint="IP address of user">

	<cfproperty name="notes" type="longchar" default="" 
		ftSeq="7" ftFieldset="" ftLabel="Notes" 
		ftType="longchar"
		hint="Extra notes">

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