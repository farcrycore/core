<!--- 	
	@@example:

	<p>Basic</p>
	<code>
		<cfproperty 
			name="emailfrom" type="string" default="" hint="The email of the person leaving feedback" 
			ftSeq="1" ftFieldset="General" 
			ftType="email" ftLabel="Email From" />
	</code>

 --->

<cfcomponent extends="field" name="email" displayname="email" hint="Field component for Email types" bDocument="true"> 
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.email" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="inputClass" required="false" type="string" default="" hint="This is the class value that will be applied to the input field.">

		<cfset var html = "" />
	
		<cfsavecontent variable="html">
			<cfoutput><input type="email" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#application.fc.lib.esapi.encodeForHTMLAttribute(arguments.stMetadata.value)#" class="textInput email #arguments.inputClass# #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" placeholder="#arguments.stMetadata.ftPlaceholder#" /></cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display. Activates mailto if recognised.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		
		<cfsavecontent variable="html">
			<cfif len(trim(arguments.stMetadata.value))>
				<cfoutput><a href="mailto:#application.fc.lib.esapi.encodeForHTMLAttribute(arguments.stMetadata.value)#">#application.fc.lib.esapi.encodeForHTML(arguments.stMetadata.value)#</a></cfoutput>
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
		<cfset stResult = super.validate(objectid=arguments.objectid, typename=arguments.typename, stFieldPost=arguments.stFieldPost, stMetadata=arguments.stMetadata )>
		<cfif stResult.bSuccess and len(stFieldPost.Value) and not isvalid("email",stFieldPost.value)>
			<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="This is not a valid email address.") />
		</cfif>
		
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

</cfcomponent> 
