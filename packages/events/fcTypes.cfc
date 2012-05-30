<cfcomponent hint="Listener for FarCry COAPI events">

	<!--- FC-2624: Load the SolrPro plugin's event handler only if the plugin is present without an fcTypes event listener --->
	<cfif listFindNoCase(application.plugins,"farcrysolrpro")
				and not Len(application.fc.utils.getPath(package="types",component="fcTypes",locations="farcrysolrpro"))>
		
		<cfset variables.solrProEventHandler = createObject("component","farcry.plugins.farcrysolrpro.packages.custom.eventHandler") />
	</cfif>

	<cffunction name="saved" access="public" hint="I am invoked when a content object has been saved">
		<cfargument name="typename" type="string" required="true" hint="The type of the object" />
		<cfargument name="oType" type="any" required="true" hint="A CFC instance of the object type" />
		<cfargument name="stProperties" type="struct" required="true" hint="The object" />
		<cfargument name="user" type="string" required="true" />
		<cfargument name="auditNote" type="string" required="true" />
		<cfargument name="bSessionOnly" type="boolean" required="true" />
		<cfargument name="bAfterSave" type="boolean" required="true" />	
		
		<cfif arguments.bAfterSave and structkeyExists(variables,"solrProEventHandler")>
			<cfset variables.solrProEventHandler.afterSave(stProperties=arguments.stProperties) />
		</cfif>
	</cffunction>

	<cffunction name="deleted" access="public" hint="I am invoked when a content object has been deleted">
		<cfargument name="typename" type="string" required="true" hint="The type of the object" />
		<cfargument name="oType" type="any" required="true" hint="A CFC instance of the object type" />
		<cfargument name="stObject" type="struct" required="true" hint="The object" />
		<cfargument name="user" type="string" required="true" />
		<cfargument name="auditNote" type="string" required="true" />
		
		<cfif structkeyExists(variables,"solrProEventHandler")>
			<cfset variables.solrProEventHandler.onDelete(typename=arguments.typename, stObject=arguments.stObject) />
		</cfif>
	</cffunction>

	<!---
	<cffunction name="statusChanged" access="public" hint="I am invoked when the status of a content object has changed">
		<cfargument name="typename" type="string" required="true" hint="The type of the object" />
		<cfargument name="oType" type="any" required="true" hint="A CFC instance of the object type" />
		<cfargument name="stObject" type="struct" required="true" hint="The object" />
		<cfargument name="newStatus" type="string" required="true" />
		<cfargument name="previousStatus" type="string" required="true" />
		
	</cffunction>

	<cffunction name="securityChanged" access="public" hint="I am invoked when the security of a content object has changed">
		<cfargument name="typename" type="string" required="true" hint="The type of the object" />
		<cfargument name="oType" type="any" required="true" hint="A CFC instance of the object type" />
		<cfargument name="stObject" type="struct" required="true" hint="The object" />
		
	</cffunction>
	
	--->

</cfcomponent>