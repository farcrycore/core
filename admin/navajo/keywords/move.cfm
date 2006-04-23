<cflock name="moveBranchNTM" type="EXCLUSIVE" timeout="3" throwontimeout="Yes">
	<cfscript>
		request.factory.oTree.moveBranch(objectID=URL.srcObjectID,parentID=URL.destObjectID);
		qGetParent = request.factory.oTree.getParentID(objectid = url.srcObjectID);
		srcParentObjectID = qGetparent.parentID;
	</cfscript>	
</cflock>
<cfoutput>
<script>
	parent.updateTree(src='#srcParentObjectID#',dest='#url.destObjectid#');
</script>
</cfoutput>