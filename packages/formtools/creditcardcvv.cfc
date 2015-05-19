

<cfcomponent name="creditcardcvv" displayname="Credit Card CVV" hint="Field containing a credit card expiry" extends="integer"> 
	
	<cfproperty name="dbPrecision" required="false" default="4" hint="Verification number for credit card" />
	
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.field" output="false" hint="Returns a copy of this initialised object">
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="inputClass" required="false" type="string" default="" hint="This is the class value that will be applied to the input field.">

		<cfset var html = "" />
		
		<cfparam name="arguments.stMetadata.ftValidation" default="" />
		<cfif not listfindnocase(arguments.stMetadata.ftValidation,"digits")>
			<cfset arguments.stMetadata.ftValidation = listappend(arguments.stMetadata.ftValidation,"digits") />
		</cfif>
		
		<cfparam name="arguments.stMetadata.ftClass" default="" />
		<cfif not listfindnocase(arguments.stMetadata.ftClass,"digits"," ")>
			<cfset arguments.stMetadata.ftClass = listappend(arguments.stMetadata.ftClass,"digits"," ") />
		</cfif>
		
		<cfsavecontent variable="html"><cfoutput>
			<div class="multiField">
				<input type="text" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" maxLength="4" class="textInput #arguments.inputClass# #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#">
				&nbsp;&nbsp;<a href="http://www.cvvnumber.com/cvv.html" target="_blank">what is this?</a>
			</div>
		</cfoutput></cfsavecontent>
		
		<cfreturn html>
	</cffunction>
	
	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="objectid" required="true" type="string" hint="The objectid of the object that this field is part of.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>
		<cfset var earliestdate = createdate(year(now()),month(now()),1) />
		<cfset var expiry = "" />
		
		<cfif len(arguments.stFieldPost.value) and not refind("^\d+$",arguments.stFieldPost.value)>
			<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="Please enter only digits.") />
		<cfelse>
			<cfset stResult = super.validate(argumentCollection=arguments) />
		</cfif>
	
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
	</cffunction>
	
</cfcomponent> 
