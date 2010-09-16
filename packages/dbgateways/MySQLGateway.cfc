<cfcomponent extends="BaseGateway" dbType="mysql:MySQL" usesDBOwner="false">
	
	
	<cffunction name="getValueForDB" access="public" output="false" returntype="struct" hint="Returns cfsqltype, null, and value for specified metadata and value">
		<cfargument name="schema" type="struct" required="true" />
		<cfargument name="value" type="any" required="true" />
		
		<cfset var stResult = structnew() />
		
		<cfswitch expression="#arguments.schema.type#">
			<cfcase value="datetime">
				<cfset stResult.cfsqltype = "cf_sql_timestamp" />
				<cfset stResult.null = false />
				<cfif (arguments.value eq "" or arguments.value gt dateadd("yyyy",100,now()) or arguments.value eq "1 January 2050" or arguments.value eq "NULL") and arguments.schema.nullable>
					<cfset stResult.null = true />
					<cfset stResult.value = "" />
				<cfelseif arguments.value eq "" or arguments.value gt dateadd("yyyy",100,now()) or arguments.value eq "1 January 2050" or arguments.value eq "NULL">
					<cfset stResult.value = dateadd('yyyy',200,now()) />
				<cfelse>
					<cfset stResult.value = arguments.value />
				</cfif>
			</cfcase>
			<cfcase value="numeric">
				<cfif listlast(arguments.schema.precision) eq 0>
					<cfset stResult.cfsqltype = "cf_sql_integer" />
				<cfelse>
					<cfset stResult.cfsqltype = "cf_sql_float" />
				</cfif>
				<cfif arguments.schema.nullable and (arguments.value eq "" or arguments.value eq "NULL")>
					<cfset stResult.value = 0 />
					<cfset stResult.null = true />
				<cfelse>
					<cfset stResult.value = arguments.value />
					<cfset stResult.null = false />
				</cfif>
			</cfcase>
			<cfcase value="string,longchar" delimiters=",">
				<cfset stResult.cfsqltype = "cf_sql_varchar" />
				<cfif arguments.schema.nullable and (arguments.value eq "" or arguments.value eq "NULL")>
					<cfset stResult.value = "" />
					<cfset stResult.null = true />
				<cfelse>
					<cfset stResult.value = arguments.value />
					<cfset stResult.null = false />
				</cfif>
			</cfcase>
		</cfswitch>
		
		<cfreturn stResult />
	</cffunction>

	<!--- DEPLOYMENT --->
	<cffunction name="deploySchema" access="public" output="false" returntype="struct" hint="Deploys the table structure for a FarCry type into a MySQL database.">
		<cfargument name="schema" type="struct" required="true" />
		<cfargument name="bDropTable" type="boolean" required="false" default="false" />
		
		<cfset var stResult = structNew() />
		<cfset var queryresult = structnew() />
		<cfset var tempresult = structnew() />
		<cfset var thisfield = "" />
		<cfset var thisindex = "" />
		<cfset var stProp = structnew() />
		<cfset var bAddedOne = false />
		<cfset var i = 0 />
		
		<cfset stResult.results = arraynew(1) />
    	<cfset stResult.bSuccess = true />
		
		<cfif arguments.bDropTable>
			<cfset stResult = dropSchema(schema=arguments.schema)>
		</cfif>
		
		<cfif not isDeployed(schema=arguments.schema)>
			<cftry>
				<cfquery datasource="#variables.dsn#" result="queryresult">
					CREATE TABLE #variables.dbowner##arguments.schema.tablename#(
					
					<cfloop collection="#arguments.schema.fields#" item="thisfield">
						<cfif arguments.schema.fields[thisfield].type neq "array">
							<cfif bAddedOne>,</cfif>
							<cfset bAddedOne = true />
							
							<cfset stProp = arguments.schema.fields[thisfield] />
							
							#stProp.name# 
							<cfswitch expression="#stProp.type#">
								<cfcase value="numeric">
									<cfif stProp.precision eq "1,0">
										tinyint(1)
									<cfelse>
										decimal(#stProp.precision#)
									</cfif>
								</cfcase>
								<cfcase value="string">varchar(#stProp.precision#)</cfcase>
								<cfcase value="longchar">longtext</cfcase>
								<cfcase value="datetime">datetime</cfcase>
							</cfswitch>
							
							<cfif stProp.nullable>NULL<cfelse>NOT NULL</cfif>
							
							<cfset stVal = getValueForDB(schema=stProp,value=stProp.default) />
							<cfif stProp.type neq "longchar" and (not stProp.type eq "numeric" or isnumeric(stProp.default))>DEFAULT <cfqueryparam cfsqltype="#stVal.cfsqltype#" null="#stVal.null#" value="#stVal.value#" /></cfif>
						</cfif>
					</cfloop>
					
					); 
				</cfquery>
				
				<cfset arrayappend(stResult.results,queryresult) />
			
				<cfcatch type="database">
					<cfset arrayappend(stResult.results,cfcatch) />
					<cfset stResult.bSuccess = false />
				</cfcatch>
			</cftry>
		</cfif>
		
		<cfif stResult.bSuccess>
			<cfloop collection="#arguments.schema.fields#" item="thisfield">
				<cfif arguments.schema.fields[thisfield].type eq 'array'>
					<cfset combineResults(stResult,deploySchema(schema=arguments.schema.fields[thisfield],bDropTable=arguments.bDropTable)) />
				</cfif>
			</cfloop>
			
			<cfloop collection="#arguments.schema.indexes#" item="thisindex">
				<cfset combineResults(stResult,addIndex(schema=arguments.schema,indexname=thisindex)) />
			</cfloop>
		</cfif>
		
		<cfif stResult.bSuccess>
			<cfset stResult.message = "Deployed '#arguments.schema.tablename#' table" />
		<cfelse>
			<cfset stResult.message = "Failed to deploy '#arguments.schema.tablename#' table" />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="addColumn" access="public" output="false" returntype="struct" hint="Runs an ALTER sql command for the property. Not for use with array properties.">
		<cfargument name="schema" type="struct" required="true" hint="The type schema" />
		<cfargument name="propertyname" type="string" required="true" hint="The property to add" />
		
		<cfset var stProp = arguments.schema.fields[arguments.propertyname] />
		<cfset var stResult = structnew() />
		<cfset var queryresult = "" />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.results = arraynew(1) />
		
		<cftry>
			<cfquery datasource="#variables.dsn#" result="queryresult">
				ALTER TABLE #variables.dbowner##arguments.schema.tablename#
				ADD #stProp.name# 
				<cfswitch expression="#stProp.type#">
					<cfcase value="numeric">
						<cfif stProp.precision eq "1,0">
							tinyint(1)
						<cfelseif listlast(stProp.precision) eq "0">
							int
						<cfelse>
							decimal(#stProp.precision#)
						</cfif>
					</cfcase>
					<cfcase value="string">varchar(#stProp.precision#)</cfcase>
					<cfcase value="longchar">longtext</cfcase>
					<cfcase value="datetime">datetime</cfcase>
				</cfswitch>
				<cfif stProp.nullable>NULL<cfelse>NOT NULL</cfif>
				<cfset stVal = getValueForDB(schema=stProp,value=stProp.default) />
				<cfif stProp.type neq "longchar">DEFAULT <cfqueryparam cfsqltype="#stVal.cfsqltype#" null="#stVal.null#" value="#stVal.value#" /></cfif>
			</cfquery>
			
			<cfset arrayappend(stResult.results,queryresult) />
			
			<cfcatch type="database">
				<cfset stResult.bSuccess = false />
				<cfset arrayappend(stResult.results,cfcatch) />
			</cfcatch>
		</cftry>
		
		<cfif stResult.bSuccess>
			<cfset stResult.message = "Deployed '#arguments.schema.tablename#.#arguments.propertyname#' column" />
		<cfelse>
			<cfset stResult.message = "Failed to deploy '#arguments.schema.tablename#.#arguments.propertyname#' column" />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="repairColumn" access="public" output="false" returntype="struct" hint="Runs an ALTER sql command for the property. Not for use with array properties.">
		<cfargument name="schema" type="struct" required="true" hint="The type schema" />
		<cfargument name="propertyname" type="string" required="true" hint="The property to repair" />
		<cfargument name="oldpropertyname" type="string" required="false" default="#arguments.propertyname#" hint="The property to rename" />
		
		<cfset var stProp = arguments.schema.fields[arguments.propertyname] />
		<cfset var stResult = structnew() />
		<cfset var queryresult = "" />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.results = arraynew(1) />
		
		<cftry>
			<cfquery datasource="#variables.dsn#" result="queryresult">
				ALTER TABLE #variables.dbowner##arguments.schema.tablename#
				CHANGE #arguments.oldpropertyname# #stProp.name# 
				<cfswitch expression="#stProp.type#">
					<cfcase value="numeric">
						<cfif stProp.precision eq "1,0">
							tinyint(1)
						<cfelseif listlast(stProp.precision) eq "0">
							int
						<cfelse>
							decimal(#stProp.precision#)
						</cfif>
					</cfcase>
					<cfcase value="string">varchar(#stProp.precision#)</cfcase>
					<cfcase value="longchar">longtext</cfcase>
					<cfcase value="datetime">datetime</cfcase>
				</cfswitch>
				<cfif stProp.nullable>NULL<cfelse>NOT NULL</cfif>
				<cfset stVal = getValueForDB(schema=stProp,value=stProp.default) />
				<cfif stProp.type neq "longchar">DEFAULT <cfqueryparam cfsqltype="#stVal.cfsqltype#" null="#stVal.null#" value="#stVal.value#" /></cfif>
			</cfquery>
			
			<cfset arrayappend(stResult.results,queryresult) />
			
			<cfcatch type="database">
				<cfset stResult.bSuccess = false />
				<cfset arrayappend(stResult.results,cfcatch) />
			</cfcatch>
		</cftry>
		
		<cfif stResult.bSuccess>
			<cfset stResult.message = "Repaired '#arguments.schema.tablename#.#arguments.propertyname#' column" />
		<cfelse>
			<cfset stResult.message = "Failed to repair '#arguments.schema.tablename#.#arguments.propertyname#' column" />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="dropColumn" access="public" output="false" returntype="struct" hint="Runs an ALTER sql command for the property. Not for use with array properties.">
		<cfargument name="schema" type="struct" required="true" hint="The type schema" />
		<cfargument name="propertyname" type="string" required="true" hint="The property to remove" />
		
		<cfset var stResult = structnew() />
		<cfset var queryresult = "" />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.results = arraynew(1) />
		
		<cftry>
			<cfquery datasource="#variables.dsn#" result="queryresult">
				ALTER TABLE #variables.dbowner##arguments.schema.tablename#
				DROP		#arguments.propertyname#
			</cfquery>
			
			<cfset arrayappend(stResult.results,queryresult) />
			
			<cfcatch type="database">
				<cfset stResult.bSuccess = false />
				<cfset arrayappend(stResult.results,cfcatch) />
			</cfcatch>
		</cftry>
		
		<cfif stResult.bSuccess>
			<cfset stResult.message = "Dropped '#arguments.schema.tablename#.#arguments.propertyname#' column" />
		<cfelse>
			<cfset stResult.message = "Failed to drop '#arguments.schema.tablename#.#arguments.propertyname#' column" />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<!--- DATABASE INTROSPECTION --->
	<cffunction name="introspectIndexes" returntype="struct" access="private" output="false" hint="Constructs metadata struct for table indexes">
		<cfargument name="tablename" type="string" required="True" hint="The table to introspect" />
		
		<cfset var stResult = structnew() />
		<cfset var getMySQLIndexes = "" />
		
		<!--- Get all tables in database--->
		<cfquery name="getMySQLIndexes" datasource="#variables.dsn#">
			SHOW INDEX FROM #arguments.tablename#
		</cfquery>
		
		<cfquery name="getMySQLIndexes" dbtype="query">
			select		*
			from		getMySQLIndexes
			order by	Key_name,Seq_in_index
		</cfquery>
		
		<cfoutput query="getMySQLIndexes" group="Key_name">
			<cfset stResult[getMySQLIndexes.Key_Name] = structnew() />
			<cfset stResult[getMySQLIndexes.Key_Name].name = getMySQLIndexes.Key_Name />
			<cfif getMySQLIndexes.Key_Name eq "primary">
				<cfset stResult[getMySQLIndexes.Key_Name].type = "primary" />
			<cfelse>
				<cfset stResult[getMySQLIndexes.Key_Name].type = "unclustered" />
			</cfif>
			<cfset stResult[getMySQLIndexes.Key_Name].fields = arraynew(1) />
			<cfoutput>
				<cfset arrayappend(stResult[getMySQLIndexes.Key_Name].fields,getMySQLIndexes.Column_name) />
			</cfoutput>
		</cfoutput>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="introspectTable" returntype="struct" access="private" output="false" hint="Constructs a metadata struct for the table">
		<cfargument name="tablename" type="string" required="True" hint="The table to introspect" />
		
		<cfset var stResult = structnew() />
		<cfset var getMySQLTables = "" />
		<cfset var myTable = "" />
		<cfset var GetMySQLColumns = "" />
		<cfset var openbracket = "" />
		<cfset var closebracket = "" />
		<cfset var myLength = "" />
		<cfset var myType = "" />
		<cfset var stColumn = structnew() />
		<cfset var thisindex = "" />
		<cfset var thisfield = "" />
		<cfset var thispos = 0 />
		
		<cfset stResult.tablename = arguments.tablename />
		<cfset stResult.fields = structnew() />
		
		<!--- Get all tables in database--->
		<cfquery name="getMySQLTables" datasource="#variables.dsn#">
			SHOW TABLES like '#arguments.tablename#'
		</cfquery>
		
		<cfloop query="getMySQLTables">
			<!--- Get tablename --->
			<cfset myTable = GetMySQLTables[columnlist][currentrow]>
			
			<!--- Get column details of each table--->
			<cfquery name="GetMySQLColumns" datasource="#variables.dsn#">
				SHOW COLUMNS FROM #myTable#
			</cfquery>
			
			<!--- Loop thru columns --->
			<cfloop query="GetMySQLColumns">
				<cfset stColumn = structnew() />
				<cfset stColumn.name = GetMySQLColumns.field />
				<cfif GetMySQLColumns.null eq "yes">
					<cfset stColumn.nullable = true />
				<cfelse>
					<cfset stColumn.nullable = false />
				</cfif>
				<cfset stColumn.default = GetMySQLColumns.default />
				<cfif stColumn.default eq "" and stColumn.nullable>
					<cfset stColumn.default = "NULL" />
				</cfif>
				<cfset stColumn.precision = "" />
				
				<cfif find("(",type)>
					<cfset openbracket = find("(",GetMySQLColumns.type) />
					<cfset closebracket = find(")",GetMySQLColumns.type) />
					<cfset stColumn.precision = mid(GetMySQLColumns.type,openbracket+1,closebracket-(openbracket+1)) />
					<cfset stColumn.type = left(GetMySQLColumns.type,openbracket-1) />
				<cfelse>
					<cfset stColumn.type = GetMySQLColumns.type />
					<cfset stColumn.precision = "" />
				</cfif>
				
				<cfswitch expression="#stColumn.type#">
					<cfcase value="longtext,text" delimiters=",">
						<cfset stColumn.type = "longchar" />
					</cfcase>
					<cfcase value="tinyint">
						<cfset stColumn.type = "numeric" />
						<cfset stColumn.precision = "1,0" />
					</cfcase>
					<cfcase value="varchar">
						<cfset stColumn.type = "string" />
					</cfcase>
					<cfcase value="decimal">
						<cfset stColumn.type = "numeric" />
					</cfcase>
					<cfcase value="int">
						<cfset stColumn.type = "numeric" />
						<cfset stColumn.precision = "#stColumn.precision#,0" />
					</cfcase>
					<cfcase value="datetime">
						<cfif stColumn.default gt dateadd('yyyy',100,now()) and stColumn.nullable>
							<cfset stColumn.default = "NULL" />
						<cfelseif stColumn.default gt dateadd('yyyy',100,now())>
							<cfset stColumn.default = "" />
						</cfif>
					</cfcase>
				</cfswitch>
				
				<cfset stResult.fields[stColumn.name] = stColumn />
			</cfloop>
		</cfloop>
		
		<!--- Table indexes --->
		<cfset stResult.indexes = introspectIndexes(arguments.tablename) />
		<cfloop collection="#stResult.indexes#" item="thisindex">
			<cfloop from="1" to="#arraylen(stResult.indexes[thisindex].fields)#" index="thispos">
				<cfset thisfield = stResult.indexes[thisindex].fields[thispos] />
				<cfparam name="stResult.fields.#thisfield#.index" default="" />
				<cfset stResult.fields[thisfield].index = listsort(listappend(stResult.fields[thisfield].index,"#thisindex#:#thispos#"),"textnocase","asc") />
			</cfloop>
		</cfloop>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="introspectType" returntype="struct" access="public" output="false" hint="Constructs a metadata struct for a type and it's array properties">
		<cfargument name="typename" type="string" required="true" hint="The type to introspect" />
		
		<cfset var stResult = structnew() />
		<cfset var stTemp = structnew() />
		
		<!--- Get basic table columns--->
		<cfquery datasource="#variables.dsn#" name="qTables">
			SHOW TABLES like '#arguments.typename#'
		</cfquery>
		<cfloop query="qTables">
			<cfset structappend(stResult,introspectTable(qTables[columnlist][currentrow]),true) />
		</cfloop>
		
		<!--- Get extended array tables --->
		<cfquery datasource="#variables.dsn#" name="qTables">
			show tables
		</cfquery>
		<cfquery dbtype="query" name="qTables">
			select 	#qTables.columnlist# as name
			from 	qTables
			where 	upper(#qTables.columnlist#) like '#ucase(arguments.typename)#@_%' escape '@'
		</cfquery>
		
		<cfloop query="qTables">
			<cfset stTemp = structnew() />
			<cfset stTemp.name = listlast(qTables[columnlist][currentrow],"_") />
			<cfset stTemp.type = "array" />
			<cfset stTemp.default = "NULL" />
			<cfset stTemp.nullable = true />
			<cfset structappend(stTemp,introspectTable(qTables[columnlist][currentrow]),true) />
			<cfset stResult.fields[listlast(qTables[columnlist][currentrow],"_")] = stTemp />
		</cfloop>
	
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="isFieldAltered" access="public" returntype="boolean" output="false" hint="Returns true if there is a difference">
		<cfargument name="expected" type="struct" required="true" hint="The expected schema" />
		<cfargument name="actual" type="struct" required="true" hint="The actual schema" />
		
		<cfreturn arguments.expected.nullable neq arguments.actual.nullable
				  OR (arguments.expected.type neq "longchar" and arguments.expected.default neq arguments.actual.default)
				  OR arguments.expected.type neq arguments.actual.type
				  OR arguments.expected.precision neq arguments.actual.precision />
	</cffunction>
	
</cfcomponent>