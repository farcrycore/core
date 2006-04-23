<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/install/_installFarcry.cfm,v 1.37 2004/01/19 06:14:19 brendan Exp $
$Author: brendan $
$Date: 2004/01/19 06:14:19 $
$Name: milestone_2-1-2 $
$Revision: 1.37 $

|| DESCRIPTION || 
$Description: Installation scripts for FarCry database components $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Peter Alexandrou (suspiria@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- STEP 1 : setup farcry database --->
<cfoutput>
<table border="0" cellpadding="1" cellspacing="0" width="400">
<tr><td colspan="2"><h4>[STEP 1] setup farcry database</h4></td></tr>
<cfif browser eq "NS"><tr><td colspan="2"><br></td></tr></cfif>
<tr><td width="100%"><li>Creating audit tables
</cfoutput>
<cfscript>
dotAnim();
// create audit table
o_fourQAudit = createObject("component", "farcry.fourq.utils.audit");
stResult = o_fourQAudit.deployAudit(dsn=application.dsn,bDropTable=true);
if (stResult.bSuccess) writeOutput(successMsg);
else writeOutput(failureMsg);
</cfscript>
<cfflush>

<cfoutput><tr><td width="100%"><li>Deploying tree tables</cfoutput>
<cfscript>
dotAnim();
// invoke tree tables deployment script
o_farcryTree = createObject("component", "#application.packagepath#.farcry.tree");
stResult = o_farcryTree.deployTree(dsn=application.dsn);
if (stResult.bSuccess) writeOutput(successMsg);
else writeOutput(failureMsg);
</cfscript>
<cfflush>

<cfoutput><tr><td width="100%"><li>Creating tables for categorisation actions</cfoutput>
<cfscript>
dotAnim();
// setup metadata categories
o_category = createObject("component", "#application.packagepath#.farcry.category");
stResult  = o_category.deployCategories(dsn=application.dsn,bDropTables=true);
if (stResult.status) writeOutput(successMsg);
else writeOutput(failureMsg);
</cfscript>
<cfflush>

<cfoutput><tr><td width="100%"><li>Creating table for site statistics</cfoutput>
<cfscript>
dotAnim();
// setup stats table
o_stats = createObject("component", "#application.packagepath#.farcry.stats");
stResult  = o_stats.deploy(dsn=application.dsn,bDropTable=true);
if (stResult.status) writeOutput(successMsg);
else writeOutput(failureMsg);
</cfscript>
<cfflush>

<cfoutput><tr><td width="100%"><li>Creating config tables to manage configuration files</cfoutput>
<cfscript>
dotAnim();
// setup config table
o_config = createObject("component", "#application.packagepath#.farcry.config");
stResult = o_config.deployConfig(dsn=application.dsn,bDropTable=true);
o_config.defaultVerity(dsn=application.dsn);
o_config.defaultFile(dsn=application.dsn);
o_config.defaultImage(dsn=application.dsn);
o_config.defaultSoEditor(dsn=application.dsn);
o_config.defaultSoEditorPro(dsn=application.dsn);
o_config.defaultEWebEditPro(dsn=application.dsn);
o_config.defaultEOPro(dsn=application.dsn);
o_config.defaultGeneral(dsn=application.dsn);
o_config.defaultPlugins(dsn=application.dsn);
o_config.defaultFU(dsn=application.dsn);
if (stResult.bSuccess) writeOutput(successMsg);
else writeOutput(failureMsg);
</cfscript>
<cfflush>

<cfoutput><tr><td width="100%"><li>Creating container and rule tables</cfoutput>
<cfscript>dotAnim();</cfscript>

<cfloop list="#getFarcryTypes(application.path.core, 'rules')#" index="index">
    <cfscript>
    // setup container table
    o_dmRule = createObject("component", "#application.packagepath#.rules.#index#");
    stResult = o_dmRule.deployType(dsn=application.dsn,bDropTable=true,bTestRun=false);
    if (not stResult.bSuccess) { writeOutput(failureMsg); abort(); }
    </cfscript>
</cfloop>
<cfoutput>#successMsg#</cfoutput>
<cfoutput></table></cfoutput>
<cfflush>


<!--- STEP 2 : setup farcry types in DB --->
<cfoutput>
<table border="0" cellpadding="1" cellspacing="0" width="400">
<tr><td colspan="2"><br></td></tr>
<tr><td colspan="2"><h4>[STEP 2] setup farcry types in database</h4></td></tr>
<cfif browser eq "NS"><tr><td colspan="2"><br></td></tr></cfif>
</cfoutput>
<cfloop list="#getFarcryTypes(application.path.core, 'types')#" index="index">
    <cfoutput><tr><td width="100%"><li>Setting up type <b>#index#</b> </cfoutput>
    <cfscript>
    dotAnim();
    // setup all default types
    o_dmType = createObject("component", "#application.packagepath#.types.#index#");
    stResult = o_dmType.deployType(dsn=application.dsn,bDropTable=true,bTestRun=false,dbtype=application.dbtype);
    if (stResult.bSuccess) writeOutput(successMsg); else writeOutput(failureMsg);
    </cfscript>
    <cfflush>
</cfloop>

<cfoutput><tr><td width="100%"><li>Creating refObject table</cfoutput>
<cfscript>
dotAnim();
// setup refObjects table
stResult = o_dmType.deployRefObjects(dsn=application.dsn,bDropTable=true);
if (stResult.bSuccess) writeOutput(successMsg);
else writeOutput(failureMsg);
// set up refContainers table
oCon = createObject("component","#application.packagepath#.rules.container");
oCon.deployRefContainers(dsn=application.dsn,dbtype=application.dbtype,dbowner=application.dbowner);
</cfscript>
<cfoutput></table></cfoutput>
<cfflush>

<!--- STEP 3 : setup Daemon security --->
<cfoutput>
<table border="0" cellpadding="1" cellspacing="0" width="400">
<tr><td colspan="2"><br></td></tr>
<tr><td colspan="2"><h4>[STEP 3] setup Daemon security (dmSec)</h4></td></tr>
<cfif browser eq "NS"><tr><td colspan="2"><br></td></tr></cfif>
<tr><td width="100%"><li>Creating Daemon security tables</cfoutput>
<cfscript>dotAnim();</cfscript>
<cfsilent><cfscript>application.o_dmSecInit.initAuthenticationDatabase(datasource=application.dsn,bTest=false,bDropTables=true);</cfscript></cfsilent>
<cfoutput>#successMsg#</cfoutput>
<cfflush>
<cfoutput><tr><td width="100%"><li>Creating Daemon PolicyStore tables</cfoutput>
<cfscript>dotAnim();</cfscript>
<cfsilent><cfscript>application.o_dmSecInit.initAuthorisationDatabase(datasource=application.dsn,bTest=false,bDropTables=true);</cfscript></cfsilent>
<cfoutput>#successMsg#</cfoutput>
<cfflush>
<cfoutput><tr><td width="100%"><li>Setting up default Policy Groups</cfoutput>
<cfscript>dotAnim();</cfscript>
<cfsilent><cfscript>application.o_dmSecInit.initPolicyGroupsDatabase(datasource=application.dsn,bClearTable=true,core=application.path.core,securitypackagepath="#application.packagepath#.security");</cfscript></cfsilent>
<cfoutput>#successMsg#</cfoutput>
<cfflush>
<cfoutput><tr><td width="100%"><li>Setting up default Permissions</cfoutput>
<cfscript>dotAnim();</cfscript>
<cfsilent>
<cfscript>application.o_dmSecInit.initPermissionsDatabase(datasource=application.dsn,bClearTable=true,core=application.path.core,securitypackagepath="#application.packagepath#.security");</cfscript>
</cfsilent>
<cfinclude template="/farcry/farcry_core/admin/security/BaseInitialise.cfm">
<cfoutput>#successMsg#</cfoutput>
<cfflush>
<cfoutput><tr><td width="100%"><li>Creating <strong>farcry</strong> user account</cfoutput>
<cfscript>
dotAnim();
// default groups
stResult = application.o_dmAuthentication.createGroup(groupName="Contributors",userDirectory="ClientUD",groupNotes="Contributors");
stResult = application.o_dmAuthentication.createGroup(groupName="Member",userDirectory="ClientUD",groupNotes="Member");
stResult = application.o_dmAuthentication.createGroup(groupName="Publishers",userDirectory="ClientUD",groupNotes="Publishers");
stResult = application.o_dmAuthentication.createGroup(groupName="News Contributor",userDirectory="ClientUD",groupNotes="News Contributor");
stResult = application.o_dmAuthentication.createGroup(groupName="SiteAdmin",userDirectory="ClientUD",groupNotes="Site Administrators");
stResult = application.o_dmAuthentication.createGroup(groupName="SysAdmin",userDirectory="ClientUD",groupNotes="Systems Administrators");
// create admin user
stResult = application.o_dmAuthentication.createUser(userLogin="farcry",userDirectory="ClientUD",userStatus="4",userNotes="Systems Administrator",userPassword="farcry");
// add admin user to SysAdmin group
stResult = application.o_dmAuthentication.addUserToGroup(userLogin="farcry",groupName="SysAdmin",userDirectory="ClientUD");
</cfscript>
<cfoutput>#successMsg#</cfoutput>
<cfflush>
<cfoutput><tr><td width="100%"><li>Mapping Policy Groups</cfoutput>
<cfscript>
dotAnim();
// create policy group mappings
stResult = application.o_dmAuthorisation.createPolicyGroupMapping(groupname="SysAdmin",userDirectory="ClientUD",policyGroupID="1");
stResult = application.o_dmAuthorisation.createPolicyGroupMapping(groupname="SiteAdmin",userDirectory="ClientUD",policyGroupID="2");
stResult = application.o_dmAuthorisation.createPolicyGroupMapping(groupname="Contributors",userDirectory="ClientUD",policyGroupID="5");
stResult = application.o_dmAuthorisation.createPolicyGroupMapping(groupname="News Contributor",userDirectory="ClientUD",policyGroupID="5");
stResult = application.o_dmAuthorisation.createPolicyGroupMapping(groupname="Member",userDirectory="ClientUD",policyGroupID="3");
stResult = application.o_dmAuthorisation.createPolicyGroupMapping(groupname="Publishers",userDirectory="ClientUD",policyGroupID="6");
</cfscript>
<cfoutput>#successMsg#</cfoutput>
<cfflush> 

<cfoutput><tr><td width="100%"><li>Creating Root node in Overview Tree</cfoutput>
<cfscript>dotAnim();</cfscript>
<cfsilent>
<cfinclude template="_createDefaultNodes.cfm">
</cfsilent>
<cfoutput>#successMsg#</cfoutput>
<cfflush>

<!--- setup default permissions --->
<cfoutput><tr><td width="100%"><li>Setting up default tree permissions</cfoutput>
<cfscript>dotAnim();</cfscript>
<cfquery name="dPerms" datasource="#application.dsn#">delete from #application.dbowner#dmPermissionBarnacle</cfquery>
<cffile action="READ" file="#application.path.core#/admin/install/dmSec_files/permissionBarnacle.csv" variable="permFile">
<cfloop list="#permFile#" index="lPerms" delimiters="#chr(13)##chr(10)#">
    <cfscript>
    oid = listGetAt(lPerms, 3);
    if (oid neq 'PolicyGroup') lPerms = listSetAt(lPerms, 3, evaluate("#oid#"));
    application.o_dmAuthorisation.createPermissionBarnacle(reference=listGetAt(lPerms, 3),status=listGetAt(lPerms, 4),policyGroupID=listGetAt(lPerms, 2),permissionID=listGetAt(lPerms, 1));
    </cfscript>
</cfloop>
<!--- remove existing permissions cache WDDX file --->
<cfif fileExists("#application.path.project#/permissionCache.wddx")>
    <cffile action="DELETE" file="#application.path.project#/permissionCache.wddx">
</cfif>
<cfoutput>#successMsg#</cfoutput>
<cfflush>

<cfoutput>
</table>

<br>

<form>
<input type="button" name="login" value="LOGIN TO FARCRY" onClick="window.open('http://#cgi.HTTP_HOST##form.farcryMapping#')" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle'" onMouseOut="this.className='normalbttnstyle'">
<input type="button" name="view" value="VIEW SITE" onClick="window.open('http://#cgi.HTTP_HOST##form.appMapping#')" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle'" onMouseOut="this.className='normalbttnstyle'">
</form>
</cfoutput>