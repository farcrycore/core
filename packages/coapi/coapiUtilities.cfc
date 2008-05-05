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

</cfcomponent>