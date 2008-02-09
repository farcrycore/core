
<cfscript>
	stStatus = structNew();
	stStatus.message = '';
	stStatus.status = false;
</cfscript>

<cfset qDesc = application.factory.oTree.getDescendants(objectid=arguments.categoryID,bIncludeSelf=1)>

 <cftry>
	<cftransaction> 
		<cfif qDesc.recordcount>
			<cfquery datasource="#arguments.dsn#">
				DELETE FROM #application.dbowner#dmCategory
				WHERE objectid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#ValueList(qDesc.objectid)#" />)
			</cfquery>
			<cfquery datasource="#arguments.dsn#">
				DELETE FROM #application.dbowner#refCategories
				WHERE categoryID IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#ValueList(qDesc.objectid)#" />)
			</cfquery>
		</cfif>
 	</cftransaction> 
	<!--- Insert into nested_tree_objects --->
	<cfinvoke component="#application.packagepath#.farcry.tree" method="deleteBranch" objectID="#arguments.categoryID#" returnvariable="stReturn">
	
	<cfscript>
		stStatus.message = '#arguments.categoryID# deleted successfully';
		stStatus.status = true;
	</cfscript>

	<cfcatch type="any">
		<cfscript>
			stStatus.message = 'Deletion of #arguments.categoryID#  FAILED';
			stStatus.status = false;
		</cfscript>
	</cfcatch>
</cftry> 