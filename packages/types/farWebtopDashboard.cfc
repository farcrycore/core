<cfcomponent extends="farcry.core.packages.types.types" displayname="Webtop Dashboard Configuration">

	<cfproperty name="title" type="string" required="no" default="" 
		ftSeq="1" ftFieldset="General Details" 
		ftLabel="Title" />

	<cfproperty name="aRoles" type="array" required="No" default=""
		ftSeq="2" ftFieldset="General Details" 
		ftLabel="Roles"
		ftHint="Select the security roles that will be permitted to see this webtop dashboard"
		ftJoin="farRole" />

	<cfproperty name="lCards" type="longchar" required="no" default="" 
		ftSeq="3" ftFieldset="General Details" 
		ftLabel="Cards" ftValidation="required"
		ftHint="The cards that will be displayed on this webtop dashboard" />

	<cfproperty name="lRoles" type="longchar" default="" hint="The roles this dashbaord is secured by (list generated automatically)" 
		ftLabel="Roles" ftType="arrayList" ftArrayField="aRoles" ftJoin="farRole" />


	<cffunction name="ftEditLCards">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var resultHTML = "">
		<cfset var lWebskins = "">
		<cfset var iTypename = "">
		<cfset var iWebskin = "">
		<cfset var qWebskins = "">
		<cfset var qDashboardCardWebskins = "">

		<cfloop collection="#application.stCoapi#" item="iTypename">
			<cfset qWebskins = application.stcoapi[iTypename].qWebskins />

			<cfquery dbtype="query" name="qDashboardCardWebskins">
			SELECT * FROM qWebskins
			WHERE lower(qWebskins.name) LIKE 'webtopdashboard%'
			</cfquery>

			<cfoutput query="qDashboardCardWebskins">
				<cfset lWebskins = listAppend(lWebskins, "#iTypename#:#qDashboardCardWebskins.methodName#")>
			</cfoutput>
		</cfloop>

		<cfsavecontent variable="resultHTML">		
			<cfoutput><select id="#arguments.fieldname#" name="#arguments.fieldname#" class="selectInput #arguments.stMetadata.ftClass#" style="#arguments.stMetadata.ftStyle#" multiple="multiple"></cfoutput>

			<cfloop list="#lWebskins#" index="iWebskin">

				<cfoutput><option value="#iWebskin#"<cfif listFindNoCase(arguments.stMetadata.value, iWebskin)> selected="selected"</cfif>>#iWebskin#</option></cfoutput>

			</cfloop>

			<cfoutput></select><input type="hidden" name="#arguments.fieldname#" value=""></cfoutput>
		</cfsavecontent>

		<cfreturn resultHTML />
	</cffunction>


	<cffunction name="getPermittedWebtopDashboards">
		<cfset var qWebtopDashboards = queryNew("objectid")>
		<cfset var lCurrentRoles = application.security.getCurrentRoles() />

		<cftry>
			<cfif len(lCurrentRoles)>
				<cfquery datasource="#application.dsn#" name="qWebtopDashboards">
				SELECT *
				FROM farWebtopDashboard
				WHERE objectid IN (
					SELECT parentID
					FROM farWebtopDashboard_aRoles
					WHERE data IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lCurrentRoles#">)
				)
				</cfquery>
			</cfif>
			<cfcatch type="any">
			</cfcatch>
		</cftry>

		<cfreturn qWebtopDashboards>
	</cffunction>

	<cffunction name="hasDashboards">
		<cfset var qWebtopDashboards = queryNew("objectid")>
		<cfset var result = 0>

		<cftry>
			<cfquery datasource="#application.dsn#" name="qWebtopDashboards">
			SELECT count(objectid) as counter
			FROM farWebtopDashboard
			</cfquery>
			<cfif qWebtopDashboards.counter GT 0>
				<cfset result = 1>
			</cfif>
			<cfcatch type="any">
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>

	<cffunction name="dynamicMenu" access="public" output="false" returntype="struct">

		<cfset var stResult = structnew() />
		<cfset var thisitem = "" />
		<cfset var id = "" />
		<cfset var qWebtopDashboards = application.fapi.getContentType("farWebtopDashboard").getPermittedWebtopDashboards() />

		<cfset stResult.children = structnew() />

		<cfif qWebtopDashboards.recordcount>

			<cfloop query="qWebtopDashboards">
				<cfset id = qWebtopDashboards.objectid />

				<cfset stResult.children[id] = structnew() />
				<cfset stResult.children[id].type = "subsection" />
				<cfset stResult.children[id].mergetype = "" />
				<cfset stResult.children[id].sequence = "0" />
				<cfset stResult.children[id].containermanagement = "" />
				<cfset stResult.children[id].icon = "" />
				<cfset stResult.children[id].label = qWebtopDashboards.title />
				<cfset stResult.children[id].rbkey = "dashboard.#id#" />
				<cfset stResult.children[id].children = structnew() />
				<cfset stResult.children[id].id = id />
				<cfset stResult.children[id].labelType = "" />
				<cfset stResult.children[id].relatedType = "" />
				<cfset stResult.children[id].typename = "farWebtopDashboard" />
				<cfset stResult.children[id].bodyView = "webtopBody" />
			</cfloop>

		<cfelse>
			<cfset id = 'Overview' />

			<cfset stResult.children[id] = structnew() />
			<cfset stResult.children[id].type = "subsection" />
			<cfset stResult.children[id].mergetype = "" />
			<cfset stResult.children[id].sequence = "0" />
			<cfset stResult.children[id].containermanagement = "" />
			<cfset stResult.children[id].icon = "" />
			<cfset stResult.children[id].label = "Overview" />
			<cfset stResult.children[id].rbkey = "dashboard.#id#" />
			<cfset stResult.children[id].children = structnew() />
			<cfset stResult.children[id].id = id />
			<cfset stResult.children[id].labelType = "" />
			<cfset stResult.children[id].relatedType = "" />
			<cfset stResult.children[id].typename = "farWebtopDashboard" />
			<cfset stResult.children[id].bodyView = "webtopBody" />
		</cfif>
		<cfreturn stResult />
	</cffunction>


</cfcomponent>