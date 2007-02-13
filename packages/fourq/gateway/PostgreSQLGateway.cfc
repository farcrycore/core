<cfcomponent extends="DBGateway">


	<cffunction name="init" access="public" returntype="PostgreSQLGateway" output="false" hint="Initializes the db specific data mappings for this db type">
		<cfargument name="dsn" type="string" required="true" />
		<cfargument name="dbowner" type="string" required="true" />
		
		<cfset super.init(arguments.dsn,arguments.dbowner) />
		<cfset variables.dataMappings = structNew() />
		<cfset variables.dataMappings.boolean = "int2" />
		<cfset variables.dataMappings.date = "timestamp" />
		<cfset variables.dataMappings.integer = "integer" />
		<cfset variables.dataMappings.numeric = "numeric" />
		<cfset variables.dataMappings.string = "varchar(255)" />
		<cfset variables.dataMappings.nstring = "varchar(255)" />
		<cfset variables.dataMappings.uuid = "varchar(50)" />
		<cfset variables.dataMappings.variablename = "varchar(64)" />
		<cfset variables.dataMappings.color = "varchar(20)" />
		<cfset variables.dataMappings.email = "varchar(255)" />
		<cfset variables.dataMappings.longchar = "text" />
		
		<cfreturn this />
	</cffunction>
	

	<!---
	 ************************************************************
	 *                                                          *
	 *                DEPLOYMENT METHODS                        *
	 *                                                          *
	 ************************************************************
	 --->
	<cffunction name="deployType" access="public" output="false" returntype="struct" hint="Deploys the table structure for a FarCry type into a Postgres database.">
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
		<cfset result.message = "">

		<cfsavecontent variable="result.sql"><cfoutput>
		CREATE TABLE #tablename#(<cfloop from="1" to="#arrayLen(SQLArray)#" index="i"><cfif i GT 1>
			,</cfif>#SQLArray[i].column# #SQLArray[i].datatype# #SQLArray[i].nullable# #SQLArray[i].defaultValue#</cfloop>
		);</cfoutput>
		</cfsavecontent>
		
		<cfif NOT arguments.bTestRun>
			<cfif arguments.bDropTable>
				<cftry>
					<!--- try to drop the table if it exists --->
					<cfquery datasource="#variables.dsn#">
					DROP TABLE #tablename#
					</cfquery>

					<cfcatch>
						<cflog text="#cfcatch.message# #cfcatch.detail# [SQL: #cfcatch.sql#]" file="coapi" type="warning" application="yes">
					</cfcatch>
				</cftry>
			</cfif>
			
			<cftry>
				<cfset result.bDeployed = true />
				<cfquery datasource="#variables.dsn#">
				#preserveSingleQuotes(result.sql)#
				</cfquery>

				<cflog text="Coapi Type Deployed [SQL: #preserveSingleQuotes(result.sql)#]" file="coapi" type="information" application="yes">

				<cfcatch>
					<cfset result.bDeployed = false />
    				<cfset result.bSuccess = false />
    				<cfset result.message = false />
					<cflog text="#cfcatch.message# #cfcatch.detail# [SQL: #cfcatch.sql#]" file="coapi" type="error" application="yes">
				</cfcatch>
			</cftry>

			
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
		
		<cfset var i = "" />
		<cfset var SQLArray = generateDeploymentSQLArray(arguments.fields) />
		<cfset var SQL = "" />
		<cfset var stResult = structNew() />
		<cfset stResult.message = "">
		<cfset stResult.bSuccess = true>
				
		<cfif arguments.bDropTable>
			<cftry>
				<cfquery datasource="#variables.dsn#">
				DROP TABLE #arguments.tablename#
				</cfquery>	
	
				<cfcatch>
					<cflog text="#cfcatch.message# #cfcatch.detail# [SQL: #cfcatch.sql#]" file="coapi" type="warning" application="yes">
				</cfcatch>
			</cftry>		
		</cfif>
		
		<cfsavecontent variable="sql"><cfoutput>
		CREATE TABLE #arguments.tablename#(<cfloop from="1" to="#arrayLen(SQLArray)#" index="i"><cfif i GT 1>
			,</cfif>#SQLArray[i].column# #SQLArray[i].datatype# #SQLArray[i].nullable# #SQLArray[i].defaultValue#</cfloop>
		)</cfoutput>
		</cfsavecontent>
		
		<cfif NOT arguments.bTestrun>		
			<cftry>
				<cfquery datasource="#variables.dsn#">
				#preserveSingleQuotes(sql)#
				</cfquery>
				<cfcatch>
					<cfset stResult.message = "ERROR: Type Property Table [#arguments.tablename#] not deployed successfully [Please read coapi log for details].">
					<cfset stResult.bSuccess = false>
					<cflog text="#cfcatch.message# #cfcatch.detail# [SQL: #cfcatch.sql#]" file="coapi" type="error" application="yes">				
				</cfcatch>
			</cftry>
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