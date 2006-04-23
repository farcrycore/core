<cfprocessingDirective pageencoding="utf-8">

<cflock name="moveBranchNTM" type="EXCLUSIVE" timeout="3" throwontimeout="Yes">
	<cfscript>
		request.factory.oTree.moveBranch(objectID=URL.srcObjectID,parentID=URL.destObjectID);
		qGetParent = request.factory.oTree.getParentID(objectid = url.srcObjectID);
		srcParentObjectID = qGetparent.parentID;
	</cfscript>	
</cflock>
<cfoutput>
<script>
	srcobjid='#URL.srcObjectID#';	
	destNavObjectId ='#url.destObjectId#';	
	//parent.updateTree(src=srcobjid,dest=destNavObjectId,srcobj='#url.srcObjectid#');
	parent.location.reload();
</script>
</cfoutput>