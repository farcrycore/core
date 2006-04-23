
<cfscript>
	stStatus = structNew();
	stStatus.message = '';
	stStatus.status = false;
</cfscript>

<cftry>
	<cftransaction>
		<cfquery datasource="#stArgs.dsn#">
			DELETE FROM categories
			WHERE categoryID = '#stArgs.categoryID#'
		</cfquery>
		<cfquery datasource="#stArgs.dsn#">
			DELETE FROM refCategories
			WHERE categoryID = '#stArgs.categoryID#'	
		</cfquery>
	</cftransaction>
	<!--- Insert into nested_tree_objects --->
	<cfinvoke component="fourq.utils.tree.tree" method="deleteBranch" objectID="#stArgs.categoryID#" returnvariable="stReturn">
	
	<cfscript>
		stStatus.message = '#stArgs.categoryID# deleted successfully';
		stStatus.status = true;
	</cfscript>
	
	<cfcatch type="any">
		<cfscript>
			stStatus.message = 'Deletion of #stArgs.categoryID#  FAILED';
			stStatus.status = false;
		</cfscript>
	</cfcatch>
</cftry>