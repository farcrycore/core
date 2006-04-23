<cfscript>
	oTree = createObject("component","#application.packagepath#.farcry.tree");
</cfscript>
<cflock name="moveBranchNTM" type="EXCLUSIVE" timeout="3" throwontimeout="Yes">
	<cfscript>
		oTree.moveBranch(objectID=URL.srcObjectID,parentID=URL.destObjectID);
		qGetParent = oTree.getParentID(objectid = url.srcObjectID);
		srcParentObjectID = qGetparent.parentID;
	</cfscript>	
</cflock>
<cfoutput>
<script>
	parent.getObjectDataAndRender( '#URL.rootObjectID#' );
	<!--- <cfif len(srcParentObjectId)>
		parent.getObjectDataAndRender( '#srcParentObjectID#' );
	</cfif> --->
</script>
</cfoutput>