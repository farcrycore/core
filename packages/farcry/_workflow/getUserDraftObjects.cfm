<!--- initialize query --->
<cfset qDraftObjects = queryNew("objectId,objectTitle,createdBy,objectLastUpdated,objectType,objectParent")>
<cfset rowCounter = 0>

<!--- Get all objects types that have status option --->
<cfloop list="#stArgs.objectTypes#" index="i">
		<cfif i eq "dmHTML">
		   <cfset sql = "SELECT objectID, title, versionID, datetimelastUpdated FROM #application.dbowner##i# WHERE status = 'draft' AND rtrim(versionID) = '' AND (createdby = '#stArgs.userLogin#' OR lastupdatedby = '#stArgs.userLogin#') ORDER BY datetimelastUpdated DESC">
        <cfelse>
		   <cfset sql = "SELECT objectID, title, '' as versionID, datetimelastUpdated FROM #application.dbowner##i# WHERE status = 'draft' AND (createdby = '#stArgs.userLogin#' OR lastupdatedby = '#stArgs.userLogin#') ORDER BY datetimelastUpdated DESC">
        </cfif>

        <cfquery name="qGetObjects" datasource="#application.dsn#">#preserveSingleQuotes(sql)#</cfquery>
				
		<!--- Create structure for object details to be outputted later --->
		<cfif qGetObjects.recordcount gt 0>
			<cfset newRows = QueryAddRow(qDraftObjects,qGetObjects.recordcount)>
			<cfloop query="qGetObjects">
				<cfset rowCounter = rowCounter + 1>
								
				<cfset temp = querySetCell(qDraftObjects,"ObjectId", objectId,rowCounter)>
				<cfif title neq "">
					<cfset temp = querySetCell(qDraftObjects,"objectTitle", title,rowCounter)>
				<cfelse>
					<cfset temp = querySetCell(qDraftObjects,"objectTitle", "<em>undefined</em>",rowCounter)>
				</cfif>
				<cfset temp = querySetCell(qDraftObjects,"objectLastUpdated", datetimelastUpdated,rowCounter)>
				<cfset temp = querySetCell(qDraftObjects,"objectType", I,rowCounter)>
				
				<cfif i eq "dmHTML">
					<!--- get object parent --->
					<cfquery name="qGetParent" datasource="#application.dsn#">
					SELECT objectID FROM #application.dbowner#dmNavigation_aObjectIDs
					WHERE data = '#objectID#'
					</cfquery>
					<cfset temp = querySetCell(qDraftObjects,"objectParent", qGetParent.objectid,rowCounter)>
				<cfelse>
					<cfset temp = querySetCell(qDraftObjects,"objectParent", 0,rowCounter)>
				</cfif>
			</cfloop>
		</cfif>
</cfloop>

<cfquery name="qDraftObjects2" dbtype="query">
SELECT * FROM qDraftObjects
ORDER BY objectLastUpdated DESC
</cfquery>
