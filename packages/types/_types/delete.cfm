<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_types/delete.cfm,v 1.9 2004/06/24 01:30:11 paul Exp $
$Author: paul $
$Date: 2004/06/24 01:30:11 $
$Name: milestone_2-2-1 $
$Revision: 1.9 $

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

	// delete categories
	oCategories = createObject('component','#application.packagepath#.farcry.category');
	oCategories.deleteAssignedCategories(objectid=stObj.objectid);
	
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

	// if this objecttype is used in tree, then it may have been used as a related link in dmHTML_aRelatedIDs 
	if (structKeyExists(application.types[stObj.typename],"bUseInTree"))
	{
		if (isBoolean(application.types[stObj.typename].bUseInTree) AND application.types[stObj.typename].bUseInTree)
		{
			oHTML = createObject("component",application.types['dmHTML'].typepath);
			oHTML.deleteRelatedIds(objectid=stObj.objectid);
		}
	
	}
		
	</cfscript>
	
	
		
	
	
