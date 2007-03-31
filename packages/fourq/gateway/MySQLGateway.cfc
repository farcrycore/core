<cfcomponent extends="DBGateway">


	<cffunction name="init" access="public" returntype="MySQLGateway" output="false" hint="Initializes the db specific data mappings for this db type">
		<cfargument name="dsn" type="string" required="true" />
		<cfargument name="dbowner" type="string" required="true" />
		
		<cfset super.init(arguments.dsn,arguments.dbowner) />
		<cfset variables.dataMappings = structNew() />
		<cfset variables.dataMappings.boolean = "tinyint(1)" />
		<cfset variables.dataMappings.date = "datetime" />
		<cfset variables.dataMappings.integer = "int" />
		<cfset variables.dataMappings.numeric = "decimal(10,2)" />
		<cfset variables.dataMappings.string = "varchar(255)" />
		<cfset variables.dataMappings.nstring = "varchar(255)" />
		<cfset variables.dataMappings.uuid = "varchar(50)" />
		<cfset variables.dataMappings.variablename = "varchar(64)" />
		<cfset variables.dataMappings.color = "varchar(20)" />
		<cfset variables.dataMappings.email = "varchar(255)" />
		<cfset variables.dataMappings.longchar = "longtext" />
		
		<cfreturn this />
	</cffunction>


	<!---
	 ************************************************************
	 *                                                          *
	 *                DEPLOYMENT METHODS                        *
	 *                                                          *
	 ************************************************************
	 --->
	<cffunction name="deployType" access="public" output="true" returntype="struct" hint="Deploys the table structure for a FarCry type into a MySQL database.">
		<cfargument name="metadata" type="farcry.core.packages.fourq.TableMetadata" required="true" />
		<cfargument name="bDropTable" type="boolean" required="false" default="false">
		<cfargument name="bTestRun" type="boolean" required="false" default="true">
		<cfargument name="dsn" type="string" required="false" default="#variables.dsn#">
		<cfargument name="dbowner" type="string" required="false" default="#variables.dbowner#">
		
		<cfset var i = "" />
		<cfset var fields = arguments.metadata.getTableDefinition() />
		<cfset var tablename = variables.dbowner & arguments.metadata.getTableName() />
		<cfset var result = structNew() />
		<cfset var SQLArray = generateDeploymentSQLArray(fields) />

    	<cfset result.bSuccess = true />

		<cfsavecontent variable="result.sql">
			<cfoutput>
			CREATE TABLE #tablename#(
			
			<cfloop from="1" to="#arrayLen(SQLArray)#" index="i">
				<cfif i GT 1>,</cfif>
				#SQLArray[i].column# 
				#SQLArray[i].datatype# 
				
				<cfswitch expression="#SQLArray[i].datatype#">
					<cfcase value="longtext,longchar">
						<!--- No Default Allowed on BLOB fields --->
					</cfcase>
					<cfdefaultcase>
						#SQLArray[i].defaultValue#
					</cfdefaultcase>
				</cfswitch>

				#SQLArray[i].nullable#
			</cfloop>
				
			
			<cfif listFindNoCase(structKeyList(fields),"objectid")>
				,PRIMARY KEY (ObjectID)
			</cfif>
			
					
			); 
			</cfoutput>
		</cfsavecontent>
		
		<cfif NOT arguments.bTestRun>
			<cfif arguments.bDropTable>
				<cfquery datasource="#variables.dsn#">
					DROP TABLE IF EXISTS #tablename#
				</cfquery>
			</cfif>
			
			<cfquery datasource="#variables.dsn#">
				#preserveSingleQuotes(result.sql)#
			</cfquery>
			<cfset result.bDeployed = true />
		</cfif>
		
		<cfset result.arrayTables = arrayNew(1) />
		
		<cfloop collection="#fields#" item="i">
			<cfif fields[i].type eq 'array'>
		    <cfset arrayAppend(result.arrayTables,deployArrayTable(fields[i].fields,tablename&"_"&fields[i].name,arguments.bDropTable,arguments.bTestRun)) />
		  </cfif>
		</cfloop>
		<cfreturn result />
		
	</cffunction>


 	<cffunction name="deployArrayTable" access="public" returntype="struct" output="false">
	   	<cfargument name="fields" type="struct" required="true" />
	   	<cfargument name="tablename" type="string" required="true" />
		<cfargument name="bDropTable" type="boolean" required="false" default="false">
		<cfargument name="bTestRun" type="boolean" required="false" default="true">
		
		<cfset var stResult = structNew() />
		<cfset var i = "" />
		<cfset var SQLArray = generateDeploymentSQLArray(arguments.fields) />
		<cfset var SQL = "" />
		
		<cfif arguments.bDropTable>
			<cftry>
				<cfquery datasource="#variables.dsn#">
					DROP TABLE IF EXISTS #arguments.tablename#
				</cfquery>	
				<cfcatch>
				<!--- Suppress Error --->
				   <cftrace inline="false" text="Drop table - failed" var="cfcatch.message">
				</cfcatch>
			</cftry>			
		</cfif>
		
		<cfsavecontent variable="sql">
			<cfoutput>
				CREATE TABLE #arguments.tablename#
				(
					<cfloop from="1" to="#arrayLen(SQLArray)#" index="i">
				    <cfif i GT 1>,</cfif>#SQLArray[i].column# #SQLArray[i].datatype# #SQLArray[i].defaultValue# #SQLArray[i].nullable#
					</cfloop>
				)
			</cfoutput>
		</cfsavecontent>
		
		<cfset stResult.message = "Test run for #arguments.tablename#. No database changes made.">
		<cfset stResult.bSuccess = true>
		<cfset stResult.sql = sql>
		
		<cfif NOT arguments.bTestrun>
			
			<cfquery datasource="#variables.dsn#">
				#preserveSingleQuotes(sql)#
			</cfquery>
		
			<cfset stResult.message = "Array Property Table [#arguments.tablename#] deployed successfully.">
			<cfset stResult.bSuccess = true>
		</cfif>
		
		<cfreturn stResult />
	</cffunction>


	<cffunction name="generateDeploymentSQLArray" access="private" output="false" returntype="array" hint="This method generates an array of structs. Each struct contains the keys column, datatype, defaultValue and nullable. The value of each struct key contains a fragment of valid SQL for the current database.">
		<cfargument name="fields" type="struct" required="true" />
	  	  
		<cfset var i = "" />
		<cfset var fieldArray = structKeyArray(fields) />
		<cfset var column = "" />
		<cfset var SQLType = "" />
		<cfset var type = "" />
		<cfset var defaultValue = "" />
		<cfset var nullable = "" />
		<cfset var SQLArray = arrayNew(1) />
		<cfset var fieldSQL = structNew() />
	
	 	<cfset arraySort(fieldArray,'textNoCase') />	  
	  
		<cfloop from="1" to="#arrayLen(fieldArray)#" index="i">
			<cfset type = arguments.fields[fieldArray[i]].type>
		
			<cfif type neq 'array'>			  
			    <cfset column = fields[fieldArray[i]].name />
				<cfset SQLType = variables.dataMappings[type] />
			  	<cfset defaultValue = fields[fieldArray[i]].default />
				<cfif listFindNoCase(variables.numericTypes,fields[fieldArray[i]].type)>
					<cfif fields[fieldArray[i]].type EQ "boolean">
						<cfif ListFindNoCase("Yes,True,Y,1", trim(defaultValue))>
							<cfset defaultValue = 1>
						<cfelse>
							<cfset defaultValue = 0>
						</cfif>
					</cfif>
									
					<cfif len(trim(defaultValue))>
						<cfset defaultValue = "default #defaultValue#">
					<cfelse>
						<cfset defaultValue = "">
					</cfif>
				<cfelseif defaultValue eq "NULL" OR not len(trim(defaultValue))>
					<cfset defaultValue = "" />
				<cfelse>
					<cfset defaultValue = "default '#defaultValue#'">
				</cfif>
			
				<cfif fields[fieldArray[i]].nullable>
					<cfset nullable = "NULL" />
				<cfelse>
					<cfset nullable = "NOT NULL" />
				</cfif>
			  	<cfset fieldSQL = structNew() />
			  	<cfset fieldSQL.column = column />
			  	<cfset fieldSQl.defaultValue = defaultValue />
			  	<cfset fieldSQL.dataType = SQLType />
			  	<cfset fieldSQL.nullable = nullable />
			  	<cfset arrayAppend(SQLArray,fieldSQL) />
			</cfif>
			
		</cfloop>
	  
	  	<cfreturn SQLArray />	  
	</cffunction>


    <cffunction name="createArrayTableData" access="public" returntype="array" output="true" hint="Inserts the array table data for the given property data and returns the Array Table data as a list of objectids">
	    <cfargument name="tableName" type="string" required="true" />
	    <cfargument name="objectid" type="uuid" required="true" />
	    <cfargument name="tabledef" type="struct" required="true" />
	    <cfargument name="aProps" type="array" required="true" />    
	
	    <cfset var i = 0 />
	    <cfset var j = 0 />
	    <cfset var stProps = "" />
	    <cfset var SQLArray = "" />
	    <cfset var stTmp = "" />
		<cfset var lNewData = "" />
		<cfset var o = "" />	

		<!--- MJB
		Only delete records that are not contained in the Array of objects passed. This ensures that any extended array properties are not deleted.
		 --->
		<!--- 
		Create a list of objectids to be added. 
		This is required because in the case of extended arrays, the objectids are contained in a structure.
		--->	
		<cfloop from ="1" to="#arrayLen(aProps)#" index="i">
			<cfif isStruct(arguments.aProps[i]) AND structKeyExists(arguments.aProps[i],"data")>
				<cfset lNewData = ListAppend(lNewData,arguments.aProps[i].data)>
			<cfelse>
				<cfset lNewData = ListAppend(lNewData,arguments.aProps[i])>
			</cfif>
			
		</cfloop>

	
		<!--------------------------------------------------------- 
			IF THE ARRAY TABLE HAS HAD A CFC CREATED FOR IT IN 
			ORDER TO EXTEND IT THEN WE USE STANDARD GET, SET & 
			DELETE.
		 ---------------------------------------------------------->
		<cfif structKeyExists(application, "types") AND structKeyExists(application.types, tableName)>
			<cfset o = createObject("component",application.types[tablename].typepath) />
			
		    <cfquery datasource="#variables.dsn#" name="qArrayRecordsToDelete">
		    SELECT parentID FROM #variables.dbowner##arguments.tableName#
		    WHERE parentID = '#arguments.objectid#'
			<cfif listlen(lNewData)>
				AND data NOT IN (#ListQualify(lNewData,"'")#)
			</cfif>
		    </cfquery>
		    
		    <cfloop query="qArrayRecordsToDelete">
				<cfset stResult = o.deleteData(objectID=qArrayRecordsToDelete.parentID) />
			</cfloop>
		    
		<!---
		IT IS JUST A STANDARD ARRAY TABLE SO HAVE TO DELETE THE OBJECTS MANUALLY
		 --->	
		<cfelse>
		    <cfquery datasource="#variables.dsn#">
		    DELETE FROM #variables.dbowner##arguments.tableName#
		    WHERE parentID = '#arguments.objectid#'
			<cfif listlen(lNewData)>
				AND data NOT IN (#ListQualify(lNewData,"'")#)
			</cfif>
		    </cfquery>
			
		</cfif>
	
		<!--- MJB:
		This will allow us to ensure that any new objects to be placed in the array table will have a unique SEQ by setting the start to qCurrentArrayRecords.RecordCount.
		We could use a MAX(Seq) but unsure about DB compatibility.
		 --->
		<cfquery datasource="#variables.dsn#" name="qCurrentArrayRecords">
	    SELECT parentID
		FROM #variables.dbowner##arguments.tableName#
	    WHERE parentID = '#arguments.objectid#'
	    </cfquery>
		
				
		<cfloop from ="1" to="#arrayLen(aProps)#" index="i">
			<cfif NOT isStruct(arguments.aProps[i])>
				<cfset stTmp = structNew() />
				<cfset stTmp.parentID = arguments.objectid />
				<cfset stTmp.data = arguments.aProps[i] />
				<cfset arguments.aProps[i] = stTmp />
			</cfif>
			
		
			
			<cfquery datasource="#variables.dsn#" name="qDuplicate">
			SELECT parentID 
			FROM #variables.dbowner##tablename#
			WHERE parentID = '#arguments.objectid#'
			AND data = <cfqueryparam value="#arguments.aProps[i].data#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			
			
					
			<cfif NOT qDuplicate.RecordCount>
			
				<!--- 
				IF THE ARRAY TABLE HAS HAD A CFC CREATED FOR IT IN ORDER TO EXTEND IT THEN WE USE STANDARD GET, SET & DELETE.
				 --->
				<cfif structKeyExists(application, "types") AND structKeyExists(application.types, tableName)>
			
					<cfset stResult = o.createData(stProperties=arguments.aProps[i]) />	
					
					
				<!---
				IT IS JUST A STANDARD ARRAY TABLE SO HAVE TO DELETE THE OBJECTS MANUALLY
				 --->	
				<cfelse>
					<cfset SQLArray = generateSQLNameValueArray(arguments.tableDef,arguments.aProps[i]) />
					
					<cfquery datasource="#variables.dsn#" name="qCreateData">
					INSERT INTO #variables.dbowner##tablename# ( 
						parentID
						,seq
						<cfloop from="1" to="#arrayLen(SQLArray)#" index="j">
							<cfif sqlArray[j].column NEQ "seq" AND sqlArray[j].column NEQ "parentid">, #sqlArray[j].column#</cfif>						
						</cfloop>
					)
					VALUES ( 
					
					<cfqueryparam value="#arguments.objectid#" cfsqltype="CF_SQL_VARCHAR">
					,<cfqueryparam value="#qCurrentArrayRecords.RecordCount + i#" cfsqltype="CF_SQL_Integer"><!--- MJB: Add the current recordcount to the seq to ensure unique seq --->
						<cfloop from="1" to="#arrayLen(SQLArray)#" index="j">
							<cfif sqlArray[j].column NEQ "seq" AND sqlArray[j].column NEQ "parentid">
								<cfif structKeyExists(sqlArray[j],'cfsqltype')>
								, <cfqueryparam cfsqltype="#sqlArray[j].cfsqltype#" value="#sqlArray[j].value#" / >
								<cfelse>
								, #sqlArray[j].value#
								</cfif>
							</cfif>
						</cfloop>
					)			
					</cfquery>
				</cfif>
				
				
			</cfif>
		</cfloop>
		
	
		<!---------------------------------------------------------------
		WE NEED TO UPDATE THE TYPENAME OF EACH RECORD IN THE ARRAY TABLE
		 --------------------------------------------------------------->	
		<!--- 
		This is the approach used in DBGateway -- bust for mySQL 5 it seems.
		<cfquery name="update" datasource="#application.dsn#">
		UPDATE #variables.dbowner##tablename#
		SET #variables.dbowner##tablename#.typename = refObjects.typename		
		FROM #variables.dbowner##tablename# INNER JOIN refObjects
		ON #variables.dbowner##tablename#.data=refObjects.objectid	
		WHERE parentID = '#arguments.objectid#'			
		</cfquery>		
		--->
		
		<!--- This works for mySQL 5 --->
		<cfquery name="update" datasource="#application.dsn#" result="qRes">
		UPDATE #variables.dbowner##tablename#
		SET 
			#variables.dbowner##tablename#.typename = 
				(SELECT DISTINCT refObjects.typename
		         FROM refObjects
		         WHERE #variables.dbowner##tablename#.data=refObjects.objectid)
		WHERE parentID = '#arguments.objectid#'
		</cfquery> 
		
		
		<!--- MJB:
		Because we are no longer deleting the array table records, we need to re-do the sort  --->
		<cfset variables.sortorder = 1>
		<cfset variables.sorted = "">	<!--- MJB: This ensures that if a duplicate ObjectID is attempted to be attached, the sorting will not get out of wack. 
										This would occur if a user added an object to the end of the array that already existed previously. --->
		
		<cfset aReturn = ArrayNew(1)>
		
		<cfloop from ="1" to="#arrayLen(aProps)#" index="i">
			<cfif not listContainsNoCase(variables.sorted,arguments.aProps[i].data)>		
				<cfquery datasource="#variables.dsn#" name="qUpdateSeq">
				UPDATE #variables.dbowner##tablename#
				SET seq = #sortorder#
				WHERE parentID = '#arguments.objectid#'
				AND data = <cfqueryparam value="#arguments.aProps[i].data#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
				<cfset sortorder = sortorder + 1>
				<cfset variables.sorted = ListAppend(variables.sorted,arguments.aProps[i].data)>
				<cfset ArrayAppend(aReturn,arguments.aProps[i].data)>
			</cfif>
	 	</cfloop>
	
		<cfreturn aReturn>	
	</cffunction>
  
  
</cfcomponent>