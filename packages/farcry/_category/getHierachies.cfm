<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_category/Attic/getHierachies.cfm,v 1.4 2003/08/08 04:23:36 brendan Exp $
$Author: brendan $
$Date: 2003/08/08 04:23:36 $
$Name: b201 $
$Revision: 1.4 $

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
	qRoot = application.factory.oTree.getRootNode(typename="categories");
	
	if (not qRoot.recordcount) {
		application.factory.oTree.setRootNode(typename="categories",objectid=createUUID(),objectName="root");
		qRoot = application.factory.oTree.getRootNode(typename="categories");
	}
	qHierarchies = application.factory.oTree.getChildren(objectid=qRoot.objectID);
</cfscript>