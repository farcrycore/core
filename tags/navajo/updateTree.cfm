<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/updateTree.cfm,v 1.14 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-0 $
$Revision: 1.14 $

|| DESCRIPTION || 
$Description: Updates the tree view $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@curtin.edu.au)$

|| ATTRIBUTES ||
$in: objectid $
$out:$
--->
<cfprocessingDirective pageencoding="utf-8"><cfoutput>
<script type="text/javascript">		
// update tree
if(parent['sidebar'].frames['sideTree'] && parent['sidebar'].frames['sideTree'].getObjectDataAndRender)
	parent['sidebar'].frames['sideTree'].getObjectDataAndRender('#attributes.objectId#');
//if (top.frames['sideTree'] && top.frames['treeFrame'].getObjectDataAndRender){
//	top.frames['treeFrame'].getObjectDataAndRender( '#attributes.objectId#' );

</script></cfoutput>
