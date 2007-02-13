<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_tree/getAncestors.cfm,v 1.15.2.1 2006/02/24 04:50:20 tlucas Exp $
$Author: tlucas $
$Date: 2006/02/24 04:50:20 $
$Name: milestone_3-0-1 $
$Revision: 1.15.2.1 $

|| DESCRIPTION || 
$Description: getAncestors Function $


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
		nlev = qNode.nlevel;
		//new query object to hold the parentIDs of ancestors
		qParentIDs = queryNew('parentID');
		queryAddRow(qParentIDs,1);
		querySetCell(qParentIDs,"parentID",parentID,rowindex);
		if (len(qParentIDs.parentID[1]))
			objID = qParentIDs.parentID[1];	
		while(nLev GT 0)
		{			
			sql = "select parentid from #arguments.dbowner#nested_tree_objects	where objectid = '#objID#'";
			q = query(sql=sql, dsn=arguments.dsn);
			if (q.recordCount EQ 1)
			{	
				rowindex = rowindex + 1;
				queryAddRow(qParentIDs,1);
				querySetCell(qParentIDs,'parentID',q.parentID,rowindex);
			}	
			nLev = nLev - 1;
			objID = q.parentID;
		}

		sql = "select objectid, objectname, nlevel from #arguments.dbowner#nested_tree_objects where objectID IN (#quotedValueList(qParentIDs.parentID)#)";
		// check if specific ancestor level is required
		if (isdefined("arguments.nLevel") and isNumeric(arguments.nLevel))
			sql = sql & "and nLevel = #arguments.nLevel#";
		ancestors = query(sql=sql, dsn=arguments.dsn);
	}
	else 
		ancestors = queryNew("objectid, objectname, nlevel");
</cfscript>  

<cfif arguments.bIncludeSelf>
	<cfquery datasource="#arguments.dsn#" name="qSelf">
	SELECT nlevel, objectid, objectname FROM #application.dbowner#nested_tree_objects
	WHERE objectid = '#arguments.objectid#'
	</cfquery>
	<cfif qSelf.recordCount>
		<cfset queryAddRow(ancestors, 1)>
		<cfset querySetCell(ancestors, "nlevel", qSelf.nlevel)>
		<cfset querySetCell(ancestors, "objectid", qSelf.objectid)>
		<cfset querySetCell(ancestors, "objectname", qSelf.objectname)>
	</cfif>
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