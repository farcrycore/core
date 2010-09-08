<cfsetting enablecfoutputonly="true" />

<!--- 
@@displayName: Tray Details
@@description: The summary details of an object that are shown in the system tray.
 --->

	
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />


<!--- If the url points to a type webskin, we need to determine the content type. --->
<cfif stObj.typename eq "farCOAPI">
	<cfset contentTypename = stobj.name />
<cfelse>
	<cfset contentTypename = stobj.typename />
</cfif>
	
<cfoutput>
<table>
<tr>
	<th>Type of Content</th>
	<td>#application.fapi.getContentTypeMetadata(typename='#contentTypename#', md='displayName', default='#stobj.typename#')#</td>
</tr>
<tr>
	<th>Label</th>
	<td>#stobj.label#</td>
</tr>
<tr>
	<th>View</th>
	<td>#application.fapi.getWebskinDisplayName(stobj.typename, arguments.stParam.view)#</td>
</tr>
<tr>
	<th>Body View</th>
	<td>#application.fapi.getWebskinDisplayName(stobj.typename, arguments.stParam.bodyView)#</td>
</tr>

<cfif structKeyExists(stobj, "lastupdatedby")>
	<cfset stLastUpdatedBy = application.fapi.getContentType("dmProfile").getProfile(stobj.lastupdatedby) />
	<tr>
		<th>#getI18Property('lastupdatedby','label')#</th>
		<td>#stLastUpdatedBy.Label# (#application.fapi.prettyDate(stobj.datetimelastupdated)#)</td>
	</tr>
</cfif>
</table>
</cfoutput>
<cfsetting enablecfoutputonly="false" />