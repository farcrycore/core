<cfsetting enablecfoutputonly="true" />

<!--- 
@@displayName: Tray Details
@@description: The summary details of an object that are shown in the system tray.
 --->

	
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- If the url points to a type webskin, we need to determine the content type. --->
<cfif stObj.typename eq "farCOAPI">
	<cfset contentTypename = stobj.name />
<cfelse>
	<cfset contentTypename = stobj.typename />
</cfif>
	
<cfoutput>
<table>
<tr><td>
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
</td>

<cfif structkeyexists(form,"profile")>
	<cfwddx action="wddx2cfml" input="#form.profile#" output="stLocal.profile" />
	<cfwddx action="wddx2cfml" input="#form.log#" output="stLocal.log" />
	<td>
		<div id="info-picker">
			<a href="##" onclick="$j('div.request-html').hide();$j(this.rel).show();return false;" rel="##request-profile-html">Profiling</a> |
			<a href="##" onclick="$j('div.request-html').hide();$j(this.rel).show();return false;" rel="##request-log-html">Log</a>
		</div>
		<div id="request-profile-html" class="request-html">#application.fapi.getProfileHTML(stLocal.profile)#</div>
		<div id="request-log-html" class="request-html" style="display:none;">#application.fapi.getRequestLogHTML(stLocal.log)#</div>
	</td>
</cfif>
</tr></table>
</cfoutput>
<cfsetting enablecfoutputonly="false" />