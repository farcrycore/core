<cfscript>
sql = "select type.*
	   FROM #application.dbowner#refObjects refObj 
	   JOIN #application.dbowner#refCategories refCat ON refObj.objectID = refCat.objectID
	   JOIN #application.dbowner##arguments.typename# type ON refObj.objectID = type.objectID  
	   WHERE refObj.typename = '#arguments.typename#' AND refCat.categoryID IN   ('#ListChangeDelims(arguments.lCategoryIDs,"','",",")#')
	   order by #arguments.orderBy# #arguments.orderDirection#";
		</cfscript>

<cfquery name="getData" datasource="#arguments.dsn#">
	#preserveSingleQuotes(sql)#
</cfquery>