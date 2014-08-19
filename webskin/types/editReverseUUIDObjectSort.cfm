
<!--- @@viewStack: data --->
<!--- @@mimeType: json --->
<!--- @@Viewbinding: object --->



<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<cfparam name="url.reverseUUIDProperty" />
<cfparam name="form.lSortOrderIDs" default="" />

<cfset stPropMetadata = application.fapi.getPropertyMetadata(	typename="#stobj.typename#",
																property="#url.reverseUUIDProperty#") />


<cfquery name="q" datasource="#application.dsn#">
	SELECT objectID,seq
	FROM #stPropMetadata.ftJoin#
	WHERE #stPropMetadata.ftJoinProperty# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stobj.objectid#" />
</cfquery>

<cfset counter = 0 />
<cfloop list="#form.lSortOrderIDs#" index="i">

	<cfset counter = counter + 1 />
	<cfset stResult = application.fapi.setData(	typename="#stPropMetadata.ftJoin#",
												objectid="#i#",
												seq="#counter#") />
	
</cfloop>

<cfset stResult = application.fapi.success("Sorting Complete") />


<cfoutput>#serializeJSON(stResult)#</cfoutput>
