<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/navajo/edit.cfm,v 1.29.2.1 2005/11/30 06:08:50 guy Exp $
$Author: guy $
$Date: 2005/11/30 06:08:50 $
$Name: milestone_3-0-1 $
$Revision: 1.29.2.1 $

|| DESCRIPTION || 
$Description: $
$TODO: This legacy code needs to be revisited 
-- should have a more generic object invocation methodology GB$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: attributes.objectid$
$out:$
--->
<cfif thistag.ExecutionMode eq "end">
	<cfexit method="exittag">
</cfif>

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">

<!--- import function libraries --->
<cfinclude template="/farcry/core/admin/includes/utilityFunctions.cfm">
<cfinclude template="/farcry/core/admin/includes/cfFunctionWrappers.cfm">

<!--- required attributes --->
<!--- 	looks like refs to URL params are everywhere... 
	  	will have to hack this in the interim till we 
		refactor the lot. 20050728 GB	--->
<cfif isdefined("url.objectid")><cfset attributes.objectid=url.objectid></cfif>
<cfif isdefined("url.typename")><cfset attributes.typename=url.typename></cfif>
<cfparam name="attributes.objectid" type="uuid">
<cfparam name="attributes.typename" default="" type="string">

<!--- Legacy support for old pages referring to URL.type--->
<cfif isDefined("URL.type") AND NOT isDefined("URL.typename")>
	<cfset URL.typename = URL.type>
	<cflog file="deprecated" application="true" type="warning" text="../tags/navajo/edit.cfm referencing type when typename required." />
</cfif>

<cfscript>
	// auto-type lookup if required
	if (NOT len(attributes.typename)) {
		q4 = createObject("component", "farcry.core.packages.fourq.fourq");
		attributes.typename = q4.findType(objectid=attributes.objectid);
		//its possible that missing objects will kill this so we only want to create object if we actually get a typename result
		if (NOT len(attributes.typename))
			abort();
	}
</cfscript>

<!--- First check tree permissions --->
<cfset bHasPermission = request.dmsec.oAuthorisation.checkInheritedPermission(permissionName='edit',objectid=attributes.objectid)>
<cfif NOT bHasPermission GTE 0>
	<cfoutput><h1>#application.adminBundle[session.dmProfile.locale].noEditPermission#</h1></cfoutput>
	<cfabort>
</cfif>

<!--- work out packagee path --->
<cfset oType = createObject("component", application.types[attributes.typename].typePath)>
<cfset stObj = oType.getData(objectid=attributes.objectid,dsn=application.dsn)>

<!--- delete underlying draft --->
<cfif isDefined("URL.deleteDraftObjectID")>
	<cfscript>
		//Delete the copied draft object containers
		oCon = createObject('component','#application.packagepath#.rules.container');
		oCon.delete(objectid="#URL.deleteDraftObjectID#");
		//Delete the copied draft object
		oType.deletedata(objectId="#URL.deleteDraftObjectID#");
		//Log this activity against live object
		oAuthentication = request.dmSec.oAuthentication;	
		stuser = oAuthentication.getUserAuthenticationData();
		application.factory.oaudit.logActivity(objectid="#attributes.objectid#",auditType="delete", username=StUser.userlogin, location=cgi.remote_host, note="Deleted Draft Object (#stObj.label#)");
	</cfscript>
	<!--- get parent for update tree --->
	<cf_getNavigation objectId="#attributes.objectid#" bInclusive="1" r_stObject="stNav" r_ObjectId="navIdSrcPerm">
	<!--- update tree --->
	<cf_updateTree objectId="#navIdSrcPerm#" complete=0>
	<!--- reload overview page --->
	<cfoutput><script type="text/javascript">
		parent['content'].location = '#application.url.farcry#/edittabOverview.cfm?objectid=#attributes.objectid#';
	</script></cfoutput>
</cfif>

<!--- See if we can edit this object --->

<cfscript>
bAllowEdit = false;
oVersioning = createObject("component","#application.packagepath#.farcry.versioning");
oLocking = createObject("component","#application.packagepath#.farcry.locking");
if (structKeyExists(stObj,"versionID") AND structKeyExists(stObj,"status"))
{			
	stRules = oVersioning.getVersioningRules(objectid=attributes.objectid);
	oVersioning.checkEdit(stRules=stRules,stObj=stObj);
}

if (structCount(stObj))
{
		
	checkForLockRet=oLocking.checkForLock(objectid=attributes.objectid);
	if (checkForLockRet.bSuccess)
	
	{
		lockRet = oLocking.lock(objectid=attributes.objectid,typename=attributes.typename);
		if (lockRet.bSuccess)
		{
			bAllowEdit = true;
			//oType.edit(objectid=attributes.objectid);
		}
		else
		{
			dump(packagepath);
			abort();
		}
	}
	else if (not checkForLockRet.bSuccess and checkForLockRet.lockedBy eq "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#")
	{
		bAllowEdit = true;
		//oType.edit(objectid=attributes.objectid);
	}
	else
	{
		writeoutput(checkForLockRet.message);
		dump(checkForLockRet);
		abort();
	}
}	
			
</cfscript>

<cfset stOnExit = structNew() />
<cfset stOnExit.Type = "HTML" />
<cfsavecontent variable="stOnExit.Content">
		<!--- get parent to update tree --->
		<nj:treeGetRelations typename="#stObj.typename#" objectId="#stObj.ObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1">
		<!--- update tree --->
		<nj:updateTree objectId="#parentID#">
		<cfoutput>
		<script type="text/javascript">
			parent['content'].location.href = '#application.url.farcry#/edittabOverview.cfm?objectid=#stObj.ObjectID#';
		</script>
		</cfoutput>
</cfsavecontent>

<cfif FileExists("#application.path.project#/webskin/#stObj.Typename#/edit.cfm")>
	<cfset oType.getDisplay(stObject=stobj, template="edit", onExit="#stOnExit#") /><!--- #application.url.farcry#/edittabOverview.cfm?objectid=#stObj.ObjectID# --->
<cfelse>
	<cfset oType.edit(objectid=attributes.objectid, onExit="#stOnExit#") />
</cfif>

<cfsetting enablecfoutputonly="No">