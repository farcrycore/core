<cfoutput>
	<link rel="stylesheet" type="text/css" href="#application.url.farcry#/css/admin.css">
</cfoutput>

<cfset permission = "Approved">
<cfset versionTypes = "dmHTML"><!--- List of dm Types that we actually version --->

<h3>Draft -> live test harness</h3>

<cfloop list="#versionTypes#" index="i">
<table width="100%" cellpadding="5">
<tr>
	<td>
	<cfoutput><strong>#i#</strong></cfoutput>
	<table width="100%">
	<tr>
		<td>
			ObjectID
		</td>
		<td>
			Label
		</td>
		<td>
			Approve
		</td>
	</tr>
	<cfquery datasource="#application.dsn#" name="qGetDrafts">
		SELECT * FROM #i# where versionID <> NULL OR versionID <> ''
	</cfquery>
	<cfif qGetDrafts.recordCount GT 0>
		<cfoutput query="qGetDrafts">
		<tr>
			<td>
				#objectID#
			</td>
			<td>
				#label#
			</td>
			<td>
				<a href="navajo/approve.cfm?objectID=#objectID#&status=approved">approve</a>
			</td>
		</tr>
		</cfoutput>
	<cfelse>
		<tr>
			<td colspan="3" align="center">
				No live objects with drafts for <cfoutput>#i#</cfoutput>
			</td>
		</tr>	
	</cfif>
	</table>
	</td>
</tr>
</table>	
</cfloop>
<!---  <cfdump var="#server#"> --->
<!---<cfdump var="#application#">
 --->
