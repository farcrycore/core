<!--- assignCategories.cfm --->


<cfquery datasource="#arguments.dsn#">
	DELETE FROM #application.dbowner#refCategories WHERE objectID = '#arguments.objectID#'	
</cfquery>	

<cfloop list="#arguments.lCategoryIDs#" index="i">
	<cftransaction>
	<cfquery datasource="#arguments.dsn#">
			INSERT INTO #application.dbowner#refCategories (categoryID,objectID) 
			VALUES ('#i#', '#arguments.objectID#')
		</cfquery>
	</cftransaction>
</cfloop>  

<cfscript>
	stStatus = structNew();
	stStatus.message = "#arguments.objectID# categories successfully assigned";
	stStatus.status = true;
</cfscript>
