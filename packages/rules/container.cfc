
<cfcomponent extends="farcry.fourq.fourq">
	<cfproperty name="objectID" hint="Primary Key" type="uuid">
	<cfproperty name="label" hint="Name of the container"  type="nstring">
	<cfproperty name="aRules" hint="Array of UUIDs" type="array"> 

	<cffunction name="getContainer" access="public" returntype="query" hint="Retrieve container instance by label lookup.">
		<cfargument name="label" type="string" required="true">
		<cfargument name="dsn" type="string" required="true">
		<cfargument name="objectID" type="uuid" required="false">
				
			
		<cfquery name="qGetContainer" datasource="#arguments.dsn#">
			SELECT *
			FROM #application.dbowner#container 
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
			 <cftry> 
				
				<cfinvoke component="farcry.fourq.fourq" returnvariable="rule" method="findType" objectID="#arguments.aRules[i]#">
				
				<!--- Is this a custom rule? or not? --->
				<cfif NOT evaluate("application.rules." & rule & ".bCustomRule")>
					<cfinvoke objectID="#arguments.aRules[i]#" component="#application.packagepath#.rules.#rule#" method="execute"/>
				<cfelse>
					<cfinvoke objectID="#arguments.aRules[i]#" component="#application.custompackagepath#.rules.#rule#" method="execute"/>										
				</cfif>					
			  	<cfcatch type="any">
					<!--- show error if debugging --->
					<cfif isdefined("url.debug")>
						<cfdump var="#cfcatch#">
					</cfif>
					<!--- Output a HTML Comment for debugging purposes --->
					<cfoutput>
						<!-- container failed on ruleID: #arguments.aRules[i]# (#rule#) 
						<br> 
						#cfcatch.Detail#<br>#cfcatch.Message#
					 	-->
					 </cfoutput>
				</cfcatch>
			</cftry>  
		</cfloop>		 
		<cfloop from="1" to="#arrayLen(request.aInvocations)#" index="i">
			<cfif isStruct(request.aInvocations[i])>
				<cfscript>
					o = createObject("component", "#request.aInvocations[i].typename#");
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