<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Dashboard Pending Content --->
<!--- @@viewstack: fragment --->
<!--- @@viewbinding: type --->
<!--- @@cardClass: fc-dashboard-card-medium --->
<!--- @@cardHeight: 400px --->
<!--- @@seq: 200 --->



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
<cfoutput>
<i class="fa fa-question-circle fa-lg pull-right" title="Content items pending approval"></i>
<h3>Content Pending Approval</h3>
</cfoutput>

<cfif qPending.recordcount>
	
	<cfoutput>	
		<table class="table table-striped">
			<thead>
				<tr>			
					<th>Type</th>
					<th>Label</th>
					<th>Updated</th>
				</tr>
			</thead>
			
			<tbody>
	</cfoutput>
	
	<cfoutput query="qPending">
		<tr>
			<td><i class="fa #application.fapi.getContentTypeMetadata(typename="#qPending.typename#", md="icon", default="fa-file-text")# fa-lg" title="#application.fapi.getContentTypeMetadata(typename="#qPending.typename#", md="displayname", default="Unknown")#"></i></td>
			<td><skin:buildlink href="#application.url.webtop#/edittabOverview.cfm?objectid=#qpending.objectid#&typename=#qpending.typename#" bmodal="true" linktext="#qPending.label#" title="Editing: #qPending.label#" /></td>
			<td nowrap="true">#application.fapi.prettyDate(qPending.datetimelastupdated)#</td>
		</tr>
	</cfoutput>
	
	<cfoutput>
			</tbody>
		</table>
	</cfoutput>
<cfelse>
	<cfoutput><p>You don't have any content pending approval.</p></cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false" />