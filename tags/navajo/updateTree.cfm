<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/updateTree.cfm,v 1.9 2003/04/01 01:38:19 brendan Exp $
$Author: brendan $
$Date: 2003/04/01 01:38:19 $
$Name: b131 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: Updates the tree view $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: objectid $
$out:$
--->
<cfoutput>
	<script language="JavaScript">
		// check if called from a pop up window
		if( window.opener && window.opener.parent )
			 theparent=window.opener.parent;
		else 
		{
			theparent=parent;	
		}
		
		// update tree
		if (theparent["treeFrame"])	
			theparent["treeFrame"].getObjectDataAndRender( '#attributes.objectId#' );
		else
			parent.getObjectDataAndRender( '#attributes.objectId#' );
	</script>

</cfoutput>
