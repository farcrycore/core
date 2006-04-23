
<cfcomponent displayname="category" hint="Set of functions to perform metadata characterisation">

	<cffunction name="getData" access="public" output="false" returntype="query" hint="">
		<cfargument name="lCategoryIDs" type="string" required="true" hint="The list of categoryIDs you wish to match">
		<cfargument name="typename" type="string" required="false" default="Typename you wish to search eg. dmNews"> 
		<cfargument name="dsn" type="string" required="true" hint="Database DSN">
		
		<cfset stArgs = arguments>
		<cfinclude template="_category/getData.cfm">
		
		<cfreturn getData>
		
	</cffunction>
	
	<cffunction name="deployCategories" access="public" output="false" returntype="struct" hint="Creates tables required for categorisation actions">
		<cfargument name="bDropTables" type="boolean" required="false" default="false">
		<cfargument name="dsn" type="string" required="true" hint="Database DSN">
		
		<cfset stArgs = arguments>
 		<cfinclude template="_category/deployCategories.cfm">
		
		<cfreturn stStatus>
	</cffunction>

	<cffunction name="getHierarchies" access="public" output="false" hint="returns a structure of all first level nodes keyed by Categories objectID">
		
 		<cfinclude template="_category/getHierachies.cfm">
		
		 <cfreturn qHierarchies>  
	</cffunction>
	
	<cffunction name="getCategoryBranch" access="public" hint="Pull all category Ids from nested Tree Objects" returntype="string" >
		<cfargument name="lCategoryIDs" required="true" hint="list of category Ids" >
		
	</cffunction>

	<cffunction name="displayTree" access="public" output="true">
		<cfargument name="objectID" type="uuid" required="true" default="#createUUID()#">
		<cfargument name="bIsForm" type="boolean" required="false" default="True" hint="If true - then the tree will function as a self contained form, if false, then form submit elements will not be rendered">
		<cfargument name="lGetCategories" type="string" hint="A list of category objectIDs that are to be selected as default" required="false" default="">
		
		<cfset stArgs = arguments>
 		<cfinclude template="_category/displayTree.cfm">
		
	</cffunction>
	

	<cffunction name="addCategory" returntype="struct" access="public" hint="Creates a record in categories and attach as node in nested_tree_objects">
		<cfargument name="categoryID" type="uuid" required="true">
		<cfargument name="categoryLabel" type="string" required="true" hint="label of category">
		<cfargument name="parentID" type="uuid" required="true" hint="UUID of parent">
		<cfargument name="dsn" type="string" required="true" hint="Database DSN">
		
		<cfset stArgs = arguments>
 		<cfinclude template="_category/addCategory.cfm">
		
		<cfreturn stStatus>
	</cffunction>
	
	<cffunction name="deleteCategory" returntype="struct" access="public" hint="Remove category and all children from nested_tree_objects,delete all relevant objects from categories,delete all relevant records in refCategories">
		<cfargument name="categoryID" type="uuid" hint="category ID" required="true">
		<cfargument name="dsn" type="string" required="true" hint="Database DSN">
		<cfargument name="bDeleteBranch" type="boolean" required="false" default="false">
				
		<cfset stArgs = arguments>
 		<cfinclude template="_category/deleteCategory.cfm">
		
		<cfreturn stStatus>
	</cffunction>
	
	<cffunction name="moveCategory" returntype="struct" access="public" hint="Moves a branch of categorys - a facade to tree.cfc.movebranch">
		<cfargument name="categoryID" type="uuid" hint="Category ID" required="true">
		<cfargument name="parentID" type="uuid" hint="New parent ID that branch will sit under">
		
		<cfset stArgs = arguments>
 		<cfinclude template="_category/moveCategory.cfm">
		<cfreturn stStatus>
	</cffunction>
	
	<cffunction name="getCategories" returntype="string" access="public" hint="Returns list of categories for a given content object instance">
		<cfargument name="objectID" required="true" type="uuid">
		<cfargument name="bReturnCategoryIDs" required="false" type="boolean" default="false">
		
		<cfset stArgs = arguments>
 		<cfinclude template="_category/getCategories.cfm">
		
		<cfreturn lCategoryIDs>  
	</cffunction>
	
	<cffunction name="assignCategories" returntype="struct" access="public" hint="Insert or update refCategories with a particular objectID. To delete category - a blank list of category IDs may be passed in">
		<cfargument name="objectID" type="uuid" required="true">
		<cfargument name="lCategoryIDs" type="string" hint="List of category objectIDs">  
		<cfargument name="dsn" type="string" required="true" hint="Database DSN">
		
		<cfset stArgs = arguments>
 		<cfinclude template="_category/assignCategories.cfm">
		
		<cfreturn stStatus>
	</cffunction>  
	
</cfcomponent>