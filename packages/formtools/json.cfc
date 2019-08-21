

<cfcomponent extends="longchar" name="json" displayname="json" hint="Field component to liase with all json types"> 
	
	<cffunction name="init" access="public" returntype="any" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>

	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="inputClass" required="false" type="string" default="" hint="This is the class value that will be applied to the input field.">

		<cfset var html = "" />
		<cfset var bfieldvisible = 0 />
		<cfset var fieldvisibletoggletext = "show..." />
		<cfset var fieldstyle = "" />
		<cfset var onkeyup = "" />
		<cfset var onkeydown = "" /> 
		<cfset var bIsGoodBrowser = "" />
		
		<cfparam name="arguments.stMetadata.ftStyle" default="">
		<cfparam name="arguments.stMetadata.ftLimit" default="0">
		<cfparam name="arguments.stMetadata.ftLimitOverage" default="truncate">
		<cfparam name="arguments.stMetadata.ftLimitWarning" default="You have exceeded the maximum number of characters">
		<cfparam name="arguments.stMetadata.ftLimitMin" default="">
	

	
		<cfset var stValue = {} />

		<cfif isJSON(arguments.stMetadata.value)>
			<cfset stValue = deserializeJSON(arguments.stMetadata.value) />
		</cfif>
		<cfparam name="stValue.jsonData" default="#structNew()#" />



		<cfsavecontent variable="html">
				
			<cfoutput>
				<input id="#arguments.fieldname#" name="#arguments.fieldname#" type="hidden" value="">
				<div class="multiField">
					<div id="#arguments.fieldname#DIV" style="#fieldStyle#;">
						<div class="blockLabel">
							<textarea name="#arguments.fieldname#jsonData" id="#arguments.fieldname#jsonData" class="textareaInput #arguments.inputClass# #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" placeholder="#arguments.stMetadata.ftPlaceholder#">#serializeJSON(stValue.jsonData?:'')#</textarea>
						</div>
					</div>
				</div>
			</cfoutput>
			
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>
	

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">

		<cfset var stResult = passed(value="{}") />

		<cfparam name="arguments.stFieldPost.stSupporting" default="#structNew()#" />

		<cfif structKeyExists(arguments.stFieldPost.stSupporting, "jsonData")>
			<cfif isJSON(arguments.stFieldPost.stSupporting.jsonData)>
				<cfset arguments.stFieldPost.stSupporting.jsonData = deserializeJSON(arguments.stFieldPost.stSupporting.jsonData) />
				<cfset stResult = passed(value="#serializeJSON(arguments.stFieldPost.stSupporting)#") />
			<cfelseif len(arguments.stFieldPost.stSupporting.jsonData)>
				<cfset stResult = failed(value="#arguments.stFieldPost.stSupporting.jsonData#", message="Not Valid JSON") />
			</cfif>
		<cfelse>
			<cfset stResult = passed(value="#serializeJSON(arguments.stFieldPost.stSupporting)#") />
		</cfif>



		<cfreturn stResult />
	</cffunction>
</cfcomponent> 