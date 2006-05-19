

<cfcomponent extends="field" name="UUID" displayname="UUID" hint="Field component to liase with all UUID types"> 

	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObj" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

	
		<cfsavecontent variable="html">
			<cfoutput><input type="Text" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" <cfif structKeyExists(arguments.stMetadata,'ftStyle')>style="#arguments.stMetadata.ftstyle#"</cfif> /></cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObj" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

	
		<cfsavecontent variable="html">
			
			<cfif isDefined("arguments.stMetadata.ftLink") AND len(arguments.stMetadata.ftLink)>
				<cfset oType = createObject("component",application.types["#arguments.stMetadata.ftLink#"].typepath)>
				
				<cfif isDefined("arguments.stMetadata.ftLinkDisplayMethod") AND len(arguments.stMetadata.ftLinkDisplayMethod) AND structKeyExists(oType,"#arguments.stMetadata.ftLinkDisplayMethod#") AND len(arguments.stMetadata.value)>
					
					<cfinvoke component="#oType#" method="#arguments.stMetadata.ftLinkDisplayMethod#" returnvariable="returnHTML">
						<cfinvokeargument name="objectid" value="#arguments.stMetadata.value#">
					</cfinvoke>					
					
					<cfoutput>#returnHTML#</cfoutput>
					
				<cfelse>
					<cfoutput>#arguments.stMetadata.value#</cfoutput>
				</cfif>
			<cfelse>
				<cfoutput>#arguments.stMetadata.value#</cfoutput>
			</cfif>

		</cfsavecontent>
	
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = "">
		<cfset stResult.stError = StructNew()>
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<cfset stResult.value = stFieldPost.Value>
		
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

</cfcomponent> 