<cfsetting enablecfoutputonly="true" />
<cfsetting showdebugoutput="false" />

<cfset qImages = queryNew("")>

<!--- Get the related images --->
<cfset qRelatedImages = application.fapi.getRelatedContent(	objectid="#url.relatedObjectid#", 
															typename="#url.relatedTypename#", 
															filter="#url.ftImageListFilterTypename#"
															) />

<cfif qRelatedImages.recordCount>
	<!--- Get the information for the array to be passed back. --->
	<cfquery datasource="#application.dsn#" name="qImages">
	SELECT objectid,label,#url.ftImageListFilterProperty# as image
	FROM #url.ftImageListFilterTypename#
	WHERE ObjectID IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#valueList(qRelatedImages.objectid)#">)
	</cfquery>
</cfif>

<cfset oType = createObject("component", application.types[url.ftImageListFilterTypename].packagePath) />

<cfoutput>
var tinyMCEImageList = new Array(
	// Name, URL	
	<cfloop query="qImages">
		["<cfif len(qImages.label)>#qImages.label#<cfelse>#qImages.image#</cfif>", "#oType.getFileLocation(objectid=qImages.objectid, fieldname=url.ftImageListFilterProperty).path#"]<cfif qImages.currentRow LT qImages.RecordCount>,</cfif>
	</cfloop>
);
</cfoutput>


<cfsetting enablecfoutputonly="false" />