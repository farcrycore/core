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
	<cfcase value="mysql,mysql5">
		<cfquery datasource="#arguments.dsn#">
			INSERT INTO #application.dbowner#categories (categoryID,categoryLabel)
			VALUES ('#arguments.categoryID#', '#arguments.categoryLabel#')
		</cfquery>
	</cfcase>
	<cfcase value="postgresql">
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

<cfscript>
	qChildren = application.factory.oTree.getChildren(objectid=arguments.parentID,typename='categories');
	position = qChildren.recordCount + 1;
	stReturn = application.factory.oTree.setChild(objectName=arguments.categoryLabel,typename='categories',parentID=arguments.parentID,objectID=arguments.categoryID,pos=position);

	stStatus.message = '#arguments.categoryLabel# successfully added';
	stStatus.status = true;
</cfscript>
