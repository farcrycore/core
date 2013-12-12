<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Dashboard Draft Content --->
<!--- @@viewstack: fragment --->
<!--- @@viewbinding: type --->
<!--- @@cardClass: fc-dashboard-card-medium --->
<!--- @@cardHeight: 400px --->



<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<!--- 
 // get all draft content for current user 
--------------------------------------------------------------------------------->
<cfset stProfile = application.fapi.getCurrentUser() />
<cfset dashboard = application.fapi.getcontenttype("dashboard") />
<cfset qDraft = dashboard.getDraftContent(lastupdatedby=stProfile.userName) />


<!--- 
 // show draft content 
--------------------------------------------------------------------------------->
<cfoutput>
<i class="fa fa-question-circle fa-lg pull-right" title="You were the last one to save them while in draft"></i>
<h3>Content You Have In Draft</h3></cfoutput>

<cfif qdraft.recordcount>
	
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
	
	<cfoutput query="qdraft">
		<tr>
			<td><i class="fa #application.fapi.getContentTypeMetadata(typename="#qDraft.typename#", md="icon", default="fa-file-text")# fa-lg" title="#application.fapi.getContentTypeMetadata(typename="#qDraft.typename#", md="displayname", default="Unknown")#"></i></td>
			<td><skin:buildlink href="#application.url.webtop#/edittabOverview.cfm?objectid=#qdraft.objectid#&typename=#qdraft.typename#" linktext="#qdraft.label#" title="Editing: #qdraft.label#" bmodal="true" /></td>
			<td nowrap="true">#application.fapi.prettyDate(qDraft.datetimelastupdated)#</td>
		</tr>
	</cfoutput>
	
	<cfoutput>
			</tbody>
		</table>
	</cfoutput>
<cfelse>
	<cfoutput><p>You don't have any content in draft.</p></cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false" />