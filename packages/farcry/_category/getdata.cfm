<cfif arguments.bMatchAll>
	<!--- must match all categories --->
	<cfquery name="qGetData" datasource="#arguments.dsn#">
		SELECT type.*
		FROM #application.dbowner#refObjects refObj 
		JOIN #application.dbowner#refCategories refCat1 ON refObj.objectID = refCat1.objectID
		JOIN #application.dbowner##arguments.typename# type ON refObj.objectID = type.objectID 
		<!--- if more than one category make join for each --->
		<cfif listLen(arguments.lCategoryIDs) gt 1>
			<cfloop from="2" to="#listlen(arguments.lCategoryIDs)#" index="i">
			    , refCategories refCat#i#
			</cfloop>
		</cfif>
		WHERE 1=1
			<!--- loop over each category and make sure item has all categories --->
			<cfloop from="1" to="#listlen(arguments.lCategoryIDs)#" index="i">
				AND refCat#i#.categoryID = '#listGetAt(arguments.lCategoryIDs,i)#'
				AND refCat#i#.objectId = type.objectId
			</cfloop>
		ORDER BY #arguments.orderBy# #arguments.orderDirection#
	</cfquery>
<cfelse>
	<cfquery name="qGetData" datasource="#arguments.dsn#">
		SELECT type.*
		FROM #application.dbowner#refObjects refObj 
		JOIN #application.dbowner#refCategories refCat ON refObj.objectID = refCat.objectID
		JOIN #application.dbowner##arguments.typename# type ON refObj.objectID = type.objectID  
		WHERE refObj.typename = '#arguments.typename#' AND refCat.categoryID IN ('#ListChangeDelims(arguments.lCategoryIDs,"','",",")#')
		ORDER BY #arguments.orderBy# #arguments.orderDirection#
	</cfquery>
</cfif>
	