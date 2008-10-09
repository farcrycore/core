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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||

$Header: /cvs/farcry/core/webtop/navajo/keywords/hierarchyedit.cfm,v 1.17.2.1 2006/01/16 22:55:42 gstewart Exp $
$Author: gstewart $
$Date: 2006/01/16 22:55:42 $
$Name: milestone_3-0-1 $
$Revision: 1.17.2.1 $

|| DESCRIPTION || 
$Description: Displays category tree $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfprocessingDirective pageencoding="utf-8">
<cfoutput>
<html>
	<head>
		<link rel="stylesheet" type="text/css" href="#application.url.farcry#/css/admin.css">
	</head>
</html>
<body>
	
</cfoutput>

<cfscript>
	oCat = createObject("component","#application.packagepath#.farcry.category");
</cfscript>

<!--- CREATE NEW HIERARCHY --->

<cfif isDefined("message")>
	<cfoutput>
		<h4 align="center" style="color:red">#message#</h4>
	</cfoutput>
</cfif>

<cfinvoke component="#application.packagepath#.farcry.category" method="getHierarchies"  returnvariable="qHierachies">
<cfoutput>
<script>
	function showTree(id)
	{		
		strURL = '#application.url.farcry#/navajo/keywords/tree.cfm?rootobjectid='+id;
		frames.cattreeframe.location.href = strURL;
				
	}	
</script>
</cfoutput>
<cfscript>
	qrootObjectID = application.factory.oTree.getRootNode(typename='dmCategory');
	catRootObjectID = qrootObjectID.objectID;
</cfscript>

<cfoutput><table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td></cfoutput>
			<cfinvoke component="#application.packagepath#.farcry.category" method="getHierarchies"  returnvariable="qHierarchies">
			<cfoutput>
			<form action="" method="post">
			#application.rb.getResource("categorytree.labels.existingHierarchies@label","Existing Hierarchies")#:
			<select name="hierarchyID" class="formfield" onchange="showTree(this.value);">
			<option value="#catRootObjectID#">#application.rb.getResource("categorytree.labels.showAllHierarchies@label","Show All Hierarchies")#
			<cfloop query="qHierarchies">
				<option value="#objectID#">#objectName#</option>
			</cfloop>
			</select> 
			</form>
		</td>
	</tr>
	<tr>
		<td></td>
	</tr>
</table>		


<div style="float:left;width:45%;height:96%;margin:0px">
	<iframe name="cattreeframe" width="100%" height="100%" id="cattreeframe" style="display:inline;" src="#application.url.farcry#/navajo/keywords/tree.cfm" scrolling="auto" frameborder="0"></iframe>
</div>
<div style="float:right;width:45%;height:90%">
	<iframe style="display:inline;" width="100%" height="100%" name="cateditframe" id="cateditframe" src="#application.url.farcry#/navajo/keywords/overview.cfm" scrolling="Auto" frameborder="0"></iframe> 			
</div>

</body>
</html>
</cfoutput>

