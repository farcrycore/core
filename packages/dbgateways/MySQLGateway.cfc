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
				<cfif listlast(arguments.schema.precision) eq 0 and listfirst(arguments.schema.precision) gt 10>
					<cfset stResult.cfsqltype = "cf_sql_bigint" />
				<cfelseif listlast(arguments.schema.precision) eq 0>
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
					<cfif stVal.null>
						DEFAULT NULL
					<cfelseif stVal.cfsqltype eq "cf_sql_varchar">
						<cfif stProp.type NEQ "longchar"><!--- Longchar cant have default --->
							DEFAULT '#stVal.value#'
						</cfif>
					<cfelseif stVal.cfsqltype eq "cf_sql_date">
						<cfif isDate(stVal.value)>
							DEFAULT '#dateformat(stVal.value,"YYYY-MM-DD")#T#timeformat(stVal.value,"hh:mm:s")#'
						</cfif>
					<cfelseif isNumeric(stVal.value)>
						DEFAULT #stVal.value#
					</cfif>
					<!--- <cfif stProp.type neq "longchar" and (not stProp.type eq "numeric" or isnumeric(stProp.default))>
						<cfqueryparam cfsqltype="#stVal.cfsqltype#" null="#stVal.null#" value="#stVal.value#" />
					</cfif> --->
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
				<cfif stProp.type neq "longchar">DEFAULT <cfqueryparam cfsqltype="#stVal.cfsqltype#" null="#stVal.null#" value="#stVal.value#" /></cfif>
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
			<cfquery datasource="#this.dsn#" result="queryresult">
				ALTER TABLE #this.dbowner##arguments.schema.tablename#
				CHANGE #arguments.oldpropertyname# #stProp.name# 
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
				<cfif stProp.type neq "longchar">DEFAULT <cfqueryparam cfsqltype="#stVal.cfsqltype#" null="#stVal.null#" value="#stVal.value#" /></cfif>
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
	
	<cffunction name="dropColumn" access="public" output="false" returntype="struct" hint="Runs an ALTER sql command for the property. Not for use with array properties.">
		<cfargument name="schema" type="struct" required="true" hint="The type schema" />
		<cfargument name="propertyname" type="string" required="true" hint="The property to remove" />
		<cfargument name="logLocation" type="string" required="false" default="" />
		
		<cfset var stResult = structnew() />
		<cfset var queryresult = "" />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.results = arraynew(1) />
		
		<cftry>
			<cfquery datasource="#this.dsn#" result="queryresult">
				ALTER TABLE #this.dbowner##arguments.schema.tablename#
				DROP		#arguments.propertyname#
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
			<cfset stResult.message = "Dropped '#arguments.schema.tablename#.#arguments.propertyname#' column" />
		<cfelse>
			<cfset stResult.message = "Failed to drop '#arguments.schema.tablename#.#arguments.propertyname#' column" />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<!--- DBINFO ABSTRACTION --->
	<cffunction name="getIndexes" returntype="query" access="private" output="false" hint="Returns the results of cfdbinfo, or an equivalent query (index_name,column_name[,ordinal_position])">
		<cfargument name="tablename" type="string" required="true" />
		
		<cfset var qIndexes = "" />
		
		<cfdbinfo datasource="#this.dsn#" type="index" table="#arguments.tablename#" name="qIndexes" />
		
		<cfreturn qIndexes />
	</cffunction>
	
	<cffunction name="getColumns" returntype="query" access="private" output="false" hint="Returns the results of cfdbinfo, or an equivalent query (column_name,is_nullable,column_default_value,type_name,char_octet_length,column_size,decimal_digits)">
		<cfargument name="tablename" type="string" required="true" />
		
		<cfset var qColumns = "" />
		
		<cfdbinfo datasource="#this.dsn#" type="columns" table="#arguments.tablename#" name="qColumns" />
		
		<cfreturn qColumns />
	</cffunction>
	
	<cffunction name="getInsertSQL" access="public" output="false" returntype="string" hint="Returns the SQL to insert data into the table specified and used by the Farcry Content Export">
		<cfargument name="table" type="string" required="true" />
		<cfargument name="aTableColMD" type="array" required="true" />
		<cfargument name="orderBy" type="string" required="true" />
		<cfargument name="from" type="numeric" default="1" />
		<cfargument name="to" type="numeric" default="0" />
		
		<cfset var resultSQL = "">
		<cfset var j = 0>
		
		<cfsavecontent variable="resultSQL">
		
		<cfoutput>
		SELECT concat(		
			<cfloop index="j" from="1" to="#ArrayLen(arguments.aTableColMD)#">
				<cfif j NEQ 1>
					 ,
				</cfif>
				
				<cfif FindNoCase("char", arguments.aTableColMD[j].TypeName)
			    OR FindNoCase("unique", arguments.aTableColMD[j].TypeName)
			    OR FindNoCase("xml", arguments.aTableColMD[j].TypeName)
			     >
					
					'|---|' , COALESCE(#arguments.aTableColMD[j].Name#,'') , '|---|'
					<!--- '|---|' + isNull(#arguments.aTableColMD[j].Name#,'') + '|---|' --->
				<cfelseif FindNoCase("text", arguments.aTableColMD[j].TypeName)>
						'|---|' , COALESCE( CAST( #arguments.aTableColMD[j].Name# as UNSIGNED),'') , '|---|'
						<!--- '|---|' + isNull(CONVERT ( varchar(MAX) , #arguments.aTableColMD[j].Name#),'') + '|---|' --->
				<cfelseif FindNoCase("date", arguments.aTableColMD[j].TypeName)>
					'|---|' , COALESCE( DATE_FORMAT(#arguments.aTableColMD[j].Name#, '%Y:%m:%d %H:%i:%s') ,'NULL') , '|---|'
					<!--- '|---|' + isNull(CONVERT ( varchar , #arguments.aTableColMD[j].Name#, 21),'NULL') + '|---|' --->
				<cfelse>
					<!--- <cfset temp = temp & qryTemp[#arguments.aTableColMD[j].Name#][i] > --->
					COALESCE( CAST( #arguments.aTableColMD[j].Name# as UNSIGNED),'|???|')
					<!--- isNull(CONVERT ( varchar , #arguments.aTableColMD[j].Name#),'|???|') --->
				</cfif>
				
				<cfif j NEQ ArrayLen(arguments.aTableColMD) >
					 , ','
				</cfif>
				
			</cfloop>
			) as insertValues
		FROM #arguments.table#
		ORDER BY #arguments.orderBy# desc
		LIMIT #arguments.from-1#, #arguments.to-arguments.from+1#
		<!--- FROM (
		    SELECT *, ROW_NUMBER() OVER (ORDER BY #sortProperty# desc) AS RowNum
		    FROM #arguments.table#
		) AS MyDerivedTable
		WHERE MyDerivedTable.RowNum BETWEEN #arguments.from# AND #arguments.to# --->
		</cfoutput>
		
		</cfsavecontent>
				
		<cfreturn resultSQL>	
	</cffunction>
	
	<!--- DATABASE INTROSPECTION --->
	<cffunction name="introspectIndexes" returntype="struct" access="private" output="false" hint="Constructs metadata struct for table indexes">
		<cfargument name="tablename" type="string" required="True" hint="The table to introspect" />
		
		<cfset var stResult = structnew() />
		<cfset var qIndexes = getIndexes(arguments.tablename) />
		<cfset var thiscolumn = "" />
		
		<cfif listfindnocase(qIndexes.columnlist,"ordinal_position")>
			<cfquery dbtype="query" name="qIndexes">
				select		*
				from		qIndexes
				order by	index_name, ordinal_position
			</cfquery>
		</cfif>
		
		<cfloop query="qIndexes">
			<cfparam name="stResult.#qIndexes.index_name#" default="#structnew()#" />
			<cfset stResult[qIndexes.index_name].name = qIndexes.index_name />
			<cfif qIndexes.index_name eq "primary">
				<cfset stResult[qIndexes.index_name].type = "primary" />
			<cfelse>
				<cfset stResult[qIndexes.index_name].type = "unclustered" />
			</cfif>
			<cfparam name="stResult.#qIndexes.index_name#.fields" default="#arraynew(1)#" />
			<cfloop list="#qIndexes.column_name#" index="thiscolumn">
				<cfset arrayappend(stResult[qIndexes.index_name].fields,trim(thiscolumn)) />
			</cfloop>
		</cfloop>
		
		<cfreturn stResult />
	</cffunction>
	
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
				<cfcase value="longtext">
					<cfset stColumn.type = "longchar" />
				</cfcase>
				<cfcase value="tinyint">
					<cfset stColumn.type = "numeric" />
					<cfset stColumn.precision = "1,0" />
				</cfcase>
				<cfcase value="bit">
					<cfset stColumn.type = "numeric" />
					<cfset stColumn.precision = "1,0" />
				</cfcase>
				<cfcase value="varchar">
					<cfset stColumn.type = "string" />
					<cfset stColumn.precision = qColumns.char_octet_length />
				</cfcase>
				<cfcase value="decimal">
					<cfset stColumn.type = "numeric" />
					<cfset stColumn.precision = "#qColumns.column_size#,#qColumns.decimal_digits#" />
				</cfcase>
				<cfcase value="int">
					<cfset stColumn.type = "numeric" />
					<cfset stColumn.precision = "#qColumns.column_size#,0" />
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
		<cfset var qAllTables = "" />
		<cfset var qTables = "" />
		
		<!--- Get basic table columns--->
		<cfdbinfo datasource="#application.dsn#" type="tables" name="qAllTables" />
		
		<cfquery dbtype="query" name="qTables">
			select * from qAllTables where upper(table_name) like '#ucase(arguments.typename)#'
		</cfquery>
		<cfloop query="qTables">
			<cfset structappend(stResult,introspectTable(qTables.table_name),true) />
		</cfloop>
		
		<!--- Get extended array tables --->
		<cfquery dbtype="query" name="qTables">
			select * from qAllTables where upper(table_name) like '#ucase(arguments.typename)#@_%' escape '@'
		</cfquery>
		
		<cfloop query="qTables">
			<cfset stTemp = structnew() />
			<cfset stTemp.name = listlast(qTables.table_name,"_") />
			<cfset stTemp.type = "array" />
			<cfset stTemp.default = "NULL" />
			<cfset stTemp.nullable = true />
			<cfset structappend(stTemp,introspectTable(qTables.table_name),true) />
			<cfset stResult.fields[listlast(qTables.table_name,"_")] = stTemp />
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