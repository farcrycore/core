<cfsetting enablecfoutputonly="Yes">

<cfscript>
//Init Application dmsec scope
Application.dmSec=StructNew();
// --- Initialise the userdirectories ---
Application.dmSec.UserDirectory = structNew();

// Client User Directory
Application.dmSec.UserDirectory.ClientUD = structNew();
temp = Application.dmSec.UserDirectory.ClientUD;
temp.type = "Daemon";
temp.datasource = application.dsn;

//Policy Store settings
Application.dmSec.PolicyStore = StructNew();
ps = Application.dmSec.PolicyStore;
ps.dataSource = application.dsn;
ps.permissionTable = "dmPermission";
ps.policyGroupTable = "dmPolicyGroup";
ps.permissionBarnacleTable = "dmPermissionBarnacle";
ps.externalGroupToPolicyGroupTable = "dmExternalGroupToPolicyGroup";
</cfscript>

<cfsetting enablecfoutputonly="no">
