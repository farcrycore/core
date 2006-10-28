<cfcomponent extends="field" name="webskin" displayname="webskin" hint="Used to liase with webskin type fields"> 
	
	<cffunction name="init" access="public" returntype="farcry.farcry_core.packages.formtools.webskin" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfparam name="arguments.stMetadata.ftPrefix" default="">
		<cfparam name="arguments.stMetadata.ftTypename" default="#arguments.typename#"><!--- The typename that the webskin is to be selected for. It defaults to the typename of the object this field is contained in. --->
	
		<cfif NOT len(arguments.stMetadata.ftTypename)>
			<cfset arguments.stMetadata.ftTypename = arguments.typename />
		</cfif>
	
		<!--- 
		<cfif directoryExists("#application.path.project#/webskin/#arguments.stMetadata.ftTypename#")>
			<cfdirectory action="list" directory="#application.path.project#/webskin/#arguments.stMetadata.ftTypename#" name="qWebskin" filter="*.cfm" >
		</cfif>
		 --->
		<cfset oType=createobject("component", application.types[arguments.stmetadata.fttypename].typepath) />
		<cfset qWebskin=oType.getWebskins(prefix=arguments.stMetadata.ftPrefix) />
		 
		<!--- This is to overcome casesensitivity issues on mac/linux machines --->
		<cfquery name="qWebskin" dbtype="query">
			SELECT *
			FROM qWebskin
			WHERE lower(qWebskin.name) LIKE '#lCase(arguments.stMetadata.ftPrefix)#%'
			AND lower(qWebskin.name) LIKE '%.cfm'
		</cfquery>

		<cfset qMethods = queryNew("methodname, displayname")>

		<cfloop query="qWebskin">
			<cfset displayname=oType.getWebskinDisplayname(typename=arguments.stmetadata.fttypename, path="#qwebskin.directory#/#qwebskin.name#") />
			
			<cfset queryAddRow(qMethods, 1)>
			<cfset querySetCell(qMethods, "methodname", listfirst(qWebskin.name, "."))>
			<cfset querySetCell(qMethods, "displayname", displayname)>
		</cfloop>

		<!--- de-dupe and reorder method list --->
		<cfquery name="qMethods" dbtype="query">
		SELECT DISTINCT methodname, displayname
		FROM qMethods
		ORDER BY DisplayName
		</cfquery>
		
		<cfsavecontent variable="html">
			<!--- Place custom code here! --->
			<cfoutput>
			<cfif isDefined("qMethods") AND qMethods.RecordCount>
				<select name="#arguments.fieldname#" id="#arguments.fieldname#">
					<cfloop query="qMethods">						
						<option value="#qMethods.methodname#" <cfif qmethods.methodname eq arguments.stMetadata.value>selected</cfif>>#qMethods.displayname#</option>
					</cfloop>
				</select>
			<cfelse>
				No Display Methods Defined
				<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="" />
			</cfif>
			
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		
		<cfsavecontent variable="html">
			<!--- Place custom code here! --->
			<cfoutput>#arguments.stMetadata.value#</cfoutput>
			
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.It consists of value and stSupporting">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = stFieldPost.Value>
		<cfset stResult.stError = StructNew()>
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->

		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

</cfcomponent>