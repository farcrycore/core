<cfcomponent name="hidden" displayname="hidden" extends="field" hint="Field component to liase with all hidden types">


	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.hidden" output="false" hint="Returns a copy of this initialised object">
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

		<cfsavecontent variable="html">
			<cfoutput><input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" style="#arguments.stMetadata.ftstyle#" class="#arguments.stMetadata.ftClass#" /></cfoutput>
		</cfsavecontent>

		<cfreturn html />
	</cffunction>



</cfcomponent>