<cfscript>
sql = "select type.*
	   FROM #application.dbowner#refObjects refObj 
	   JOIN #application.dbowner#refCategories refCat ON refObj.objectID = refCat.objectID
	   JOIN #application.dbowner#dmNews type ON refObj.objectID = type.objectID  
	   WHERE refObj.typename = '#stArgs.typename#' AND refCat.categoryID IN   ('#ListChangeDelims(stArgs.lCategoryIDs,"','",",")#')
	   order by #stArgs.orderBy# #stArgs.orderDirection#";
		</cfscript>

<cfquery name="getData" datasource="#stArgs.dsn#">
	#preserveSingleQuotes(sql)#
</cfquery>