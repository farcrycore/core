<cfsetting enablecfoutputonly="true" />
<cfsetting showdebugoutput="false" />


<!--- Get the site map --->
<cfset oTree = createObject("component","#application.packagepath#.farcry.tree")>
<cfset qSiteMap = oTree.getDescendants(objectid="#application.fapi.getNavID('home')#", bIncludeSelf=1)>


<!--- Get the related images --->
<cfset qRelatedContent = application.fapi.getRelatedContent(	objectid="#url.relatedObjectid#", 
																typename="#url.relatedTypename#", 
																filter="#url.ftLinkListFilterTypenames#"
																) />

<!--- We wont know what list of related typenames we have so we need to do that manually. --->
<cfquery dbtype="query" name="qRelatedTypes">
SELECT distinct typename
FROM qRelatedContent
</cfquery>
<cfset relatedTypenameList = valueList(qRelatedTypes.typename) />


<!--- Initialize the related query --->
<cfset qRelatedWithLabels = queryNew("objectid,label") />



<!--- Need to retrieve the labels for each of the related content --->
<cfif qRelatedContent.recordCount>
	
	<cfquery datasource="#application.dsn#" name="qRelatedWithLabels">

		<cfloop list="#relatedTypenameList#" index="iTypename">					
			
			SELECT r.objectid, t.label 
			FROM refObjects r 
			INNER JOIN #iTypename# t ON t.objectid = r.objectid
			WHERE r.objectid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#valueList(qRelatedContent.objectid)#" />)
			AND r.typename = '#iTypename#'
			
			<cfif iTypename NEQ listLast(relatedTypenameList)>UNION</cfif>
			
		</cfloop>

	</cfquery>	
</cfif>


<cfset inc = 0>
	
	
<cfoutput>
var tinyMCELinkList = new Array(
	// Name, URL
</cfoutput>

	
	<cfif qRelatedWithLabels.recordCount>
		<cfoutput>["--- RELATED CONTENT ---", ""],
		</cfoutput>
		
		<cfloop query="qRelatedWithLabels">
			<cfset inc = inc + 1>
			<cfset urlLink = application.fapi.getLink(objectid="#qRelatedWithLabels.objectid#") />
			<cfoutput>["#jsstringformat(qRelatedWithLabels.label)#", "#urlLink#"]<cfif inc LT qSiteMap.RecordCount + qRelatedWithLabels.RecordCount>,</cfif>
			</cfoutput>
		</cfloop>
		
	</cfif>
	
	<cfif qSiteMap.recordCount>	
		<cfoutput>["--- NAVIGATION TREE ---", ""],
		</cfoutput>
		
		<cfloop query="qSiteMap">		
			<cfset inc = inc + 1>
			<cfset urlLink = application.fapi.getLink(objectid="#qSiteMap.objectid#") />
			<cfoutput>["#RepeatString('-', qSiteMap.nLevel)# #jsstringformat(qSiteMap.objectname)#", "#urlLink#"]<cfif inc LT qSiteMap.RecordCount + qRelatedWithLabels.RecordCount>,</cfif>
			</cfoutput>
		</cfloop>
		
	</cfif>
	
<cfoutput>
);
</cfoutput>


<cfsetting enablecfoutputonly="false" />