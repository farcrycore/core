<cfcomponent displayname="Farcry Skeleton Creation" hint="The Skeleton creation form" extends="forms" output="false">
	<cfproperty ftSeq="1" ftFieldset="" name="name" type="string" default="" hint="The name of the new skeleton" ftLabel="Skeleton name" ftValidation="required" />
	<cfproperty ftSeq="2" ftFieldset="" name="description" type="longchar" default="" hint="The description of the new skeleton" ftLabel="Description" />
	<cfproperty ftSeq="3" ftFieldset="" name="bContentOnly" type="boolean" default="1" hint="unchecked will copy the project into the /farcry/skeleton folder. Checked will simply export the content wddx files into the project and create the manifest" ftLabel="Content Only" />
	<cfproperty ftSeq="3" ftFieldset="" name="bIncludeLog" type="boolean" default="0" hint="Should they include the farLog Table" ftLabel="Include Log Table" />
	<cfproperty ftSeq="4" ftFieldset="" name="bIncludeArchive" type="boolean" default="0" hint="Should they include the dmArchive Table" ftLabel="Include Archive Table" />
	
	
	<cffunction name="ftValidateName" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="objectid" required="true" type="string" hint="The objectid of the object that this field is part of.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset var oField = createObject("component", "farcry.core.packages.formtools.field") />		
		<cfset stResult = oField.passed(value=stFieldPost.Value) />
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->	
		<cfif structKeyExists(arguments.stMetadata, "ftValidation") AND listFindNoCase(arguments.stMetadata.ftValidation, "required") AND NOT len(stFieldPost.Value)>
			<cfset stResult = oField.failed(value="#arguments.stFieldPost.value#", message="This is a required field.") />
		</cfif>
		
		<cfset stResult = oField.failed(value="#arguments.stFieldPost.value#", message="This is a required field.") />
	<cfdump var="#stResult#" expand="false" label="stResult" /><cfabort showerror="debugging" />
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>	
</cfcomponent>