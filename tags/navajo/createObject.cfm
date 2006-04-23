<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/createObject.cfm,v 1.11 2003/07/10 02:07:06 brendan Exp $
$Author: brendan $
$Date: 2003/07/10 02:07:06 $
$Name: b131 $
$Revision: 1.11 $

|| DESCRIPTION || 
$Description: creates an instance of an type object and returns to edit handler$
$TODO: make more generic. There is some type specific code here for defaulting properties. Should build instance by using type specified fields/defaults$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
<link rel="stylesheet" type="text/css" href="../../www/farcry/navajo/navajo_popup.css">

<cfparam name="url.objectId" default="">

<cfif NOT isDefined("URL.typename")>
	<h3>URL.typename variable not provided</h3>
	<cfabort>
</cfif>

<cfif len(url.objectId)>
	<q4:contentobjectget  objectid="#url.objectId#" bactiveonly="False" r_stobject="stParent">
	<!--- permission check for objects --->
	<nj:getNavigation objectId="#stParent.objectID#" bInclusive="1" r_stObject="bob" r_ObjectId="objectId">
	
	<Cfif len(objectId)>
		<!--- <cfscript>
			oAuthorisation = request.dmSec.oAuthorisation;
			iObjectCreatePermission = oAuthorisation.checkPermission(permissionName="Create",reference="dmNavigation",bThrowOnError=1);
		</cfscript> --->	
		
		
		<cfset parentNavigationId=objectId>
	</CFIF>
	
<cfelse>
	<cfset temp=1>
</cfif>

<!--- make sure parent can hold an object before doing anything... --->	
<cfif len(url.objectId) AND not structKeyExists(stParent,"aObjectIds")>
	<cfoutput>
		You cannot create an object inside this object as it has no aObjectIds property.
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
	</cfscript>
	
	<!--- create the new OBJECT --->
	<cfif application.types['#url.typename#'].bCustomType>
		<q4:contentobjectcreate typename="#application.custompackagepath#.types.#URL.typename#" stproperties="#stProps#" r_objectid="NewObjID">
	<Cfelse>
		<q4:contentobjectcreate typename="#application.packagepath#.types.#URL.typename#" stproperties="#stProps#" r_objectid="NewObjID">
	</cfif>
			
	<!--- update parent object  --->
	<cfif len(url.objectId) AND not (arraytolist(stParent.aObjectIds) contains NewObjID)>
	
		<cfif url.typename eq "dmNavigation">
			
			<cfif stParent.typename neq "dmNavigation">
				<cfoutput><b>Cannot create navigation nodes in objects!</b></cfoutput>
				<cfabort>
			<cfelse>
				<!--- Insert this node into the tree --->
				<cfscript>
					oTree = createobject("component","#application.packagepath#.farcry.tree");
					qChildren = oTree.getChildren(objectid=stParent.objectID,typename=stParent.typename);
					position = qChildren.recordCount + 1;
					streturn = oTree.setChild(objectName=stProps.label,typename=typename,parentID=stParent.objectID,objectID=newObjId,pos=position);
				</cfscript>

			</cfif>
		<cfelse>
			<!--- Append new ObjectIDs to AObjects array --->
			<cfset noPurpose = arrayAppend(stParent.aObjectIds, NewObjID)>
			<cfscript>
				stParent.DATETIMECREATED =  createODBCDate("#datepart('yyyy',stParent.DATETIMECREATED)#-#datepart('m',stParent.DATETIMECREATED)#-#datepart('d',stParent.DATETIMECREATED)#");
				stParent.DATETIMELASTUPDATED = createODBCDate(now());
			</cfscript>
			
			<q4:contentobjectdata
			 typename="#application.packagepath#.types.#stParent.typename#"
			 stProperties="#stParent#"
			 objectid="#stParent.objectID#">
		</cfif>
		
		<cfif len(stParent.objectID)>
			<!--- Refresh the tree --->
			<nj:updateTree objectId="#stParent.objectID#" complete="0">
		</cfif>
	</cfif>
	
	<!--- Now that we know its type and new objectID go and edit the object now --->
	<cfoutput>
		<script>
			window.location="#application.url.farcry#/navajo/edit.cfm?objectId=#NewObjID#&type=#URL.typename#<cfif isDefined('url.finishUrl')>&finishUrl=#url.finishUrl#</cfif>";
		</script>
	</cfoutput>
	
</cfif>

<cfsetting enablecfoutputonly="No">