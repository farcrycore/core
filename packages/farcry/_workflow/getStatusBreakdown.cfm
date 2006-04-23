<!--- initialize structure --->
<cfset stStatus = structNew()>
<cfset stStatus["Draft"] = 0>
<cfset stStatus["Pending"] = 0>
<cfset stStatus["Approved"] = 0>

<cfset statusList = "draft,Pending,approved">

<!--- Get all objects types that have status option --->
<cfloop collection="#application.types#" item="i">
	<cfif structkeyexists(application.types[i].stProps,"status")>
		
		<cfloop list="#statusList#"	index="status">
			<cftry>			
				<!--- Get all objects that have status --->
				<cfquery name="qGetObjects" datasource="#application.dsn#">
					select count(objectID) as objectCount
					From #application.dbowner##i#
					WHERE status = '#status#'
				</cfquery>
			
				<!--- Add count to the list --->
				<cfif qGetObjects.recordcount gt 0>
					<cfset stStatus[status] = stStatus[status] + qGetObjects.objectCount>
				</cfif>
				<cfcatch></cfcatch>
			</cftry>
		</cfloop>
	</cfif>
</cfloop>