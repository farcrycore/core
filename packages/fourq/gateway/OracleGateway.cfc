<cfcomponent extends="DBGateway">
	<!--- @@Note: this component works with the latest Oracle driver provided by Adobe. Other drivers such as Oracle OCI drivers may have problems
		  (esp. with NCLOBs). 2006/05/25
		  --->

	<cffunction name="init" access="public" returntype="OracleGateway" output="false" hint="Initializes the db specific data mappings for this db type">
		<cfargument name="dsn" type="string" required="true" />
		<cfargument name="dbowner" type="string" required="true" />
		<cfset super.init(arguments.dsn,arguments.dbowner) />
		<cfset variables.dataMappings = structNew() />
		<!--- in DBGateway, booleans are 1 or 0 --->
		<cfset variables.dataMappings.boolean      = "number" />
		<cfset variables.dataMappings.date         = "date" />
		<cfset variables.dataMappings.integer      = "integer" />
		<cfset variables.dataMappings.numeric      = "number" />
		<cfset variables.dataMappings.string       = "varchar2(255)" />
		<cfset variables.dataMappings.nstring      = "nvarchar2(255)" />
		<cfset variables.dataMappings.uuid         = "varchar2(50)" />
		<cfset variables.dataMappings.variablename = "varchar2(64)" />
		<cfset variables.dataMappings.color        = "varchar2(20)" />
		<cfset variables.dataMappings.email        = "varchar2(255)" />
		<cfset variables.dataMappings.longchar     = "nclob" />

		<cfreturn this />
	</cffunction>

<!---
 ************************************************************
 *                                                          *
 *                DEPLOYMENT METHODS                        *
 *                                                          *
 ************************************************************
 --->

	<cffunction name="deployType" access="public" output="false" returntype="struct" hint="Deploys the table structure for a FarCry type into a MySQL database.">
		<cfargument name="metadata"      type="farcry.core.packages.fourq.TableMetadata" required="true" />
		<cfargument name="bDropTable"    type="boolean" required="false" default="false">
		<cfargument name="bTestRun"      type="boolean" required="false" default="true">
		<cfargument name="dsn"           type="string" required="false" default="#variables.dsn#">
		<cfargument name="dbowner"       type="string" required="false" default="#variables.dbowner#">

		<cfset var i = "" />
		<cfset var fields = arguments.metadata.getTableDefinition() />
		<cfset var tablename = variables.dbowner & arguments.metadata.getTableName() />
		<cfset var result = structNew() />
		<cfset var SQLArray = generateDeploymentSQLArray(fields) />
		<cfset var local = structNew() />
		
		<cfif arguments.dbowner is not ""> 
			<cfset local.dbowner = left( arguments.dbowner, len(arguments.dbowner) - 1) />
		<cfelse> 
			<cfset local.dbowner = application.dbowner />
		</cfif> 

    <cfset result.bSuccess = true />

		<cfsavecontent variable="result.sql">
			<cfoutput>
			CREATE TABLE #tablename#(
			<cfloop from="1" to="#arrayLen(SQLArray)#" index="i">
				<cfif i GT 1>,</cfif>#SQLArray[i].column# #SQLArray[i].datatype# #SQLArray[i].defaultValue# #SQLArray[i].nullable#
			</cfloop>)
			</cfoutput>
		</cfsavecontent>

		<cfif NOT arguments.bTestRun>
			<cfif arguments.bDropTable>
			   <cfquery name="local.qryTableExists1" datasource="#variables.dsn#">
					select 1
					from   all_tables
					where  table_name = '#ucase(arguments.metadata.getTableName())#'
					and    owner      = '#ucase(local.dbowner)#'
				</cfquery>
				<cfif local.qryTableExists1.recordcount gt 0 >
   				<cfquery datasource="#variables.dsn#">
	   				DROP TABLE #tablename#
		   		</cfquery>
		   	</cfif>
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
	   	<cfargument name="fields"     type="struct" required="true" />
	   	<cfargument name="tablename"  type="string" required="true" />
		<cfargument name="bDropTable" type="boolean" required="false" default="false">
		<cfargument name="bTestRun"   type="boolean" required="false" default="true">
		<cfargument name="dbowner"    type="string" required="false" default="#variables.dbowner#">

		<cfset var stResult  = structNew() />
		<cfset var i         = "" />
		<cfset var SQLArray  = generateDeploymentSQLArray(arguments.fields) />
		<cfset var SQL       = "" />
		<cfset var local     = structNew() />
				
		
		<cfif arguments.dbowner is not ""> 
			<cfset local.dbowner = left( arguments.dbowner, len(arguments.dbowner) - 1) />
		<cfelse> 
			<cfset local.dbowner = application.dbowner />
		</cfif> 
						
		<cfif find(".",arguments.tablename) is not 0> 
			<cfset local.tablename = listLast(arguments.tablename,".") /> 
		<cfelse> 
			<cfset local.tablename = arguments.tablename> 
		</cfif> 

		<cfif arguments.bDropTable>
			<cfquery name="local.qryTableExists2" datasource="#variables.dsn#">
				select 1
				from   all_tables
				where  table_name = '#ucase(local.tablename)#'
				and    owner      = '#ucase(local.dbowner)#'
			</cfquery>
			<cfif local.qryTableExists2.recordcount gt 0 >
				<cftry>
					<cfquery datasource="#variables.dsn#">
						DROP TABLE #arguments.dbowner##local.tablename#
					</cfquery>
					<cfcatch>
					<cfrethrow /><!--- suppress error --->
					   <cftrace inline="false" text="Drop table #arguments.tablename# - failed" var="cfcatch.message" />
					</cfcatch>
				</cftry>
			</cfif>
		</cfif>

			<cfsavecontent variable="sql">
			<cfoutput>
				CREATE TABLE #arguments.dbowner##local.tablename#
				(
					<cfloop from="1" to="#arrayLen(SQLArray)#" index="i">
				    <cfif i GT 1>,</cfif>#SQLArray[i].column# #SQLArray[i].datatype# #SQLArray[i].defaultValue# #SQLArray[i].nullable#
					</cfloop>
				)
			</cfoutput>
			</cfsavecontent>
			<cfset stResult.message = "Test run for #arguments.tablename#. No database changes made." />
			<cfset stResult.bSuccess = true />
			<cfset stResult.sql = sql />

		<cfif NOT arguments.bTestrun>

				<cfquery datasource="#variables.dsn#">
				  #preserveSingleQuotes(sql)#
				</cfquery>

			<cfset stResult.message = "Array Property Table [#arguments.tablename#] deployed successfully." />
			<cfset stResult.bSuccess = true />
		</cfif>
		<cfreturn stResult />
	</cffunction>


	<cffunction name="generateDeploymentSQLArray" access="private" output="false" returntype="array" hint="This method generates an array of structs. Each struct contains the keys column, datatype, defaultValue and nullable. The value of each struct key contains a fragment of valid SQL for the current database.">
		<cfargument name="fields" type="struct" required="true" />

		<cfset var i            = "" />
		<cfset var fieldArray   = structKeyArray(fields) />
		<cfset var column       = "" />
		<cfset var SQLType      = "" />
		<cfset var type         = "" />
		<cfset var defaultValue = "" />
		<cfset var nullable     = "" />
		<cfset var SQLArray     = arrayNew(1) />
		<cfset var fieldSQL     = structNew() />

		<cfset arraySort(fieldArray,'textNoCase') />

		<cfloop from="1" to="#arrayLen(fieldArray)#" index="i">
			<cfset type = arguments.fields[fieldArray[i]].type>

			<cfif type neq 'array'>

				<cfset column = fields[fieldArray[i]].name />
				<cfset SQLType = variables.dataMappings[type] />
				<cfset defaultValue = fields[fieldArray[i]].default />

				<!--- determine and assign default value for column --->
				<cfif listFindNoCase(variables.numericTypes,fields[fieldArray[i]].type)>
					<cfif Len( Trim( defaultValue ) )>

						<!--- ensure booleans are recorded as 1/0 --->
						<cfif fields[fieldArray[i]].type eq 'boolean'>
							<cfif ListFindNoCase("Yes,True,Y,1", trim(defaultValue))>
								<cfset defaultValue = 1 />
							<cfelse>
								<cfset defaultValue = 0 />
							</cfif>
						</cfif>
						
						<cfset defaultValue = "default #defaultValue#" />
					<cfelse>
						<cfset defaultValue = "" />
					</cfif>
				
				<!--- AJM: added date test. Use string converter function --->
				<cfelseif Trim(fields[fieldArray[i]].type) eq 'date'>
					<cfif Len( Trim( defaultValue ) )>
						<cfset defaultValue = "default to_date('#defaultValue#','yyyy-mm-dd')" />
					<cfelse>
						<cfset defaultValue = "" />
					</cfif>

				<cfelse>
					<cfif defaultValue is not "NULL">
						<cfset defaultValue = "default '#defaultValue#'" />
					<cfelse>
						<cfset defaultValue = "" />
					</cfif>
				</cfif>

				<cfif fields[fieldArray[i]].nullable>
					<cfset nullable = "NULL" />
				<cfelse>
					<cfset nullable = "NOT NULL" />
				</cfif>

				<cfset fieldSQL = structNew() />
				<cfset fieldSQL.column       = column />
				<cfset fieldSQl.defaultValue = defaultValue />
				<cfset fieldSQL.dataType     = SQLType />
				<cfset fieldSQL.nullable     = nullable />
				<cfset arrayAppend(SQLArray,fieldSQL) />

			</cfif>

		</cfloop>

		<cfreturn SQLArray />

	</cffunction>


   <!--- bowden - overriden from dbgateway to handle longtext as clob. --->
	<cffunction name="generateSQLNameValueArray" access="private" output="false" returntype="array" hint="Generates an array of structs. Each struct contains three keys column, cfsqltype and value. The column matches the database column name and the value is the SQL fragment that should be passed to the database for the column. The cfsqltype indicates the value for the type attribute of the cfqueryparam tag.">
    <cfargument name="tableDef" type="struct" required="true" />
    <cfargument name="stProperties" type="struct" required="true" />
	  <cfset var field = "" />
	  <cfset var SQLArray = arrayNew(1) />
	  <cfset var propertyValue = "" />
   		<cfset var stField = structNew() />

    <cfloop collection="#tableDef#" item="field">

			<cfif StructKeyExists(arguments.stProperties, field)
              AND field NEQ "ObjectID"
              AND tableDef[field].type neq "array">
				<cfset stField = structNew() />
				<cfset stField.column = field />

				<cfset propertyValue = arguments.stProperties[field]>
				<!--- determine sql treatment --->
				<cfswitch expression="#tableDef[field].type#">

					<cfcase value="date">
						<cfif IsDate(propertyValue)>
	            			<cfset stField.cfsqltype = "CF_SQL_TIMESTAMP" />
							<cfset stField.value = propertyValue />
						<cfelseif tableDef[field].nullable>
							<cfset stField.value = "NULL" />
						<cfelse>
							<cfabort showerror="Error: #field# must be a date (#propertyValue#)." />
						</cfif>
					</cfcase>

					<cfcase value="numeric">
						<cfif IsNumeric(propertyValue)>
							<cfset stField.value = propertyValue />
						<cfelse>
							<cfset stField.value = 0>
						</cfif>
						<cfset stField.cfsqltype = "CF_SQL_FLOAT" />
					</cfcase>

					<cfcase value="boolean">
						<cfset propertyValue = YesNoFormat(propertyValue)>
						<cfif propertyValue eq "Yes">
							<cfset propertyValue = 1>
						<cfelseif propertyValue eq "No">
							<cfset propertyValue = 0>
						</cfif>
						<cfset stField.value = propertyValue />
                        <cfset stField.cfsqltype="CF_SQL_INTEGER" />
					</cfcase>

					<cfcase value="longchar">
						<cfset stField.value= propertyValue />
						<cfset stField.cfsqltype="CF_SQL_CLOB" />
					</cfcase>

					<cfdefaultcase>
						<!--- string data --->
						<cfset stField.value= propertyValue />
						<cfset stField.cfsqltype="CF_SQL_VARCHAR" />
					</cfdefaultcase>

				</cfswitch>

				<cfset arrayAppend(sqlArray,stField) />
			</cfif>
		</cfloop>
    <cfreturn sqlArray />
	</cffunction>
<!--- end - bowden --->

</cfcomponent>
