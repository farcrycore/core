<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Stack --->
<!--- @@seq: 900 --->

<cfdbinfo type="version" datasource="#application.dsn#" name="dbinfo">
<cfset stJava = CreateObject("java", "java.lang.System").getProperties()>

<cfoutput>
	<table class="table">
		<thead>
			<tr>
				<th style="width:220px;">Component</th>
				<th>Value</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td>Operating System</td>
				<td>#stJava['os.name']# #stJava['os.version']# (#stJava['os.arch']#)</td>
			</tr>
			<tr>
				<td>Java Version</td>
				<td>#stJava['java.runtime.version']#</td>
			</tr>
			<tr>
				<td>CFML Engine</td>
				<td>
					<cfif structKeyExists(server, "lucee")>
						#server.coldfusion.productname# #server.lucee.version# (#server.lucee.state#) (Compatible #server.coldfusion.productversion#)
					<cfelseif structKeyExists(server, "railo")>
						#server.coldfusion.productname# #server.railo.version# (#server.railo.state#) (Compatible #server.coldfusion.productversion#)
					<cfelse>
						#server.coldfusion.productname# #server.coldfusion.productversion#
					</cfif>
				</td>
			</tr>
			<tr>
				<td>Database</td>
				<td>#dbinfo.DATABASE_PRODUCTNAME# #dbinfo.DATABASE_VERSION#</td>
			</tr>
			<tr>
				<td>Database Driver</td>
				<td>#dbinfo.DRIVER_VERSION#</td>
			</tr>
			<tr>
				<td>Timezone</td>
				<td>#stJava['user.timezone']#</td>
			</tr>
		</tbody>
	</table>
</cfoutput>


<cfsetting enablecfoutputonly="false">