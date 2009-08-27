<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
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

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4" />
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj" />
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />
 
<cfinclude template="/farcry/core/webtop/includes/cfFunctionWrappers.cfm">

<cfparam name="url.srcObjectId" default="">
<cfparam name="url.destObjectId" default="">
<cfparam name="lAncestorIds" default="">

<!--- get the source object --->
<q4:contentobjectget objectid="#url.srcObjectId#"  r_stobject="srcObj">

<!--- get destination object --->
<q4:contentobjectget objectid="#url.destObjectId#" r_stobject="DestObj">

<cfset lExclude = "dmImage,dmFile">

<cfif listContainsNoCase(lExclude,destObj.typename)>
	<cfoutput><h3>#application.rb.getResource("sitetree.messages.cantDragObjectsBelowFileImage@text","File or Image content items may not have objects dragged beneath them")# </h3>
	<div align="center"> <input type="button" value="#application.rb.getResource('forms.buttons.close@label','Close')#" class="normalBttnStyle" onClick="window.close();" ></div>
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
</cfscript>

<cfif haspermission>

	<nj:treeGetRelations get="ancestors" bInclusive="1" objectId="#destObj.objectId#" r_lObjectIds="lAncestorIds">
	
	<cfif url.srcObjectId eq url.destObjectId OR ListFind( lAncestorIds, url.srcObjectId )>
		<cfoutput>
			<script>
			parent.alert("#application.rb.getResource('sitetree.messages.destinationNodeCantBeChild@text','Destination node cannot be a child of or same as the Source node!')#");
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
				
				application.factory.oTree.moveBranch(dsn=application.dsn,objectID=URL.srcObjectID,parentID=URL.destObjectID);
				
				//updatetree(objectid=srcParentObjectID);
			</cfscript>	
			
			<cfset application.fapi.setData(typename)>
		</cflock>
			 <cfcatch>
			 	<cfdump var="#cfcatch#">
			 	<cfoutput>
				<h2>#application.rb.getResource('sitetree.messages.branchLockoutBlurb@heading','Branch Lockout')#</h2>
				<p>#application.rb.getResource('sitetree.messages.branchLockoutBlurb@text','Another editor is currently modifying the hierarchy. Please refresh the site overview tree and try again.')#</p>
				<script>
					top['frames']['treeFrame'].alert("#application.rb.getResource('sitetree.messages.branchLockoutBlurb@text','Another editor is currently modifying the hierarchy. Please refresh the site overview tree and try again.')#");
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
	<cfif srcObj.typename IS 'dmNavigation'>
		<cfset destParentObjectId = destObj.ObjectID />
	</cfif>
		
	<!--- if they are moving to trash - log this as the audit note	 --->
	<cfif isDefined("application.navid.rubbish") AND URL.destObjectID IS application.navid.rubbish>
		<farcry:logevent objectid="#srcobj.objectid#" type="sitetree" event="movenode" notes="Object moved to trash" />
	<cfelse>
		<farcry:logevent objectid="#srcobj.objectid#" type="sitetree" event="movenode" notes="Object moved to new parentid #url.destObjectID#" />
	</cfif>
	
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