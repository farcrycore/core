<!--- initialize query --->
<cfset qLockedObjects = queryNew("objectId,objectTitle,createdBy,objectLastUpdated,objectType,objectParent")>
<cfset rowCounter = 0>

<!--- Loop through all objects that are locked by specified user --->
<cfloop list="#stArgs.types#" index="i">
		
	<cfset sql = "select distinct objectID,title, datetimelastUpdated From #application.dbowner##i# WHERE locked = 1 and lockedby = '#stArgs.userlogin#' order by datetimelastUpdated desc">
	
	<cfquery name="qGetObjects" datasource="#application.dsn#">
		#preserveSingleQuotes(sql)#
	</cfquery>		
			
	<!--- Create structure for object details to be outputted later --->
	<cfif qGetObjects.recordcount gt 0>
		<cfset newRows = QueryAddRow(qLockedObjects,qGetObjects.recordcount)>
		<cfloop query="qGetObjects">
			<cfset rowCounter = rowCounter + 1>
							
			<cfset temp = querySetCell(qLockedObjects,"ObjectId", objectId,rowCounter)>
			<cfif title neq "">
				<cfset temp = querySetCell(qLockedObjects,"objectTitle", title,rowCounter)>
			<cfelse>
				<cfset temp = querySetCell(qLockedObjects,"objectTitle", "<em>undefined</em>",rowCounter)>
			</cfif>
			<cfset temp = querySetCell(qLockedObjects,"objectLastUpdated", datetimelastUpdated,rowCounter)>
			<cfset temp = querySetCell(qLockedObjects,"objectType", I,rowCounter)>
			
			<cfif i neq "dmNews">
				<!--- get object parent --->
				<cfquery name="qGetParent" datasource="#application.dsn#">
					SELECT objectid FROM #application.dbowner#dmNavigation_aObjectIDs 
					WHERE data = '#objectId#'	
				</cfquery>
				<cfset temp = querySetCell(qLockedObjects,"objectParent", qGetParent.objectid,rowCounter)>
			<cfelse>
				<cfset temp = querySetCell(qLockedObjects,"objectParent", 0,rowCounter)>
			</cfif>
		</cfloop>
	</cfif>
</cfloop>

<cfquery name="qLockedObjects2" dbtype="query">
	select * 
	from qLockedObjects
	order by objectLastUpdated desc
</cfquery>
