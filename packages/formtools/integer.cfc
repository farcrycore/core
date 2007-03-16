<cfcomponent name="integer" displayname="integer" extends="field" hint="Field component to liase with all integer types"> 
	
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.integer" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this />
	</cffunction>
	
	
	<cffunction name="edit" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of." />
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of." />
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument." />
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform." />
	
		<cfset var html = "" />
	
		<cfparam name="arguments.stMetadata.ftClass" default="" />
		<cfparam name="arguments.stMetadata.ftStyle" default="width:50px;" />
		<cfparam name="arguments.stMetadata.ftPrefix" default="">
		<cfparam name="arguments.stMetadata.ftSuffix" default="">
	
		<cfsavecontent variable="html">
			<cfoutput><input type="text" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.ftPrefix##arguments.stMetadata.value##arguments.stMetadata.ftSuffix#" style="#arguments.stMetadata.ftstyle#" class="#arguments.stMetadata.ftClass#" /></cfoutput>
		</cfsavecontent>
		
		<cfreturn html />
	</cffunction>


	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of." />
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of." />
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument." />
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform." />

		<cfset var html = "" />		
		
		<cfparam name="arguments.stMetadata.ftPrefix" default="">
		<cfparam name="arguments.stMetadata.ftSuffix" default="">
		
		<cfsavecontent variable="html">
			<cfoutput>#arguments.stMetadata.ftPrefix##arguments.stMetadata.value##arguments.stMetadata.ftSuffix#</cfoutput>
		</cfsavecontent>
		
		<cfreturn html />
	</cffunction>


	<cffunction name="validate" access="public" output="false" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type." />
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument." />
		
		<cfset var stResult = structNew() />
		
		<cfparam name="arguments.stMetadata.ftPrefix" default="">
		<cfparam name="arguments.stMetadata.ftSuffix" default="">
		
		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = "#stFieldPost.Value#">
		<cfset stResult.stError = StructNew()>
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<cfset stResult.value = ReplaceNoCase(stResult.value, ",","","all")>
		
		<cfif len(trim(arguments.stMetadata.ftPrefix))>
			<cfset stResult.value = ReplaceNoCase(stResult.value, trim(arguments.stMetadata.ftPrefix), "","all")>
		</cfif>
		<cfif len(trim(arguments.stMetadata.ftSuffix))>
			<cfset stResult.value = ReplaceNoCase(stResult.value, trim(arguments.stMetadata.ftSuffix), "","all")>
		</cfif>
		
		
		<cfset stResult.value = trim(stResult.value) />
	
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>


</cfcomponent>