<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/getBloodLine.cfm,v 1.15 2003/04/23 06:59:25 paul Exp $
$Author: paul $
$Date: 2003/04/23 06:59:25 $
$Name: b131 $
$Revision: 1.15 $

|| DESCRIPTION || 
$Description: getBloodline Function $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfscript>
stArgsCopy = structCopy(stArgs);
// put all the objectids of the ancestors, plus the objectid of the object in question, 
qTemp = getAncestors(objectID=stArgs.objectID, dsn=stArgs.dsn);
stArgs = stArgsCopy;
sql = "select objectid, objectname, nlevel 	from nested_tree_objects where objectid = '#stArgs.objectid#'";
q = query(sql=sql, dsn=stArgs.dsn);

queryAddRow(qTemp);
querySetCell(qTemp,'objectid',q.objectid);
querySetCell(qTemp,'objectname',q.objectname);
querySetCell(qTemp,'nlevel',q.nlevel);

if (isDefined("stArgs.status") AND len(stArgs.status))
	statusClause = "where j.status in ('#ListChangeDelims(stArgs.Status,"','",",")#')";
else	
	statusClause = "where 1 = 1";
levelsabove = stArgs.levelsabove + 1;

sql = "select objectid from qTemp order by nlevel desc";
q = queryOfQuery(sql,levelsabove+1);	
vlParentID = quotedvalueList(q.objectid); //value list of objectids

sql = "select  objectid from qTemp	order by nlevel desc";
q = queryOfQuery(sql,levelsabove);
vlObjectID = quotedValueList(q.objectid);
		
//this gets the levels right
//build query
sql = "select distinct nto.*, j.* from nested_tree_objects nto
inner join #stArgs.joinTable# j on nto.objectid = j.objectid #statusClause#
and ( nto.parentid in (#vlParentID#) 
or nto.objectid in (#vlObjectID#)	)
order by nto.nleft";

bloodline = query(sql=sql, dsn=stArgs.dsn);
</cfscript>

<!--- set return variable --->
<cfset qReturn=bloodline>

<cfsetting enablecfoutputonly="no">