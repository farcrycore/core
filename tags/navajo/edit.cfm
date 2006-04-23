<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/edit.cfm,v 1.18 2003/10/23 08:22:18 paul Exp $
$Author: paul $
$Date: 2003/10/23 08:22:18 $
$Name: b201 $
$Revision: 1.18 $

|| DESCRIPTION || 
$Description: $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: url.Objectid$
$out:$
--->

<cfsetting enablecfoutputonly="yes">
<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">
<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">
<!--- First check permissions --->
<cfscript>
	bHasPermission = request.dmsec.oAuthorisation.checkInheritedPermission(permissionName='edit',objectid=URL.objectid);
</cfscript>
<cfif NOT bHasPermission GTE 0>
	<h1>You do not have permission to edit this object</h1>
	<cfabort>
</cfif>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">

<!--- work out package epath --->
<cfscript>
	packagePath = getPackagePath(URL.type);
	oType = createObject("component",packagePath);
	stObj = oType.getData(objectid=url.objectid,dsn=application.dsn);
</cfscript>

<!--- delete underlying draft --->
<cfif isDefined("URL.deleteDraftObjectID")>
	<!--- delete instance --->
	<cf_deleteObjects typename="dmHTML" lObjectIDs="#URL.deleteDraftObjectID#">
	<!--- Log this against live object --->
	<cfscript>
		oAuthentication = request.dmSec.oAuthentication;	
		stuser = oAuthentication.getUserAuthenticationData();
		application.factory.oaudit.logActivity(objectid="#url.objectid#",auditType="delete", username=StUser.userlogin, location=cgi.remote_host, note="Draft object deleted");
	</cfscript>
	<!--- get parent for update tree --->
	<cf_getNavigation objectId="#url.ObjectId#" bInclusive="1" r_stObject="stNav" r_ObjectId="navIdSrcPerm">
	<!--- update tree --->
	<cf_updateTree objectId="#navIdSrcPerm#" complete=0>
	<!--- reload overview page --->
	<cfoutput>
		<script language="JavaScript">
			parent['editFrame'].location.href = '#application.url.farcry#/edittabOverview.cfm?objectid=#url.ObjectID#';
		</script>
	</cfoutput>
</cfif>
<!--- See if we can edit this object --->
<cfscript>
oVersioning = createObject("component","#application.packagepath#.farcry.versioning");
oLocking = createObject("component","#application.packagepath#.farcry.locking");
if (structKeyExists(stObj,"versionID") AND structKeyExists(stObj,"status"))
{			
	stRules = oVersioning.getVersioningRules(objectid=url.objectid);
	oVersioning.checkEdit(stRules=stRules,stObj=stObj);
}

if (structCount(stObj))
{
	checkForLockRet=oLocking.checkForLock(objectid=url.objectid);
	if (checkForLockRet.bSuccess)
	{
		lockRet = oLocking.lock(objectid=url.objectid,typename=url.type);
		if (lockRet.bSuccess)
		{
			oType.edit(objectid=url.objectid);
		}
		else
		{
			dump(packagepath);
			abort();
		}
	}
	else if (not checkForLockRet.bSuccess and checkForLockRet.lockedBy eq "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#")	
	{
		oType.edit(objectid=url.objectid);
	}
	else
	{
		writeoutput(checkForLockRet.message);
		abort();
	}
}	
			
</cfscript>
	  
<admin:footer>

<cfsetting enablecfoutputonly="No">