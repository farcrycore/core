<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||

$Header: /cvs/farcry/farcry_core/admin/navajo/keywords/hierarchyedit.cfm,v 1.17 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-0 $
$Revision: 1.17 $

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
		document.frames.cattreeframe.location.href = strURL;
				
	}	
</script>
</cfoutput>
<cfscript>
	qrootObjectID = request.factory.oTree.getRootNode(typename='categories');
	catRootObjectID = qrootObjectID.objectID;
</cfscript>

 <table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td>
			<cfinvoke component="#application.packagepath#.farcry.category" method="getHierarchies"  returnvariable="qHierarchies">

			<form action="" method="post">
			<cfoutput>#application.adminBundle[session.dmProfile.locale].existingHierarchies#</cfoutput>
			<select name="hierarchyID" class="formfield" onchange="showTree(this.value);">
			<cfoutput><option value="#catRootObjectID#">#application.adminBundle[session.dmProfile.locale].showAllHierarchies#</cfoutput>
			<cfoutput query="qHierarchies">
				<option value="#objectID#">#objectName#</option>
			</cfoutput>
			</select> 
			</form>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
</table>		

<cfoutput>
<div>
	<iframe name="cattreeframe" width="250" height="100%" id="cattreeframe" style="display:inline;" src="#application.url.farcry#/navajo/keywords/tree.cfm" scrolling="No" frameborder="0"></iframe>
	<iframe style="display:inline;" width="400" height="100%" name="cateditframe" id="cateditframe" src="#application.url.farcry#/navajo/keywords/overview.cfm" scrolling="Auto" frameborder="0"></iframe> 
</div>
</body>
</html>
</cfoutput>

