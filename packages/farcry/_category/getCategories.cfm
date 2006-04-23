
<!--- getCategories --->

<cfquery datasource="#application.dsn#" name="qGetCategories">
	SELECT <cfif stArgs.bReturnCategoryIDs>cat.categoryID<cfelse>cat.categoryLabel</cfif>
	FROM #application.dbowner#categories cat 
	JOIN refCategories ref ON cat.categoryID = ref.categoryID
	WHERE ref.objectID = '#stArgs.objectID#'
</cfquery> 

<cfif stArgs.bReturnCategoryIDs>
	<cfset lCategoryIDs = valueList(qGetCategories.categoryID)>
<cfelse>
	<cfset lCategoryIDs = valueList(qGetCategories.categoryLabel)>
</cfif>	