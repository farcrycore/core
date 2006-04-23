<!--- initialize query --->
<cfset qLockedObjects = queryNew("objectId,objectTitle,lastupdatedby,objectLastUpdated,objectType,objectParent")>
<cfset rowCounter = 0>

<!--- Loop through all objects that are locked --->
<cfloop list="#stArgs.types#" index="i">

	<cfquery name="qLockedObjects1" datasource="#application.dsn#">
		select distinct objectID,title,datetimelastUpdated,lastupdatedby
		From #application.dbowner##i#
		WHERE locked = 1 and datetimelastupdated < #dateadd("d",-stArgs.days,now())#
	</cfquery>		
			
	<!--- unlock each object --->
	<cfif qLockedObjects1.recordcount gt 0>
		<cfset newRows = QueryAddRow(qLockedObjects,qLockedObjects1.recordcount)>
		<cfloop query="qLockedObjects1">
			<cfinvoke component="#application.packagepath#.farcry.locking" method="unlock" returnvariable="unlockRet">
				<cfinvokeargument name="objectId" value="#objectid#"/>
				<cfinvokeargument name="typename" value="#i#"/>
			</cfinvoke>
			
			<!--- add to query object --->
			<cfset rowCounter = rowCounter + 1>
			<cfset temp = querySetCell(qLockedObjects,"ObjectId", objectId,rowCounter)>
			<cfset temp = querySetCell(qLockedObjects,"lastupdatedby", lastupdatedby,rowCounter)>
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