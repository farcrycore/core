<cfsetting enablecfoutputonly="true" />
<cfsetting showdebugoutput="false" />

<cfparam name="url.ftImageListFilterTypename" default="">
<cfparam name="url.ftImageListFilterProperty" default="">
<cfparam name="url.relatedObjectid" default="">
<cfparam name="url.relatedTypename" default="">


<cfset qImages = queryNew("")>

<cfset bValid = true>

<cfif NOT isValid("uuid", url.relatedObjectid)>
	<cfset bValid = false>
<cfelseif NOT len(url.ftImageListFilterTypename) OR NOT len(url.ftImageListFilterProperty)>
	<cfset bValid = false>
<cfelse>
	<cfset stRelatedType = application.fapi.getContentTypeMetadata(typename=url.ftImageListFilterTypename)>
	<cfif NOT isStruct(stRelatedType) OR structIsEmpty(stRelatedType)>
		<cfset bValid = false>
	</cfif>
	<cfset stImageListFilterProp = application.fapi.getPropertyMetadata(typename=url.ftImageListFilterTypename, property=url.ftImageListFilterProperty)>
	<cfif NOT isStruct(stImageListFilterProp) OR structIsEmpty(stImageListFilterProp)>
		<cfset bValid = false>
	</cfif>
</cfif>


<cfif bValid>

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
	<cfset oType = createObject("component", application.types[url.ftImageListFilterTypename].packagePath) />
	</cfif>

</cfif>


<cfoutput>
var tinyMCEImageList = new Array(
	// Name, URL	
	<cfloop query="qImages">
		["<cfif len(qImages.label)>#qImages.label#<cfelse>#qImages.image#</cfif>", "#oType.getFileLocation(objectid=qImages.objectid, fieldname=url.ftImageListFilterProperty).path#"]<cfif qImages.currentRow LT qImages.RecordCount>,</cfif>
	</cfloop>
);
</cfoutput>


<cfsetting enablecfoutputonly="false" />