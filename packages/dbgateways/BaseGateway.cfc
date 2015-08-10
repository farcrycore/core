<cfcomponent name="DBGateway" output="false" hint="This component provides generic database access for the fourq persistence layer of FarCry">


	<cffunction name="init" access="public" returntype="any" output="false" hint="Initializes the instance data">
		<cfargument name="dsn" type="string" required="true" />
		<cfargument name="dbowner" type="string" required="true" />
		<cfargument name="dbtype" type="string" required="true" />
		
		<cfset this.dbowner = arguments.dbowner />
		<cfset this.dsn = arguments.dsn />
		<cfset this.dbtype = arguments.dbtype />
		<cfset this.newline = "
" />
		
		<cfreturn this />
	</cffunction>

	<cffunction name="getProperties" access="public" returntype="struct" output="false" hint="Returns information about this gateway">

		<cfreturn {
			"dbowner" = this.dbowner,
			"dsn" = this.dsn,
			"dbtype" = this.dbtype,
			"dbtype_label" = listlast(getMetadata(this).dbType,":")
		} />
	</cffunction>
	
	<!--- UTILITY FUNCTIONS --->
	<cffunction name="combineResults" access="public" returntype="struct" output="false" hint="Merges two standard stResult struts (bSuccess,results)">
		<cfargument name="firstResult" type="struct" required="true" />
		<cfargument name="secondResult" type="struct" required="true" />
		
		<cfset var i = 0 />
		
		<cfparam name="arguments.firstResult.bSuccess" default="true" />
		<cfparam name="arguments.firstResult.results" default="#arraynew(1)#" />
		<cfparam name="arguments.secondResult.bSuccess" default="true" />
		<cfparam name="arguments.secondResult.results" default="#arraynew(1)#" />
		
		<cfset arguments.firstResult.bSuccess = arguments.firstResult.bSuccess and arguments.secondResult.bSuccess />
		<cfloop from="1" to="#arraylen(arguments.secondResult.results)#" index="i">
			<cfset arrayappend(arguments.firstResult.results,arguments.secondResult.results[i]) />
		</cfloop>
		<cfloop collection="#arguments.secondResult#" item="i">
			<cfif not listcontainsnocase("bSuccess,results",i)>
				<cfset arguments.firstResult[i] = arguments.secondResult[i] />
			</cfif>
		</cfloop>
		
		<cfreturn arguments.firstResult />
	</cffunction>
	
	<cffunction name="logQuery" access="public" returntype="void" output="false" hint="Logs specified query result to the specified file">
		<cfargument name="logfile" type="string" required="true" hint="Log file" />
		<cfargument name="queryresult" type="struct" required="true" hint="Query result variable" />
		
		<cfset var sql = trim(rereplace(arguments.queryresult.sql,"\s+(?=([^']*'[^']*')*[^']*$)"," ","ALL")) & ";" & this.newline />
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
	
	
	<!--- INTERNAL DB FUNCTIONS --->
	<cffunction name="setArrayTypenames" access="public" returntype="struct" output="false" hint="Updates the typenames of a standard array property">
		<cfargument name="tablename" type="struct" required="true" hint="The table of the array property" />
    	<cfargument name="parentid" type="uuid" required="true" hint="The parentid of the array property" />
		<cfargument name="logLocation" type="string" required="false" default="" />
		
		<cfset var queryresult = "" />
		<cfset var stResult = structnew() />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.results = arraynew(1) />
		
		<cftry>
			<!--- anything else / needs to be checked as this does not work for all databases--->
			<cfquery datasource="#this.dsn#" result="queryresult">
				UPDATE 	#this.dbowner##arguments.tablename#
				SET 	#this.dbowner##arguments.tablename#.typename = refObjects.typename		
				FROM 	#this.dbowner##arguments.tablename# INNER JOIN refObjects
						ON #this.dbowner##arguments.tablename#.data=refObjects.objectid	
				WHERE 	parentID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.parentid#" />
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
		
		<cfreturn stResult />
	</cffunction>
	
  	<cffunction name="setArrayData" access="public" returntype="struct" output="false" >
	  	<cfargument name="schema" type="struct" required="true" hint="Type metadata" />
    	<cfargument name="aProperties" type="array" required="true" />
		<cfargument name="parentid" type="uuid" required="true" hint="The parentid of the array property" />
		<cfargument name="logLocation" type="string" required="false" default="" />
		
		<cfset var stResult = structnew() />
		<cfset var qExisting = "" />
		<cfset var i = 0 />
		<cfset var bExtended = not (lcase(listsort(structkeylist(arguments.schema.fields),"text")) eq "data,seq,parentid,typename") />
		<cfset var stData = structnew() />
		<cfset var value1 = "" />
		<cfset var value2 = "" />
		<cfset var sendback = "" />
		<cfset var result = "" />
		<cfset var aData = duplicate(arguments.aProperties) />
	  	
	  	<cfimport taglib="/farcry/core/tags/misc" prefix="misc" />
	  	
	  	<cfset stResult.bSuccess = true />
	  	<cfset stResult.results = arraynew(1) />
	  	
	  	<!--- Convert array to array of structs and normalise seq --->
	  	<cfloop from="1" to="#arraylen(aData)#" index="i">
			<cfif isstruct(aData[i])>
				<cfif not structkeyexists(aData[i],"parentid")>
					<cfset aData[i].parentid = arguments.parentid />
				</cfif>
				<cfif not structkeyexists(aData[i],"seq")>
					<cfset aData[i].seq = i />
				</cfif>
			<cfelse>
				<cfset stData = structnew() />
				<cfif refind("\:\d+",aData[i])>
					<cfset stData.parentid = arguments.parentid />
					<cfset stData.seq = listlast(aData[i],":") />
					<cfset stData.data = listfirst(aData[i],":") />
					<cfset stData.typename = application.fapi.findType(objectid = stData.data) />
				<cfelse>
					<cfset stData.parentid = arguments.parentid />
					<cfset stData.seq = i />
					<cfset stData.data = aData[i] />
					<cfset stData.typename = application.fapi.findType(objectid = stData.data) />
				</cfif>
				
				<cfset aData[i] = stData />
			</cfif>
		</cfloop>
		<misc:sort values="#aData#" result="aData"><cfset sendback = value1.seq - value2.seq /></misc:sort>
	  	<cfloop from="1" to="#arraylen(aData)#" index="i">
	  		<cfset aData[i].seq = i />
	  	</cfloop>
	  	
	  	<!--- Find existing array values --->
	  	<cfquery datasource="#this.dsn#" name="qExisting">
			select		#structkeylist(arguments.schema.fields)#
			from		#this.dbowner##arguments.schema.tablename#
			where		parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.parentid#" />
			order by	seq
		</cfquery>
	  	
	  	<!--- Update DB --->
	  	<cfloop from="1" to="#max(arraylen(aData),qExisting.recordcount)#" index="i">
		  	
			<cfif i gt arraylen(aData)>
				<!--- Delete item from DB --->
				<cfif listfindnocase(qExisting.columnlist,"objectid")>
					<cfset combineResults(stResult,deleteData(schema=arguments.schema,objectid=qExisting.objectid[i],logLocation=arguments.logLocation)) />
				<cfelse>
					<cfset combineResults(stResult,deleteData(schema=arguments.schema,parentid=arguments.parentid,seq=qExisting.seq[i],logLocation=arguments.logLocation)) />
				</cfif>
			<cfelseif aData[i].seq gt qExisting.recordcount>
				<!--- Add item to DB --->
				<cfset combineResults(stResult,createData(schema=arguments.schema,stProperties=aData[i],logLocation=arguments.logLocation)) />
			<cfelseif bExtended or aData[i].data neq qExisting.data[i]>

				<cfif qExisting.seq[i] neq i><!--- Too complicated - just delete the bugger and add the new one --->
					<!--- Delete item from DB --->
				    <cfif structKeyExists(arguments.schema.fields,"objectid")>
					    <!--- extended arrays use "objectid" as the primary key --->
					    <cfset combineResults(stResult,deleteData(schema=arguments.schema,objectid=qExisting.objectid[i],seq=qExisting.seq[i],logLocation=arguments.logLocation)) />
					<cfelse>
						<cfset combineResults(stResult,deleteData(schema=arguments.schema,parentid=arguments.parentid,seq=qExisting.seq[i],logLocation=arguments.logLocation)) />
				    </cfif>
					<cfset combineResults(stResult,createData(schema=arguments.schema,stProperties=aData[i],logLocation=arguments.logLocation)) />
				<cfelse>
					<cfset combineResults(stResult,setData(schema=arguments.schema,stProperties=aData[i],logLocation=arguments.logLocation)) />
				</cfif>
			</cfif>
			
		</cfloop>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="getValueFromDB" access="public" output="false" returntype="any" hint="Returns the FarCry value for the specified property metadata and value">
		<cfargument name="schema" type="struct" required="true" />
		<cfargument name="value" type="any" required="true" />
		
		<cfswitch expression="#arguments.schema.type#">
			<cfcase value="datetime">
				<cfif arguments.value eq "" or not isdate(arguments.value) or arguments.value gt dateadd('yyyy',150,now()) or (year(arguments.value) eq 1970 and month(arguments.value) eq 1 and day(arguments.value) eq 1)>
					<cfreturn "" />
				<cfelse>
					<cfreturn arguments.value />
				</cfif>
			</cfcase>
			<cfdefaultcase>
				<cfreturn arguments.value />
			</cfdefaultcase>
		</cfswitch>
	</cffunction>	
	
	<!--- DATA ACCESS --->
	<cffunction name="createData" access="public" returntype="struct" output="false" hint="Creates a new row in the db for the given properties">
		<cfargument name="schema" type="struct" required="true" hint="Type metadata" />
    	<cfargument name="stProperties" type="struct" required="true" />
		<!--- Additional optional arguments for each primary key field --->
		<cfargument name="logLocation" type="string" required="false" default="" />
		
		<cfset var stResult = structnew() />
		<cfset var queryresult = "" />
		<cfset var bFirst = false />
 		
		<!--- AJM --->
		<cfset var thisfield   = "" >
		<cfset var stVal       = "" >
		<cfset var qCreateData = "">
		
		<!--- set defaults for status --->
		<cfset stResult.bSuccess = true />
		<cfset stResult.message = "Object created successfully" />
		<cfset stResult.results = arraynew(1) />
		
		<!--- Check that the primary key/s have been passed as arguments or in stProperties --->
		<cfloop list="#arraytolist(arguments.schema.indexes.primary.fields)#" index="thisfield">
			<cfif structkeyexists(arguments,thisfield)>
				<cfset arguments.stProperties[thisfield] = arguments[thisfield] />
			<cfelseif not structkeyexists(arguments.stProperties,thisfield) and thisfield eq "objectid">
				<cfset arguments.stProperties[thisfield] = createuuid()>
			<cfelseif not structkeyexists(arguments.stProperties,thisfield)>
				<cfthrow message="[#thisfield#] is part of this table's primary key and must be included in stProperties" />
			</cfif>
		</cfloop>
		
		<cftry>
			<!--- build query --->
			<cfquery datasource="#this.dsn#" name="qCreateData" result="queryresult">
				INSERT INTO #this.dbowner##arguments.schema.tablename# (
					<cfset bFirst = true />
					<cfloop collection="#arguments.stProperties#" item="thisfield">
						<cfif structkeyexists(arguments.schema.fields,thisfield) and not arguments.schema.fields[thisfield].type eq "array" and arguments.schema.fields[thisfield].savable>
							<cfif NOT bFirst>,</cfif><cfset bFirst = false />
							#thisfield#
						</cfif>
					</cfloop>
				)
				VALUES (
					<cfset bFirst = true />
					<cfloop collection="#arguments.stProperties#" item="thisfield">
						<cfif structkeyexists(arguments.schema.fields,thisfield) and structkeyexists(arguments.stProperties,thisfield) and not arguments.schema.fields[thisfield].type eq "array" and arguments.schema.fields[thisfield].savable>
							<cfif NOT bFirst>,</cfif><cfset bFirst = false />
							
							<cfset stVal = getValueForDB(schema=arguments.schema.fields[thisfield],value=arguments.stProperties[thisfield]) />
							<cfqueryparam cfsqltype="#stVal.cfsqltype#" null="#stVal.null#" value="#stVal.value#" />
						</cfif>
					</cfloop>
				)			
			</cfquery>
				
			<cfset arrayappend(stResult.results,queryresult) />
			<cfif len(arguments.logLocation)>
				<cfset logQuery(arguments.logLocation,queryresult) />
			</cfif>
			
			<cfcatch type="database">
				<cfset stResult.bSuccess = false />
				<cfset stResult.message = cfcatch.message />
				<cfset arrayappend(stResult.results,cfcatch) />
			</cfcatch>
		</cftry>
		
		<!--- Insert any array property data - only applicable for standard types i.e. has an objectid primarykey --->		
		<cfloop collection="#arguments.schema.fields#" item="thisfield">
			<cfif structkeyexists(arguments.schema.fields,thisfield) and  structkeyexists(arguments.stProperties,thisfield) and arguments.schema.fields[thisfield].type eq 'array' AND structKeyExists(arguments.stProperties,thisfield) and arguments.schema.fields[thisfield].savable>
				<cfset combineResults(stResult,setArrayData(schema=arguments.schema.fields[thisfield],aProperties=arguments.stProperties[thisfield],parentid=arguments.stProperties.objectid,logLocation=arguments.logLocation)) />
			</cfif>
		</cfloop>
		
		<cfif structkeyexists(arguments.stProperties,"objectid")>
			<cfset stResult.objectid = arguments.stProperties.objectid />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="setData" access="public" returntype="struct" output="false" hint="Performs an UPDATE for the given schema and properties">
	  	<cfargument name="schema" type="struct" required="true" hint="Type metadata" />
    	<cfargument name="stProperties" type="struct" required="true" />
		<cfargument name="logLocation" type="string" required="false" default="" />
	  	
   		<cfset var thisfield = "" />
   		<cfset var qRecordExists = queryNew("blah") />
		<cfset var stResult = structnew() />
   		<cfset var qSetData = queryNew("blah") />
		<cfset var queryresult = "" />
		<cfset var bFirst = true />
		<cfset var stVal = structnew() />

		<cfset stResult.bSuccess = true />
		<cfset stResult.message = "" />
		<cfset stResult.results = arraynew(1) />
		<cfset stResult.stProperties = arguments.stProperties />
		
		<!--- Check that the primary key/s have been passed as arguments --->
		<cfloop list="#arraytolist(arguments.schema.indexes.primary.fields)#" index="thisfield">
			<cfif not structkeyexists(arguments.stProperties,thisfield)>
				<cfthrow message="[#thisfield#] is part of this table's primary key and must be included in stProperties" />
			</cfif>
		</cfloop>
		
		<!--- Check to see if the objectID already exists in the database --->
		<cfquery datasource="#this.dsn#" name="qRecordExists">
			SELECT 	#arraytolist(arguments.schema.indexes.primary.fields)# 
			FROM 	#this.dbowner##arguments.schema.tablename#
			WHERE 	<cfset bFirst = true />
					<cfloop list="#arraytolist(arguments.schema.indexes.primary.fields)#" index="thisfield">
						<cfif NOT bFirst>AND</cfif><cfset bFirst = false />
						
						<cfset stVal = getValueForDB(schema=arguments.schema.fields[thisfield],value=arguments.stProperties[thisfield]) />
						#thisfield#=<cfqueryparam cfsqltype="#stVal.cfsqltype#" null="#stVal.null#" value="#stVal.value#" />
					</cfloop>
		</cfquery>
		
		<cfif qRecordExists.RecordCount EQ 0>
		
			<cfset stResult.bSuccess = false />
			<cfset stResult.message = "Object does not exist" />
			
		<cfelse>
			
			<cftry>
				<!--- build query --->
				<cfset bFirst = true />
				<cfquery datasource="#this.dsn#" name="qSetData" result="queryresult">
					UPDATE	#this.dbowner##arguments.schema.tablename#
					SET		<cfloop collection="#arguments.stProperties#" item="thisfield">
								<cfif structkeyexists(arguments.schema.fields,thisfield) and not arguments.schema.fields[thisfield].type eq "array" and not listcontains(arraytolist(arguments.schema.indexes.primary.fields),thisfield) and arguments.schema.fields[thisfield].savable>
									<cfif NOT bFirst>,</cfif><cfset bFirst = false />
									
									<cfset stVal = getValueForDB(schema=arguments.schema.fields[thisfield],value=arguments.stProperties[thisfield]) />
									#thisfield#=<cfqueryparam cfsqltype="#stVal.cfsqltype#" null="#stVal.null#" value="#stVal.value#" />
								</cfif>
							</cfloop>
					WHERE	<cfset bFirst = true />
							<cfloop list="#arraytolist(arguments.schema.indexes.primary.fields)#" index="thisfield">
								<cfif NOT bFirst>AND</cfif><cfset bFirst = false />
								
								<cfset stVal = getValueForDB(schema=arguments.schema.fields[thisfield],value=arguments.stProperties[thisfield]) />
								#thisfield#=<cfqueryparam cfsqltype="#stVal.cfsqltype#" null="#stVal.null#" value="#stVal.value#" />
							</cfloop>
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
			
			<!--- Insert any array property data - only applicable for standard types i.e. has an objectid primarykey --->		
			<cfloop collection="#arguments.schema.fields#" item="thisfield">
				<cfif arguments.schema.fields[thisfield].type eq 'array' AND structKeyExists(arguments.stProperties,thisfield) and arguments.schema.fields[thisfield].savable>
					<cfset combineResults(stResult,setArrayData(schema=arguments.schema.fields[thisfield],aProperties=arguments.stProperties[thisfield],parentid=arguments.stProperties.objectid,logLocation=arguments.logLocation)) />
				</cfif>
			</cfloop>
			
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="getData" access="public" output="true" returntype="struct" hint="Get data for a specific objectid and return as a structure, including array properties and typename.">
		<cfargument name="schema" type="struct" required="true" hint="The type metadata" />
		<cfargument name="bDepth" type="numeric" required="false" default="1" hint="0:Everything (with full structs for all array field elements),1:Everything (only extended array field as structs),2:No array fields,3:No array or longchar fields" />
		<cfargument name="fields" type="string" required="false" default="" hint="Overrides the default fields returned. NOTE: the bDepth field may restrict the list further." />
		<!--- Additional required arguments for each primary key field --->
		
		<cfset var thisfield = "" />
		<cfset var sqlSelect = "" />
		<cfset var qGetData = "" />
		<cfset var stObj = structnew() />
		<cfset var key = "" />
		<cfset var qArrayData = "" />
		<cfset var i = 0 />
		<cfset var thiscol = "" />
		<cfset var thisext = structnew() />
		<cfset var bFirst = false />
		<cfset var errordetail = "" />
		
		<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
		
		<!--- Check that the primary key/s have been passed as arguments --->
		<cfloop list="#arraytolist(arguments.schema.indexes.primary.fields)#" index="thisfield">
			<cfif not structkeyexists(arguments,thisfield)>
				<cfthrow message="[#thisfield#] is part of this table's primary key and is required" />
			</cfif>
		</cfloop>
		
		<!--- Determine which fields should be returned --->
		<cfif not len(arguments.fields)>
			<cfset sqlSelect = "" />
			<cfloop collection="#arguments.schema.fields#" item="thisfield">
				<cfif arguments.schema.fields[thisfield].type eq "array" and arguments.bDepth lt 2>
					<cfset sqlSelect = listappend(sqlSelect,thisfield) />
				<cfelseif arguments.schema.fields[thisfield].type eq "longchar" and arguments.bDepth lt 3>
					<cfset sqlSelect = listappend(sqlSelect,thisfield) />
				<cfelseif arguments.schema.fields[thisfield].type neq "array" and arguments.schema.fields[thisfield].type neq "longchar">
					<cfset sqlSelect = listappend(sqlSelect,thisfield) />
				</cfif>
			</cfloop>
			<cfset arguments.fields = sqlSelect />
		</cfif>
		
		<!--- Filter basic select --->
		<cfset sqlSelect = "" />
		<cfloop list="#arguments.fields#" index="thisfield">
			<cfif arguments.schema.fields[thisfield].type eq "array">
				<!--- Don't add that to the basic select --->
			<cfelse>
				<cfset sqlSelect = listappend(sqlSelect,thisfield) />
			</cfif>
		</cfloop>
		
		<cftry>
			<cfquery datasource="#this.dsn#" name="qGetData">
				SELECT 	#sqlSelect# 
				FROM 	#this.dbowner##arguments.schema.tablename#
				WHERE 	<cfset bFirst = true />
						<cfloop list="#arraytolist(arguments.schema.indexes.primary.fields)#" index="thisfield">
							<cfif NOT bFirst>AND</cfif><cfset bFirst = false />
							
							<cfif arguments.schema.fields[thisfield].type eq "numeric">
								#thisfield# = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments[thisfield]#" />
							<cfelse><!--- String --->
								#thisfield# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments[thisfield]#" />
							</cfif>
						</cfloop>
			</cfquery>
			
		 	<cfcatch type="database">
				<cfif isDefined("cfcatch.detail")>
					<cfset errordetail = cfcatch.detail>
				<cfelseif isDefined("cfcatch.message")>
					<cfset errordetail = cfcatch.message>
				<cfelse>
					<cfset errordetail = "unknown database error">
				</cfif>
				<!--- Looks like a property has not yet been deployed. If so, simply try a select * --->
				<cflog file="fourq" text="Error running getdata() for #arguments.objectID# (#arguments.schema.tablename#): #errordetail#"  />
				<cfquery datasource="#this.dsn#" name="qGetData">
					SELECT 	*
					FROM 	#this.dbowner##arguments.schema.tablename#
					WHERE 	<cfset bFirst = true />
							<cfloop list="#arraytolist(arguments.schema.indexes.primary.fields)#" index="thisfield">
								<cfif NOT bFirst>AND</cfif><cfset bFirst = false />
								
								<cfif arguments.schema.fields[thisfield].type eq "numeric">
									#thisfield# = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments[thisfield]#" />
								<cfelse><!--- String --->
									#thisfield# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments[thisfield]#" />
								</cfif>
							</cfloop>
				</cfquery>
			</cfcatch>
		</cftry>
		
		<cfif qGetData.recordCount>
			<!--- convert query to structure --->
			<cfloop list="#qGetData.columnlist#" index="key">
				<cfif structKeyExists(arguments.schema.fields, key)>
					<cfset stObj[key] = getValueFromDB(schema=arguments.schema.fields[key],value=qGetData[key][1]) />
				</cfif>
			</cfloop>
			
			<cfset stObj.typename = arguments.schema.tablename />
		
			<!--- determine array properties --->
			<cfloop collection="#arguments.schema.fields#" item="thisfield">
				<cfif arguments.schema.fields[thisfield].type eq "array">
					
					<cfset stObj[thisfield] = arraynew(1) />
					
					<cfif (listsort(structkeylist(arguments.schema.fields[thisfield].fields),"textnocase") eq "data,parentid,seq,typename" and arguments.bDepth eq 0)
					   OR (listsort(structkeylist(arguments.schema.fields[thisfield].fields),"textnocase") neq "data,parentid,seq,typename")>
						<!--- Return this array as an array of structs --->
						
						<!--- getdata for array properties --->
						<cfquery datasource="#this.dsn#" name="qArrayData">
				  			select 		#structkeylist(arguments.schema.fields[thisfield].fields)# 
				  			from 		#this.dbowner##arguments.schema.fields[thisfield].tablename#
							where 		parentID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectID#" />
							order by 	seq
						</cfquery>
						
						<cfloop query="qArrayData">
							<cfset thisext = structnew() />
							<cfloop list="#qArrayData.columnlist#" index="thiscol">
								<cfset thisext[thiscol] = getValueFromDB(schema=arguments.schema.fields[thisfield].fields[thiscol],value=qArrayData[thiscol]) />
							</cfloop>
							<cfset arrayappend(stObj[thisfield],thisext) />
						</cfloop>
						
					<cfelse><!--- Return this array as an array of objectids --->
						
						<!--- getdata for array properties --->
						<cfquery datasource="#this.dsn#" name="qArrayData">
				  			select 		data 
				  			from 		#this.dbowner##arguments.schema.fields[thisfield].tablename#
							where 		parentID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectID#" />
							order by 	seq
						</cfquery>
						
						<cfloop query="qArrayData">
							<cfset arrayappend(stObj[thisfield],getValueFromDB(schema=arguments.schema.fields[thisfield].fields["data"],value=qArrayData["data"])) />
						</cfloop>
						
					</cfif>
					
				</cfif>
			</cfloop>
			
		<cfelse>
			
			<!--- return an empty structure - indicating that record does not actually exist --->
			<cfset stObj = structNew()>
		
		</cfif>
		
		<cfreturn stObj />
	</cffunction>
	
	<cffunction name="deleteData" access="public" output="false" returntype="struct" hint="Delete the specified objectid and corresponding data, including array properties and refObjects.">
		<cfargument name="schema" type="struct" required="true" hint="The type schema" />
		<!--- Additional required arguments for each primary key field --->
		<cfargument name="logLocation" type="string" required="false" default="" />
		
		<cfset var thisfield = "" />
		<cfset var stResult = structnew() />
		<cfset var queryresult = "" />
		<cfset var bFirst = true />
		
		<cfset stResult.bSuccess = true>
		<cfset stResult.results = arraynew(1) />
		
		<!--- Check that the primary key/s have been passed as arguments --->
		<cfloop list="#arraytolist(arguments.schema.indexes.primary.fields)#" index="thisfield">
			<cfif not structkeyexists(arguments,thisfield)>
				<cfthrow message="[#thisfield#] is part of this table's primary key and is required" />
			</cfif>
		</cfloop>
		
		<cftransaction>
			<cftry>
				<cfquery datasource="#this.dsn#" result="queryresult">
					DELETE 
					FROM 	#arguments.schema.tablename#
					WHERE 	<cfset bFirst = true />
							<cfloop list="#arraytolist(arguments.schema.indexes.primary.fields)#" index="thisfield">
								<cfif NOT bFirst>AND</cfif><cfset bFirst = false />
								
								<cfif arguments.schema.fields[thisfield].type eq "numeric">
									#thisfield# = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments[thisfield]#" />
								<cfelse><!--- String --->
									#thisfield# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments[thisfield]#" />
								</cfif>
							</cfloop>
				</cfquery>
				<cfset arrayappend(stResult.results,queryresult) />
				<cfif len(arguments.logLocation)>
					<cfset logQuery(arguments.logLocation,queryresult) />
				</cfif>
			
				<!--- Delete array data - only applicable for standard types (i.e. objectid primary key) --->
				<cfloop collection="#arguments.schema.fields#" item="thisfield">
					<cfif arguments.schema.fields[thisfield].type eq 'array'>
						<cfquery datasource="#this.dsn#" result="queryresult">
							DELETE 
							FROM 	#arguments.schema.fields[thisfield].tablename#
							WHERE 	parentid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
						</cfquery>
						<cfset arrayappend(stResult.results,queryresult) />
						<cfif len(arguments.logLocation)>
							<cfset logQuery(arguments.logLocation,queryresult) />
						</cfif>
					</cfif>
				</cfloop>
				
				<cfcatch type="database">
					<cfset stResult.bSuccess = false />
					<cfset stResult.message = cfcatch.message />
					<cfset arrayappend(stResult.results,cfcatch) />
				</cfcatch>
			</cftry>
		</cftransaction>
		
		<cfreturn stResult />
	</cffunction>
	
	<!--- DEPLOYMENT --->
	<cffunction name="dropSchema" access="public" output="false" returntype="struct" hint="Drops the table structure for a FarCry type">
		<cfargument name="schema" type="struct" required="true" />
		<cfargument name="logLocation" type="string" required="false" default="" />
		
		<cfset var stResult = structNew() />
		<cfset var queryresult = structnew() />
		<cfset var thisfield = "" />
		
		<cfset stResult.results = arraynew(1) />
    	<cfset stResult.bSuccess = true />
		
		<cfif isDeployed(arguments.schema)>
			<cftry>
				<cfquery datasource="#this.dsn#" result="queryresult">
					DROP TABLE #arguments.schema.tablename#
				</cfquery>
				
				<cfset arrayappend(stResult.results,queryresult) />
				<cfif len(arguments.logLocation)>
					<cfset logQuery(arguments.logLocation,queryresult) />
				</cfif>
				
				<cfcatch>
					<cfset arrayappend(stResult.results,cfcatch) />
					<cfset stResult.bSuccess = false />
				</cfcatch>
			</cftry>
		</cfif>
		
		<cfif stResult.bSuccess>
			<cfloop collection="#arguments.schema.fields#" item="thisfield">
				<cfif arguments.schema.fields[thisfield].type eq 'array'>
					<cfset combineResults(stResult,dropSchema(schema=arguments.schema.fields[thisfield],logLocation=arguments.logLocation)) />
				</cfif>
			</cfloop>
		</cfif>
		
		<cfif stResult.bSuccess>
			<cfset stResult.message = "Dropped '#arguments.schema.tablename#' table" />
		<cfelse>
			<cfset stResult.message = "Failed to drop '#arguments.schema.tablename#' table" />
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
					 	CREATE INDEX 	#stIndex.name# 
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
	
	<cffunction name="repairIndex" access="public" output="false" returntype="struct" hint="Repairs the index in a MySQL database.">
		<cfargument name="schema" type="struct" required="true" />
		<cfargument name="indexname" type="string" required="true" />
		<cfargument name="logLocation" type="string" required="false" default="" />
		
		<cfset var stIndex = arguments.schema.indexes[arguments.indexname] />
		<cfset var stResult = structnew() />
		<cfset var queryresult = "" />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.results = arraynew(1) />
		
		<cftry>
			<cfset stResult = dropIndex(schema=arguments.schema,indexname=arguments.indexname,logLocation=arguments.logLocation) />
			<cfset combineResults(stResult,addIndex(schema=arguments.schema,indexname=arguments.indexname,logLocation=arguments.logLocation)) />
			
			<cfcatch>
				<cfset stResult.bSuccess = false />
				<cfset arrayappend(stResult.results,cfcatch) />
			</cfcatch>
		</cftry>
		
		
		<cfif stResult.bSuccess>
			<cfset stResult.message = "Repaired '#arguments.schema.tablename#.#arguments.indexname#' index" />
		<cfelse>
			<cfset stResult.message = "Failed to repair '#arguments.schema.tablename#.#arguments.indexname#' index" />
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
		
		<cfset stIndex=stDB.indexes[arguments.indexname]>
		
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
				<cfelseif FindNoCase("text", arguments.aTableColMD[j].TypeName)>
					'|---|' , COALESCE( CAST( #arguments.aTableColMD[j].Name# as VARCHAR),'') , '|---|'
					<cfelseif FindNoCase("date", arguments.aTableColMD[j].TypeName)>
					'|---|' , COALESCE(#arguments.aTableColMD[j].Name#,'NULL') , '|---|'
				<cfelse>
					COALESCE( CAST( #arguments.aTableColMD[j].Name# as VARCHAR),'=???=')
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
	<cffunction name="isFieldAltered" access="public" returntype="boolean" output="false" hint="Returns true if there is a difference">
		<cfargument name="expected" type="struct" required="true" hint="The expected schema" />
		<cfargument name="actual" type="struct" required="true" hint="The actual schema" />
		
		<cfreturn arguments.expected.nullable neq arguments.actual.nullable OR arguments.expected.default neq arguments.actual.default OR arguments.expected.type neq arguments.actual.type OR arguments.expected.precision neq arguments.actual.precision />
	</cffunction>
	
	<cffunction name="diffSchema" access="public" returntype="struct" output="false" hint="Compares type metadata to the actual database schema">
		<cfargument name="schema" type="struct" required="true" hint="The type schema" />
		
		<cfset var stDB = structnew() />
		<cfset var stResult = structnew() />
		<cfset var thisfield = "" />
		<cfset var stThisResult = structnew() />
		<cfset var thisindex = "" />
		
		<cfset stResult.tables = structnew() />
		
		<cfif not isDeployed(schema=arguments.schema)>
			<cfset stResult.tables[arguments.schema.tablename] = structnew() />
			<cfset stResult.tables[arguments.schema.tablename].conflict = "Undeployed table" />
			<cfset stResult.tables[arguments.schema.tablename].newmetadata = arguments.schema />
			<cfset stResult.tables[arguments.schema.tablename].resolution = "+" />
		<cfelse>
			<cfset stDB = introspectType(arguments.schema.tablename) />
			
			<cfset stResult.tables[arguments.schema.tablename] = structnew() />
			<cfset stResult.tables[arguments.schema.tablename].fields = structnew() />
			<cfset stResult.tables[arguments.schema.tablename].indexes = structnew() />

			<!--- Fields --->
			<cfloop collection="#arguments.schema.fields#" item="thisfield">
				<cfset stThisResult = structnew() />
				
				<cfif not arguments.schema.fields[thisfield].type eq "array" and not structkeyexists(stDB.fields,thisfield)>
					<cfset stThisResult.conflict = "Undeployed property" />
					<cfset stThisResult.resolution = "+" />
					<cfset stThisResult.newMetadata = arguments.schema.fields[thisfield] />
					
					<cfset stResult.tables[arguments.schema.tablename].fields[thisfield] = stThisResult />
				<cfelseif not arguments.schema.fields[thisfield].type eq "array" and isFieldAltered(expected=arguments.schema.fields[thisfield],actual=stDB.fields[thisfield])>
					<cfset stThisResult.conflict = "Altered property" />
					<cfset stThisResult.resolution = "x" />
					<cfset stThisResult.oldMetadata = stDB.fields[thisfield] />
					<cfset stThisResult.newMetadata = arguments.schema.fields[thisfield] />
					
					<cfset stResult.tables[arguments.schema.tablename].fields[thisfield] = stThisResult />
				</cfif>
			</cfloop>
			
			<cfloop collection="#stDB.fields#" item="thisfield">
				<cfset stThisResult = structnew() />
				
				<cfif not structkeyexists(arguments.schema.fields,thisfield)>
					<cfif stDB.fields[thisfield].type eq "array">
						<cfset stResult.tables[stDB.fields[thisfield].tablename] = structnew() />
						<cfset stResult.tables[stDB.fields[thisfield].tablename].conflict = "Surplus table" />
						<cfset stResult.tables[stDB.fields[thisfield].tablename].oldMetadata = stDB.fields[thisfield] />
						<cfset stResult.tables[stDB.fields[thisfield].tablename].resolution = "-" />
					<cfelse>
						<cfset stThisResult.conflict = "Surplus property" />
						<cfset stThisResult.resolution = "-" />
						<cfset stThisResult.oldMetadata = stDB.fields[thisfield] />
						
						<cfset stResult.tables[arguments.schema.tablename].fields[thisfield] = stThisResult />
					</cfif>
				</cfif>
			</cfloop>
			
			<!--- Indexes --->
			<cfloop collection="#arguments.schema.indexes#" item="thisindex">
				<cfset stThisResult = structnew() />
				
				<cfif not structkeyexists(stDB.indexes,thisindex)>
					<cfset stThisResult.conflict = "Undeployed index" />
					<cfset stThisResult.resolution = "+" />
					<cfset stThisResult.newMetadata = arguments.schema.indexes[thisindex] />
					
					<cfset stResult.tables[arguments.schema.tablename].indexes[thisindex] = stThisResult />
				<cfelseif arraytolist(arguments.schema.indexes[thisindex].fields) neq arraytolist(stDB.indexes[thisindex].fields)>
					<cfset stThisResult.conflict = "Altered index" />
					<cfset stThisResult.resolution = "x" />
					<cfset stThisResult.newMetadata = arguments.schema.indexes[thisindex] />
					<cfset stThisResult.oldMetadata = stDB.indexes[thisindex] />
					
					<cfset stResult.tables[arguments.schema.tablename].indexes[thisindex] = stThisResult />
				</cfif>
			</cfloop>
			
			<cfloop collection="#stDB.indexes#" item="thisindex">
				<cfset stThisResult = structnew() />
				
				<cfif not structkeyexists(arguments.schema.indexes,thisindex)>
					<cfset stThisResult.conflict = "Surplus index" />
					<cfset stThisResult.resolution = "-" />
					<cfset stThisResult.oldMetadata = stDB.indexes[thisindex] />
					
					<cfset stResult.tables[arguments.schema.tablename].indexes[thisindex] = stThisResult />
				</cfif>
			</cfloop>
			
			<cfif structcount(stResult.tables[arguments.schema.tablename].fields) or structcount(stResult.tables[arguments.schema.tablename].indexes)>
				<cfset stResult.tables[arguments.schema.tablename].conflict = "Altered table" />
				<cfset stResult.tables[arguments.schema.tablename].resolution = "x" />
				<cfset stResult.tables[arguments.schema.tablename].newmetadata = arguments.schema />
			<cfelse>
				<cfset structdelete(stResult.tables,arguments.schema.tablename) />
			</cfif>
		</cfif>
		
		<!--- Find any array tables and add them too --->
		<cfloop collection="#arguments.schema.fields#" item="thisfield">
			<cfif arguments.schema.fields[thisfield].type eq "array">
				<cfset structappend(stResult.tables, diffSchema(arguments.schema.fields[thisfield]).tables) />
			</cfif>
		</cfloop>
		
		<cfreturn stResult />
	</cffunction>

	<cffunction name="isDeployed" access="public" output="false" returntype="boolean" hint="Returns True if the table is already deployed">
		<cfargument name="schema" type="struct" required="true" hint="Table schema to check" />
		
		<cfset var q = "" />
		
		<cftry>
			<cfquery datasource="#this.dsn#" name="q">
				SELECT count(*)
				FROM #this.dbowner##arguments.schema.tablename#
			</cfquery>
			
			<cfcatch type="database">
				<cfreturn false />
			</cfcatch>
		</cftry>
		
		<cfreturn true />
	</cffunction>

</cfcomponent>