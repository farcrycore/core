<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/getSecondaryNav.cfm,v 1.9 2005/10/28 04:17:51 paul Exp $
$Author: paul $
$Date: 2005/10/28 04:17:51 $
$Name: milestone_3-0-1 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: getSecondaryNav Function $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfscript>
	// from given objectid, 2 things could happen. 
	// If it is a leaf (has no children), return its grandparent, aunts and uncles, and siblings (no cousins). 
	// If not, return its parent, siblings and children. In both cases, return object in amongst the result
	
   
	//if object is a leaf, there will be no room between its left and right values
	sql = "select  nleft, nright from #arguments.dbowner#nested_tree_objects where objectid = '#arguments.objectid#'";
	q = query(sql=sql, dsn=arguments.dsn);
	nleft = q.nleft;
	nright = q.nright;
	
	if (nleft + 1 EQ nright)
		leaf = 1;
	else
		leaf = 0;
	
	// get parent	
	sql = "select parentid from #arguments.dbowner#nested_tree_objects where objectid = '#arguments.objectid#'";
	qParent = query(sql=sql, dsn=arguments.dsn);
	parent = qParent.parentId;	
	
	//get its grandparent. we will need this for both cases.
	sql =  "
		select parentid from #arguments.dbowner#nested_tree_objects
		where objectid = '#parent#'";
	q = query(sql=sql, dsn=arguments.dsn);	
	grandpa = q.parentID;	
	
	if (leaf EQ 1) // the object has no children. 
	{
		//get its parents, (uncles and aunts) and siblings. First the parents and uncles
		// + now the siblings (includes object itself)
		//+ grandpa
		sql = "
		select objectid, objectname, nlevel, nleft, 1 as leaf from #arguments.dbowner#nested_tree_objects
		where parentid =  '#grandpa#'
		union 
		select objectid, objectname, nlevel, nleft, 1 as leaf from #arguments.dbowner#nested_tree_objects
		where parentid =  '#parent#'
		union
		select objectid, objectname, nlevel, nleft, 1 as leaf from #arguments.dbowner#nested_tree_objects
		where objectid =  '#grandpa#'
		order by  nleft";
	}
	else
	{
		// get its parent,  siblings and children. First the parent     	
		//+ get the object itself, just in case it's the root (no parent or siblings) 
		//+  plus its children
		sql = "
		select objectid, objectname, nlevel, nleft from #arguments.dbowner#nested_tree_objects
		where objectid =  '#parent#'
		union  
		select objectid, objectname, nlevel, nleft from #arguments.dbowner#nested_tree_objects
		where objectid =  '#arguments.objectID#'
		union  
		select objectid, objectname, nlevel, nleft from #arguments.dbowner#nested_tree_objects
		where parentid =  '#parent#'
		union 
		select objectid, objectname, nlevel, nleft from #arguments.dbowner#nested_tree_objects
		where parentid =  '#arguments.objectid#'
		order by  nleft";
	}	
	secondaryNav = query(sql=sql, dsn=arguments.dsn);
</cfscript>

<!--- set return variable --->
<cfset qReturn=secondaryNav>

<cfsetting enablecfoutputonly="no">