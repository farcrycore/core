<cfif structKeyExists(url,"ObjectID") AND structKeyExists(url,"Typename") AND structKeyExists(url,"Fieldname")>
	<cfset o = createObject("component",application.types['dmImage'].typepath)>
	<cfset q = o.getArrayFieldAsQuery(objectid=url.objectid,Fieldname=url.Fieldname,typename=url.typename,Link='dmImage')>
</cfif>

<cfoutput>
	
	
// This list may be created by a server logic page PHP/ASP/ASPX/JSP in some backend system.
// There images will be displayed as a dropdown in all image dialogs if the "external_link_image_url"
// option is defined in TinyMCE init.

var tinyMCEImageList = new Array(
	// Name, URL
	
	<cfset currentrow = 1>
	<cfloop query="q">
		["<cfif len(q.title)>#q.title#<cfelse>#q.optimisedImage#</cfif>", "#q.optimisedImage#"]<cfif currentRow LT q.RecordCount>,<cfset currentrow = currentrow + 1></cfif>
	</cfloop>
);
</cfoutput>