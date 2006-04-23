<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/delete.cfm,v 1.14 2003/08/20 07:03:13 brendan Exp $
$Author: brendan $
$Date: 2003/08/20 07:03:13 $
$Name: b201 $
$Revision: 1.14 $

|| DESCRIPTION || 
$Description: DELETE OBJECTS FROM TREE $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: <separate entry for each variable>$
$out: <separate entry for each variable>$
--->
<cfsetting enablecfoutputonly="Yes">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<cfif isDefined("URL.objectID")>

<!--- Get the object --->

<q4:contentobjectget objectid="#url.ObjectId#" r_stobject="stObj">

<!--- This gets the parent object -- need this to clean up its reference to the object we are deleting --->
<cfscript>
	if (application.types[stObj.typename].bCustomType) {
				packagepath = application.customPackagepath;
			} else {
				packagepath = application.packagepath;
			}
	oType = createObject("component","#packagepath#.types.#stObj.typename#");
	oNav = createObject("component", "#application.packagepath#.types.dmNavigation");
	if (stObj.typename IS 'dmNavigation')
	{
		qGetParent = application.factory.oTree.getParentID(objectID = stObj.objectID);
		parentObjectID = qGetParent.parentID;	
	}
	else
	{
	// likely to be a parent object with aObjects property (eg. dmHTML, dmNews)
		qGetParent = oNav.getParent(objectid=stObj.objectID);
		parentObjectID = qGetParent.objectID;
	}	
	oAuthorisation = request.dmSec.oAuthorisation;
	oAuthorisation.checkInheritedPermission(permissionName="edit",objectid=parentobjectid,bThrowOnError=1);
</cfscript>

<!--- get the parentID --->
<q4:contentobjectget objectid="#parentObjectId#" r_stobject="srcObjParent">

<!--- Does the user have permission to do this? --->
<cfscript>
</cfscript>	
					

<cfif NOT stObj.typename IS "dmNavigation">
	<cfset key = 'aobjectids'>
	<cfloop index="i" from="#ArrayLen(srcObjParent[key])#" to="1" step="-1">
		<cfif srcObjParent[key][i] eq stObj.objectId>
			<cfset ArrayDeleteAt( srcObjParent[key], i )>
		</cfif>
	</cfloop>
	<cfscript>
		// $TODO: may want to check if this is necessary, implies that date value has been changed on get. GB$
		srcObjParent.datetimecreated = createODBCDate("#datepart('yyyy',srcObjParent.datetimecreated)#-#datepart('m',srcObjParent.datetimecreated)#-#datepart('d',srcObjparent.datetimecreated)#");
		srcObjParent.datetimelastupdated = createODBCDate(now());
		
		// update the parent object instance
		oParentType = createobject("component","#application.packagepath#.types.#srcObjParent.typename#");
		oParentType.setData(stProperties=srcObjParent,auditNote="Child deleted");	
	</cfscript>
	<!--- $TODO: may need to remove typename attribute and force a lookup -- what if it's a custom type? GB$ --->
</cfif>	
	
	<!--- type specific delete options --->
	<cfscript>
		oType.delete(stObj.objectId);
	</cfscript>
	
	<!--- Update the tree view --->
	<nj:updateTree objectId="#parentObjectID#"> 
	
	<!--- update overview page --->
	<cfoutput>
		<script>
				top['editFrame'].location.href = '#application.url.farcry#/edittabOverview.cfm?objectid=#parentObjectID#';
		</script>
	</cfoutput>

<cfelse>
	<cfthrow detail="URL.objectID not passed">
</cfif>

<cfsetting enablecfoutputonly="No">