<cfset alterType = createObject("component","#application.packagepath#.farcry.alterType") />
<cfset migrateresult = "" />

<!--- SECURITY --->
<cfif NOT alterType.isCFCDeployed(typename="farUser")>
	<cfset alterType.deployCFC(typename="farUser") />
</cfif>
<cfif NOT alterType.isCFCDeployed(typename="farGroup")>
	<cfset alterType.deployCFC(typename="farGroup") />
</cfif>
<cfif NOT alterType.isCFCDeployed(typename="farRole")>
	<cfset alterType.deployCFC(typename="farRole") />
</cfif>
<cfif NOT alterType.isCFCDeployed(typename="farPermission")>
	<cfset alterType.deployCFC(typename="farPermission") />
</cfif>
<cfif NOT alterType.isCFCDeployed(typename="farBarnacle")>
	<cfset alterType.deployCFC(typename="farBarnacle") />
</cfif>

<cfquery datasource="#application.dsn#">
	delete from #application.dbowner#farRole
	delete from #application.dbowner#farRole_groups
	delete from #application.dbowner#farRole_permissions
	delete from #application.dbowner#farUser
	delete from #application.dbowner#farUser_groups
	delete from #application.dbowner#farGroup
	delete from #application.dbowner#farPermission
	delete from #application.dbowner#farBarnacle
</cfquery>

<cfset application.security = createobject("component","farcry.core.packages.security.security").init() />
<cfset migrateresult = createobject("component","farcry.core.packages.security.FarcryUD").migrate() />

<cfoutput><p>#migrateresult#</p></cfoutput>