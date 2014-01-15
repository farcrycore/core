<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Dashboard Draft Content --->
<!--- @@viewstack: fragment --->
<!--- @@viewbinding: type --->
<!--- @@cardClass: fc-dashboard-card-large --->
<!--- @@seq: 80 --->

<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<cfset stProfile = application.fapi.getCurrentUser() />
<cfset dashboard = application.fapi.getcontenttype("dashboard") />
<cfset qDraft = dashboard.getDraftContent(lastupdatedby=stProfile.userName) />


<cfoutput>
<div style="padding: 0 6px;">

	<i class="fa fa-question-circle fa-lg pull-right" style="margin-top:6px" title="You were the last one to save them while in draft"></i>
	<h3>Your Draft Content</h3>

	<cfif qDraft.recordcount>
		<table class="table table-striped">
			<thead>
				<tr>			
					<th>Type</th>
					<th>Label</th>
					<th>Updated</th>
				</tr>
			</thead>
			<tbody>
				<cfloop query="qDraft">
					<tr>
						<td><i class="fa #application.fapi.getContentTypeMetadata(typename="#qDraft.typename#", md="icon", default="fa-file-text")# fa-lg" title="#application.fapi.getContentTypeMetadata(typename="#qDraft.typename#", md="displayname", default="Unknown")#"></i></td>
						<td><skin:buildLink href="#application.url.webtop#/edittabOverview.cfm?objectid=#qDraft.objectid#&typename=#qDraft.typename#" linktext="#qDraft.label#" title="Editing: #qDraft.label#" bmodal="true" /></td>
						<td nowrap="true">#application.fapi.prettyDate(qDraft.datetimelastupdated)#</td>
					</tr>
				</cfloop>
			</tbody>
		</table>
	<cfelse>
		<p>You don't have any content in draft.</p>
	</cfif>

</div>
</cfoutput>

<cfsetting enablecfoutputonly="false">