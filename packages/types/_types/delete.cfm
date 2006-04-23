<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_types/delete.cfm,v 1.1 2003/03/31 06:35:31 brendan Exp $
$Author: brendan $
$Date: 2003/03/31 06:35:31 $
$Name: b131 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: Generic delete method. Checks for associated objects and deletes them, deletes actual object and deletes object from any verity collection if needed$
$TODO: Verity check/delete$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfscript>
	// check for associated objects 
	if(structKeyExists(stObj,"aObjectIds")) {

		//loop over associated objects
		for(i=1; i LTE arrayLen(stObj.aObjectIds); i=i+1) {
			
			//work out typename
			objType = findType(stObj.aObjectIds[i]);
			
			// delete associated object
			oType = createObject("component","#application.packagepath#.types.#objType#");
			oType.delete(stObj.aObjectIds[i]);
			
		}
	}
	
	// delete actual object
	deleteData(stObj.objectId);
	
	// check if in verity collection
	
	// delete from verity
</cfscript>