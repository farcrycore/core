<cfif structKeyExists(url,"ObjectID") AND structKeyExists(url,"Typename") AND structKeyExists(url,"Fieldname")>
	<cfset o = createObject("component",application.types['dmImage'].typepath)>
	<cfset q = o.getArrayFieldAsQuery(objectid=url.objectid,Fieldname=url.Fieldname,typename=url.typename,ftJoin='dmImage')>
</cfif>

<cfquery datasource="#application.dsn#" name="qImages">
SELECT * 
FROM dmImage
WHERE ObjectID IN (#ListQualify(ValueList(q.ObjectID),"'")#)
</cfquery>

<cfoutput>
	
	
// This list may be created by a server logic page PHP/ASP/ASPX/JSP in some backend system.
// There images will be displayed as a dropdown in all image dialogs if the "external_link_image_url"
// option is defined in TinyMCE init.

var tinyMCEImageList = new Array(
	// Name, URL
	
	<cfset currentrow = 1>
	<cfloop query="qImages">
		["<cfif len(qImages.title)>#qImages.title#<cfelse>#qImages.optimisedImage#</cfif>", "#qImages.optimisedImage#"]<cfif currentRow LT qImages.RecordCount>,<cfset currentrow = currentrow + 1></cfif>
	</cfloop>
);
</cfoutput>