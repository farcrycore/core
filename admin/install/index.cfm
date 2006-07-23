<cfsetting enableCFOutputOnly="Yes" requestTimeOut="600">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/install/index.cfm,v 1.58.2.1 2005/11/29 04:04:28 paul Exp $
$Author: paul $
$Date: 2005/11/29 04:04:28 $
$Name: milestone_3-0-1 $
$Revision: 1.58.2.1 $

|| DESCRIPTION || 
$Description: Installation scripts for FarCry$


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
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>FarCry Install</title>
<link rel="STYLESHEET" type="text/css" href="installer.css">
</head>

<body>
<div id="wrap">
<div class="logo"><img src="farcry_logo.gif" alt="FarCry CMS" width="220" height="95" border="0"></div>
</cfoutput>

<cfif isDefined("form.proceed")>
    <cfif not isDefined("errorMsg")>
	
	<!--- check if mysql check privledges are set correctly --->
	<cfif form.dbtype eq "mysql">
		<cftry>
			<!--- delete temp table --->
			<cfquery name="qDeleteTemp" datasource="#form.appDsn#">
				DROP TABLE IF EXISTS tblTemp1
			</cfquery>
			<cfcatch></cfcatch>
		</cftry>
		<cftry>
			<!--- test temp table creation --->
			<cfquery name="qTestPrivledges" datasource="#form.appDsn#">
				create temporary table `tblTemp1`
				(
				`test`  VARCHAR(255) NOT NULL
				)
			</cfquery>
			
			<cfcatch>
				<!--- display form with error message --->
				<cfset errorMsg = "You need to have Create_tmp_table_priv privilege set to true for your MySQL user">
 			   	<cfinclude template="_installForm.cfm">
				<cfabort>
			</cfcatch>
		</cftry>
	</cfif>
	
    <!--- begin try/catch clause --->
    <cftry>
		
    <cfoutput><p>Installing <strong>farcry</strong> content management system...</p></cfoutput>
    <cfflush>
		
    
			<!--- copy farcry_pliant directory to new site name --->
		    <cfscript>
		    projectPath = replaceNoCase(replace(getCurrentTemplatePath(),"\","/","all"), "/farcry_core/admin/install/index.cfm", "") & "/farcry_mollio";
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
	application.url.webroot = form.appMapping;
	application.url.farcry = form.farcryMapping;
    application.path.defaultImagePath = "#application.path.project#/www/images";
    application.path.defaultFilepath = "#application.path.project#/www/files";
	
	
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
		//check for valid dbOwner
		if (len(form.dbOwner) and right(form.dbOwner,1) neq ".") {
        	application.dbowner = form.dbOwner & ".";
		} else {
			application.dbowner = form.dbOwner;
		}
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
      <!--- Copied by bowden 7/23/2006. Copied from b301.cfm --->
      <cfoutput><p><span class="frameMenuBullet">&raquo;</span> Adding FCKEditor Custom Configurations File...</cfoutput><cfflush>
	
    	<cfset jsDirectoryPath = "#application.path.project#/www/js/" />
    	<cfset customFCKConfigFilePath = "#jsDirectoryPath#customfckconfig.js" />
    	
    	<cfif NOT directoryExists(jsDirectoryPath)>
    		<cfdirectory action="create" directory="#jsDirectoryPath#" />
    	</cfif>
    	
    	<cfif NOT fileExists(customFCKConfigFilePath)>
    		<cfset fckCustomConfigFileContent = "
/*
FCKEditor Custom Configurations File
=========================================================
Use this file to override the default FCKEditor configurations.
Information about the FCKEditor Custom Config can be found on the 
FCKEditor Wiki: 

http://wiki.fckeditor.net/Developer%27s_Guide/Configuration/Configurations_File

!!IF YOU DELETE OR MOVE THIS FILE YOU MUST UPDATE THE FCKEDITOR
CONFIG IN FARCRY/ADMIN/CONFIG_FILES
=========================================================
*/
		
		" />
  		<cffile action="write" file="#customFCKConfigFilePath#" output="#fckCustomConfigFileContent#">
  	</cfif>
    <cfoutput>COMPLETE</p></cfoutput><cfflush>
	  <!--- end of copy  --->
      <!--- Copied by bowden 7/23/2006. Copied from b301.cfm --->
    	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Create SourceImages, thumbnailImages and StandardImages directories...</cfoutput><cfflush>
        	<cftry>
      	
      		<cfif NOT directoryExists("#application.path.project#\www\images\Source\")>
      			<cfdirectory action="create" directory="#application.path.project#\www\images\Source\">
      		</cfif>
      		<cfif NOT directoryExists("#application.path.project#\www\images\thumbnail\")>
      			<cfdirectory action="create" directory="#application.path.project#\www\images\thumbnail\">
      		</cfif>
      		<cfif NOT directoryExists("#application.path.project#\www\images\Standard\")>
      			<cfdirectory action="create" directory="#application.path.project#\www\images\Standard\">
      		</cfif>
          <cfoutput>COMPLETE</p></cfoutput><cfflush>
      		<cfcatch>
    				<!--- display form with error message --->
		    		<cfset errorMsg = "problem creating SourceImages, thumbnailImages and StandardImages directories">
 			     	<cfinclude template="_installForm.cfm">
				    <cfabort>
          </cfcatch>
      	</cftry>
	  <!--- end of copy  --->   

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
    <!--- copied by bowden 7/23/2006. copied from b300.cfm. --->
    	<!--- FU updates --->
    	<cftry>
    	<cfinclude template="fu.cfm">
    	<cfcatch>
    				<!--- display form with error message --->
		    		<cfset errorMsg = "problem creating SourceImages, thumbnailImages and StandardImages directories">
 			     	<cfinclude template="_installForm.cfm">
				    <cfabort>
    	</cfcatch>
    	</cftry>
    
    	<cfoutput> done</p></cfoutput><cfflush>
    
    	<cfoutput></ul></cfoutput>
    <!--- end of copy --->
    
    </cfif>

</cfif>

<cfif isDefined("errorMsg") OR not isDefined("form.proceed")>
    <!--- display form --->
    <cfinclude template="_installForm.cfm">
</cfif>

<cfoutput>
<p><font size="1">copyright &copy; 2003 - #year(now())#. <a href="http://www.daemon.com.au" target="_blank">Daemon Internet Consultants</a></font></p>

</div>

</body>
</html>
</cfoutput>

<cfsetting enableCFOutputOnly="No">