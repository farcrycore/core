<cfcomponent extends="forms"
	displayname="Farcry Skeleton Creation" 
	hint="Skeleton Export Utility" 
	output="false">

	<cfproperty name="lExcludeData" type="longchar" default="" 
		ftSeq="14" ftFieldset="" ftLabel="Exclude Data" 
		ftType="list" ftRenderType="checkbox" 
		ftListData="getTablesToExport" ftListDataTypename="farSkeleton"
		ftHint="The deploy scripts will still be generated."
		hint="What tables should be excluded from the data export ">

	<cfproperty name="exportData" type="longchar" default="" hint="A structure containing the export data"
		ftLabel="Export Data" />

	<cfproperty name="bSetupComplete" type="boolean" default="0" hint="" 
		ftLabel="Setup Complete" />


<!--- 
 // helper functions 
--------------------------------------------------------------------------------->
	<cffunction name="getSQLDataSize" hint="Returns size of the SQL data export in MB.">
		<cfargument name="objectid">
		<cfset var SQLDataSize = 0>
		<cfset var qSQL = "">
		<cfset var directoryInfo = "">

		<!--- is there any exported data? --->
		<cfdirectory action="list" directory="#getSQLStagingPath()#" name="qSQL" filter="*.sql" />
		
		<cfif qSQL.recordcount>
			<cfquery name="directoryInfo" dbtype="query">
			SELECT SUM(size) AS totalSize FROM qSQL
			</cfquery>
			<cfset SQLDataSize = directoryInfo.totalSize/1000000>
		</cfif>

		<cfreturn SQLDataSize />
	</cffunction>

	<cffunction name="getTablesToExport" hint="Returns a list of table names to export.">
		<cfargument name="objectid">
		
		<cfset var i = "">
		<cfset var lResult = "" />
		<cfset var lTableNamesToExport = "">
		<cfset lTableNamesToExport = listAppend(lTableNamesToExport,structKeyList(application.types))>
		<cfset lTableNamesToExport = listAppend(lTableNamesToExport,structKeyList(application.rules))>
		<cfset lTableNamesToExport = listAppend(lTableNamesToExport,structKeyList(application.schema))>
		
		<cfloop list="#lTableNamesToExport#" index="i">
			<cfif not listFindNoCase("refObjects,dmArchive,farLog,dmWizard,dmWebskinAncestor",i)>
				<cfset lResult = listAppend(lResult, "#i#") />
			</cfif>
		</cfloop>
		
		<cfset lResult = listSort(lResult,"text","asc")>
		
		<cfreturn lResult>
	</cffunction>
	

	<cffunction name="isExportComplete" hint="Check that all SQL has been exported.">
		<cfargument name="objectid" required="true" hint="Skeleton form session object.">

		<cfset var stSkeleton = getData(arguments.objectid) />
		<cfset var bExportComplete = 1 />
		<cfset var iTable = "" />

		<cfif isStruct(stSkeleton.exportData)>
			
			<cfloop from="1" to="#arrayLen(stSkeleton.exportData.aTables)#" index="iTable">
				<cfif NOT stSkeleton.exportData.aTables[iTable].bComplete>
					<cfset bExportComplete = 0 />
				</cfif>
			</cfloop>
		<cfelse>
			<cfset bExportComplete = 0 />
		</cfif>

		<cfreturn bExportComplete />
	</cffunction>

<!--- 
 // file export functions 
--------------------------------------------------------------------------------->
	<cffunction name="getSQLStagingPath" hint="Returns path to temp staging directory for assembling zips">
		<cfset var path = "#getTempDirectory()#/#application.projectDirectoryName#/sql">

		<cfreturn path>
	</cffunction>

	<cffunction name="getZipStagingPath" hint="Returns path to temp staging directory for assembling zips">
		<cfset var path = "#getTempDirectory()#/#application.projectDirectoryName#">

		<cfreturn path>
	</cffunction>

	<cffunction name="deleteSQLExportData">
		<cfset var qSQL = "">

		<cftry>
		<cfdirectory action="list" directory="#getSQLStagingPath()#" name="qSQL" filter="*.sql" />
		<cfloop query="qSQL">
			<cffile action="delete" file="#qsql.directory#/#qsql.name#">
		</cfloop>

			<cfcatch type="any">
				<cfreturn application.fapi.fail("#cfcatch.message#") />
			</cfcatch>
		</cftry>

		<cfreturn application.fapi.success("SQL export data deleted") />

	</cffunction>

	<cffunction name="deleteOldExport">

		<cftry>
			<!--- cleanup zip staging area --->
			<cfif directoryexists('#application.path.project#/project_export')>
				<cfdirectory action="delete" directory="#application.path.project#/project_export" mode="777" recurse="true" />
			</cfif>

			<!--- remove zips --->
			<cfif fileExists("#application.path.webroot#/project.zip")>
				<cffile action="delete"  file="#application.path.webroot#/project.zip">	
			</cfif>

			<cfcatch type="any">
				<cfreturn application.fapi.fail("#cfcatch.message#") />
			</cfcatch>
		</cftry>

		<cfreturn application.fapi.success("Old export deleted") />

	</cffunction>

	<cffunction name="zipSQLData">
		<!--- build zip in temp directory --->
		<cfset var zipFile = "#getTempDirectory()##application.applicationname#-data.zip" />
		
		<cfif fileExists(zipFile)>
			<cffile action="delete"  file="#zipFile#">	
		</cfif>
		
		<cfzip action="zip" recurse="true" 
			source="#getSQLStagingPath()#"
			file="#zipFile#" />
		
		<cfreturn zipFile>

	</cffunction>

	<cffunction name="zipInstaller" hint="Package code into a ZIP for the installer; excludes media.">
		
		<cfset var zipFile = "#getTempDirectory()##application.applicationname#-project.zip">
		<cfset var excludeDir = ".git|.svn|mediaArchive|www/cache|www/images|www/files">

		<cfset var qProject = getDirContents(
							directory=application.path.project, 
							ignoreDirectories=excludeDir, 
							ignoreFiles="project.zip")>

		<cfset var qCore = getDirContents(
							directory=expandpath("/farcry/core"), 
							ignoreDirectories=excludeDir, 
							ignoreFiles="project.zip")>

		<cfset var qPlugins = getDirContents(
							directory=expandpath("/farcry/plugins"), 
							ignoreDirectories=excludeDir, 
							ignoreFiles="project.zip")>


		<!--- create ZIP for entire project, core and plugins --->
		<cfzip action="zip" file="#zipFile#" overwrite="true">

			<cfloop query="qProject">
				<cfif qproject.type neq "Dir">
					<cfset filepath = "farcry/projects/" & application.projectDirectoryName & replacenocase(qProject.directory, application.path.project, "") & "/" & qproject.name>
					<cfzipparam source="#qProject.directory#/#qproject.name#" entrypath="#filepath#">
				</cfif>
			</cfloop>

			<cfloop query="qCore">
				<cfif qCore.type neq "Dir">
					<cfset filepath = "farcry/core" & replace(replacenocase(qCore.directory, expandpath("/farcry/core"), ""), "\", "/", "all") & "/" & qCore.name>
					<cfzipparam source="#qCore.directory#/#qCore.name#" entrypath="#filepath#">
				</cfif>
			</cfloop>

			<cfloop query="qPlugins">
				<cfif qPlugins.type neq "Dir">
					<cfset filepath = "farcry/plugins" & replace(replacenocase(qPlugins.directory, expandpath("/farcry/plugins"), ""), "\", "/", "all") & "/" & qPlugins.name>
					<cfzipparam source="#qPlugins.directory#/#qPlugins.name#" entrypath="#filepath#">
				</cfif>
			</cfloop>

		</cfzip>
		<!--- create installer CFM into ./farcry --->
		<!--- TODO: needs blank Application.cfm to block framework interference --->
		<!--- <cffile action="copy" source="#expandPath('/farcry/core')#/webskin/farSkeleton/projectINSTALLER.txt" destination="#application.path.project#/project_export/farcry" /> --->
		<!--- <cffile action="rename" source="#application.path.project#/project_export/farcry/projectINSTALLER.txt" destination="#application.path.project#/project_export/farcry/index.cfm"> --->
		
		<cfreturn zipfile />

	</cffunction>

	<cffunction name="getDirContents" hint="Recursive CFDIRECTORY with ignore option and remove hidden by default. Ignore delimited by pipes." access="private">
		<cfargument name="directory" type="string" default="">
		<cfargument name="ignoreFiles" type="string" default="">
		<cfargument name="ignoreDirectories" type="string" default=".git|.svn">
		<cfargument name="showHidden" type="boolean" default="false">
		<cfset var qDir = "">
		<cfset var aDir = listtoarray(arguments.ignoreDirectories, "|")>

		<cfdirectory action="list" directory="#arguments.directory#" name="qDir" recurse="true" />
		
		<cfquery dbtype="query" name="qDir">
		SELECT * FROM qDir 
		WHERE 0=0
		<cfif len(arguments.ignoreFiles)>AND name NOT IN (#ListQualify(arguments.ignoreFiles, "'", "|")#)</cfif>
		<cfif NOT arguments.showhidden>AND attributes <> 'H'</cfif>
		<cfloop from="1" to="#arrayLen(aDir)#" index="i">
			AND directory NOT LIKE '%\#aDir[i]#%'
			AND directory NOT LIKE '%/#aDir[i]#%'
		</cfloop>
		</cfquery>

		<cfreturn qDir>
	</cffunction>


<!--- 
 // data export functions 
--------------------------------------------------------------------------------->
	<cffunction name="exportStepCreateSQL" hint="SQL export magic.">
		<cfargument name="objectid">

		<cfset var stSkeleton = getData(arguments.objectid) />
		<cfset var stResult = application.fapi.fail("SQL Not Created") />
		<cfset var lTableNamesToExport = "" />
		<cfset var stCoapiExportTable = "" />
		<cfset var oGateway = "" />
		<cfset var deploymentSQL = "" />
		<cfset var oGateway = "" />
		<cfset var oGateway = "" />

		<!--- build export metadata --->
		<cfset stSkeleton.exportData = structNew()>
		<cfset stSkeleton.exportData.aTables = arrayNew(1)>
		<cfset stSkeleton.exportData.dbTypes = application.fc.lib.db.getDBTypes()>
		<cfset stSkeleton.exportData.lDBTypes = "">
		<cfset stSkeleton.exportData.sqlFilesPath = "#getSQLStagingPath()#">

		<cfloop list="#structKeyList(stSkeleton.exportData.dbTypes)#" index="iDBType">
			<cfif iDBType NEQ "BaseGateway">
				<cfset stSkeleton.exportData.lDBTypes = listAppend(stSkeleton.exportData.lDBTypes, iDBType)>
			</cfif>
		</cfloop>
		
		<!--- get a list of all types, rules and schema tables; everything else is ignored --->
		<cfset lTableNamesToExport = "">
		<cfset lTableNamesToExport = listAppend(lTableNamesToExport,structKeyList(application.types))>
		<cfset lTableNamesToExport = listAppend(lTableNamesToExport,structKeyList(application.rules))>
		<cfset lTableNamesToExport = listAppend(lTableNamesToExport,structKeyList(application.schema))>
		
		<cfloop list="#lTableNamesToExport#" index="iTable">
		
			<cfset stCoapiExportTable = structNew()>
			<cfset stCoapiExportTable.bComplete = false>
			<cfset stCoapiExportTable.bCoapi = true>
			<cfset stCoapiExportTable.name = iTable>
			<cfset stCoapiExportTable.stMetadata = application.fc.lib.db.getTableMetadata(typename="#iTable#")>
			<cfset stCoapiExportTable.insertFieldnames = "">
			<cfset stCoapiExportTable.aInsertSQL = arrayNew(1)>
			<cfset stCoapiExportTable.aDeploySQL = arrayNew(1)>
			
			<cfset arrayAppend(stSkeleton.exportData.aTables,stCoapiExportTable) />

			<!--- generate deploy scripts for all db gateways --->
			<cfloop list="#stSkeleton.exportData.lDBTypes#" index="idbType">
				<cfset oGateway = createObject('component',stSkeleton.exportData.dbTypes[idbType][1]).init(dsn="", dbowner="", dbtype="") />
				<cfset deploymentSQL = oGateway.getDeploySchemaSQL(schema="#stCoapiExportTable.stMetadata#")>
				<cfset stDeploymentSQL = structNew()>
				<cfset stDeploymentSQL.dbType = idbType>
				<cfset stDeploymentSQL.sql = deploymentSQL>
				<cfset arrayAppend(stCoapiExportTable.aDeploySQL,stDeploymentSQL)>
				<!--- <cffile action="write" file="#getSQLStagingPath()#/sql/DEPLOY-#idbType#_#iTable#.sql" output="#deploymentSQL#"> --->
			</cfloop>

			<!--- exclude abstract classes; only actual tables will have metadata --->
			<cfif isStruct(stCoapiExportTable.stMetadata)>
			
				<cfloop collection="#stCoapiExportTable.stMetadata.fields#" item="iField">
					<cfif stCoapiExportTable.stMetadata.fields[iField].type eq 'array'>
						
						<cfset stArrayExportTable = structNew()>
						<cfset stArrayExportTable.bComplete = false>
						<cfset stArrayExportTable.bCoapi = false>
						<cfset stArrayExportTable.name = "#iTable#_#iField#">
						<cfset stArrayExportTable.stMetadata = structNew()>
						<cfset stArrayExportTable.insertFieldnames = "">
						<cfset stArrayExportTable.aInsertSQL = arrayNew(1)>
						<cfset stArrayExportTable.aDeploySQL = arrayNew(1)>
			
						<cfset arrayAppend(stSkeleton.exportData.aTables,stArrayExportTable) />
						

						<cfloop list="#stSkeleton.exportData.lDBTypes#" index="idbType">
							<cfset oGateway = createObject('component',stSkeleton.exportData.dbTypes[idbType][1]).init(dsn="", dbowner="", dbtype="") />
							<cfset deploymentSQL = oGateway.getDeploySchemaSQL(schema="#stCoapiExportTable.stMetadata.fields[iField]#")>
							<cfset stDeploymentSQL = structNew()>
							<cfset stDeploymentSQL.dbType = idbType>
							<cfset stDeploymentSQL.sql = deploymentSQL>
							<cfset arrayAppend(stArrayExportTable.aDeploySQL,stDeploymentSQL)>
							<!--- <cffile action="write" file="#getSQLStagingPath()#/sql/DEPLOY-#idbType#_#iTable#_#iField#.sql" output="#deploymentSQL#"> --->
						</cfloop>
										
					</cfif>
				</cfloop>

			</cfif>
		</cfloop>	

		<!--- register a list of all table data to exclude by default --->
		<cfset stSkeleton.lExcludeData = listAppend(stSkeleton.lExcludeData,"refObjects,dmArchive,farLog,dmWizard,dmWebskinAncestor")>
		
		<cfloop from="1" to="#arrayLen(stSkeleton.exportData.aTables)#" index="iTable">
			<cfif not listFindNoCase("#stSkeleton.lExcludeData#", stSkeleton.exportData.aTables[iTable].name)>
				<cfset setupInsertSQL(stTable="#stSkeleton.exportData.aTables[iTable]#")>
			</cfif>
		</cfloop>


		<cfset stSkeleton.bSetupComplete = 1>
		<cfset setData(stProperties="#stSkeleton#", bSessionOnly="true") />


		<cfset stResult = application.fapi.success("SQL Created") />

		<cfreturn stResult />
	</cffunction>


	<cffunction name="setupInsertSQL" returnType="string" output="true">
	        <cfargument name="stTable" type="struct" required="true">
	        <cfargument name="perPage" type="numeric" default="1000">
	        <cfargument name="maxPages" type="numeric" default="100">

	        <cfset var i = 1>
	        <cfset var j = 1>
	        <cfset var k = 0>
	        <cfset var temp = "">
	        <cfset var qTableCounter = "">
	        <cfset var qryTemp = "">
	        <cfset var aTableColMD = "">
	        <cfset var str = "">
	        <cfset var textstr = "">
	        <cfset var iPage = 0>
	        <cfset var thisfield = "">
			<cfset var insertFields = "">
			<cfset var insertSQL = "">
			<cfset var oGateway = application.fc.lib.db.getGateway(dsn=application.dsn)>

			<cfif structKeyExists(stTable.stMetadata, "fields")>

				<cfset selectFields = "">
				<cfloop list="#structKeyList(stTable.stMetadata.fields)#" index="iProp">
					<cfif stTable.stMetadata.fields[iProp].type NEQ "Array">
						<cfset selectFields = listAppend(selectFields,"#iProp#")>
					</cfif>
				</cfloop>
			<cfelse>
				<cfset selectFields = "*">
			</cfif>
			
		
	        <!--- Getting table data --->
	        <cfquery name="qTableCounter" datasource="#application.dsn#">
	        select count(*) as counter from #arguments.stTable.name#
	        </cfquery>
			
			<cfquery name="qSelectFields" datasource="#application.dsn#" maxrows="1">
			SELECT #selectFields#
			FROM #arguments.stTable.name#
			</cfquery>


	        <!--- Getting meta information of executed query --->
	        <cfset aTableColMD = getMetaData(qSelectFields)>
			
			<!--- set relevant order by for table type --->
			<cfif listFindNoCase(qSelectFields.columnList,"dateTimeLastUpdated")>
				<cfset orderBy = "dateTimeLastUpdated">
			<cfelseif listFindNoCase(qSelectFields.columnList,"objectid")>
				<cfset orderBy = "objectid">
			<cfelseif listFindNoCase(qSelectFields.columnList,"parentID")>
				<cfset orderBy = "parentID">
			<cfelse>
				<cfabort showerror="not a valid table to export">
			</cfif>

			<cfset k = ArrayLen(aTableColMD) >
			<!--- -1 removes [RowNum] column which is last column --->
			
			<!--- build field names for INSERT statement --->
			<cfsavecontent variable="stTable.insertFieldnames">
				<cfloop index="j" from="1" to="#k#"><cfoutput>#aTableColMD[j].Name#<cfif j NEQ k >,</cfif></cfoutput></cfloop>
			</cfsavecontent>
			
			<cfif qTableCounter.counter GT 0>
				
				<cfset pages = Ceiling(qTableCounter.counter/arguments.perPage)>
				
				<cfloop from="1" to="#pages#" index="iPage">
					
					<cfif iPage GT arguments.maxPages>
						<cfbreak>
					</cfif>
					<cfset iFrom = iPage*arguments.perPage-(arguments.perPage) + 1>
					<cfset iTo = iFrom + (arguments.perPage) - 1>
					
					<cfif iTo GT qTableCounter.counter>
						<cfset iTo = qTableCounter.counter>
					</cfif>
					

					<cfset insertSQL = oGateway.getInsertSQL(	table="#arguments.stTable.name#",
																aTableColMD="#aTableColMD#",
																orderBy="#orderBy#",
																from="#iFrom#",
																to="#iTo#" )>
					

					<!--- GB: how does this work? ie. how is stTable returned? --->
					<cfset arrayAppend(stTable.aInsertSQL, insertSQL)>

				</cfloop>
			</cfif>

	        <cfreturn "done">
	</cffunction>


<!--- 
 // third-party UDFs 
--------------------------------------------------------------------------------->
	<!---
	 Copies a directory.
	 v1.0 by Joe Rinehart
	 v2.0 mod by [author not noted]
	 v3.1 mod by Anthony Petruzzi
	 v3.2 mod by Adam Cameron under guidance of Justin Z (removing NAMECONFLICT argument which was never supported in file-copy operations)
	 
	 @param source      Source directory. (Required)
	 @param destination      Destination directory. (Required)
	 @param ignore      List of folders, files to ignore. Defaults to nothing. (Optional)
	 @return Returns nothing. 
	 @author Joe Rinehart (joe.rinehart@gmail.com) 
	 @version 3.2, March 21, 2013 
	--->
	<cffunction name="dCopy" output="false" returntype="void">
	    <cfargument name="source" required="true" type="string">
	    <cfargument name="destination" required="true" type="string">
	    <cfargument name="ignore" required="false" type="string" default="">

	    <cfset var contents = "">
	    
	    <cfif not(directoryExists(arguments.destination))>
	        <cfdirectory action="create" directory="#arguments.destination#">
	    </cfif>
	    
	    <cfdirectory action="list" directory="#arguments.source#" name="contents">

	    <cfif len(arguments.ignore)>
	        <cfquery dbtype="query" name="contents">
	        select * from contents where name not in(#ListQualify(arguments.ignore, "'")#)
	        </cfquery>
	    </cfif>
	    
	    <cfloop query="contents">
	        <cfif contents.type eq "file">
	            <cftry>
		            <cffile action="copy" source="#arguments.source#/#name#" destination="#arguments.destination#/#name#">
		            <cfcatch type="any">
			            <cfdump var="#cfcatch#" label="Cant copy #arguments.source#/#name# to #arguments.destination#/#name#"><cfabort>
					</cfcatch>
				</cftry>
	        <cfelseif contents.type eq "dir" AND name neq '.svn'>
	            <cfset dCopy(arguments.source & "/" & name, arguments.destination & "/" & name)>
	        </cfif>
	    </cfloop>
	</cffunction>



</cfcomponent>