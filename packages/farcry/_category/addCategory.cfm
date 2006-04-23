<!--- addCategory.cfm --->

<cfscript>
	stStatus = structNew();
	stStatus.message = '';
	stStatus.status = false;
</cfscript>

<cftry>
	<cfquery datasource="#stArgs.dsn#">
		INSERT INTO categories (categoryID,categoryLabel)
		VALUES ('#stArgs.categoryID#', '#stArgs.categoryLabel#')
	</cfquery>
	<!--- Insert into nested_tree_objects --->
	<cfinvoke component="fourq.utils.tree.tree" method="setChild" objectName = "#stArgs.categoryLabel#"	 typename = "categories" parentID="#stArgs.parentID#"	 objectID="#stArgs.categoryID#" pos = "1" returnvariable="stReturn">
	<cfscript>
		stStatus.message = '#stArgs.categoryLabel# successfully added';
		stStatus.status = true;
	</cfscript>
	
	<cfcatch type="any">
		<cfdump var="#cfcatch#">
 		<cfscript>
			stStatus.message = 'Adding #stArgs.categoryLabel# successfully FAILED ';
			stStatus.status = false;
		</cfscript>
	</cfcatch>
</cftry>