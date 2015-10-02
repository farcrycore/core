<cfsetting enablecfoutputonly="true">

<cfset qGateways = application.fc.lib.db.getGatewayProperties() />

<cfoutput>
	<h1>Database Gateways</h1>

	<table class="table table-striped">
		<thead>
			<th>DSN</th>
			<th>DB Owner</th>
			<th>DB Type</th>
			<th>Read</th>
			<th>Write</th>
		</thead>
		<tbody>
</cfoutput>

<cfoutput query="qGateways">
	<tr>
		<td>#qGateways.dsn#</td>
		<td>#qGateways.dbowner#</td>
		<td><span title="#qGateways.dbtype#">#qGateways.dbtype_label#</span></td>
		<cfif qGateways.read>
			<td><span class="text-success">Yes</span></td>
		<cfelse>
			<td><span class="text-error">No</span></td>
		</cfif>
		<cfif qGateways.write>
			<td><span class="text-success">Yes</span></td>
		<cfelse>
			<td><span class="text-error">No</span></td>
		</cfif>
	</tr>
</cfoutput>

<cfoutput>
		</tbody>
	</table>
</cfoutput>

<cfsetting enablecfoutputonly="false">