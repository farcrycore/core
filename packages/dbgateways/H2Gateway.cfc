<cfcomponent extends="MySQLGateway" dbType="h2:H2" usesDBOwner="false">
	
	<!--- DEPLOYMENT --->
	
	<cffunction name="getDeploySchemaSQL" access="public" output="false" returntype="string" hint="The returns the sql for Deployment of the table structure for a FarCry type into a MySQL database.">
		<cfargument name="schema" type="struct" required="true" />
		
		<cfset var resultSQL = "">
		<cfset var bAddedOne = false />
		
		<cfsavecontent variable="resultSQL">
			<cfoutput>
			CREATE TABLE #this.dbowner##arguments.schema.tablename#(
			
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
						<cfcase value="string">
							<cfif stProp.precision eq "MAX">
								varchar(2000)
							<cfelse>
								varchar(#stProp.precision#)
							</cfif>
						</cfcase>
						<cfcase value="longchar">longtext</cfcase>
						<cfcase value="datetime">datetime</cfcase>
					</cfswitch>
					
					<cfif stProp.nullable>NULL<cfelse>NOT NULL</cfif>
					
					<cfset stVal = getValueForDB(schema=stProp,value=stProp.default) />
					<cfif stProp.type neq "longchar" and (not stProp.type eq "numeric" or isnumeric(stProp.default))>DEFAULT <cfif stVal.null>NULL<cfelseif stVal.cfsqltype eq "cf_sql_varchar">'#stVal.value#'<cfelseif stVal.cfsqltype eq "cf_sql_timestamp">'#dateformat(stVal.value,"yyyy-MM-dd")# #timeformat(stVal.value,"hh:mm:ss")#'<cfelse>#stVal.value#</cfif></cfif>
				</cfif>
			</cfloop>
			
			);
			</cfoutput>
		</cfsavecontent>
		
		
		<cfreturn resultSQL>
	</cffunction>
	
	<cffunction name="deploySchema" access="public" output="false" returntype="struct" hint="Deploys the table structure for a FarCry type into a MySQL database.">
		<cfargument name="schema" type="struct" required="true" />
		<cfargument name="bDropTable" type="boolean" required="false" default="false" />
		<cfargument name="logLocation" type="string" required="false" default="" />
		
		<cfset var stResult = structNew() />
		<cfset var queryresult = structnew() />
		<cfset var tempresult = structnew() />
		<cfset var thisfield = "" />
		<cfset var thisindex = "" />
		<cfset var stProp = structnew() />
		<cfset var bAddedOne = false />
		<cfset var i = 0 />
		<cfset var deploySchemaSQL = "" />
		
		<cfset stResult.results = arraynew(1) />
    	<cfset stResult.bSuccess = true />
		
		<cfif arguments.bDropTable>
			<cfset stResult = dropSchema(schema=arguments.schema,logLocation=arguments.logLocation)>
		</cfif>
		
		<cfif not isDeployed(schema=arguments.schema)>
			<cftry>
				<cfset deploySchemaSQL = getDeploySchemaSQL(schema="#arguments.schema#")>
				<cfquery datasource="#this.dsn#" result="queryresult">
					#deploySchemaSQL#
				</cfquery>
				
				<cfset arrayappend(stResult.results,queryresult) />
				<cfif len(arguments.logLocation)>
					<cfset logQuery(arguments.logLocation,queryresult) />
				</cfif>
			
				<cfcatch type="database">
					<cfset arrayappend(stResult.results,cfcatch) />
					<cfset stResult.bSuccess = false />
				</cfcatch>
			</cftry>
		</cfif>
		
		<cfif stResult.bSuccess>
			<cfloop collection="#arguments.schema.fields#" item="thisfield">
				<cfif arguments.schema.fields[thisfield].type eq 'array'>
					<cfset combineResults(stResult,deploySchema(schema=arguments.schema.fields[thisfield],bDropTable=arguments.bDropTable,logLocation=arguments.logLocation)) />
				</cfif>
			</cfloop>
			
			<cfloop collection="#arguments.schema.indexes#" item="thisindex">
				<cfset combineResults(stResult,addIndex(schema=arguments.schema,indexname=thisindex,logLocation=arguments.logLocation)) />
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
		<cfargument name="logLocation" type="string" required="false" default="" />
		
		<cfset var stProp = arguments.schema.fields[arguments.propertyname] />
		<cfset var stResult = structnew() />
		<cfset var queryresult = "" />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.results = arraynew(1) />
		
		<cftry>
			<cfquery datasource="#this.dsn#" result="queryresult">
				ALTER TABLE #this.dbowner##arguments.schema.tablename#
				ADD #stProp.name# 
				<cfswitch expression="#stProp.type#">
					<cfcase value="numeric">
						<cfif stProp.precision eq "1,0">
							tinyint(1)
						<cfelse>
							decimal(#stProp.precision#)
						</cfif>
					</cfcase>
					<cfcase value="string">
						<cfif stProp.precision eq "MAX">
							varchar(2000)
						<cfelse>
							varchar(#stProp.precision#)
						</cfif>
					</cfcase>
					<cfcase value="longchar">longtext</cfcase>
					<cfcase value="datetime">datetime</cfcase>
				</cfswitch>
				<cfif stProp.nullable>NULL<cfelse>NOT NULL</cfif>
				<cfset stVal = getValueForDB(schema=stProp,value=stProp.default) />
				<cfif stProp.type neq "longchar">DEFAULT <cfif stVal.null>NULL<cfelseif stVal.cfsqltype eq "cf_sql_varchar">'#stVal.value#'<cfelseif stVal.cfsqltype eq "cf_sql_timestamp">'#dateformat(stVal.value,"yyyy-MM-dd")# #timeformat(stVal.value,"hh:mm:ss")#'<cfelse>#stVal.value#</cfif></cfif>
			</cfquery>
			
			<cfset arrayappend(stResult.results,queryresult) />
			<cfif len(arguments.logLocation)>
				<cfset logQuery(arguments.logLocation,queryresult) />
			</cfif>
			
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
		<cfargument name="logLocation" type="string" required="false" default="" />
		
		<cfset var stProp = arguments.schema.fields[arguments.propertyname] />
		<cfset var stResult = structnew() />
		<cfset var queryresult = "" />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.results = arraynew(1) />
		
		<cftry>
			<!--- Rename column --->
			<cfif arguments.propertyname neq arguments.oldpropertyname>
				<cfquery datasource="#this.dsn#" result="queryresult">
					ALTER TABLE #this.dbowner##arguments.chema.tablename#
					ALTER COLUMN #arguments.oldpropertyname# RENAME TO #arguments.propertyname#
				</cfquery>
				<cfset arrayappend(stResult.results,queryresult) />
				<cfif len(arguments.logLocation)>
					<cfset logQuery(arguments.logLocation,queryresult) />
				</cfif>
			</cfif>
			
			<!--- Alter column --->
			<cfquery datasource="#this.dsn#" result="queryresult">
				ALTER TABLE #this.dbowner##arguments.schema.tablename#
				ALTER COLUMN #stProp.name# 
				<cfswitch expression="#stProp.type#">
					<cfcase value="numeric">
						<cfif stProp.precision eq "1,0">
							tinyint(1)
						<cfelse>
							decimal(#stProp.precision#)
						</cfif>
					</cfcase>
					<cfcase value="string">
						<cfif stProp.precision eq "MAX">
							varchar(2000)
						<cfelse>
							varchar(#stProp.precision#)
						</cfif>
					</cfcase>
					<cfcase value="longchar">longtext</cfcase>
					<cfcase value="datetime">datetime</cfcase>
				</cfswitch>
				<cfif stProp.nullable>NULL<cfelse>NOT NULL</cfif>
				<cfset stVal = getValueForDB(schema=stProp,value=stProp.default) />
				<cfif stProp.type neq "longchar">DEFAULT <cfif stVal.null>NULL<cfelseif stVal.cfsqltype eq "cf_sql_varchar">'#stVal.value#'<cfelseif stVal.cfsqltype eq "cf_sql_timestamp">'#dateformat(stVal.value,"yyyy-MM-dd")# #timeformat(stVal.value,"hh:mm:ss")#'<cfelse>#stVal.value#</cfif></cfif>
			</cfquery>
			
			<cfset arrayappend(stResult.results,queryresult) />
			<cfif len(arguments.logLocation)>
				<cfset logQuery(arguments.logLocation,queryresult) />
			</cfif>
			
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
	
	<cffunction name="addIndex" access="public" output="false" returntype="struct" hint="Deploys the index into a MySQL database.">
		<cfargument name="schema" type="struct" required="true" />
		<cfargument name="indexname" type="string" required="true" />
		<cfargument name="logLocation" type="string" required="false" default="" />
		
		<cfset var stIndex = arguments.schema.indexes[arguments.indexname] />
		<cfset var stResult = structnew() />
		<cfset var queryresult = "" />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.results = arraynew(1) />
		
		<cftry>
			<cfswitch expression="#stIndex.type#">
				<cfcase value="primary">
					<cfquery datasource="#this.dsn#" result="queryresult">
					 	ALTER TABLE 	#this.dbowner##arguments.schema.tablename#
						ADD 			PRIMARY KEY
										(#arraytolist(stIndex.fields)#)
					</cfquery>
				</cfcase>
				<cfcase value="unclustered">
					<cfquery datasource="#this.dsn#" result="queryresult">
					 	CREATE INDEX 	#arguments.schema.tablename#_#stIndex.name# 
					 	ON 				#this.dbowner##arguments.schema.tablename# 
					 					(#arraytolist(stIndex.fields)#)
					</cfquery>
				</cfcase>
			</cfswitch>
			
			<cfset arrayappend(stResult.results,queryresult) />
			<cfif len(arguments.logLocation)>
				<cfset logQuery(arguments.logLocation,queryresult) />
			</cfif>
			
			<cfcatch type="database">
				<cfset stResult.bSuccess = false />
				<cfset arrayappend(stResult.results,cfcatch) />
			</cfcatch>
		</cftry>
		
		<cfif stResult.bSuccess>
			<cfset stResult.message = "Deployed '#arguments.schema.tablename#_#arguments.indexname#' index on #arguments.schema.tablename#" />
		<cfelse>
			<cfset stResult.message = "Failed to deploy '#arguments.schema.tablename#_#arguments.indexname#' index on #arguments.schema.tablename#" />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="dropIndex" access="public" output="false" returntype="struct" hint="Drops the index from a MySQL database.">
		<cfargument name="schema" type="struct" required="true" />
		<cfargument name="indexname" type="string" required="true" />
		<cfargument name="logLocation" type="string" required="false" default="" />
		
		<cfset var stResult = structnew() />
		<cfset var queryresult = "" />
		<cfset var stDB = introspectType(arguments.schema.tablename) />
		<cfset var stIndex = structnew() />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.results = arraynew(1) />
		
		<cfif not structkeyexists(stDB.indexes,arguments.indexname)>
			<cfreturn stResult />
		</cfif>
		
		<cfset stIndex = stDB.indexes[arguments.indexname] />
		
		<cftry>
			<cfswitch expression="#stIndex.type#">
				<cfcase value="primary">
					<cfquery datasource="#this.dsn#" result="queryresult">
						ALTER TABLE 	#this.dbowner##arguments.schema.tablename#
						DROP 			PRIMARY KEY
					</cfquery>
				</cfcase>
				<cfcase value="unclustered">
					<cfquery datasource="#this.dsn#" result="queryresult">
					 	DROP INDEX 		#arguments.schema.tablename#_#stDB.indexes[arguments.indexname].name# 
					</cfquery>
				</cfcase>
			</cfswitch>
			
			<cfset arrayappend(stResult.results,queryresult) />
			<cfif len(arguments.logLocation)>
				<cfset logQuery(arguments.logLocation,queryresult) />
			</cfif>
			
			<cfcatch type="database">
				<cfset stResult.bSuccess = false />
				<cfset arrayappend(stResult.results,cfcatch) />
			</cfcatch>
		</cftry>
		
		<cfif stResult.bSuccess>
			<cfset stResult.message = "Dropped '#arguments.schema.tablename#_#arguments.indexname#' index on #arguments.schema.tablename#" />
		<cfelse>
			<cfset stResult.message = "Failed to drop '#arguments.schema.tablename#_#arguments.indexname#' index on #arguments.schema.tablename#" />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<!--- DBINFO ABSTRACTION --->
	<cffunction name="getIndexes" returntype="query" access="private" output="false" hint="Returns the results of cfdbinfo, or an equivalent query (index_name,column_name[,ordinal_position])">
		<cfargument name="tablename" type="string" required="true" />
		
		<cfset var qIndexes = "" />
		
		<cfquery datasource="#this.dsn#" name="qIndexes">
			SELECT * FROM INFORMATION_SCHEMA.INDEXES WHERE Table_name='#arguments.tablename#' ORDER BY index_name, ordinal_position
		</cfquery>
		
		<cfloop query="qIndexes">
			<cfif refindnocase("^#arguments.tablename#_",qIndexes.index_name)>
				<cfset querysetcell(qIndexes,"index_name",mid(qIndexes.index_name,len(arguments.tablename)+2,len(qIndexes.index_name)),qIndexes.currentrow) />
			</cfif>
			<cfif refindnocase("^primary_key_\d+$",qIndexes.index_name)>
				<cfset querysetcell(qIndexes,"index_name","primary",qIndexes.currentrow) />
			</cfif>
		</cfloop>
		
		<cfreturn qIndexes />
	</cffunction>
	
	<cffunction name="getColumns" returntype="query" access="private" output="false" hint="Returns the results of cfdbinfo, or an equivalent query (column_name,is_nullable,column_default_value,type_name,char_octet_length,column_size,decimal_digits)">
		<cfargument name="tablename" type="string" required="true" />
		
		<cfset var qColumns = "" />
		
		<cfquery datasource="#this.dsn#" name="qColumns">
			SELECT 	column_name,is_nullable,column_default as column_default_value,type_name,numeric_precision as char_octet_length,numeric_precision as column_size,numeric_scale as decimal_digits
			FROM 	INFORMATION_SCHEMA.COLUMNS 
			WHERE	Table_name='#arguments.tablename#'
		</cfquery>
		
		<cfloop query="qColumns">
			<cfif refind("^'.*'$",qColumns.column_default_value)>
				<cfset querysetcell(qColumns,"column_default_value",mid(qColumns.column_default_value,2,len(qColumns.column_default_value)-2),qColumns.currentrow) />
			</cfif>
		</cfloop>
		
		<cfreturn qColumns />
	</cffunction>
	
	<!--- DATABASE INTROSPECTION --->
	<cffunction name="introspectTable" returntype="struct" access="private" output="false" hint="Constructs a metadata struct for the table">
		<cfargument name="tablename" type="string" required="True" hint="The table to introspect" />
		
		<cfset var stResult = structnew() />
		<cfset var qColumns = getColumns(arguments.tablename) />
		<cfset var stColumn = structnew() />
		<cfset var thisindex = "" />
		<cfset var thisfield = "" />
		<cfset var thispos = 0 />
		
		<cfset stResult.tablename = arguments.tablename />
		<cfset stResult.fields = structnew() />
		
		<!--- Loop thru columns --->
		<cfloop query="qColumns">
			<cfset stColumn = structnew() />
			<cfset stColumn.name = qColumns.column_name />
			<cfif qColumns.is_nullable>
				<cfset stColumn.nullable = true />
			<cfelse>
				<cfset stColumn.nullable = false />
			</cfif>
			<cfset stColumn.default = qColumns.column_default_value />
			<cfif stColumn.default eq "" and stColumn.nullable>
				<cfset stColumn.default = "NULL" />
			</cfif>
			<cfset stColumn.precision = "" />
			<cfset stColumn.type = qColumns.type_name />
			
			<cfswitch expression="#stColumn.type#">
				<cfcase value="clob" delimiters=",">
					<cfset stColumn.type = "longchar" />
					<cfset stColumn.precision = "" />
				</cfcase>
				<cfcase value="tinyint">
					<cfset stColumn.type = "numeric" />
					<cfset stColumn.precision = "1,0" />
				</cfcase>
				<cfcase value="varchar">
					<cfset stColumn.type = "string" />
					<cfset stColumn.precision = qColumns.char_octet_length />
				</cfcase>
				<cfcase value="decimal">
					<cfset stColumn.type = "numeric" />
					<cfset stColumn.precision = "#qColumns.column_size#,#qColumns.decimal_digits#">
				</cfcase>
				<cfcase value="int">
					<cfset stColumn.type = "numeric" />
					<cfset stColumn.precision = "#qColumns.column_size#,0" />
				</cfcase>
				<cfcase value="datetime,timestamp" delimiters=",">
					<cfset stColumn.type = "datetime" />
					<cfset stColumn.precision = "" />
					<cfif stColumn.default gt dateadd('yyyy',100,now()) and stColumn.nullable>
						<cfset stColumn.default = "NULL" />
					<cfelseif stColumn.default gt dateadd('yyyy',100,now())>
						<cfset stColumn.default = "" />
					</cfif>
				</cfcase>
			</cfswitch>
			
			<cfset stResult.fields[stColumn.name] = stColumn />
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
		<cfquery datasource="#this.dsn#" name="qTables">
			SELECT Table_Name as name FROM INFORMATION_SCHEMA.TABLES WHERE table_type = 'TABLE' and upper(Table_Name) like '#ucase(arguments.typename)#'
		</cfquery>
		<cfloop query="qTables">
			<cfset structappend(stResult,introspectTable(qTables[columnlist][currentrow]),true) />
		</cfloop>
		
		<!--- Get extended array tables --->
		<cfquery datasource="#this.dsn#" name="qTables">
			SELECT Table_Name as name FROM INFORMATION_SCHEMA.TABLES WHERE table_type = 'TABLE' and upper(Table_Name) like '#ucase(arguments.typename)#@_%' escape '@'
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
	
</cfcomponent>