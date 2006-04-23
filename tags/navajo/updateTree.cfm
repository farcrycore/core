<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/updateTree.cfm,v 1.11 2003/10/01 01:51:23 paul Exp $
$Author: paul $
$Date: 2003/10/01 01:51:23 $
$Name: b201 $
$Revision: 1.11 $

|| DESCRIPTION || 
$Description: Updates the tree view $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@curtin.edu.au)$

|| ATTRIBUTES ||
$in: objectid $
$out:$
--->
<cfoutput>
	<script language="JavaScript">
				
		// update tree

		if (top.frames['treeFrame'] && top.frames['treeFrame'].getObjectDataAndRender)	
		{
			top.frames['treeFrame'].getObjectDataAndRender( '#attributes.objectId#' );
		}	

	</script>

</cfoutput>
