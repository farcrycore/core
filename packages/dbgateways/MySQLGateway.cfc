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
				<cfelseif isDate(arguments.value)>
					<cfset stResult.value = "#lsdateformat(arguments.value,'yyyy-mm-dd')# #timeformat(arguments.value,'HH:mm:ss.lll')#" />
				<cfelse>
					<cfset stResult.value = arguments.value />
				</cfif>
			</cfcase>
			<cfcase value="numeric,identity">
				<cfif listlast(arguments.schema.precision) eq 0 and listfirst(arguments.schema.precision) gt 10>
					<cfset stResult.cfsqltype = "cf_sql_bigint" />
				<cfelseif listlast(arguments.schema.precision) eq 0>
					<cfset stResult.cfsqltype = "cf_sql_integer" />
				<cfelse>
					<cfset stResult.cfsqltype = "cf_sql_decimal" />
					<cfset stResult.scale = listlast(arguments.schema.precision) />
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
			<cfcase value="json">
				<cfset stResult.cfsqltype = "cf_sql_varchar" />
				<cfif arguments.schema.nullable and (arguments.value eq "" or arguments.value eq "NULL")>
					<cfset stResult.value = "" />
					<cfset stResult.null = true />
				<cfelseif isJSON(arguments.value)>
					<cfset stResult.value = arguments.value />
					<cfset stResult.null = false />
				<cfelse>
					<cfset stResult.value = "{}" />
					<cfset stResult.null = false />
				</cfif>
			</cfcase>
		</cfswitch>
		
		<cfreturn stResult />
	</cffunction>

	<!--- DEPLOYMENT --->
	
	<cffunction name="getDeploySchemaSQL" access="public" output="false" returntype="string" hint="The returns the sql for Deployment of the table structure for a FarCry type into the database.">
		<cfargument name="schema" type="struct" required="true" />
		
		<cfset var resultSQL = "">
		<cfset var bAddedOne = false />
		<cfset var stVal = structNew()>
		<cfset var stProp = "">
		<cfset var thisfield = "">
		
		<cfprocessingdirective suppressWhitespace="true">
		<cfsavecontent variable="resultSQL">
			<cfoutput>CREATE TABLE #this.dbowner##arguments.schema.tablename#(#chr(13)##chr(10)#</cfoutput>
			
			<cfloop collection="#arguments.schema.fields#" item="thisfield">
				<cfif arguments.schema.fields[thisfield].type neq "array">
					<cfif bAddedOne><cfoutput>,#chr(13)##chr(10)#</cfoutput></cfif>
					<cfset bAddedOne = true />
					
					<cfset stProp = arguments.schema.fields[thisfield] />
					
					<cfoutput>#stProp.name# </cfoutput>
					<cfswitch expression="#stProp.type#">
						<cfcase value="identity">
							<cfoutput>int(11) </cfoutput>
						</cfcase>
						<cfcase value="json">
							<cfoutput>json </cfoutput>
						</cfcase>
						<cfcase value="numeric">
							<cfif stProp.precision eq "1,0">
								<cfoutput>tinyint(1) </cfoutput>
							<cfelse>
								<cfoutput>decimal(#stProp.precision#) </cfoutput>
							</cfif>
						</cfcase>
						<cfcase value="string">
							<cfif stProp.precision eq "MAX">
								<cfoutput>longtext </cfoutput>
							<cfelse>
								<cfoutput>varchar(#stProp.precision#) </cfoutput>
							</cfif>
						</cfcase>
						<cfcase value="longchar"><cfoutput>longtext </cfoutput></cfcase>
						<cfcase value="datetime">
							<cfif stProp.precision eq "">
								<cfoutput>datetime(3) </cfoutput>
							<cfelse>
								<cfoutput>datetime(#stProp.precision#) </cfoutput>
							</cfif>
						</cfcase>
					</cfswitch>
					
					<cfif stProp.nullable><cfoutput>NULL </cfoutput><cfelse><cfoutput>NOT NULL </cfoutput></cfif>
					
					<cfif NOT listFindNoCase("identity,longchar,json", stProp.type) and (not stProp.type eq "numeric" or isnumeric(stProp.default))>
						<cfset stVal = getValueForDB(schema=stProp,value=stProp.default) />
						<cfif stVal.null>
							<cfoutput>DEFAULT NULL </cfoutput>
						<cfelseif stVal.cfsqltype eq "cf_sql_varchar">
							<cfoutput>DEFAULT '#stVal.value#' </cfoutput>
						<cfelseif stVal.cfsqltype eq "cf_sql_timestamp">
							<cfoutput>DEFAULT '#dateformat(stVal.value,"YYYY-MM-DD")#T#timeformat(stVal.value,"HH:mm:s")#' </cfoutput>
						<cfelseif isNumeric(stVal.value)>
							<cfoutput>DEFAULT #stVal.value# </cfoutput>
						</cfif>
					</cfif>
					<cfif stProp.type eq "identity"><cfoutput>AUTO_INCREMENT </cfoutput></cfif>
				</cfif>
			</cfloop>
			
			<cfoutput>#chr(13)##chr(10)#);</cfoutput>
		</cfsavecontent>
		</cfprocessingdirective>
		
		<cfreturn resultSQL>
	</cffunction>
	
	<cffunction name="deploySchema" access="public" output="false" returntype="struct" hint="Deploys the table structure for a FarCry type into the database.">
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
					#preserveSingleQuotes(deploySchemaSQL)#
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
		<cfset var stVal = structNew()>
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.results = arraynew(1) />

		<cftry>
			<cfquery datasource="#this.dsn#" result="queryresult">
				ALTER TABLE #this.dbowner##arguments.schema.tablename#
				ADD #stProp.name# 
				<cfswitch expression="#stProp.type#">
					<cfcase value="identity">int(11)</cfcase>
					<cfcase value="json">json</cfcase>
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
					<cfcase value="datetime">
						<cfif stProp.precision eq "">
							datetime(3)
						<cfelse>
							datetime(#stProp.precision#)
						</cfif>
					</cfcase>
				</cfswitch>

				<cfif len(trim(stProp.generatedAlways))>
					GENERATED ALWAYS AS (#PreserveSingleQuotes(stProp.generatedAlways)#) #stProp.virtualType#
				</cfif>

				<cfif stProp.nullable>NULL<cfelse>NOT NULL</cfif>

				<cfif NOT listFindNoCase("identity,longchar,json", stProp.type) AND NOT len(trim(stProp.generatedAlways))>
					<cfset stVal = getValueForDB(schema=stProp,value=stProp.default) />
					DEFAULT <cfqueryparam attributeCollection="#stVal#" />
				</cfif>
				<cfif stProp.type eq "identity">AUTO_INCREMENT, ADD UNIQUE INDEX #stProp.name#_UNIQUE(#stProp.name#) USING BTREE</cfif>
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
		<cfset var stVal = structNew()>
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.results = arraynew(1) />
		
		<cftry>
			<cfquery datasource="#this.dsn#" result="queryresult">
				ALTER TABLE #this.dbowner##arguments.schema.tablename#
				CHANGE #arguments.oldpropertyname# #stProp.name# 
				<cfswitch expression="#stProp.type#">
					<cfcase value="identity">int(11)</cfcase>
					<cfcase value="json">json</cfcase>
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
					<cfcase value="datetime">
						<cfif stProp.precision eq "">
							datetime(3)
						<cfelse>
							datetime(#stProp.precision#)
						</cfif>
					</cfcase>				
				</cfswitch>

				<cfif len(trim(stProp.generatedAlways))>
					GENERATED ALWAYS AS (#PreserveSingleQuotes(stProp.generatedAlways)#) #stProp.virtualType#
				</cfif>

				<cfif stProp.nullable>NULL<cfelse>NOT NULL</cfif>

				<cfif NOT listFindNoCase("identity,longchar,json", stProp.type) AND NOT len(trim(stProp.generatedAlways))>
					<cfset stVal = getValueForDB(schema=stProp,value=stProp.default) />
					DEFAULT <cfqueryparam attributeCollection="#stVal#" />
				</cfif>

				<cfif stProp.type eq "identity">AUTO_INCREMENT, ADD UNIQUE INDEX #stProp.name#_UNIQUE(#stProp.name#) USING BTREE</cfif>
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
		<cfset var qSchema = "" />

		<cfquery datasource="#application.dsn#" name="qSchema">
			SELECT DATABASE() AS table_schema
		</cfquery>

		<cfquery name="qColumns" datasource="#this.dsn#">
			SELECT table_name
				, column_name
				, column_default AS column_default_value
				, data_type AS type_name
				, character_octet_length AS char_octet_length
				, character_maximum_length AS column_size
				, numeric_precision
				, numeric_scale AS decimal_digits
				, datetime_precision
				, is_nullable
				, generation_expression
				, extra
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qSchema.table_schema#">
				AND table_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.tablename#">
			ORDER BY table_name, ordinal_position
		</cfquery>

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
			    OR FindNoCase("object", arguments.aTableColMD[j].TypeName)
			     >
					'|---|' , COALESCE(#arguments.aTableColMD[j].Name#,'') , '|---|'
				<cfelseif FindNoCase("text", arguments.aTableColMD[j].TypeName)>
					'|---|' , COALESCE( CAST( #arguments.aTableColMD[j].Name# as CHAR),'') , '|---|'
				<cfelseif FindNoCase("date", arguments.aTableColMD[j].TypeName) OR FindNoCase("time", arguments.aTableColMD[j].TypeName)>
					'|---|' , COALESCE( DATE_FORMAT(#arguments.aTableColMD[j].Name#, '%Y-%m-%d %H:%i:%s') ,'NULL') , '|---|'
				<cfelse>
					COALESCE( CAST( #arguments.aTableColMD[j].Name# as CHAR),'=???=')
				</cfif>
				
				<cfif j NEQ ArrayLen(arguments.aTableColMD) >
					 , ','
				</cfif>
				
			</cfloop>
			) as insertValues
		FROM #arguments.table#
		ORDER BY #arguments.orderBy# desc
		LIMIT #arguments.from-1#, #arguments.to-arguments.from+1#
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
			<cfif len(qIndexes.index_name)>
				<cfif not structkeyexists(stResult,qIndexes.index_name)>
					<cfset stResult[qIndexes.index_name] = structnew() />
				</cfif>
				<cfset stResult[qIndexes.index_name].name = qIndexes.index_name />
				<cfif qIndexes.index_name eq "primary">
					<cfset stResult[qIndexes.index_name].type = "primary" />
				<cfelseif listLast(qIndexes.index_name, "_") eq "unique">
					<cfset stResult[qIndexes.index_name].type = "unique" />
				<cfelse>
					<cfset stResult[qIndexes.index_name].type = "unclustered" />
				</cfif>
				<cfif not structkeyexists(stResult[qIndexes.index_name],"fields")>
					<cfset stResult[qIndexes.index_name].fields = arraynew(1) />
				</cfif>
				<cfloop list="#qIndexes.column_name#" index="thiscolumn">
					<cfset arrayappend(stResult[qIndexes.index_name].fields,trim(thiscolumn)) />
				</cfloop>
			</cfif>
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
					<cfset stColumn.precision = qColumns.column_size />
				</cfcase>
				<cfcase value="decimal">
					<cfset stColumn.type = "numeric" />
					<cfset stColumn.precision = "#qColumns.numeric_precision#,#qColumns.decimal_digits#" />
				</cfcase>
				<cfcase value="int">
					<cfif isDefined("qColumns.extra") AND qColumns.extra eq "auto_increment">
						<cfset stColumn.type = "identity" />
						<cfset stColumn.precision = "11" />
						<cfset stColumn.nullable = false />
					<cfelse>
						<cfset stColumn.type = "numeric" />
						<cfset stColumn.precision = "#qColumns.numeric_precision#,0" />
					</cfif>
				</cfcase>
				<cfcase value="datetime">
					<cfset stColumn.type = "datetime" />
					<cfset stColumn.precision = "#qColumns.datetime_precision#" />
					<!--- For MariaDB 10.2+, strip out ' so date comparisons work --->
					<cfset stColumn.default = replace(stColumn.default, "'", "", "ALL") />
					<cfif stColumn.default gt dateadd('yyyy',100,now()) and stColumn.nullable>
						<cfset stColumn.default = "NULL" />
					<cfelseif stColumn.default gt dateadd('yyyy',100,now())>
						<cfset stColumn.default = "" />
					</cfif>
				</cfcase>
			</cfswitch>

			<!--- GENERATED COLUMN --->
			<cfset stColumn.generatedAlways = replaceNoCase(qColumns.generation_expression, "`", "","all") />
			<cfif len(stColumn.generatedAlways)>
				<cfset stColumn.virtualType = listFirst(qColumns.extra, " ") />
			<cfelse>
				<cfset stColumn.virtualType = "" />
			</cfif>



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
		<cfdbinfo datasource="#this.dsn#" type="tables" name="qAllTables" />

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
			<cfset stTemp.GENERATEDALWAYS = "" />
			<cfset stTemp.VIRTUALTYPE = "" />
			<cfset structappend(stTemp,introspectTable(qTables.table_name),true) />
			<cfset stResult.fields[listlast(qTables.table_name,"_")] = stTemp />
		</cfloop>
	
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="isFieldAltered" access="public" returntype="boolean" output="false" hint="Returns true if there is a difference">
		<cfargument name="expected" type="struct" required="true" hint="The expected schema" />
		<cfargument name="actual" type="struct" required="true" hint="The actual schema" />

		<!--- For MariaDB 10.2+, also compare default with 'default' --->

		<cfset var altered = arguments.expected.nullable neq arguments.actual.nullable
				  OR (arguments.expected.type neq "longchar" and arguments.expected.default neq arguments.actual.default and "'#arguments.expected.default#'" neq arguments.actual.default)
				  OR arguments.expected.type neq arguments.actual.type
				  OR arguments.expected.precision neq arguments.actual.precision
				  OR (arguments.expected.GENERATEDALWAYS?:'') neq (arguments.actual.GENERATEDALWAYS?:'')
				  OR (arguments.expected.VIRTUALTYPE?:'') neq (arguments.actual.VIRTUALTYPE?:'') />

		<cfreturn altered />
	</cffunction>

	
</cfcomponent>
