<cfset request.bLoggedIn = "true">
<cftry>
<!--- Try to include apps.cfm from the farcry directory --->
<cfinclude template="/farcry/apps.cfm">
<cfinclude template="/farcry/#stApps[cgi.server_name]#/www/Application.cfm">

	<cfcatch>
		<cfinclude template="/Application.cfm">
	</cfcatch>
</cftry>

<!--- <cfapplication name="farcry_core_updater" sessionmanagement="Yes">

<cfscript>
	application.dsn = "farcry";
	application.path.core = "c:\inetpub\applications\farcry_core";
	application.path.project = "c:\inetpub\applications\farcry_project";
	application.packagepath = "farcry_core.packages";
	application.urlwebroot = "";
	
	// --- Initialise the policy store ---
	Application.dmSec.PolicyStore = StructNew();
	ps = Application.dmSec.PolicyStore;
	ps.dataSource = application.dsn;
	ps.permissionTable = "dmPermission";
	ps.policyGroupTable = "dmPolicyGroup";
	ps.permissionBarnacleTable = "dmPermissionBarnacle";
	ps.externalGroupToPolicyGroupTable = "dmExternalGroupToPolicyGroup";
</cfscript>

<!--- get rode nav node --->
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">
<nj:NavigationIds> --->