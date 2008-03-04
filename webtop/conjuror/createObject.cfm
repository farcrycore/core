<!--- 
merge of ../admin/navajo/createObject.cfm and ../tags/navajo/createObject.cfm
 --->
<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">
<cfsetting enablecfoutputonly="Yes">

<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/conjuror/createObject.cfm,v 1.1 2005/06/11 07:55:24 geoff Exp $
$Author: geoff $
$Date: 2005/06/11 07:55:24 $
$Name: milestone_3-0-1 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: creates an instance of an type object and returns to edit handler$
$TODO: make more generic. There is some type specific code here for defaulting properties. Should build instance by using type specified fields/defaults$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfinclude template="/farcry/core/webtop/includes/utilityFunctions.cfm">


<cfparam name="url.objectId" default="">
<cfparam name="url.nodetype" default="dmNavigation">

<cfif NOT isDefined("URL.typename")>
	<h3>URL.typename variable not provided</h3>
	<cfabort>
</cfif>

<cfif len(url.objectId)>
	<q4:contentobjectget  objectid="#url.objectId#" bactiveonly="False" r_stobject="stParent">
	<!--- permission check for objects --->
	<nj:getNavigation objectId="#stParent.objectID#" bInclusive="1" r_stObject="bob" r_ObjectId="objectId">
	
	<Cfif len(objectId)>
		<cfset parentNavigationId=objectId>
	</CFIF>
	
<cfelse>
	<cfset temp=1>
</cfif>

<!--- make sure parent can hold an object before doing anything... --->	
<cfif len(url.objectId) AND not structKeyExists(stParent,"aObjectIds")>
	<cfoutput>
		#apapplication.rb.getResource("noaObjectIds")#
	</cfoutput>
	<cfabort>

<cfelse>	
	<!--- default properties --->
	<cfscript>
		stProps=structNew();
		stProps.objectid = createUUID();
		stProps.label = "(incomplete)";
		stProps.title = "";
		stProps.lastupdatedby = session.dmSec.authentication.userlogin;
		stProps.datetimelastupdated = Now();
		stProps.createdby = session.dmSec.authentication.userlogin;
		stProps.datetimecreated = Now();

		// dmHTML specific props
		stProps.displayMethod = "display";
		stProps.status = "draft";
		//dmNews specific props
		stProps.publishDate = now();
		stProps.expiryDate = now();
		
		oType = createobject("component", application.types[url.typename].typePath);
		stNewObj = oType.createData(stProperties=stProps);
		NewObjId = stNewObj.objectid;
	</cfscript>

			
	<!--- update parent object  --->
	<cfif len(url.objectId) AND not (arraytolist(stParent.aObjectIds) contains NewObjID)>
	
		<cfif url.typename IS url.nodetype>
			
			<cfif NOT stParent.typename IS url.nodetype>
				<cfoutput><b>#apapplication.rb.getResource("cantCreateNavObj")#</b></cfoutput>
				<cfabort>
			<cfelse>
				<!--- Insert this node into the tree --->
				<cfscript>
					qChildren = application.factory.oTree.getChildren(objectid=stParent.objectID,typename=stParent.typename);
					position = qChildren.recordCount + 1;
					streturn = application.factory.oTree.setChild(objectName=stProps.label,typename=typename,parentID=stParent.objectID,objectID=newObjId,pos=position);
				</cfscript>

			</cfif>
		<cfelse>
			<!--- Append new ObjectIDs to AObjects array --->
			<cfscript>
				arrayAppend(stParent.aObjectIds, NewObjID);
				stParent.DATETIMECREATED =  createODBCDate("#datepart('yyyy',stParent.DATETIMECREATED)#-#datepart('m',stParent.DATETIMECREATED)#-#datepart('d',stParent.DATETIMECREATED)#");
				stParent.DATETIMELASTUPDATED = createODBCDate(now());
				oParentType = createobject("component", application.types[stParent.typename].typePath);
				oParentType.setData(stProperties=stParent);
			</cfscript>
			
		</cfif>
		
		<cfif len(stParent.objectID)>
			<!--- Refresh the tree --->
			<nj:updateTree objectId="#stParent.objectID#" complete="0">
		</cfif>
	</cfif>
	
	<!--- Now that we know its type and new objectID go and edit the object now --->
	<cfscript>
		st = filterStructure(URL,'objectid,nodetype');
		queryString=structToNamePairs(st);
	</cfscript>
	<cfoutput>
		<script>
			window.location="#application.url.farcry#/navajo/edit.cfm?objectId=#NewObjID#&#queryString#";
		</script>
	</cfoutput>
	
</cfif>

<cfsetting enablecfoutputonly="No">

<cfsetting enablecfoutputonly="No">