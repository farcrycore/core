<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/getAncestors.cfm,v 1.7 2003/03/31 02:36:03 internal Exp $
$Author: internal $
$Date: 2003/03/31 02:36:03 $
$Name: b131 $
$Revision: 1.7 $

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
	sql = "select nlevel, parentid from nested_tree_objects 
	where objectid  = '#stArgs.objectid#'";
	q = query(sql=sql, dsn=stArgs.dsn);
	dump(q);
	if (q.recordCount) {
	parentID = q.parentID;	
	nlevel = q.nlevel;
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
		q = query(sql=sql, dsn=stArgs.dsn);
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
	ancestors = query(sql=sql, dsn=stArgs.dsn);
	}
	else 
		ancestors = queryNew("objectid, objectname, nlevel");
</cfscript>  

<cfif stArgs.bIncludeSelf>
	<cfquery datasource="#stArgs.dsn#" name="qSelf">
	SELECT nlevel, objectid, objectname FROM #application.dbowner#nested_tree_objects
	WHERE objectid = '#stArgs.objectid#'
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