<!--- assignCategories.cfm --->

<!--- 
	If an alias is sent to this method, then the user has only been allowed to pick from a particular point in the tree.
	If this is the case, then we only want to delete any categories that have been selected from this point only.
 --->
<cfif isDefined("arguments.Alias") and len(arguments.Alias) and application.fapi.checkCatID(arguments.Alias)>
	<cfset lDescendents = getCategoryBranchAsList(lCategoryIDs=application.fapi.getCatID(arguments.Alias)) />
</cfif>

<cfquery datasource="#arguments.dsn#">
	DELETE FROM #application.dbowner#refCategories 
	WHERE objectID = '#arguments.objectID#'	
	<cfif isDefined("lDescendents") AND len(lDescendents)>
		AND categoryid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lDescendents#" />)
	</cfif>
</cfquery>	

<cfset aCategoryIds = listToArray(arguments.lcategoryIds)>

<cfloop from="1" to="#arrayLen(aCategoryIds)#" index="i" >
 	<cfquery datasource="#arguments.dsn#">
			INSERT INTO #application.dbowner#refCategories (categoryID,objectID) 
			VALUES ('#aCategoryIds[i]#', '#arguments.objectID#')
	</cfquery>
</cfloop>  

<cfscript>
	stStatus = structNew();
	stStatus.message = "#arguments.objectID# categories successfully assigned";
	stStatus.status = true;
</cfscript>
