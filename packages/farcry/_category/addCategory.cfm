<!--- addCategory.cfm --->

<cfscript>
	stStatus = structNew();
	stStatus.message = '';
	stStatus.status = false;
</cfscript>

<!--- unicode support --->
<cfswitch expression="#application.dbType#">
	<cfcase value="ora">
		<cfquery datasource="#stArgs.dsn#">
			INSERT INTO #application.dbowner#categories (categoryID,categoryLabel)
			VALUES ('#stArgs.categoryID#', '#stArgs.categoryLabel#')
		</cfquery>
	</cfcase>
	<cfcase value="mysql">
		<cfquery datasource="#stArgs.dsn#">
			INSERT INTO #application.dbowner#categories (categoryID,categoryLabel)
			VALUES ('#stArgs.categoryID#', '#stArgs.categoryLabel#')
		</cfquery>
	</cfcase>
	<cfdefaultcase>
		<cfquery datasource="#stArgs.dsn#">
			INSERT INTO #application.dbowner#categories (categoryID,categoryLabel)
			VALUES ('#stArgs.categoryID#', N'#stArgs.categoryLabel#')
		</cfquery>
	</cfdefaultcase>
</cfswitch>

   <!--- Insert into nested_tree_objects --->
<cfinvoke component="#application.packagepath#.farcry.tree" 
	method="setChild" dsn="#stArgs.dsn#" objectName="#stArgs.categoryLabel#" 
	typename="categories" pos="1" parentID="#stArgs.parentID#" objectID="#stArgs.categoryID#" 
	returnvariable="stReturn">
	
<cfscript>
	stStatus.message = '#stArgs.categoryLabel# successfully added';
	stStatus.status = true;
</cfscript>
