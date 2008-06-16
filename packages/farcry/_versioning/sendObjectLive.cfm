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
$Header: /cvs/farcry/core/packages/farcry/_versioning/sendObjectLive.cfm,v 1.16 2005/09/02 02:32:34 guy Exp $
$Author: guy $
$Date: 2005/09/02 02:32:34 $
$Name: milestone_3-0-1 $
$Revision: 1.16 $

|| DESCRIPTION || 
$Description: sends versioned object live $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">

<cfscript>
	stResult = structNew();
	stResult.result = false;
	stResult.message = 'No update has taken place';
	if (NOT isDefined("typename"))
	{
		q4 = createObject("component","farcry.core.packages.fourq.fourq");
		typename = q4.findType(objectid=objectid);
	}
	o = createObject("component",application.types[typename].typePath);	
</cfscript>

<cfif structKeyExists(stDraftObject,"versionID") AND NOT len(trim(stDraftObject.versionID)) EQ 0 >
	<!--- get the current Live Object to archive --->
	<!--- <cfset stLiveObject = o.getData(arguments.stDraftObject.versionID)> --->
	<!--- Convert current live object to WDDX for archive --->
	<!--- <cfwddx input="#stLiveObject#" output="stLiveWDDX"  action="cfml2wddx"> --->
	<!--- <cfset archiveObject(arguments.stDraftObject.versionID,typename)> --->

	<!--- <cfscript>
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
		else 
			stProps.label = stLiveObject.label;
		//end dmArchive struct  

	</cfscript> --->

	<cflock name="sendlive_#arguments.stDraftObject.versionID#" timeout="50" type="exclusive">

		<cfscript>
			//copy all container data to live object
			if (arguments.bCopyDraftContainers) {
				oCon = createobject("component","#application.packagepath#.rules.container");
				oCon.copyContainers(srcObjectID=arguments.stDraftObject.objectId,destObjectID=arguments.stDraftObject.versionID,bDeleteSrcData=1);
			}
			
			//this will copy categories from draft object to live
			oCategory = createobject("component","#application.packagepath#.farcry.category");
			oCategory.copyCategories(arguments.stDraftObject.objectid,arguments.stDraftObject.versionID);

			//Archive the object
//			oArchive = createobject("component","#application.packagepath#.types.dmArchive");
//			oArchive.createData(stProperties=stProps);
			archiveObject(arguments.stDraftObject.versionID,typename);
			
			//delete the old draft
			o.deleteData(objectid=arguments.stDraftObject.objectid);
			oCategory.deleteAssignedCategories(objectid=stDraftObject.objectid);
			
			//need to set stDraft object to live for fourq update. Update datetimeLastUpdated and clear out versionID
			arguments.stDraftObject.objectid = arguments.stDraftObject.versionID;
			arguments.stDraftObject.versionID = "";
			arguments.stDraftObject.dateTimeLastUpdated = createODBCDateTime(Now());
			arguments.stDraftObject.dateTimeCreated = createODBCDateTime(arguments.stDraftObject.dateTimeCreated);
			o.setData(stProperties=arguments.stDraftObject,auditNote='Draft version sent live');
			
			stResult.result = true;
			stResult.message = 'Update Successful';
			
		</cfscript>	
						
	</cflock>
	
</cfif>	