<!--- assignCategories.cfm --->


<cfquery datasource="#arguments.dsn#">
	DELETE FROM #application.dbowner#refCategories WHERE objectID = '#arguments.objectID#'	
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
