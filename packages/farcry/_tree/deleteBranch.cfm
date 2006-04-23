<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/deleteBranch.cfm,v 1.13 2005/10/28 04:15:56 paul Exp $
$Author: paul $
$Date: 2005/10/28 04:15:56 $
$Name: milestone_3-0-1 $
$Revision: 1.13 $

|| DESCRIPTION || 
$Description: deleteBranch Function $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- set positive result --->
<cfset stTmp.bSucess = "true">
<cfset stTmp.message = "Branch deleted.">

<cftry> 

	<cfscript>
	
	//delete a node, and its descendants
	//preserve old nleft for later
	sql = "
	select nleft, typename from #arguments.dbowner#nested_tree_objects where objectid = '#arguments.objectid#'";
	q = query(sql=sql, dsn=arguments.dsn);
	
	oldleft = q.nleft;
	typename = q.typename;
	
	// get nleft
	nLeftSql = "select nleft from #arguments.dbowner#nested_tree_objects where objectid = '#arguments.objectid#' and typename = '#typename#'";
	qNLeft = query(sql=nLeftSql, dsn=arguments.dsn);
	
	// get nright
	nRightSql = "select nright from #arguments.dbowner#nested_tree_objects where objectid = '#arguments.objectid#' and typename = '#typename#'";
	qNRight = query(sql=nRightSql, dsn=arguments.dsn);
	
	// get the number of objects that are descendants of the object, plus the object itself. times 2, so that we can 
	// move the lefts and rights back of the remaining nodes.
	sql = "
		select count(*)*2 AS objCount
		from #arguments.dbowner#nested_tree_objects
		where nleft between #qNleft.nleft#
		and #qNRight.nright# 
		and typename = '#typename#'";
	q = query(sql=sql, dsn=arguments.dsn);	
	count = q.objCount;
	
	// delete the object itself, and its spawn
	sql = "
		delete from #arguments.dbowner#nested_tree_objects
		where objectid = '#arguments.objectid#'
		or nleft between #qNleft.nleft#
		and #qNRight.nright# 
		and typename = '#typename#'";
	query(sql=sql, dsn=arguments.dsn);	
	
	// contract the other nodes left hands
	sql = "
		update #arguments.dbowner#nested_tree_objects
		set 	nleft = nleft - #count#
		where  nleft > #oldleft#
		and typename = '#typename#'";
	query(sql=sql, dsn=arguments.dsn);	
	
	// contract the other nodes right hands
	sql = "
		update #arguments.dbowner#nested_tree_objects
		set 	nright = nright - #count#
		where  nright > #oldleft#
		and typename = '#typename#'";
	query(sql=sql, dsn=arguments.dsn);	
	</cfscript>

	<cfcatch>
		<!--- set negative result --->
		<cfset stTmp.bSucess = "false">
		<cfset stTmp.message = cfcatch>
		<cfdump var="#cfcatch#"><cfabort>
	</cfcatch>

</cftry>

<!--- set return variable --->
<cfset stReturn=stTmp>
