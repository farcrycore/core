<cfcomponent displayname="Content Type Filter" output="false" extends="farcry.core.packages.types.types" hint="Allows storage of a property filters that can then be used to generate a query of objectids that can be used to filter a recordset" bRefObjects="false" bSystem="true">

	<cfproperty name="title" type="string" hint="The Title"
		ftSeq="" ftWizardStep="" ftFieldset=""
		ftLabel="Filter Name"  />
		
	<cfproperty name="listID" type="string" hint="The id"
		ftSeq="" ftWizardStep="" ftFieldset=""
		ftLabel="ID"  />
		
	<cfproperty name="profileID" type="uuid" hint="The profileID"
		ftSeq="" ftWizardStep="" ftFieldset=""
		ftLabel="Profile"
		ftType="UUID" ftJoin="dmProfile"  />
		
	<cfproperty name="filterTypename" type="string" hint="The typename"
		ftSeq="" ftWizardStep="" ftFieldset=""
		ftLabel="Typename"  />
		
	<cfproperty name="lRoles" type="string" hint="The typename"
		ftSeq="" ftWizardStep="" ftFieldset=""
		ftLabel="Roles"
		ftType="list"
		ftListData="getAllRoles"
		ftListDataTypename="farFilter"
		ftSelectMultiple="true"  />
	
	
	
	<cffunction name="getAllRoles" access="public" output="false" hint="Returns the roles that can access this filter.">
	
		<cfset var qRoles = "" />
		
		<cfquery datasource="#application.dsn#" name="qRoles">
			select		objectid as value,title as name
			from		#application.dbowner#farRole
			order by	title
		</cfquery>
		
		<cfreturn qRoles />
	</cffunction>
		
		
	<cffunction name="getFilterSQLWhereClause" returntype="String" hint="Returns the sql where clause for the filter ID or array of filter props passed in. It does not include the 'WHERE' so it can be used as required.">
		<cfargument name="typename" required="true" />
		<cfargument name="filterID" required="false" default="" />
		<cfargument name="aProperties" required="false" default="#arrayNew(1)#" />
		
		<cfset var stFilter = "" />
		<cfset var aProps = arrayNew(1) />
		<cfset var bFirstClause = true />
		<cfset var formtool = "" />
		<cfset var whereClause = "" />
		<cfset var oFormtool = "" />
		<cfset var stProp = "" />
		<cfset var stProps = "" />
		<cfset var sqlResult = "" />
		<cfset var qProperties	= '' />
		<cfset var ftType	= '' />
		<cfset var i	= '' />

		<cfif len(arguments.filterID)>
			<cfset stFilter = getData(arguments.filterID) />
			
			<cfset qProperties = getFilterProperties(arguments.filterID) />		
			
			<cfloop query="qProperties">
				<cfset stProp = structNew() />
				<cfset stProp.name = qProperties.property />
				<cfset stProp.type = qProperties.type />
				<cfif isWDDX(qProperties.wddxDefinition)>
				
					<cfwddx	action="wddx2cfml" 
								input="#qProperties.wddxDefinition#" 
								output="stPropData" />
					<cfset stProp.stProps = stPropData />		
				</cfif>		
				<cfset arrayAppend(aProps, duplicate(stProp)) />
			</cfloop>	
		</cfif>
		
		<cfloop from="1" to="#arrayLen(arguments.aProperties)#" index="i">
			<cfset arrayAppend(aProps, arguments.aProperties[i]) />
		</cfloop>	

		<cfsavecontent variable="sqlResult">
			<cfloop from="1" to="#arrayLen(aProps)#" index="i">
				
				<cfif len(aProps[i].name)>
					
					<!--- Which formtool does this property use? --->
					<cfset ftType = application.fapi.getPropertyMetadata(
															typename="#arguments.typename#", 
															property="#aProps[i].name#", 
															md="ftType", 
															default="field") />

					<!--- Get the appropriate SQL for that formtool --->
					<cfset whereClause = application.fapi.getFormtool(ftType).getFilterSQL(
														filterTypename="#arguments.typename#",
														filterProperty="#aProps[i].name#",
														filterType="#aProps[i].type#",
														stFilterProps="#aProps[i].stProps#"
														)>
					
					<!--- Add the returned sql to the final sql where clause result --->
					<cfif len(trim(whereClause))>
						<cfif bFirstClause>
							<cfset bFirstClause = false />
						<cfelse>
							<cfoutput>AND</cfoutput>
						</cfif>
						
						<cfoutput> #whereClause# </cfoutput>
					</cfif>	
				</cfif>	
			</cfloop>
		</cfsavecontent>


		<cfreturn sqlResult />		
	</cffunction>
				
	<cffunction name="getFilterSQLString" returntype="String" hint="Returns the sql where clause summary for the filter ID or array of filter props passed in. It does not include the 'WHERE' so it can be used as required.">
		<cfargument name="filterID" required="false" default="" />
		<cfargument name="typename" required="false" default="" />
		<cfargument name="aProperties" required="false" default="#arrayNew(1)#" />
		
		<cfset var stFilter = "" />
		<cfset var aProps = arrayNew(1) />
		<cfset var bFirstClause = true />
		<cfset var formtool = "" />
		<cfset var whereClause = "" />
		<cfset var oFormtool = "" />
		<cfset var stProp = "" />
		<cfset var stProps = "" />
		<cfset var sqlResult = "" />
		<cfset var qProperties	= '' />
		<cfset var ftLabel	= '' />
		<cfset var i	= '' />

		<cfif len(arguments.filterID)>
			<cfset stFilter = getData(arguments.filterID) />
			
			<cfset qProperties = getFilterProperties(arguments.filterID) />		
			
			<cfloop query="qProperties">
				<cfset stProp = structNew() />
				<cfset stProp.name = qProperties.property />
				<cfset stProp.type = qProperties.type />
				<cfif isWDDX(qProperties.wddxDefinition)>
				
					<cfwddx	action="wddx2cfml" 
								input="#qProperties.wddxDefinition#" 
								output="stPropData" />
					<cfset stProp.stProps = stPropData />		
				</cfif>		
				
				<cfset arrayAppend(aProps, duplicate(stProp)) />
			</cfloop>	
		</cfif>
		
		<cfloop from="1" to="#arrayLen(arguments.aProperties)#" index="i">
			<cfset arrayAppend(aProps, arguments.aProperties[i]) />
		</cfloop>	

		<cfsavecontent variable="sqlResult">
		
			<cfloop from="1" to="#arrayLen(aProps)#" index="i">
				
				<cfif len(aProps[i].name)>
					
					<!--- Which formtool does this property use? --->
					<cfset formtool = application.fapi.getPropertyMetadata(
															typename="#arguments.typename#", 
															property="#aProps[i].name#", 
															md="ftType", 
															default="field") />
	
					<!--- Get the appropriate SQL for that formtool --->
					

					<cfset whereClause = application.fapi.getFormtool(formtool).displayFilterUI(
														filterTypename="#arguments.typename#", 
														filterProperty="#aProps[i].name#",
														filterType="#aProps[i].type#",
														stFilterProps="#aProps[i].stProps#"
														)>													
			
					<!--- Add the returned sql to the final sql where clause result --->
					<cfif len(trim(whereClause))>
						<cfif bFirstClause>
							<cfset bFirstClause = false />
						<cfelse>
							<cfoutput> ; </cfoutput>
						</cfif>
						
						<!--- What is the properties label? --->
						<cfset ftLabel = application.fapi.getPropertyMetadata(
															typename="#arguments.typename#", 
															property="#aProps[i].name#", 
															md="ftLabel", 
															default="#aProps[i].name#") />
															
						<cfoutput><b>#ftLabel#</b> #aProps[i].type# #whereClause# </cfoutput>
					</cfif>	
				</cfif>
			</cfloop>
		</cfsavecontent>

		<cfreturn sqlResult />		
	</cffunction>
	
	<cffunction name="getFilterProperties" returntype="query" hint="Returns a query containing the filter properties for the filter ID passed in.">
		<cfargument name="filterID" required="true" />
		
		<cfset var qProperties = "" />
		
		<cfquery datasource="#application.dsn#" name="qProperties">
		SELECT *
		FROM farFilterProperty
		WHERE filterID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filterID#" />
		ORDER BY datetimecreated
		</cfquery>
		
		<cfreturn qProperties />
	</cffunction>
		
		
	<cffunction name="getFilters">
		<cfargument name="listID" />
		<cfargument name="typename" required="false" default="" />
		<cfargument name="profileID" required="false" default="" />
		
		<cfset var qFilters = "" />
		
		<cfquery datasource="#application.dsn#" name="qFilters">
		SELECT *
		FROM farFilter
		WHERE 1=1
		<cfif len(arguments.listID)>
			AND listID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.listID#" />
		</cfif>
		<cfif len(arguments.typename)>
			AND filterTypename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.typename#" />
		</cfif>
		<cfif len(arguments.profileID)>
			AND profileID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.profileID#" />
		</cfif>
		ORDER BY datetimecreated
		</cfquery>
				
		<cfreturn qFilters />
		
	</cffunction>
</cfcomponent>