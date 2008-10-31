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
	
	<cffunction name="install">
		
		<cfset var result = "" />	
		
		<cfset result = createContent() />
		
		<cfreturn result />
	</cffunction>
	
	
	<cffunction name="createContent" access="public" returntype="string" output="false">
	
		<cfset var result = "success" />
		<cfset var oContent = "" />
		<cfset var aContent = arrayNew(1) />
		<cfset var stProperties = structNew() />
		<cfset var stResult = structNew() />
		<cfset var qTree = queryNew("blah") />
		<cfset var qInsertTree = queryNew("blah") />
		<cfset var qWDDX = queryNew("blah") />
		<cfset var wddxTree = "" />
		
		<cfif fileExists("#GetDirectoryFromPath(GetCurrentTemplatePath())#nested_tree_objects.wddx")>

			<cffile action="read" file="#GetDirectoryFromPath(GetCurrentTemplatePath())#nested_tree_objects.wddx" variable="wddxTree" />
			<cfwddx action="wddx2cfml" input="#wddxTree#" output="qTree" />
			<cfloop query="qTree">
				<cfquery datasource="#application.dsn#" name="qInsertTree">
				INSERT INTO #application.dbowner#nested_tree_objects
			  	(ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
			  	VALUES  ('#qTree.objectid#','#qTree.parentID#', '#qTree.objectName#','#qTree.typeName#',#qTree.nLeft#, #qTree.nRight#, #qTree.nLevel#)
				</cfquery>
			</cfloop>

		</cfif>
		<cfif fileExists("#GetDirectoryFromPath(GetCurrentTemplatePath())#refCategories.wddx")>

			<cffile action="read" file="#GetDirectoryFromPath(GetCurrentTemplatePath())#refCategories.wddx" variable="wddxRefCat" />
			<cfwddx action="wddx2cfml" input="#wddxRefCat#" output="qRefCat" />
			<cfloop query="qRefCat">
				<cfquery datasource="#application.dsn#" name="qInsertTree">
				INSERT INTO #application.dbowner#refCategories
			  	(categoryID, objectID)
			  	VALUES  ('#qRefCat.categoryID#','#qRefCat.objectid#')
				</cfquery>
			</cfloop>

		</cfif>

		<cfdirectory directory="#GetDirectoryFromPath(GetCurrentTemplatePath())#" name="qWDDX" filter="*.wddx" sort="name">
		
		<cfloop query="qWDDX">
		
			<cfif len(qWDDX.name) AND NOT listFindNoCase('nested_tree_objects.wddx,refCategories.wddx', qWDDX.name)>
				<cffile action="read" file="#GetDirectoryFromPath(GetCurrentTemplatePath())##qWDDX.name#" variable="wddxContent" />
				<cfwddx action="wddx2cfml" input="#wddxContent#" output="aContent" />
				<cfif arrayLen(aContent)>
					<cfloop from="1" to="#arrayLen(aContent)#" index="i">
						
						<cfset stProperties = aContent[i] />
						
						<cfset oContent = createObject("component", application.stcoapi["#stProperties.typeName#"].packagePath) />
						
						<cfset stResult = oContent.createData(stProperties=stProperties) />
					</cfloop>
				</cfif>
			</cfif>
		</cfloop>
		

		
		<cfreturn result />
	</cffunction>
</cfcomponent>