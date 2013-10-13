<cfcomponent extends="MSSQLGateway" dbType="mssql2005:Microsoft SQL 2005" usesDBOwner="true">
	
	
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
								bit
							<cfelse>
								decimal(#stProp.precision#)
							</cfif>
						</cfcase>
						<cfcase value="string">nvarchar(#stProp.precision#)</cfcase>
						<cfcase value="longchar">ntext</cfcase>
						<cfcase value="datetime">datetime</cfcase>
					</cfswitch>
					
					<cfif stProp.nullable>NULL<cfelse>NOT NULL</cfif>
					
					<cfif stProp.type neq "longchar" and (not stProp.type eq "numeric" or isnumeric(stProp.default))>
						<cfset stVal = getValueForDB(schema=stProp,value=stProp.default) />
						<cfif stVal.null>
							DEFAULT NULL
						<cfelseif stVal.cfsqltype eq "cf_sql_varchar">
							DEFAULT '#stVal.value#'
						<cfelseif stVal.cfsqltype eq "cf_sql_date">
							DEFAULT '#dateformat(stVal.value,"YYYY-MM-DD")#T#timeformat(stVal.value,"hh:mm:s")#'
						<cfelse>
							DEFAULT #stVal.value#
						</cfif>
					</cfif>
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
							bit
						<cfelse>
							decimal(#stProp.precision#)
						</cfif>
					</cfcase>
					<cfcase value="string">nvarchar(#stProp.precision#)</cfcase>
					<cfcase value="longchar">nvarchar(MAX)</cfcase>
					<cfcase value="datetime">datetime</cfcase>
				</cfswitch>
				<cfif stProp.nullable>NULL<cfelse>NOT NULL</cfif>
				
				<cfif stProp.type neq "longchar" and (not stProp.type eq "numeric" or isnumeric(stProp.default))>
					<cfset stVal = getValueForDB(schema=stProp,value=stProp.default) />
					<cfif stVal.null>
						DEFAULT NULL
					<cfelseif stVal.cfsqltype eq "cf_sql_varchar">
						DEFAULT '#stVal.value#'
					<cfelseif stVal.cfsqltype eq "cf_sql_date">
						DEFAULT '#dateformat(stVal.value,"YYYY-MM-DD")#T#timeformat(stVal.value,"hh:mm:s")#'
					<cfelseif isNumeric(stVal.value)>
						DEFAULT #stVal.value#
					</cfif>
				</cfif>
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
		<cfset var qDefault = "" />
		<cfset var stCurrentSchema = introspectTable(arguments.schema.tablename) />
		<cfset var thisindex = "" />
		<cfset var lIndexesToRestore = "" />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.results = arraynew(1) />
		
		<cftry>
			<!--- Remove any defaults on column (default constraints can effect the alterability of a column) --->
			<cfquery datasource="#this.dsn#" name="qDefault">
				select		d.name
				from		sys.columns c
							inner join
							sys.objects d
							on c.default_object_id=d.object_id
							inner join
							sys.objects t
							on c.object_id=t.object_id
				where		c.name=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.oldpropertyname#" />
							and t.name=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.schema.tablename#" />
			</cfquery>
			<cfif qDefault.recordcount>
				<cfquery datasource="#this.dsn#" result="queryresult">
					ALTER TABLE #this.dbowner##arguments.schema.tablename#
					DROP CONSTRAINT #qDefault.name#
				</cfquery>
				<cfset arrayappend(stResult.results,queryresult) />
				<cfif len(arguments.logLocation)>
					<cfset logQuery(arguments.logLocation,queryresult) />
				</cfif>
				
				<cfquery datasource="#this.dsn#" name="qDefault">
					select		d.name
					from		sys.objects d
					where		d.name=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qDefault.name#" />
				</cfquery>
				<cfif qDefault.recordcount>
					<cfquery datasource="#this.dsn#" result="queryresult">
						DROP DEFAULT #qDefault.name#
					</cfquery>
					<cfset arrayappend(stResult.results,queryresult) />
					<cfif len(arguments.logLocation)>
						<cfset logQuery(arguments.logLocation,queryresult) />
					</cfif>
				</cfif>
			</cfif>
			
			<!--- Remove any indexes on this column (indexes can effect the alterability of a column) --->
			<cfloop collection="#stCurrentSchema.indexes#" item="thisindex">
				<cfif refindnocase("(^|,)#arguments.oldpropertyname#($|,)",arraytolist(stCurrentSchema.indexes[thisindex].fields))>
					<cfset lIndexesToRestore = listappend(lIndexesToRestore,thisindex) />
					<cfset combineResults(stResult,dropIndex(schema=stCurrentSchema,indexname=thisindex,logLocation=arguments.logLocation)) />
				</cfif>
			</cfloop>
			
			<!--- Alter column --->
			<cfquery datasource="#this.dsn#" result="queryresult">
				ALTER TABLE #this.dbowner##arguments.schema.tablename#
				ALTER COLUMN #arguments.oldpropertyname#
				<cfswitch expression="#stProp.type#">
					<cfcase value="numeric">
						<cfif stProp.precision eq "1,0">
							bit
						<cfelse>
							decimal(#stProp.precision#)
						</cfif>
					</cfcase>
					<cfcase value="string">nvarchar(#stProp.precision#)</cfcase>
					<cfcase value="longchar">nvarchar(MAX)</cfcase>
					<cfcase value="datetime">datetime</cfcase>
				</cfswitch>
				<cfif stProp.nullable>NULL<cfelse>NOT NULL</cfif>
			</cfquery>
			
			<cfset arrayappend(stResult.results,queryresult) />
			<cfif len(arguments.logLocation)>
				<cfset logQuery(arguments.logLocation,queryresult) />
			</cfif>
			
			<!--- Rename column --->
			<cfif arguments.propertyname neq arguments.oldpropertyname>
				<cfquery datasource="#this.dsn#" result="queryresult">
					EXEC sp_rename '#arguments.schema.tablename#.#arguments.oldpropertyname#', '#arguments.propertyname#', 'COLUMN'
				</cfquery>
				<cfset arrayappend(stResult.results,queryresult) />
				<cfif len(arguments.logLocation)>
					<cfset logQuery(arguments.logLocation,queryresult) />
				</cfif>
			</cfif>
			
			<!--- Add new default --->
			<cfif stProp.type neq "longchar" and (not stProp.type eq "numeric" or isnumeric(stProp.default))>
				<cfset stVal = getValueForDB(schema=stProp,value=stProp.default) />
				<cfquery datasource="#this.dsn#" result="queryresult">
					ALTER TABLE #this.dbowner##arguments.schema.tablename#
						ADD CONSTRAINT def_#arguments.schema.tablename#_#arguments.propertyname#
						<cfif stVal.null>
							DEFAULT NULL
						<cfelseif stVal.cfsqltype eq "cf_sql_varchar">
							DEFAULT '#stVal.value#'
						<cfelseif stVal.cfsqltype eq "cf_sql_date">
							DEFAULT '#dateformat(stVal.value,"YYYY-MM-DD")#T#timeformat(stVal.value,"hh:mm:s")#'
						<cfelse>
							DEFAULT #stVal.value#
						</cfif>
						FOR #arguments.propertyname#
				</cfquery>
				<cfset arrayappend(stResult.results,queryresult) />
				<cfif len(arguments.logLocation)>
					<cfset logQuery(arguments.logLocation,queryresult) />
				</cfif>
			</cfif>
			
			<!--- Readd old indexes --->
			<cfloop list="#lIndexesToRestore#" index="thisindex">
				<cfset addIndex(schema=stCurrentSchema,indexname=thisindex,logLocation=arguments.logLocation) />
			</cfloop>
			
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
	
	
	<!--- DATABASE INTROSPECTION --->
	<cffunction name="introspectTable" returntype="struct" access="private" output="false" hint="Constructs a metadata struct for the table">
		<cfargument name="tablename" type="string" required="True" hint="The table to introspect" />
		
		<cfset var stResult = structnew() />
		<cfset var qTables = "" />
		<cfset var myTable = "" />
		<cfset var qColumns = "" />
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
		<cfquery name="qTables" datasource="#this.dsn#">
				select 	Table_name as name
				from 	Information_schema.Tables
				where 	Table_type = 'BASE TABLE' 
						and Objectproperty (Object_id(Table_name), 'IsMsShipped') = 0
						and table_name like <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.tablename#" />
		</cfquery>
		
		<cfloop query="qTables">
			<!--- Get tablename --->
			<cfset myTable = qTables[columnlist][currentrow]>
			
			<!--- Get column details of each table--->
			<cfquery name="qColumns" datasource="#this.dsn#">
				select 		*
				from		information_schema.columns
				where		table_name=<cfqueryparam cfsqltype="cf_sql_varchar" value="#mytable#">
			</cfquery>

			<!--- Loop thru columns --->
			<cfloop query="qColumns">
				<cfset stColumn = structnew() />
				<cfset stColumn.name = qColumns.column_name />
				<cfif qColumns.is_nullable eq "yes">
					<cfset stColumn.nullable = true />
				<cfelse>
					<cfset stColumn.nullable = false />
				</cfif>
				<cfif qColumns.column_default eq "(NULL)">
					<cfset stColumn.default = "NULL" />
				<cfelseif qColumns.column_default eq "('')" or qColumns.column_default eq "">
					<cfset stColumn.default = "" />
				<cfelseif refind("^\([\d\.]+\)$",qColumns.column_default)>
					<cfset stColumn.default = mid(qColumns.column_default,2,len(qColumns.column_default)-2) />
				<cfelse><!--- There is an actual default --->
					<cfset stColumn.default = mid(qColumns.column_default,3,len(qColumns.column_default)-4) />
				</cfif>
				<cfif stColumn.default eq "" and stColumn.nullable>
					<cfset stColumn.default = "NULL" />
				</cfif>
				<cfset stColumn.precision = "" />
				
				<cfswitch expression="#qColumns.data_type#">
					<cfcase value="longtext,text,ntext" delimiters=",">
						<cfset stColumn.type = "ntext" />
					</cfcase>
					<cfcase value="bit">
						<cfset stColumn.type = "numeric" />
						<cfset stColumn.precision = "1,0" />
					</cfcase>
					<cfcase value="char,varchar,nchar,nvarchar" delimiters=",">
						<cfset stColumn.type = "string" />
						<cfset stColumn.precision = qColumns.character_maximum_length />
						<cfif stColumn.precision eq "-1">
							<cfset stColumn.type = "longchar" />
							<cfset stColumn.precision = "" />
						</cfif>
					</cfcase>
					<cfcase value="decimal,numeric,int" delimiters=",">
						<cfset stColumn.type = "numeric" />
						<cfset stColumn.precision = "#qColumns.numeric_precision#,#qColumns.numeric_scale#" />
					</cfcase>
					<cfcase value="datetime,datetime2" delimiters=",">
						<cfset stColumn.type = "datetime" />
						<cfif stColumn.default gt dateadd('yyyy',100,now()) and stColumn.nullable>
							<cfset stColumn.default = "NULL" />
						<cfelseif stColumn.default gt dateadd('yyyy',100,now())>
							<cfset stColumn.default = "" />
						</cfif>
					</cfcase>
					<cfdefaultcase><cfthrow message="Could not find type for #stColumn.name# from #qColumns.data_type#"></cfdefaultcase>
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
	
</cfcomponent>