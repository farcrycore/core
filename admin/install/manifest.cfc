<cfcomponent name="manifest">
	
	<cfset this.name = "EMPTY" />
	<cfset this.description = "EMPTY" />
	<cfset this.lRequiredPlugins = "" />
	<cfset this.stSupportedCores = structNew() />
	
	<cffunction name="addSupportedCore">
		<cfargument name="majorVersion" type="numeric" required="true" />
		<cfargument name="minorVersion" type="numeric" required="false" default="0" />
		<cfargument name="patchVersion" type="numeric" required="false" default="0" />
		
		<cfparam name="this.stSupportedCores" default="#structNew()#" />
		
		<cfset this.stSupportedCores["#arguments.majorVersion#-#arguments.minorVersion#"] = structNew() />
		<cfset this.stSupportedCores["#arguments.majorVersion#-#arguments.minorVersion#"].patchVersion = arguments.patchVersion />
	
	</cffunction>
	
	<cffunction name="isSupported">
		<cfargument name="coreMajorVersion" type="numeric" required="true" />
		<cfargument name="coreMinorVersion" type="numeric" required="false" default="0" />
		<cfargument name="corePatchVersion" type="numeric" required="false" default="0" />
		
		<cfset var bSupported = false />
		
		<cfif structKeyExists(this.stSupportedCores, "#arguments.coreMajorVersion#-#arguments.coreMinorVersion#")>
			<cfif arguments.corePatchVersion GTE this.stSupportedCores["#arguments.coreMajorVersion#-#arguments.coreMinorVersion#"].patchVersion>
				<cfset bSupported = true />
			</cfif>
		</cfif>
		
		<cfreturn bSupported />
	</cffunction>
	
	
	<cffunction name="createContent" access="public" returntype="string" output="false">
	
		<cfset var result = "" />
		<cfset var oContent = "" />
		
		<cffile action="read" file="#GetDirectoryFromPath(GetCurrentTemplatePath())#nested_tree_objects.wddx" variable="wddxTree" />
		<cfwddx action="wddx2cfml" input="#wddxTree#" output="qTree" />
		<cfloop query="qTree">
			<cfquery datasource="#application.dsn#" name="qInsertTree">
			INSERT INTO #application.dbowner#nested_tree_objects
		  	(ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
		  	VALUES  ('#qTree.objectid#','#qTree.parentID#', '#qTree.objectName#','#qTree.typeName#',#qTree.nLeft#, #qTree.nRight#, #qTree.nLevel#)
			</cfquery>
		</cfloop>

		<cffile action="read" file="#GetDirectoryFromPath(GetCurrentTemplatePath())#treeContent.wddx" variable="wddxTreeContent" />
		<cfwddx action="wddx2cfml" input="#wddxTreeContent#" output="aTreeContent" />
		<cfif arrayLen(aTreeContent)>
			<cfloop from="1" to="#arrayLen(aTreeContent)#" index="i">
				
				<cfset stProperties = aTreeContent[i] />
				
				<cfif stProperties.typename EQ "container">
					<cfset oContent = createObject("component", "farcry.core.packages.rules.container") />
				<cfelse>
					<cfset oContent = createObject("component", application.stcoapi["#stProperties.typeName#"].packagePath) />
				</cfif>
				
				<cfset stResult = oContent.createData(stProperties=stProperties) />
			</cfloop>
		</cfif>

		

		<cffile action="read" file="#GetDirectoryFromPath(GetCurrentTemplatePath())#security.wddx" variable="wddxSecurity" />
		<cfwddx action="wddx2cfml" input="#wddxSecurity#" output="aSecurity" />

		<cfif arrayLen(aSecurity)>
			<cfloop from="1" to="#arrayLen(aSecurity)#" index="i">
				
				<cfset stProperties = aSecurity[i] />
				<cfset oSecurity = createObject("component", application.stcoapi["#stProperties.typename#"].packagePath) />
				<cfset stResult = oSecurity.createData(stProperties=stProperties) />
			</cfloop>
		</cfif>

		
		<cfreturn result />
	</cffunction>
</cfcomponent>