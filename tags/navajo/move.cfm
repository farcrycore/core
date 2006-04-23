<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/move.cfm,v 1.13 2003/05/03 07:52:07 geoff Exp $
$Author: geoff $
$Date: 2003/05/03 07:52:07 $
$Name: b131 $
$Revision: 1.13 $

|| DESCRIPTION || 

|| USAGE ||

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: url.srcObjectId: id of node to move from$
$in: url.destObjectId: id of node to move to$
$out:$
--->
<!--- set long timeout for template to prevent data-corruption on incomplete tree.moveBranch() --->
<cfsetting requesttimeout="90">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<cfparam name="url.srcObjectId" default="">
<cfparam name="url.destObjectId" default="">
<cfparam name="lAncestorIds" default="">

<!--- get the source object --->
<q4:contentobjectget objectid="#url.srcObjectId#"  r_stobject="srcObj">

<!--- get destination object --->
<q4:contentobjectget objectid="#url.destObjectId#" r_stobject="DestObj">

<cfset lExclude = "dmImage,dmFile">

<cfif listContainsNoCase(lExclude,destObj.typename)>
	<cfoutput><h3>File or Image objects may not have objects dragged beneath them </h3>
	<div align="center"> <input type="button" value="Close" class="normalBttnStyle" onClick="window.close();" ></div>
	</cfoutput>
	<cfabort>
</cfif>

<cfscript>
	oTree = createObject("component","#application.packagepath#.farcry.tree");
	if (srcObj.typename IS "dmNavigation")
	{
		qGetParent = oTree.getParentID(objectid = srcObj.objectID);
		srcParentObjectID = qGetparent.parentID;
		qGetParent = oTree.getParentID(objectid = destObj.objectID);
		destNavObjectID = qGetparent.parentID;
		
	}	
	else{	
		oNav = createObject("component", "#application.packagepath#.types.dmNavigation");
		qGetParent = oNav.getParent(objectid=srcObj.objectID);
		srcParentObjectID = qGetParent.objectID;
		destNavObjectID = destObj.objectId;
		qGetParent = oNav.getParent(objectid=destObj.objectID);
		destParentObjectID = qGetParent.objectID;
	}	
</cfscript>


<!--- get source parent object --->
<q4:contentobjectget objectid="#srcParentObjectID#"  r_stobject="srcObjParent">

<!--- Check permissions - are you allowed to do this? --->
<cfscript>
	oAuthorisation = request.dmSec.oAuthorisation;
	if (not len(srcParentObjectID))
		oAuthorisation.checkPermission(permissionName="RootNodeManagement",reference="PolicyGroup",bThrowOnError=1);
	else
		oAuthorisation.checkInheritedPermission(permissionName="Edit",objectid=srcParentObjectID,bThrowOnError=1);	
</cfscript>


<!--- get dest parent object --->
<q4:contentobjectget objectid="#destNavObjectID#"  r_stobject="destObjParent">

<cfscript>
	oAuthorisation.checkInheritedPermission(permissionName="Edit",objectid=destNavObjectID,bThrowOnError=1);	
</cfscript>

<nj:treeGetRelations get="ancestors" bInclusive="1" objectId="#destObj.objectId#" r_lObjectIds="lAncestorIds">

<cfif url.srcObjectId eq url.destObjectId OR ListFind( lAncestorIds, url.srcObjectId )>
	<cfoutput>
		<script>
		parent.alert("Destination node cannot be a child of or same as the Source node!");
		window.close();
		</script>
	</cfoutput>
	<cfabort>
</cfif>

<!--- <cfif url.destObjectId EQ destNavObjectID AND srcObj.typename> 
<cfoutput>
	<script>
		alert("Destination node cannot be a child of or same as the Source node!");
		window.close();
		</script>
	</cfoutput>
	<cfabort>
</cfif>
 --->

<cfif srcObj.typename IS "dmNavigation">
	<!--- Move the branch in the NTM --->
	<cftry>
	<!--- exclusive lock tree.moveBranch() to prevent corruption --->
	<cflock name="moveBranchNTM" type="EXCLUSIVE" timeout="3" throwontimeout="Yes">
		<cfscript>
			oTree.moveBranch(objectID=URL.srcObjectID,parentID=URL.destObjectID);
		</cfscript>	
	</cflock>
		<cfcatch>
			<h2>moveBranch Lockout</h2>
			<p>Another editor is currently modifying the hierarchy.  Please refresh the site overview tree and try again.</p>
			<cfabort>
		</cfcatch>
	</cftry>
<cfelse>
	<cfset key="AOBJECTIDS">
</cfif>

<!--- remove srcnav from its parent --->
<cfif isStruct( srcObjParent ) and structcount(srcObjParent) AND isDefined("key")>
 	<cfloop index="i" from="#ArrayLen(srcObjParent[key])#" to="1" step="-1">
		<cfif srcObjParent[key][i] eq srcObj.objectId>
			<cfset ArrayDeleteAt( srcObjParent[key], i )>
		</cfif>
	</cfloop>

	<cfscript>
		srcObjParent.datetimecreated = createODBCDate("#datepart('yyyy',srcObjParent.datetimecreated)#-#datepart('m',srcObjParent.datetimecreated)#-#datepart('d',srcObjparent.datetimecreated)#");
		srcObjParent.datetimelastupdated = createODBCDate(now());
	</cfscript>
	<q4:contentobjectdata objectid="#srcObjParent.objectID#" typename="#application.packagepath#.types.#srcObjParent.typename#"	 stProperties="#srcObjParent#"> 
</cfif>

<!--- add src nav to dest nav --->
<cfscript>
	destObj.datetimecreated = createODBCDate("#datepart('yyyy',destObj.datetimecreated)#-#datepart('m',destObj.datetimecreated)#-#datepart('d',destObj.datetimecreated)#");
	destObj.datetimelastupdated = createODBCDate(now());
	if (isDefined("key"))
		arrayAppend( destObj[key], srcObj.objectId);
</cfscript>

<!--- Now Update the dest object --->
<q4:contentobjectdata objectid="#destObj.objectID#"	typename="#application.packagepath#.types.#destObj.typename#" stProperties="#destObj#">

<cfoutput>
	<!--- Update the tree --->
	<cfscript>
		if (srcObj.typename IS 'dmNavigation')
			destParentObjectId = destObj.ObjectID;
	
	</cfscript>
	
	<script>
		
		if (parent.getObjectDataAndRender)
		{   
			parent.getObjectDataAndRender( '#srcParentObjectID#' );
			parent.getObjectDataAndRender( '#destParentObjectID#' );
			
		}	
	</script>
</cfoutput>

<cfsetting enablecfoutputonly="No">