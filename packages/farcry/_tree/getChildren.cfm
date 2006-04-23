<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/getChildren.cfm,v 1.6 2003/09/10 12:21:48 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 12:21:48 $
$Name: b201 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: getChildren Function $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfscript>
sql = "select objectid, objectname from nested_tree_objects
		where parentid =  '#arguments.objectid#'
		order by nleft";
children = query(sql=sql, dsn=arguments.dsn);		
</cfscript>

<!--- set return variable --->
<cfset qReturn=children>

<cfsetting enablecfoutputonly="no">