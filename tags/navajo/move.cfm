<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/tags/navajo/" prefix="nj">


<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/move.cfm,v 1.1.1.1 2002/09/27 06:54:04 petera Exp $
$Author: petera $
$Date: 2002/09/27 06:54:04 $
$Name: b100 $
$Revision: 1.1.1.1 $

|| DESCRIPTION || 

|| USAGE ||

|| DEVELOPER ||
original: Nick Shearer (nick@daemon.com.au)
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||
-> url.srcObjectId: id of node to move from
-> url.destObjectId: id of node to move to

|| HISTORY ||
$Log: move.cfm,v $
Revision 1.1.1.1  2002/09/27 06:54:04  petera
no message

Revision 1.14  2002/09/17 00:39:06  geoff
no message

Revision 1.13  2002/09/11 06:52:09  geoff
no message

Revision 1.12  2002/09/10 23:52:56  geoff
no message

Revision 1.11  2002/09/10 04:52:38  geoff
no message

Revision 1.10  2002/09/05 01:43:06  geoff
no message

Revision 1.9  2002/09/05 00:52:20  geoff
no message

Revision 1.8  2002/08/29 07:08:36  geoff
no message

Revision 1.7  2002/08/29 04:17:34  geoff
no message

Revision 1.6  2002/08/29 03:37:29  geoff
no message

Revision 1.5  2002/08/22 04:53:19  geoff
no message

Revision 1.4  2002/08/22 00:09:38  geoff
no message

Revision 1.3  2002/07/18 07:32:52  geoff
no message

Revision 1.1  2002/07/16 07:25:21  geoff
*** empty log message ***

Revision 1.8  2002/03/26 04:20:56  aaron
no message

Revision 1.7  2002/03/13 01:42:21  aaron
changed cachedObject to contentobject

Revision 1.6  2002/03/13 01:08:25  aaron
changed cachedObject to contentobject


|| END FUSEDOC ||
--->

<cfparam name="url.srcObjectId" default="">
<cfparam name="url.destObjectId" default="">


<cfoutput>
<html>
<body>
<link rel="stylesheet" type="text/css" href="navajo_popup.css">
</cfoutput>

<!--- Check the user is allowed to move stuff from fromIDs parent node --->
<q4:contentobjectget objectid="#url.srcObjectId#"  r_stobject="srcObj">
<cfif len(trim(url.destObjectId)) NEQ 0>
	<q4:contentobjectget objectid="#url.destObjectId#" r_stobject="DestObj">
	<cfset lExclude = "dmImage,dmFile">
	<cfif listContainsNoCase(lExclude,destObj.typename)>
	<cfoutput><h3>File or Image objects may not have objects dragged beneath them </h3>
	<div align="center"> <input type="button" value="Close" class="normalBttnStyle" onClick="window.close();" ></div>
	</cfoutput>
	<cfabort>
	</cfif>
	
</cfif>	



<nj:getNavigation objectId="#url.srcObjectId#" bInclusive="1" r_stObject="stNav" r_ObjectId="navIdSrcPerm">
<!--- <nj:getNavigation objectId="#stObj.objectID#" bInclusive="1" r_stObject="stNav" r_ObjectId="objectId">
 --->
<cfif not len(navIdSrcPerm)>
	<cf_dmSec2_PermissionCheck permissionName="RootNodeManagement" reference1="PolicyGroup" bThrowOnError="1">
<cfelse>
	<cf_dmSec2_PermissionCheck permissionName="Edit" objectId="#navIdSrcPerm#" reference1="dmNavigation"   bThrowOnError="1">
</cfif>

<!--- Check the user is allowed to move stuff to toIDs node --->
<cfif len(trim(url.destObjectId)) NEQ 0>
	<cfif destObj.typename IS "dmNavigation">
		<cfset navIdDestPerm = destObj.objectId>
	<cfelse>
		<nj:getNavigation objectId="#destObj.objectId#" r_ObjectId="navIdDestPerm">
	</cfif>
</cfif>	

<cfparam name="lAncestorIds" default="">
<cfif len(trim(url.destObjectId)) NEQ 0>
	<cf_dmSec2_PermissionCheck permissionName="Edit" objectId="#navIdDestPerm#" reference1="dmNavigation" bThrowOnError="1">
	<nj:treeGetRelations get="ancestors" bInclusive="1" objectId="#destObj.objectId#" r_lObjectIds="lAncestorIds">
</cfif>	

<cfif url.srcObjectId eq url.destObjectId OR ListFind( lAncestorIds, url.srcObjectId )>
	<cfoutput>
		<script>
		alert("Destination node cannot be a child of or same as the Source node!");
		window.close();
		</script>
	</cfoutput>
	<cfabort>
</cfif>


<!--- get the src & dest immediate parents --->	
<nj:TreeGetRelations typename="#srcObj.typename#" objectId="#URL.srcObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1">

<q4:contentobjectGet objectId="#ParentID#" r_stObject="srcObjParent">
<cfdump var="#srcObjParent#">

<cfif url.destObjectId EQ parentID>
<cfoutput>
	<script>
		alert("Destination node cannot be a child of or same as the Source node!");
		window.close();
		</script>
	</cfoutput>
	<cfabort>
</cfif>



<!--- <nj:treeGetRelations get="parents" bInclusive="1" objectId="#URL.srcObjectID#" r_stObject="srcObjParent"> --->
<!--- if we are moving a nav node we are dealing with aNavChilds --->
<cfif srcObj.typename IS "dmNavigation">
	<!--- delete from nested tree objects --->
	<cfif NOT len(URL.destObjectID)>
		<cfinvoke component="fourq.utils.tree.tree" method="deleteBranch" objectID="#srcObj.objectID#" returnvariable="stReturn">
	<cfelse>
		 <cfinvoke  component="fourq.utils.tree.tree" method="moveBranch" returnvariable="moveBranchRet">
			<cfinvokeargument name="dsn" value="#application.dsn#"/>
			<cfinvokeargument name="objectid" value="#URL.srcObjectID#"/>
			<cfinvokeargument name="parentid" value="#URL.destObjectID#"/>
		</cfinvoke> 
	</cfif>
	
	
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
	
	<q4:contentobjectdata objectid="#srcObjParent.objectID#"
		typename="#application.packagepath#.types.#srcObjParent.typename#"
		 stProperties="#srcObjParent#"> 
</cfif>

<!--- add src nav to dest nav --->
<cfif len(trim(url.destObjectId)) NEQ 0>
	<cfscript>
		destObj.datetimecreated = createODBCDate("#datepart('yyyy',destObj.datetimecreated)#-#datepart('m',destObj.datetimecreated)#-#datepart('d',destObj.datetimecreated)#");
		destObj.datetimelastupdated = createODBCDate(now());
	</cfscript>
	<cfif isDefined("key")>
		<Cfset ArrayAppend( destObj[key], srcObj.objectId )>
	</cfif>
	<q4:contentobjectdata objectid="#destObj.objectID#"	
	typename="#application.packagepath#.types.#destObj.typename#" stProperties="#destObj#">
<cfelse>
	<!--- DELETE THE OBJECT	 --->
	<q4:contentobjectdelete objectID="#srcObj.objectID#" typename="#application.packagepath#.types.#srcObj.typename#">
</cfif>	

<!--- update the tree view for srcparent and dest --->
<cfoutput>

<cfif len(trim(url.destObjectId)) NEQ 0 OR srcObj.typename IS "dmNavigation">
	<nj:updateTree objectId="#parentID#">
<cfelse>	
	<nj:updateTree objectId="#navIdSrcPerm#">
</cfif>	
<h3>Object Deleted</h3>
</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="No">