<cfsetting enableCFOutputOnly="Yes" requestTimeOut="600">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/install/index.cfm,v 1.49 2003/09/17 07:24:36 brendan Exp $
$Author: brendan $
$Date: 2003/09/17 07:24:36 $
$Name: b201 $
$Revision: 1.49 $

|| DESCRIPTION || 
$Description: Installation scripts for FarCry$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Peter Alexandrou (suspiria@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfparam name="url.dbonly" default="false" type="boolean">
<cfparam name="url.dsn" default="">
<cfparam name="url.dbtype" default="sql">
<cfparam name="url.dbowner" default="dbo.">
<cfparam name="url.sitename" default="farcry">

<cfparam name="form.appDsn" default="#url.dsn#">
<cfparam name="form.dbtype" default="#url.dbtype#">
<cfparam name="form.dbowner" default="#url.dbowner#">
<cfparam name="form.sitename" default="#url.sitename#">
<cfparam name="form.dbonly" default="#url.dbonly#">
<cfparam name="FORM.osType" default="server">
<cfparam name="FORM.hostName" default="">
<cfparam name="form.appMapping" default="/">
<cfparam name="form.farcryMapping" default="/farcry">
<cfparam name="form.domain" default="localhost">
<cfparam name="form.bDeleteApp" default="0">


<cfparam name="successMsg" default="<td>&nbsp;&nbsp;&nbsp;&nbsp;<span class=""success"">DONE</span></td></tr>#chr(13)##chr(10)#">
<cfparam name="failureMsg" default="<td>&nbsp;&nbsp;&nbsp;&nbsp;<span class=""failure"">FAILED!</span></td></tr>#chr(13)##chr(10)#">

<!--- include UDFs --->
<cfinclude template="_functions.cfm">

<!--- HTML header --->
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>farcry Install</title>
<link rel="STYLESHEET" type="text/css" href="installer.css">
</head>

<body bgcolor="##FFFFFF">
<div align="center">
<p><img src="farcry_logo.gif" alt="farcry" width="265" height="70" border="0" align="bottom"></p>
<p>Please complete the form below with your installation options...</p>
</cfoutput>

<cfif isDefined("form.proceed")>
    <cfif not isDefined("errorMsg")>

    <!--- begin try/catch clause --->
    <cftry>

    <cfoutput><p>Installing <strong>farcry</strong> content management system...</p></cfoutput>
    <cfflush>
		
    
			<!--- copy farcry_aura directory to new site name --->
		    <cfscript>
		    projectPath = replaceNoCase(replace(getCurrentTemplatePath(),"\","/","all"), "/farcry_core/admin/install/index.cfm", "") & "/farcry_aura";
		    newProjectPath = listDeleteAt(projectPath, listLen(projectPath, "/"), "/") & "/" & form.siteName;
			basePath = replaceNoCase(replace(getCurrentTemplatePath(),"\","/","all"), "/farcry_core/admin/install/index.cfm", "") & "";
		    </cfscript>
		
		<!--- Check if we are only supposed to be installing the database. If so,
		don't copy the directory --->
		<cfif not form.dbOnly>    
		
			<cf_copydirectory source="#projectPath#" destination="#newProjectPath#" copyrootdir="no" nameconflict="overwrite">	
		
		</cfif>
		
    <cfscript>
    application.path.project = newProjectPath;

    // CF datasources
    if (form.appDSN eq "createnew") {
        /* not feasible at this stage
        // remove any spacing in sitename to set DSN
        newDSN = "farcry_#replace(form.siteName, " ", "", "ALL")#";

        // add new datasource
        ds_service = application.o_serviceFactory.datasourceService;
        DSNs = ds_service.datasources;
        dump(DSNs);

        application.dsn = newDSN;
        */
    } else {
        application.dsn = form.appDSN;
        application.dbtype = form.dbType;
        application.dbowner = form.dbOwner;
     }

    //initialise the security structures
    application.dmSec = structNew();
    // --- Initialise the policy store ---
    application.dmSec.PolicyStore = structNew();
    ps = application.dmSec.PolicyStore;
    ps.dataSource = application.dsn;
    ps.permissionTable = "dmPermission";
    ps.policyGroupTable = "dmPolicyGroup";
    ps.permissionBarnacleTable = "dmPermissionBarnacle";
    ps.externalGroupToPolicyGroupTable = "dmExternalGroupToPolicyGroup";
    // --- Initialise the audit store ---
    Application.dmAud = structNew();
    Application.dmAud.dataSource = application.dsn;
    // --- Initialise the userdirectories ---
    Application.dmSec.UserDirectory = structNew();
    // Client User Directory
    Application.dmSec.UserDirectory.ClientUD = structNew();
    temp = Application.dmSec.UserDirectory.ClientUD;
    temp.type = "Daemon";
    temp.datasource = application.dsn;
    </cfscript>
		
		<!--- Check if we are only supposed to be installing the database --->
		<cfif not form.dbOnly>
	    <!--- install config files --->
	    <cfinclude template="_installConfigFiles.cfm">
		</cfif>
		
    <!--- install farcry --->
    <cfinclude template="_installFarcry.cfm">

    <!--- remove farcry_project directory --->
    <cfif directoryExists(projectPath) and form.bDeleteApp><cf_deletedirectory directory="#projectPath#"></cfif>

    <cfcatch type="Any">
			<cfdump var="#cfcatch#">
			<!--- Only rollback these steps if we were doing a full install --->
			<cfif not form.dbOnly>
		        <!--- delete project directory --->
		        <cfif directoryExists(newProjectPath)><cf_deletedirectory directory="#newProjectPath#"></cfif>
		
		        <cfscript>
		        // remove CF mappings
		        stMappings = application.o_mappings.showMappings();
		        if (structKeyExists(stMappings, "farcry")) application.o_mappings.deleteMapping(mapping="farcry");
		        </cfscript>
			</cfif>
				
    </cfcatch>

    </cftry>

    </cfif>

</cfif>

<cfif isDefined("errorMsg") OR not isDefined("form.proceed")>
    <!--- display form --->
    <cfinclude template="_installForm.cfm">
</cfif>

<cfoutput>
<p><font size="1">copyright &copy; 2003 . <a href="http://www.daemon.com.au" target="_blank">Daemon Internet Consultants</a></font></p>

</div>

</body>
</html>
</cfoutput>

<cfsetting enableCFOutputOnly="No">