<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Stack --->
<!--- @@seq: 900 --->

<cfdbinfo type="version" datasource="#application.dsn#" name="dbinfo">
<cfset stJava = CreateObject("java", "java.lang.System").getProperties()>

<cfoutput>
	<table class="table table-bordered">
		<tbody>
			<tr>
				<th>Operating System</th>
				<td>#stJava['os.name']# #stJava['os.version']# (#stJava['os.arch']#)</td>
			</tr>
			<tr>
				<th>Java Version</th>
				<td>#stJava['java.runtime.version']#</td>
			</tr>
			<tr>
				<th>ColdFusion Engine</th>
				<td>#server.coldfusion.productname# #server.coldfusion.productversion#</td>
			</tr>
			<tr>
				<th>Database</th>
				<td>#dbinfo.DATABASE_PRODUCTNAME# #dbinfo.DATABASE_VERSION#</td>
			</tr>
			<tr>
				<th>Database Driver</th>
				<td>#dbinfo.DRIVER_VERSION#</td>
			</tr>
			<tr>
				<th>Timezone</th>
				<td>#stJava['user.timezone']#</td>
			</tr>
		</tbody>
	</table>
</cfoutput>

<!---
<cfdump var="#server.coldfusion#" label="CFML Engine">
<cfdump var="#dbinfo#" label="Database">
<cfdump var="#CreateObject("java", "java.lang.System").getProperties()#" />
--->

<cfsetting enablecfoutputonly="false">