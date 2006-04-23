<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/navajo/keywords/hierarchyedit.cfm,v 1.10 2003/05/16 01:47:32 brendan Exp $
$Author: brendan $
$Date: 2003/05/16 01:47:32 $
$Name: b131 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: Displays category tree $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfoutput>
	<link rel="stylesheet" type="text/css" href="#application.url.farcry#/css/admin.css">
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
	oTree = createObject('component',"#application.packagepath#.farcry.tree");
	qrootObjectID = oTree.getRootNode(typename='categories');
	catRootObjectID = qrootObjectID.objectID;
</cfscript>

 <table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td>
			<cfinvoke component="#application.packagepath#.farcry.category" method="getHierarchies"  returnvariable="qHierarchies">

			
			Existing Hierarchies:
			<select name="hierarchyID" class="formfield" onchange="showTree(this.value);">
				<cfoutput><option value="#catRootObjectID#">Show All Hierarchies</cfoutput>
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
<iframe width="300" height="100%" id="cattreeframe" style="display:inline" src="#application.url.farcry#/navajo/keywords/tree.cfm" scrolling="No" frameborder="0"></iframe>
<iframe style="display:inline;" width="400" height="100%" id="cateditframe" src="#application.url.farcry#/navajo/keywords/overview.cfm" scrolling="Auto" frameborder="0"></iframe> 
</div>
</cfoutput>

