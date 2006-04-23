<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/move.cfm,v 1.23 2003/10/28 07:22:08 paul Exp $
$Author: paul $
$Date: 2003/10/28 07:22:08 $
$Name: b201 $
$Revision: 1.23 $

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
<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">

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
	oAudit = createObject("component","#application.packagepath#.farcry.audit");
	//get all the descendants for source
	qGetDescendants = application.factory.oTree.getDescendants(objectid=srcObj.objectID);
	
	if (srcObj.typename IS "dmNavigation")
	{
		qGetParent = application.factory.oTree.getParentID(objectid = srcObj.objectID);
		srcParentObjectID = qGetparent.parentID;
		qGetParent = application.factory.oTree.getParentID(objectid = destObj.objectID);
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
	//get logged in user
	oAuthentication = request.dmSec.oAuthentication;	
	stuser = oAuthentication.getUserAuthenticationData();

</cfscript>

<!--- get dest parent object --->
<!--- <q4:contentobjectget objectid="#destNavObjectID#"  r_stobject="destObjParent"> --->

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


<cfif srcObj.typename IS "dmNavigation">
	<!--- Move the branch in the NTM --->
	
 	<cftry> 
	<!--- exclusive lock tree.moveBranch() to prevent corruption --->
	
	<cflock name="moveBranchNTM" type="EXCLUSIVE" timeout="3" throwontimeout="Yes">
		<cfscript>
			if (application.config.plugins.fu)
			{
				//first delete all old fu's
				fuUrl = application.factory.oFU.getFU(objectid=srcObj.objectid);
				application.factory.oFU.deleteFu(fuUrl);
				//now the descendants if they exist
				for (i=1;i LTE qGetDescendants.recordcount;i=i+1)
				{
					fuUrl = application.factory.oFU.getFU(objectid=qGetDescendants.objectid[i]);
					application.factory.oFU.deleteFu(fuUrl);
				}
			}
			
			application.factory.oTree.moveBranch(dsn=application.dsn,objectID=URL.srcObjectID,parentID=URL.destObjectID);
			
			if (application.config.plugins.fu)
			{		
				//now create the new fu branch	

				fuAlias = application.factory.oFU.createFUAlias(srcObj.objectid);
				application.factory.oFU.setFU(objectid=srcObj.objectid,alias=fuAlias);

				for (i=1;i LTE qGetDescendants.recordcount;i=i+1)
				{
					fuAlias = application.factory.oFU.createFUAlias(objectid=qGetDescendants.objectid[i]);
					application.factory.oFU.setFu(objectid=qGetDescendants.objectid[i],alias=fuAlias);
				}

			}	
			//updatetree(objectid=srcParentObjectID);
		</cfscript>	
	</cflock>
		 <cfcatch>
		 	<cfdump var="#cfcatch#">
			<h2>moveBranch Lockout</h2>
			<p>Another editor is currently modifying the hierarchy.  Please refresh the site overview tree and try again.</p>
			<cfabort>
		</cfcatch>
	</cftry> 
	
<cfelse>
	<cfset key="AOBJECTIDS">
</cfif>

<!--- remove srcnav from its parent --->
<cfif isStruct( srcObjParent ) and structcount(srcObjParent) AND isDefined("key") AND NOT srcObj.typename IS "dmNavigation">
 	<cfloop index="i" from="#ArrayLen(srcObjParent[key])#" to="1" step="-1">
		<cfif srcObjParent[key][i] eq srcObj.objectId>
			<cfset ArrayDeleteAt( srcObjParent[key], i )>
		</cfif>
	</cfloop>

	<cfscript>
		srcObjParent.datetimecreated = createODBCDate("#datepart('yyyy',srcObjParent.datetimecreated)#-#datepart('m',srcObjParent.datetimecreated)#-#datepart('d',srcObjparent.datetimecreated)#");
		srcObjParent.datetimelastupdated = createODBCDate(now());
		// update the parent object instance
		oType = createobject("component","#application.packagepath#.types.#srcObjParent.typename#");
		oType.setData(stProperties=srcObjParent,auditNote="Child moved");	
	</cfscript>
</cfif>
<!--- add src nav to dest nav --->
<cfscript>
	destObj.datetimecreated = createODBCDate("#datepart('yyyy',destObj.datetimecreated)#-#datepart('m',destObj.datetimecreated)#-#datepart('d',destObj.datetimecreated)#");
	destObj.datetimelastupdated = createODBCDate(now());
	if (NOT srcObj.typename IS "dmNavigation")
		arrayAppend( destObj[key], srcObj.objectId);
	// Now Update the dest object
	oType = createobject("component","#application.packagepath#.types.#destObj.typename#");
	oType.setData(stProperties=destObj,auditNote="Child moved");		
</cfscript>

<cfoutput>
	<!--- Update the tree and log--->
	<cfscript>
		if (srcObj.typename IS 'dmNavigation')
			destParentObjectId = destObj.ObjectID;
		//if they are moving to trash - log this as the audit note	
		if (isDefined("application.navid.rubbish") AND URL.destObjectID IS application.navid.rubbish)	
			auditNote = "object moved to trash";
		else
			auditnote = "object moved to new parentid #url.destObjectID#";			
		oaudit.logActivity(objectid="#srcobj.objectid#",auditType="sitetree.movenode", username=StUser.userlogin, location=cgi.remote_host, note="#auditNote#");

	</cfscript>
	<script>
		srcobjid='#URL.srcObjectID#';	
		destNavObjectId ='#destObj.objectid#';	
						
		parent.updateTree(src=srcobjid,dest=destNavObjectId,srcobj='#url.srcObjectid#');
	</script>
	
</cfoutput>

<cfsetting enablecfoutputonly="No">