<!--- initialise last segment for everything greater than last segment --->
<cfset stArgs.breakdown = listAppend(stArgs.breakdown, (">" & listLast(stArgs.breakdown)))>

<!--- initialize structure --->
<cfset stAge = structNew()>

<cfloop list="#stArgs.breakdown#" index="segment">
	<cfset stAge[segment] = 0>
</cfloop>

<!--- Get all objects types that have dateTimeLastUpdated option --->
<cfloop collection="#application.types#" item="i">
	<cfif structkeyexists(application.types[i].stProps,"dateTimeLastUpdated")>
	
		<cfset previousSegment = "">
		<!--- loop over each segment to get count of objects --->
		<cfloop list="#stArgs.breakdown#" index="segment">
			<cftry>
				<!--- Get all objects that between dates --->
				<cfquery name="qGetObjects" datasource="#application.dsn#">
					select count(objectID) as objectCount
					From #application.dbowner##i#
					WHERE
						<!--- check if last segment ie > last defined segment --->
						<cfif not isnumeric(segment) and segment eq listLast(segment)>
							dateTimeLastUpdated < #createodbcdatetime(dateadd("d",-previousSegment,now()))#
						<cfelse>
							dateTimeLastUpdated >= #createodbcdatetime(dateadd("d",-segment,now()))#
							<!--- if not the first item, compare between two dates --->
							<cfif previousSegment neq "">
								and dateTimeLastUpdated <= #createodbcdatetime(dateadd("d",-previousSegment,now()))#
							</cfif>
						</cfif>
				</cfquery>
				
				<!--- Add count to the list --->
				<cfif qGetObjects.recordcount gt 0>
					<cfset stAge[segment] = stAge[segment] + qGetObjects.objectCount>
				</cfif>
				<cfcatch></cfcatch>
			</cftry>
			<cfset previousSegment = segment>
		</cfloop>
	</cfif>
</cfloop>