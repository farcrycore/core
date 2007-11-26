<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/navajo/move.cfm,v 1.34.2.1 2005/11/25 00:15:23 paul Exp $
$Author: paul $
$Date: 2005/11/25 00:15:23 $
$Name: milestone_3-0-1 $
$Revision: 1.34.2.1 $

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

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfinclude template="/farcry/core/admin/includes/cfFunctionWrappers.cfm">

<cfparam name="url.srcObjectId" default="">
<cfparam name="url.destObjectId" default="">
<cfparam name="lAncestorIds" default="">

<!--- get the source object --->
<q4:contentobjectget objectid="#url.srcObjectId#"  r_stobject="srcObj">

<!--- get destination object --->
<q4:contentobjectget objectid="#url.destObjectId#" r_stobject="DestObj">

<cfset lExclude = "dmImage,dmFile">

<cfif listContainsNoCase(lExclude,destObj.typename)>
	<cfoutput><h3>#application.adminBundle[session.dmProfile.locale].cantDragObjectsBelowFileImage# </h3>
	<div align="center"> <input type="button" value="#application.adminBundle[session.dmProfile.locale].close#" class="normalBttnStyle" onClick="window.close();" ></div>
	</cfoutput>
	<cfabort>
</cfif>
<!--- <cffunction name="dump">
	<cfargument name="vai">
	<cfdump var="#vai#">
	<cfabort>
</cffunction> --->
<cfscript>
	oAudit = createObject("component","#application.packagepath#.farcry.audit");
	//get all the descendants for source
	//dump(srcObj);
	
	
	if (srcObj.typename IS "dmNavigation")
	{
		qGetDescendants = application.factory.oTree.getDescendants(objectid=srcObj.objectID);
		qGetParent = application.factory.oTree.getParentID(objectid = srcObj.objectID);
		srcParentObjectID = qGetparent.parentID;
		qGetParent = application.factory.oTree.getParentID(objectid = destObj.objectID);
		destNavObjectID = qGetparent.parentID;
		
	}	
	else{	
		oNav = createObject("component", application.types.dmNavigation.typePath);
		qGetParent = oNav.getParent(objectid=srcObj.objectID);
		srcParentObjectID = qGetParent.parentID;
		destNavObjectID = destObj.objectId;
		qGetParent = oNav.getParent(objectid=destObj.objectID);
		destParentObjectID = qGetParent.parentID;
	}	
</cfscript>


<!--- get source parent object --->
<q4:contentobjectget objectid="#srcParentObjectID#"  r_stobject="srcObjParent">

<!--- Check permissions - are you allowed to do this? --->
<cfscript>
	if (not len(trim(destNavObjectID)))
		haspermission = application.security.checkPermission(permission="RootNodeManagement");
	else
		haspermission = application.security.checkPermission(permission="Create",object=destNavObjectID);	
	//get logged in user
	stuser = application.factory.oAuthentication.getUserAuthenticationData();

</cfscript>

<cfif haspermission>

	<nj:treeGetRelations get="ancestors" bInclusive="1" objectId="#destObj.objectId#" r_lObjectIds="lAncestorIds">
	
	<cfif url.srcObjectId eq url.destObjectId OR ListFind( lAncestorIds, url.srcObjectId )>
		<cfoutput>
			<script>
			parent.alert("#application.adminBundle[session.dmProfile.locale].destinationNodeCantBeChild#");
			window.close();
			</script>
		</cfoutput>
		<cfabort>
	</cfif>
	
	
	 <cfif srcObj.typename IS "dmNavigation">
		<!--- Move the branch in the NTM --->
		
	 	<cftry> 
		<!--- exclusive lock tree.moveBranch() to prevent corruption --->
		
		<cflock scope="Application"  type="EXCLUSIVE" timeout="1" throwontimeout="Yes">
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
			 	<cfoutput>
				<h2>#application.adminBundle[session.dmProfile.locale].moveBranchLockout#</h2>
				<p>#application.adminBundle[session.dmProfile.locale].branchLockoutBlurb#</p>
				<script>
					top['frames']['treeFrame'].alert("#application.adminBundle[session.dmProfile.locale].branchLockoutBlurb#");
					top['frames']['treeFrame'].enableDragAndDrop();
				</script>
				</cfoutput>
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
			oType = createobject("component", application.types[srcObjParent.typename].typePath);
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
		oType = createobject("component", application.types[destObj.typename].typePath);
		oType.setData(stProperties=destObj,auditNote="Child moved");		
	</cfscript>
	
	
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
	
	<!--- update overview page --->
	<cfoutput>
	
	<script>
		srcobjid='#URL.srcObjectID#';	
		destNavObjectId ='#destObj.objectid#';	
		if(top['sidebar'].frames['sideTree'])
		{
			top.frames['sidebar'].frames['sideTree'].updateTree(src=srcobjid,dest=destNavObjectId,srcobj='#url.srcObjectid#');
			top.frames['sidebar'].frames['sideTree'].enableDragAndDrop();
		}
	</script>
	</cfoutput>

</cfif>

<cfsetting enablecfoutputonly="No">