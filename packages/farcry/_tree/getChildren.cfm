<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_tree/getChildren.cfm,v 1.8.2.1 2006/01/18 23:46:54 paul Exp $
$Author: paul $
$Date: 2006/01/18 23:46:54 $
$Name: milestone_3-0-1 $
$Revision: 1.8.2.1 $

|| DESCRIPTION || 
$Description: getChildren Function $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfscript>
sql = "select objectid, objectname,nLeft,nRight,nLevel from #arguments.dbowner#nested_tree_objects
		where parentid =  '#arguments.objectid#'
		order by nleft";
children = query(sql=sql, dsn=arguments.dsn);		
</cfscript>

<!--- set return variable --->
<cfset qReturn=children>

<cfsetting enablecfoutputonly="no">