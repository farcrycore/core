<cfcomponent displayname="coapiUtilities" output="false">
	
	<cffunction name="init" access="public" output="false" returntype="coapiUtilities">
		<cfif structKeyExists(variables, "initialised")>
			<cfthrow type="Application" detail="coapiUtilities instace already intialised">
		<cfelse>
			<cfset variables.initialised = true />
		</cfif>
		<cfset variables.stRefobjects = structNew() />
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="typeInRefObjects" access="public" output="false" returntype="boolean" hint="Returns true/false as to whether the type is to add a reference in the refObjects table">
		<cfargument name="typename" required="true" hint="The name of the type to check" />
		
		<cfset var result = true /><!--- Assume true unless specifically instructed not too. --->
		
		<cfif isDefined("application.stCoapi.#arguments.typename#.bRefObjects") AND NOT application.stCoapi[arguments.typename].bRefObjects>
			<cfset result = false />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	

	<cffunction name="createRefObjectID" access="public" output="false" returntype="boolean" hint="Ensures objectid is unique and creates a refObject reference record.">
		<cfargument name="objectid" required="true" hint="The objectID to check" />
		<cfargument name="typename" required="yes" type="string" default="#getTablename()#">	
		<cfargument name="dsn" type="string" required="false" default="">
		<cfargument name="dbtype" type="string" required="false" default="">
		<cfargument name="dbowner" type="string" required="false" default="">

		<cfset var qRefDataDupe = "" />
		<cfset var qRefData = "" />
		<cfset var qObjectDupe = "" />
		<cfset var bSuccess = true />

		<cfif not len(arguments.dsn)>
			<cfset arguments.dsn = application.dsn_write />
		</cfif>
		<cfif not len(arguments.dbtype)>
			<cfset arguments.dbtype = application.dbtype_write />
		</cfif>
		<cfif not len(arguments.dbowner)>
			<cfset arguments.dbowner = application.dbowner_write />
		</cfif>

		<!--- Need to check for existance of fapi as it will not be available during installation. --->
		<cfif not structKeyExists(application, "fapi") OR application.fapi.getContentTypeMetadata(arguments.typename,'bRefObjects',true)>

			<cftry>
				
				<cfquery datasource="#arguments.dsn#" name="qRefDataDupe">
				SELECT ObjectID FROM #arguments.dbowner#refObjects
				WHERE ObjectID = <cfqueryparam value="#arguments.objectid#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
				
				<cfif NOT qRefDataDupe.RecordCount>			
				<!--- If note in refObjects we have no problem --->
					
					<!--- create lookup ref for default type --->
					<cfquery datasource="#arguments.dsn#" name="qRefData">
						INSERT INTO #arguments.dbowner#refObjects (
							objectID, 
							typename
						)
						VALUES (
							<cfqueryparam value="#arguments.objectid#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#arguments.typename#" cfsqltype="CF_SQL_VARCHAR">
						)
					</cfquery>
				
				 
				<cfelse>
					<!--- 
						If its already in Ref Objects we have to work out if it was created during a previous Default Object Call
						We do this by seeing if the objectID exists in the actual type table. If it does, then it means it was a real objectID and we have a problem.
					--->
					<cfquery datasource="#arguments.dsn#" name="qObjectDupe">
					SELECT ObjectID FROM #arguments.dbowner##arguments.typename#
					WHERE ObjectID = <cfqueryparam value="#arguments.objectid#" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
					
					<cfif qObjectDupe.RecordCount>
						<cfset application.fapi.throw(detail="Attempting to add a duplicate refObjectID (#arguments.objectid#) for #arguments.typename#") />
					</cfif>
				
				</cfif>
				
				<cfcatch type="database">
					<!--- This simply means the refObjects table has not been deployed so .  --->
					<cfset application.fapi.throw(detail="#cfcatch.detail#") />
				</cfcatch>
				
			</cftry>
		<cfelse>
			<cfset bSuccess = true />
		</cfif>
		
		<cfreturn bSuccess />
		
	</cffunction>
		
	<cffunction name="createCopy" access="public" output="false" returntype="struct" hint="Returns a duplicated struct with any extended array properties changed to point to the new struct.">
		<cfargument name="objectid" type="uuid" required="true" />
		<cfargument name="typename" type="string" required="false" default="" />
		
		<cfset var st = structNew() />
		<cfset var iField = "" />
		<cfset var pos = "" />
		<cfset var userlogin = "anonymous" />
		<cfset var o =  ""/>
		
		<cfif not len(arguments.typename)>
			<cfset arguments.typename = findType(objectid=arguments.objectid) />
		</cfif>
		<cfif application.security.isLoggedIn()>
			<cfset userlogin = application.security.getCurrentUserID() />
		</cfif>
		
		<cfif len(arguments.typename)>
			<cfset o = createObject("component", application.stcoapi["#arguments.typename#"].packagePath) />
			<cfset st = duplicate(o.getData(objectid=arguments.objectid)) />
			<cfset st.objectid = application.fc.utils.createJavaUUID() />
			
			<cfset st.lastupdatedby = userlogin />
			<cfset st.datetimelastupdated = now() />
			<!--- // todo: not sure createdby/datetimecreated should be changed for DRAFT GB 20050126 --->
			<cfset st.createdby = userlogin />
			<cfset st.datetimecreated = Now() />
			
			
			<cfloop list="#structKeyList(st)#" index="iField">
				<cfif isArray(st[iField]) AND arrayLen(st[iField])>
					<cfloop from="1" to="#arrayLen(st[iField])#" index="pos">
						<cfif isStruct(st[iField][pos]) and structKeyExists(st[iField][pos], "objectid")>
							<cfset st[iField][pos].objectid = application.fc.utils.createJavaUUID() />
						</cfif>
						<cfif isStruct(st[iField][pos]) and structKeyExists(st[iField][pos], "parentid")>
							<cfset st[iField][pos].parentid = st.objectid />
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn st />
	
	</cffunction>
	
	
	<cffunction name="findType" access="public" output="false" returntype="string" hint="Determine the typename for an objectID.">
		<cfargument name="objectid"  required="true">
		<cfargument name="dsn" type="string" required="false" default="">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		<cfset var qFindType=queryNew("init") />
		<cfset var result = "" />

		<cfif not len(arguments.dsn)>
			<cfset arguments.dsn = application.dsn_read />
		</cfif>
		<cfif not len(arguments.dbowner)>
			<cfset arguments.dbowner = application.dbowner_read />
		</cfif>
		
		<cfif structKeyExists(variables.stRefobjects, arguments.objectid)>
			<cfset result = variables.stRefobjects[arguments.objectid] />
		<cfelse>
			
			<cfquery datasource="#arguments.dsn#" name="qFindType">
			select typename from #arguments.dbowner#refObjects
			where objectID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectID#" />
			</cfquery>
			
			<cfif qFindType.recordCount>
				<cfset result = qFindType.typename />
			<cfelse>		
				<cfif isDefined("Session") AND structKeyExists(Session, "TempObjectStore") 
					AND structKeyExists(Session.TempObjectStore, "#arguments.objectid#")
					AND structKeyExists(Session.TempObjectStore["#arguments.objectid#"], "typename")>
					
					<cfset result = Session.TempObjectStore["#arguments.objectid#"].typename />
				</cfif>
			</cfif>	
			
			<cfif len(result)>
				<cfset variables.stRefobjects[arguments.objectid] = result />
			</cfif>
			
		</cfif>
		
		<cfreturn result />	
	</cffunction>
	
	<cffunction name="loadPlugin" access="public" output="false" returntype="void" hint="Loads a plugin; makes plugin active for application">
		<cfthrow message="loadPlugin() has not been implemented." />
	</cffunction>
	
	<cffunction name="unloadPlugin" access="public" output="false" returntype="void" hint="Unloads a plugin; makes plugin inactive for application">
		<cfargument name="plugin" required="true" type="string" hint="Name of the plugin to remove." />
		<cfset var pos = listFind(application.plugins, arguments.plugin) />
		<cfset listdeleteat(application.plugins, pos) />
	</cffunction>

	<cffunction name="getRelatedContent" access="public" output="false" returntype="query" hint="Returns a query containing all the objects related to the objectid passed in.">
		<cfargument name="objectid" type="uuID" required="true" hint="The object for which related objects are to be found" />
		<cfargument name="typename" type="string" required="false" default="" hint="The typename of the objectid. Pass in to avoid having to lookup the type." />
		<cfargument name="filter" type="string" required="false" default="" hint="The typename of related objects to find. Empty for ALL typenames." />
		<cfargument name="arrayType" type="string" required="false" default="" hint="The typename containing the property that defines the relationship we are looking for" />
		<cfargument name="arrayProperty" type="string" required="false" default="" hint="The property that defines the relationship we are looking for" />
				
		<cfset var iType = "" />
		<cfset var iProp = "" />
		<cfset var q = queryNew("objectid,typename") />
		<cfset var qRelatedContent = queryNew("objectid,typename") />
		
		<!--- IF THE TYPENAME HAS NOT BEEN PASSED, FIND IT --->
		<cfif not len(arguments.typename)>
			<cfset arguments.typename = application.coapi.coapiutilities.findType(objectid="#arguments.objectid#") />
		</cfif>
		
		<!--- MAKE SURE WE FOUND THE TYPENAME --->
		<cfif not len(arguments.typename)>
			<cfthrow message="Could not find the object #arguments.objectid#" />
		</cfif>
			
			
		<!--- MAKE SURE THEY HAVE PASSED A VALID filter --->
		<cfif len(arguments.filter) AND NOT structKeyExists(application.stcoapi, arguments.filter)>
			<cfthrow message="The content type #arguments.filter# does not exist" />
		</cfif>
		
		<!--- IF THEY WAN A SPECIFIC RELATIONSHIP --->
		<cfif len(arguments.arrayProperty)>
		
			<!--- MAKE SURE THEY TYPE FOR THAT PROPERTY IS DEFINED AND IF NOT, DEFAULT TO THE CURRENT TYPENAME --->
			<cfif not len(arguments.arrayType)>
				<cfset arguments.arrayType = arguments.typename />
			</cfif>
			
			<!--- MAKE SURE THAT TYPE EXISTS --->
			<cfif NOT structKeyExists(application.stcoapi, arguments.arrayType)>
				<cfthrow message="The content type #arguments.arrayType# does not exist" />
			</cfif>
			
			<!--- MAKE SURE THE PROPERTY EXISTS IN THAT TYPE --->
			<cfif NOT structKeyExists(application.stcoapi[arguments.arrayType].stprops, arguments.arrayProperty)>
				<cfthrow message="The property #arguments.arrayProperty# does not exist in the content type #arguments.arrayType#" />
			</cfif>
			
		</cfif>
		
		
		<!--- MANUALLY SET THE TYPE WE ARE CURRENTLY LOOKING AT --->
		<cfset iType = arguments.typename />
	
		<!--- IF WE ARE ONLY LOOKING FOR A PARTICULAR RELATIONSHIP, CHECK IT HERE --->
		<cfif not len(arguments.arrayType) OR arguments.arrayType EQ iType>
			<!--- LOOP THROUGH PROPERTIES IN THE CURRENT TYPENAME LOOKING FOR RELATED CONTENT --->
			<cfloop collection="#application.stcoapi[arguments.typename].stprops#" item="iProp">		
				<!--- IGNORE OBJECTID PROPERTY --->
				<cfif iProp NEQ "objectid">					
					<!--- IF WE ARE ONLY LOOKING AT RELATIONSHIPS DEFINED BY A SINGLE PROPERTY, ONLY LOOK AT THAT PROPERTY --->
					<cfif not len(arguments.arrayProperty) OR listFindNoCase(arguments.arrayProperty, iProp)>					
						<!--- MAKE SURE THAT THE PROPERTY HAS FTJOIN METADATA --->
						<cfif structKeyExists(application.stcoapi[iType].stprops[iProp].metadata, "ftJoin")>
							<!--- IF WE ARE ONLY LOOKING FOR REALTED CONTENT OF A SPECIFIC TYPE, MAKE SURE THIS PROPERTY HAS THAT TYPE RELATED --->
							<cfif not len(arguments.filter) OR listFindNoCase(application.stcoapi[iType].stprops[iProp].metadata.ftJoin, arguments.filter) GT 0 OR (structKeyExists(application.stcoapi[iType], "buseintree") and application.stcoapi[iType].buseintree)>							
								<cfset q = queryNew("objectid,typename") />						
								
								<!--- IF THE PROPERTY IS AN ARRAY, LOOK IN THIS OBJECTS ARRAY TABLE FOR RELATED CONTENT --->
								<cfif application.stcoapi[iType].stprops[iProp].metadata.Type EQ "array">
									<cfquery datasource="#application.dsn_read#" name="q">
									SELECT data as objectID, typename
									FROM #iType#_#iProp#
									WHERE parentID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
									<cfif len(arguments.filter)>
										AND typename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filter#" />
									</cfif>
									ORDER BY seq
									</cfquery>
								</cfif>
		
								<!--- IF THE PROPERTY IS A UUID, LOOK IN THIS OBJECTS PROPERTY FOR RELATED CONTENT --->
								<cfif application.stcoapi[iType].stprops[iProp].metadata.Type EQ "uuid">
									<cfquery datasource="#application.dsn_read#" name="q">
									SELECT #iProp# as objectID, refObjects.typename AS typename
									FROM #iType# INNER JOIN refObjects
									ON #iType#.#iProp#=refObjects.objectid
									WHERE #iType#.objectid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
									AND #iProp# <> ''
									AND #iProp# is not null									
									<cfif len(arguments.filter)>
										AND refObjects.typename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filter#" />
									</cfif>
									</cfquery>
								</cfif>	
								
								<!--- APPEND ANY RESULTS TO THE RETURN QUERY --->
								<cfif q.recordCount>
									<cfif qRelatedContent.recordCount>
										<cftry>
										<cfquery dbtype="query" name="qRelatedContent">
										SELECT objectid,typename FROM qRelatedContent
										UNION
										SELECT objectid,typename FROM q
										</cfquery>
										<cfcatch type="any">
											<cfdump var="#qRelatedContent#" expand="false" label="qRelatedContent" />
											<cfdump var="#q#" expand="false" label="q" />
											<cfabort showerror="debugging" />
										</cfcatch>
										</cftry>
									<cfelse>
										<cfset qRelatedContent = duplicate(q) />
									</cfif>
								</cfif>
							</cfif>
						</cfif>					
					</cfif>
				</cfif>
			</cfloop>		
		</cfif>				
	
		<!--- LOOP THROUGHT THE REST OF OUR APPLICATION --->
		<cfloop collection="#application.stcoapi#" item="iType">
			
			<!--- IF WE ARE ONLY LOOKING FOR A PARTICULAR RELATIONSHIP, CHECK IT HERE --->
			<cfif not len(arguments.arrayType) OR arguments.arrayType EQ iType>			
				<!--- IGNORE OUR BASE CONTENT TYPE. THIS WAS HANDLED ABOVE --->
				<cfif iType NEQ arguments.typename>
				
					<!--- IF WE ARE ONLY LOOKING AT RELATIONSHIPS TO A SINGLE TYPENAME, ONLY LOOK AT THAT TYPENAME --->
					<cfif not len(arguments.filter) OR listFindNoCase(arguments.filter, iType)>
						
						<!--- LOOP THROUGH PROPERTIES IN THE CURRENT TYPENAME LOOKING FOR RELATED CONTENT --->
						<cfloop collection="#application.stcoapi[iType].stprops#" item="iProp">
							
							<!--- IGNORE OBJECTID PROPERTY --->
							<cfif iProp NEQ "objectid">
							
								<!--- IF WE ARE ONLY LOOKING AT RELATIONSHIPS DEFINED BY A SINGLE PROPERTY, ONLY LOOK AT THAT PROPERTY --->
								<cfif not len(arguments.arrayProperty) OR listFindNoCase(arguments.arrayProperty, iProp)>
								
									<cfset q = queryNew("objectid,typename") />
						
									<!--- MAKE SURE THAT THIS PROPERTY POTENTIALLY RELATES TO OUR OBJECT --->	
									<cfif (structKeyExists(application.stcoapi[iType].stprops[iProp].metadata, "ftJoin") AND listFindNoCase(application.stcoapi[iType].stprops[iProp].metadata.ftJoin, arguments.typename) )>
						
										<!--- IF THE PROPERTY IS AN ARRAY, LOOK IN THIS CONTENT TYPES ARRAY TABLE FOR RELATED CONTENT --->
										<cfif application.stcoapi[iType].stprops[iProp].metadata.Type EQ "array">
											<cfquery datasource="#application.dsn_read#" name="q">
											SELECT parentID as objectID, '#iType#' AS typename
											FROM #iType#_#iProp#
											WHERE data = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
											</cfquery>
										</cfif>
										
										<!--- IF THE PROPERTY IS A UUID, LOOK IN THIS CONTENT TYPES PROPERTY FOR RELATED CONTENT --->
										<cfif application.stcoapi[iType].stprops[iProp].metadata.Type EQ "uuid">
											<cfquery datasource="#application.dsn_read#" name="q">
											SELECT objectID, '#iType#' AS typename
											FROM #iType#
											WHERE #iProp# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
											</cfquery>
										</cfif>
									</cfif>
															
									<!--- APPEND ANY RESULTS TO THE RETURN QUERY --->
									<cfif q.recordCount>
										<cfif qRelatedContent.recordCount>
											<cfquery dbtype="query" name="qRelatedContent">
											SELECT objectid,typename FROM qRelatedContent
											UNION
											SELECT objectid,typename FROM q
											</cfquery>									
										<cfelse>
											<cfset qRelatedContent = duplicate(q) />
										</cfif>
									</cfif>
									
									
								</cfif>
							</cfif>
						</cfloop>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		
		<!--- SORT OUR CONTENT --->
		<cfif qRelatedContent.recordCount>
			<cfquery dbtype="query" name="qRelatedContent">
			SELECT objectid,typename FROM qRelatedContent
			ORDER BY typename
			</cfquery>
		</cfif>	
		
		<cfreturn qRelatedContent />	
		
		
	</cffunction>
		
	<cffunction name="getContentObject" access="public" output="false" returnType="struct" hint="Allows you to fetch a content object with only the objectID">
		<cfargument name="objectid" type="UUID" required="true" hint="The object for which object is to be found" />
		<cfargument name="typename" type="string" required="false" default="" hint="The typename of the objectid. Pass in to avoid having to lookup the type." />
		
		<cfset var stResult = structNew() />
		<cfset var oCO = structNew() />
		
		<cfif not len(arguments.typename)>
			<cfset arguments.typename = findType(argumentCollection="#arguments#") />
		</cfif>
		
		<cfif len(arguments.typename)>
			<!--- Just in case the whole package path has been passed in, we only need the actual typename --->
			<cfset arguments.typename = listLast(arguments.typename,".") />
		
			<cfset oCO  = createObject("component", application.stcoapi[arguments.typename].packagePath) />
			<cfset stResult = oCO.getData(argumentCollection="#arguments#") />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>

</cfcomponent>