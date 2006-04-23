
<cfscript>
	stStatus = structNew();
	stStatus.message = '';
	stStatus.status = false;
</cfscript>

<cftry>
	<cftransaction>
		<cfquery datasource="#arguments.dsn#">
			DELETE FROM #application.dbowner#categories
			WHERE categoryID = '#arguments.categoryID#'
		</cfquery>
		<cfquery datasource="#arguments.dsn#">
			DELETE FROM #application.dbowner#refCategories
			WHERE categoryID = '#arguments.categoryID#'	
		</cfquery>
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