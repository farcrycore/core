<cfscript>
sql = "select type.*
	   FROM refObjects refObj 
	   JOIN refCategories refCat ON refObj.objectID = refCat.objectID
	   JOIN dmNews type ON refObj.objectID = type.objectID  
	   WHERE refObj.typename = '#stArgs.typename#' AND refCat.categoryID IN   ('#ListChangeDelims(stArgs.lCategoryIDs,"','",",")#')";
		</cfscript>

<cfquery name="getData" datasource="#stArgs.dsn#">
	#preserveSingleQuotes(sql)#
</cfquery>