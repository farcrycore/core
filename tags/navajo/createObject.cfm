<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/tags/navajo/" prefix="nj">
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
	<cf_dmSec2_PermissionCheck
		permissionName="Create"
		objectId="#objectId#"
		reference1="dmNavigation"
		bThrowOnError="1">
	<cfset parentNavigationId=objectId>
	</CFIF>
	
<cfelse>
	<!---cf_dmSec2_PermissionCheck
		permissionName="Create"
		objectId="#objectId#"
		bThrowOnError="1"--->
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
	
	<!--- Get the typename of the new object we are editing --->
		
	<!--- create the new OBJECT --->
	<q4:contentobjectcreate typename="#application.packagepath#.types.#URL.typename#" stproperties="#stProps#" r_objectid="NewObjID">
			
	<!--- update parent object  --->
	<cfif len(url.objectId) AND not (arraytolist(stParent.aObjectIds) contains NewObjID)>
	
		<cfif url.typename eq "dmNavigation">
			
			<cfif stParent.typename neq "dmNavigation">
				<cfoutput><b>Cannot create navigation nodes in objects!</b></cfoutput>
				<cfabort>
			<cfelse>
				<!--- <cfset noPurpose = arrayAppend(stParent.aNavChild, NewObjID)> --->
					<!--- Insert this node into the tree --->
					<cfinvoke component="fourq.utils.tree.tree" method="setChild" objectName = "#stProps.label#"	 typename = "#typename#" parentID="#stParent.objectID#"	 objectID="#newObjID#"	 pos = "1" returnvariable="stReturn">

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
			<nj:UpdateTree objectId="#stParent.objectID#" complete="0">
		</cfif>
	</cfif>
	<cfoutput>
	<!--- Now that we know its type and new objectID go and edit the object now --->
	<script>
		window.location="#application.url.farcry#/Navajo/edit.cfm?objectId=#NewObjID#&type=#URL.typename#<cfif isDefined('url.finishUrl')>&finishUrl=#url.finishUrl#</cfif>";
	</script>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="No">