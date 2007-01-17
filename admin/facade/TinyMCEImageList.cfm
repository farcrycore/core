<!--- <cfif structKeyExists(url,"ObjectID") AND structKeyExists(url,"typename") AND structKeyExists(url,"imageArrayField") AND structKeyExists(url,"imageTypename") AND structKeyExists(url,"imageField")>
	<cfset o = createObject("component",application.types[url.imageTypename].typepath)>
	<cfset q = o.getArrayFieldAsQuery(objectid=url.objectid,Fieldname=url.Fieldname,typename=url.typename,ftJoin='dmImage')>
</cfif>
 --->
<cfquery datasource="#application.dsn#" name="qImages">
SELECT objectid,label,#url.imageField# 
FROM #url.imageTypename#
WHERE ObjectID IN (
	select data
	from #url.typename#_#url.imageArrayField#
	where parentID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.objectid#" />
)
</cfquery>

<cfoutput>
	
	
// This list may be created by a server logic page PHP/ASP/ASPX/JSP in some backend system.
// There images will be displayed as a dropdown in all image dialogs if the "external_link_image_url"
// option is defined in TinyMCE init.

var tinyMCEImageList = new Array(
	// Name, URL
	
	<cfset currentrow = 1>
	<cfloop query="qImages">
		["<cfif len(qImages.label)>#qImages.label#<cfelse>#qImages[url.imageField][currentRow]#</cfif>", "#qImages[url.imageField][currentRow]#"]<cfif currentRow LT qImages.RecordCount>,<cfset currentrow = currentrow + 1></cfif>
	</cfloop>
);
</cfoutput>