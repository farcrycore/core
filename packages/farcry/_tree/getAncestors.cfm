<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/getAncestors.cfm,v 1.12 2003/10/26 23:32:52 brendan Exp $
$Author: brendan $
$Date: 2003/10/26 23:32:52 $
$Name: b201 $
$Revision: 1.12 $

|| DESCRIPTION || 
$Description: getAncestors Function $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfscript>
	/*sql = "select nlevel, parentid from nested_tree_objects 
	where objectid  = '#arguments.objectid#'";*/
	qNode = getNode(objectid=arguments.objectid,dsn=arguments.dsn);
	if (qNode.recordCount EQ 1 AND isDefined('qNode.nlevel'))
	{	rowindex=1;
		parentID = qNode.parentID;	
		nlevel = qNode.nlevel;
		//new query object to hold the parentIDs of ancestors
		qParentIDs = queryNew('parentID');
		queryAddRow(qParentIDs,1);
		querySetCell(qParentIDs,"parentID",parentID,rowindex);
		if (len(qParentIDs.parentID[1]))
			objectID = qParentIDs.parentID[1];	
		while(nLevel GT 0)
		{			
			sql = "select parentid
			from nested_tree_objects
			where objectid = '#objectid#'";
			q = query(sql=sql, dsn=arguments.dsn);
			if (q.recordCount)
			{	
				rowindex = rowindex + 1;
				queryAddRow(qParentIDs,1);
				querySetCell(qParentIDs,'parentID',q.parentID,rowindex);
			}	
			nLevel = nLevel - 1;
			objectID = q.parentID;
		}

		sql = "select objectid, objectname, nlevel from nested_tree_objects where objectID IN (#quotedValueList(qParentIDs.parentID)#)";
		// check if specific ancestor level is required
		if (isdefined("arguments.nLevel") and isNumeric(arguments.nLevel))
			sql = sql & "and nLevel = #arguments.nLevel#";
		ancestors = query(sql=sql, dsn=arguments.dsn);
	}
	else 
		ancestors = queryNew("objectid,parentid,typename,nleft,nright,nlevel,objectname");
</cfscript>  

<cfif arguments.bIncludeSelf>
	<cfquery datasource="#arguments.dsn#" name="qSelf">
	SELECT nlevel, objectid, objectname FROM #application.dbowner#nested_tree_objects
	WHERE objectid = '#arguments.objectid#'
	</cfquery>
	<cfset queryAddRow(ancestors, 1)>
	<cfset querySetCell(ancestors, "nlevel", qSelf.nlevel)>
	<cfset querySetCell(ancestors, "objectid", qSelf.objectid)>
	<cfset querySetCell(ancestors, "objectname", qSelf.objectname)>
</cfif>	

<!--- reorder, to put this at the front of the query --->
<cfquery dbtype="query" name="q">
SELECT * FROM ancestors
ORDER BY nlevel
</cfquery> 

<cfset ancestors = q>

<!--- set return variable --->
<cfset qReturn=ancestors>

<cfsetting enablecfoutputonly="no">