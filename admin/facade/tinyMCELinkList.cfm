<cfsetting enablecfoutputonly="true" />
<cfsetting showdebugoutput="false" />

<!--- <cfset oTree = createObject("component","#application.packagepath#.farcry.tree")>
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
</cfoutput> --->



<cfset oTree = createObject("component","#application.packagepath#.farcry.tree")>
<cfset qSiteMap = oTree.getDescendants(objectid='#application.navid.home#',bIncludeSelf=1)>

<cfset qRelated = queryNew("blah") /><!--- This will contain the list of  --->
<cfset aAllRelated = arrayNew(1) />

<cfif structKeyExists(application.stcoapi, url.typename)>
	<cfif listLen(url.relatedTypenames)>
		
		<cfset stObject = createObject("component", application.stcoapi["#url.typename#"].packagePath).getData(objectid=url.objectid) />
		
		<cfloop list="#structKeyList(application.stcoapi[url.typename].stprops)#" index="iField">
			<cfif application.stcoapi[url.typename].stprops[iField].metadata.type EQ "array">
				<cfif arrayLen(stObject[iField])>
					<cfloop from="1" to="#arrayLen(stObject[iField])#" index="iArrayItem">
						<cfset arrayAppend(aAllRelated, stObject[iField][iArrayItem]) />
					</cfloop>
				</cfif>
				
			</cfif>
		</cfloop>
		
		<cfif arrayLen(aAllRelated)>
			
				
			<cfquery datasource="#application.dsn#" name="qRelated">

				<cfloop list="#url.relatedTypenames#" index="iTypename">					
					
					SELECT r.objectid, t.label 
					FROM refObjects r 
					INNER JOIN #iTypename# t ON t.objectid = r.objectid
					WHERE r.objectid IN (#ListQualify(arrayToList(aAllRelated), "'")#)
					AND r.typename = '#iTypename#'
					
					<cfif iTypename NEQ listLast(url.relatedTypenames)>UNION</cfif>
					
				</cfloop>

			</cfquery>
		</cfif>
	</cfif>
</cfif>


<cfset inc = 0>
	
	
<cfoutput>
// This list may be created by a server logic page PHP/ASP/ASPX/JSP in some backend system.
// There links will be displayed as a dropdown in all link dialogs if the "external_link_list_url"
// option is defined in TinyMCE init.

var tinyMCELinkList = new Array(
	// Name, URL
</cfoutput>

	
	<cfif qRelated.recordCount>
		<cfoutput>["--- RELATED OBJECTS ---", ""],
		</cfoutput>
		
		<cfloop query="qRelated">
			<cfset inc = inc + 1>
			<cfoutput>["#qRelated.label#", "#application.url.webroot#/index.cfm?objectid=#qRelated.objectid#"]<cfif inc LT qSiteMap.RecordCount + qRelated.RecordCount>,</cfif>
			</cfoutput>
		</cfloop>
		
	</cfif>
	
	<cfif qSiteMap.recordCount>	
		<cfoutput>["--- NAVIGATION TREE ---", ""],
		</cfoutput>
		
		<cfloop query="qSiteMap">		
			<cfset inc = inc + 1>
			<cfoutput>["#RepeatString('-', qSiteMap.nLevel)# #qSiteMap.objectname#", "#application.url.webroot#/index.cfm?objectid=#qSiteMap.objectid#"]<cfif inc LT qSiteMap.RecordCount + qRelated.RecordCount>,</cfif>
			</cfoutput>
		</cfloop>
		
	</cfif>
	
<cfoutput>
);
</cfoutput>

<cfsetting enablecfoutputonly="false" />
