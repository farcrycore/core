<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmnavigation/delete.cfm,v 1.11.6.2 2005/04/21 06:24:29 paul Exp $
$Author: paul $
$Date: 2005/04/21 06:24:29 $
$Name: milestone_2-3-2 $
$Revision: 1.11.6.2 $

|| DESCRIPTION || 
$Description: Specific delete method for dmNavigation. Deletes all descendants aswell as cleaning up verity collections$
$TODO: Verity check/delete$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfscript>

	// get descendants
	qGetDescendants = request.factory.oTree.getDescendants(objectid=stObj.objectID);
	oNavigation = createObject("component", application.types.dmNavigation.typePath);
	
	// delete actual object
	super.delete(stObj.objectId);
	
	// delete fu
	if (application.config.plugins.fu) {
		fuUrl = application.factory.oFU.getFU(objectid=stObj.objectid);
		application.factory.oFU.deleteFu(fuUrl);
	}
	
	// delete branch
	request.factory.oTree.deleteBranch(objectid=stObj.objectID);
	
	// remove permissions
	oAuthorisation = request.dmSec.oAuthorisation;
	oAuthorisation.deletePermissionBarnacle(objectid=stObj.objectID);
	
	// check for associated objects 
	if(structKeyExists(stObj,"aObjectIds") and arrayLen(stObj.aObjectIds)) {

		// loop over associated objects
		for(i=1; i LTE arrayLen(stObj.aObjectIds); i=i+1) {
			
			// work out typename
			objType = findType(stObj.aObjectIds[i]);
			if (len(objType)) {
				// delete associated object
				oType = createObject("component", application.types[objType].typePath);
				oType.delete(stObj.aObjectIds[i]);
			}
		}
	}

	// loop over descendants
	if (qGetDescendants.recordcount) {
		for(loop0=1; loop0 LTE qGetDescendants.recordcount; loop0=loop0+1) {
			
			//get descendant data
			objDesc = getData(qGetDescendants.objectId[loop0]);
			
			// delete associated descendants
			if (arrayLen(objDesc.aObjectIds)) {
		
				// loop over associated objects
				for(i=1; i LTE arrayLen(objDesc.aObjectIds); i=i+1) {
				
					// work out typename
					objType = findType(objDesc.aObjectIds[i]);
					if (len(objType)) {
						// delete associated object
						oType = createObject("component", application.types[objType].typePath);
						oType.delete(objDesc.aObjectIds[i]);
					}
				}
			}
			
			// delete fu
			if (application.config.plugins.fu) {
				fuUrl = application.factory.oFU.getFU(objectid=qGetDescendants.objectId[loop0]);
				application.factory.oFU.deleteFu(fuUrl);
			}
			
			// remove permissions
			oAuthorisation.deletePermissionBarnacle(objectid=qGetDescendants.objectId[loop0]);
			
			// delete descendant
			super.delete(qGetDescendants.objectId[loop0]);	
		
		}
	}
	
	// check if in verity collection
	
	// delete from verity
</cfscript>