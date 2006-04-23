<!--- createDraftObject.cfm 

Creates a draft object

--->

<cfsetting enablecfoutputonly="no">
<cfimport taglib="/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/tags/navajo/" prefix="nj">
<cfoutput>
	<link rel="stylesheet" type="text/css" href="#application.url.farcry#/navajo/navajo_popup.css">
</cfoutput>


<cfparam name="url.objectId" default="">

<cfif len(url.objectId)>
	<cf_dmSec_PermissionCheck reference1="dmNavigation" permissionName="Create"  r_iState="bCreatePermission" bThrowOnError="0">
	
	<!--- Get this object so we can duplicate it --->
	<q4:contentobjectget objectid="#url.objectId#" bactiveonly="False" r_stobject="stObject">
	<!--- <cfinvoke component="fourq.fourq" returnvariable="thisTypename" method="findType" objectID="#url.ObjectId#"> --->
	<cfscript>
		stProps=structCopy(stObject);
		stProps.objectid = createUUID();
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
		stProps.versionID = URL.objectID;
	</cfscript>
	<q4:contentobjectcreate typename="#application.packagepath#.types.#stProps.TypeName#" stproperties="#stProps#" r_objectid="NewObjID">
	<cfoutput>
	<script>
		window.location="#application.url.farcry#/Navajo/edit.cfm?objectId=#NewObjID#&type=#stProps.typename#<cfif isDefined('url.finishUrl')>&finishUrl=#url.finishUrl#</cfif>";
	</script>
	</cfoutput>
</cfif>

