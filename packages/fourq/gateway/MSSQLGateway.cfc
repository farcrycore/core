<cfcomponent extends="DBGateway">


	<cffunction name="init" access="public" returntype="MSSQLGateway" output="false" hint="Initializes the db specific data mappings for this db type">
		<cfargument name="dsn" type="string" required="true" />
		<cfargument name="dbowner" type="string" required="true" />
		
		<cfset super.init(arguments.dsn,arguments.dbowner) />
		<cfset variables.dataMappings = structNew() />
		<cfset variables.dataMappings.boolean = "[int]" />
		<cfset variables.dataMappings.date = "[DATETIME]" />
		<cfset variables.dataMappings.integer = "[INT]" />
		<cfset variables.dataMappings.numeric = "[NUMERIC]" />
		<cfset variables.dataMappings.string = "[VARCHAR] (255)" />
		<cfset variables.dataMappings.nstring = "[NVARCHAR] (512)" />
		<cfset variables.dataMappings.uuid = "[VARCHAR] (50)" />
		<cfset variables.dataMappings.variablename = "[VARCHAR] (64)" />
		<cfset variables.dataMappings.color = "[VARCHAR] (20)" />
		<cfset variables.dataMappings.email = "[VARCHAR] (255)" />
		<cfset variables.dataMappings.longchar = "[NTEXT]" />
		
		<cfreturn this />
	</cffunction>
	

	<!---
	 ************************************************************
	 *                                                          *
	 *                DEPLOYMENT METHODS                        *
	 *                                                          *
	 ************************************************************
	 --->
	<cffunction name="deployType" access="public" output="false" returntype="struct" hint="Deploys the table structure for a FarCry type into a MSSQL database.">
		<cfargument name="metadata" type="farcry.farcry_core.fourq.TableMetadata" required="true" />
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
			
			<cfif structKeyExists(fields,"objectid") AND structKeyExists(fields.objectid,  "nullable") AND NOT fields.objectid.nullable>
				,PRIMARY KEY (ObjectID)
			</cfif>
			
			); 
			</cfoutput>
		</cfsavecontent>

		<cfif NOT arguments.bTestRun>
			<cfif arguments.bDropTable>
				<!--- when looking up the system catalogue you don't specify database owner --->
				<cfset sysTableName = replaceNoCase(tableName, "DBO.", "") />
				<cfquery datasource="#variables.dsn#">
					if exists (select * from sysobjects where name = '#sysTableName#')
		      		drop table [#sysTableName#]
				</cfquery>
			</cfif>
			<cftry>
			<cfquery datasource="#variables.dsn#">
				#preserveSingleQuotes(result.sql)#
			</cfquery>
			
			<cfcatch>
			<cfdump var="#fields#" label="SQLArray" />
			<cfdump var="#cfcatch#" label="Error Variables" />
			<cfabort>
			</cfcatch>
			</cftry>
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


 	<cffunction name="deployArrayTable" access="public" returntype="struct" output="true">
   		<cfargument name="fields" type="struct" required="true" />
   		<cfargument name="tablename" type="string" required="true" />
		<cfargument name="bDropTable" type="boolean" required="false" default="false">
		<cfargument name="bTestRun" type="boolean" required="false" default="true">

		<cfset var stResult = structNew() />
		<cfset var i = "" />
		<cfset var SQLArray = generateDeploymentSQLArray(arguments.fields) />
		<cfset var SQL = "" />

		<cfset arguments.tablename = ListLast(arguments.tablename,".")>
		<!--- <cfif ListFindNoCase(arguments.tablename,variables.dbowner,".")>
			<cfset arrayTableName = arguments.tablename>
		<cfelse>
			<cfset arrayTableName = variables.dbowner & arguments.tablename>
		</cfif> --->
		
		<cfif arguments.bDropTable>
			<cftry>
				<!--- when looking up the system catalogue you don't specify database owner --->
				<cfset sysTableName = replaceNoCase(tableName, "DBO.", "") />
				<cfquery datasource="#variables.dsn#">
				if exists (select * from sysobjects where name = '#sysTableName#')
				drop table [#sysTableName#]
				</cfquery>	
				<cfcatch>
				<!--- Suppress Error --->
				   <cftrace inline="false" text="Drop table - failed" var="cfcatch.message">
				</cfcatch>
			</cftry>
			
		</cfif>
		
			<cfsavecontent variable="sql">
			<cfoutput>
				CREATE TABLE #variables.dbowner##arguments.tablename#
				(
					<cfloop from="1" to="#arrayLen(SQLArray)#" index="i">
				    <cfif i GT 1>,</cfif>#SQLArray[i].column# #SQLArray[i].datatype# #SQLArray[i].defaultValue# #IIF(listfindNocase("data,ParentID", SQLArray[i].column),  DE("NOT NULL"), DE(SQLArray[i].nullable))#
					</cfloop>
					PRIMARY KEY CLUSTERED (ParentID ,Data))
			</cfoutput>
			</cfsavecontent>
			<cfset stResult.message = "Test run for #arguments.tablename#. No database changes made.">
			<cfset stResult.bSuccess = true>
			<cfset stResult.sql = sql>
		
		<cfif NOT arguments.bTestrun>
			<cftry>
				<cfquery datasource="#variables.dsn#">
				  #preserveSingleQuotes(sql)#
				</cfquery>
				<cfquery datasource="#variables.dsn#">
					CREATE INDEX IDX_#arguments.tablename#_ParentID
					on #arguments.tablename#(ParentID)
				</cfquery>
				<cfcatch>
<cfoutput>
#preserveSingleQuotes(sql)#
</cfoutput>
<cfdump var="#arguments#"><cfabort>				
				</cfcatch>
			</cftry>
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
			<cfif type NEQ 'array'>			  
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
				<cfelseif defaultValue eq "NULL">
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


</cfcomponent>