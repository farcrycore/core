<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/getBloodLine.cfm,v 1.18 2003/09/12 06:15:00 paul Exp $
$Author: paul $
$Date: 2003/09/12 06:15:00 $
$Name: b201 $
$Revision: 1.18 $

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

// put all the objectids of the ancestors, plus the objectid of the object in question, 
qTemp = getAncestors(objectID=arguments.objectID, dsn=arguments.dsn);

sql = "select objectid, objectname, nlevel 	from nested_tree_objects where objectid = '#arguments.objectid#'";
q = query(sql=sql, dsn=arguments.dsn);

queryAddRow(qTemp);
querySetCell(qTemp,'objectid',q.objectid);
querySetCell(qTemp,'objectname',q.objectname);
querySetCell(qTemp,'nlevel',q.nlevel);


if (isDefined("arguments.status") AND len(arguments.status))
	statusClause = "where j.status in ('#ListChangeDelims(arguments.Status,"','",",")#')";

else	
	statusClause = "where 1 = 1";
levelsabove = arguments.levelsabove + 1;

sql = "select objectid from qTemp order by nlevel desc";
q = queryOfQuery(sql,levelsabove+1);	
vlParentID = quotedvalueList(q.objectid); //value list of objectids

sql = "select  objectid from qTemp	order by nlevel desc";
q = queryOfQuery(sql,levelsabove);
vlObjectID = quotedValueList(q.objectid);
		
//this gets the levels right
//build query
sql = "select distinct nto.*, j.* from nested_tree_objects nto
inner join #arguments.joinTable# j on nto.objectid = j.objectid #statusClause#
and ( nto.parentid in (#vlParentID#) 
or nto.objectid in (#vlObjectID#)	)
order by nto.nleft";

bloodline = query(sql=sql, dsn=arguments.dsn);
</cfscript>

<!--- set return variable --->
<cfset qReturn=bloodline>

<cfsetting enablecfoutputonly="no">