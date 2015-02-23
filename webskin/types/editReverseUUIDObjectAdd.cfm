<!--- @@Viewstack: body --->
<!--- @@Viewbinding: object --->


<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<cfparam name="url.reverseUUIDProperty" />

<cfset stPropMetadata = application.fapi.getPropertyMetadata(	typename="#stobj.typename#",
																property="#url.reverseUUIDProperty#") />

<cfset stProperties = structNew() />
<cfset stProperties.typename = stPropMetadata.ftJoin />
<cfset stProperties.objectid = application.fapi.getUUID() />
<cfset stProperties[stPropMetadata.ftJoinProperty] = stobj.objectid />

<cfset stResult = application.fapi.setData(stProperties="#stProperties#", bSessionOnly="true") />


<skin:location 	type="#stProperties.typename#" 
				objectid="#stProperties.objectid#" 
				view="#stPropMetadata.ftEditView#" 
				bodyView="#stPropMetadata.ftEditBodyView#"
				urlParameters="dialogID=#url.dialogID#&iframe=1" />
