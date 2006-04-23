<!--- assignCategories.cfm --->


<cfquery datasource="#stArgs.dsn#">
	DELETE FROM refCategories WHERE objectID = '#stArgs.objectID#'	
</cfquery>	

<cfloop list="#stArgs.lCategoryIDs#" index="i">
	<cftransaction>
	<cfquery datasource="#stArgs.dsn#">
			INSERT INTO refCategories (categoryID,objectID) 
			VALUES ('#i#', '#stArgs.objectID#')
		</cfquery>
	</cftransaction>
</cfloop>  

<cfscript>
	stStatus = structNew();
	stStatus.message = "#stArgs.objectID# categories successfully assigned";
	stStatus.status = true;
</cfscript>
