<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_types/delete.cfm,v 1.7 2003/11/05 04:46:09 tom Exp $
$Author: tom $
$Date: 2003/11/05 04:46:09 $
$Name: milestone_2-1-2 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: Generic delete method. Checks for associated objects and deletes them, deletes actual object and deletes object from any verity collection if needed$
$TODO: Verity check/delete$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfscript>
	//Clean up containers
	lTypesWithContainers = 'dmHTML,dmInclude';
	if(listContainsNoCase(lTypesWithContainers,stObj.typename))
	{
		oCon = createObject('component','#application.packagepath#.rules.container');
		oCon.delete(objectid=stObj.objectid);
	}	

	// check for associated objects 
	if(structKeyExists(stObj,"aObjectIds")) {

		//loop over associated objects
		for(i=1; i LTE arrayLen(stObj.aObjectIds); i=i+1) {
			
			//work out typename
			objType = findType(stObj.aObjectIds[i]);
			
			// delete associated object
			oType = createObject("component", application.types[objType].typePath);
			oType.delete(stObj.aObjectIds[i]);
			
		}
	}
	
	// delete actual object
	deleteData(stObj.objectId);

	oConfig = createObject("component", "#application.packagepath#.farcry.config");
	if (NOT isDefined("application.config.verity"))
		application.config.verity = oConfig.getConfig("verity");
	// isolate the contenttypes to be indexed
	stCollections = application.config.verity.contenttype;
	
	// check if in verity collection
	if (structKeyExists(stCollections,stObj.typename)) {
		collectionName = application.applicationname & "_" & stObj.typename;
		application.factory.oVerity.deleteFromCollection(collection=collectionName,objectid=stObj.objectid);
	}
	</cfscript>
	
		
	
	
