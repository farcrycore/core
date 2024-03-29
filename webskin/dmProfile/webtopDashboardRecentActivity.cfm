<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Dashboard Recent Activity --->
<!--- @@viewstack: fragment --->
<!--- @@viewbinding: type --->
<!--- @@cardClass: fc-dashboard-card-large --->
<!--- seq: 200 --->

<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<cfset stProfile = application.fapi.getCurrentUser() />
<cfset dashboard = application.fapi.getcontenttype("dashboard") />
<cfset qActivity = dashboard.getRecentActivity(maxrows=20) />


<cfset oProfile = application.fapi.getContentType("dmProfile")>

<cfoutput>
<div style="padding: 0 6px;">

	<i class="fa fa-question-circle fa-lg pull-right" style="margin-top:6px" title="Recent Activity"></i>
	<h3>Recent Activity</h3>

	<cfif qActivity.recordcount>
		<table class="table table-striped">
			<thead>
				<tr>			
					<th>Type</th>
					<th>Label</th>
					<th>Note</th>
					<th>User</th>
					<th>Date</th>
				</tr>
			</thead>
			<tbody>
				<cfloop query="qActivity"  >

					<cfset eventTypename=application.fapi.findType(qActivity.object) />
					<cfif len(eventTypename) AND eventTypename neq "container">
						<cftry>
						
							<cfset stActivityObject = application.fapi.getContentObject(qActivity.object,eventTypename) />
							<cfif structKeyExists(stActivityObject, "label") AND stActivityObject.label NEQ "(incomplete)">
								<cfset stProfile = oProfile.getProfile(qActivity.userid)>
								<tr>
									<td nowrap="true"><i class="fa #application.fapi.getContentTypeMetadata(typename="#stActivityObject.Typename#", md="icon", default="fa-file-text")# fa-lg" title="#application.fapi.getContentTypeMetadata(typename="#stActivityObject.Typename#", md="displayname", default="Unknown")#"></i> #stActivityObject.Typename#</td>
									<td><skin:buildLink href="#application.url.webtop#/edittabOverview.cfm?objectid=#qActivity.object#&typename=#stActivityObject.Typename#" bmodal="true" linktext="#stActivityObject.label#" title="Editing: #stActivityObject.label#" /></td>
									<td><cfif len(qactivity.notes)>#qActivity.notes#<cfelse>-</cfif></td>
									<td>#stProfile.label#</td>
									<td nowrap="true">#application.fapi.prettyDate(qactivity.datetimelastupdated)#</td>
								</tr>
							</cfif>
						
							<cfcatch>
								<tr>
									<td>#eventTypename#</td>
									<td><strong>Error</strong> for objectid '#qActivity.object#'<br />#CFCATCH.Message#. #CFCATCH.Detail#</td>
									<td><cfif len(qactivity.notes)>#qActivity.notes#<cfelse>-</cfif></td>
									<td nowrap="true">-</td>
									<td nowrap="true">#application.fapi.prettyDate(qactivity.datetimelastupdated)#</td>
								</tr>
							</cfcatch>
						</cftry>
					</cfif>

				</cfloop>
			</tbody>
		</table>
	<cfelse>
		<p>You don't have any content pending approval.</p>
	</cfif>

</div>
</cfoutput>

<cfsetting enablecfoutputonly="false">

