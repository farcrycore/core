<cfsetting enablecfoutputonly="true" />
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<!--- 
 // DATA
--------------------------------------------------------------------------------------------------->
<cfset stProfile = application.fapi.getCurrentUser() />
<cfset dashboard = application.fapi.getcontenttype("dashboard") />
<cfset qDraft = dashboard.getDraftContent(lastupdatedby=stProfile.userName) />
<cfset qPending = dashboard.getPendingContent() />
<cfset qActivity = dashboard.getRecentActivity(maxrows=20) />
<cfset qReview = dashboard.getContentForReview(ownedby=stProfile.objectid) />

<!--- 
 // VIEW
--------------------------------------------------------------------------------------------------->
<admin:header>

<cfoutput>
<h1>Content Dashboard</h1>

<table width="100%">
<tr valign="top">
<td width="50%">
</cfoutput>
<!--- left hand column --->

<!--- Items in draft --->
<cfif qdraft.recordcount>
<skin:tooltip selector="##tip_contentInDraft">
  <cfoutput>
    <p>These are content items where:</p>
    <ul>
      <li>- They are in draft</li>
      <li>- You were the last one to save them while in draft</li>
    </ul>
  </cfoutput>
</skin:tooltip>
<cfoutput>
	<h3>Content You Have In Draft <img id="tip_contentInDraft" src="#application.url.webtop#/images/tooltip.png" /></h3>
	<table width="100%" class="objectAdmin">
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
</cfif>

<!--- Items to review --->
<cfif qReview.recordcount>
<skin:tooltip selector="##tip_contentReview">
  <cfoutput>
    <p>These are content items where:</p>
    <ul>
      <li>- You are currently set as the owner</li>
      <li>- The content's review date is past due</li>
    </ul>
  </cfoutput>
</skin:tooltip>
<cfoutput>
	<h3>Content You Need to Review <img id="tip_contentReview" src="#application.url.webtop#/images/tooltip.png" /></h3>
	<table width="100%" class="objectAdmin">
		<thead>
			<tr>			
				<th>Type</th>
				<th>Label</th>
				<th>Last Updated</th>
				<th>Review Date</th>
			</tr>
		</thead>

		<tbody>
		</cfoutput>
		<cfoutput query="qReview">
			<tr class="#IIF(qReview.currentrow MOD 2, de("alt"), de(""))#">
				<td nowrap="true">#application.fapi.getContentTypeMetadata(typename="#qReview.typename#", md="displayname", default="Unknown")#</td>
				<td><a href="#application.url.webtop#/edittabOverview.cfm?objectid=#qReview.objectid#&typename=#qReview.typename#">#qReview.label#</a></td>
				<td nowrap="true">#application.fapi.prettyDate(qReview.datetimelastupdated)#</td>
				<td nowrap="true">#application.fapi.prettyDate(qReview.reviewdate)#</td>
			</tr>
		</cfoutput>
		<cfoutput>
		</tbody>
	</table>
</cfoutput>
</cfif>

<!--- /left hand column --->
<cfoutput>
</td>
<td>&nbsp;&nbsp;</td>
<td width="50%">
</cfoutput>
<!--- right hand column --->

<!--- Items pending approval --->
<cfif qPending.recordcount>
<skin:tooltip selector="##tip_contentPending">
  <cfoutput>
    <p>Content items pending approval</p>
  </cfoutput>
</skin:tooltip>
<cfoutput>
	<h3>Content Pending Approval <img id="tip_contentPending" src="#application.url.webtop#/images/tooltip.png" /></h3>
	<table width="100%" class="objectAdmin">
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

<cfif qActivity.recordcount>
<skin:tooltip selector="##tip_contentActivity">
  <cfoutput>
    <p>Content items with recent activity</p>
  </cfoutput>
</skin:tooltip>
<cfoutput>
	<h3>Recent Activity <img id="tip_contentActivity" src="#application.url.webtop#/images/tooltip.png" /></h3>
	<table width="100%" class="objectAdmin">
		<thead>
			<tr>			
				<th>Type</th>
				<th>Label</th>
				<th>Note</th>
				<!--- <th>Event</th> --->
				<th>User</th>
				<th>Date</th>
			</tr>
		</thead>

		<tbody>
		</cfoutput>
		<cfoutput query="qActivity">
			<cfset eventTypename=application.fapi.findType(qActivity.object) />
			<cfif len(eventTypename) AND eventTypename neq "container">
				<tr class="#IIF(qactivity.currentrow MOD 2, de("alt"), de(""))#">
					<td nowrap="true">#application.fapi.getContentTypeMetadata(typename="#eventTypename#", md="displayname", default="Unknown")#</td>
					<td><a href="#application.url.webtop#/edittabOverview.cfm?objectid=#qactivity.object#&typename=#eventTypename#"><skin:view objectid="#qactivity.object#" webskin="displayLabel" typename="#eventTypename#" /></a></td>
					<td><cfif len(qactivity.notes)>#qActivity.notes#<cfelse>-</cfif></td>
					<!--- <td>#qActivity.event#</td> --->
					<td><cfif listlen(qActivity.userid, "_") gt 0>#listGetAt(qActivity.userid, 1, "_")#</cfif></td>
					<td nowrap="true">#application.fapi.prettyDate(qactivity.datetimelastupdated)#</td>
				</tr>
			</cfif>
		</cfoutput>
		<cfoutput>
		</tbody>
	</table>
</cfoutput>
</cfif>

<!--- /right hand column --->
<cfoutput>
</td>
</tr>
</table>
</cfoutput>

<!--- <skin:view typename="dashboard" webskin="webtopDashboard" /> --->

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="false" />