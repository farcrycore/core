<cfsetting requesttimeout="999" />
<!--- 
 // export table data 
 - called via AJAX from ./webskin/farCOAPI/webtopBodyExportSkeleton.cfm
 	/index.cfm?ajaxmode=1&type=farSkeleton&objectid=#stSkeletonExport.objectid#&view=ajaxExportTable&position=#iTable#&sqlFilesPath=#urlEncodedFormat(stSkeletonExport.exportData.sqlFilesPath)#
--------------------------------------------------------------------------------->
<cftry>
	<cfset stTable = stobj.exportData.aTables[url.position]>

	<!--- create folder under current project for SQL install scripts --->
	<cfif NOT directoryExists("#getSQLStagingPath()#")>
		<cfdirectory action="create" directory="#getSQLStagingPath()#" />
	</cfif>

	<cfloop from="1" to="#arrayLen(stTable.aDeploySQL)#" index="iType">
		<cffile action="write" file="#stobj.exportData.sqlFilesPath#/DEPLOY-#stTable.aDeploySQL[iType].dbType#_#stTable.name#.sql" output="#stTable.aDeploySQL[iType].sql#" charset="utf-8">
	</cfloop>
	
	<cfloop from="1" to="#arrayLen(stTable.aInsertSQL)#" index="iPage">
		
		<cfset insertSQL = stTable.aInsertSQL[iPage]>
		<cfquery datasource="#application.dsn#" name="qryTemp">
		#preserveSingleQuotes(insertSQL)#
		</cfquery>
		
		<cfsavecontent variable="insertSQL">
		<cfloop query="qryTemp">
			<cfset formattedValues = replaceNoCase(qryTemp.insertValues,'|???|','null','all')>
			<cfset formattedValues = replaceNoCase(formattedValues,"'","''","all")>
			<cfset formattedValues = replaceNoCase(formattedValues,"|---|","'","all")>
			<cfset formattedValues = rereplace(formattedValues,'\{ts ([^}]*)\}','\1','all')>
			<cfset formattedValues = replaceNoCase(formattedValues,"'NULL'","NULL","all")>
			<cfoutput>INSERT INTO #stTable.name# (#stTable.insertFieldnames#) VALUES ( #formattedValues# );
</cfoutput>
		</cfloop>
		</cfsavecontent>
		
					   													
		<cffile action="write" file="#stobj.exportData.sqlFilesPath#/INSERT-#stTable.name#-#iPage#.sql" output="#insertSQL#" charset="utf-8">
			
	</cfloop>

	<cfset stTable.bComplete = 1>
	<cfset setData(stProperties="#stobj#", bSessionOnly="true") />


	<!--- RETURN RESULT --->
	<cfset stResult = structNew()>
	<cfset stResult.bSuccess = true>
	<cfset stResult.message = "#arrayLen(stTable.aInsertSQL)# pages generated.">
	<cfset stResult.name = stTable.name>
	<cfset stResult.bExportComplete = application.fapi.getContentType("farSkeleton").isExportComplete(stobj.objectid)>
		
	<cfcontent 	
		reset="true"
		type="application/json"
		variable="#toBinary( toBase64( serializeJSON( stResult ) ) )#"
		/>

	
	<!--- CATCH ANY ERRORS --->
	<cfcatch type="any">
		<cfset stResult = structNew()>
		<cfset stResult.bSuccess = false>
		<cfset stResult.message = "#cfcatch.message#">
		<cfset stResult.bExportComplete = 0>

		<cflog file="farcry-export" text="Error exporting #stTable.name#, #serializeJSON(stResult)#">
		
		<cfcontent 	
			reset="true"
			type="application/json"
			variable="#toBinary( toBase64( serializeJSON( stResult ) ) )#"
			/>
	</cfcatch>
</cftry>