<cfcomponent displayname="coapiUtilities" output="false">
	
	<cffunction name="init" access="public" output="false" returntype="coapiUtilities">
		<cfif structKeyExists(variables, "initialised")>
			<cfthrow type="Application" detail="coapiUtilities instace already intialised">
		<cfelse>
			<cfset variables.initialised = true />
		</cfif>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="createCopy" access="public" output="false" returntype="struct" hint="Returns a duplicated struct with any extended array properties changed to point to the new struct.">
		<cfargument name="objectid" type="uuid" required="true" default="#application.dsn#" />
		<cfargument name="typename" type="string" required="false" default="" />
		
		<cfset var st = structNew() />
		<cfset var iField = "" />
		<cfset var pos = "" />
		<cfset var userlogin = "anonymous" />
		<cfset var o =  ""/>
		
		<cfif not len(arguments.typename)>
			<cfset arguments.typename = findType(objectid=arguments.objectid) />
		</cfif>
		<cfif isDefined("session.dmSec.authentication.userlogin")>
			<cfset userlogin = session.dmSec.authentication.userlogin />
		</cfif>
		
		<cfif len(arguments.typename)>
			<cfset o = createObject("component", application.stcoapi["#arguments.typename#"].packagePath) />
			<cfset st = duplicate(o.getData(objectid=arguments.objectid)) />
			<cfset st.objectid = createUUID() />
			
			<cfset st.lastupdatedby = userlogin />
			<cfset st.datetimelastupdated = now() />
			<!--- // todo: not sure createdby/datetimecreated should be changed for DRAFT GB 20050126 --->
			<cfset st.createdby = userlogin />
			<cfset st.datetimecreated = Now() />
			
			
			<cfloop list="#structKeyList(st)#" index="iField">
				<cfif isArray(st[iField]) AND arrayLen(st[iField])>
					<cfloop from="1" to="#arrayLen(st[iField])#" index="pos">
						<cfif isStruct(st[iField][pos]) and structKeyExists(st[iField][pos], "objectid")>
							<cfset st[iField][pos].objectid = createUUID() />
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
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		<cfset var qFindType = queryNew("blah") />

		<cfquery datasource="#arguments.dsn#" name="qFindType">
		select typename from #arguments.dbowner#refObjects
		where objectID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectID#" />
		</cfquery>
				
		<!--- 
		$ TODO: resolve upstream errors
		<cfif NOT qgetType.recordCount>
			<cfthrow type="fourq" detail="<b>Invalid reference:</b> object #arguments.objectID# is not in refObjects table">
		</cfif> 
		$
		--->

		<cfreturn qFindType.typename>
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
		<cfset var iProperty = "" />
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
							<cfif not len(arguments.filter) OR listFindNoCase(application.stcoapi[iType].stprops[iProp].metadata.ftJoin, arguments.filter)>
								<cfset q = queryNew("objectid,typename") />						
								
								<!--- IF THE PROPERTY IS AN ARRAY, LOOK IN THIS OBJECTS ARRAY TABLE FOR RELATED CONTENT --->
								<cfif application.stcoapi[iType].stprops[iProp].metadata.Type EQ "array">
									<cfquery datasource="#application.dsn#" name="q">
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
									<cfquery datasource="#application.dsn#" name="q">
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
											<cfquery datasource="#application.dsn#" name="q">
											SELECT parentID as objectID, '#iType#' AS typename
											FROM #iType#_#iProp#
											WHERE data = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
											</cfquery>
										</cfif>
										
										<!--- IF THE PROPERTY IS A UUID, LOOK IN THIS CONTENT TYPES PROPERTY FOR RELATED CONTENT --->
										<cfif application.stcoapi[iType].stprops[iProp].metadata.Type EQ "uuid">
											<cfquery datasource="#application.dsn#" name="q">
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
		
</cfcomponent>