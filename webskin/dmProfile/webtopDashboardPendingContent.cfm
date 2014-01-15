<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Dashboard Pending Content --->
<!--- @@viewstack: fragment --->
<!--- @@viewbinding: type --->
<!--- @@cardClass: fc-dashboard-card-large --->
<!--- @@seq: 90 --->

<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<cfset stProfile = application.fapi.getCurrentUser() />
<cfset dashboard = application.fapi.getcontenttype("dashboard") />
<cfset qPending = dashboard.getPendingContent() />


<cfoutput>
<div style="padding: 0 6px;">

	<i class="fa fa-question-circle fa-lg pull-right" style="margin-top:6px" title="Content items pending approval"></i>
	<h3>Content Pending Approval</h3>

	<cfif qPending.recordcount>
		<table class="table table-striped">
			<thead>
				<tr>			
					<th>Type</th>
					<th>Label</th>
					<th>Updated</th>
				</tr>
			</thead>
			<tbody>
				<cfloop query="qPending">
					<tr>
						<td><i class="fa #application.fapi.getContentTypeMetadata(typename="#qPending.typename#", md="icon", default="fa-file-text")# fa-lg" title="#application.fapi.getContentTypeMetadata(typename="#qPending.typename#", md="displayname", default="Unknown")#"></i></td>
						<td><skin:buildLink href="#application.url.webtop#/edittabOverview.cfm?objectid=#qpending.objectid#&typename=#qpending.typename#" bmodal="true" linktext="#qPending.label#" title="Editing: #qPending.label#" /></td>
						<td nowrap="true">#application.fapi.prettyDate(qPending.datetimelastupdated)#</td>
					</tr>
				</cfloop>
			</tbody>
		</table>
	<cfelse>
		<p>You don't have any content pending approval.</p>
	</cfif>

</div>
</cfoutput>

<cfsetting enablecfoutputonly="false">