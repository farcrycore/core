<!--- addCategory.cfm --->

<cfscript>
	stStatus = structNew();
	stStatus.message = '';
	stStatus.status = false;
</cfscript>

<!--- unicode support --->

<cfswitch expression="#application.dbType#">
	<cfcase value="ora">
		<cfquery datasource="#arguments.dsn#">
			INSERT INTO #application.dbowner#categories (categoryID,categoryLabel)
			VALUES ('#arguments.categoryID#', '#arguments.categoryLabel#')
		</cfquery>
	</cfcase>
	<cfcase value="mysql">
		<cfquery datasource="#arguments.dsn#">
			INSERT INTO #application.dbowner#categories (categoryID,categoryLabel)
			VALUES ('#arguments.categoryID#', '#arguments.categoryLabel#')
		</cfquery>
	</cfcase>
	<cfdefaultcase>
		<cfquery datasource="#arguments.dsn#">
			INSERT INTO #application.dbowner#categories (categoryID,categoryLabel)
			VALUES ('#arguments.categoryID#', N'#arguments.categoryLabel#')
		</cfquery>
	</cfdefaultcase>
</cfswitch>

   <!--- Insert into nested_tree_objects --->
<cfinvoke component="#application.packagepath#.farcry.tree" 
	method="setChild" dsn="#arguments.dsn#" objectName="#arguments.categoryLabel#" 
	typename="categories" pos="1" parentID="#arguments.parentID#" objectID="#arguments.categoryID#" 
	returnvariable="stReturn">
	
<cfscript>
	stStatus.message = '#arguments.categoryLabel# successfully added';
	stStatus.status = true;
</cfscript>
