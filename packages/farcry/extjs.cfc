<cfcomponent displayName="Farcry ExtJS Componet" hint="component to handle ExtJS functions">

<cffunction name="renderItem" access="public" returntype="string">
	<cfargument name="stProperties" type="struct" required="true" />
	
	<cfset var returnHTML = "">
	<cfset var firstConfigProperty = true />
	<cfset var firstItem = true />
	<cfset var itemHTML = "">
	<cfset var configPropertyName = "">

	<cfsavecontent variable="returnHTML">
		<cfif structKeyExists(arguments.stProperties, "var") AND len(arguments.stProperties.var)>
			<cfoutput>var #arguments.stProperties.var# =</cfoutput>
		</cfif>
		<cfif structKeyExists(arguments.stProperties, "container") AND len(arguments.stProperties.container)>
			<cfoutput>new Ext.#arguments.stProperties.container#(</cfoutput>
		</cfif>
	
	
		<cfif structKeyExists(arguments.stProperties, "html") AND len(arguments.stProperties.html)>
			<cfset arrayAppend(request.extJS.stLayout.aHTML, arguments.stProperties.html) />
		</cfif>
	
	
		<cfoutput>{</cfoutput>
		
		<cfif structKeyExists(arguments.stProperties, "itemConfig") and len(arguments.stProperties.itemConfig)>
			<cfoutput>#arguments.stProperties.itemConfig#</cfoutput>
		<cfelse>
		
		
			<cfloop list="#structKeyList(arguments.stProperties)#" index="i">
				<cfif NOT listFindNoCase("container,aItems,html,listeners,var,plugins,bGlobalVar", i) >
					<cfif firstConfigProperty>
						<cfset firstConfigProperty = false />
					<cfelse>
						<cfoutput>,</cfoutput>
					</cfif>
					<cfif structKeyExists(request.extJS.stLayout.stConfig, i)>
						<cfset configPropertyName = request.extJS.stLayout.stConfig[i] />
					<cfelse>
						<cfset configPropertyName = lCase(i) />
					</cfif>
					<cfoutput>#configPropertyName#:<cfif isNumeric(arguments.stProperties[i]) 
														OR left(trim(arguments.stProperties[i]),1) EQ "{" 
														OR left(trim(arguments.stProperties[i]),1) EQ "[" 
										 				OR left(trim(arguments.stProperties[i]),9) EQ "function(" 
										 				OR left(trim(arguments.stProperties[i]),8) EQ "new Ext." 
														OR isBoolean(arguments.stProperties[i])>#arguments.stProperties[i]#
													<cfelse>'#arguments.stProperties[i]#'</cfif>
						
					</cfoutput>
					
				</cfif>
			</cfloop>
			
			<cfif structKeyExists(arguments.stProperties, "listeners") and len(arguments.stProperties.listeners)>
				<cfoutput>,listeners:#arguments.stProperties.listeners#
				</cfoutput>
			</cfif>
			<cfif structKeyExists(arguments.stProperties, "plugins") and len(arguments.stProperties.plugins)>
				<cfoutput>,plugins:#arguments.stProperties.plugins#
				</cfoutput>
			</cfif>
			
			<cfif structKeyExists(arguments.stProperties, "aItems") and arrayLen(arguments.stProperties.aItems)>
				<cfoutput>,items:
				</cfoutput>
				<cfoutput>[</cfoutput>
				<cfset firstItem = true />
				<cfloop from="1" to="#arrayLen(arguments.stProperties.aItems)#" index="i">
					<cfif firstItem>
						<cfset firstItem = false />
					<cfelse>
						<cfoutput>,
						</cfoutput>
					</cfif>
					<cfset itemHTML = renderItem(stProperties=arguments.stProperties.aItems[i]) />
					<cfoutput>#itemHTML#</cfoutput>
				</cfloop>
				<cfoutput>]</cfoutput>
			</cfif>
		</cfif>
		<cfoutput>}</cfoutput>
		<cfif structKeyExists(arguments.stProperties, "container") AND len(arguments.stProperties.container)>
			<cfoutput>)</cfoutput>
		</cfif>
	</cfsavecontent>
	
	<cfreturn returnHTML /> 
</cffunction>

</cfcomponent>