<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Dashboard Pending Content --->
<!--- @@viewstack: fragment --->
<!--- @@viewbinding: type --->
<!--- @@cardClass: fc-card-medium --->


<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<!--- 
 // get all draft content for current user 
--------------------------------------------------------------------------------->
<cfset stProfile = application.fapi.getCurrentUser() />
<cfset dashboard = application.fapi.getcontenttype("dashboard") />
<cfset qPending = dashboard.getPendingContent() />


<!--- 
 // show pending content 
--------------------------------------------------------------------------------->
<cfif qPending.recordcount>
	<skin:tooltip selector="##tip_contentPending"><cfoutput>
		<p>Content items pending approval</p>
	</cfoutput></skin:tooltip>
	
	<cfoutput>
		<h3>Content Pending Approval <img id="tip_contentPending" src="#application.url.webtop#/images/tooltip.png" /></h3>
		<table width="100%" class="table table-striped">
			<thead>
				<tr>			
					<th>Type</th>
					<th>Label</th>
					<th>Last Updated</th>
				</tr>
			</thead>
			
			<tbody>
	</cfoutput>
	
	<cfoutput query="qPending">
		<tr class="#IIF(qPending.currentrow MOD 2, de("alt"), de(""))#">
			<td nowrap="true">#application.fapi.getContentTypeMetadata(typename="#qPending.typename#", md="displayname", default="Unknown")#</td>
			<td><a href="#application.url.webtop#/edittabOverview.cfm?objectid=#qpending.objectid#&typename=#qpending.typename#">#qPending.label#</a></td>
			<td nowrap="true">#application.fapi.prettyDate(qPending.datetimelastupdated)#</td>
		</tr>
	</cfoutput>
	
	<cfoutput>
			</tbody>
		</table>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false" />