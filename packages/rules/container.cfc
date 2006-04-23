
<cfcomponent extends="fourq.fourq">
	<cfproperty name="objectID" hint="Primary Key" type="uuid">
	<cfproperty name="label" hint="Name of the container"  type="string">
	<cfproperty name="aRules" hint="Array of UUIDs" type="array"> 

	<cffunction name="getContainer" access="public" returntype="query" hint="Retrieve container instance by label lookup.">
		<cfargument name="label" type="string" required="true">
		<cfargument name="dsn" type="string" required="true">
		<cfargument name="objectID" type="uuid" required="false">
				
			
		<cfquery name="qGetContainer" datasource="#arguments.dsn#">
			SELECT *
			FROM container 
			WHERE 
			<cfif isDefined("arguments.objectID")>
				objectID = '#objectID#'
			<cfelse>
				label = '#arguments.label#'
			</cfif>
		</cfquery>
		<cfreturn qGetContainer>
	</cffunction> 
	
	<cffunction name="populate" access="public" hint="Gets Rule instances and execute them">
		<cfargument name="aRules" type="array" required="true">
		
		<cfset request.aInvocations = arrayNew(1)>
		<cfloop from="1" to="#arrayLen(arguments.aRules)#" index="i">
			<cfinvoke component="fourq.fourq" returnvariable="rule" method="findType" objectID="#arguments.aRules[i]#">
			<cfinvoke objectID="#arguments.aRules[i]#" component="#application.packagepath#.rules.#rule#" method="execute"/>
					
		</cfloop>		 
		<cfloop from="1" to="#arrayLen(request.aInvocations)#" index="i">
			<cfif isStruct(request.aInvocations[i])>
				<cfscript>
					o = createObject("component", "#application.packagepath#.types.#request.aInvocations[i].typename#");
					o.getDisplay(request.aInvocations[i].objectID, request.aInvocations[i].method);	
				</cfscript>
			<cfelse>
				<cfoutput>
					<p>
					#request.aInvocations[i]#
					</p>
				</cfoutput>	
			</cfif>	
		</cfloop>
	</cffunction>
	
</cfcomponent>