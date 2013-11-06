<cfcomponent displayname="Farcry Skeleton Creation" hint="The Skeleton creation form" extends="forms" output="false">
	<cfproperty ftSeq="1" ftFieldset="" name="name" type="string" default="" hint="The name of the new skeleton" ftLabel="Skeleton name" ftValidation="required" />
	<cfproperty ftSeq="2" ftFieldset="" name="description" type="longchar" default="" hint="The description of the new skeleton" ftLabel="Description" />
	<cfproperty ftSeq="2" ftFieldset="" name="exportFolder" type="string" default="" hint="" ftLabel="Export Folder" />
	<cfproperty ftSeq="2" ftFieldset="" name="exportFilename" type="string" default="" hint="" ftLabel="Export Filename" />
	<cfproperty ftSeq="3" ftFieldset="" name="dsn" type="string" default="" hint="" ftLabel="DSN" />
	<cfproperty ftSeq="4" ftFieldset="" name="dbType" type="string" default="" hint="" ftLabel="DB Type" />
	<cfproperty ftSeq="5" ftFieldset="" name="dbOwner" type="string" default="" hint="" ftLabel="DB Owner" />
	<cfproperty ftSeq="6" ftFieldset="" name="farcryPassword" type="string" default="" hint="" ftLabel="Farcry Default Password" />
	<cfproperty ftSeq="7" ftFieldset="" name="updateAppKey" type="string" default="" hint="" ftLabel="Update App Key" />
	<cfproperty ftSeq="8" ftFieldset="" name="bContentOnly" type="boolean" default="1" hint="unchecked will copy the project into the /farcry/skeleton folder. Checked will simply export the content wddx files into the project and create the manifest" ftLabel="Content Only" />
	<cfproperty ftSeq="9" ftFieldset="" name="bIncludeLog" type="boolean" default="0" hint="Should they include the farLog Table" ftLabel="Include Log Table" />
	<cfproperty ftSeq="10" ftFieldset="" name="bIncludeArchive" type="boolean" default="0" hint="Should they include the dmArchive Table" ftLabel="Include Archive Table" />
	<cfproperty ftSeq="11" ftFieldset="" name="bIncludeMedia" type="boolean" default="1" hint="Should they include the media folders" ftLabel="Include Media" />
	<cfproperty ftSeq="12" ftFieldset="" name="lExcludeData" type="longchar" default="" hint="What tables should be excluded from the data export " 
				ftLabel="Exclude Data" 
				ftHint="The deploy scripts will still be generated."
				ftType="list"
				ftRenderType="checkbox"
				ftListData="getExcludeDataTypenames"
				ftListDataTypename="farSkeleton" />

	<cfproperty ftSeq="20" ftFieldset="" name="bSetupComplete" type="boolean" default="0" hint="" ftLabel="Setup Complete" />
	<cfproperty ftSeq="21" ftFieldset="" name="exportData" type="longchar" default="" hint="A structure containing the export data" ftLabel="Export Data" />
	
	
	<cffunction name="getExcludeDataTypenames">
		<cfargument name="objectid">
		
		<cfset var i = "">
		<cfset var lResult = "" />
		<cfset var lTableNamesToExport = "">
		<cfset lTableNamesToExport = listAppend(lTableNamesToExport,structKeyList(application.types))>
		<cfset lTableNamesToExport = listAppend(lTableNamesToExport,structKeyList(application.rules))>
		<cfset lTableNamesToExport = listAppend(lTableNamesToExport,structKeyList(application.schema))>
		
		<cfloop list="#lTableNamesToExport#" index="i">
			<cfif not listFindNoCase("refObjects,dmArchive,farLog,dmWizard",i)>
				<cfset lResult = listAppend(lResult, "#i#") />
			</cfif>
		</cfloop>
		
		<cfset lResult = listSort(lResult,"text","asc")>
		
		<cfreturn lResult>
	</cffunction>
	
	
	<cffunction name="ftValidateName" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="objectid" required="true" type="string" hint="The objectid of the object that this field is part of.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset var oField = createObject("component", "farcry.core.packages.formtools.field") />		
		<cfset stResult = oField.passed(value=stFieldPost.Value) />
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->	
		<cfif structKeyExists(arguments.stMetadata, "ftValidation") AND listFindNoCase(arguments.stMetadata.ftValidation, "required") AND NOT len(stFieldPost.Value)>
			<cfset stResult = oField.failed(value="#arguments.stFieldPost.value#", message="This is a required field.") />
		</cfif>

		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>


	
	<cffunction name="ftEditExportFolder" access="public" returntype="string" description="Provides the edit skin for exportFolder property" output="false">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />

		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

		<cfsavecontent variable="html">
			<cfoutput><input type="text" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#HTMLEditFormat(arguments.stMetadata.value)#" class="#arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" placeholder="#arguments.stMetadata.ftPlaceholder#"  /></cfoutput>
			<cfoutput>
				<p class="text-info"><small id="#arguments.fieldname#-path">#HTMLEditFormat(arguments.stMetadata.value)#\farcry-export\#dateFormat(now(),'yymmdd')#.zip</small></p>
			</cfoutput>

		</cfsavecontent>

		<skin:onReady>
			
			<cfoutput>
			$j(document).on("keyup","###arguments.fieldname#", function (e) {
				$j('###arguments.fieldname#-path').html($j('###arguments.fieldname#').val());
			});	
			</cfoutput>

		</skin:onReady>
		
		<cfreturn html />
	</cffunction>	


	<cffunction name="isExportComplete">
		<cfargument name="objectid">

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

	<cffunction name="deleteOldExport">

		<cftry>

			<cfif directoryexists('#application.path.project#/project_export')>
				<cfdirectory action="delete" directory="#application.path.project#/project_export" mode="777" recurse="true" />
			</cfif>

			<cfif fileExists("#application.path.webroot#/project.zip")>
				<cffile action="delete"  file="#application.path.webroot#/project.zip">	
			</cfif>


			<cfcatch type="any">
				<cfreturn application.fapi.fail("#cfcatch.message#") />
			</cfcatch>
		</cftry>

		<cfreturn application.fapi.success("Old export deleted") />

	</cffunction>

	<cffunction name="exportStepCreateSQL">
		<cfargument name="objectid">

		<cfset var stSkeleton = getData(arguments.objectid) />
		<cfset var stResult = application.fapi.fail("SQL Not Created") />
		<cfset var lTableNamesToExport = "" />
		<cfset var stCoapiExportTable = "" />
		<cfset var oGateway = "" />
		<cfset var deploymentSQL = "" />
		<cfset var oGateway = "" />
		<cfset var oGateway = "" />


		<cfif not len(stSkeleton.name)>
			<cfreturn application.fapi.fail("Project Name must not be empty") />
		</cfif>




		<!--- 
		ZIP ENTIRE APPLICATION
		 --->
		<cfset stResult = deleteOldExport() />

		<cfif not stResult.bSuccess>
			<cfreturn stResult />
		</cfif>

		<cfdirectory action="create" directory="#application.path.project#/project_export/farcry" mode="777" />
		

		<!--- DATA ONLY --->
		<cfset dCopy(source="#expandPath('/farcry/core')#", destination="#application.path.project#/project_export/farcry/core", ignore="") />
		<cfset dCopy(source="#expandPath('/farcry/plugins')#", destination="#application.path.project#/project_export/farcry/plugins", ignore="") /> 
		<cfset dCopy(source="#application.path.project#", destination="#application.path.project#/project_export/farcry/projects/#application.applicationName#", ignore="www,project_export,install,securefiles") />
		<cfset dCopy(source="#application.path.webroot#", destination="#application.path.project#/project_export/farcry/projects/#application.applicationName#/www", ignore="WEB-INF,farcry,project.zip,cache,images,files") />
		 
		<cffile action="copy" source="#expandPath('/farcry/core')#/webskin/farSkeleton/projectINSTALLER.txt" destination="#application.path.project#/project_export/farcry" />
		<cffile action="rename" source="#application.path.project#/project_export/farcry/projectINSTALLER.txt" destination="#application.path.project#/project_export/farcry/index.cfm">
		
		
		<cfdirectory action="create" directory="#application.path.project#/project_export/farcry/projects/#application.applicationName#/install" />
		<!--- <cfset oZip.Extract(zipFilePath="#arguments.intermediate#/temp.zip", extractPath=arguments.destination, overwriteFiles="true") /> --->


		 <!--- 
		DELETE THE facry_export folder from the zip
		  --->

		<!--- 
		CREATE EXPORT FOLDER
		 --->

	<!--- 
		<cfdirectory action="list" directory="#application.path.project#/install/sql/" name="qSQLFiles" filter="*.sql" />
		
		<cfloop query="qSQLFiles">
			<cffile action="delete"  file="#application.path.project#/install/sql/#qSQLFiles.NAME#">
		</cfloop> 
	--->	
		
		<cfset stSkeleton.exportData = structNew()>
		<cfset stSkeleton.exportData.aTables = arrayNew(1)>
		<cfset stSkeleton.exportData.dbTypes = application.fc.lib.db.getDBTypes()>
		<cfset stSkeleton.exportData.lDBTypes = "">
		<cfset stSkeleton.exportData.sqlFilesPath = "#application.path.project#/project_export/farcry/projects/#application.applicationName#/install">

		<cfloop list="#structKeyList(stSkeleton.exportData.dbTypes)#" index="iDBType">
			<cfif iDBType NEQ "BaseGateway">
				<cfset stSkeleton.exportData.lDBTypes = listAppend(stSkeleton.exportData.lDBTypes, iDBType)>
			</cfif>
		</cfloop>	
		
		
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

			<cfloop list="#stSkeleton.exportData.lDBTypes#" index="idbType">
				<cfset oGateway = createObject('component',stSkeleton.exportData.dbTypes[idbType][1]).init(dsn="", dbowner="", dbtype="") />
				<cfset deploymentSQL = oGateway.getDeploySchemaSQL(schema="#stCoapiExportTable.stMetadata#")>
				<cfset stDeploymentSQL = structNew()>
				<cfset stDeploymentSQL.dbType = idbType>
				<cfset stDeploymentSQL.sql = deploymentSQL>
				<cfset arrayAppend(stCoapiExportTable.aDeploySQL,stDeploymentSQL)>
				<!--- <cffile action="write" file="#application.path.project#/install/sql/DEPLOY-#idbType#_#iTable#.sql" output="#deploymentSQL#"> --->
			</cfloop>	
			
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
							<!--- <cffile action="write" file="#application.path.project#/install/sql/DEPLOY-#idbType#_#iTable#_#iField#.sql" output="#deploymentSQL#"> --->
						</cfloop>	
						
										
					</cfif>
				</cfloop>		
				
			</cfif>
			
			
		</cfloop>	
		<cfset stSkeleton.lExcludeData = listAppend(stSkeleton.lExcludeData,"refObjects,dmArchive,farLog,dmWizard")>
		
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
	<!--- 
						<cfset lTableNamesToExport = listAppend(lTableNamesToExport,"#iTable#_#stTableMD.stProps[iProp].metadata.name#")>
	 --->
						
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
					<!--- <cfif arguments.stTable.name EQ "dmHTML">
														<cfdump var="#aTableColMD#"><cfabort>
													</cfif> --->
					<cfset insertSQL = oGateway.getInsertSQL(	table="#arguments.stTable.name#",
																aTableColMD="#aTableColMD#",
																orderBy="#orderBy#",
																from="#iFrom#",
																to="#iTo#" )>
					

					
					
					<cfset arrayAppend(stTable.aInsertSQL, insertSQL)>

					
				</cfloop>
			</cfif>

	        <cfreturn "done">
	</cffunction>






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