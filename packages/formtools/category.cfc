




<cfcomponent extends="field" name="category" displayname="category" hint="Field component to liase with all category field types"> 

	<cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets">
	<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >

	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfparam name="arguments.stMetadata.ftAlias" default="">
		
		<cfif structKeyExists(application.catid, arguments.stMetadata.ftAlias)>
			<cfset navid = application.catid[arguments.stMetadata.ftAlias] >
		<cfelse>
			<cfset navid = application.catid['root'] >
		</cfif>
		
		

		<cfinvoke component="#application.packagepath#.farcry.category" method="getCategories" returnvariable="lSelectedCategoryID">
			<cfinvokeargument name="objectID" value="#stObject.ObjectID#"/>
			<cfinvokeargument name="bReturnCategoryIDs" value="true"/>
		</cfinvoke>
		
		<cfsavecontent variable="html">
			<cfoutput>
			<div style="float:left;">
				<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" />
				<ft:PrototypeTree id="#arguments.fieldname#" navid="#navid#" depth="99" bIncludeHome=1 lSelectedItems="#lSelectedCategoryID#">
			</div>
			</cfoutput>					
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfparam name="arguments.stMetadata.ftAlias" default="">
	
		<cfinvoke component="#application.packagepath#.farcry.category" method="getCategories" returnvariable="lSelectedCategoryID">
			<cfinvokeargument name="objectID" value="#stObject.ObjectID#"/>
			<cfinvokeargument name="bReturnCategoryIDs" value="false"/>
			<cfinvokeargument name="alias" value="#arguments.stMetadata.ftAlias#"/>
		</cfinvoke>
		
		<cfsavecontent variable="html">
			<cfoutput>#lSelectedCategoryID#</cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="ObjectID" required="true" type="UUID" hint="The objectid of the object that this field is part of.">
		<cfargument name="Typename" required="true" type="string" hint="the typename of the objectid.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = "#arguments.stFieldPost.Value#">
		<cfset stResult.stError = StructNew()>
		
		<cfparam name="arguments.stMetadata.ftAlias" default="">
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->

		<cfinvoke  component="#application.packagepath#.farcry.category" method="assignCategories" returnvariable="stStatus">
			<cfinvokeargument name="objectID" value="#arguments.ObjectID#"/>
			<cfinvokeargument name="lCategoryIDs" value="#arguments.stFieldPost.Value#"/>
			<cfinvokeargument name="alias" value="#arguments.stMetadata.ftAlias#"/>
			<cfinvokeargument name="dsn" value="#application.dsn#"/>
		</cfinvoke>

					
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

</cfcomponent> 



