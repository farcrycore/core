<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_category/Attic/getHierachies.cfm,v 1.5 2003/12/08 05:39:11 paul Exp $
$Author: paul $
$Date: 2003/12/08 05:39:11 $
$Name: milestone_2-1-2 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfscript>
	// Get root node
	qRoot = request.factory.oTree.getRootNode(typename="categories");
	
	if (not qRoot.recordcount) {
		request.factory.oTree.setRootNode(typename="categories",objectid=createUUID(),objectName="root");
		qRoot = request.factory.oTree.getRootNode(typename="categories");
	}
	qHierarchies = request.factory.oTree.getChildren(objectid=qRoot.objectID);
</cfscript>