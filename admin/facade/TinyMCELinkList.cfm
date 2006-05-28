<cfset oTree = createObject("component","#application.packagepath#.farcry.tree")>
<cfset qSiteMap = oTree.getDescendants(objectid='#application.navid.home#',bIncludeSelf=1)>


<cfoutput>
// This list may be created by a server logic page PHP/ASP/ASPX/JSP in some backend system.
// There links will be displayed as a dropdown in all link dialogs if the "external_link_list_url"
// option is defined in TinyMCE init.

var tinyMCELinkList = new Array(
	// Name, URL
	
	<cfset currentrow = 1>
	<cfloop query="qSiteMap">		
		["#RepeatString('-', qSiteMap.nLevel)# #qSiteMap.objectname#", "#application.url.webroot#/index.cfm?objectid=#qSiteMap.objectid#"]<cfif currentRow LT qSiteMap.RecordCount>,<cfset currentrow = currentrow + 1></cfif>
	</cfloop>
	
);
</cfoutput>