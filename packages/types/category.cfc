<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<cfcomponent 
	displayname="Category" 
	extends="types" bAbstract="true" 
	hint="Abstract class defining categories. Set of functions to perform metadata characterisation" 
	bDocument="true" scopelocation="application.factory.oCategory"
	icon="fa-tags">
	
	<cfproperty name="categoryLabel" type="string" required="true" default="" 
		ftSeq="1" ftFieldset="General Details" ftLabel="Label" 
		ftValidation="required" bLabel="true"
		hint="Label used in nested tree table.">

	<cfproperty name="alias" type="string" 
		ftSeq="2" ftFieldset="General Details" ftLabel="Alias"
		hint="Alias used for application.catid">

	<cfproperty name="imgCategory" type="string" 
		ftSeq="3" ftFieldset="Media" ftLabel="Image" 
		ftType="image"
		hint="Image">
			
	<cffunction name="setData" access="public" output="false" returntype="struct" hint="Update the record for an objectID including array properties.  Pass in a structure of property values; arrays should be passed as an array." bDocument="true">
	
		<cfset var stResult = structNew() />
		<cfset var stSavedObject = structNew() />
		<cfset var q = queryNew("blah") />
		
		<cfset stResult = super.setData(argumentCollection = "#arguments#") />
		
		<cfif stResult.bSuccess>
			<cfset stSavedObject = getData(objectid="#arguments.stProperties.objectid#") />
			
			<cfquery name="q" datasource="#application.dsn#">
			UPDATE nested_tree_objects
			SET objectname = '#stSavedObject.categoryLabel#'
			WHERE objectID = '#arguments.stProperties.objectID#'
			</cfquery>		
			
			<cfset application.catid = getCatAliases(bIgnoreCache=true) />
			
		</cfif>
		
		<cfreturn stResult />
	</cffunction>

	
	
	
	<cffunction name="getCategoryNamebyID" returntype="string" access="public" hint="Returns category label for a speicfic category object id from nested tree table. Returns empty string if no match." output="yes" bDocument="true">
		<cfargument name="categoryid" required="true" type="uuid" hint="Categoryid for the matching category label.">
		<cfargument name="typename" required="false" default="dmCategory" type="string" hint="nested_tree_objects typename to match.">
		<cfargument name="dsn" required="no" default="#application.dsn#">
		<cfargument name="dbowner" required="no" default="#application.dbowner#">

		<cfset var catname="">
		<cfset var qCat="">
		
		<cfquery name="qCat" datasource="#arguments.dsn#">
			SELECT objectname
			FROM #arguments.dbowner#nested_tree_objects
			WHERE objectid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.categoryid#">
			AND typename = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.typename#">
		</cfquery>
			
		<cfif qCat.recordcount>
			<cfset catname=qCat.objectname>
		</cfif>
		<cfreturn catname>
	</cffunction>

	<cffunction name="getCategoryIDbyName" returntype="string" access="public" hint="Returns categoryid for a speicfic category name from nested tree table. Returns empty string if no match." output="No" bDocument="true">
		<cfargument name="categoryname" required="true" type="string" hint="Category label to match.">
		<cfargument name="typename" required="false" default="dmCategory" type="string" hint="nested_tree_objects typename to match.">
		<cfargument name="dsn" required="no" default="#application.dsn#">
		<cfargument name="dbowner" required="no" default="#application.dbowner#">
		<cfargument name="alias" required="no" default="">

		<cfset var objectid="">
		<cfset var qCat="">
		<cfset var q="">
		<cfset var rootid="">

		<cfif len(arguments.alias)>
			<cfset rootid = application.fapi.getCatID(alias=arguments.alias) />
			<cfset q = application.factory.oTree.getDescendants(objectid=rootid, bIncludeSelf=true)>
			<cfif q.recordcount>
				<cfquery name="qCat" dbtype="query" datasource="#arguments.dsn#">
					SELECT objectid
					FROM q
					WHERE (objectname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.categoryname#"> OR objectname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#replace(arguments.categoryname,"&","&amp;","all")#">) 
					AND typename = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.typename#">
				</cfquery>		
			</cfif>
		<cfelse>
			<cfquery name="qCat" datasource="#arguments.dsn#">
				SELECT objectid
				FROM #arguments.dbowner#nested_tree_objects
				WHERE (objectname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.categoryname#"> OR objectname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#replace(arguments.categoryname,"&","&amp;","all")#">) 
				AND typename = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.typename#">
			</cfquery>		
		</cfif>
	
		<cfif qCat.recordcount>
			<cfset objectid=qCat.Objectid>
		</cfif>

		<cfreturn objectid>
	</cffunction>

	<cffunction name="getCategoryBranchAsList" returntype="string" access="public" hint="Get all the descendants of the categoryids passed in." output="false" bDocument="true">
		<cfargument name="lCategoryIDs" type="string" required="true" hint="List of categoryIDs to expand.">
		<cfset var i=0>
		<cfset var q="">
		<cfset var r_lcategoryids="">
		<cfset var aID=arraynew(1)>
		<cfset var lResult="">


		<!--- get all descendent categories --->
		<cfloop list="#arguments.lCategoryIDs#" index="i">
			<cfset q = application.factory.oTree.getDescendants(objectid=i, bIncludeSelf=true)>
			<cfif q.recordcount>
				<cfset r_lcategoryids = ValueList(q.objectID)>
				<cfset arguments.lCategoryIDs = ListAppend(arguments.lCategoryIDs,r_lcategoryids)>
			</cfif>
		</cfloop>

		<!--- dedupe the categoryids --->
	  	<cfscript>
	  	aID=ListToArray(arguments.lCategoryIDs);
		for(i=1; i LTE ArrayLen(aID); i=i+1) {
			if(NOT ListFindNoCase(lResult, aID[i]))
				lResult=ListAppend(lResult, aID[i]);
		}
		</cfscript>
		
		<!--- return deduped list of categoryids --->
		<cfreturn lResult>
	</cffunction>
	
	<cffunction name="getCatAliases" output="true" returntype="struct" hint="Returns a structure of all categories keyed by alias." access="public">
		<cfargument name="dsn" type="string" default="#application.dsn#" required="false" hint="Database DSN">
		<cfargument name="bIgnoreCache" type="boolean" default="false" required="false" hint="Ignores the object broker cache and retrieves from the database" />

		<cfset var q = queryNew('objectid,alias')>
		<cfset var st = structNew()>
		<cfset var stLocal = structNew()>

		<cfif isdefined("application.fc.lib.objectbroker") and not arguments.bIgnoreCache>
			<!--- if the objectbroker is set up and we aren't skipping the cache, get the struct from object broker --->
			<cfset st = application.fc.lib.objectbroker.GetFromObjectBroker("catid","catid") />
		</cfif>

		<cfif structIsEmpty(st)>
			<cftry>
				<cfquery name="stLocal.q" datasource="#arguments.dsn#">
				SELECT objectid,alias
				FROM #application.dbowner#dmCategory
				WHERE alias IS NOT null OR alias <> ''
				</cfquery>

				<cfloop query="stLocal.q">
					<cfif trim(stLocal.q.alias) NEQ "">
						<cfset stLocal.lAliases = trim(stLocal.q.alias)>
						<cfloop index="stLocal.currentAlias" list="#stLocal.lAliases#">
							<cfset stLocal.currentAlias = trim(stLocal.currentAlias)>
							<cfif StructKeyExists(st,stLocal.currentAlias)>
								<cfset st[stLocal.currentAlias] = ListAppend(st[stLocal.currentAlias],stLocal.q.objectid)>
							<cfelse>
								<cfset st[stLocal.currentAlias] = stLocal.q.objectid>
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>

				<cfcatch>
					<!--- then the 'alias' column prolly doesn't exist yet - do nothing --->
					<cftrace category="farcry.category" type="warning" text="getCatAliases lookup failed.  Perhaps column doesn't exist?" var="cfcatch.detail">
				</cfcatch>
			</cftry>

			<cfset st.datetimeLastUpdated = now() />
			<cfset application.fc.lib.objectBroker.AddToObjectBroker(st,"catid","catid") />
		</cfif>

		<cfreturn st>
	</cffunction>

	<cffunction name="getDataQuery" access="public" output="true" returntype="query" hint="Return a query of objects in a specific content type that match a list of category objectids." bDocument="true">
		<cfargument name="lCategoryIDs" type="string" required="true" hint="The list of categoryIDs you wish to match">
		<cfargument name="typename" type="string" required="True" hint="The type of content to be returned"> 
		<cfargument name="bMatchAll" type="boolean" required="false" default="0" hint="Does the object need to match all categories"> 
		<cfargument name="bHasDescendants" type="boolean" required="false" default="0" hint="Should we match for the entire category branch or not."> 
		<cfargument name="dsn" type="string" default="#application.dsn#" required="false" hint="Database DSN">
		<cfargument name="maxRows" type="numeric" required="false" default="0" hint="maximum of rows returned">
		<cfargument name="sqlWhere" required="No" type="string" default="" hint="adds to the where clause of the query" />
		<cfargument name="sqlOrderBy" required="No" type="string" default="datetimelastupdated desc" hint="Used by the query to sort." />
		<cfargument name="lFields" type="string" required="false" default="" hint="the list of additional fields from the type if required.">
		
		<cfset var i=0>
		<cfset var qGetData = QueryNew("objectid")>
		<cfset var strSQL = "">
		<cfset var stLocal = StructNew()>
		<cfset var sqlMaxRows = "">
		<cfset var bSqlMax = 0>
		<cfset var rData	= '' />
		
		<cfparam name="request.mode.showdraft" default="false" />
		
		<!--- Ensure there is always something in the sqlWhere Clause --->
		<cfif not len(arguments.sqlWhere)>
			<cfset arguments.sqlWhere = "1=1" />
		</cfif>
		
		<cfif arguments.maxRows neq 0>
			<cfswitch expression="#application.dbtype#">
				<cfcase value="mssql,mssql2005">
					<cfset sqlMaxRows = " top #numberFormat(arguments.maxRows)# ">
					<cfset bSqlMax = 1>
				</cfcase>
				<cfcase value="mysql,postgres">
					<cfset sqlMaxRows = " LIMIT #numberFormat(arguments.maxRows)# ">
					<cfset bSqlMax = 0>
				</cfcase>
				<cfcase value="ora,oracle">
					<!--- This goes in the WHERE clause, not right at the SELECT statemetn --->
					<cfset sqlMaxRows = " ROWNUM <= #numberFormat(arguments.maxRows)# ">
					<cfset bSqlMax = 2>
				</cfcase>
				<cfdefaultcase>
					<cfthrow detail="The method getData of  category.cfc does not support your database type" type="Application" />				
				</cfdefaultcase>
			</cfswitch>
		</cfif>
		
		<cfif arguments.bHasDescendants and len(arguments.lCategoryIDs)>
			<cfset arguments.lCategoryIDs = getCategoryBranchAsList(lCategoryIDs="#arguments.lCategoryIDs#") />
		</cfif>
	
		<cfquery name="qGetData" datasource="#arguments.dsn#" result="rData">
		SELECT
		<cfif sqlMaxRows NEQ "" AND bSqlMax EQ 1>
			<!--- mssql --->
			#sqlMaxRows#
		</cfif>
		
		type.objectid ,'#arguments.typename#' as typename
		
		<cfif len(trim(arguments.lFields))>
			, #arguments.lFields#
		</cfif>
		
		
		FROM 	#application.dbowner##arguments.typename# type
		WHERE	#preserveSingleQuotes(arguments.SqlWhere)#
		
		<cfif StructKeyExists(application.stcoapi[arguments.typename].stprops,"status")>
			<cfif request.mode.showdraft>	
				<cfif StructKeyExists(application.types[arguments.typename].stprops,"versionid")>
					AND objectid not in (select versionid from #application.dbowner##arguments.typename#)
				</cfif>
			<cfelse>
				AND upper(type.status) = <cfqueryparam cfsqltype="cf_sql_varchar" value="APPROVED" />			
			</cfif>
		</cfif>
		
		<cfif len(arguments.lcategoryids)>
		
			<cfif arguments.bMatchAll>						
				<!--- loop over each category and make sure item has all categories --->
				<cfloop from="1" to="#listlen(arguments.lCategoryIDs)#" index="i">
					AND objectid IN (
					    select distinct objectid 
					    from #application.dbowner#refCategories 
					    where categoryID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#listGetAt(arguments.lCategoryIDs, i)#" />
					    )							
				</cfloop>
			<cfelse>					
				AND objectid IN (
				    select distinct objectid 
				    from #application.dbowner#refCategories 
				    where categoryID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.lcategoryids#">)
				    )				
			</cfif>
		<cfelse>
			<!--- ONLY GET OBJECTS THAT ARE NOT ASSIGNED --->
			AND type.objectid NOT IN (SELECT objectid FROM #application.dbowner#refCategories)	
		</cfif>	
		
		<!--- WHERE bHasMultipleVersion = <cfqueryparam cfsqltype="cf_sql_integer" value="0" /> --->
		

		<cfif sqlMaxRows NEQ "" AND bSqlMax EQ 2>
			<!--- Oracle --->
			AND #sqlMaxRows#
		</cfif>
		
		<cfif len(trim(arguments.sqlOrderBy))>
			ORDER BY #preserveSingleQuotes(arguments.sqlOrderBy)#
		</cfif>
				
		<cfif sqlMaxRows NEQ "" AND bSqlMax EQ 0>
			<!--- mysql,postgres --->
			#sqlMaxRows#
		</cfif>
		
		</cfquery>
		
		<cfreturn qGetData>
	</cffunction>
	
	<cffunction name="deployCategories" access="public" output="false" returntype="struct" hint="Creates tables required for categorisation actions">
		<cfargument name="bDropTables" type="boolean" required="false" default="false">
		<cfargument name="dsn" required="Yes" >
		<cfargument name="dbtype" required="Yes"> 
		<cfargument name="dbowner" required="Yes"> 
		
		<cfinclude template="_category/deployCategories.cfm">
		
		<cfreturn stStatus>
	</cffunction>

	<cffunction name="getHierarchies" access="public" output="false" hint="Returns a query of all first level nodes keyed by typename 'categories' in the nested tree model." returntype="query" bDocument="true">
		<cfset var qroot="">
		<cfset var qHierarchies="">
		<cfset var objectName	= '' />
		
		<cfscript>
			// Get root node
			qRoot = application.factory.oTree.getRootNode(typename="dmCategory");
			if (not qRoot.recordcount) {
				application.factory.oTree.setRootNode(typename="dmCategory",objectid=application.fc.utils.createJavaUUID(),objectName="root");
				qRoot = application.factory.oTree.getRootNode(typename="dmCategory");
			}
			qHierarchies = application.factory.oTree.getChildren(objectid=qRoot.objectID);
		</cfscript>
				
		 <cfreturn qHierarchies>  
	</cffunction>
	
	<cffunction name="getHierarchyRoot" hint="Returns objectid of hierarchy root ie. nlevel 2, by objectname." returntype="UUID" access="public" output="false" bDocument="true">
		<cfargument name="objectname" required="Yes" type="string">
		<cfargument name="dsn" required="no" default="#application.dsn#" type="string">
		<cfset var objectid="">
		<cfset var q="">
		
		<cfquery name="q" datasource="#arguments.dsn#">
			SELECT objectID
			FROM #application.dbowner#nested_tree_objects
			WHERE nlevel = 1 AND lower(objectname) = '#lcase(arguments.objectname)#' AND lower(typename) = 'dmcategory'
		</cfquery>
				
		<cfif q.recordcount EQ 1>
			<cfset objectid = q.objectid>
		<cfelse>
			<cfthrow errorcode="farcry.category" message="Objectname is does not have a category hierarchy.">
		</cfif>
		<cfreturn objectid>
	</cffunction>	
	
	<cffunction name="getAllCategories" hint="Returns a query of the entire category tree, ordered by nLeft." returntype="query" output="false" access="public" bDocument="true">
		<cfargument name="dsn" required="no" default="#application.dsn#" type="string">
		<cfargument name="dbowner" required="No" default="#application.dbowner#">
		<cfset var q="">
		
		
		<cfquery name="q" datasource="#arguments.dsn#">
			SELECT	ntm.*, cat.alias
			FROM 	#arguments.dbowner#nested_tree_objects ntm
			LEFT JOIN #arguments.dbowner#dmCategory cat ON ntm.objectid = cat.objectid
			WHERE lower(typename) = 'dmcategory'
			ORDER BY nleft
		</cfquery>

		<cfreturn q>
	</cffunction>
		
	<cffunction name="setAlias" access="public" returntype="void" output="false" bDocument="true">
		<cfargument name="categoryid" type="uuid" required="true" />
		<cfargument name="alias" type="string" required="true" />
		<cfargument name="dsn" required="false" type="string" default="#application.dsn#">
		<cfargument name="dbowner" required="false" type="string" default="#application.dbowner#">
		
		<cfset var setAlias	= '' />
		
		<cfquery datasource="#application.dsn#" name="setAlias">
			UPDATE #application.dbowner#dmCategory
			SET alias = '#arguments.alias#'
			WHERE objectID = '#arguments.categoryid#'
		</cfquery>
		
	</cffunction>
	
	<cffunction name="displayTree" access="public" output="true" hint="Render form tree-widget for category picker.  Can be prepoulated with categories." returntype="string">
		<cfargument name="rootobjectID" type="uuid" required="false">
		<cfargument name="bShowCheckBox" required="No" default="false">
		<cfargument name="bIsForm" type="boolean" required="false" default="True" hint="If true - then the tree will function as a self contained form, if false, then form submit elements will not be rendered">
		<cfargument name="lSelectedCategories" type="string" hint="A list of category objectIDs that are to be selected as default" required="false" default="">
		<cfargument name="lExcludeCategories" type="string" hint="A list of category objectIDs that are to be exlcuded" required="false" default="">
		<cfargument name="bExpand" type="boolean" hint="Defaul action for root node expansion" required="false" default="True">
		<cfargument name="dsn" required="no" default="#application.dsn#">
		<cfargument name="typename" required="no" default="dmCategory">

		<cfset application.fapi.deprecated("category.cfc displayTree() is deprecated as of FarCry 7.0")>
		
	</cffunction>
	
	<cffunction name="addCategory" returntype="struct" access="public" hint="Creates a record in categories and attach as node in nested_tree_objects" bDocument="true">
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
	
	<cffunction name="deleteCategory" returntype="struct" access="public" hint="Remove category and all children from nested_tree_objects,delete all relevant objects from categories,delete all relevant records in refCategories" bDocument="true">
		<cfargument name="categoryID" type="uuid" hint="category ID" required="true">
		<cfargument name="dsn" type="string" required="true" hint="Database DSN">
		<cfargument name="bDeleteBranch" type="boolean" required="false" default="false">
				
		<cfinclude template="_category/deleteCategory.cfm">
		
		<cfreturn stStatus>
	</cffunction>
	
	<cffunction name="moveCategory" returntype="struct" access="public" hint="Moves a branch of categorys - a facade to tree.cfc.movebranch" bDocument="true">
		<cfargument name="categoryID" type="uuid" hint="Category ID" required="true">
		<cfargument name="parentID" type="uuid" hint="New parent ID that branch will sit under">
		
		<cfinclude template="_category/moveCategory.cfm">
		<cfreturn stStatus>
	</cffunction>
	
	<cffunction name="copyCategories" access="public" hint="Copies categories from draft to live object or vice versa. Doesn't change the tree." bDocument="true">
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
	
	<cffunction name="getCategories" returntype="string" access="public" hint="Returns list of categories for a given content object instance" output="false" bDocument="true">
		<cfargument name="objectID" required="true" type="uuid">
		<cfargument name="bReturnCategoryIDs" required="false" type="boolean" default="false" hint="Set flag to true if you want category objectids instead of category labels.">
		<cfargument name="alias" type="string" hint="The alias of the section of the category tree that is going to be re-asigned." required="false" default="">  
		
		<cfset var qGetCategories="">
		<cfset var lCategoryIDs="">
		<cfset var lDescendents	= '' />
		
		<cfif isDefined("arguments.Alias") and len(arguments.Alias) and application.fapi.checkCatID(arguments.Alias)>
			<cfset lDescendents = getCategoryBranchAsList(lCategoryIDs=application.fapi.getCatID(arguments.Alias)) />
		</cfif>

		
		<!--- getCategories --->
		<cfquery datasource="#application.dsn#" name="qGetCategories">
			SELECT DISTINCT <cfif arguments.bReturnCategoryIDs>cat.objectid<cfelse>cat.categoryLabel</cfif>
			FROM #application.dbowner#dmCategory cat,#application.dbowner#refCategories ref
			WHERE cat.objectid = ref.categoryID
			AND ref.objectID = '#arguments.objectID#'
			<cfif isDefined("lDescendents") AND len(lDescendents)>
				AND ref.categoryid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lDescendents#" />)
			</cfif>
		</cfquery> 

		<cfif arguments.bReturnCategoryIDs>
			<cfset lCategoryIDs = valueList(qGetCategories.objectid)>
		<cfelse>
			<cfset lCategoryIDs = valueList(qGetCategories.categoryLabel)>
		</cfif>	
		
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
	
	<cffunction name="getCategoryByName" returntype="query" access="public" hint="Returns category info" output="No" bDocument="true">
		<cfargument name="name" required="true" type="string" hint="Name of the category you want returned">
		<cfargument name="typename" required="false" default="dmCategory" type="string" hint="nested_tree_objects typename to match">
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
		<cfargument name="alias" type="string" hint="The alias of the section of the category tree that is going to be re-asigned.">  
		<cfargument name="dsn" type="string" required="no" default="#application.dsn#" hint="Database DSN">
		
		<cfinclude template="_category/assignCategories.cfm">
		
		<cfreturn stStatus>
	</cffunction>  
	
	<cffunction name="getTreeData" hint="Return a WDDX JS array for category object data, for use in the category tree UI control." returntype="string" output="false" access="public">
		<cfargument name="ObjectId" type="uuid" required="true">
		<cfargument name="topLevelVariable" type="string" required="No" default="objects">
		<cfargument name="dsn" type="string" required="No" default="#application.dsn#" hint="Database DSN">
		
		<cfset var jsout="">
		<cfset var stAllObjects=structNew()>
		<cfset var qDescendants="">
		<cfset var q="">
		<cfset var stObjects=structNew()>
		<cfset var stTmp=structNew()>
		<cfset var qChildren="">
		<cfset var key	= '' />
			
		<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
		
		<cfscript>
			qDescendants=application.factory.oTree.getDescendants(dsn=arguments.dsn,objectid=arguments.objectid);
		</cfscript>
		
		<cfquery name="q" datasource="#arguments.dsn#">
			SELECT * from nested_tree_objects where objectid = '#arguments.objectid#'
		</cfquery> 

		<!--- TODO: Investigate
			There appears to be some crack smoking going on here... 
			is this method even used?  Is nominating a typename of dmnavigation. 
			Was this possibly copied from tree.cfc and then never needed??
			20050602GB
		--->
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
			qChildren = application.factory.oTree.getChildren(objectid=key,dsn=arguments.dsn);
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
		
		<cfset var jscode = getTreeData(arguments.lobjectids) />
		
			
		<cfoutput>
		<script>
			parent.downloadDone("#JSStringFormat(jscode)# objectId='#arguments.lObjectIds#'");
		</script>
		</cfoutput>
	
	</cffunction>
	
	<cffunction name="getCategoryId" returnType="string" access="public" output="false" bDocument="true">
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
			AND lower(typeName) = 'dmcategory'
		</cfquery>
		
		<cfreturn qCheckCategoryName.objectid>
		
	</cffunction>
	
	<cffunction name="getObjectByCategory" returntype="query" hint="Returns a query containing objects for a list of categories, including all subcategories in a selected branch, for a specific content type." output="false" access="public" bDocument="true">
	<!--- 
		TODO: Investigate
		How is this method different to category categor.getData() ???
		20050602GB  
		 --->
		<cfargument name="lCategories" required="true" type="string" hint="A comma delimited list of category UUIDs." />
		<cfargument name="typename" required="true" type="string" />
		<cfargument name="bHasAny" required="true" type="boolean" default="true" />

		<cfset var stLocal = StructNew()>
		<cfset stLocal.bRootNode = 0>
		<cfset stLocal.qList = QueryNew("objectid")>
		<cfset stLocal.objTree = CreateObject("component","#application.packagepath#.farcry.tree")>
		<cfset stLocal.qtemp = stLocal.objTree.getRootNode(application.dsn,"categories")>
		<cfif stLocal.qtemp.recordCount GT 0>
			<cfset stLocal.bRootNode = ListFindNoCase(lCategories,stLocal.qtemp.objectID)>
		</cfif>

		<cfset stLocal.lcategories = lCategories>
		<!--- grab all the categories in a selected branch, and concatenate to original list --->
		<cfloop index="stLocal.tCategoryID" list="#arguments.lCategories#">
			<cfset stLocal.returnstruct = stLocal.objTree.getDescendants(stLocal.tCategoryID)>
			<cfset stLocal.tlcategories = ValueList(stLocal.returnstruct.objectid)>
			<cfset stLocal.lcategories = ListAppend(stLocal.lcategories,stLocal.tlcategories)>
		</cfloop>
		<!--- 
		TODO: this list appears to need de-duping before qualifying 20050602GB
		 --->

		<cfquery datasource="#application.dsn#" name="stLocal.qList">
		SELECT l.*
		FROM	#application.dbowner##arguments.typename# l <cfif stLocal.lcategories NEQ "" AND stLocal.bRootNode EQ 0>, #application.dbowner#refCategories c
		WHERE	c.objectid = l.objectid
				AND c.categoryid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#stLocal.lcategories#" />)</cfif>
		</cfquery>
		
		<cfreturn stLocal.qList>
	</cffunction>

	<cffunction name="fPagingContentObjectByCategoryID" access="public" hint="returns a query of the specified content type based on the category id and all of its descendants, this function uses a stored procedure to return paging" returntype="struct">
		<cfargument name="categoryID" required="true" type="string" hint="A category UUIDs." />
		<cfargument name="typename" required="true" type="string" hint="content type you whish to return." />
		<cfargument name="pageCurrent" required="false" type="numeric" default="1" hint="the current records for the page" />
		<cfargument name="pageMaxsize" required="false" type="numeric" default="20" hint="the max number of records to return per page" />

		<!---
		ms sql server specific //todo: move this out and refactor for latest version
		curret functionality works fine but for large nested trees there is a big performace issue,
		calls a private function to return a subset of the query for paging
		NOTE: this function can not be called from getData() because the getData() function has the return type of query, we need to return additional paging variablea and accept pagingg variables
		--->
			
		<cfset var stReturn = StructNew()>
		<cfset var stLocal = StructNew()>	
		<cfset var qGetDataPage	= '' />
		<cfset var qGetData	= '' />
		<cfset var qGetCount	= '' />
		
		<cfset stReturn.bSuccess = 1>
		<cfset stReturn.message = "">
		<cfset stReturn.totalRecords = 0>

		<cfset stLocal.strFields = "type.objectid">
		<cfset stLocal.strPK = "type.objectID">
		<cfset stLocal.strTables = "#application.dbowner#refObjects refObj JOIN #application.dbowner#refCategories refCat ON refObj.objectid = refCat.objectID JOIN #application.dbowner##arguments.typename# type ON refObj.objectid = type.ObjectID">
		<cfset stLocal.strGroup = stLocal.strPK>
		<!--- filter with sub select, using the nested tree model ie. all sub categorys are within the nleft and nright of the category id --->
		<cfset stLocal.strFilter = "refObj.typename = ''#arguments.typename#'' AND refCat.categoryid IN (SELECT objectid FROM nested_tree_objects WHERE (nLeft >= (SELECT nLeft FROM nested_tree_objects WHERE (objectid = ''#arguments.categoryid#'') AND (lower(TypeName) = ''dmcategory''))) AND (nRight <=  (SELECT  nRight FROM nested_tree_objects WHERE (objectid = ''#arguments.categoryid#'') AND (lower(TypeName) = ''dmcategory''))) AND (lower(TypeName) = ''dmcategory''))">
																																																																						  
		<!--- get all the content objectids for the particular page --->
		<cfquery name="qGetDataPage" datasource="#application.dsn#">
		SELECT_WITH_PAGING '#stLocal.strFields#', '#stLocal.strPK#', '#stLocal.strTables#',#arguments.pageCurrent#,#arguments.pageMaxsize#,0,'#stLocal.strFilter#',null,'#stLocal.strGroup#'
		</cfquery>

		<!--- get all the content object  --->
		<cfquery name="qGetData" datasource="#application.dsn#">
		SELECT type.*
		FROM #application.dbowner##arguments.typename# type
		WHERE 	type.objectid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#valuelist(qGetDataPage.objectid)#" />)
		</cfquery>
		
		<!--- get the total recorcount --->
		<!--- deescape the ' --->

		<cfset stLocal.strFilter = ReplaceNoCase(stLocal.strFilter,"''","'","All")>

		<cfquery name="qGetCount" datasource="#application.dsn#">
		SELECT count(DISTINCT #stLocal.strFields#) as numberofrecords
		FROM	#stLocal.strTables#
		WHERE	#preservesinglequotes(stLocal.strFilter)#
		</cfquery>
					

		<cfset stReturn.totalRecords = qGetCount.numberofrecords>
		<cfset stReturn.queryObject = qGetData>

		<cfreturn stReturn>
	</cffunction>
</cfcomponent>