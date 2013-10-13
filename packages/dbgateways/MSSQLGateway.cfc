<cfcomponent extends="BaseGateway" dbType="mssql:Microsoft SQL 2000 and before" usesDBOwner="true">
	
	<!--- UTILITY FUNCTIONS --->
	<cffunction name="logQuery" access="public" returntype="void" output="false" hint="Logs specified query result to the specified file">
		<cfargument name="logfile" type="string" required="true" hint="Log file" />
		<cfargument name="queryresult" type="struct" required="true" hint="Query result variable" />
		
		<cfset var sql = trim(rereplace(arguments.queryresult.sql,"\s+(?=([^']*'[^']*')*[^']*$)"," ","ALL")) & "; GO" & this.newline />
		<cfset var st = refind("\?(?=([^']*'[^']*')*[^']*$)",sql,1,true) />
		<cfset var paramindex = 1 />
		<cfset var sqlParam = "" />
		<cfset var comment = "#### #dateformat(now(),'yyyy-mm-dd')# #timeformat(now(),'hh:mm:ss')#" />
		
		<cfif structkeyexists(request,"id")>
			<cfset comment = comment & ", " & request.id />
		</cfif>
		
		<cfloop condition="arraylen(st.pos) and st.pos[1]">
			<cfset sqlParam = replace(arguments.queryresult.sqlParameters[paramindex],"'","''","ALL") />
			<cfset sql = left(sql,st.pos[1]-1) & "'#sqlParam#'" & mid(sql,st.pos[1]+st.len[1],len(sql)) />
			<cfset st = refind("\?(?=([^']*'[^']*')*[^']*$)",sql,st.pos[1]+len(sqlParam)+1,true) />
			<cfset paramindex = paramindex + 1 />
		</cfloop>
		
		<cffile action="append" file="#arguments.logfile#" output="#comment##this.newline##sql#" addnewline="true" mode="660" />
	</cffunction>
	
	
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
								bit
							<cfelse>
								decimal(#stProp.precision#)
							</cfif>
						</cfcase>
						<cfcase value="string">
							<cfif stProp.precision eq "MAX">
								nvarchar(4000)
							<cfelse>
								nvarchar(#stProp.precision#)
							</cfif>
						</cfcase>
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
						<cfelseif isNumeric(stVal.value)>
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
			<cfset stResult = dropSchema(schema=arguments.schema)>
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
					<cfcase value="string">
						<cfif stProp.precision eq "MAX">
							nvarchar(4000)
						<cfelse>
							nvarchar(#stProp.precision#)
						</cfif>
					</cfcase>
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
					<cfcase value="string">
						<cfif stProp.precision eq "MAX">
							nvarchar(4000)
						<cfelse>
							nvarchar(#stProp.precision#)
						</cfif>
					</cfcase>
					<cfcase value="longchar">ntext</cfcase>
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
	
	<cffunction name="dropColumn" access="public" output="false" returntype="struct" hint="Runs an ALTER sql command for the property. Not for use with array properties.">
		<cfargument name="schema" type="struct" required="true" hint="The type schema" />
		<cfargument name="propertyname" type="string" required="true" hint="The property to remove" />
		<cfargument name="logLocation" type="string" required="false" default="" />
		
		<cfset var stResult = structnew() />
		<cfset var queryresult = "" />
		<cfset var qCheck = "" />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.results = arraynew(1) />
		
		<cftry>
			<!--- check for constraint --->
			<cfquery datasource="#this.dsn#" name="qCheck">
				SELECT c_obj.name as CONSTRAINT_NAME, col.name	as COLUMN_NAME, com.text as DEFAULT_CLAUSE
				FROM	sysobjects	c_obj
				JOIN 	syscomments	com on 	c_obj.id = com.id
				JOIN 	sysobjects	t_obj on c_obj.parent_obj = t_obj.id
				JOIN    sysconstraints con on c_obj.id	= con.constid
				JOIN 	syscolumns	col on t_obj.id = col.id
							AND con.colid = col.colid
				WHERE c_obj.xtype	= 'D'
					AND t_obj.name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.schema.tablename#">
					AND (col.name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.propertyname#">)
			</cfquery>

			<cfif qCheck.recordcount GT 0>
				<cfquery datasource="#this.dsn#" result="queryresult">
					ALTER TABLE #this.dbowner##arguments.schema.tablename# DROP CONSTRAINT #qCheck.Constraint_Name#
				</cfquery>
				<cfset arrayappend(stResult.results,queryresult) />
				<cfif len(arguments.logLocation)>
					<cfset logQuery(arguments.logLocation,queryresult) />
				</cfif>
			</cfif>
			
			<cfquery datasource="#this.dsn#" result="queryresult">
				ALTER TABLE #this.dbowner##arguments.schema.tablename#
				DROP COLUMN	#arguments.propertyname#
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
			<cfset stResult.message = "Deployed '#arguments.schema.tablename#.#arguments.indexname#' index" />
		<cfelse>
			<cfset stResult.message = "Failed to deploy '#arguments.schema.tablename#.#arguments.indexname#' index" />
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
		<cfset var q = "" />
		<cfset var stIndex = structnew() />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.results = arraynew(1) />
		
		<cfif not structkeyexists(stDB.indexes,arguments.indexname)>
			<cfreturn stResult />
		</cfif>
		
		<cfset stIndex=stDB.indexes[arguments.indexname]>
		
		<cftry>
			<cfswitch expression="#stIndex.type#">
				<cfcase value="primary">
					<cfquery datasource="#this.dsn#" result="queryresult">
						ALTER TABLE #this.dbowner##arguments.schema.tablename#
					    DROP CONSTRAINT #stDB.indexes[arguments.indexname].name#
					</cfquery>
				</cfcase>
				<cfcase value="unclustered">
					<cfquery datasource="#this.dsn#" result="queryresult">
					 	DROP INDEX 		#stDB.indexes[arguments.indexname].name# 
					 	ON 				#this.dbowner##arguments.schema.tablename#
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
			<cfset stResult.message = "Dropped '#arguments.schema.tablename#.#arguments.indexname#' index" />
		<cfelse>
			<cfset stResult.message = "Failed to drop '#arguments.schema.tablename#.#arguments.indexname#' index" />
		</cfif>
		
		<cfreturn stResult />
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
		SELECT (		
			<cfloop index="j" from="1" to="#ArrayLen(arguments.aTableColMD)#">
				<cfif j NEQ 1>
					 +
				</cfif>
				
				<cfif FindNoCase("char", arguments.aTableColMD[j].TypeName)
			    OR FindNoCase("unique", arguments.aTableColMD[j].TypeName)
			    OR FindNoCase("xml", arguments.aTableColMD[j].TypeName)
			     >
					
					'|---|' + COALESCE(#arguments.aTableColMD[j].Name#,'') + '|---|'
					<!--- '|---|' + isNull(#arguments.aTableColMD[j].Name#,'') + '|---|' --->
				<cfelseif FindNoCase("text", arguments.aTableColMD[j].TypeName)>
						'|---|' + COALESCE( CONVERT( varchar(MAX) , #arguments.aTableColMD[j].Name#),'') + '|---|'
						<!--- '|---|' + isNull(CONVERT ( varchar(MAX) , #arguments.aTableColMD[j].Name#),'') + '|---|' --->
					<cfelseif FindNoCase("date", arguments.aTableColMD[j].TypeName)>
					'|---|' + COALESCE( CONVERT ( varchar , #arguments.aTableColMD[j].Name#, 21) ,'NULL') + '|---|'
					<!--- '|---|' + isNull(CONVERT ( varchar , #arguments.aTableColMD[j].Name#, 21),'NULL') + '|---|' --->
				<cfelse>
					<!--- <cfset temp = temp & qryTemp[#arguments.aTableColMD[j].Name#][i] > --->
					COALESCE( CONVERT( varchar, #arguments.aTableColMD[j].Name#),'|???|')
					<!--- isNull(CONVERT ( varchar , #arguments.aTableColMD[j].Name#),'|???|') --->
				</cfif>
				
				<cfif j NEQ ArrayLen(arguments.aTableColMD) >
					 + ','
				</cfif>
				
			</cfloop>
			) as insertValues
		FROM (
		    SELECT *, ROW_NUMBER() OVER (ORDER BY #arguments.orderBy# desc) AS RowNum
		    FROM #arguments.table#
		) AS MyDerivedTable
		WHERE MyDerivedTable.RowNum BETWEEN #arguments.from# AND #arguments.to#
		</cfoutput>
		
		</cfsavecontent>
				
		<cfreturn resultSQL>	
	</cffunction>
	
	<!--- DATABASE INTROSPECTION --->
	<cffunction name="introspectIndexes" returntype="struct" access="private" output="false" hint="Constructs metadata struct for table indexes">
		<cfargument name="tablename" type="string" required="True" hint="The table to introspect" />
		
		<cfset var stResult = structnew() />
		<cfset var qIndexes = "" />
		<cfset var thiskey = "" />
		<cfset var thisindex = "" />
		
		<!--- Get all indexes for table --->
		<cfstoredproc datasource="#this.dsn#" procedure="sp_helpindex">
			<cfprocparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.tablename#" />
			<cfprocresult name="qIndexes" />
		</cfstoredproc>
		
		<cfif isquery(qIndexes)>
			<cfloop query="qIndexes">
				<cfif refind("primary key",qIndexes.index_description) and qIndexes.index_name neq "primary">
					<cfset stResult["PRIMARY"] = structnew() />
					<cfset stResult["PRIMARY"].name = qIndexes.index_name />
					<cfset stResult["PRIMARY"].type = "primary" />
					<cfset stResult["PRIMARY"].fields = arraynew(1) />
					
					<cfloop list="#qIndexes.index_keys#" index="thiskey">
						<cfset arrayappend(stResult["PRIMARY"].fields,trim(thiskey)) />
					</cfloop>
				<cfelse>
					<cfset thisindex = replacenocase(qIndexes.index_name,"#arguments.tablename#_","") />
					<cfset stResult[thisindex] = structnew() />
					<cfset stResult[thisindex].name = qIndexes.index_name />
					<cfset stResult[thisindex].type = "unclustered" />
					<cfset stResult[thisindex].fields = arraynew(1) />
					
					<cfloop list="#qIndexes.index_keys#" index="thiskey">
						<cfset arrayappend(stResult[thisindex].fields,trim(thiskey)) />
					</cfloop>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
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
						<cfset stColumn.type = "longchar" />
					</cfcase>
					<cfcase value="bit">
						<cfset stColumn.type = "numeric" />
						<cfset stColumn.precision = "1,0" />
					</cfcase>
					<cfcase value="char,varchar,nchar,nvarchar" delimiters=",">
						<cfset stColumn.type = "string" />
						<cfset stColumn.precision = qColumns.character_maximum_length />
						<cfif stColumn.precision eq "4000">
							<cfset stColumn.precision = "MAX" />
						</cfif>
					</cfcase>
					<cfcase value="decimal,numeric,int,real,bigint" delimiters=",">
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
			<cfif isvalid("variableName","#thisfield#")>
				<cfparam name="stResult.fields.#thisfield#.index" default="" />
				<cfset stResult.fields[thisfield].index = listsort(listappend(stResult.fields[thisfield].index,"#thisindex#:#thispos#"),"textnocase","asc") />
			</cfif>
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
				select 	Table_name as name
				from 	Information_schema.Tables
				where 	Table_type = 'BASE TABLE' 
						and Objectproperty (Object_id(Table_name), 'IsMsShipped') = 0
						and table_name like <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.typename#" />
		</cfquery>
		<cfloop query="qTables">
			<cfset structappend(stResult,introspectTable(qTables[columnlist][currentrow]),true) />
		</cfloop>
		
		<!--- Get extended array tables --->
		<cfquery datasource="#this.dsn#" name="qTables">
			select 	Table_name as name
			from 	Information_schema.Tables
			where 	Table_type = 'BASE TABLE' 
					and Objectproperty (Object_id(Table_name), 'IsMsShipped') = 0
					and table_name like <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.typename)#[_]%" />
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
		
		<cfset var b = false />
		<cfset var e = "" />
		<cfset var a = "" />
		
		<!--- Nullable --->
		<cfset b = b or arguments.expected.nullable neq arguments.actual.nullable />
		
		<!--- Default --->
		<cfif arguments.expected.type eq "longchar">
			<!--- Ignore. Longchar can't have a default. --->
		<cfelseif arguments.expected.type eq "datetime">
			<!--- Handle weird null values --->
			<cfset e = getValueFromDB(schema=arguments.expected,value=arguments.expected.default) />
			<cfset a = getValueFromDB(schema=arguments.actual,value=arguments.actual.default) />
			<cfset b = b or e neq a />
		<cfelse>
			<cfset b = b or arguments.expected.default neq arguments.actual.default />
		</cfif>
		
		<!--- Type --->
		<cfset b = b or arguments.expected.type neq arguments.actual.type />
		
		<!--- Precision --->
		<cfset b = b or arguments.expected.precision neq arguments.actual.precision />
		
		<cfreturn b />
	</cffunction>

	<cffunction name="isDeployed" access="public" output="false" returntype="boolean" hint="Returns True if the table is already deployed">
		<cfargument name="schema" type="struct" required="true" hint="Table schema to check" />
		
		<cfset var q = "" />
		<cfset var dbo = "">
		<cfif len(this.dbowner)>
			<cfset dbo = left(this.dbowner, len(this.dbowner)-1)>
		</cfif>

		<cfquery datasource="#this.dsn#" name="q">
			SELECT * 
			FROM INFORMATION_SCHEMA.TABLES 
			WHERE 
				TABLE_NAME = '#arguments.schema.tablename#'
				<cfif len(dbo)>
					AND TABLE_SCHEMA = '#dbo#'
				</cfif>
		</cfquery>
		
		<cfreturn q.recordCount gt 0 />
	</cffunction>

</cfcomponent>