<cfcomponent name="DBGateway" output="false" hint="This component provides generic database access for the fourq persistence layer of FarCry">


	<cffunction name="init" access="public" returntype="farcry.core.packages.fourq.gateway.DBGateway" output="false" hint="Initializes the instance data">
		<cfargument name="dsn" type="string" required="true" />
		<cfargument name="dbowner" type="string" required="true" />
		<cfset variables.dbowner = arguments.dbowner />
		<cfset variables.dsn = arguments.dsn />
		<cfset variables.numericTypes = "boolean,date,numeric,integer" />
		<cfreturn this />
	</cffunction>


	<cffunction name="deployType" access="public" output="false" returntype="struct" hint="Deploys the table structure for a FarCry type">
		<cfargument name="metadata" type="farcry.core.packages.fourq.TableMetadata" required="true" />
		<cfargument name="bDropTable" type="boolean" required="false" default="false">
		<cfargument name="bTestRun" type="boolean" required="false" default="true">
		<cfargument name="dsn" type="string" required="false" default="#variables.dsn#">
		<cfargument name="dbowner" type="string" required="false" default="#variables.dbowner#">
		
			<cfthrow type="farcry.core.packages.fourq.DBGATEWAY.UNIMPLEMENTED" message="DBGateway deployType() unimplemented"
				 detail="The method deployType() was not implemented in a child of DBGateway." />
	</cffunction>
	

	<!---
	 ************************************************************
	 *                                                          *
	 *                    CRUD METHODS                          *
	 *                                                          *
	 ************************************************************
	 --->	
	<cffunction name="createData" access="public" returntype="struct" output="false" hint="Creates a new row in the db for the given properties">
	  <cfargument name="stProperties" type="struct" required="true" />
	  <cfargument name="objectid" type="uuid" required="true" />
	  <cfargument name="metadata" type="farcry.core.packages.fourq.TableMetadata" required="true" />
	  <cfargument name="dsn" type="string" required="false" default="#variables.dsn#">
	  
			<cfset var stResult = structNew() />
			<cfset var tablename=arguments.metadata.getTableName() />
			<cfset var i=0>
			<cfset var j=0>
			
			<cfset var stFields = arguments.metadata.getTableDefinition() />      
      		<cfset var SQLArray = generateSQLNameValueArray(stFields,stProperties) />
      		<cfset var qCreateData = queryNew("blah") />
      		<cfset var qRefData = queryNew("blah") />
      		<cfset var createDataResult = structNew() />
      		<cfset var currentObjectID = "" />
	    
			<!--- set defaults for status --->
			<cfset createDataResult.bSuccess = true>
			<cfset createDataResult.message = "Object created successfully">


			<!--- check objectid passed --->
			<cfif structKeyExists(arguments.stProperties,"objectid")>
				<cfset currentObjectID=arguments.stProperties.objectid>
			<cfelseif structKeyExists(arguments,"objectid")>
				<cfset currentObjectID=arguments.objectid>
			<cfelse>
				<cfset currentObjectID = CreateUUID()>
			</cfif>
			
			<!--- build query --->
	
				<cfquery datasource="#arguments.dsn#" name="qCreateData">
					INSERT INTO #variables.dbowner##tablename# ( 
						objectID
						<cfloop from="1" to="#arrayLen(SQLArray)#" index="i">
							<!--- Check to make sure property is to be saved in the db. --->
							<cfif not structKeyExists(application, "stcoapi") OR  not structKeyExists(application.stCoapi, tablename) OR not structKeyExists(application.stCoapi[tableName].STPROPS[sqlArray[i].column].METADATA,"BSAVE") OR application.stCoapi[tableName].STPROPS[sqlArray[i].column].METADATA.bSave>
							  , #sqlArray[i].column#	
							</cfif>
						</cfloop>
					)
					VALUES ( 
					
						<cfqueryparam value="#currentObjectID#" cfsqltype="CF_SQL_VARCHAR">
						<cfloop from="1" to="#arrayLen(SQLArray)#" index="i">
							<!--- Check to make sure property is to be saved in the db. --->
							<cfif not structKeyExists(application, "stcoapi") OR  not structKeyExists(application.stCoapi, tablename) OR not structKeyExists(application.stCoapi[tableName].STPROPS[sqlArray[i].column].METADATA,"BSAVE") OR application.stCoapi[tableName].STPROPS[sqlArray[i].column].METADATA.bSave>
							  <!--- temp fix for mySQL, looks as though the datatype decimal and bind type float don't live peacefully together :( --->
							  <cfif structKeyExists(sqlArray[i],'cfsqltype') AND sqlArray[i].cfsqltype NEQ "CF_SQL_FLOAT">
							    , <cfqueryparam cfsqltype="#sqlArray[i].cfsqltype#" value="#sqlArray[i].value#" />
							  <cfelseif structKeyExists(sqlArray[i],'cfsqltype') AND sqlArray[i].cfsqltype EQ "CF_SQL_FLOAT">
								<!--- make sure we are only passing 2 places after the decimal point --->
								, #numberFormat(sqlArray[i].value, "99999999999999.00")#
							   <cfelse>
							    , #sqlArray[i].value#
							  </cfif>
							</cfif>
						</cfloop>
					)			
				</cfquery>

				
				<!--- Insert any array property data. --->
				<cfloop collection="#stFields#" item="i">
				  <cfif stFields[i].type eq 'array' AND structKeyExists(stProperties,i)>
				  	<cfif IsArray(stProperties[i])>
						<cfset createArrayTableData(tableName&"_"&i,currentObjectID,stFields[i].fields,stProperties[i],arguments.dsn) />
					</cfif>
				  </cfif>
				</cfloop>
					
				
				<cftry>
				<!--- create lookup ref for type --->			
				<cfquery datasource="#arguments.dsn#" name="qRefData">
					INSERT INTO #variables.dbowner#refObjects (
						objectID, 
						typename
					)
					VALUES (
						<cfqueryparam value="#currentObjectID#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#tablename#" cfsqltype="CF_SQL_VARCHAR">
					)
				</cfquery>
					<cfcatch type="any">
						<!--- This error can occur because of a duplicate already in the refObjects table caused by the initial create data saving to session.
						TODO: need a more elegent solution to handle this.
						 --->
					</cfcatch>	
				</cftry>

			<cfset createDataResult.objectid = currentObjectID>
			
			<cfreturn createDataResult>
	</cffunction>


	<cffunction name="createArrayTableData" access="public" returntype="array" output="true" hint="Inserts the array table data for the given property data and returns the Array Table data as a list of objectids">
	    <cfargument name="tableName" type="string" required="true" />
	    <cfargument name="objectid" type="uuid" required="true" />
	    <cfargument name="tabledef" type="struct" required="true" />
	    <cfargument name="aProps" type="array" required="true" />
	    <cfargument name="dsn" type="string" required="false" default="#variables.dsn#">
	
	    <cfset var i = 0 />
	    <cfset var j = 0 />
	    <cfset var stProps = "" />
	    <cfset var SQLArray = "" />
	    <cfset var stTmp = "" />
		<cfset var lNewData = "" />
		<cfset var o = "" />
   		<cfset var qArrayRecordsToDelete = queryNew("blah") />
   		<cfset var qDeleteRecords = queryNew("blah") />
   		<cfset var qCurrentArrayRecords = queryNew("blah") />
   		<cfset var qDuplicate = queryNew("blah") />
   		<cfset var qCreateData = queryNew("blah") />
   		<cfset var update = "" />
   		<cfset var qArrayData = queryNew("blah") />
   		<cfset var qTypename = queryNew("blah") />
   		<cfset var qUpdateSeq = queryNew("blah") />
   		<cfset var stResult = structNew() />
   		<cfset var insertSEQ = "" />
   		<cfset var aReturn = arrayNew(1) />
   		<cfset var sortorder = "" />
		<cfset var aPropsPassedIn = arrayNew(1) />
		<cfset var stArrayProp = structNew() />
		
		<cfloop from ="1" to="#arrayLen(arguments.aProps)#" index="i">
			<cfif NOT isStruct(arguments.aProps[i])>
				<cfset stArrayProp = structNew() />
				<cfset stArrayProp.parentID = arguments.objectid />
				<cfset stArrayProp.data = listFirst(arguments.aProps[i],":") />
				<cfif listLast(arguments.aProps[i],":") NEQ listFirst(arguments.aProps[i],":")><!--- SEQ PASSED IN --->
					<cfset stArrayProp.seq = listLast(arguments.aProps[i],":") />
				<cfelse>
					<cfset stArrayProp.seq = i />
				</cfif>
				
				<cfset arguments.aProps[i] = stArrayProp>
			</cfif>
			
		</cfloop>
	
		
		
		<!--- 
		IF THE ARRAY TABLE HAS HAD A CFC CREATED FOR IT IN ORDER TO EXTEND IT THEN WE USE STANDARD GET, SET & DELETE.
		 --->
		<cfif structKeyExists(application, "stcoapi") AND structKeyExists(application.stcoapi, tableName)>
			
			<!--- MJB
			Only delete records that are not contained in the Array of objects passed. This ensures that any extended array properties are not deleted.
			 --->
			<!--- 
			Create a list of objectids to be added. 
			This is required because in the case of extended arrays, the objectids are contained in a structure.
			--->	
		
			<cfset o = createObject("component",application.stcoapi[tablename].packagepath) />
		

				
		    <cfquery datasource="#arguments.dsn#" name="qCurrentArrayRecords">
		    SELECT * FROM #variables.dbowner##arguments.tableName#
		    WHERE parentID = '#arguments.objectid#'
		    </cfquery>
		  
		    <cfloop query="qCurrentArrayRecords">
		    
		    	<!--- Only delete items where they are not passed in.  --->
		    	<cfset bDeleteArrayItem = true />
			    <cfloop from ="1" to="#arrayLen(arguments.aProps)#" index="i">
					<cfif arguments.aProps[i].data EQ qCurrentArrayRecords.data AND arguments.aProps[i].seq EQ qCurrentArrayRecords.seq >
						<cfset bDeleteArrayItem = false />
						
						<!--- Add objectid to the struct if it is an extended array. This will make it easier to find shortly. --->
						<cfif listContainsNoCase(qCurrentArrayRecords.columnList, "objectid")>
							<cfset arguments.aProps[i].objectid = qCurrentArrayRecords.objectID />
						</cfif>
					</cfif>
				</cfloop>
				<cfif bDeleteArrayItem>
					<cfset stResult = o.deleteData(objectID=qCurrentArrayRecords.objectid) />
				</cfif>
			</cfloop>
		      
		<!---
		IT IS JUST A STANDARD ARRAY TABLE SO HAVE TO DELETE THE OBJECTS MANUALLY AND WE DONT HAVE TO WORRY ABOUT EXTENDED METADATA
		 --->	
		<cfelse>
		
			<cfquery datasource="#arguments.dsn#" name="qDeleteRecords">
		    DELETE FROM #variables.dbowner##arguments.tableName#
		    WHERE parentID = '#arguments.objectid#'
		    </cfquery>
			
		    <!--- <cfquery datasource="#arguments.dsn#">
		    DELETE FROM #variables.dbowner##arguments.tableName#
		    WHERE parentID = '#arguments.objectid#'
			<cfif listlen(lNewData)>
				AND data NOT IN (#ListQualify(lNewData,"'")#)
			</cfif>
		    </cfquery> --->
			
		</cfif>
		
			
		<!--- MJB:
		This will allow us to ensure that any new objects to be placed in the array table will have a unique SEQ by setting the start to qCurrentArrayRecords.RecordCount.
		We could use a MAX(Seq) but unsure about DB compatibility.
		 --->
		<cfquery datasource="#arguments.dsn#" name="qCurrentArrayRecords">
	    SELECT *
		FROM #variables.dbowner##arguments.tableName#
	    WHERE parentID = '#arguments.objectid#'
	    </cfquery>
		
		<cfloop from ="1" to="#arrayLen(aProps)#" index="i">
		
			<cfquery dbtype="query" name="qDuplicate">
			SELECT * 
			FROM qCurrentArrayRecords
			WHERE parentID = '#arguments.objectid#'
			<cfif structKeyExists(arguments.aProps[i], "objectid")>
				AND objectid = <cfqueryparam value="#arguments.aProps[i].objectid#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				AND data = <cfqueryparam value="#arguments.aProps[i].data#" cfsqltype="CF_SQL_VARCHAR">
				AND seq = <cfqueryparam value="#arguments.aProps[i].seq#" cfsqltype="cf_sql_numeric">
			</cfif>
			</cfquery>
			
			
			<cfif qDuplicate.RecordCount>
			
				<!--- 
				IF THE ARRAY TABLE HAS HAD A CFC CREATED FOR IT IN ORDER TO EXTEND IT THEN WE USE STANDARD GET, SET & DELETE.
				 --->
				<cfif structKeyExists(application, "types") AND structKeyExists(application.types, tableName) AND arguments.aProps[i].seq NEQ i>
					
					<!--- Use the extended arrayTable's' objectid and Set the seq to the new position in the array --->
					<cfset arguments.aProps[i].objectid = qDuplicate.objectid />	
					<cfset arguments.aProps[i].seq = i />	
					<cfset stResult = o.setdata(stProperties=arguments.aProps[i]) />	
				</cfif>
				
				
			<cfelse>
			
				<!--- 
				IF THE ARRAY TABLE HAS HAD A CFC CREATED FOR IT IN ORDER TO EXTEND IT THEN WE USE STANDARD GET, SET & DELETE.
				 --->
				<cfif structKeyExists(application, "types") AND structKeyExists(application.types, tableName)>
			
					<cfset stResult = o.createData(stProperties=arguments.aProps[i]) />	
					
					
				<!---
				IT IS JUST A STANDARD ARRAY TABLE SO HAVE TO INSERT THE OBJECTS MANUALLY
				 --->	
				<cfelse>
					<cfset SQLArray = generateSQLNameValueArray(arguments.tableDef,arguments.aProps[i]) />
					
					<cfquery datasource="#arguments.dsn#" name="qCreateData">
					INSERT INTO #variables.dbowner##tablename# ( 
						parentID
						,seq
						<cfloop from="1" to="#arrayLen(SQLArray)#" index="j">
							<cfif sqlArray[j].column NEQ "seq" AND sqlArray[j].column NEQ "parentid">, #sqlArray[j].column#</cfif>						
						</cfloop>
					)
					VALUES ( 
					
					<cfqueryparam value="#arguments.objectid#" cfsqltype="CF_SQL_VARCHAR">
					,<cfqueryparam value="#qCurrentArrayRecords.RecordCount + i#" cfsqltype="CF_SQL_Integer"><!--- MJB: Add the current recordcount to the seq to ensure unique seq --->
						<cfloop from="1" to="#arrayLen(SQLArray)#" index="j">
							<cfif sqlArray[j].column NEQ "seq" AND sqlArray[j].column NEQ "parentid">
								<cfif structKeyExists(sqlArray[j],'cfsqltype')>
								, <cfqueryparam cfsqltype="#sqlArray[j].cfsqltype#" value="#sqlArray[j].value#" />
								<cfelse>
								, #sqlArray[j].value#
								</cfif>
							</cfif>
						</cfloop>
					)			
					</cfquery>
				</cfif>
				
				
			</cfif>
		</cfloop>
		
	
		<!---------------------------------------------------------------
		WE NEED TO UPDATE THE TYPENAME OF EACH RECORD IN THE ARRAY TABLE
		 --------------------------------------------------------------->	
		<!--- todo: work out most efficient way for each dbtype and break out into the relevant gateway --->
		<cfswitch expression="#application.dbtype#">
		<cfcase value="mysql,mysql5">
			<!--- This works for mySQL 5; see mysql5 specific gateway --->
			<cfquery name="update" datasource="#arguments.dsn#">
			UPDATE #tablename# p
			INNER JOIN refObjects pp
			ON p.data = pp.objectid
			SET p.typename = pp.typename
			WHERE p.parentID = '#arguments.objectid#'
			</cfquery> 
		</cfcase>
		<cfcase value="postgresql">
			
			<cfquery name="qArrayData" datasource="#arguments.dsn#">
			SELECT data as arrayobjid
			FROM #variables.dbowner##tablename#
			WHERE parentID = '#arguments.objectid#'
			</cfquery>
			
			<cfloop query="qArrayData">
				<cfquery name="qTypename" datasource="#arguments.dsn#">
				SELECT typename
				FROM refobjects
				WHERE objectID = '#qarraydata.arrayobjid#'
				</cfquery>
				
				<cfquery name="update" datasource="#arguments.dsn#">
				UPDATE #variables.dbowner##tablename#
				SET 
				typename = '#qtypename.typename#'
				WHERE
				data = '#qarraydata.arrayobjid#'
				</cfquery>
			</cfloop>
			
		</cfcase>
		<cfcase value="mssql">
			<cfquery name="update" datasource="#arguments.dsn#">
				UPDATE #variables.dbowner##tablename#
				SET #variables.dbowner##tablename#.typename = refObjects.typename		
				FROM #variables.dbowner##tablename# INNER JOIN refObjects
				ON #variables.dbowner##tablename#.data=refObjects.objectid	
				WHERE parentID = '#arguments.objectid#'			
			</cfquery>
		</cfcase>
		<cfcase value="ora">
			<cfquery name="update" datasource="#arguments.dsn#">
			UPDATE #variables.dbowner##tablename#
			SET #variables.dbowner##tablename#.typename =
				(SELECT refObjects.typename
				FROM refObjects 
				WHERE #variables.dbowner##tablename#.data = refObjects.objectid) 
			WHERE parentID = '#arguments.objectid#'    
			</cfquery>
		</cfcase>	
		<cfdefaultcase>
			<!--- anything else / needs to be checked as this does not work for all databases--->
			<cfquery name="update" datasource="#arguments.dsn#">
				UPDATE #variables.dbowner##tablename#
				SET #variables.dbowner##tablename#.typename = refObjects.typename		
				FROM #variables.dbowner##tablename# INNER JOIN refObjects
				ON #variables.dbowner##tablename#.data=refObjects.objectid	
				WHERE parentID = '#arguments.objectid#'			
			</cfquery>	
		</cfdefaultcase>
		</cfswitch>
		
		<!--- MJB:
		Because we are no longer deleting the array table records, we need to re-do the sort  --->
		<cfset variables.sortorder = 1>
		<cfset variables.sorted = "">	<!--- MJB: This ensures that if a duplicate ObjectID is attempted to be attached, the sorting will not get out of wack. 
										This would occur if a user added an object to the end of the array that already existed previously. --->
		
		
		<cfreturn aProps>
		
		<!--- 
		<cfset aReturn = ArrayNew(1)>
		
		<cfloop from ="1" to="#arrayLen(aProps)#" index="i">
			<cfif not listContainsNoCase(variables.sorted,arguments.aProps[i].data)>		
				<cfquery datasource="#arguments.dsn#" name="qUpdateSeq">
				UPDATE #variables.dbowner##tablename#
				SET seq = #sortorder#
				WHERE parentID = '#arguments.objectid#'
				AND data = <cfqueryparam value="#arguments.aProps[i].data#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
				<cfset sortorder = sortorder + 1>
				<cfset variables.sorted = ListAppend(variables.sorted,arguments.aProps[i].data)>
				<cfset ArrayAppend(aReturn,arguments.aProps[i].data)>
			</cfif>
	 	</cfloop>
	
		
	
		<cfreturn aReturn> --->
		
	</cffunction>


  	<cffunction name="setData" access="public" returntype="struct" output="false" >
    	<cfargument name="stProperties" type="struct" required="true" />
	  	<cfargument name="metadata" type="farcry.core.packages.fourq.TableMetadata" required="true" />
		<cfargument name="dsn" type="string" required="false" default="#variables.dsn#">
	  	
	  	<cfset var stFields = arguments.metadata.getTableDefinition() />
		<cfset var tablename = arguments.metadata.getTableName() />
		<cfset var SQLArray = generateSQLNameValueArray(stFields,stProperties) />
   		<cfset var i = "" />
   		<cfset var qRecordExists = queryNew("blah") />
   		<cfset var qSetData = queryNew("blah") />
   		<cfset var stResult = structNew() />
   		<cfset var objectid = "" />
   		<cfset var stPackage = structNew() />
   		<cfset var packagePath = "" />
   		<cfset var userLogin = "" />
   		<cfset var t = "" />
   		<cfset var stDefaultProperties = structNew() />
   		<cfset var stCreatedObject = structNew() />
		<cfset var bFirst = true />

		<cfset stResult.bSuccess = true />
		<cfset stResult.message = "" />
		
		<!--- check objectid passed --->
		<cfif IsDefined("arguments.stProperties.objectid")>
			<cfset objectid=arguments.stProperties.objectid>
		<cfelseif IsDefined("arguments.objectid")>
			<cfset objectid=arguments.objectid>
		<cfelse>
			<cfabort showerror="Error: You must pass the objectid as an argument or part of the stProperties structure.">
		</cfif>
	
		
		<cfif structKeyExists(application.types, tablename)>
			<cfset stPackage = application.types[tablename]>
			<cfset packagePath = application.types[tablename].typepath>
		<cfelseif  structKeyExists(application.rules, tablename)>
			<cfset stPackage = application.rules[tablename]>
			<cfset packagePath = application.rules[tablename].rulepath>
		</cfif>	
		
		<!--- Check to see if the objectID already exists in the database, if not, create it quickly with the objectid passed in stProperties. --->
		<cfquery datasource="#arguments.dsn#" name="qRecordExists">
		SELECT objectID FROM #variables.dbowner##tablename#
		WHERE objectID = <cfqueryparam value="#objectID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		<cfif qRecordExists.RecordCount EQ 0>
			<cfif isDefined("session.dmSec.authentication.userlogin")>
				<cfset userLogin = session.dmSec.authentication.userlogin>
			<cfelse>
				<cfset userLogin = "Unknown">
			</cfif>
			<cfset t = createObject("component",packagePath)>
			
			<cfset stDefaultProperties = t.getDefaultObject(objectid=objectID,typename=tablename,dsn=arguments.dsn)>
			<cfset StructAppend(arguments.stProperties,stDefaultProperties,false)>			
			<cfset stCreatedObject = t.createData(stProperties=arguments.stProperties, objectID=stProperties.ObjectID,User=userLogin,dsn=arguments.dsn)>
		</cfif>
		

		<!--- build query --->
		<cfset bFirst = true />
		<cfquery datasource="#arguments.dsn#" name="qSetData">
			UPDATE #variables.dbowner##tablename#
			SET
			<cfloop from="1" to="#arrayLen(SQLArray)#" index="i">
				<cfset setProp = false>
				
				<!--- Check to make sure property is to be saved in the db. --->
			  	<cfif not structKeyExists(application.stCoapi, tablename) OR not structKeyExists(application.stCoapi[tableName].STPROPS[sqlArray[i].column].METADATA,"BSAVE") OR application.stCoapi[tableName].STPROPS[sqlArray[i].column].METADATA.bSave>

					<cfif structKeyExists(arguments.stProperties,sqlArray[i].column) and sqlArray[i].column neq "objectid" and sqlArray[i].column neq "typename">
					  	<cfif NOT bFirst>,</cfif><cfset bFirst = false /> #sqlArray[i].column# = 
						<!--- temp fix for mySQL, looks as though the datatype decimal and bind type float don't live peacefully together :( --->
						<cfif structKeyExists(sqlArray[i],'cfsqltype') AND sqlArray[i].cfsqltype NEQ "CF_SQL_FLOAT">
						  <cfqueryparam cfsqltype="#sqlArray[i].cfsqltype#" value="#SQLArray[i].value#" />
						<cfelseif structKeyExists(sqlArray[i],'cfsqltype') AND sqlArray[i].cfsqltype EQ "CF_SQL_FLOAT">
							<!--- make sure we are only passing 2 places after the decimal point --->
							#numberFormat(sqlArray[i].value, "99999999999999.00")#
						<cfelse>
						  #sqlArray[i].value#
						</cfif>
					</cfif>
				
				</cfif>
			
			</cfloop>
			
			WHERE objectID = <cfqueryparam value="#objectID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		



		<!--- Insert any array property data. --->		
		<cfloop collection="#stFields#" item="i">
		  <cfif stFields[i].type eq 'array' AND structKeyExists(stProperties,i)>
		      <cfset createArrayTableData(tableName&"_"&i,objectid,stFields[i].fields,stProperties[i],arguments.dsn) />
		  </cfif>
		</cfloop>
			
		
		<cfreturn stResult />
	</cffunction>


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
							<cfabort showerror="Error: #field# must be a date (#propertyValue#).">
						</cfif>
					</cfcase>
					
					<cfcase value="integer">
						<cfif IsNumeric(propertyValue)>
							<cfset stField.value = propertyValue />
						<cfelse>
							<cfset stField.value = "0" />
						</cfif>
						<cfset stField.cfsqltype = "CF_SQL_INTEGER" />
					</cfcase>
					
					<cfcase value="numeric">
						<cfif IsNumeric(propertyValue)>
							<cfset stField.value = propertyValue />
						<cfelse>
							<cfset stField.value = "0" />
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
						<cfset stField.cfsqltype="CF_SQL_LONGVARCHAR" />
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


	<cffunction name="deployArrayTable" access="package" output="false" returntype="struct" hint="Deploys the array table for the given metadata.">
		<cfargument name="metadata" type="farcry.core.packages.fourq.TableMetadat" required="true" />
		<cfargument name="bDropTable" type="boolean" required="false" default="false">
		<cfargument name="bTestRun" type="boolean" required="false" default="true">
		<cfargument name="parent" type="string" required="true">
		<cfargument name="property" type="string" required="true">
		<cfargument name="datatype" type="string" required="false" default="String">
		<cfargument name="dsn" type="string" required="false" default="#variables.dsn#">
		<cfargument name="dbowner" type="string" required="false" default="#variables.dbowner#">
		
		
			<cfthrow type="farcry.core.packages.fourq.DBGATEWAY.UNIMPLEMENTED" message="DBGateway deleteData() unimplemented"
				 detail="The method deleteData() was not implemented in a child of DBGateway." />
	</cffunction>
	
		
	<cffunction name="getMultiple" access="public" hint="Get multpile objects of a particular type" ouput="false" returntype="struct">
		<cfargument name="tableName" type="string" required="true">
		<cfargument name="stProps" type="struct" required="true">
		<cfargument name="lObjectIDs" type="string" required="false" default="" hint="Restrict resultset to a comma delimited list of objectids.">
		<cfargument name="OrderBy" type="string" required="false" default="" hint="Comma delimited list of properties to order by. Known issue: method returns a struct which randomises sort order :(">
		<cfargument name="SortOrder" type="string" required="false" default="asc" hint="asc or desc options.">
		<cfargument name="conditions" type="struct" required="false" default="#structNew()#" hint="Query filter; pass in structure keyed by property and with a value equal to the desired filter.">
		<cfargument name="whereclause" type="string" required="false">
		
		<cfset var prop = "" />
		<cfset var key = "" />
		<cfset var stObjects = "" />
   		<cfset var qMultipleObjects = queryNew("blah") />
   		<cfset var qArrayData = queryNew("blah") />
   		<cfset var sql = "" />
		
		<cfsavecontent variable="sql">
		<cfoutput>
			SELECT *
			FROM #variables.dbowner##arguments.tablename#
			<cfif isDefined('arguments.whereclause')>
				#preservesinglequotes(arguments.whereclause)#
			<cfelse>
				WHERE 0=0
				
				<cfloop collection="#arguments.conditions#" item="prop">
					<cfswitch expression="#stProps[prop].metadata.type#">
						<cfcase value="numeric,date,boolean">
							AND #prop# = #arguments.conditions[prop]#
						</cfcase>
						<cfdefaultcase>
							AND #prop# = '#arguments.conditions[prop]#'
						</cfdefaultcase>
					</cfswitch>
				</cfloop>
				
				<cfif len(arguments.lObjectIDs)>
					AND objectid IN (#listQualify(arguments.lObjectIDs,"'")#)
				</cfif>
				
			</cfif>
			<cfif len(arguments.OrderBy)>
				ORDER BY #arguments.OrderBy# #arguments.SortOrder#
			</cfif>
		</cfoutput>
		</cfsavecontent>
		
		<cftry>
			<cfquery datasource="#variables.dsn#" name="qMultipleObjects">
				#preservesinglequotes(sql)#
			</cfquery>
			<cfcatch>
				<cfset request.fourqGetMultipleErrorContext = cfcatch>
				<cfthrow type="fourq.getMultiple" message="Query error occurred in fourq.cfc getMultiple()" detail="<p>This is a dynamically generated query which can be the mother or all things to debug. Try looking at the stack trace and the sequence of templates parsed to figure out where the function was called from.</p> <p>SQL for the failed query:<br><pre>#reReplaceNoCase(sql,'[#chr(20)##chr(9)#]','','all')#</pre></p> <p>The original cfcatch scope was put into request.fourqGetMultipleErrorContext.</p>">
			</cfcatch>
		</cftry>
		
		
		<cfset stObjects = StructNew()>
		
		<cfloop query="qMultipleObjects">
			<cfset stObjects[qMultipleObjects.objectid] = structNew()>
			<cfloop collection="#stProps#" item="prop">
				<!--- check for array tables --->
				<cfif stProps[prop].metadata.Type eq 'array'>
					<cfset key = prop>

					<!--- getdata for array properties --->
					<cfquery datasource="#variables.dsn#" name="qArrayData">
						select * from #variables.dbowner##arguments.tableName#_#key#
						where parentid = '#qMultipleObjects.objectid#'
						order by seq
					</cfquery>
				
					<cfset SetVariable("#key#", ArrayNew(1))>
				
					<cfloop query="qArrayData">
						<cfset ArrayAppend(Evaluate(key), qArrayData.data)>
					</cfloop>
				
					<cfset SetVariable("stObjects[qMultipleObjects.objectid]['#UCase(key)#']", Evaluate(key))>
				<cfelse>
					<cfset stObjects[qMultipleObjects.objectid][prop] = qMultipleObjects[prop][qMultipleObjects.currentRow]>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn stObjects>
		
  </cffunction>
  

	<cffunction name="getMultiplebyQuery" access="public" hint="Get multpile rows of a query" ouput="false" returntype="query">
		<cfargument name="tableName" type="string" required="true">
		<cfargument name="stProps" type="struct" required="true">
		<cfargument name="lObjectIDs" type="string" required="false" default="" hint="Restrict resultset to a comma delimited list of objectids.">
		<cfargument name="OrderBy" type="string" required="false" default="" hint="Comma delimited list of properties to order by. Known issue: method returns a struct which randomises sort order :(">
		<cfargument name="SortOrder" type="string" required="false" default="asc" hint="asc or desc options.">
		<cfargument name="conditions" type="struct" required="false" default="#structNew()#" hint="Query filter; pass in structure keyed by property and with a value equal to the desired filter.">
		<cfargument name="whereclause" type="string" required="false">
		<cfargument name ="maxRows" required="false" type="numeric" default="-1">
		
		<cfset var prop = "" />
		<cfset var key = "" />
		<cfset var stObjects = "" />
   		<cfset var qMultipleObjects = queryNew("blah") />
   		<cfset var sql = "" />
		
		<cfsavecontent variable="sql">
		<cfoutput>
			SELECT *
			FROM #variables.dbowner##arguments.tablename#
			WHERE 0=0
			<cfif arguments.whereclause neq "">
				AND #preservesinglequotes(arguments.whereclause)#
			<cfelse>
				<cfloop collection="#arguments.conditions#" item="prop">
					<cfswitch expression="#stProps[prop].metadata.type#">
						<cfcase value="numeric,date,boolean">
							AND #prop# = #arguments.conditions[prop]#
						</cfcase>
						<cfdefaultcase>
							AND #prop# = '#arguments.conditions[prop]#'
						</cfdefaultcase>
					</cfswitch>
				</cfloop>
				<cfif len(arguments.lObjectIDs)>
					AND objectid IN (#listQualify(arguments.lObjectIDs,"'")#)
				</cfif>
			</cfif>
			<cfif len(arguments.OrderBy)>
				ORDER BY #arguments.OrderBy# #arguments.SortOrder#
			</cfif>
		</cfoutput>
		</cfsavecontent>
		
		
		<cftry>
			<cfif arguments.maxrows eq "">
				<cfquery datasource="#variables.dsn#" name="qMultipleObjects">
					#preservesinglequotes(sql)#
				</cfquery>
			<cfelse>
				<cfquery datasource="#variables.dsn#" name="qMultipleObjects" maxrows="#arguments.maxRows#">
					#preservesinglequotes(sql)#
				</cfquery>
			</cfif>
			<cfcatch>
				<!--- <cfset request.fourqGetMultipleErrorContext = cfcatch>
				<cfthrow type="fourq.getMultiple" message="Query error occurred in fourq.cfc getMultiple()" detail="<p>This is a dynamically generated query which can be the mother or all things to debug. Try looking at the stack trace and the sequence of templates parsed to figure out where the function was called from.</p> <p>SQL for the failed query:<br><pre>#reReplaceNoCase(sql,'[#chr(20)##chr(9)#]','','all')#</pre></p> <p>The original cfcatch scope was put into request.fourqGetMultipleErrorContext.</p>"> --->
				<cfdump var="#cfcatch#">
			</cfcatch>
		</cftry>
		
		<cfreturn qMultipleObjects>
		
  	</cffunction>
	

	<cffunction name="setMultiple" access="public" hint="Set a single property for multpile objects of a particular type" ouput="false" returntype="void">
		<cfargument name="tableName" required="true" type="string" />
		<cfargument name="stProps" required="true" type="struct" />
		<cfargument name="prop" type="string" required="yes">
		<cfargument name="value" type="string" required="yes">
		<cfargument name="whereclause" type="string" required="false" default="WHERE 0=1">
		
		
   		<cfset var qSetMultipleObjects = queryNew("blah") />
   		<cfset var sql = "" />
	
	
		<cfif stProps[arguments.prop].metadata.type neq 'array'>
			<cfsavecontent variable="sql">
				<cfoutput>
					UPDATE #variables.dbowner##arguments.tablename#
					SET #arguments.prop# = #arguments.value#
					#preservesinglequotes(arguments.whereclause)#
				</cfoutput>
			</cfsavecontent>
			<cftry>
				<cfquery datasource="#variables.dsn#" name="qSetMultipleObjects">
					#preserveSingleQuotes(sql)#
				</cfquery>
			
				<cfcatch>
					<cfset request.fourqSetMultipleErrorContext = cfcatch>
					<cfthrow type="farcry.core.packages.fourq.gateway.dbgateway.setmultiple" message="Query error occurred in farcry.core.packages.fourq.gateway.dbgateway.cfc setMultiple()" detail="<p>This is a dynamically generated query which can be the mother or all things to debug. Try looking at the stack trace and the sequence of templates parsed to figure out where the function was called from.</p> <p>SQL for the failed query:<br><pre>#reReplaceNoCase(sql,'[#chr(20)##chr(9)#]','','all')#</pre></p> <p>The original cfcatch scope was put into request.fourqSetMultipleErrorContext.</p>">
				</cfcatch>
			</cftry>
		<cfelse>
			<cfabort showerror="Sorry, can't use setMultiple to update array properties. use setData() instead">
		</cfif>
	</cffunction>
	
	
	<cffunction name="deployRefObjects" access="public" returntype="struct" output="false">
		<cfthrow type="fourq.dbgateway" message="Method not implemented." detail="This method has been deprecated.  Use ./packages/schema/refobjects.cfc instead." />
	</cffunction>
	
	
</cfcomponent>