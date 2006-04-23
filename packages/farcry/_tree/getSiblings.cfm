<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/getSiblings.cfm,v 1.6 2003/04/14 01:45:19 brendan Exp $
$Author: brendan $
$Date: 2003/04/14 01:45:19 $
$Name: b131 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: getSiblings Function $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfscript>
	// get parent
	parentSql = "select parentid from nested_tree_objects where objectid = '#arguments.objectid#'";
	qParent = query(sql=parentSQl, dsn=stArgs.dsn);	
	 
	// get siblings
	sql = "
		select objectid, objectname from nested_tree_objects
		where parentid =  '#qParent.parentid#'
		and objectid <> '#arguments.objectid#'
		order by nleft";
	siblings = query(sql=sql, dsn=stArgs.dsn);	   	
</cfscript>
	

<!--- set return variable --->
<cfset qReturn=siblings>

<cfsetting enablecfoutputonly="no">