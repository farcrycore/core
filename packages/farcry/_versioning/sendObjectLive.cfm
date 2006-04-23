<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_versioning/sendObjectLive.cfm,v 1.11.2.2 2004/07/16 11:26:30 geoff Exp $
$Author: geoff $
$Date: 2004/07/16 11:26:30 $
$Name: milestone_2-2-1 $
$Revision: 1.11.2.2 $

|| DESCRIPTION || 
$Description: sends versioned object live $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">

<cfscript>
	stResult = structNew();
	stResult.result = false;
	stResult.message = 'No update has taken place';
	if (NOT isDefined("typename"))
	{
		q4 = createObject("component","farcry.fourq.fourq");
		typename = q4.findType(objectid=objectid);
	}
	o = createObject("component",application.types[typename].typePath);	
</cfscript>
		
<cfif structKeyExists(stDraftObject,"versionID") AND NOT len(trim(stDraftObject.versionID)) EQ 0 >
	<!--- get the current Live Object to archive --->
	<cfscript>
		stLiveObject = o.getData(arguments.stDraftObject.versionID);
	</cfscript>		
	<!--- Convert current live object to WDDX for archive --->
	<cfwddx input="#stLiveObject#" output="stLiveWDDX"  action="cfml2wddx">

	<cfscript>
		//set up the dmArchive structure to save
		stProps = structNew();
		stProps.objectID = createUUID();
		stProps.archiveID = stLiveObject.objectID;
		stProps.objectWDDX = stLiveWDDX;
		stProps.lastupdatedby = session.dmSec.authentication.userlogin;
		stProps.datetimelastupdated = createODBCDateTime(Now());
		stProps.createdby = session.dmSec.authentication.userlogin;
		stProps.datetimecreated = createODBCDateTime(Now());
		// TODO: remove references to non-system attributes like TITLE from core
		if (structkeyexists(stliveobject, "title"))
			stProps.label = stLiveObject.title;
		//end dmArchive struct  

	</cfscript>

	<cflock name="sendlive_#stLiveObject.objectID#" timeout="50" type="exclusive">

		<cfscript>
			//copy all container data to live object
			oCon = createobject("component","#application.packagepath#.rules.container");
			//copy draft containers to live
			oCon.copyContainers(srcObjectID=arguments.stDraftObject.objectId,destObjectID=stLiveObject.objectID,bDeleteSrcData=1);
			//this will copy categories from draft object to live
			oCategory = createobject("component","#application.packagepath#.farcry.category");
			oCategory.copyCategories(arguments.stDraftObject.objectid,stLiveObject.objectID);
			//Archive the object
			oArchive = createobject("component","#application.packagepath#.types.dmArchive");
			oArchive.createData(stProperties=stProps);
			
			//delete the old draft
			o.deleteData(objectid=arguments.stDraftObject.objectid);
			oCategory.deleteAssignedCategories(objectid=stDraftObject.objectid);
			
			//need to set stDraft object to live for fourq update. Update datetimeLastUpdated and clear out versionID
			arguments.stDraftObject.objectid = stLiveObject.objectID;
			arguments.stDraftObject.versionID = "";
			arguments.stDraftObject.dateTimeLastUpdated = createODBCDateTime(Now());
			arguments.stDraftObject.dateTimeCreated = createODBCDateTime(arguments.stDraftObject.dateTimeCreated);
			o.setData(stProperties=arguments.stDraftObject,auditNote='Draft version sent live');
			
			stResult.result = true;
			stResult.message = 'Update Successful';
			
		</cfscript>	
						
	</cflock>
	
</cfif>	