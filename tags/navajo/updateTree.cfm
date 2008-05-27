<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/navajo/updateTree.cfm,v 1.14 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
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
