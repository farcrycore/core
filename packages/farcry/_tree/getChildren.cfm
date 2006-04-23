<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/getChildren.cfm,v 1.8 2005/10/28 03:44:39 paul Exp $
$Author: paul $
$Date: 2005/10/28 03:44:39 $
$Name: milestone_3-0-0 $
$Revision: 1.8 $

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
sql = "select objectid, objectname from #arguments.dbowner#nested_tree_objects
		where parentid =  '#arguments.objectid#'
		order by nleft";
children = query(sql=sql, dsn=arguments.dsn);		
</cfscript>

<!--- set return variable --->
<cfset qReturn=children>

<cfsetting enablecfoutputonly="no">