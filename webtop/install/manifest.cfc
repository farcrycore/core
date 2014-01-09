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
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#" hint="The datasource name" />
		<cfargument name="dbowner" type="string" required="false" default="#application.dbowner#" hint="The database owner" />
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#" hint="The database type" />
		<cfargument name="path" type="struct" required="false" default="#application.path#" hint="Application file paths" />
		<cfargument name="factory" type="any" required="false" hint="The factory to use for DB" />
		<cfargument name="stTableMetadata" type="struct" required="false" default="#structnew()#" hint="The metadata needed for createData" />
		
		<cfset var result = "" />	
		
		<cfset result = createContent(argumentCollection=arguments) />
		
		<cfreturn result />
	</cffunction>
	
	
	<cffunction name="createContent" access="public" returntype="string" output="false">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#" hint="The datasource name" />
		<cfargument name="dbowner" type="string" required="false" default="#application.dbowner#" hint="The database owner" />
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#" hint="The database type" />
		<cfargument name="path" type="struct" required="false" default="#application.path#" hint="Application file paths" />
		<cfargument name="factory" type="any" required="false" hint="The factory to use for DB" />
		<cfargument name="stTableMetadata" type="struct" required="false" default="#structnew()#" hint="The metadata needed for createData" />
		
		
		<cfset var result = "success" />
		<cfset var oContent = "" />
		<cfset var aContent = arrayNew(1) />
		<cfset var stProperties = structNew() />
		<cfset var stResult = structNew() />
		<cfset var qTree = queryNew("blah") />
		<cfset var qInsertTree = queryNew("blah") />
		<cfset var qWDDX = queryNew("blah") />
		<cfset var wddxTree = "" />
		<cfset var coapiutilities = createobject("component","farcry.core.packages.coapi.coapiUtilities") />
		<cfset var stRef = structnew() />
		
		<cfif fileExists("#GetDirectoryFromPath(GetCurrentTemplatePath())#nested_tree_objects.wddx")>

			<cffile action="read" file="#GetDirectoryFromPath(GetCurrentTemplatePath())#nested_tree_objects.wddx" variable="wddxTree" />
			<cfwddx action="wddx2cfml" input="#wddxTree#" output="qTree" />
			<cfloop query="qTree">
				<cfset stProperties = structnew() />
				<cfset stProperties.ObjectID = qTree.ObjectID />
				<cfset stProperties.ParentID = qTree.ParentID />
				<cfset stProperties.ObjectName = qTree.ObjectName />
				<cfset stProperties.TypeName = qTree.TypeName />
				<cfset stProperties.Nleft = qTree.nLeft />
				<cfset stProperties.Nright = qTree.Nright />
				<cfset stProperties.Nlevel = qTree.Nlevel />
				<cfset arguments.factory.createData(typename="nested_tree_objects",stProperties=stProperties,dsn=arguments.dsn) />
			</cfloop>

		</cfif>
		<cfif fileExists("#GetDirectoryFromPath(GetCurrentTemplatePath())#refCategories.wddx")>

			<cffile action="read" file="#GetDirectoryFromPath(GetCurrentTemplatePath())#refCategories.wddx" variable="wddxRefCat" />
			<cfwddx action="wddx2cfml" input="#wddxRefCat#" output="qRefCat" />
			<cfloop query="qRefCat">
				<cfset stProperties = structnew() />
				<cfset stProperties.ObjectID = qRefCat.ObjectID />
				<cfset stProperties.categoryID = qRefCat.categoryID />
				<cfset arguments.factory.createData(typename="refCategories",stProperties=stProperties,dsn=arguments.dsn) />
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
						
						<cfif structkeyexists(arguments,"factory")>
							<cfset arguments.factory.createData(typename=stProperties.typename,stProperties=stProperties,dsn=arguments.dsn) />
							<cfset stRef = structnew() />
							<cfset stRef.objectid = stProperties.objectid />
							<cfset stRef.typename = stProperties.typename />
							<cfset arguments.factory.createData(typename="refObjects",stProperties=stRef,dsn=arguments.dsn) />
						<cfelse>
							<cfset oContent = createObject("component", application.stcoapi["#stProperties.typeName#"].packagePath) />
							
							<cfset stResult = oContent.createData(stProperties=stProperties) /><br />
						</cfif>
					</cfloop>
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn result />
	</cffunction>
	
</cfcomponent>