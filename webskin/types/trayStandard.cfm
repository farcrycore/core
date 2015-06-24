<cfsetting enablecfoutputonly="true" />

<!--- 
@@displayName: Tray Details
@@description: The summary details of an object that are shown in the system tray.
 --->

	
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="arguments.stParam" default="#url#">
<cfparam name="arguments.stParam.view" default="">
<cfparam name="arguments.stParam.bodyView" default="">


<!--- If the url points to a type webskin, we need to determine the content type. --->
<cfif stObj.typename eq "farCOAPI">
	<cfset contentTypename = stobj.name />
<cfelse>
	<cfset contentTypename = stobj.typename />
</cfif>
	
<cfoutput>
<div class="farcryTrayBodyContentDetails">	

<cfif structkeyexists(form,"profile")>
	<cfwddx action="wddx2cfml" input="#form.profile#" output="stLocal.profile" />
	<cfwddx action="wddx2cfml" input="#form.log#" output="stLocal.log" />
		<div id="info-picker">
			<a href="##" onclick="$j('div.request-html').hide();$j(this.rel).show();return false;" rel="##request-profile-html"><admin:resource key='tray.profile.profiling@title'>Profiling</admin:resource></a> |
			<a href="##" onclick="$j('div.request-html').hide();$j(this.rel).show();return false;" rel="##request-log-html"><admin:resource key='tray.profile.log@title'>Log</admin:resource></a>
		</div>
		<div id="request-profile-html" class="request-html">#application.fapi.getProfileHTML(stLocal.profile)#</div>
		<div id="request-log-html" class="request-html" style="display:none;">#application.fapi.getRequestLogHTML(stLocal.log)#</div>

<cfelse>


	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<th><admin:resource key='tray.summary.contenttype@label'>Content Type</admin:resource></th>
		<td><admin:resource key='coapi.#contentTypename#@label'>#application.fapi.getContentTypeMetadata(typename='#contentTypename#', md='displayName', default='#stobj.typename#')#</admin:resource></td>
	</tr>
	<tr>
		<th><admin:resource key='tray.summary.label@label'>Label</admin:resource></th>
		<td>#stobj.label#</td>
	</tr>
	<tr>
		<th><admin:resource key='tray.summary.pageview@label'>Page View</admin:resource></th>
		<td>#application.fc.lib.esapi.encodeForHTML(application.fapi.getWebskinDisplayName(stobj.typename, arguments.stParam.view))# (#application.fc.lib.esapi.encodeForHTML(arguments.stParam.view)#)</td>
	</tr>
	<tr>
		<th><admin:resource key='tray.summary.bodyview@label'>Body View</admin:resource></th>
		<td>#application.fc.lib.esapi.encodeForHTML(application.fapi.getWebskinDisplayName(stobj.typename, arguments.stParam.bodyView))# (#application.fc.lib.esapi.encodeForHTML(arguments.stParam.bodyView)#)</td>
	</tr>
	</table>

</cfif>

</div>

</cfoutput>
<cfsetting enablecfoutputonly="false" />