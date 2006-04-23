<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/category.cfc,v 1.26 2004/12/16 04:49:56 brendan Exp $
$Author: brendan $
$Date: 2004/12/16 04:49:56 $
$Name: milestone_2-3-2 $
$Revision: 1.26 $

|| DESCRIPTION || 
$Description: Set of functions to perform metadata characterisation $

|| DEVELOPER ||
$Developer: Paul Harrison (paul@daemon.com.au) $
--->

<cfcomponent displayname="category" hint="Set of functions to perform metadata characterisation">
	
	<cffunction name="getCatAliases" output="false" returntype="struct" hint="Returns a query of all categories that have an alias">
		<cfargument name="dsn" type="string" default="#application.dsn#" required="false" hint="Database DSN">
		<cfset var q = queryNew('categoryid,alias')>
		<cfset var st = structNew()>
		<cftry>
		<cfquery name="q" datasource="#arguments.dsn#">
			SELECT categoryid,alias
			FROM #application.dbowner#categories
			WHERE alias IS NOT null OR alias <> ''
		</cfquery>
		<cfloop query="q">
			<cfscript>
			if(len(q.Alias))
			{
				if (NOT StructKeyExists(st, alias))
					st[trim(q.alias)] = q.categoryID;
			}
			</cfscript>
		</cfloop>
			<cfcatch>
				<!--- then the 'alias' column prolly doesn't exist yet - do nothing --->
			</cfcatch>
		</cftry>
		<cfreturn st>
	</cffunction>

	<cffunction name="getData" access="public" output="false" returntype="query" hint="">
		<cfargument name="lCategoryIDs" type="string" required="true" hint="The list of categoryIDs you wish to match">
		<cfargument name="typename" type="string" required="True"> 
		<cfargument name="bMatchAll" type="boolean" required="false" default="0" hint="Does the object need to match all categories"> 
		<cfargument name="dsn" type="string" default="#application.dsn#" required="false" hint="Database DSN">
		<cfargument name="orderBy" type="string" required="False" default="dateTimeLastUpdated" hint="field to order by">
		<cfargument name="orderDirection" type="string" required="False" default="desc" hint="order in which direction? descending or ascending">
		
		<cfset var qGetData = "">
		<cfinclude template="_category/getData.cfm">
		
		<cfreturn qGetData>
	</cffunction>
	
	<cffunction name="deployCategories" access="public" output="false" returntype="struct" hint="Creates tables required for categorisation actions">
		<cfargument name="bDropTables" type="boolean" required="false" default="false">
		<cfargument name="dsn" type="string" required="true" hint="Database DSN">
		
		<cfinclude template="_category/deployCategories.cfm">
		
		<cfreturn stStatus>
	</cffunction>

	<cffunction name="getHierarchies" access="public" output="false" hint="returns a structure of all first level nodes keyed by Categories objectID">
		
 		<cfinclude template="_category/getHierachies.cfm">
		
		 <cfreturn qHierarchies>  
	</cffunction>
	
	<cffunction name="getHierarchyRoot" hint="This gets a hierarchy root - nlevel 2 - by name">
		<cfargument name="objectname" required="Yes">
		<cfargument name="dsn" required="no" default="#application.dsn#">
		
		<cfquery name="q" datasource="#arguments.dsn#">
			SELECT objectID
			FROM nested_tree_objects
			WHERE nlevel = 1 AND lower(objectname) = '#lcase(arguments.objectname)#' AND lower(typename) = 'categories'
		</cfquery>
				
		<cfif q.recordcount EQ 1>
			<cfset objectid = q.objectid>
		<cfelse>
			<cfset objectid = ''>	
		</cfif>
		<cfreturn objectid>
	</cffunction>	
	
	
	<cffunction name="setAlias" access="public" returntype="void" output="false">
		<cfargument name="categoryid" type="uuid" required="true" />
		<cfargument name="alias" type="string" required="true" />
		<cfargument name="dsn" required="false" type="string" default="#application.dsn#">
		<cfargument name="dbowner" required="false" type="string" default="#application.dbowner#">
		
		<cfquery datasource="#application.dsn#" name="setAlias">
			UPDATE #application.dbowner#categories
			SET alias = '#arguments.alias#'
			WHERE categoryid = '#arguments.categoryid#'
		</cfquery>
		
	</cffunction>
	


	<cffunction name="displayTree" access="public" output="true">
		<cfargument name="rootobjectID" type="uuid" required="false">
		<cfargument name="bShowCheckBox" required="No" default="false">
		<cfargument name="bIsForm" type="boolean" required="false" default="True" hint="If true - then the tree will function as a self contained form, if false, then form submit elements will not be rendered">
		<cfargument name="lSelectedCategories" type="string" hint="A list of category objectIDs that are to be selected as default" required="false" default="">
		<cfargument name="lExcludeCategories" type="string" hint="A list of category objectIDs that are to be exlcuded" required="false" default="">
		<cfargument name="bExpand" type="boolean" hint="Defaul action for root node expansion" required="false" default="True">
		<cfargument name="dsn" required="no" default="#application.dsn#">
		<cfargument name="typename" required="no" default="categories">
		
		<cfinclude template="_category/displayTree.cfm">
		
	</cffunction>
	

	<cffunction name="addCategory" returntype="struct" access="public" hint="Creates a record in categories and attach as node in nested_tree_objects">
		<cfargument name="categoryID" type="uuid" required="true">
		<cfargument name="categoryLabel" type="string" required="true" hint="label of category">
		<cfargument name="parentID" type="uuid" required="true" hint="UUID of parent">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#" hint="Database DSN">
		
		<cfset var qChildren = ''>
		<cfset var stStatus = structNew()>
		<cfset var position = 0>
		
		<cfinclude template="_category/addCategory.cfm">
		
		<cfreturn stStatus>
	</cffunction>
	
	<cffunction name="deleteCategory" returntype="struct" access="public" hint="Remove category and all children from nested_tree_objects,delete all relevant objects from categories,delete all relevant records in refCategories">
		<cfargument name="categoryID" type="uuid" hint="category ID" required="true">
		<cfargument name="dsn" type="string" required="true" hint="Database DSN">
		<cfargument name="bDeleteBranch" type="boolean" required="false" default="false">
				
		<cfinclude template="_category/deleteCategory.cfm">
		
		<cfreturn stStatus>
	</cffunction>
	
	<cffunction name="moveCategory" returntype="struct" access="public" hint="Moves a branch of categorys - a facade to tree.cfc.movebranch">
		<cfargument name="categoryID" type="uuid" hint="Category ID" required="true">
		<cfargument name="parentID" type="uuid" hint="New parent ID that branch will sit under">
		
		<cfinclude template="_category/moveCategory.cfm">
		<cfreturn stStatus>
	</cffunction>
	
	<cffunction name="copyCategories" access="public" hint="Copies categories from draft to live object or vice versa. Doesn't change the tree.">
		<cfargument name="srcObjectID" required="Yes" type="UUID" hint="Source object whose category data is to be copied">
		<cfargument name="destObjectID" required="Yes" type="UUID" hint="Destination object for copied category data">
		<cfargument name="dsn" required="no" default="#application.dsn#">
		<cfargument name="dbowner" required="no" default="#application.dbowner#">
		
		<cfset var qGetCategories= "">
				
		<!--- get categories in source object --->
		<cfquery datasource="#arguments.dsn#" name="qGetCategories">
			SELECT categoryID
			FROM #arguments.dbowner#refCategories
			WHERE objectID = '#arguments.srcObjectID#'
		</cfquery> 
		
		<cfset assignCategories(objectid=arguments.destObjectID,lCategoryIDs=valueList(qGetCategories.categoryid))>

	</cffunction>
	
	<cffunction name="getCategories" returntype="string" access="public" hint="Returns list of categories for a given content object instance" output="No">
		<cfargument name="objectID" required="true" type="uuid">
		<cfargument name="bReturnCategoryIDs" required="false" type="boolean" default="false" hint="Set flag to true if you want category objectids instead of category labels.">
		
		<cfinclude template="_category/getCategories.cfm">
		
		<cfreturn lCategoryIDs>  
	</cffunction>
	
	<cffunction name="deleteAssignedCategories" access="public" hint="Deletes categories assigned to an object" output="No">
		<cfargument name="objectID" required="true" type="uuid">
		<cfargument name="dsn" required="no" default="#application.dsn#">
		<cfargument name="dbowner" required="no" default="#application.dbowner#">
		
		<cfset var qDeleteCategories = "">
		
		<!--- get categories in source object --->
		<cfquery datasource="#arguments.dsn#" name="qDeleteCategories">
			Delete FROM #arguments.dbowner#refCategories
			WHERE objectID = '#arguments.objectID#'
		</cfquery> 
	</cffunction>
	
	<cffunction name="getCategoryByName" returntype="query" access="public" hint="Returns category info" output="No">
		<cfargument name="name" required="true" type="string" hint="Name of the category you want returned">
		<cfargument name="typename" required="false" default="categories" type="string" hint="nested_tree_objects typename to match">
		<cfargument name="dsn" required="no" default="#application.dsn#">
		<cfargument name="dbowner" required="no" default="#application.dbowner#">
		
		<cfset var qCategory = "">
		
		<cfquery name="qCategory" datasource="#arguments.dsn#">
			SELECT *
			FROM #arguments.dbowner#nested_tree_objects
			WHERE objectname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.name#">
			AND typename = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.typename#">
		</cfquery>		
				
		<cfreturn qCategory>  
	</cffunction>
	
	<cffunction name="assignCategories" returntype="struct" access="public" hint="Insert or update refCategories with a particular objectID. To delete category - a blank list of category IDs may be passed in">
		<cfargument name="objectID" type="uuid" required="true">
		<cfargument name="lCategoryIDs" type="string" hint="List of category objectIDs">  
		<cfargument name="dsn" type="string" required="no" default="#application.dsn#" hint="Database DSN">
		
		<cfinclude template="_category/assignCategories.cfm">
		
		<cfreturn stStatus>
	</cffunction>  
	
	<cffunction name="getTreeData">
		<cfargument name="ObjectId" type="uuid" required="true">
		<cfargument name="topLevelVariable" type="string" required="No" default="objects">
		<cfargument name="dsn" type="string" required="No" default="#application.dsn#" hint="Database DSN">
		
		<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
		
		<cfscript>
			jsout = "";
			stAllObjects = structNew();
		</cfscript>

		<cfscript>
			qDescendants =request.factory.oTree.getDescendants(dsn=arguments.dsn,objectid=arguments.objectid);
		</cfscript>
		
		<cfquery name="q" datasource="#arguments.dsn#">
			SELECT * from nested_tree_objects where objectid = '#arguments.objectid#'
		</cfquery> 

		<cfset stObjects = structNew()>

		<cfscript>
			sttmp = structNew();
			sttmp.objectid = arguments.objectid;
			sttmp.title = q.objectname;
			sttmp.label = q.objectname;
			sttmp.typename = 'dmNavigation';
			sttmp.aObjectids = arrayNew(1);
			sttmp.status = 'approved';
			stObjects[arguments.objectid] = duplicate(sttmp);
		</cfscript>		

		<cfloop query="qDescendants">
		<cfscript>
			sttmp = structNew();
			sttmp.objectid = qDescendants.objectid;
			sttmp.title = qDescendants.objectname;
			sttmp.label = qDescendants.objectname;
			sttmp.typename = 'dmNavigation';
			sttmp.aObjectids = arrayNew(1);
			sttmp.status = 'approved';
			stObjects[qDescendants.objectid] = duplicate(sttmp);
		</cfscript>
		</cfloop>
	
		
		<cfloop collection="#stObjects#" item="key">
		<cfscript>
			qChildren = request.factory.oTree.getChildren(objectid=key,dsn=arguments.dsn);
			stObjects['#key#'].aNavChild = ListToArray(ValueList(qChildren.ObjectID));
			if (NOT ArrayLen(stObjects['#key#'].aNavChild))
				stObjects['#key#'].aNavChild = ""; // tree seems to barf on empty array
			if (NOT ArrayLen(stObjects['#key#'].aObjectIDs))
				stObjects['#key#'].aObjectIDs = ""; // tree seems to barf on empty array	
		</cfscript>
		</cfloop>
		
		<cfscript>
			StructAppend( stAllObjects, stObjects, "Yes" );
		</cfscript>
		
		<nj:WDDXToJavascript input="#stAllObjects#" output="jsout" toplevelvariable="#arguments.topLevelVariable#">
		
		<cfreturn jsout>  
		
	</cffunction>
	
	
	<cffunction name="updateTree">
		<cfargument name="lObjectIds">
		<cfargument name="dsn" type="string" required="No" default="#application.dsn#" hint="Database DSN">
		<cfscript>
			jscode = getTreeData(arguments.lobjectids);
		</cfscript>
			
		<cfoutput>
		<script>
			parent.downloadDone("#JSStringFormat(jscode)# objectId='#arguments.lObjectIds#'");
		</script>
		</cfoutput>
	
	</cffunction>
	
	
	<cffunction name="getCategoryId" returnType="string" access="public" output="false">
		<cfargument name="categoryName" required="true" type="string" />
		<cfargument name="parentid" required="true" type="uuid" />
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#" />
		<cfargument name="dbowner" type="string" required="false" default="#application.dbowner#" />
		
		<cfset var qCheckCategoryName = "">
		<cfset var qBranchExtents = "">

		<cfquery datasource="#arguments.dsn#" name="qCheckCategoryName">
			SELECT objectid
			FROM #arguments.dbowner#nested_tree_objects
			WHERE lower(objectname) = '#lcase(arguments.categoryName)#'
			AND parentid = '#arguments.parentid#'
			AND typeName = 'categories'
		</cfquery>
		
		<cfreturn qCheckCategoryName.objectid>
		
	</cffunction>
	
	
</cfcomponent>