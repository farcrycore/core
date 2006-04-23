<!--- initialize query --->
<cfset qDraftObjects = queryNew("objectId,objectTitle,createdBy,objectLastUpdated,objectType,objectParent")>
<cfset rowCounter = 0>

<!--- Get all objects types that have status option --->
<cfloop list="#stArgs.objectTypes#" index="i">
		
		<!--- Get all objects that have status of pending --->
		<cfquery name="qGetObjects" datasource="#application.dsn#">
			select objectID,title, datetimelastUpdated
			From #i#, dmUser
			WHERE status = 'Draft'
				and (dmUser.userLogin = createdby or dmUser.userLogin = lastupdatedby)
				and dmUser.userLogin = '#stArgs.userLogin#'
				order by datetimelastUpdated desc
		</cfquery>
		
				
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
						SELECT objectid FROM dmNavigation_aObjectIds 
						WHERE data = '#objectId#'	
					</cfquery>
					<cfset temp = querySetCell(qDraftObjects,"objectParent", qGetParent.objectid,rowCounter)>
				<cfelse>
					<cfset temp = querySetCell(qDraftObjects,"objectParent", 0,rowCounter)>
				</cfif>
			</cfloop>
		</cfif>
</cfloop>

<cfquery name="qDraftObjects2" dbtype="query">
	select * 
	from qDraftObjects
	order by objectLastUpdated desc
	
</cfquery>
