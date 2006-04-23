<cftry>
	<cfset stReturn.owners = StructNew()>
	<cfloop item="stLocal.typeItem" collection="#application.types#">
		<cfquery datasource="#application.dsn#" name="stLocal.qList">
		SELECT COUNT(objectid) as noItem, ownedBy FROM #application.dbowner##stLocal.typeItem# GROUP BY ownedBy
		</cfquery>
		<cfloop query="stLocal.qList">
			<cfset stLocal.currentOwner = Trim(stLocal.qList.ownedBy)>
			<cfif stLocal.currentOwner EQ "">
				<cfset stLocal.currentOwner = "Unknown">
			</cfif>
			
			<cfif NOT StructKeyExists(stReturn.owners,stLocal.currentOwner)>
				<cfset stReturn.owners[stLocal.currentOwner] = StructNew()>
				<cfset stReturn.owners[stLocal.currentOwner].items = StructNew()>
				<cfset stReturn.owners[stLocal.currentOwner].items.total = 0>
			</cfif>

			<cfset stReturn.owners[stLocal.currentOwner].items[stLocal.typeItem] = stLocal.qList.noItem>
			<cfset stReturn.owners[stLocal.currentOwner].items.total = stReturn.owners[stLocal.currentOwner].items.total + stLocal.qList.noItem>
		</cfloop>
	</cfloop>

	<cfcatch>
		<cfset stReturn.returnCode = 0>	
		<cfset stReturn.returnCode = "Sorry an Error has occured while trying to generate Owned By report. <br />">	
	</cfcatch>
</cftry>