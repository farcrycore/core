

<cfcomponent extends="field" name="selectTable" displayname="selectTable" hint="Field component to liase with all string types"> 

	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObj" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfparam name="arguments.stMetadata.ftSelectTable" default="true">
		<cfparam name="arguments.stMetadata.ftSelectTableField" default="">
		
		
		<cfif stMetadata.ftIncludeDecimal>
			<cfset arguments.stMetadata.value = DecimalFormat(arguments.stMetadata.value)>
		<cfelse>
			<cfset arguments.stMetadata.value = NumberFormat(arguments.stMetadata.value)>
		</cfif>
		
		<cfsavecontent variable="html">
			<cfoutput>
				<cfdump var="#arguments#">
				<input type="Text" name="#arguments.fieldname#" id="#arguments.fieldname#" value="HERE#arguments.stMetadata.ftCurrencySymbol##arguments.stMetadata.value#" <cfif structKeyExists(arguments.stMetadata,'ftStyle')>style="#arguments.stMetadata.ftstyle#"</cfif> /></cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObj" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfparam name="stMetadata.ftIncludeDecimal" default="true">
		<cfparam name="stMetadata.ftCurrencySymbol" default="">
		
		<cfif NOT stMetadata.ftIncludeDecimal>
			<cfset arguments.stMetadata.value = NumberFormat(arguments.stMetadata.value)>
		</cfif>
		
		<cfsavecontent variable="html">
			<cfoutput>#stMetadata.ftCurrencySymbol##arguments.stMetadata.value#</cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = "#stFieldPost.Value#">
		<cfset stResult.stError = StructNew()>
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<cfset stResult.value = ReplaceNoCase(stResult.value, ",","","all")>
		
		<cfif isDefined("arguments.stMetadata.ftCurrencySymbol") AND len(arguments.stMetadata.ftCurrencySymbol)>
			<cfset stResult.value = ReplaceNoCase(stResult.value, arguments.stMetadata.ftCurrencySymbol, "","all")>
		</cfif>
		
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

</cfcomponent> 

<!--- 
<cfswitch expression="#Attributes.Format#">
	<cfcase value="edit">
		<cfquery datasource="#application.dsn#" name="qObjects">
		SELECT ObjectID, #attributes.SelectTableField#
		FROM #attributes.SelectTable#
		ORDER BY #attributes.SelectTableField#
		</cfquery>
		
		<cfif qObjects.RecordCount>
			<cfoutput>
			<select  name="#attributes.name#" id="#attributes.name#" style="#attributes.style#">
				<cfloop query="qObjects">
					<option value="#qObjects.ObjectID#" <cfif qObjects.ObjectID EQ attributes.value>selected</cfif>>#Evaluate("qObjects.#attributes.SelectTableField#")#</option>
				</cfloop>
			</select>
			</cfoutput>
		</cfif>
	</cfcase>
	
	<cfdefaultcase>
		<cfquery datasource="#application.dsn#" name="qObjects">
		SELECT ObjectID, #attributes.SelectTableField#
		FROM #attributes.SelectTable#
		WHERE ObjectID = '#attributes.value#'
		</cfquery>
		
		<cfif qObjects.RecordCount>
			<cfoutput>#Evaluate("qObjects.#attributes.SelectTableField#")#</cfoutput>
		</cfif>
	</cfdefaultcase>
</cfswitch>
 --->