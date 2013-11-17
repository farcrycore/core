<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Dashboard Draft Content --->
<!--- @@viewstack: fragment --->
<!--- @@viewbinding: type --->
<!--- @@cardClass: fc-dashboard-card-medium --->



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

<skin:tooltip selector="##tip_contentInDraft"><cfoutput>
	<p>These are content items where:</p>
	<ul>
		<li>They are in draft</li>
		<li>You were the last one to save them while in draft</li>
	</ul>
</cfoutput></skin:tooltip>

<cfoutput><h3>Content You Have In Draft <i id="tip_contentInDraft" class="fa fa-info"></i></h3></cfoutput>

<cfif qdraft.recordcount>
	
	<cfoutput>
		
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
	
	<cfoutput query="qdraft">
		<tr class="#IIF(qDraft.currentrow MOD 2, de("alt"), de(""))#">
			<td nowrap="true">#application.fapi.getContentTypeMetadata(typename="#qDraft.typename#", md="displayname", default="Unknown")#</td>
			<td><a href="#application.url.webtop#/edittabOverview.cfm?objectid=#qdraft.objectid#&typename=#qdraft.typename#">#qdraft.label#</a></td>
			<td nowrap="true">#application.fapi.prettyDate(qDraft.datetimelastupdated)#</td>
		</tr>
	</cfoutput>
	
	<cfoutput>
			</tbody>
		</table>
	</cfoutput>
<cfelse>
	<cfoutput>No items in draft.</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false" />