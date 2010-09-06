<cfcomponent name="HSQLDBGateway" extends="DBGateway">

	<cffunction name="init" access="public" returntype="HSQLDBGateway" output="false" 
		hint="Initializes the db specific data mappings for this db type">
		
		<cfargument name="dsn" type="string" required="true" />
		<cfargument name="dbowner" type="string" required="true" />
		<cfargument name="dbtype" type="string" required="true" />
		
		<cfset super.init(argumentCollection=arguments) />
		
		<cfset variables.dataMappings = structNew() />
		<cfset variables.dataMappings.boolean = "BOOLEAN" />
		<cfset variables.dataMappings.date = "DATETIME" />
		<cfset variables.dataMappings.integer = "INT" />
		<cfset variables.dataMappings.numeric = "NUMERIC" />
		<cfset variables.dataMappings.string = "VARCHAR(255)" />
		<cfset variables.dataMappings.nstring = "VARCHAR(255)" />
		<cfset variables.dataMappings.uuid = "VARCHAR(50)" />
		<cfset variables.dataMappings.variablename = "VARCHAR(64)" />
		<cfset variables.dataMappings.color = "VARCHAR(20)" />
		<cfset variables.dataMappings.email = "VARCHAR(255)" />
		<cfset variables.dataMappings.longchar = "LONGVARCHAR" />
		
		<cfreturn this />
	</cffunction>


	<!---
	 ************************************************************
	 *                                                          *
	 *                DEPLOYMENT METHODS                        *
	 *                                                          *
	 ************************************************************
	 --->
	<cffunction name="deployType" access="public" output="false" returntype="struct" 
		hint="Deploys the table structure for a FarCry type into a HSQL database.">
		
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
		
		<!--- For some reason (need to dig deeper) this value can be "default NULL" which is odd. At the
			least is should just be "default" (which causes an HSQLDB error by itself) --->
		<!--- <cfset var strDefaultValue = trim(replaceNoCase(SQLArray[i].defaultValue,"NULL","")) />
		<cfif strDefaultValue eq "default">
			<cfset var strDefaultValue = "" />
		</cfif> --->
		<cfset var strDefaultValue = "" />
		
    	<cfset result.bSuccess = true />
		
		
		
		<cfsavecontent variable="result.sql">
			<cfoutput>
			CREATE TABLE #tablename# (
			<cfloop from="1" to="#arrayLen(SQLArray)#" index="i">
				<cfif i GT 1>,</cfif>
				<cfif SQLArray[i].column eq "position">
					"#SQLArray[i].column#"
				<cfelse>
					#SQLArray[i].column#
				</cfif>
				#SQLArray[i].datatype#
				
				<cfswitch expression="#SQLArray[i].datatype#">
					<cfcase value="longtext,longchar">
						<!--- No Default Allowed on BLOB fields --->
					</cfcase>
					<cfcase value="string,nstring,uuid,variable,color,email,varchar">
						'#strDefaultValue#'
					</cfcase>
					<cfdefaultcase>
						#strDefaultValue#
					</cfdefaultcase>
				</cfswitch>

				#SQLArray[i].nullable#
				
				<cfif #SQLArray[i].column# eq "objectid">
				PRIMARY KEY
				</cfif>
				
			</cfloop>
			); 
			</cfoutput>
		</cfsavecontent>
		
		
		<!--- <cfoutput>#result.sql#</cfoutput>--->
		
		
		<cfif NOT arguments.bTestRun>
			<cfif arguments.bDropTable>
				<cfquery datasource="#variables.dsn#">
					DROP TABLE #tablename# IF EXISTS; 
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
		    	<cfset arrayAppend(
		    		result.arrayTables,
		    		deployArrayTable(
		    			fields[i].fields,
		    			tablename&"_"&fields[i].name,
		    			arguments.bDropTable,
		    			arguments.bTestRun
		    		)
		    	) />
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
					DROP TABLE #arguments.tablename# IF EXISTS;
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
				    <cfif i GT 1>,</cfif>
				    #SQLArray[i].column# #SQLArray[i].datatype# #SQLArray[i].defaultValue# #SQLArray[i].nullable#
					</cfloop>
				);
			</cfoutput>
		</cfsavecontent>
		
		<!--- <cfoutput>#sql#</cfoutput> --->
		
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


	<cffunction name="generateDeploymentSQLArray" access="private" output="false" returntype="array" 
		hint="This method generates an array of structs. Each struct contains the keys column, datatype, defaultValue and nullable. The value of each struct key contains a fragment of valid SQL for the current database.">
		
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