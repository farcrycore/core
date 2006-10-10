<cfcomponent extends="field" name="boolean" displayname="boolean" hint="Used to liase with boolean type fields"> 
		
	<cffunction name="init" access="public" returntype="farcry.farcry_core.packages.formtools.boolean" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>

	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
	
		<cfparam name="arguments.stMetadata.ftclass" default="">
		<cfparam name="arguments.stMetadata.ftstyle" default="">
		
		<cfsavecontent variable="html">
			<cfoutput>
				<input type="checkbox" name="#arguments.fieldname#" id="#arguments.fieldname#" value="1" class="formcheckbox #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" <cfif arguments.stMetadata.value EQ 1>checked</cfif> />
				<input type="hidden" name="#arguments.fieldname#" value="0" />
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
			<cfoutput>#YesNoFormat(arguments.stMetadata.value)#</cfoutput>
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
		<cfset stResult.value = ListFirst(stFieldPost.Value)>
		
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

</cfcomponent> 
