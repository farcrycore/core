<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/updateTree.cfm,v 1.12 2004/07/15 02:03:00 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 02:03:00 $
$Name: milestone_2-3-2 $
$Revision: 1.12 $

|| DESCRIPTION || 
$Description: Updates the tree view $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@curtin.edu.au)$

|| ATTRIBUTES ||
$in: objectid $
$out:$
--->
<cfprocessingDirective pageencoding="utf-8">
<cfoutput>
	<script language="JavaScript">
				
		// update tree

		if (top.frames['treeFrame'] && top.frames['treeFrame'].getObjectDataAndRender)	
		{
			top.frames['treeFrame'].getObjectDataAndRender( '#attributes.objectId#' );
		}	

	</script>

</cfoutput>
